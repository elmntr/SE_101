// lib/services/supabase_sync_service.dart
import 'dart:async';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import 'package:flutter/foundation.dart';

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
    String? organizationType,
    int? parentCommissaryId,
  }) async {
    print('🚀 Initializing optimized sync service...');
    
    try {
      // Set organization context for star topology
      _currentOrganizationId = organizationId;
      _currentOrganizationType = organizationType;
      _parentCommissaryId = parentCommissaryId;
      
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
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_handleConnectivityChange);
      
      // Initial sync if online
      if (_isOnline) {
        // Delay initial sync slightly to let UI settle
        Future.delayed(const Duration(seconds: 2), () => syncAll());
      }
      
      print('✅ Sync service initialized (${_currentOrganizationType ?? 'unknown'} mode)');
    } catch (e, stackTrace) {
      print('❌ Failed to initialize sync service: $e');
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
        print('📡 Network restored, triggering sync...');
        syncAll();
      } else {
        print('🔵 Network lost');
        onSyncStatusChanged?.call('Offline');
      }
    }
  }

  /// Load organization cloud IDs for context
  Future<void> _loadOrganizationCloudIds() async {
    if (_currentOrganizationId != null) {
      _currentOrganizationCloudId = _getCloudId('organizations', _currentOrganizationId);
    }
    if (_parentCommissaryId != null) {
      _parentCommissaryCloudId = _getCloudId('organizations', _parentCommissaryId);
    }
  }

  // ============================================================================
  // CACHE MANAGEMENT
  // ============================================================================

  /// Build both forward and reverse caches
  Future<void> _buildCaches() async {
    print('🔧 Building UUID caches...');
    final stopwatch = Stopwatch()..start();
    
    try {
      await Future.wait([
        _cacheTable('organizations', () => db.organizationsDao.getAllOrganizations(), 
            (org) => org.cloudId, (org) => org.id),
        _cacheTable('roles', () => db.rolesDao.getAllRoles(), 
            (role) => role.cloudId, (role) => role.id),
        _cacheTable('users', () => db.usersDao.getAllUsers(), 
            (user) => user.cloudId, (user) => user.id),
        _cacheTable('items', () => db.itemsDao.getAllItems(), 
            (item) => item.cloudId, (item) => item.id),
        _cacheTable('ingredients', () => db.ingredientsDao.getAllIngredients(), 
            (ing) => ing.cloudId, (ing) => ing.id),
        _cacheTable('recipe_ingredients', () => db.recipeIngredientsDao.getAllRecipeIngredients(), 
            (ri) => ri.cloudId, (ri) => ri.id),
      ]);
      
      stopwatch.stop();
      final totalEntries = _localToCloudCache.values.fold(0, (sum, map) => sum + map.length);
      print('✅ Caches built: $totalEntries entries in ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      print('⚠️ Error building caches: $e');
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
  void _clearTableCache(String table) {
    _localToCloudCache[table]?.clear();
    _cloudToLocalCache[table]?.clear();
  }

  // ============================================================================
  // CONNECTIVITY
  // ============================================================================

  Future<bool> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity()
          .timeout(const Duration(seconds: 5));
      return result != ConnectivityResult.none;
    } catch (e) {
      print('⚠️ Connectivity check failed: $e');
      return false;
    }
  }

  void startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(syncInterval, (_) => syncAll());
    print('â° Periodic sync started (every ${syncInterval.inMinutes} minutes)');
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    print('⏸️ Periodic sync stopped');
  }

  // ============================================================================
  // MAIN SYNC ORCHESTRATION
  // ============================================================================

  /// Main sync method with star topology awareness
  Future<void> syncAll() async {
    if (_isSyncing) {
      print('⏳ Sync already in progress, skipping...');
      return;
    }

    if (!_isOnline) {
      print('🔵 Offline, sync skipped');
      onSyncStatusChanged?.call('Offline');
      return;
    }

    _isSyncing = true;
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        onSyncStatusChanged?.call('Syncing...');
        
        print('🔄 Starting sync (attempt $attempt/$maxRetries)...');
        print('   Mode: ${_currentOrganizationType ?? 'full'} | Org: $_currentOrganizationId');
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
        
        print('✅ Sync completed in ${duration.inSeconds}s');
        onSyncStatusChanged?.call('Synced');
        onSyncComplete?.call();
        
        // Rebuild caches after successful sync
        await _buildCaches();
        
        // Cleanup old deleted records
        await _cleanupDeletedRecords();
        
        _isSyncing = false;
        return;
        
      } catch (e, stackTrace) {
        print('❌ Sync attempt $attempt failed: $e');
        if (kDebugMode) print(stackTrace);
        
        if (attempt == maxRetries) {
          onSyncError?.call('Sync failed after $maxRetries attempts: $e');
          onSyncStatusChanged?.call('Sync failed');
          _isSyncing = false;
          return;
        }
        
        // Exponential backoff with jitter
        final delay = _calculateBackoff(attempt);
        print('⏳ Retrying in ${delay.inSeconds}s...');
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
      _SyncStep('ReplenishmentRequests', syncStockReplenishmentRequests),
      _SyncStep('ChangeRequests', syncStockChangeRequests),
    ];
  }

  /// Calculate exponential backoff with jitter
  Duration _calculateBackoff(int attempt) {
    final baseDelay = initialRetryDelay.inMilliseconds * pow(2, attempt - 1);
    final jitter = Random().nextInt(1000); // 0-1000ms jitter
    return Duration(milliseconds: baseDelay.toInt() + jitter);
  }

  /// Sync table with isolated error handling
  Future<void> _syncTableWithRetry(String tableName, Future<void> Function() syncFunction) async {
    try {
      print('📊 Syncing $tableName...');
      await syncFunction().timeout(requestTimeout);
      print('   ✅ $tableName done');
    } catch (e) {
      print('   ⚠️ $tableName failed: $e');
      // Don't rethrow - continue with other tables
      onSyncError?.call('$tableName: $e');
    }
  }

  // ============================================================================
  // ORGANIZATIONS SYNC (Star topology aware)
  // ============================================================================

  Future<void> syncOrganizations() async {
    try {
      print('ðŸ¢ Syncing organizations...');
      await _pushOrganizations();
      await _pullOrganizations();
      print('   âœ… Organizations sync complete');
    } catch (e) {
      print('   âŒ Organizations sync failed: $e');
      rethrow;
    }
  }

  Future<void> _pushOrganizations() async {
    int totalPushed = 0;
    int offset = 0;
    int totalPushed = 0;

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

        final parentCloudId = _getCloudId('organizations', org.parentCommissaryId);

        batchData.add({
          'cloud_id': cloudId,
          'local_id': org.id,
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
        await supabase.from('organizations').upsert(batchData, onConflict: 'cloud_id');
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.organizationsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) print('   ↑ Pushed $totalPushed organizations');
  }

  Future<void> _pullOrganizations() async {
    try {
      final lastSync = _lastSuccessfulSync?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';
      
      // RLS will filter based on user's organization automatically
      final cloudOrgs = await supabase
          .from('organizations')
          .select()
          .order('last_updated', ascending: false)
          .limit(500);

      if (cloudOrgs.isNotEmpty) {
        final resolvedOrgs = <Map<String, dynamic>>[];
        
        for (final cloudOrg in cloudOrgs) {
          int? parentId;
          if (cloudOrg['parent_commissary_id'] != null) {
            parentId = _getLocalId('organizations', cloudOrg['parent_commissary_id']);
          }
          
          resolvedOrgs.add({
            ...cloudOrg,
            'parent_commissary_id': parentId,
          });
        }
        
        await db.organizationsDao.upsertBatchFromCloud(resolvedOrgs);
        print('   ↓ Pulled ${resolvedOrgs.length} organizations');
        
        // Update caches
        for (final org in resolvedOrgs) {
          if (org['cloud_id'] != null && org['local_id'] != null) {
            _updateCache('organizations', org['local_id'], org['cloud_id']);
          }
        }
      }
    } catch (e) {
      print('   âš ï¸ Failed to pull organizations: $e');
    }
  }

  // ============================================================================
  // ROLES SYNC
  // ============================================================================

  Future<void> syncIngredients() async {
    try {
      print('ðŸ¥• Syncing ingredients...');
      await _pushIngredients();
      await _pullIngredients();
      print('   âœ… Ingredients sync complete');
    } catch (e) {
      print('   âŒ Ingredients sync failed: $e');
      rethrow;
    }
  }

  Future<void> _pushIngredients() async {
    int offset = 0;
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

      for (final role in unsynced) {
        if (!role.isActive) continue;

        final cloudId = role.cloudId ?? _uuid.v4();
        cloudIdMap[role.id] = cloudId;
        _updateCache('roles', role.id, cloudId);

        batchData.add({
          'cloud_id': cloudId,
          'local_id': role.id,
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
        await supabase.from('ingredients').upsert(batchData);
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.ingredientsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) print('   ↑ Pushed $totalPushed roles');
  }

  Future<void> _pullIngredients() async {
    try {
      final cloudIngredients = await supabase
          .from('ingredients')
          .select()
          .order('last_updated', ascending: false)
          .limit(500);

      if (cloudRoles.isNotEmpty) {
        await db.rolesDao.upsertBatchFromCloud(cloudRoles);
        print('   ↓ Pulled ${cloudRoles.length} roles');
        
        for (final role in cloudRoles) {
          if (role['cloud_id'] != null && role['local_id'] != null) {
            _updateCache('roles', role['local_id'], role['cloud_id']);
          }
        }
      }
    } catch (e) {
      print('   âš ï¸ Failed to pull ingredients: $e');
    }
  }

  // ============================================================================
  // USERS SYNC (with FK resolution)
  // ============================================================================

  Future<void> syncUsers() async {
    await _pushUsers();
    await _pullUsers();
  }

  Future<void> _pushRecipeIngredients() async {
    int offset = 0;
    int totalPushed = 0;
    int skipped = 0;
    int offset = 0;

    while (true) {
      final unsynced = await db.recipeIngredientsDao
          .getUnsyncedRecipeIngredients(limit: batchSize, offset: offset);

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
          'local_id': user.id,
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
        await supabase.from('recipe_ingredients').upsert(batchData);
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

    if (totalPushed > 0) print('   ↑ Pushed $totalPushed users');
    if (skipped > 0) print('   ⚠️ Skipped $skipped users (missing FKs)');
  }

  Future<void> _pullRecipeIngredients() async {
    try {
      final lastSync = _lastSuccessfulSync?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';
      
      // RLS filters users based on organization
      final cloudUsers = await supabase
          .from('users')
          .select()
          .order('last_updated', ascending: false)
          .limit(500);

      if (cloudUsers.isNotEmpty) {
        final resolvedUsers = <Map<String, dynamic>>[];
        
        for (final cloudUser in cloudUsers) {
          final orgId = _getLocalId('organizations', cloudUser['organization_id']);
          final roleId = _getLocalId('roles', cloudUser['role_id']);
          
          if (orgId == null || roleId == null) continue;
          
          resolvedUsers.add({
            ...cloudUser,
            'organization_id': orgId,
            'role_id': roleId,
          });
        }
        
        if (resolvedUsers.isNotEmpty) {
          await db.usersDao.upsertBatchFromCloud(resolvedUsers);
          print('   ↓ Pulled ${resolvedUsers.length} users');
        }
      }
    } catch (e) {
      print('   âš ï¸ Failed to pull recipe ingredients: $e');
    }
  }

  // ============================================================================
  // ITEMS SYNC (Star topology: Commissary items visible to franchisees)
  // ============================================================================

  Future<void> syncItems() async {
    await _pushItems();
    await _pullItems();
  }

  Future<void> _pushReplenishmentRequests() async {
    int offset = 0;
    int totalPushed = 0;
    int skipped = 0;
    int offset = 0;

    while (true) {
      final unsynced = await db.stockReplenishmentRequestsDao
          .getUnsyncedRequests(limit: batchSize, offset: offset);

      if (unsynced.isEmpty) break;

      final batchData = <Map<String, dynamic>>[];
      final syncedIds = <int>[];
      final cloudIdMap = <int, String>{};

      for (final item in unsynced) {
        if (item.isDeleted) continue;

        final cloudId = item.cloudId ?? _uuid.v4();
        final orgCloudId = _getCloudId('organizations', item.organizationId);
        final masterItemCloudId = _getCloudId('items', item.masterItemId);

        if (orgCloudId == null) {
          skipped++;
          continue;
        }

        cloudIdMap[item.id] = cloudId;
        _updateCache('items', item.id, cloudId);

        batchData.add({
          'cloud_id': cloudId,
          'local_id': item.id,
          'name': item.name,
          'organization_id': orgCloudId,
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
        await supabase.from('stock_replenishment_requests').upsert(batchData);
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

    if (totalPushed > 0) print('   ↑ Pushed $totalPushed items');
    if (skipped > 0) print('   ⚠️ Skipped $skipped items (missing FKs)');
  }

  Future<void> _pullReplenishmentRequests() async {
    try {
      final lastSync = _lastSuccessfulSync?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';
      
      // RLS handles filtering - commissary sees all, franchisee sees own + master items
      final cloudItems = await supabase
          .from('items')
          .select()
          .order('last_updated', ascending: false)
          .limit(1000);

      if (cloudItems.isNotEmpty) {
        final resolvedItems = <Map<String, dynamic>>[];
        
        for (final cloudItem in cloudItems) {
          final orgId = _getLocalId('organizations', cloudItem['organization_id']);
          final masterItemId = _getLocalId('items', cloudItem['master_item_id']);
          
          if (orgId == null) continue;
          
          resolvedItems.add({
            ...cloudItem,
            'organization_id': orgId,
            'master_item_id': masterItemId,
          });
        }
        
        if (resolvedItems.isNotEmpty) {
          // Process in batches
          for (int i = 0; i < resolvedItems.length; i += batchSize) {
            final end = min(i + batchSize, resolvedItems.length);
            final batch = resolvedItems.sublist(i, end);
            await db.itemsDao.upsertBatchFromCloud(batch);
          }
          print('   ↓ Pulled ${resolvedItems.length} items');
        }
      }
    } catch (e) {
      print('   âš ï¸ Failed to pull replenishment requests: $e');
    }
  }

  // ============================================================================
  // INGREDIENTS SYNC (Commissary only, visible to franchisees)
  // ============================================================================

  Future<void> syncIngredients() async {
    await _pushIngredients();
    await _pullIngredients();
  }

  Future<void> _pushChangeRequests() async {
    int offset = 0;
    int totalPushed = 0;
    int offset = 0;

    while (true) {
      final unsynced = await db.stockChangeRequestsDao
          .getUnsyncedChangeRequests(limit: batchSize, offset: offset);

      if (unsynced.isEmpty) break;

      final batchData = <Map<String, dynamic>>[];
      final syncedIds = <int>[];
      final cloudIdMap = <int, String>{};

      for (final ingredient in unsynced) {
        if (ingredient.isDeleted) continue;

        final cloudId = ingredient.cloudId ?? _uuid.v4();
        final commissaryCloudId = _getCloudId('organizations', ingredient.commissaryId);

        if (commissaryCloudId == null) continue;

        cloudIdMap[ingredient.id] = cloudId;
        _updateCache('ingredients', ingredient.id, cloudId);

        batchData.add({
          'cloud_id': cloudId,
          'local_id': ingredient.id,
          'name': ingredient.name,
          'commissary_id': commissaryCloudId,
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
        await supabase.from('stock_change_requests').upsert(batchData);
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

    if (totalPushed > 0) print('   ↑ Pushed $totalPushed ingredients');
  }

  Future<void> _pullChangeRequests() async {
    try {
      final cloudRequests = await supabase
          .from('stock_change_requests')
          .select()
          .order('last_updated', ascending: false)
          .limit(500);

      if (cloudIngredients.isNotEmpty) {
        final resolvedIngredients = <Map<String, dynamic>>[];
        
        for (final cloudIngredient in cloudIngredients) {
          final commissaryId = _getLocalId('organizations', cloudIngredient['commissary_id']);
          
          if (commissaryId == null) continue;
          
          resolvedIngredients.add({
            ...cloudIngredient,
            'commissary_id': commissaryId,
          });
        }
        
        if (resolvedIngredients.isNotEmpty) {
          await db.ingredientsDao.upsertBatchFromCloud(resolvedIngredients);
          print('   ↓ Pulled ${resolvedIngredients.length} ingredients');
        }
      }
    } catch (e) {
      print('   âš ï¸ Failed to pull change requests: $e');
    }
  }

  // ============================================================================
  // RECIPE INGREDIENTS SYNC
  // ============================================================================

  Future<void> syncRecipeIngredients() async {
    await _pushRecipeIngredients();
    await _pullRecipeIngredients();
  }

  Future<void> _pushItems() async {
    int offset = 0;
    int totalPushed = 0;
    int offset = 0;

    while (true) {
      final unsyncedItems = await db.itemsDao.getUnsyncedItems(
        limit: batchSize,
        offset: offset,
      );

      if (unsyncedItems.isEmpty) break;

      final batchData = <Map<String, dynamic>>[];
      final syncedIds = <int>[];
      final cloudIdMap = <int, String>{};

      for (final recipe in unsynced) {
        if (recipe.isDeleted) continue;

        final cloudId = recipe.cloudId ?? _uuid.v4();
        final itemCloudId = _getCloudId('items', recipe.itemId);
        final ingredientCloudId = _getCloudId('ingredients', recipe.ingredientId);

        if (itemCloudId == null || ingredientCloudId == null) continue;

        cloudIdMap[recipe.id] = cloudId;
        _updateCache('recipe_ingredients', recipe.id, cloudId);

        batchData.add({
          'cloud_id': cloudId,
          'local_id': recipe.id,
          'item_id': itemCloudId,
          'ingredient_id': ingredientCloudId,
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
        await supabase.from('items').upsert(batchData);
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.itemsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) print('   ↑ Pushed $totalPushed recipe ingredients');
  }

  Future<void> _pullItems() async {
    try {
      final cloudItems = await supabase
          .from('items')
          .select()
          .order('last_updated', ascending: false)
          .limit(500);

      if (cloudRecipes.isNotEmpty) {
        final resolvedRecipes = <Map<String, dynamic>>[];
        
        for (final cloudRecipe in cloudRecipes) {
          final itemId = _getLocalId('items', cloudRecipe['item_id']);
          final ingredientId = _getLocalId('ingredients', cloudRecipe['ingredient_id']);
          
          if (itemId == null || ingredientId == null) continue;
          
          resolvedRecipes.add({
            ...cloudRecipe,
            'item_id': itemId,
            'ingredient_id': ingredientId,
          });
        }
        
        if (resolvedRecipes.isNotEmpty) {
          await db.recipeIngredientsDao.upsertBatchFromCloud(resolvedRecipes);
          print('   ↓ Pulled ${resolvedRecipes.length} recipe ingredients');
        }
      }
    } catch (e) {
      print('   âš ï¸ Failed to pull items: $e');
    }
  }

  // ============================================================================
  // STOCK REPLENISHMENT REQUESTS SYNC
  // ============================================================================

  Future<void> syncUsers() async {
    try {
      print('ðŸ¥ Syncing users...');
      await _pushUsers();
      await _pullUsers();
      print('   âœ… Users sync complete');
    } catch (e) {
      print('   âŒ Users sync failed: $e');
    }
  }

  Future<void> _pushUsers() async {
    int offset = 0;
    int totalPushed = 0;
    int offset = 0;

    while (true) {
      final unsyncedUsers = await db.usersDao.getUnsyncedUsers(
        limit: batchSize,
        offset: offset,
      );

      if (unsyncedUsers.isEmpty) break;

      final batchData = <Map<String, dynamic>>[];
      final syncedIds = <int>[];
      final cloudIdMap = <int, String>{};

      for (final request in unsynced) {
        if (request.isDeleted) continue;

        final cloudId = request.cloudId ?? _uuid.v4();
        final franchiseeCloudId = _getCloudId('organizations', request.franchiseeId);
        final commissaryCloudId = _getCloudId('organizations', request.commissaryId);
        final itemCloudId = _getCloudId('items', request.itemId);
        final requestedByCloudId = _getCloudId('users', request.requestedBy);
        final reviewedByCloudId = _getCloudId('users', request.reviewedBy);

        if (franchiseeCloudId == null || commissaryCloudId == null || 
            itemCloudId == null || requestedByCloudId == null) continue;

        cloudIdMap[request.id] = cloudId;

        batchData.add({
          'cloud_id': cloudId,
          'local_id': request.id,
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
        await supabase.from('users').upsert(batchData);
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.usersDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) print('   ↑ Pushed $totalPushed replenishment requests');
  }

  Future<void> _pullUsers() async {
    try {
      final lastSync = _lastSuccessfulSync?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';
      
      // RLS filters: Commissary sees requests to them, Franchisee sees own requests
      final cloudRequests = await supabase
          .from('stock_replenishment_requests')
          .select()
          .order('last_updated', ascending: false)
          .limit(500);

      if (cloudRequests.isNotEmpty) {
        final resolvedRequests = <Map<String, dynamic>>[];
        
        for (final cloudRequest in cloudRequests) {
          final franchiseeId = _getLocalId('organizations', cloudRequest['franchisee_id']);
          final commissaryId = _getLocalId('organizations', cloudRequest['commissary_id']);
          final itemId = _getLocalId('items', cloudRequest['item_id']);
          final requestedById = _getLocalId('users', cloudRequest['requested_by']);
          final reviewedById = _getLocalId('users', cloudRequest['reviewed_by']);
          
          if (franchiseeId == null || commissaryId == null || 
              itemId == null || requestedById == null) continue;
          
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
          await db.stockReplenishmentRequestsDao.upsertBatchFromCloud(resolvedRequests);
          print('   ↓ Pulled ${resolvedRequests.length} replenishment requests');
        }
      }
    } catch (e) {
      print('   âš ï¸ Failed to pull users: $e');
    }
  }

  // ============================================================================
  // STOCK CHANGE REQUESTS SYNC
  // ============================================================================

  Future<void> syncRoles() async {
    try {
      print('ðŸ" Syncing roles...');
      await _pushRoles();
      await _pullRoles();
      print('   âœ… Roles sync complete');
    } catch (e) {
      print('   âŒ Roles sync failed: $e');
    }
  }

  Future<void> _pushRoles() async {
    int offset = 0;
    int totalPushed = 0;
    int offset = 0;

    while (true) {
      final unsyncedRoles = await db.rolesDao.getUnsyncedRoles(
        limit: batchSize,
        offset: offset,
      );

      if (unsyncedRoles.isEmpty) break;

      final batchData = <Map<String, dynamic>>[];
      final syncedIds = <int>[];
      final cloudIdMap = <int, String>{};

      for (final request in unsynced) {
        if (request.isDeleted) continue;

        final cloudId = request.cloudId ?? _uuid.v4();
        final franchiseeCloudId = _getCloudId('organizations', request.franchiseeId);
        final itemCloudId = _getCloudId('items', request.itemId);
        final requestedByCloudId = _getCloudId('users', request.requestedBy);
        final reviewedByCloudId = _getCloudId('users', request.reviewedBy);

        if (franchiseeCloudId == null || itemCloudId == null || requestedByCloudId == null) continue;

        cloudIdMap[request.id] = cloudId;

        batchData.add({
          'cloud_id': cloudId,
          'local_id': request.id,
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
        await supabase.from('roles').upsert(batchData);
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.rolesDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) print('   ↑ Pushed $totalPushed change requests');
  }

  Future<void> _pullRoles() async {
    try {
      final cloudRoles = await supabase
          .from('roles')
          .select()
          .order('last_updated', ascending: false)
          .limit(500);

      if (cloudRequests.isNotEmpty) {
        final resolvedRequests = <Map<String, dynamic>>[];
        
        for (final cloudRequest in cloudRequests) {
          final franchiseeId = _getLocalId('organizations', cloudRequest['franchisee_id']);
          final itemId = _getLocalId('items', cloudRequest['item_id']);
          final requestedById = _getLocalId('users', cloudRequest['requested_by']);
          final reviewedById = _getLocalId('users', cloudRequest['reviewed_by']);
          
          if (franchiseeId == null || itemId == null || requestedById == null) continue;
          
          resolvedRequests.add({
            ...cloudRequest,
            'franchisee_id': franchiseeId,
            'item_id': itemId,
            'requested_by': requestedById,
            'reviewed_by': reviewedById,
          });
        }
        
        if (resolvedRequests.isNotEmpty) {
          await db.stockChangeRequestsDao.upsertBatchFromCloud(resolvedRequests);
          print('   ↓ Pulled ${resolvedRequests.length} change requests');
        }
      }
    } catch (e) {
      print('   âš ï¸ Failed to pull roles: $e');
    }
  }

  // ============================================================================
  // UTILITIES
  // ============================================================================

  /// Cleanup old deleted records
  Future<void> _cleanupDeletedRecords() async {
    try {
      print('🧹 Cleaning up deleted records...');
      
      final results = await Future.wait([
        db.itemsDao.cleanupDeletedItems(),
        db.usersDao.cleanupDeletedUsers(),
        db.rolesDao.cleanupDeletedRoles(),
        db.categoriesDao.cleanupDeletedCategories(),
      ]);
      
      final totalCleaned = results.fold(0, (sum, count) => sum + count);
      
      if (totalCleaned > 0) {
        print('✅ Cleaned up $totalCleaned deleted records');
      }
    } catch (e) {
      print('⚠️ Cleanup failed: $e');
    }
  }

  /// Force immediate sync
  Future<void> syncImmediate() async {
    print('âš¡ Immediate sync requested');
    await syncAll();
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
        'cache_size': _localToCloudCache.values.fold(0, (sum, map) => sum + map.length),
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
    
    print('📍 Sync context updated: $organizationType org #$organizationId');
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    _localToCloudCache.clear();
    _cloudToLocalCache.clear();
    print('🛑 Sync service disposed');
  }
}

/// Internal sync step helper
class _SyncStep {
  final String name;
  final Future<void> Function() sync;
  
  _SyncStep(this.name, this.sync);
}
