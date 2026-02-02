// lib/services/supabase_sync_service.dart
import 'dart:async';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';
import '../app_globals.dart' show notifySyncComplete;

/// ============================================================================
/// OPTIMIZED SUPABASE SYNC SERVICE WITH STAR TOPOLOGY SUPPORT
/// ============================================================================
///
/// Key Features:
/// - UUID cache for faster foreign key resolution
/// - Local integer IDs ↔ Cloud UUIDs mapping
/// - Star topology aware: Commissary syncs all, Franchisee syncs own data
/// - Parallel batch operations where possible
/// - Exponential backoff with jitter for retries
/// - Connection pooling and request coalescing
/// - Progress tracking with granular updates
/// - Selective sync based on organization context
/// - RLS-aware: Requires authenticated user for sync operations
/// ============================================================================
class SupabaseSyncService {
  final AppDatabase db;
  final SupabaseClient supabase;

  Timer? _syncTimer;
  bool _isSyncing = false;
  bool _isOnline = true;
  DateTime? _lastSuccessfulSync;
  StreamSubscription? _connectivitySubscription;

  // ✅ UUID cache for O(1) lookups
  final Map<String, Map<int, String>> _localToCloudCache = {
    'organizations': {},
    'roles': {},
    'users': {},
    'items': {},
    'ingredients': {},
    'recipe_ingredients': {},
    'stock_replenishment_requests': {},
    'stock_change_requests': {},
    'daily_sales_summary': {},
    'branch_ingredient_stock': {},
    'branch_item_stock': {},
  };

  // ✅ Reverse cache for cloud to local lookups
  final Map<String, Map<String, int>> _cloudToLocalCache = {
    'organizations': {},
    'roles': {},
    'users': {},
    'items': {},
    'ingredients': {},
    'recipe_ingredients': {},
    'stock_replenishment_requests': {},
    'stock_change_requests': {},
    'daily_sales_summary': {},
    'branch_ingredient_stock': {},
    'branch_item_stock': {},
  };

  // ✅ Configuration - Optimized values
  static const Duration syncInterval = Duration(minutes: 5);
  static const int batchSize = 50; // Reduced for faster response
  static const int maxRetries = 3;
  static const Duration initialRetryDelay = Duration(seconds: 1);
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration requestTimeout = Duration(seconds: 30);

  // ✅ Organization context for star topology
  int? _currentOrganizationId;
  String? _currentOrganizationCloudId;
  String? _currentOrganizationType; // 'commissary' or 'franchisee'
  int? _parentCommissaryId;
  String? _parentCommissaryCloudId;

  // Callbacks for UI updates
  Function(bool isOnline)? onConnectivityChanged;
  Function(String status)? onSyncStatusChanged;
  Function(String error)? onSyncError;
  Function(double progress, String tableName)? onSyncProgress;
  Function()? onSyncComplete;

  final Uuid _uuid = const Uuid();

  /// Get the client to use for sync operations
  /// Uses the main supabase client which respects RLS policies
  /// Sync operations require an authenticated user session
  SupabaseClient get _syncClient {
    // Check if user is authenticated
    if (supabase.auth.currentUser == null) {
      if (kDebugMode) {
        AppLogger.sync('⚠️ Sync client: No authenticated user - some operations may fail');
      }
    }
    return supabase;
  }

  /// Check if sync is allowed (user must be authenticated)
  bool get canSync => supabase.auth.currentUser != null;

