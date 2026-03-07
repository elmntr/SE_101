// lib/services/supabase_sync_service_v2.dart
//
// REFACTORED SYNC SERVICE - Uses SyncEngine with table descriptors
// Reduces ~2,200 lines to ~500 lines with better maintainability
//
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../utils/app_logger.dart';
import '../app_globals.dart' show notifySyncComplete;
import 'sync/sync.dart';

/// Refactored Supabase Sync Service using generic SyncEngine
/// 
/// Key improvements:
/// - Generic push/pull via SyncEngine with per-table retry
/// - Parallel sync within dependency tiers
/// - Conflict detection with audit table
/// - Reduced code duplication (~500 lines vs ~2,200)
/// - Toast notifications for conflicts
class SupabaseSyncServiceV2 {
  final AppDatabase db;
  final SupabaseClient supabase;
  late final SyncEngine _engine;

  Timer? _syncTimer;
  bool _isSyncing = false;
  bool _isOnline = true;
  // Set to true when clearOrganizationContext() is called while a sync is
  // running; the clear is applied in syncAll()'s finally block instead.
  bool _pendingContextClear = false;
  StreamSubscription? _connectivitySubscription;

  // Issue 6 fix: Sync lock to prevent overlapping sync calls
  Completer<void>? _syncCompleter;

  // Issue 5 fix: Debounce rapid sync requests
  Timer? _syncDebounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  // Smart sync: Don't re-sync within 30 seconds
  DateTime? _lastFullSyncTime;
  static const Duration smartSyncCooldown = Duration(seconds: 30);

  // Issue 2 fix: Prevent duplicate initialization
  bool _isInitialized = false;

  // Issue 11 fix: Cache getSyncStatus result for 10 seconds
  Map<String, dynamic>? _cachedSyncStatus;
  DateTime? _cacheTimestamp;
  static const Duration _cacheTTL = Duration(seconds: 10);

  // Configuration
  static const Duration syncInterval = Duration(minutes: 5);

  // Organization context
  int? _currentOrganizationId;
  String? _currentOrganizationCloudId;
  String? _currentOrganizationType;
  int? _parentCommissaryId;
  String? _parentCommissaryCloudId;

  // Callbacks
  Function(bool isOnline)? onConnectivityChanged;
  Function(String status)? onSyncStatusChanged;
  Function(String error)? onSyncError;
  Function(double progress, String tableName)? onSyncProgress;
  Function()? onSyncComplete;
  Function(String tableName, String message)? onConflictDetected;

  /// Check if sync is allowed (user must be authenticated)
  bool get canSync => supabase.auth.currentUser != null;