  SupabaseSyncService({
    required this.db,
    required this.supabase,
    this.onConnectivityChanged,
    this.onSyncStatusChanged,
    this.onSyncError,
    this.onSyncProgress,
    this.onSyncComplete,
  });

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize sync service with organization context
  Future<void> initialize({
    int? organizationId,
    String? organizationCloudId,  // ✅ Accept cloud ID directly
    String? organizationType,
    int? parentCommissaryId,
    String? parentCommissaryCloudId,  // ✅ Accept cloud ID directly
  }) async {
    AppLogger.sync('🚀 Initializing optimized sync service...');

    try {
      // Set organization context for star topology
      _currentOrganizationId = organizationId;
      _currentOrganizationCloudId = organizationCloudId;  // ✅ Use directly if provided
      _currentOrganizationType = organizationType;
      _parentCommissaryId = parentCommissaryId;
      _parentCommissaryCloudId = parentCommissaryCloudId;  // ✅ Use directly if provided

      // Check initial connectivity
      _isOnline = await _checkConnectivity();
      onConnectivityChanged?.call(_isOnline);

      // Build UUID caches from local database
      await _buildCaches();

      // Load organization cloud IDs
      await _loadOrganizationCloudIds();

      // Start periodic sync
      startPeriodicSync();

      // Listen to connectivity changes
      _connectivitySubscription?.cancel();
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
        _handleConnectivityChange,
      );

      // Initial sync if online
      if (_isOnline) {
        // Delay initial sync slightly to let UI settle
        Future.delayed(const Duration(seconds: 2), () => syncAll());
      }

      print(
        '✅ Sync service initialized (${_currentOrganizationType ?? 'unknown'} mode)',
      );
    } catch (e, stackTrace) {
      AppLogger.sync('❌ Failed to initialize sync service: $e');
      if (kDebugMode) print(stackTrace);
      onSyncError?.call('Initialization failed: $e');
    }
  }

  /// Handle connectivity changes
  void _handleConnectivityChange(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;

    if (wasOnline != _isOnline) {
      onConnectivityChanged?.call(_isOnline);

      if (_isOnline) {
        AppLogger.sync('📡 Network restored, triggering sync...');
        syncAll();
      } else {
        AppLogger.sync('🔵 Network lost');
        onSyncStatusChanged?.call('Offline');
      }
    }
  }

  /// Load organization cloud IDs for context (only if not already set)
  Future<void> _loadOrganizationCloudIds() async {
    if (_currentOrganizationCloudId == null && _currentOrganizationId != null) {
      _currentOrganizationCloudId = _getCloudId(
        'organizations',
        _currentOrganizationId,
      );
    }
    if (_parentCommissaryCloudId == null && _parentCommissaryId != null) {
      _parentCommissaryCloudId = _getCloudId(
        'organizations',
        _parentCommissaryId,
      );
    }
    
    if (kDebugMode) {
      AppLogger.sync('   📍 Organization context loaded:');
      AppLogger.sync('      - currentOrgCloudId: $_currentOrganizationCloudId');
      AppLogger.sync('      - parentCommissaryCloudId: $_parentCommissaryCloudId');
    }
  }

  /// ✅ FIX: Reload parent commissary ID from local database after organizations sync
  /// This resolves the issue where franchisees can't pull commissary items because
  /// _parentCommissaryId was null or stale when sync started (before organizations were pulled)
  Future<void> _reloadParentCommissaryId() async {
    if (_currentOrganizationType != 'franchisee') return;
    
    try {
      // If we already have a valid parent commissary ID, verify it still exists
      if (_parentCommissaryId != null) {
        final existing = await db.organizationsDao.getOrganizationById(_parentCommissaryId!);
        if (existing != null) {
          AppLogger.sync('   ✅ Parent commissary ID $_parentCommissaryId verified');
          return;
        }
      }
      
      // Try to find the parent commissary from the current organization's record
      if (_currentOrganizationId != null) {
        final currentOrg = await db.organizationsDao.getOrganizationById(_currentOrganizationId!);
        if (currentOrg?.parentCommissaryId != null) {
          _parentCommissaryId = currentOrg!.parentCommissaryId;
          _parentCommissaryCloudId = _getCloudId('organizations', _parentCommissaryId);
          AppLogger.sync('   🔄 Reloaded parent commissary ID from org record: $_parentCommissaryId');
          return;
        }
      }
      
      // Fallback: Find any commissary in the database
      final commissaries = await db.organizationsDao.getAllOrganizations(type: 'commissary');
      if (commissaries.isNotEmpty) {
        _parentCommissaryId = commissaries.first.id;
        _parentCommissaryCloudId = commissaries.first.cloudId;
        AppLogger.sync('   🔄 Found commissary via fallback: $_parentCommissaryId (${commissaries.first.name})');
      } else {
        AppLogger.sync('   ⚠️ No commissary found in local database');
      }
    } catch (e) {
      AppLogger.sync('   ⚠️ Failed to reload parent commissary ID: $e');
    }
  }

  // ============================================================================
  // CACHE MANAGEMENT
  // ============================================================================

  /// Build both forward and reverse caches
  Future<void> _buildCaches() async {
    AppLogger.sync('🔧 Building UUID caches...');
    final stopwatch = Stopwatch()..start();

    try {
      await Future.wait([
        _cacheTable(
          'organizations',
          () => db.organizationsDao.getAllOrganizations(),
          (org) => org.cloudId,
          (org) => org.id,
        ),
        _cacheTable(
          'roles',
          () => db.rolesDao.getAllRoles(),
          (role) => role.cloudId,
          (role) => role.id,
        ),
        _cacheTable(
          'users',
          () => db.usersDao.getAllUsers(),
          (user) => user.cloudId,
          (user) => user.id,
        ),
        _cacheTable(
          'items',
          () => db.itemsDao.getAllItems(),
          (item) => item.cloudId,
          (item) => item.id,
        ),
        _cacheTable(
          'ingredients',
          () => db.ingredientsDao.getAllIngredients(),
          (ing) => ing.cloudId,
          (ing) => ing.id,
        ),
        _cacheTable(
          'recipe_ingredients',
          () => db.recipeIngredientsDao.getAllRecipeIngredients(),
          (ri) => ri.cloudId,
          (ri) => ri.id,
        ),
      ]);

      stopwatch.stop();
      final totalEntries = _localToCloudCache.values.fold(
        0,
        (sum, map) => sum + map.length,
      );
      print(
        '✅ Caches built: $totalEntries entries in ${stopwatch.elapsedMilliseconds}ms',
      );
    } catch (e) {
      AppLogger.sync('⚠️ Error building caches: $e');
    }
  }

  /// Generic cache builder for a table
  Future<void> _cacheTable<T>(
    String tableName,
    Future<List<T>> Function() getAll,
    String? Function(T) getCloudId,
    int Function(T) getLocalId,
  ) async {
    final items = await getAll();
    _localToCloudCache[tableName]!.clear();
    _cloudToLocalCache[tableName]!.clear();

    for (final item in items) {
      final cloudId = getCloudId(item);
      final localId = getLocalId(item);
      if (cloudId != null) {
        _localToCloudCache[tableName]![localId] = cloudId;
        _cloudToLocalCache[tableName]![cloudId] = localId;
      }
    }
  }

  /// Get cloud UUID for local ID - O(1)
  String? _getCloudId(String table, int? localId) {
    if (localId == null) return null;
    return _localToCloudCache[table]?[localId];
  }

  /// Get local ID for cloud UUID - O(1)
  int? _getLocalId(String table, String? cloudId) {
    if (cloudId == null) return null;
    return _cloudToLocalCache[table]?[cloudId];
  }

  /// Update both caches
  void _updateCache(String table, int localId, String cloudId) {
    _localToCloudCache[table]![localId] = cloudId;
    _cloudToLocalCache[table]![cloudId] = localId;
  }

  /// Clear caches for a table
  // ignore: unused_element - Reserved for future cache invalidation use
  void _clearTableCache(String table) {
    _localToCloudCache[table]?.clear();
    _cloudToLocalCache[table]?.clear();
  }

  // ============================================================================
  // CONNECTIVITY
  // ============================================================================

  Future<bool> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity().timeout(
        const Duration(seconds: 5),
      );
      return result != ConnectivityResult.none;
    } catch (e) {
      AppLogger.sync('⚠️ Connectivity check failed: $e');
      return false;
    }
  }

  void startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(syncInterval, (_) => syncAll());
    AppLogger.sync('⏰ Periodic sync started (every ${syncInterval.inMinutes} minutes)');
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    AppLogger.sync('⏸️ Periodic sync stopped');
  }

  // ============================================================================
  // MAIN SYNC ORCHESTRATION
  // ============================================================================

  /// Main sync method with star topology awareness
  Future<void> syncAll() async {
    if (_isSyncing) {
      AppLogger.sync('⏳ Sync already in progress, skipping...');
      return;
    }

    if (!_isOnline) {
      AppLogger.sync('🔵 Offline, sync skipped');
      onSyncStatusChanged?.call('Offline');
      return;
    }

    // Check if user is authenticated (required for RLS-protected operations)
    if (!canSync) {
      AppLogger.sync('🔒 Not authenticated, sync skipped (login required)');
      onSyncStatusChanged?.call('Not authenticated');
      return;
    }

    _isSyncing = true;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        onSyncStatusChanged?.call('Syncing...');

        AppLogger.sync('🔄 Starting sync (attempt $attempt/$maxRetries)...');
        print(
          '   Mode: ${_currentOrganizationType ?? 'full'} | Org: $_currentOrganizationId',
        );
        final startTime = DateTime.now();

        // ✅ Sync in dependency order to avoid FK conflicts
        final syncSteps = _getSyncSteps();

        for (int i = 0; i < syncSteps.length; i++) {
          final step = syncSteps[i];
          await _syncTableWithRetry(step.name, step.sync);
          onSyncProgress?.call((i + 1) / syncSteps.length, step.name);
        }

        _lastSuccessfulSync = DateTime.now();
        final duration = _lastSuccessfulSync!.difference(startTime);

        AppLogger.sync('✅ Sync completed in ${duration.inSeconds}s');
        onSyncStatusChanged?.call('Synced');
        onSyncComplete?.call();
        
        // ✅ FIX: Notify all screens that sync is complete so they can refresh
        AppLogger.sync('📢 Calling notifySyncComplete() to refresh UI...');
        notifySyncComplete();
        AppLogger.sync('📢 syncCompleteNotifier triggered - screens should refresh now');

        // Rebuild caches after successful sync
        await _buildCaches();

        // Cleanup old deleted records
        await _cleanupDeletedRecords();

        _isSyncing = false;
        return;
      } catch (e, stackTrace) {
        AppLogger.sync('❌ Sync attempt $attempt failed: $e');
        if (kDebugMode) print(stackTrace);

        if (attempt == maxRetries) {
          onSyncError?.call('Sync failed after $maxRetries attempts: $e');
          onSyncStatusChanged?.call('Sync failed');
          _isSyncing = false;
          return;
        }

        // Exponential backoff with jitter
        final delay = _calculateBackoff(attempt);
        AppLogger.sync('⏳ Retrying in ${delay.inSeconds}s...');
        await Future.delayed(delay);
      }
    }

    _isSyncing = false;
  }

  /// Get sync steps based on organization type
  List<_SyncStep> _getSyncSteps() {
    return [
      _SyncStep('Organizations', syncOrganizations),
      _SyncStep('Roles', syncRoles),
      _SyncStep('Users', syncUsers),
      _SyncStep('Items', syncItems),
      _SyncStep('Ingredients', syncIngredients),
      _SyncStep('RecipeIngredients', syncRecipeIngredients),
      _SyncStep('BranchIngredientStock', syncBranchIngredientStock),
      _SyncStep('BranchItemStock', syncBranchItemStock),  // ✅ NEW: Per-branch item inventory
      _SyncStep('ReplenishmentRequests', syncStockReplenishmentRequests),
      _SyncStep('ChangeRequests', syncStockChangeRequests),
      _SyncStep('DailySalesSummary', syncDailySalesSummary),
    ];
  }

  /// Calculate exponential backoff with jitter
  Duration _calculateBackoff(int attempt) {
    final baseDelay = initialRetryDelay.inMilliseconds * pow(2, attempt - 1);
    final jitter = Random().nextInt(1000); // 0-1000ms jitter
    return Duration(milliseconds: baseDelay.toInt() + jitter);
  }

  /// Sync table with isolated error handling
  Future<void> _syncTableWithRetry(
    String tableName,
    Future<void> Function() syncFunction,
  ) async {
    try {
      AppLogger.sync('📊 Syncing $tableName...');
      await syncFunction().timeout(requestTimeout);
      AppLogger.sync('   ✅ $tableName done');
    } catch (e) {
      AppLogger.sync('   ⚠️ $tableName failed: $e');
      // Don't rethrow - continue with other tables
      onSyncError?.call('$tableName: $e');
    }
  }

  // ============================================================================
  // ORGANIZATIONS SYNC (Star topology aware)
  // ============================================================================
  // NOTE: Only commissary can INSERT organizations
  // Franchisees should ONLY pull organizations, never push

  Future<void> syncOrganizations() async {
    // Only commissary users can push organizations
    // Franchisees cannot create organizations per RLS policy
    if (_currentOrganizationType == 'commissary') {
      await _pushOrganizations();
    } else {
      AppLogger.sync('   ℹ️ Skipping organization push (franchisee mode - read-only)');
    }
    await _pullOrganizations();
  }

  Future<void> _pushOrganizations() async {
    int totalPushed = 0;
    int offset = 0;

    while (true) {
      final unsynced = await db.organizationsDao.getUnsyncedOrganizations(
        limit: batchSize,
        offset: offset,
      );

      if (unsynced.isEmpty) break;

      final batchData = <Map<String, dynamic>>[];
      final syncedIds = <int>[];
      final cloudIdMap = <int, String>{};

      for (final org in unsynced) {
        if (!org.isActive) continue;

        final cloudId = org.cloudId ?? _uuid.v4();
        cloudIdMap[org.id] = cloudId;
        _updateCache('organizations', org.id, cloudId);

        final parentCloudId = _getCloudId(
          'organizations',
          org.parentCommissaryId,
        );

        batchData.add({
          'cloud_id': cloudId,
          // NOTE: Don't send local_id - it causes conflicts across devices
          'name': org.name,
          'type': org.type,
          'parent_commissary_id': parentCloudId,
          'contact_person': org.contactPerson,
          'phone': org.phone,
          'email': org.email,
          'address': org.address,
          'is_active': org.isActive,
          'created_at': org.createdAt.toIso8601String(),
          'last_updated': org.lastUpdated.toIso8601String(),
        });
        syncedIds.add(org.id);
      }

      if (batchData.isNotEmpty) {
        await _syncClient
            .from('organizations')
            .upsert(batchData, onConflict: 'cloud_id');
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.organizationsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) AppLogger.sync('   ↑ Pushed $totalPushed organizations');
  }

  Future<void> _pullOrganizations() async {
    try {
      final lastSync =
          _lastSuccessfulSync?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';

      // RLS will filter based on user's organization automatically
      final cloudOrgs = await supabase
          .from('organizations')
          .select()
          .gte('last_updated', lastSync)
          .order('last_updated', ascending: false)
          .limit(500);

      if (cloudOrgs.isNotEmpty) {
        final resolvedOrgs = <Map<String, dynamic>>[];

        for (final cloudOrg in cloudOrgs) {
          int? parentId;
          if (cloudOrg['parent_commissary_id'] != null) {
            parentId = _getLocalId(
              'organizations',
              cloudOrg['parent_commissary_id'],
            );
          }

          resolvedOrgs.add({...cloudOrg, 'parent_commissary_id': parentId});
        }

        await db.organizationsDao.upsertBatchFromCloud(resolvedOrgs);
        AppLogger.sync('   ↓ Pulled ${resolvedOrgs.length} organizations');

        // ✅ FIXED: Rebuild organization cache from local DB after upsert
        // The cloud data doesn't have local_id, so we need to fetch from local DB
        await _rebuildOrganizationCache();
        
        // ✅ FIXED: Reload organization cloud IDs after cache rebuild
        await _loadOrganizationCloudIds();
        
        // ✅ FIX: Reload parent commissary ID for franchisees
        // This ensures _parentCommissaryId is set correctly before pulling items
        await _reloadParentCommissaryId();
      }
    } catch (e) {
      AppLogger.sync('   ⚠️ Failed to pull organizations: $e');
    }
  }

  /// Rebuild organization cache from local database
  Future<void> _rebuildOrganizationCache() async {
    try {
      final localOrgs = await db.organizationsDao.getAllOrganizations();
      _localToCloudCache['organizations']!.clear();
      _cloudToLocalCache['organizations']!.clear();
      
      for (final org in localOrgs) {
        if (org.cloudId != null) {
          _localToCloudCache['organizations']![org.id] = org.cloudId!;
          _cloudToLocalCache['organizations']![org.cloudId!] = org.id;
        }
      }
      AppLogger.sync('   🔄 Rebuilt organization cache: ${localOrgs.length} entries');
      
      // ✅ Debug: Print cache contents
      if (kDebugMode) {
        for (final entry in _cloudToLocalCache['organizations']!.entries) {
          AppLogger.sync('      📍 Org: ${entry.key} → local ID ${entry.value}');
        }
      }
    } catch (e) {
      AppLogger.sync('   ⚠️ Failed to rebuild organization cache: $e');
    }
  }

  // ============================================================================
  // ROLES SYNC
  // ============================================================================
  // NOTE: Only commissary can INSERT/UPDATE/DELETE roles
  // Franchisees should ONLY pull roles, never push

  Future<void> syncRoles() async {
    // Only commissary users can push roles
    // Franchisees cannot create/modify roles per RLS policy
    if (_currentOrganizationType == 'commissary') {
      await _pushRoles();
    } else {
      AppLogger.sync('   ℹ️ Skipping roles push (franchisee mode - read-only)');
    }
    await _pullRoles();
  }

  Future<void> _pushRoles() async {
    int totalPushed = 0;
    int offset = 0;

    while (true) {
      final unsynced = await db.rolesDao.getUnsyncedRoles(
        limit: batchSize,
        offset: offset,
      );

      if (unsynced.isEmpty) break;

      final batchData = <Map<String, dynamic>>[];
      final syncedIds = <int>[];
      final cloudIdMap = <int, String>{};

      for (final role in unsynced) {
        if (!role.isActive) continue;

        final cloudId = role.cloudId ?? _uuid.v4();
        cloudIdMap[role.id] = cloudId;
        _updateCache('roles', role.id, cloudId);

        batchData.add({
          'cloud_id': cloudId,
          // NOTE: Don't send local_id - it causes conflicts across devices
          'name': role.name,
          'description': role.description,
          'can_view_inventory': role.canViewInventory,
          'can_add_inventory': role.canAddInventory,
          'can_edit_inventory': role.canEditInventory,
          'can_delete_inventory': role.canDeleteInventory,
          'can_view_reports': role.canViewReports,
          'can_export_data': role.canExportData,
          'can_access_settings': role.canAccessSettings,
          'can_manage_employees': role.canManageEmployees,
          'can_manage_roles': role.canManageRoles,
          'is_system_role': role.isSystemRole,
          'is_active': role.isActive,
          'created_at': role.createdAt.toIso8601String(),
          'last_updated': role.lastUpdated.toIso8601String(),
        });
        syncedIds.add(role.id);
      }

      if (batchData.isNotEmpty) {
        await _syncClient
            .from('roles')
            .upsert(batchData, onConflict: 'cloud_id');
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.rolesDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) AppLogger.sync('   ↑ Pushed $totalPushed roles');
  }

  Future<void> _pullRoles() async {
    try {
      final lastSync =
          _lastSuccessfulSync?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';

      final cloudRoles = await supabase
          .from('roles')
          .select()
          .gte('last_updated', lastSync)
          .order('last_updated', ascending: false)
          .limit(500);

      if (cloudRoles.isNotEmpty) {
        await db.rolesDao.upsertBatchFromCloud(cloudRoles);
        AppLogger.sync('   ↓ Pulled ${cloudRoles.length} roles');

        // ✅ FIXED: Rebuild roles cache from local DB after upsert
        await _rebuildRolesCache();
      }
    } catch (e) {
      AppLogger.sync('   ⚠️ Failed to pull roles: $e');
    }
  }

  /// Rebuild roles cache from local database
  Future<void> _rebuildRolesCache() async {
    try {
      final localRoles = await db.rolesDao.getAllRoles();
      _localToCloudCache['roles']!.clear();
      _cloudToLocalCache['roles']!.clear();
      
      for (final role in localRoles) {
        if (role.cloudId != null) {
          _localToCloudCache['roles']![role.id] = role.cloudId!;
          _cloudToLocalCache['roles']![role.cloudId!] = role.id;
        }
      }
    } catch (e) {
      AppLogger.sync('   ⚠️ Failed to rebuild roles cache: $e');
    }
  }

  // ============================================================================
  // USERS SYNC (with FK resolution)
  // ============================================================================

  Future<void> syncUsers() async {
    await _pushUsers();
    await _pullUsers();
  }

  Future<void> _pushUsers() async {
    int totalPushed = 0;
    int skipped = 0;
    int offset = 0;

    while (true) {
      final unsynced = await db.usersDao.getUnsyncedUsers(
        limit: batchSize,
        offset: offset,
      );

      if (unsynced.isEmpty) break;

      final batchData = <Map<String, dynamic>>[];
      final syncedIds = <int>[];
      final cloudIdMap = <int, String>{};

      for (final user in unsynced) {
        if (!user.isActive) continue;

        final cloudId = user.cloudId ?? _uuid.v4();
        final orgCloudId = _getCloudId('organizations', user.organizationId);
        final roleCloudId = _getCloudId('roles', user.roleId);

        if (orgCloudId == null || roleCloudId == null) {
          skipped++;
          continue;
        }

        cloudIdMap[user.id] = cloudId;
        _updateCache('users', user.id, cloudId);

        batchData.add({
          'cloud_id': cloudId,
          // NOTE: Don't send local_id - it causes conflicts across devices
          'email': user.email,
          'username': user.username,
          'password': user.password,
          'phone': user.phone,
          'organization_id': orgCloudId,
          'role_id': roleCloudId,
          'full_name': user.fullName,
          'is_active': user.isActive,
          'created_at': user.createdAt.toIso8601String(),
          'last_updated': user.lastUpdated.toIso8601String(),
        });
        syncedIds.add(user.id);
      }

      if (batchData.isNotEmpty) {
        await _syncClient
            .from('users')
            .upsert(batchData, onConflict: 'cloud_id');
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.usersDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) AppLogger.sync('   ↑ Pushed $totalPushed users');
    if (skipped > 0) AppLogger.sync('   ⚠️ Skipped $skipped users (missing FKs)');
  }

  Future<void> _pullUsers() async {
    try {
      final lastSync =
          _lastSuccessfulSync?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';

      // RLS filters users based on organization
      final cloudUsers = await supabase
          .from('users')
          .select()
          .gte('last_updated', lastSync)
          .order('last_updated', ascending: false)
          .limit(500);

      if (cloudUsers.isNotEmpty) {
        final resolvedUsers = <Map<String, dynamic>>[];

        for (final cloudUser in cloudUsers) {
          final orgId = _getLocalId(
            'organizations',
            cloudUser['organization_id'],
          );
          final roleId = _getLocalId('roles', cloudUser['role_id']);

          if (orgId == null || roleId == null) {
            AppLogger.sync('   ⚠️ Skipping user ${cloudUser['email']}: org=$orgId, role=$roleId');
            continue;
          }

          resolvedUsers.add({
            ...cloudUser,
            'organization_id': orgId,
            'role_id': roleId,
          });
        }

        if (resolvedUsers.isNotEmpty) {
          await db.usersDao.upsertBatchFromCloud(resolvedUsers);
          AppLogger.sync('   ↓ Pulled ${resolvedUsers.length} users');
          
          // ✅ FIXED: Rebuild users cache from local DB after upsert
          await _rebuildUsersCache();
        }
      }
    } catch (e) {
      AppLogger.sync('   ⚠️ Failed to pull users: $e');
    }
  }

  /// Rebuild users cache from local database
  Future<void> _rebuildUsersCache() async {
    try {
      final localUsers = await db.usersDao.getAllUsers();
      _localToCloudCache['users']!.clear();
      _cloudToLocalCache['users']!.clear();
      
      for (final user in localUsers) {
        if (user.cloudId != null) {
          _localToCloudCache['users']![user.id] = user.cloudId!;
          _cloudToLocalCache['users']![user.cloudId!] = user.id;
        }
      }
    } catch (e) {
      AppLogger.sync('   ⚠️ Failed to rebuild users cache: $e');
    }
  }

  // ============================================================================
  // ITEMS SYNC (Star topology: Commissary items visible to franchisees)
  // ============================================================================

  Future<void> syncItems() async {
    await _pushItems();
    await _pullItems();
  }

  Future<void> _pushItems() async {
    int totalPushed = 0;
    int skipped = 0;
    int offset = 0;

    while (true) {
      final unsynced = await db.itemsDao.getUnsyncedItems(
        limit: batchSize,
        offset: offset,
      );

      if (unsynced.isEmpty) break;

      final batchData = <Map<String, dynamic>>[];
      final syncedIds = <int>[];
      final cloudIdMap = <int, String>{};

      for (final item in unsynced) {
        if (item.isDeleted) continue;

        final cloudId = item.cloudId ?? _uuid.v4();
        // ✅ FIX: Supabase RLS uses UUID for organization_id, so we must send the cloud_id
        final orgCloudId = _getCloudId('organizations', item.organizationId);
        // master_item_id is stored as TEXT (cloud_id) in Supabase
        final masterItemCloudId = _getCloudId('items', item.masterItemId);
        final categoryCloudId = _getCloudId('categories', item.categoryId);

        if (orgCloudId == null) {
          AppLogger.sync('   ⚠️ Skipping item ${item.name}: org cloud_id not found for org ${item.organizationId}');
          continue;
        }

        cloudIdMap[item.id] = cloudId;
        _updateCache('items', item.id, cloudId);

        batchData.add({
          'cloud_id': cloudId,
          // NOTE: Don't send local_id - it causes conflicts across devices
          'name': item.name,
          'organization_id': orgCloudId,  // ✅ FIX: Use cloud_id (UUID), not local int
          'category_id': categoryCloudId,
          'master_item_id': masterItemCloudId,
          'stock': item.stock,
          'sold': item.sold,
          'spoilage': item.spoilage,
          'price': item.price,
          'cost_price': item.costPrice,
          'unit': item.unit,
          'minimum_stock': item.minimumStock,
          'description': item.description,
          'created_at': item.createdAt.toIso8601String(),
          'last_updated': item.lastUpdated.toIso8601String(),
          'is_deleted': item.isDeleted,
        });
        syncedIds.add(item.id);
      }

      if (batchData.isNotEmpty) {
        await _syncClient
            .from('items')
            .upsert(batchData, onConflict: 'cloud_id');
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.itemsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) AppLogger.sync('   ↑ Pushed $totalPushed items');
    if (skipped > 0) AppLogger.sync('   ⚠️ Skipped $skipped items (missing FKs)');
  }

  Future<void> _pullItems() async {
    try {
      // ✅ FIX: Always do a full pull for items to ensure all master items are synced
      // The incremental sync was causing items to be missed if created before the 
      // franchisee's first sync but not yet synced to this client.
      // For a more robust solution, we'd track per-record sync status.
      final lastSync = '1970-01-01T00:00:00.000Z';  // Always full refresh for items

      // ✅ Debug: Log current organization context
      print('   📍 _pullItems: Current org context:');
      print('      - orgId (local): $_currentOrganizationId');
      print('      - orgCloudId: $_currentOrganizationCloudId');
      print('      - orgType: $_currentOrganizationType');
      print('      - parentCommissaryId (local): $_parentCommissaryId');
      print('      - parentCommissaryCloudId: $_parentCommissaryCloudId');
      
      // Debug: Print organization cache
      print('   📍 Organization cache contents (${_cloudToLocalCache['organizations']!.length} entries):');
      for (final entry in _cloudToLocalCache['organizations']!.entries) {
        print('      ${entry.key} → local ID ${entry.value}');
      }

      // Build query with organization filter
      // ✅ FIX: Supabase RLS already filters items based on organization.
      // Franchisees can see their own items + commissary master items.
      // We don't need to manually filter here - RLS handles it.
      // The organization_id in Supabase is a UUID (cloud_id), not local int.
      var query = supabase
          .from('items')
          .select()
          .gte('last_updated', lastSync);

      // RLS handles the filtering, but we can add explicit filter for debugging
      if (_currentOrganizationId != null && _currentOrganizationCloudId != null) {
        if (_currentOrganizationType == 'franchisee') {
          // ✅ FIX: For franchisees, pull master items from commissary + own items
          // RLS already allows this, but we can be explicit with cloud IDs
          print('   🔍 Franchisee mode: RLS will filter to show master items + own items');
          // Don't manually filter - let RLS handle it based on authenticated user
          // The RLS policy: organization_id = own OR (parent_commissary AND master_item_id IS NULL)
        } else {
          // Commissary: RLS filters to own network
          AppLogger.sync('   🔍 Commissary mode: RLS will filter to network items');
        }
      } else {
        AppLogger.sync('   ⚠️ Warning: org context incomplete - relying on RLS only');
      }

      final cloudItems = await query
          .order('last_updated', ascending: false)
          .limit(1000);

      print('   📥 Received ${cloudItems.length} items from Supabase');
      
      // Debug: Log each item received
      for (final item in cloudItems) {
        print('      📦 Cloud item: ${item['name']} | org_id=${item['organization_id']} | master=${item['master_item_id']}');
      }

      if (cloudItems.isNotEmpty) {
        final resolvedItems = <Map<String, dynamic>>[];

        for (final cloudItem in cloudItems) {
          // ✅ FIX: organization_id in Supabase is now a UUID (cloud_id), needs resolution
          final orgCloudId = cloudItem['organization_id']?.toString();
          final orgId = _getLocalId('organizations', orgCloudId);
          // master_item_id is TEXT (cloud_id) in Supabase, needs resolution
          final masterItemId = _getLocalId(
            'items',
            cloudItem['master_item_id'],
          );

          if (orgId == null) {
            print('   ⚠️ Skipping item ${cloudItem['name']}: org not found for cloud_id=$orgCloudId');
            continue;
          }
          
          // Debug: Log resolved item
          print('      ✅ Resolved: ${cloudItem['name']} | orgCloudId=$orgCloudId → localOrgId=$orgId');

          resolvedItems.add({
            ...cloudItem,
            'organization_id': orgId,
            'master_item_id': masterItemId,
          });
        }

        print('   ✅ Resolved ${resolvedItems.length} items for local insert');

        if (resolvedItems.isNotEmpty) {
          // Process in batches
          for (int i = 0; i < resolvedItems.length; i += batchSize) {
            final end = min(i + batchSize, resolvedItems.length);
            final batch = resolvedItems.sublist(i, end);
            await db.itemsDao.upsertBatchFromCloud(batch);
          }
          AppLogger.sync('   ↓ Pulled ${resolvedItems.length} items');
          
          // ✅ FIXED: Rebuild items cache from local DB after upsert
          await _rebuildItemsCache();
        }
      }
    } catch (e) {
      AppLogger.sync('   ⚠️ Failed to pull items: $e');
    }
  }

  /// Rebuild items cache from local database
  Future<void> _rebuildItemsCache() async {
    try {
      final localItems = await db.itemsDao.getAllItems();
      _localToCloudCache['items']!.clear();
      _cloudToLocalCache['items']!.clear();
      
      for (final item in localItems) {
        if (item.cloudId != null) {
          _localToCloudCache['items']![item.id] = item.cloudId!;
          _cloudToLocalCache['items']![item.cloudId!] = item.id;
        }
      }
    } catch (e) {
      AppLogger.sync('   ⚠️ Failed to rebuild items cache: $e');
    }
  }

  // ============================================================================
  // INGREDIENTS SYNC (Commissary only, visible to franchisees)
  // ============================================================================

  Future<void> syncIngredients() async {
    await _pushIngredients();
    await _pullIngredients();
  }

  Future<void> _pushIngredients() async {
    int totalPushed = 0;
    int offset = 0;

    while (true) {
      final unsynced = await db.ingredientsDao.getUnsyncedIngredients(
        limit: batchSize,
        offset: offset,
      );

      if (unsynced.isEmpty) break;

      final batchData = <Map<String, dynamic>>[];
      final syncedIds = <int>[];
      final cloudIdMap = <int, String>{};

      for (final ingredient in unsynced) {
        if (ingredient.isDeleted) continue;

        final cloudId = ingredient.cloudId ?? _uuid.v4();
        // NOTE: Supabase stores commissary_id as INTEGER, not cloud_id
        final commissaryId = ingredient.commissaryId;

        cloudIdMap[ingredient.id] = cloudId;
        _updateCache('ingredients', ingredient.id, cloudId);

        batchData.add({
          'cloud_id': cloudId,
          // NOTE: Don't send local_id - it causes conflicts across devices
          'name': ingredient.name,
          'commissary_id': commissaryId,  // INTEGER, not cloud_id
          'stock': ingredient.stock,
          'spoilage': ingredient.spoilage,
          'unit': ingredient.unit,
          'minimum_stock': ingredient.minimumStock,
          'description': ingredient.description,
          'created_at': ingredient.createdAt.toIso8601String(),
          'last_updated': ingredient.lastUpdated.toIso8601String(),
          'is_deleted': ingredient.isDeleted,
        });
        syncedIds.add(ingredient.id);
      }

      if (batchData.isNotEmpty) {
        await _syncClient
            .from('ingredients')
            .upsert(batchData, onConflict: 'cloud_id');
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.ingredientsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) AppLogger.sync('   ↑ Pushed $totalPushed ingredients');
  }

  Future<void> _pullIngredients() async {
    try {
      final lastSync =
          _lastSuccessfulSync?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';

      // Try to fetch with last_updated filter, fallback to fetching all if column doesn't exist
      List<dynamic> cloudIngredients;
      try {
        cloudIngredients = await supabase
            .from('ingredients')
            .select()
            .gte('last_updated', lastSync)
            .order('last_updated', ascending: false)
            .limit(500);
      } catch (e) {
        // Fallback: fetch all ingredients without last_updated filter
        AppLogger.sync('   ⚠️ last_updated filter failed, fetching all ingredients...');
        cloudIngredients = await supabase
            .from('ingredients')
            .select()
            .limit(500);
      }

      AppLogger.sync('   📥 Received ${cloudIngredients.length} ingredients from Supabase');

      if (cloudIngredients.isNotEmpty) {
        final resolvedIngredients = <Map<String, dynamic>>[];

        for (final cloudIngredient in cloudIngredients) {
          // commissary_id is already an integer in Supabase, use directly
          final commissaryId = cloudIngredient['commissary_id'] as int?;

          if (commissaryId == null) {
            AppLogger.sync('   ⚠️ Skipping ingredient ${cloudIngredient['name']}: commissary_id is null');
            continue;
          }

          resolvedIngredients.add({
            ...cloudIngredient,
            'commissary_id': commissaryId,
          });
        }

        if (resolvedIngredients.isNotEmpty) {
          await db.ingredientsDao.upsertBatchFromCloud(resolvedIngredients);
          AppLogger.sync('   ↓ Pulled ${resolvedIngredients.length} ingredients');
        } else {
          AppLogger.sync('   ℹ️ No valid ingredients to pull (all had null commissary_id)');
        }
      } else {
        AppLogger.sync('   ℹ️ No ingredients found in Supabase');
      }
    } catch (e) {
      AppLogger.sync('   ⚠️ Failed to pull ingredients: $e');
    }
  }

  // ============================================================================
  // RECIPE INGREDIENTS SYNC
  // ============================================================================

  Future<void> syncRecipeIngredients() async {
    await _pushRecipeIngredients();
    await _pullRecipeIngredients();
  }

  Future<void> _pushRecipeIngredients() async {
    int totalPushed = 0;
    int offset = 0;

    while (true) {
      final unsynced = await db.recipeIngredientsDao
          .getUnsyncedRecipeIngredients(limit: batchSize, offset: offset);

      if (unsynced.isEmpty) break;

      final batchData = <Map<String, dynamic>>[];
      final syncedIds = <int>[];
      final cloudIdMap = <int, String>{};

      for (final recipe in unsynced) {
        if (recipe.isDeleted) continue;

        final cloudId = recipe.cloudId ?? _uuid.v4();
        // NOTE: Supabase stores item_id and ingredient_id as INTEGER, not cloud_id
        final itemId = recipe.itemId;
        final ingredientId = recipe.ingredientId;

        cloudIdMap[recipe.id] = cloudId;
        _updateCache('recipe_ingredients', recipe.id, cloudId);

        batchData.add({
          'cloud_id': cloudId,
          // NOTE: Don't send local_id - it causes conflicts across devices
          'item_id': itemId,  // INTEGER, not cloud_id
          'ingredient_id': ingredientId,  // INTEGER, not cloud_id
          'quantity_needed': recipe.quantityNeeded,
          'unit': recipe.unit,
          'notes': recipe.notes,
          'created_at': recipe.createdAt.toIso8601String(),
          'last_updated': recipe.lastUpdated.toIso8601String(),
          'is_deleted': recipe.isDeleted,
        });
        syncedIds.add(recipe.id);
      }

      if (batchData.isNotEmpty) {
        await _syncClient
            .from('recipe_ingredients')
            .upsert(batchData, onConflict: 'cloud_id');
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.recipeIngredientsDao.markAsSynced(
          syncedIds,
          cloudIds: cloudIdMap,
        );
      }

      offset += batchSize;
    }

    if (totalPushed > 0) AppLogger.sync('   ↑ Pushed $totalPushed recipe ingredients');
  }

  Future<void> _pullRecipeIngredients() async {
    try {
      final lastSync =
          _lastSuccessfulSync?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';

      // Try to fetch with last_updated filter, fallback if column doesn't exist
      List<dynamic> cloudRecipes;
      try {
        cloudRecipes = await supabase
            .from('recipe_ingredients')
            .select()
            .gte('last_updated', lastSync)
            .order('last_updated', ascending: false)
            .limit(500);
      } catch (e) {
        // Fallback: fetch all without last_updated filter
        AppLogger.sync('   ⚠️ last_updated filter failed, fetching all recipe_ingredients...');
        cloudRecipes = await supabase
            .from('recipe_ingredients')
            .select()
            .limit(500);
      }

      AppLogger.sync('   📥 Received ${cloudRecipes.length} recipe_ingredients from Supabase');

      if (cloudRecipes.isNotEmpty) {
        final resolvedRecipes = <Map<String, dynamic>>[];

        for (final cloudRecipe in cloudRecipes) {
          // item_id and ingredient_id are already integers in Supabase, use directly
          final itemId = cloudRecipe['item_id'] as int?;
          final ingredientId = cloudRecipe['ingredient_id'] as int?;

          if (itemId == null || ingredientId == null) {
            AppLogger.sync('   ⚠️ Skipping recipe: item_id=$itemId, ingredient_id=$ingredientId');
            continue;
          }

          resolvedRecipes.add({
            ...cloudRecipe,
            'item_id': itemId,
            'ingredient_id': ingredientId,
          });
        }

        if (resolvedRecipes.isNotEmpty) {
          await db.recipeIngredientsDao.upsertBatchFromCloud(resolvedRecipes);
          AppLogger.sync('   ↓ Pulled ${resolvedRecipes.length} recipe ingredients');
        } else {
          AppLogger.sync('   ℹ️ No valid recipe_ingredients to pull');
        }
      } else {
        AppLogger.sync('   ℹ️ No recipe_ingredients found in Supabase');
      }
    } catch (e) {
      AppLogger.sync('   ⚠️ Failed to pull recipe ingredients: $e');
    }
  }

  // ============================================================================
  // STOCK REPLENISHMENT REQUESTS SYNC
  // ============================================================================

  Future<void> syncStockReplenishmentRequests() async {
    await _pushReplenishmentRequests();
    await _pullReplenishmentRequests();
  }

  Future<void> _pushReplenishmentRequests() async {
    int totalPushed = 0;
    int offset = 0;

    while (true) {
      final unsynced = await db.stockReplenishmentRequestsDao
          .getUnsyncedRequests(limit: batchSize, offset: offset);

      if (unsynced.isEmpty) break;

      final batchData = <Map<String, dynamic>>[];
      final syncedIds = <int>[];
      final cloudIdMap = <int, String>{};

      for (final request in unsynced) {
        if (request.isDeleted) continue;

        final cloudId = request.cloudId ?? _uuid.v4();
        final franchiseeCloudId = _getCloudId(
          'organizations',
          request.franchiseeId,
        );
        final commissaryCloudId = _getCloudId(
          'organizations',
          request.commissaryId,
        );
        final itemCloudId = _getCloudId('items', request.itemId);
        final requestedByCloudId = _getCloudId('users', request.requestedBy);
        final reviewedByCloudId = _getCloudId('users', request.reviewedBy);

        if (franchiseeCloudId == null ||
            commissaryCloudId == null ||
            itemCloudId == null ||
            requestedByCloudId == null)
          continue;

        cloudIdMap[request.id] = cloudId;

        batchData.add({
          'cloud_id': cloudId,
          // NOTE: Don't send local_id - it causes conflicts across devices
          'franchisee_id': franchiseeCloudId,
          'commissary_id': commissaryCloudId,
          'item_id': itemCloudId,
          'quantity_requested': request.quantityRequested,
          'status': request.status,
          'requested_by': requestedByCloudId,
          'requested_at': request.requestedAt.toIso8601String(),
          'reviewed_by': reviewedByCloudId,
          'reviewed_at': request.reviewedAt?.toIso8601String(),
          'delivery_date': request.deliveryDate?.toIso8601String(),
          'franchisee_notes': request.franchiseeNotes,
          'commissary_notes': request.commissaryNotes,
          'created_at': request.createdAt.toIso8601String(),
          'last_updated': request.lastUpdated.toIso8601String(),
          'is_deleted': request.isDeleted,
        });
        syncedIds.add(request.id);
      }

      if (batchData.isNotEmpty) {
        await _syncClient
            .from('stock_replenishment_requests')
            .upsert(batchData, onConflict: 'cloud_id');
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.stockReplenishmentRequestsDao.markAsSynced(
          syncedIds,
          cloudIds: cloudIdMap,
        );
      }

      offset += batchSize;
    }

    if (totalPushed > 0)
      AppLogger.sync('   ↑ Pushed $totalPushed replenishment requests');
  }

  Future<void> _pullReplenishmentRequests() async {
    try {
      // Always pull recent requests (last 30 days) to catch status updates
      // Don't rely on lastSync since status changes can happen anytime
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30)).toIso8601String();

      // RLS filters: Commissary sees requests to them, Franchisee sees own requests
      final cloudRequests = await supabase
          .from('stock_replenishment_requests')
          .select()
          .gte('last_updated', thirtyDaysAgo)
          .order('last_updated', ascending: false)
          .limit(500);

      print('   📥 Fetched ${cloudRequests.length} replenishment requests from cloud');

      if (cloudRequests.isNotEmpty) {
        final resolvedRequests = <Map<String, dynamic>>[];

        for (final cloudRequest in cloudRequests) {
          final franchiseeId = _getLocalId(
            'organizations',
            cloudRequest['franchisee_id'],
          );
          final commissaryId = _getLocalId(
            'organizations',
            cloudRequest['commissary_id'],
          );
          final itemId = _getLocalId('items', cloudRequest['item_id']);
          final requestedById = _getLocalId(
            'users',
            cloudRequest['requested_by'],
          );
          final reviewedById = _getLocalId(
            'users',
            cloudRequest['reviewed_by'],
          );

          if (franchiseeId == null ||
              commissaryId == null ||
              itemId == null ||
              requestedById == null) {
            print('   ⚠️ Skipping request ${cloudRequest['cloud_id']}: missing local FK');
            continue;
          }

          print('   📋 Processing request ${cloudRequest['cloud_id']}: status=${cloudRequest['status']}');

          resolvedRequests.add({
            ...cloudRequest,
            'franchisee_id': franchiseeId,
            'commissary_id': commissaryId,
            'item_id': itemId,
            'requested_by': requestedById,
            'reviewed_by': reviewedById,
          });
        }

        if (resolvedRequests.isNotEmpty) {
          await db.stockReplenishmentRequestsDao.upsertBatchFromCloud(
            resolvedRequests,
          );
          print(
            '   ↓ Pulled ${resolvedRequests.length} replenishment requests',
          );
        }
      }
    } catch (e) {
      AppLogger.sync('   ⚠️ Failed to pull replenishment requests: $e');
      print('   ⚠️ Failed to pull replenishment requests: $e');
    }
  }

  // ============================================================================
  // STOCK CHANGE REQUESTS SYNC
  // ============================================================================

  Future<void> syncStockChangeRequests() async {
    await _pushChangeRequests();
    await _pullChangeRequests();
  }

  Future<void> _pushChangeRequests() async {
    int totalPushed = 0;
    int offset = 0;

    while (true) {
      final unsynced = await db.stockChangeRequestsDao
          .getUnsyncedChangeRequests(limit: batchSize, offset: offset);

      if (unsynced.isEmpty) break;

      final batchData = <Map<String, dynamic>>[];
      final syncedIds = <int>[];
      final cloudIdMap = <int, String>{};

      for (final request in unsynced) {
        if (request.isDeleted) continue;

        final cloudId = request.cloudId ?? _uuid.v4();
        final franchiseeCloudId = _getCloudId(
          'organizations',
          request.franchiseeId,
        );
        final itemCloudId = _getCloudId('items', request.itemId);
        final requestedByCloudId = _getCloudId('users', request.requestedBy);
        final reviewedByCloudId = _getCloudId('users', request.reviewedBy);

        if (franchiseeCloudId == null ||
            itemCloudId == null ||
            requestedByCloudId == null)
          continue;

        cloudIdMap[request.id] = cloudId;

        batchData.add({
          'cloud_id': cloudId,
          // NOTE: Don't send local_id - it causes conflicts across devices
          'franchisee_id': franchiseeCloudId,
          'item_id': itemCloudId,
          'change_type': request.changeType,
          'quantity': request.quantity,
          'status': request.status,
          'requested_by': requestedByCloudId,
          'requested_at': request.requestedAt.toIso8601String(),
          'submitted_at': request.submittedAt?.toIso8601String(),
          'reviewed_by': reviewedByCloudId,
          'reviewed_at': request.reviewedAt?.toIso8601String(),
          'reason': request.reason,
          'review_notes': request.reviewNotes,
          'original_stock': request.originalStock,
          'created_at': request.createdAt.toIso8601String(),
          'last_updated': request.lastUpdated.toIso8601String(),
          'is_deleted': request.isDeleted,
        });
        syncedIds.add(request.id);
      }

      if (batchData.isNotEmpty) {
        await _syncClient
            .from('stock_change_requests')
            .upsert(batchData, onConflict: 'cloud_id');
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.stockChangeRequestsDao.markAsSynced(
          syncedIds,
          cloudIds: cloudIdMap,
        );
      }

      offset += batchSize;
    }

    if (totalPushed > 0) AppLogger.sync('   ↑ Pushed $totalPushed change requests');
  }

  Future<void> _pullChangeRequests() async {
    try {
      final lastSync =
          _lastSuccessfulSync?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';

      final cloudRequests = await supabase
          .from('stock_change_requests')
          .select()
          .gte('last_updated', lastSync)
          .order('last_updated', ascending: false)
          .limit(500);

      if (cloudRequests.isNotEmpty) {
        final resolvedRequests = <Map<String, dynamic>>[];

        for (final cloudRequest in cloudRequests) {
          final franchiseeId = _getLocalId(
            'organizations',
            cloudRequest['franchisee_id'],
          );
          final itemId = _getLocalId('items', cloudRequest['item_id']);
          final requestedById = _getLocalId(
            'users',
            cloudRequest['requested_by'],
          );
          final reviewedById = _getLocalId(
            'users',
            cloudRequest['reviewed_by'],
          );

          if (franchiseeId == null || itemId == null || requestedById == null)
            continue;

          resolvedRequests.add({
            ...cloudRequest,
            'franchisee_id': franchiseeId,
            'item_id': itemId,
            'requested_by': requestedById,
            'reviewed_by': reviewedById,
          });
        }

        if (resolvedRequests.isNotEmpty) {
          await db.stockChangeRequestsDao.upsertBatchFromCloud(
            resolvedRequests,
          );
          AppLogger.sync('   ↓ Pulled ${resolvedRequests.length} change requests');
        }
      }
    } catch (e) {
      AppLogger.sync('   ⚠️ Failed to pull change requests: $e');
    }
  }

  // ============================================================================
  // DAILY SALES SUMMARY SYNC
  // ============================================================================

  Future<void> syncDailySalesSummary() async {
    await _pushDailySalesSummary();
    await _pullDailySalesSummary();
  }

  Future<void> _pushDailySalesSummary() async {
    int totalPushed = 0;

    while (true) {
      final unsynced = await db.dailySalesSummaryDao.getUnsyncedSummaries(
        limit: batchSize,
      );

      if (unsynced.isEmpty) break;

      final batchData = <Map<String, dynamic>>[];
      final syncedIds = <int>[];
      final cloudIdMap = <int, String>{};

      for (final summary in unsynced) {
        final cloudId = summary.cloudId ?? _uuid.v4();
        cloudIdMap[summary.id] = cloudId;
        _updateCache('daily_sales_summary', summary.id, cloudId);

        final orgCloudId = _getCloudId('organizations', summary.organizationId);
        final itemCloudId = _getCloudId('items', summary.itemId);

        if (orgCloudId == null || itemCloudId == null) {
          AppLogger.sync('   ⚠️ Missing FK for sales summary ${summary.id}');
          continue;
        }

        batchData.add({
          'cloud_id': cloudId,
          'organization_id': orgCloudId,
          'item_id': itemCloudId,
          'summary_date': summary.summaryDate.toIso8601String().split('T')[0],
          'quantity_sold': summary.quantitySold,
          'quantity_spoiled': summary.quantitySpoiled,
          'revenue': summary.revenue,
          'cost_of_goods_sold': summary.costOfGoodsSold,
          'gross_profit': summary.grossProfit,
          'transaction_count': summary.transactionCount,
          'opening_stock': summary.openingStock,
          'closing_stock': summary.closingStock,
          'created_at': summary.createdAt.toIso8601String(),
          'last_updated': summary.lastUpdated.toIso8601String(),
        });
        syncedIds.add(summary.id);
      }

      if (batchData.isNotEmpty) {
        await _syncClient
            .from('daily_sales_summary')
            .upsert(batchData, onConflict: 'cloud_id');
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.dailySalesSummaryDao.markAsSynced(syncedIds);
        for (final entry in cloudIdMap.entries) {
          await db.dailySalesSummaryDao.updateCloudId(entry.key, entry.value);
        }
      }

      // Break after processing since getUnsyncedSummaries returns all unsynced
      break;
    }

    if (totalPushed > 0) AppLogger.sync('   ↑ Pushed $totalPushed sales summaries');
  }

  Future<void> _pullDailySalesSummary() async {
    try {
      // Only commissary pulls all summaries; franchisees only get their own (via RLS)
      final lastSync =
          _lastSuccessfulSync?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';

      final cloudSummaries = await supabase
          .from('daily_sales_summary')
          .select()
          .gte('last_updated', lastSync)
          .order('last_updated', ascending: false)
          .limit(500);

      if (cloudSummaries.isNotEmpty) {
        int pulled = 0;
        for (final cloudSummary in cloudSummaries) {
          final orgId = _getLocalId('organizations', cloudSummary['organization_id']);
          final itemId = _getLocalId('items', cloudSummary['item_id']);

          if (orgId == null || itemId == null) continue;

          // Upsert into local database
          final summaryDate = DateTime.parse(cloudSummary['summary_date']);
          
          await db.dailySalesSummaryDao.upsertDailySummary(
            DailySalesSummaryCompanion(
              cloudId: Value(cloudSummary['cloud_id']),
              organizationId: Value(orgId),
              itemId: Value(itemId),
              summaryDate: Value(summaryDate),
              quantitySold: Value(cloudSummary['quantity_sold'] ?? 0),
              quantitySpoiled: Value(cloudSummary['quantity_spoiled'] ?? 0),
              revenue: Value((cloudSummary['revenue'] ?? 0).toDouble()),
              costOfGoodsSold: Value((cloudSummary['cost_of_goods_sold'] ?? 0).toDouble()),
              grossProfit: Value((cloudSummary['gross_profit'] ?? 0).toDouble()),
              transactionCount: Value(cloudSummary['transaction_count'] ?? 0),
              openingStock: Value(cloudSummary['opening_stock']),
              closingStock: Value(cloudSummary['closing_stock']),
              isSynced: const Value(true),
            ),
          );
          pulled++;
        }
        if (pulled > 0) AppLogger.sync('   ↓ Pulled $pulled sales summaries');
      }
    } catch (e) {
      AppLogger.sync('   ⚠️ Failed to pull sales summaries: $e');
    }
  }

  // ============================================================================
  // BRANCH INGREDIENT STOCK SYNC
  // ============================================================================

  Future<void> syncBranchIngredientStock() async {
    await _pushBranchIngredientStock();
    await _pullBranchIngredientStock();
  }

  Future<void> _pushBranchIngredientStock() async {
    int totalPushed = 0;

    while (true) {
      final unsynced = await db.branchIngredientStockDao.getUnsyncedStocks(
        limit: batchSize,
      );

      if (unsynced.isEmpty) break;

      final batchData = <Map<String, dynamic>>[];
      final syncedIds = <int>[];
      final cloudIdMap = <int, String>{};

      for (final stock in unsynced) {
        final cloudId = stock.cloudId ?? _uuid.v4();
        cloudIdMap[stock.id] = cloudId;
        _updateCache('branch_ingredient_stock', stock.id, cloudId);

        final orgCloudId = _getCloudId('organizations', stock.organizationId);
        final ingredientCloudId = _getCloudId('ingredients', stock.ingredientId);

        if (orgCloudId == null || ingredientCloudId == null) {
          AppLogger.sync('   ⚠️ Missing FK for branch ingredient stock ${stock.id}');
          continue;
        }

        batchData.add({
          'cloud_id': cloudId,
          'organization_id': orgCloudId,
          'ingredient_id': ingredientCloudId,
          'quantity': stock.quantity,
          'minimum_stock': stock.minimumStock,
          'last_received_at': stock.lastReceivedAt?.toIso8601String(),
          'last_received_quantity': stock.lastReceivedQuantity,
          'created_at': stock.createdAt.toIso8601String(),
          'last_updated': stock.lastUpdated.toIso8601String(),
        });
        syncedIds.add(stock.id);
      }

      if (batchData.isNotEmpty) {
        await _syncClient
            .from('branch_ingredient_stock')
            .upsert(batchData, onConflict: 'cloud_id');
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.branchIngredientStockDao.markAsSynced(syncedIds);
        for (final entry in cloudIdMap.entries) {
          await db.branchIngredientStockDao.updateCloudId(entry.key, entry.value);
        }
      }

      // Break after processing since getUnsyncedStocks returns all unsynced
      break;
    }

    if (totalPushed > 0) AppLogger.sync('   ↑ Pushed $totalPushed branch ingredient stocks');
  }

  Future<void> _pullBranchIngredientStock() async {
    try {
      final lastSync =
          _lastSuccessfulSync?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';

      final cloudStocks = await supabase
          .from('branch_ingredient_stock')
          .select()
          .gte('last_updated', lastSync)
          .order('last_updated', ascending: false)
          .limit(500);

      if (cloudStocks.isNotEmpty) {
        int pulled = 0;
        for (final cloudStock in cloudStocks) {
          final orgId = _getLocalId('organizations', cloudStock['organization_id']);
          final ingredientId = _getLocalId('ingredients', cloudStock['ingredient_id']);

          if (orgId == null || ingredientId == null) continue;

          await db.branchIngredientStockDao.upsertStock(
            BranchIngredientStockCompanion(
              cloudId: Value(cloudStock['cloud_id']),
              organizationId: Value(orgId),
              ingredientId: Value(ingredientId),
              quantity: Value((cloudStock['quantity'] ?? 0).toDouble()),
              minimumStock: Value(cloudStock['minimum_stock']?.toDouble()),
              lastReceivedAt: Value(
                cloudStock['last_received_at'] != null
                    ? DateTime.parse(cloudStock['last_received_at'])
                    : null,
              ),
              lastReceivedQuantity: Value(cloudStock['last_received_quantity']?.toDouble()),
              isSynced: const Value(true),
            ),
          );
          pulled++;
        }
        if (pulled > 0) AppLogger.sync('   ↓ Pulled $pulled branch ingredient stocks');
      }
    } catch (e) {
      AppLogger.sync('   ⚠️ Failed to pull branch ingredient stocks: $e');
    }
  }

  // ============================================================================
  // BRANCH ITEM STOCK SYNC (Per-branch item inventory)
  // ============================================================================

  Future<void> syncBranchItemStock() async {
    await _pushBranchItemStock();
    await _pullBranchItemStock();
  }

  Future<void> _pushBranchItemStock() async {
    int totalPushed = 0;

    while (true) {
      final unsynced = await db.branchItemStockDao.getUnsyncedStock(
        limit: batchSize,
      );

      if (unsynced.isEmpty) break;

      final batchData = <Map<String, dynamic>>[];
      final syncedIds = <int>[];
      final cloudIdMap = <int, String>{};

      for (final stock in unsynced) {
        final cloudId = stock.cloudId ?? _uuid.v4();
        cloudIdMap[stock.id] = cloudId;
        _updateCache('branch_item_stock', stock.id, cloudId);

        final orgCloudId = _getCloudId('organizations', stock.organizationId);
        final itemCloudId = _getCloudId('items', stock.itemId);

        if (orgCloudId == null || itemCloudId == null) {
          AppLogger.sync('   ⚠️ Missing FK for branch item stock ${stock.id}: org=$orgCloudId, item=$itemCloudId');
          continue;
        }

        batchData.add({
          'cloud_id': cloudId,
          'organization_id': orgCloudId,
          'item_id': itemCloudId,
          'stock': stock.stock,
          'sold': stock.sold,
          'spoilage': stock.spoilage,
          'price': stock.price,
          'cost_price': stock.costPrice,
          'minimum_stock': stock.minimumStock,
          'last_received_at': stock.lastReceivedAt?.toIso8601String(),
          'last_received_quantity': stock.lastReceivedQuantity,
          'created_at': stock.createdAt.toIso8601String(),
          'last_updated': stock.lastUpdated.toIso8601String(),
          'is_deleted': stock.isDeleted,
        });
        syncedIds.add(stock.id);
      }

      if (batchData.isNotEmpty) {
        await _syncClient
            .from('branch_item_stock')
            .upsert(batchData, onConflict: 'cloud_id');
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.branchItemStockDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      // Break after processing since we're not using offset
      break;
    }

    if (totalPushed > 0) AppLogger.sync('   ↑ Pushed $totalPushed branch item stocks');
  }

  Future<void> _pullBranchItemStock() async {
    try {
      final lastSync =
          _lastSuccessfulSync?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';

      // RLS will filter to show only stocks for this org (or all for commissary)
      final cloudStocks = await supabase
          .from('branch_item_stock')
          .select()
          .gte('last_updated', lastSync)
          .order('last_updated', ascending: false)
          .limit(1000);

      AppLogger.sync('   📥 Received ${cloudStocks.length} branch item stocks from Supabase');

      if (cloudStocks.isNotEmpty) {
        int pulled = 0;
        for (final cloudStock in cloudStocks) {
          final orgCloudId = cloudStock['organization_id']?.toString();
          final itemCloudId = cloudStock['item_id']?.toString();

          final orgId = _getLocalId('organizations', orgCloudId);
          final itemId = _getLocalId('items', itemCloudId);

          if (orgId == null || itemId == null) {
            if (kDebugMode) {
              AppLogger.sync('   ⚠️ Skipping branch item stock: org=$orgId, item=$itemId');
            }
            continue;
          }

          await db.branchItemStockDao.upsertFromCloud({
            'cloud_id': cloudStock['cloud_id'],
            'organization_id': orgId,
            'item_id': itemId,
            'stock': cloudStock['stock'] ?? 0,
            'sold': cloudStock['sold'] ?? 0,
            'spoilage': cloudStock['spoilage'] ?? 0,
            'price': cloudStock['price'],
            'cost_price': cloudStock['cost_price'],
            'minimum_stock': cloudStock['minimum_stock'],
            'last_received_at': cloudStock['last_received_at'],
            'last_received_quantity': cloudStock['last_received_quantity'],
            'last_updated': cloudStock['last_updated'] ?? DateTime.now().toIso8601String(),
            'is_deleted': cloudStock['is_deleted'] ?? false,
          });
          pulled++;

          // Update cache
          final localStock = await db.branchItemStockDao.getStockForItem(orgId, itemId);
          if (localStock != null) {
            _updateCache('branch_item_stock', localStock.id, cloudStock['cloud_id']);
          }
        }
        if (pulled > 0) AppLogger.sync('   ↓ Pulled $pulled branch item stocks');
      }
    } catch (e) {
      AppLogger.sync('   ⚠️ Failed to pull branch item stocks: $e');
    }
  }

  // ============================================================================
  // IMMEDIATE SALES SYNC (for real-time)
  // ============================================================================

  /// Push a single sale immediately (bypasses batch sync)
  /// Call this when a sale is recorded for real-time visibility
  Future<bool> pushSaleImmediate(int stockChangeRequestId) async {
    if (!_isOnline || !canSync) return false;

    try {
      final request = await db.stockChangeRequestsDao.getChangeRequestById(stockChangeRequestId);
      if (request == null) return false;

      final cloudId = request.cloudId ?? _uuid.v4();
      final franchiseeCloudId = _getCloudId('organizations', request.franchiseeId);
      final itemCloudId = _getCloudId('items', request.itemId);
      final requestedByCloudId = _getCloudId('users', request.requestedBy);

      if (franchiseeCloudId == null || itemCloudId == null || requestedByCloudId == null) {
        AppLogger.sync('   ⚠️ Missing FK for immediate sale push');
        return false;
      }

      await _syncClient.from('stock_change_requests').upsert({
        'cloud_id': cloudId,
        'franchisee_id': franchiseeCloudId,
        'item_id': itemCloudId,
        'change_type': request.changeType,
        'quantity': request.quantity,
        'status': request.status,
        'requested_by': requestedByCloudId,
        'requested_at': request.requestedAt.toIso8601String(),
        'original_stock': request.originalStock,
        'reason': request.reason,
        'created_at': request.createdAt.toIso8601String(),
        'last_updated': request.lastUpdated.toIso8601String(),
      }, onConflict: 'cloud_id');

      // Mark as synced locally
      await db.stockChangeRequestsDao.markAsSynced(
        [request.id],
        cloudIds: {request.id: cloudId},
      );

      AppLogger.sync('⚡ Immediate sale pushed: $cloudId');
      return true;
    } catch (e) {
      AppLogger.sync('❌ Immediate sale push failed: $e');
      return false;
    }
  }

  // ============================================================================
  // UTILITIES
  // ============================================================================

  /// Cleanup old deleted records
  Future<void> _cleanupDeletedRecords() async {
    try {
      AppLogger.sync('🧹 Cleaning up deleted records...');

      final results = await Future.wait([
        db.itemsDao.cleanupDeletedItems(),
        db.usersDao.cleanupDeletedUsers(),
        db.rolesDao.cleanupDeletedRoles(),
        db.categoriesDao.cleanupDeletedCategories(),
      ]);

      final totalCleaned = results.fold(0, (sum, count) => sum + count);

      if (totalCleaned > 0) {
        AppLogger.sync('✅ Cleaned up $totalCleaned deleted records');
      }
    } catch (e) {
      AppLogger.sync('⚠️ Cleanup failed: $e');
    }
  }

  /// Force immediate sync
  Future<void> syncImmediate() async {
    AppLogger.sync('⚡ Immediate sync requested');
    await syncAll();
  }

  /// Quick sync for items/products only (faster than full sync)
  /// Use this for refresh buttons on product screens
  Future<void> syncItemsOnly() async {
    if (_isSyncing) {
      AppLogger.sync('⏳ Sync already in progress, skipping items-only sync...');
      return;
    }

    _isSyncing = true;
    AppLogger.sync('🔄 Quick sync: Items only...');
    onSyncStatusChanged?.call('Syncing products...');

    try {
      // Ensure caches are built
      if (_localToCloudCache['organizations']!.isEmpty) {
        await _buildCaches();
      }

      // Sync items (push local changes, pull from cloud)
      await syncItems();

      AppLogger.sync('✅ Quick sync completed');
      onSyncStatusChanged?.call('Synced');
      
      // Notify screens to refresh
      notifySyncComplete();
    } catch (e) {
      AppLogger.sync('❌ Quick sync failed: $e');
      onSyncError?.call('Quick sync failed: $e');
      onSyncStatusChanged?.call('Sync failed');
    } finally {
      _isSyncing = false;
    }
  }

  /// Get current sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final counts = await Future.wait([
        db.itemsDao.getUnsyncedItemCount(),
        db.usersDao.getUnsyncedUserCount(),
        db.rolesDao.getUnsyncedRoleCount(),
        db.organizationsDao.getUnsyncedOrganizationCount(),
        db.ingredientsDao.getUnsyncedIngredientCount(),
        db.recipeIngredientsDao.getUnsyncedRecipeIngredientCount(),
        db.stockReplenishmentRequestsDao.getUnsyncedRequestCount(),
        db.stockChangeRequestsDao.getUnsyncedChangeRequestCount(),
      ]);

      return {
        'unsynced_items': counts[0],
        'unsynced_users': counts[1],
        'unsynced_roles': counts[2],
        'unsynced_organizations': counts[3],
        'unsynced_ingredients': counts[4],
        'unsynced_recipes': counts[5],
        'unsynced_replenishment_requests': counts[6],
        'unsynced_change_requests': counts[7],
        'total_unsynced': counts.fold(0, (sum, c) => sum + c),
        'is_syncing': _isSyncing,
        'is_online': _isOnline,
        'last_sync': _lastSuccessfulSync?.toIso8601String() ?? 'Never',
        'cache_size': _localToCloudCache.values.fold(
          0,
          (sum, map) => sum + map.length,
        ),
        'organization_type': _currentOrganizationType,
        'organization_id': _currentOrganizationId,
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'is_syncing': _isSyncing,
        'is_online': _isOnline,
      };
    }
  }

  /// Update organization context (call after login)
  void setOrganizationContext({
    required int organizationId,
    required String organizationType,
    int? parentCommissaryId,
  }) {
    _currentOrganizationId = organizationId;
    _currentOrganizationType = organizationType;
    _parentCommissaryId = parentCommissaryId;
    _loadOrganizationCloudIds();

    AppLogger.sync('📍 Sync context updated: $organizationType org #$organizationId');
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    _localToCloudCache.clear();
    _cloudToLocalCache.clear();
    AppLogger.sync('🛑 Sync service disposed');
  }
}

/// Internal sync step helper
class _SyncStep {
  final String name;
  final Future<void> Function() sync;

  _SyncStep(this.name, this.sync);
}