  SupabaseSyncServiceV2({
    required this.db,
    required this.supabase,
    this.onConnectivityChanged,
    this.onSyncStatusChanged,
    this.onSyncError,
    this.onSyncProgress,
    this.onSyncComplete,
    this.onConflictDetected,
  }) {
    _engine = SyncEngine(
      db: db,
      supabase: supabase,
      onConflictDetected: (tableName, message) {
        onConflictDetected?.call(tableName, message);
        _logConflictNotification(tableName, message);
      },
      onTableError: (tableName, error) {
        onSyncError?.call('$tableName: $error');
      },
      onTableSynced: (tableName, pushed, pulled) {
        if (kDebugMode) {
          AppLogger.sync('   ✅ $tableName: ↑$pushed ↓$pulled');
        }
      },
      onConflictLogged: (conflict) async {
        await _saveConflictToDb(conflict);
      },
    );
  }

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  Future<void> initialize({
    int? organizationId,
    String? organizationCloudId,
    String? organizationType,
    int? parentCommissaryId,
    String? parentCommissaryCloudId,
  }) async {
    // Issue 2 fix: Guard against duplicate initialization
    if (_isInitialized) {
      AppLogger.sync('⚠️ Sync service already initialized, skipping');
      return;
    }

    AppLogger.sync('🚀 Initializing sync service v2...');
    AppLogger.websocket('🔌 SYNC INIT  orgId=$organizationId  orgType=$organizationType  cloudId=$organizationCloudId');

    try {
      _currentOrganizationId = organizationId;
      _currentOrganizationCloudId = organizationCloudId;
      _currentOrganizationType = organizationType;
      _parentCommissaryId = parentCommissaryId;
      _parentCommissaryCloudId = parentCommissaryCloudId;

      // Set engine context
      _engine.setOrganizationContext(
        organizationType: organizationType,
        organizationId: organizationId,
        organizationCloudId: organizationCloudId,
      );

      // Check connectivity
      _isOnline = await _checkConnectivity();
      onConnectivityChanged?.call(_isOnline);

      // Initialize caches (defer to background - don't block UI)
      AppLogger.sync('⏱️ Deferring cache initialization to background...');
      _engine.initializeCaches([
        'organizations',
        'roles',
        'users',
        'items',
        'ingredients',
        'recipe_ingredients',
        'stock_replenishment_requests',
        'stock_change_requests',
        'daily_sales_summary',
        'branch_ingredient_stock',
        'branch_item_stock',
      ]).then((_) {
        AppLogger.sync('⏱️ Cache initialization completed in background');
      }).catchError((e) {
        AppLogger.error('⚠️ Cache initialization failed: $e');
      });

      // Load organization cloud IDs (quick operation)
      await _loadOrganizationCloudIds();

      // Start periodic sync
      startPeriodicSync();

      // Listen to connectivity
      _connectivitySubscription?.cancel();
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
        _handleConnectivityChange,
      );

      _isInitialized = true;

      // Initial sync
      if (_isOnline) {
        Future.delayed(const Duration(seconds: 2), () => syncAll());
      }

      AppLogger.sync('✅ Sync service v2 initialized (${_currentOrganizationType ?? 'unknown'} mode)');
    } catch (e, stackTrace) {
      AppLogger.sync('❌ Failed to initialize sync service: $e');
      //if (kDebugMode) print(stackTrace);
      onSyncError?.call('Initialization failed: $e');
    }
  }

  Future<bool> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity().timeout(
        const Duration(seconds: 5),
      );
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;

    if (wasOnline != _isOnline) {
      onConnectivityChanged?.call(_isOnline);

      if (_isOnline) {
        AppLogger.sync('📡 Network restored, debouncing sync...');
        // Debounce rapid connectivity events (WiFi reconnect often fires
        // multiple times in quick succession).
        _syncDebounceTimer?.cancel();
        _syncDebounceTimer = Timer(_debounceDelay, () => syncAll());
      } else {
        AppLogger.sync('🔵 Network lost');
        onSyncStatusChanged?.call('Offline');
      }
    }
  }

  Future<void> _loadOrganizationCloudIds() async {
    if (_currentOrganizationCloudId == null && _currentOrganizationId != null) {
      _currentOrganizationCloudId = _engine.getCloudId(
        'organizations',
        _currentOrganizationId,
      );
    }
    if (_parentCommissaryCloudId == null && _parentCommissaryId != null) {
      _parentCommissaryCloudId = _engine.getCloudId(
        'organizations',
        _parentCommissaryId,
      );
    }
  }

  void startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(syncInterval, (_) => syncAll());
    AppLogger.sync('⏰ Periodic sync started (every ${syncInterval.inMinutes} minutes)');
    AppLogger.websocket('🔌 PERIODIC SYNC STARTED  interval=${syncInterval.inMinutes}min');
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    AppLogger.sync('⏸️ Periodic sync stopped');
    AppLogger.websocket('🔌 PERIODIC SYNC STOPPED');
  }

  // ============================================================================
  // MAIN SYNC ORCHESTRATION - TIERED PARALLEL SYNC
  // ============================================================================

  Future<void> syncAll() async {
    // Issue 6 fix: Use Completer to prevent overlapping sync calls
    if (_syncCompleter != null && !_syncCompleter!.isCompleted) {
      AppLogger.sync('⏳ Sync already in progress (via Completer)');
      return _syncCompleter!.future;
    }

    if (_isSyncing) {
      AppLogger.sync('⏳ Sync already in progress');
      return;
    }

    if (!_isOnline) {
      AppLogger.sync('🔵 Offline, sync skipped');
      onSyncStatusChanged?.call('Offline');
      return;
    }

    if (!canSync) {
      AppLogger.sync('🔒 Not authenticated');
      onSyncStatusChanged?.call('Not authenticated');
      return;
    }

    // Smart sync: Don't re-sync within cooldown period
    if (_lastFullSyncTime != null) {
      final timeSinceLastSync = DateTime.now().difference(_lastFullSyncTime!);
      if (timeSinceLastSync.inSeconds < smartSyncCooldown.inSeconds) {
        AppLogger.sync('⏸️ Sync already ran ${timeSinceLastSync.inSeconds}s ago, skipping (cooldown: ${smartSyncCooldown.inSeconds}s)');
        return;
      }
    }

    _isSyncing = true;
    _syncCompleter = Completer<void>();
    onSyncStatusChanged?.call('Syncing...');

    try {
      AppLogger.sync('🔄 Starting tiered sync...');
      final startTime = DateTime.now();

      // Build tiered sync map
      final tierMap = _buildTierMap();
      final totalTables = tierMap.values.fold(0, (sum, list) => sum + list.length);
      int completedTables = 0;

      // Execute tiers sequentially, tables within tier in parallel
      final sortedTiers = tierMap.keys.toList()..sort();
      
      for (final tier in sortedTiers) {
        // Re-check auth before each tier to avoid wasted requests
        if (!canSync) {
          AppLogger.sync('🔒 Auth lost before tier $tier, aborting sync');
          onSyncStatusChanged?.call('Not authenticated');
          return;
        }

        final tierFunctions = tierMap[tier] ?? [];
        if (tierFunctions.isEmpty) continue;

        if (kDebugMode) {
          AppLogger.sync('📊 Syncing Tier $tier (${tierFunctions.length} tables)...');
        }

        // Execute all tables in this tier in parallel
        await Future.wait(tierFunctions.map((fn) => fn()), eagerError: true);

        // IMPORTANT: Rebuild caches after each tier so that subsequent tiers
        // can resolve foreign keys to records just pulled from this tier.
        // For example, Tier 2 (items) needs Tier 1 (organizations) in the cache.
        await _engine.rebuildAllCaches();

        completedTables += tierFunctions.length;
        onSyncProgress?.call(completedTables / totalTables, 'Tier $tier');

        // Issue 1 fix: Yield to UI thread between tiers to prevent jank
        await Future.delayed(Duration.zero);
      }

      // Final cache rebuild (redundant but ensures consistency)
      await _engine.rebuildAllCaches();

      // Cleanup old records
      await _cleanupDeletedRecords();

      _engine.lastSuccessfulSync = DateTime.now();
      _lastFullSyncTime = DateTime.now(); // Update cooldown timestamp
      final duration = DateTime.now().difference(startTime);

      AppLogger.sync('✅ Sync completed in ${duration.inSeconds}s');
      onSyncStatusChanged?.call('Synced');
      onSyncComplete?.call();
      notifySyncComplete();

    } on SyncAuthException catch (e) {
      AppLogger.sync('🔒 Auth error during sync: $e');
      onSyncStatusChanged?.call('Session expired');
      // Try to refresh the session once
      try {
        await supabase.auth.refreshSession();
        AppLogger.sync('🔄 Session refreshed after auth error — next periodic sync will retry');
      } catch (refreshError) {
        AppLogger.sync('❌ Session refresh failed: $refreshError');
        stopPeriodicSync();
        onSyncError?.call('Session expired. Please sign in again.');
        onSyncStatusChanged?.call('Not authenticated');
      }
    } catch (e, stackTrace) {
      AppLogger.sync('❌ Sync failed: $e');
      //if (kDebugMode) print(stackTrace);
      onSyncError?.call('Sync failed: $e');
      onSyncStatusChanged?.call('Sync failed');
    } finally {
      _isSyncing = false;
      _syncCompleter?.complete();
      // Apply any context clear that was deferred because a sync was running.
      if (_pendingContextClear) {
        _pendingContextClear = false;
        clearOrganizationContext();
      }
    }
  }

  /// Build tier map for parallel sync
  Map<int, List<Future<void> Function()>> _buildTierMap() {
    return {
      // Tier 1: No dependencies
      1: [
        () => _syncOrganizations(),
        () => _syncRoles(),
      ],
      // Tier 2: Depends on Tier 1
      2: [
        () => _syncUsers(),
        () => _syncItems(),
        () => _syncIngredients(),
      ],
      // Tier 3: Depends on Tier 2
      3: [
        () => _syncRecipeIngredients(),
        () => _syncBranchIngredientStock(),
        () => _syncBranchItemStock(),
      ],
      // Tier 4: Depends on Tier 2/3
      4: [
        () => _syncReplenishmentRequests(),
        () => _syncChangeRequests(),
        () => _syncDailySalesSummary(),
      ],
    };
  }

  // ============================================================================
  // TABLE-SPECIFIC SYNC METHODS
  // Using SyncEngine for generic push/pull with per-table retry
  // ============================================================================

  Future<void> _syncOrganizations() async {
    // Push (commissary only)
    if (organizationsDescriptor.canPushFor(_currentOrganizationType)) {
      await _engine.pushTable(
        descriptor: organizationsDescriptor,
        getUnsyncedRecords: ({int limit = 100, int offset = 0}) =>
            db.organizationsDao.getUnsyncedOrganizations(limit: limit, offset: offset),
        markAsSynced: (ids, {cloudIds}) =>
            db.organizationsDao.markAsSynced(ids, cloudIds: cloudIds),
        toMap: (org) => {
          'id': org.id,
          'name': org.name,
          'type': org.type,
          'parentCommissaryId': org.parentCommissaryId,
          'contactPerson': org.contactPerson,
          'phone': org.phone,
          'email': org.email,
          'address': org.address,
          'isActive': org.isActive,
          'createdAt': org.createdAt,
          'lastUpdated': org.lastUpdated,
        },
        getId: (org) => org.id,
        getCloudId: (org) => org.cloudId,
        shouldSkip: (org) => !org.isActive,
      );
    }

    // Pull
    await _engine.pullTable(
      descriptor: organizationsDescriptor,
      upsertBatchFromCloud: (records) =>
          db.organizationsDao.upsertBatchFromCloud(records),
      getByCloudId: (cloudId) =>
          db.organizationsDao.getOrganizationByCloudId(cloudId),
      getLastUpdated: (org) => org.lastUpdated,
      getOrganizationId: (org) => null, // Organizations don't have org_id
    );

    // Rebuild cache so commissary orgs pulled above are available for FK fix
    await _engine.rebuildAllCaches();

    // Fix franchisees whose parentCommissaryId was null due to cache-miss during pull
    await _fixFranchiseeParentIds();

    // Reload parent commissary for franchisees
    await _reloadParentCommissaryId();
  }

  /// After an organizations pull, some franchisees may have been stored with
  /// parentCommissaryId = null because the commissary org wasn't in the FK
  /// cache yet (same-batch ordering issue).  This method queries Supabase for
  /// the correct parent UUID, resolves it to a local ID using the now-rebuilt
  /// cache, and updates the affected rows.
  Future<void> _fixFranchiseeParentIds() async {
    try {
      final orphaned = (await db.organizationsDao.getAllFranchisees())
          .where((f) => f.parentCommissaryId == null && f.cloudId != null)
          .toList();

      if (orphaned.isEmpty) return;

      AppLogger.sync('   🔧 Fixing ${orphaned.length} franchisee(s) with null parentCommissaryId...');

      final cloudIds = orphaned.map((f) => f.cloudId!).toList();
      final records = await supabase
          .from('organizations')
          .select('cloud_id, parent_commissary_id')
          .inFilter('cloud_id', cloudIds);

      for (final r in records) {
        final parentCloudId = r['parent_commissary_id'] as String?;
        if (parentCloudId == null) continue;

        final parentLocalId = _engine.getLocalId('organizations', parentCloudId);
        if (parentLocalId == null) continue;

        final orgCloudId = r['cloud_id'] as String;
        final org = orphaned.where((f) => f.cloudId == orgCloudId).firstOrNull;
        if (org == null) continue;

        await db.organizationsDao.updateParentCommissaryId(org.id, parentLocalId);
        AppLogger.sync('   ✅ Fixed ${org.name} → parentCommissaryId = $parentLocalId');
      }
    } catch (e) {
      AppLogger.sync('   ⚠️ Failed to fix franchisee parent IDs: $e');
    }
  }

  Future<void> _syncRoles() async {
    if (rolesDescriptor.canPushFor(_currentOrganizationType)) {
      await _engine.pushTable(
        descriptor: rolesDescriptor,
        getUnsyncedRecords: ({int limit = 100, int offset = 0}) =>
            db.rolesDao.getUnsyncedRoles(limit: limit, offset: offset),
        markAsSynced: (ids, {cloudIds}) =>
            db.rolesDao.markAsSynced(ids, cloudIds: cloudIds),
        toMap: (role) => {
          'id': role.id,
          'name': role.name,
          'description': role.description,
          'canViewInventory': role.canViewInventory,
          'canAddInventory': role.canAddInventory,
          'canEditInventory': role.canEditInventory,
          'canDeleteInventory': role.canDeleteInventory,
          'canViewReports': role.canViewReports,
          'canExportData': role.canExportData,
          'canAccessSettings': role.canAccessSettings,
          'canManageEmployees': role.canManageEmployees,
          'canManageRoles': role.canManageRoles,
          'isSystemRole': role.isSystemRole,
          'isActive': role.isActive,
          'createdAt': role.createdAt,
          'lastUpdated': role.lastUpdated,
        },
        getId: (role) => role.id,
        getCloudId: (role) => role.cloudId,
        shouldSkip: (role) => !role.isActive,
      );
    }

    await _engine.pullTable(
      descriptor: rolesDescriptor,
      upsertBatchFromCloud: (records) => db.rolesDao.upsertBatchFromCloud(records),
      getByCloudId: (cloudId) => db.rolesDao.getRoleByCloudId(cloudId),
      getLastUpdated: (role) => role.lastUpdated,
      getOrganizationId: (role) => null,
    );
  }

  Future<void> _syncUsers() async {
    AppLogger.sync('   📊 Starting users sync...');
    
    await _engine.pushTable(
      descriptor: usersDescriptor,
      getUnsyncedRecords: ({int limit = 100, int offset = 0}) =>
          db.usersDao.getUnsyncedUsers(limit: limit, offset: offset),
      markAsSynced: (ids, {cloudIds}) =>
          db.usersDao.markAsSynced(ids, cloudIds: cloudIds),
      toMap: (user) => {
        'id': user.id,
        'email': user.email,
        'username': user.username,
        // password excluded — kept local-only for security
        'phone': user.phone,
        'organizationId': user.organizationId,
        'roleId': user.roleId,
        'fullName': user.fullName,
        'isActive': user.isActive,
        'createdAt': user.createdAt,
        'lastUpdated': user.lastUpdated,
      },
      getId: (user) => user.id,
      getCloudId: (user) => user.cloudId,
      shouldSkip: (user) => false,
    );

    final result = await _engine.pullTable(
      descriptor: usersDescriptor,
      upsertBatchFromCloud: (records) {
        AppLogger.sync('   💾 Upserting ${records.length} users to local DB');
        for (final r in records) {
          AppLogger.sync('      - ${r['email'] ?? r['username']} (cloudId: ${r['cloudId']})');
        }
        return db.usersDao.upsertBatchFromCloud(records);
      },
      getByCloudId: (cloudId) => db.usersDao.getUserByCloudId(cloudId),
      getLastUpdated: (user) => user.lastUpdated,
      getOrganizationId: (user) => user.organizationId,
    );
    
    AppLogger.sync('   ✅ Users sync complete: pulled ${result.pulledCount}');
  }

  Future<void> _syncItems() async {
    await _engine.pushTable(
      descriptor: itemsDescriptor,
      getUnsyncedRecords: ({int limit = 100, int offset = 0}) =>
          db.itemsDao.getUnsyncedItems(limit: limit, offset: offset),
      markAsSynced: (ids, {cloudIds}) =>
          db.itemsDao.markAsSynced(ids, cloudIds: cloudIds),
      toMap: (item) => {
        'id': item.id,
        'name': item.name,
        'organizationId': item.organizationId,
        'categoryId': item.categoryId,
        'masterItemId': item.masterItemId,
        'stock': item.stock,
        'sold': item.sold,
        'spoilage': item.spoilage,
        'price': item.price,
        'costPrice': item.costPrice,
        'unit': item.unit,
        'minimumStock': item.minimumStock,
        'description': item.description,
        'isDeleted': item.isDeleted,
        'createdAt': item.createdAt,
        'lastUpdated': item.lastUpdated,
      },
      getId: (item) => item.id,
      getCloudId: (item) => item.cloudId,
      shouldSkip: (item) => item.isDeleted,
    );

    await _engine.pullTable(
      descriptor: itemsDescriptor,
      upsertBatchFromCloud: (records) => db.itemsDao.upsertBatchFromCloud(records),
      getByCloudId: (cloudId) => db.itemsDao.getItemByCloudId(cloudId),
      getLastUpdated: (item) => item.lastUpdated,
      getOrganizationId: (item) => item.organizationId,
    );
  }

  Future<void> _syncIngredients() async {
    if (ingredientsDescriptor.canPushFor(_currentOrganizationType)) {
      await _engine.pushTable(
        descriptor: ingredientsDescriptor,
        getUnsyncedRecords: ({int limit = 100, int offset = 0}) =>
            db.ingredientsDao.getUnsyncedIngredients(limit: limit, offset: offset),
        markAsSynced: (ids, {cloudIds}) =>
            db.ingredientsDao.markAsSynced(ids, cloudIds: cloudIds),
        toMap: (ing) => {
          'id': ing.id,
          'name': ing.name,
          'commissaryId': ing.commissaryId,
          'stock': ing.stock,
          'unit': ing.unit,
          'criticalLevel': ing.criticalLevel,
          'costPerUnit': ing.costPerUnit,
          'isActive': ing.isActive,
          'needsSync': ing.needsSync,
          'createdAt': ing.createdAt,
          'lastUpdated': ing.lastUpdated,
          'updatedAt': ing.updatedAt,
          'lastSyncedAt': ing.lastSyncedAt,
        },
        getId: (ing) => ing.id,
        getCloudId: (ing) => ing.cloudId,
        shouldSkip: (ing) => !ing.isActive,
      );
    }

    await _engine.pullTable(
      descriptor: ingredientsDescriptor,
      upsertBatchFromCloud: (records) =>
          db.ingredientsDao.upsertBatchFromCloud(records),
      getByCloudId: (cloudId) => db.ingredientsDao.getIngredientByCloudId(cloudId),
      getLastUpdated: (ing) => ing.lastUpdated,
      getOrganizationId: (ing) => ing.commissaryId,
    );
  }

  Future<void> _syncRecipeIngredients() async {
    if (recipeIngredientsDescriptor.canPushFor(_currentOrganizationType)) {
      await _engine.pushTable(
        descriptor: recipeIngredientsDescriptor,
        getUnsyncedRecords: ({int limit = 100, int offset = 0}) =>
            db.recipeIngredientsDao.getUnsyncedRecipeIngredients(
              limit: limit,
              offset: offset,
            ),
        markAsSynced: (ids, {cloudIds}) =>
            db.recipeIngredientsDao.markAsSynced(ids, cloudIds: cloudIds),
        toMap: (ri) => {
          'id': ri.id,
          'itemId': ri.itemId,
          'ingredientId': ri.ingredientId,
          'quantityNeeded': ri.quantityNeeded,
          'unit': ri.unit,
          'notes': ri.notes,
          'isDeleted': ri.isDeleted,
          'createdAt': ri.createdAt,
          'lastUpdated': ri.lastUpdated,
        },
        getId: (ri) => ri.id,
        getCloudId: (ri) => ri.cloudId,
        shouldSkip: (ri) => ri.isDeleted,
      );
    }

    await _engine.pullTable(
      descriptor: recipeIngredientsDescriptor,
      upsertBatchFromCloud: (records) =>
          db.recipeIngredientsDao.upsertBatchFromCloud(records),
      getByCloudId: (cloudId) =>
          db.recipeIngredientsDao.getRecipeIngredientByCloudId(cloudId),
      getLastUpdated: (ri) => ri.lastUpdated,
      getOrganizationId: (ri) => null,
    );
  }

  Future<void> _syncBranchIngredientStock() async {
    AppLogger.sync('   📊 Syncing BranchIngredientStock...');

    await _engine.pushTable(
      descriptor: branchIngredientStockDescriptor,
      getUnsyncedRecords: ({int limit = 100, int offset = 0}) =>
          db.branchIngredientStockDao.getUnsyncedStocks(limit: limit, offset: offset),
      markAsSynced: (ids, {cloudIds}) =>
          db.branchIngredientStockDao.markAsSynced(ids, cloudIds: cloudIds),
      toMap: (stock) => {
        'id': stock.id,
        'organizationId': stock.organizationId,
        'ingredientId': stock.ingredientId,
        'stock': stock.quantity,
        'spoilage': 0,
        'minimumStock': stock.minimumStock,
        'createdAt': stock.createdAt,
        'lastUpdated': stock.lastUpdated,
      },
      getId: (stock) => stock.id,
      getCloudId: (stock) => stock.cloudId,
      shouldSkip: (stock) => false,
    );

    await _engine.pullTable(
      descriptor: branchIngredientStockDescriptor,
      upsertBatchFromCloud: (records) =>
          db.branchIngredientStockDao.upsertBatchFromCloud(records),
      getByCloudId: (cloudId) =>
          db.branchIngredientStockDao.getByCloudId(cloudId),
      getLastUpdated: (stock) => stock.lastUpdated,
      getOrganizationId: (stock) => stock.organizationId,
    );
  }

  Future<void> _syncBranchItemStock() async {
    AppLogger.sync('   📊 Syncing BranchItemStock...');

    await _engine.pushTable(
      descriptor: branchItemStockDescriptor,
      getUnsyncedRecords: ({int limit = 100, int offset = 0}) =>
          db.branchItemStockDao.getUnsyncedStock(limit: limit, offset: offset),
      markAsSynced: (ids, {cloudIds}) =>
          db.branchItemStockDao.markAsSynced(ids, cloudIds: cloudIds),
      toMap: (stock) => {
        'id': stock.id,
        'organizationId': stock.organizationId,
        'itemId': stock.itemId,
        'stock': stock.stock,
        'sold': stock.sold,
        'spoilage': stock.spoilage,
        'price': stock.price,
        'costPrice': stock.costPrice,
        'minimumStock': stock.minimumStock,
        'isDeleted': stock.isDeleted,
        'createdAt': stock.createdAt,
        'lastUpdated': stock.lastUpdated,
      },
      getId: (stock) => stock.id,
      getCloudId: (stock) => stock.cloudId,
      shouldSkip: (stock) => stock.isDeleted,
    );

    await _engine.pullTable(
      descriptor: branchItemStockDescriptor,
      upsertBatchFromCloud: (records) =>
          db.branchItemStockDao.upsertBatchFromCloud(records),
      getByCloudId: (cloudId) =>
          db.branchItemStockDao.getByCloudId(cloudId),
      getLastUpdated: (stock) => stock.lastUpdated,
      getOrganizationId: (stock) => stock.organizationId,
    );
  }

  Future<void> _syncReplenishmentRequests({bool forceFullPull = false}) async {
    AppLogger.sync('   📊 Syncing ReplenishmentRequests...');
    
    // Push local requests to cloud
    await _engine.pushTable(
      descriptor: replenishmentRequestsDescriptor,
      getUnsyncedRecords: ({int limit = 100, int offset = 0}) =>
          db.stockReplenishmentRequestsDao.getUnsyncedRequests(limit: limit, offset: offset),
      markAsSynced: (ids, {cloudIds}) =>
          db.stockReplenishmentRequestsDao.markAsSynced(ids, cloudIds: cloudIds),
      toMap: (req) => {
        'id': req.id,
        'franchiseeId': req.franchiseeId,
        'commissaryId': req.commissaryId,
        'itemId': req.itemId,
        'quantityRequested': req.quantityRequested,
        'status': req.status,
        'requestedBy': req.requestedBy,
        'requestedAt': req.requestedAt,
        'reviewedBy': req.reviewedBy,
        'reviewedAt': req.reviewedAt,
        'deliveryDate': req.deliveryDate,
        'franchiseeNotes': req.franchiseeNotes,
        'commissaryNotes': req.commissaryNotes,
        'isDeleted': req.isDeleted,
        'createdAt': req.createdAt,
        'lastUpdated': req.lastUpdated,
      },
      getId: (req) => req.id,
      getCloudId: (req) => req.cloudId,
      shouldSkip: (req) => req.isDeleted,
    );

    // Pull cloud requests to local
    await _engine.pullTable(
      descriptor: replenishmentRequestsDescriptor,
      upsertBatchFromCloud: (records) =>
          db.stockReplenishmentRequestsDao.upsertBatchFromCloud(records),
      getByCloudId: (cloudId) =>
          db.stockReplenishmentRequestsDao.getRequestByCloudId(cloudId),
      getLastUpdated: (req) => req.lastUpdated,
      getOrganizationId: (req) => req.franchiseeId,
      // When force-pulling, override the incremental filter without touching
      // the engine's shared lastSuccessfulSync timestamp.
      sinceOverride: forceFullPull ? DateTime.utc(1970) : null,
    );
  }

  /// Force a FULL sync of replenishment requests (ignores lastSuccessfulSync)
  /// Used by realtime service when it detects pending updates
  Future<void> forceFullSyncReplenishmentRequests() async {
    await _runGuardedSync('replenishment_requests_force',
        () => _syncReplenishmentRequests(forceFullPull: true));
  }

  Future<void> _syncChangeRequests() async {
    AppLogger.sync('   📊 Syncing ChangeRequests...');
    
    // Push local change requests to cloud
    await _engine.pushTable(
      descriptor: changeRequestsDescriptor,
      getUnsyncedRecords: ({int limit = 100, int offset = 0}) =>
          db.stockChangeRequestsDao.getUnsyncedChangeRequests(limit: limit, offset: offset),
      markAsSynced: (ids, {cloudIds}) =>
          db.stockChangeRequestsDao.markAsSynced(ids, cloudIds: cloudIds),
      toMap: (req) => {
        'id': req.id,
        'franchiseeId': req.franchiseeId,
        'itemId': req.itemId,
        'changeType': req.changeType,
        'quantity': req.quantity,
        'originalStock': req.originalStock,

        'status': req.status,
        'requestedBy': req.requestedBy,
        'requestedAt': req.requestedAt,
        'reviewedBy': req.reviewedBy,
        'reviewedAt': req.reviewedAt,
        'reason': req.reason,
        'reviewerNotes': req.reviewNotes,
        'isDeleted': req.isDeleted,
        'createdAt': req.createdAt,
        'lastUpdated': req.lastUpdated,
      },
      getId: (req) => req.id,
      getCloudId: (req) => req.cloudId,
      shouldSkip: (req) => req.isDeleted,
    );

    // Pull cloud change requests to local
    await _engine.pullTable(
      descriptor: changeRequestsDescriptor,
      upsertBatchFromCloud: (records) =>
          db.stockChangeRequestsDao.upsertBatchFromCloud(records),
      getByCloudId: (cloudId) =>
          db.stockChangeRequestsDao.getChangeRequestByCloudId(cloudId),
      getLastUpdated: (req) => req.lastUpdated,
      getOrganizationId: (req) => req.franchiseeId,
    );
  }

  Future<void> _syncDailySalesSummary() async {
    AppLogger.sync('   📊 Syncing DailySalesSummary...');
    
    // Push
    await _engine.pushTable(
      descriptor: dailySalesSummaryDescriptor,
      getUnsyncedRecords: ({int limit = 100, int offset = 0}) =>
          db.dailySalesSummaryDao.getUnsyncedSummaries(limit: limit, offset: offset),
      markAsSynced: (ids, {cloudIds}) =>
          db.dailySalesSummaryDao.markAsSynced(ids, cloudIds: cloudIds),
      toMap: (summary) => {
        'id': summary.id,
        'organizationId': summary.organizationId,
        'itemId': summary.itemId,
        'summaryDate': summary.summaryDate,
        'quantitySold': summary.quantitySold,
        'quantitySpoiled': summary.quantitySpoiled,
        'revenue': summary.revenue,
        'costOfGoodsSold': summary.costOfGoodsSold,
        'grossProfit': summary.grossProfit,
        'transactionCount': summary.transactionCount,
        'openingStock': summary.openingStock,
        'closingStock': summary.closingStock,
        'createdAt': summary.createdAt,
        'lastUpdated': summary.lastUpdated,
      },
      getId: (summary) => summary.id,
      getCloudId: (summary) => summary.cloudId,
      shouldSkip: (summary) => false,
    );

    // Pull
    await _engine.pullTable(
      descriptor: dailySalesSummaryDescriptor,
      upsertBatchFromCloud: (records) =>
          db.dailySalesSummaryDao.upsertBatchFromCloud(records),
      getByCloudId: (cloudId) =>
          db.dailySalesSummaryDao.getByCloudId(cloudId),
      getLastUpdated: (summary) => summary.lastUpdated,
      getOrganizationId: (summary) => summary.organizationId,
      // Use business key for conflict detection
      getByBusinessKey: (localData) async {
        final organizationId = localData['organizationId'] as int?;
        final itemId = localData['itemId'] as int?;
        final summaryDate = localData['summaryDate'] as DateTime?;
        
        if (organizationId != null && itemId != null && summaryDate != null) {
          return await db.dailySalesSummaryDao.getByBusinessKey(
            organizationId: organizationId,
            itemId: itemId,
            summaryDate: summaryDate,
          );
        }
        return null;
      },
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  Future<void> _reloadParentCommissaryId() async {
    if (_currentOrganizationType != 'franchisee') return;

    try {
      if (_parentCommissaryId != null) {
        final existing = await db.organizationsDao.getOrganizationById(_parentCommissaryId!);
        if (existing != null) return;
      }

      if (_currentOrganizationId != null) {
        final currentOrg = await db.organizationsDao.getOrganizationById(_currentOrganizationId!);
        if (currentOrg?.parentCommissaryId != null) {
          _parentCommissaryId = currentOrg!.parentCommissaryId;
          _parentCommissaryCloudId = _engine.getCloudId('organizations', _parentCommissaryId);
          return;
        }
      }

      // No fallback — log the failure so it surfaces in diagnostics.
      AppLogger.sync('   ⚠️ Franchisee parent commissary could not be resolved. '
          'Ensure the organization has a valid parent_commissary_id.');
    } catch (e) {
      AppLogger.sync('   ⚠️ Failed to reload parent commissary: $e');
    }
  }

  Future<void> _cleanupDeletedRecords() async {
    try {
      AppLogger.sync('🧹 Cleaning up deleted records...');

      final results = await Future.wait([
        db.itemsDao.cleanupDeletedItems(),
        db.usersDao.cleanupDeletedUsers(),
        db.rolesDao.cleanupDeletedRoles(),
        db.categoriesDao.cleanupDeletedCategories(),
        db.syncConflictsDao.cleanupOldConflicts(days: 30),
      ]);

      final totalCleaned = results.fold(0, (sum, count) => sum + count);
      if (totalCleaned > 0) {
        AppLogger.sync('✅ Cleaned up $totalCleaned records');
      }
    } catch (e) {
      AppLogger.sync('⚠️ Cleanup failed: $e');
    }
  }

  void _logConflictNotification(String tableName, String message) {
    AppLogger.sync('⚠️ Conflict in $tableName: $message');
  }

  Future<void> _saveConflictToDb(SyncConflictRecord conflict) async {
    try {
      await db.syncConflictsDao.logConflict(
        sourceTable: conflict.tableName,
        cloudId: conflict.cloudId,
        localData: const JsonEncoder().convert(conflict.localData),
        cloudData: const JsonEncoder().convert(conflict.cloudData),
        conflictType: conflict.conflictType.name,
        organizationId: conflict.organizationId,
      );
    } catch (e) {
      AppLogger.sync('⚠️ Failed to save conflict: $e');
    }
  }

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  Future<void> syncImmediate() async {
    AppLogger.sync('⚡ Immediate sync requested');
    await syncAll();
  }

  /// Directly update a single stock_replenishment_request row in Supabase
  /// without touching the sync engine, bypassing all locks and cooldowns.
  ///
  /// Call this immediately after the local DB approve/reject write so the
  /// change reaches the cloud in real-time just like an incoming WebSocket
  /// event triggers an immediate pull.
  Future<void> directUpdateRequestStatus({
    required String requestCloudId,
    required String status,           // 'approved' | 'rejected'
    required String reviewerCloudId,  // Supabase auth UUID of the commissary user
    String? notes,
    required DateTime reviewedAt,
  }) async {
    if (!_isOnline) {
      AppLogger.sync('⚠️ directUpdateRequestStatus: offline, skipping direct push');
      return;
    }
    AppLogger.sync('🚀 directUpdateRequestStatus: $requestCloudId → $status');
    await supabase.from('stock_replenishment_requests').update({
      'status': status,
      'reviewed_by': reviewerCloudId,
      'reviewed_at': reviewedAt.toUtc().toIso8601String(),
      'commissary_notes': notes,
      'last_updated': DateTime.now().toUtc().toIso8601String(),
    }).eq('cloud_id', requestCloudId);
    AppLogger.sync('✅ directUpdateRequestStatus: done ($requestCloudId → $status)');
  }

  /// Push the result of a commissary approve/reject action to Supabase
  /// immediately, bypassing the smart-sync cooldown.
  ///
  /// Only syncs the three tables that change during an approval/rejection:
  ///   • stock_replenishment_requests  (status update)
  ///   • branch_item_stock             (stock added to franchisee)
  ///   • items                         (commissary stock deducted)
  ///
  /// Waits for any in-flight full sync to complete first so the DB engine
  /// is not used concurrently. After pushing, listeners are notified via
  /// [notifySyncComplete].
  Future<void> pushReplenishmentOutcomeNow() async {
    if (!_isOnline || !canSync) {
      AppLogger.sync('⚠️ pushReplenishmentOutcomeNow: offline or not authenticated, skipping');
      return;
    }

    // If a full sync is already in flight, wait for it to finish so the DB
    // engine is not used concurrently.  We must NOT return early — the local
    // approve/reject write happened AFTER the in-flight sync's push phase
    // already ran, so this outcome has NOT been pushed yet.
    if (_syncCompleter != null && !_syncCompleter!.isCompleted) {
      AppLogger.sync('⏳ pushReplenishmentOutcomeNow: awaiting in-flight sync before pushing outcome...');
      await _syncCompleter!.future.catchError((_) {});
      AppLogger.sync('⏳ pushReplenishmentOutcomeNow: in-flight sync done, now pushing outcome...');
    }

    if (_isSyncing) {
      AppLogger.sync('⏳ pushReplenishmentOutcomeNow: _isSyncing=true, waiting...');
      int waited = 0;
      while (_isSyncing && waited < 10000) {
        await Future.delayed(const Duration(milliseconds: 100));
        waited += 100;
      }
    }

    AppLogger.sync('🚀 pushReplenishmentOutcomeNow: pushing approval outcome to cloud...');
    _isSyncing = true;
    _syncCompleter = Completer<void>();
    try {
      await _engine.rebuildAllCaches();
      // Push + pull in dependency order
      await _syncItems();                    // commissary stock deduction
      await _syncBranchItemStock();          // franchisee stock credit
      await _syncReplenishmentRequests();    // status = approved/rejected
      _engine.lastSuccessfulSync = DateTime.now();
      AppLogger.sync('✅ pushReplenishmentOutcomeNow: done');
      notifySyncComplete();
    } catch (e) {
      AppLogger.error('pushReplenishmentOutcomeNow failed: $e');
      onSyncError?.call('Push failed: $e');
    } finally {
      _isSyncing = false;
      _syncCompleter?.complete();
      if (_pendingContextClear) {
        _pendingContextClear = false;
        clearOrganizationContext();
      }
    }
  }

  /// Force a **full** pull from Supabase (ignores lastSuccessfulSync)
  /// and push any locally pending changes.
  ///
  /// Use this for user-initiated "Sync Now" button presses where the
  /// expectation is that ALL cloud data is downloaded, not just incremental
  /// changes since the last automatic sync.
  Future<void> forceSyncAll() async {
    AppLogger.sync('🔄 Force full sync requested (resetting timestamp)');
    // Re-check connectivity in case the cached flag is stale (common on Windows)
    _isOnline = await _checkConnectivity();
    // Resetting lastSuccessfulSync makes the engine use '1970-01-01' as the
    // lower-bound for every pull query, i.e. it fetches everything.
    _engine.resetLastSuccessfulSync();
    await syncAll();
  }

  Future<void> syncItemsOnly() async {
    await _runGuardedSync('products', () async {
      await _syncItems();
    });
  }

  // ============================================================================
  // INDIVIDUAL TABLE SYNC METHODS (for backward compatibility)
  // These allow screens/helpers to trigger single-table syncs
  // ============================================================================

  /// Acquire the same sync lock used by [syncAll] and run [body].
  /// If a sync is already in flight, the call is dropped.
  Future<void> _runGuardedSync(String label, Future<void> Function() body) async {
    if (_syncCompleter != null && !_syncCompleter!.isCompleted) return;
    if (_isSyncing) return;

    _isSyncing = true;
    _syncCompleter = Completer<void>();
    try {
      await body();
    } catch (e) {
      onSyncError?.call('$label sync failed: $e');
    } finally {
      _isSyncing = false;
      _syncCompleter?.complete();
      if (_pendingContextClear) {
        _pendingContextClear = false;
        clearOrganizationContext();
      }
    }
  }

  /// Sync organizations table only
  Future<void> syncOrganizations() async {
    await _runGuardedSync('organizations', _syncOrganizations);
  }

  /// Sync roles table only
  Future<void> syncRoles() async {
    await _runGuardedSync('roles', _syncRoles);
  }

  /// Sync users table only
  Future<void> syncUsers() async {
    await _runGuardedSync('users', _syncUsers);
  }

  /// Sync items table only
  Future<void> syncItems() async {
    await _runGuardedSync('items', _syncItems);
  }

  /// Sync ingredients table only
  Future<void> syncIngredients() async {
    await _runGuardedSync('ingredients', _syncIngredients);
  }

  /// Sync recipe ingredients table only
  Future<void> syncRecipeIngredients() async {
    await _runGuardedSync('recipe_ingredients', _syncRecipeIngredients);
  }

  /// Sync stock replenishment requests table only
  Future<void> syncStockReplenishmentRequests() async {
    await _runGuardedSync('replenishment_requests', () => _syncReplenishmentRequests());
  }

  /// Sync stock change requests table only
  Future<void> syncStockChangeRequests() async {
    await _runGuardedSync('change_requests', _syncChangeRequests);
  }

  /// Sync branch item stock table only
  Future<void> syncBranchItemStock() async {
    await _runGuardedSync('branch_item_stock', _syncBranchItemStock);
  }

  /// Sync branch ingredient stock table only
  Future<void> syncBranchIngredientStock() async {
    await _runGuardedSync('branch_ingredient_stock', _syncBranchIngredientStock);
  }

  /// Sync daily sales summary table only
  Future<void> syncDailySalesSummary() async {
    await _runGuardedSync('daily_sales_summary', _syncDailySalesSummary);
  }

  Future<Map<String, dynamic>> getSyncStatus() async {
    // Issue 11 fix: Cache result for 10 seconds to avoid 9 COUNT queries every 30s
    if (_cachedSyncStatus != null && _cacheTimestamp != null) {
      final age = DateTime.now().difference(_cacheTimestamp!);
      if (age < _cacheTTL) {
        // Return cached result, but update live fields
        return {
          ..._cachedSyncStatus!,
          'is_syncing': _isSyncing,
          'is_online': _isOnline,
        };
      }
    }

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
        db.syncConflictsDao.getUnresolvedConflictCount(organizationId: _currentOrganizationId),
        db.branchItemStockDao.getUnsyncedStock().then((l) => l.length),
        db.dailySalesSummaryDao.getUnsyncedSummaries().then((l) => l.length),
      ]);

      final result = {
        'unsynced_items': counts[0],
        'unsynced_users': counts[1],
        'unsynced_roles': counts[2],
        'unsynced_organizations': counts[3],
        'unsynced_ingredients': counts[4],
        'unsynced_recipes': counts[5],
        'unsynced_replenishment_requests': counts[6],
        'unsynced_change_requests': counts[7],
        'unresolved_conflicts': counts[8],
        'unsynced_branch_item_stock': counts[9],
        'unsynced_daily_sales': counts[10],
        'total_unsynced': counts.sublist(0, 8).fold(0, (sum, c) => sum + c) + counts[9] + counts[10],
        'is_syncing': _isSyncing,
        'is_online': _isOnline,
        'last_sync': _engine.lastSuccessfulSync?.toIso8601String() ?? 'Never',
        'cache_size': _engine.getCacheStats().values.fold(0, (sum, c) => sum + c),
        'organization_type': _currentOrganizationType,
        'organization_id': _currentOrganizationId,
      };

      // Cache the result
      _cachedSyncStatus = result;
      _cacheTimestamp = DateTime.now();

      return result;
    } catch (e) {
      return {
        'error': e.toString(),
        'is_syncing': _isSyncing,
        'is_online': _isOnline,
      };
    }
  }

  void setOrganizationContext({
    required int organizationId,
    required String organizationType,
    int? parentCommissaryId,
  }) {
    _currentOrganizationId = organizationId;
    _currentOrganizationType = organizationType;
    _parentCommissaryId = parentCommissaryId;

    _engine.setOrganizationContext(
      organizationType: organizationType,
      organizationId: organizationId,
    );

    _loadOrganizationCloudIds();
    AppLogger.sync('📍 Sync context updated: $organizationType org #$organizationId');
  }

  /// Clear organization context on logout to prevent stale sync operations
  void clearOrganizationContext() {
    // If a sync is currently running, defer the clear to avoid nulling
    // context fields (_currentOrganizationType etc.) mid-flight.
    if (_isSyncing) {
      _pendingContextClear = true;
      AppLogger.sync('⏳ Sync in progress – deferring context clear');
      return;
    }
    _pendingContextClear = false;
    _currentOrganizationId = null;
    _currentOrganizationCloudId = null;
    _currentOrganizationType = null;
    _parentCommissaryId = null;
    _parentCommissaryCloudId = null;
    _engine.clearOrganizationContext();
    AppLogger.sync('🧹 Sync context cleared');
  }

  void dispose() {
    _syncTimer?.cancel();
    _syncDebounceTimer?.cancel();
    _connectivitySubscription?.cancel();
    _engine.clearCaches();
    AppLogger.sync('🛑 Sync service disposed');
  }
}
