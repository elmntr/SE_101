// lib/services/supabase_sync_service.dart
import 'dart:async';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import 'package:flutter/foundation.dart';

/// ✅ Optimized Supabase Sync Service with UUID Caching
/// 
/// Key Features:
/// - UUID cache for faster foreign key resolution
/// - Local integer IDs ↔ Cloud UUIDs mapping
/// - Better error handling with exponential backoff
/// - Optimized batch operations
/// - Connection state management
/// - Progress tracking
/// - Automatic cleanup of deleted records
class SupabaseSyncService {
  final AppDatabase db;
  final SupabaseClient supabase;
  Timer? _syncTimer;
  bool _isSyncing = false;
  bool _isOnline = true;
  DateTime? _lastSuccessfulSync;
  
  // ✅ UUID cache for faster lookups
  final Map<String, Map<int, String>> _cloudIdCache = {
    'organizations': {},
    'roles': {},
    'users': {},
    'items': {},
    'ingredients': {},
  };
  
  // ✅ Configuration
  static const Duration syncInterval = Duration(minutes: 10);
  static const int batchSize = 100;
  static const int maxRetries = 3;
  static const Duration initialRetryDelay = Duration(seconds: 2);
  static const Duration connectionTimeout = Duration(seconds: 30);
  
  // Callbacks for UI updates
  Function(bool isOnline)? onConnectivityChanged;
  Function(String status)? onSyncStatusChanged;
  Function(String error)? onSyncError;
  Function(double progress)? onSyncProgress;
  
  final Uuid _uuid = const Uuid();
  
  SupabaseSyncService({
    required this.db,
    required this.supabase,
    this.onConnectivityChanged,
    this.onSyncStatusChanged,
    this.onSyncError,
    this.onSyncProgress,
  });

  /// ✅ Initialize sync service
  Future<void> initialize() async {
    print('🚀 Initializing sync service...');
    
    try {
      // Check initial connectivity
      _isOnline = await _checkConnectivity();
      onConnectivityChanged?.call(_isOnline);
      
      // Build UUID cache from local database
      await _buildCloudIdCache();
      
      // Start periodic sync
      startPeriodicSync();
      
      // Listen to connectivity changes
      Connectivity().onConnectivityChanged.listen((result) {
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
      });
      
      // Initial sync if online
      if (_isOnline) {
        await syncAll();
      }
      
      print('✅ Sync service initialized');
    } catch (e) {
      print('❌ Failed to initialize sync service: $e');
      onSyncError?.call('Initialization failed: $e');
    }
  }

  /// ✅ Build UUID cache from local database
  Future<void> _buildCloudIdCache() async {
    print('🔧 Building cloud ID cache...');
    
    try {
      // Cache organizations
      final orgs = await db.organizationsDao.getAllOrganizations();
      for (final org in orgs) {
        if (org.cloudId != null) {
          _cloudIdCache['organizations']![org.id] = org.cloudId!;
        }
      }
      
      // Cache roles
      final roles = await db.rolesDao.getAllRoles();
      for (final role in roles) {
        if (role.cloudId != null) {
          _cloudIdCache['roles']![role.id] = role.cloudId!;
        }
      }
      
      // Cache users
      final users = await db.usersDao.getAllUsers();
      for (final user in users) {
        if (user.cloudId != null) {
          _cloudIdCache['users']![user.id] = user.cloudId!;
        }
      }
      
      // Cache items
      final items = await db.itemsDao.getAllItems();
      for (final item in items) {
        if (item.cloudId != null) {
          _cloudIdCache['items']![item.id] = item.cloudId!;
        }
      }
      
      // Cache ingredients
      final ingredients = await db.ingredientsDao.getAllIngredients();
      for (final ingredient in ingredients) {
        if (ingredient.cloudId != null) {
          _cloudIdCache['ingredients']![ingredient.id] = ingredient.cloudId!;
        }
      }
      
      print('✅ Cache built: ${_cloudIdCache.values.fold(0, (sum, map) => sum + map.length)} entries');
    } catch (e) {
      print('⚠️ Error building cache: $e');
    }
  }

  /// ✅ Get cloud UUID for local ID (with cache)
  String? _getCloudId(String table, int? localId) {
    if (localId == null) return null;
    return _cloudIdCache[table]?[localId];
  }

  /// ✅ Update cache with new UUID
  void _updateCache(String table, int localId, String cloudId) {
    _cloudIdCache[table]![localId] = cloudId;
  }

  /// ✅ Find local ID from cloud UUID (reverse lookup)
  int? _findLocalIdByCloudId(String table, dynamic cloudId) {
    if (cloudId == null) return null;
    if (cloudId is int) return cloudId; // Already a local ID
    
    final cloudIdStr = cloudId.toString();
    final cache = _cloudIdCache[table];
    if (cache == null) return null;
    
    // Search cache for matching UUID
    for (final entry in cache.entries) {
      if (entry.value == cloudIdStr) {
        return entry.key;
      }
    }
    
    return null; // UUID not found in cache
  }

  /// ✅ Check connectivity with timeout
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
    print('⏰ Periodic sync started (every ${syncInterval.inMinutes} minutes)');
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
    print('⏸️ Periodic sync stopped');
  }

  /// ✅ Main sync method with dependency-aware ordering and retry logic
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

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        _isSyncing = true;
        onSyncStatusChanged?.call('Syncing...');
        
        print('🔄 Starting sync (attempt $attempt/$maxRetries)...');
        final startTime = DateTime.now();
        
        // ✅ Sync in dependency order to avoid foreign key conflicts
        await _syncWithProgress([
          () => _syncTable('Organizations', syncOrganizations),
          () => _syncTable('Roles', syncRoles),
          () => _syncTable('Users', syncUsers),
          () => _syncTable('Items', syncItems),
          () => _syncTable('Ingredients', syncIngredients),
          () => _syncTable('RecipeIngredients', syncRecipeIngredients),
          () => _syncTable('StockReplenishmentRequests', syncStockReplenishmentRequests),
          () => _syncTable('StockChangeRequests', syncStockChangeRequests),
        ]);
        
        _lastSuccessfulSync = DateTime.now();
        final duration = _lastSuccessfulSync!.difference(startTime);
        
        print('✅ Sync completed successfully in ${duration.inSeconds}s');
        onSyncStatusChanged?.call('Synced');
        
        // ✅ Rebuild cache after successful sync
        await _buildCloudIdCache();
        
        // ✅ Cleanup old deleted records after successful sync
        await _cleanupDeletedRecords();
        
        return;
        
      } catch (e, stackTrace) {
        print('❌ Sync attempt $attempt failed: $e');
        if (kDebugMode) {
          print('Stack trace: $stackTrace');
        }
        
        if (attempt == maxRetries) {
          onSyncError?.call('Sync failed after $maxRetries attempts: $e');
          onSyncStatusChanged?.call('Sync failed');
        } else {
          final delay = initialRetryDelay * pow(2, attempt - 1);
          print('⏳ Retrying in ${delay.inSeconds} seconds...');
          await Future.delayed(delay);
        }
      } finally {
        _isSyncing = false;
      }
    }
  }

  /// ✅ Sync individual table with error isolation
  Future<void> _syncTable(String tableName, Future<void> Function() syncFunction) async {
    try {
      print('📊 Syncing $tableName...');
      await syncFunction();
      print('   ✅ $tableName sync complete');
    } catch (e) {
      print('   ❌ $tableName sync failed: $e');
      // Don't rethrow - continue with other tables
      onSyncError?.call('$tableName sync failed: $e');
    }
  }

  Future<void> _syncWithProgress(List<Future<void> Function()> steps) async {
    for (int i = 0; i < steps.length; i++) {
      await steps[i]();
      final progress = (i + 1) / steps.length;
      onSyncProgress?.call(progress);
    }
  }

  // ==========================================================================
  // ORGANIZATIONS SYNC (with UUID resolution)
  // ==========================================================================

  Future<void> syncOrganizations() async {
    await _pushOrganizations();
    await _pullOrganizations();
  }

  Future<void> _pushOrganizations() async {
    int totalPushed = 0;
    int totalDeleted = 0;
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
      final deleteIds = <String>[];

      for (final org in unsynced) {
        // Handle deletions
        if (!org.isActive && org.cloudId != null) {
          deleteIds.add(org.cloudId!);
          syncedIds.add(org.id);
          continue;
        }

        // Handle upserts
        if (org.isActive) {
          final cloudId = org.cloudId ?? _uuid.v4();
          cloudIdMap[org.id] = cloudId;
          _updateCache('organizations', org.id, cloudId);

          // ✅ Resolve parent commissary UUID
          final parentCloudId = _getCloudId('organizations', org.parentCommissaryId);

          batchData.add({
            'cloud_id': cloudId,
            'local_id': org.id,
            'name': org.name,
            'type': org.type,
            'parent_commissary_id': parentCloudId, // ✅ UUID instead of integer
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
      }

      // ✅ Batch delete
      if (deleteIds.isNotEmpty) {
        await supabase.from('organizations').delete().inFilter('cloud_id', deleteIds);
        totalDeleted += deleteIds.length;
      }

      // ✅ Batch upsert
      if (batchData.isNotEmpty) {
        await supabase.from('organizations').upsert(batchData, onConflict: 'cloud_id');
        totalPushed += batchData.length;
      }

      // Mark as synced and update cache
      if (syncedIds.isNotEmpty) {
        await db.organizationsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
        
        // ✅ Update cache after marking as synced
        for (final entry in cloudIdMap.entries) {
          _updateCache('organizations', entry.key, entry.value);
        }
      }

      offset += batchSize;
    }

    if (totalPushed > 0) print('   ↑ Pushed $totalPushed organizations');
    if (totalDeleted > 0) print('   🗑️ Deleted $totalDeleted organizations');
  }

  Future<void> _pullOrganizations() async {
    try {
      final lastSync = _lastSuccessfulSync?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';
      
      final cloudOrgs = await supabase
          .from('organizations')
          .select()
          .gte('last_updated', lastSync)
          .order('last_updated', ascending: false)
          .limit(1000);

      if (cloudOrgs.isNotEmpty) {
        // ✅ Resolve UUIDs back to local IDs
        final resolvedOrgs = <Map<String, dynamic>>[];
        
        for (final cloudOrg in cloudOrgs) {
          // Resolve parent commissary UUID to local ID
          int? parentId;
          if (cloudOrg['parent_commissary_id'] != null) {
            parentId = _findLocalIdByCloudId('organizations', cloudOrg['parent_commissary_id']);
          }
          
          resolvedOrgs.add({
            ...cloudOrg,
            'parent_commissary_id': parentId,
          });
        }
        
        await db.organizationsDao.upsertBatchFromCloud(resolvedOrgs);
        print('   ↓ Pulled ${resolvedOrgs.length} organizations');
      }
    } catch (e) {
      print('   ⚠️ Failed to pull organizations: $e');
    }
  }

  // ==========================================================================
  // ROLES SYNC
  // ==========================================================================

  Future<void> syncRoles() async {
    await _pushRoles();
    await _pullRoles();
  }

  Future<void> _pushRoles() async {
    int totalPushed = 0;
    int totalDeleted = 0;
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
      final deleteIds = <String>[];

      for (final role in unsynced) {
        // Don't delete system roles from cloud
        if (!role.isActive && role.cloudId != null && !role.isSystemRole) {
          deleteIds.add(role.cloudId!);
          syncedIds.add(role.id);
          continue;
        }

        if (role.isActive) {
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
      }

      if (deleteIds.isNotEmpty) {
        await supabase.from('roles').delete().inFilter('cloud_id', deleteIds);
        totalDeleted += deleteIds.length;
      }

      if (batchData.isNotEmpty) {
        await supabase.from('roles').upsert(batchData, onConflict: 'cloud_id');
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.rolesDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) print('   ↑ Pushed $totalPushed roles');
    if (totalDeleted > 0) print('   🗑️ Deleted $totalDeleted roles');
  }

  Future<void> _pullRoles() async {
    try {
      final lastSync = _lastSuccessfulSync?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';
      
      final cloudRoles = await supabase
          .from('roles')
          .select()
          .gte('last_updated', lastSync)
          .order('last_updated', ascending: false)
          .limit(1000);

      if (cloudRoles.isNotEmpty) {
        await db.rolesDao.upsertBatchFromCloud(cloudRoles);
        print('   ↓ Pulled ${cloudRoles.length} roles');
      }
    } catch (e) {
      print('   ⚠️ Failed to pull roles: $e');
    }
  }

  // ==========================================================================
  // USERS SYNC (with UUID foreign keys)
  // ==========================================================================

  Future<void> syncUsers() async {
    await _pushUsers();
    await _pullUsers();
  }

  Future<void> _pushUsers() async {
    int totalPushed = 0;
    int totalDeleted = 0;
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
      final deleteIds = <String>[];

      for (final user in unsynced) {
        if (!user.isActive && user.cloudId != null) {
          deleteIds.add(user.cloudId!);
          syncedIds.add(user.id);
          continue;
        }

        if (user.isActive) {
          final cloudId = user.cloudId ?? _uuid.v4();
          cloudIdMap[user.id] = cloudId;
          _updateCache('users', user.id, cloudId);

          // ✅ Resolve foreign key UUIDs
          final orgCloudId = _getCloudId('organizations', user.organizationId);
          final roleCloudId = _getCloudId('roles', user.roleId);

          // Skip if foreign keys not yet synced
          if (orgCloudId == null || roleCloudId == null) {
            print('   ⚠️ Skipping user ${user.id}: missing foreign key UUIDs');
            continue;
          }

          batchData.add({
            'cloud_id': cloudId,
            'local_id': user.id,
            'email': user.email,
            'username': user.username,
            'password': user.password, // Already hashed
            'phone': user.phone,
            'organization_id': orgCloudId, // ✅ UUID
            'role_id': roleCloudId, // ✅ UUID
            'full_name': user.fullName,
            'is_active': user.isActive,
            'created_at': user.createdAt.toIso8601String(),
            'last_updated': user.lastUpdated.toIso8601String(),
          });
          syncedIds.add(user.id);
        }
      }

      if (deleteIds.isNotEmpty) {
        await supabase.from('users').delete().inFilter('cloud_id', deleteIds);
        totalDeleted += deleteIds.length;
      }

      if (batchData.isNotEmpty) {
        await supabase.from('users').upsert(batchData, onConflict: 'cloud_id');
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.usersDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) print('   ↑ Pushed $totalPushed users');
    if (totalDeleted > 0) print('   🗑️ Deleted $totalDeleted users');
  }

  Future<void> _pullUsers() async {
    try {
      final lastSync = _lastSuccessfulSync?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';
      
      final cloudUsers = await supabase
          .from('users')
          .select()
          .gte('last_updated', lastSync)
          .order('last_updated', ascending: false)
          .limit(1000);

      if (cloudUsers.isNotEmpty) {
        // ✅ Resolve UUIDs back to local IDs
        final resolvedUsers = <Map<String, dynamic>>[];
        
        for (final cloudUser in cloudUsers) {
          // Find local IDs from cloud UUIDs
          final orgId = _findLocalIdByCloudId('organizations', cloudUser['organization_id']);
          final roleId = _findLocalIdByCloudId('roles', cloudUser['role_id']);
          
          if (orgId == null || roleId == null) {
            print('   ⚠️ Skipping cloud user ${cloudUser['cloud_id']}: missing local foreign keys');
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
          print('   ↓ Pulled ${resolvedUsers.length} users');
        }
      }
    } catch (e) {
      print('   ⚠️ Failed to pull users: $e');
    }
  }

  // ==========================================================================
  // ITEMS SYNC (with UUID foreign keys)
  // ==========================================================================

  Future<void> syncItems() async {
    await _pushItems();
    await _pullItems();
  }

  Future<void> _pushItems() async {
    int totalPushed = 0;
    int totalDeleted = 0;
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
      final deleteIds = <String>[];

      for (final item in unsynced) {
        if (item.isDeleted && item.cloudId != null) {
          deleteIds.add(item.cloudId!);
          syncedIds.add(item.id);
          continue;
        }

        if (!item.isDeleted) {
          final cloudId = item.cloudId ?? _uuid.v4();
          cloudIdMap[item.id] = cloudId;
          _updateCache('items', item.id, cloudId);

          // ✅ Resolve foreign key UUIDs
          final orgCloudId = _getCloudId('organizations', item.organizationId);
          final masterItemCloudId = _getCloudId('items', item.masterItemId);

          if (orgCloudId == null) {
            print('   ⚠️ Skipping item ${item.id}: missing organization UUID');
            continue;
          }

          batchData.add({
            'cloud_id': cloudId,
            'local_id': item.id,
            'name': item.name,
            'organization_id': orgCloudId, // ✅ UUID
            'master_item_id': masterItemCloudId, // ✅ UUID or null
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
      }

      if (deleteIds.isNotEmpty) {
        await supabase.from('items').delete().inFilter('cloud_id', deleteIds);
        totalDeleted += deleteIds.length;
      }

      if (batchData.isNotEmpty) {
        await supabase.from('items').upsert(batchData, onConflict: 'cloud_id');
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.itemsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) print('   ↑ Pushed $totalPushed items');
    if (totalDeleted > 0) print('   🗑️ Deleted $totalDeleted items');
  }

  Future<void> _pullItems() async {
    try {
      final lastSync = _lastSuccessfulSync?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';
      
      final cloudItems = await supabase
          .from('items')
          .select()
          .gte('last_updated', lastSync)
          .order('last_updated', ascending: false)
          .limit(1000);

      if (cloudItems.isNotEmpty) {
        // ✅ Resolve UUIDs back to local IDs
        final resolvedItems = <Map<String, dynamic>>[];
        
        for (final cloudItem in cloudItems) {
          final orgId = _findLocalIdByCloudId('organizations', cloudItem['organization_id']);
          final masterItemId = _findLocalIdByCloudId('items', cloudItem['master_item_id']);
          
          if (orgId == null) {
            print('   ⚠️ Skipping cloud item ${cloudItem['cloud_id']}: missing local organization');
            continue;
          }
          
          resolvedItems.add({
            ...cloudItem,
            'organization_id': orgId,
            'master_item_id': masterItemId,
          });
        }
        
        if (resolvedItems.isNotEmpty) {
          // Process in batches to avoid memory issues
          for (int i = 0; i < resolvedItems.length; i += batchSize) {
            final end = (i + batchSize < resolvedItems.length) ? i + batchSize : resolvedItems.length;
            final batch = resolvedItems.sublist(i, end);
            await db.itemsDao.upsertBatchFromCloud(batch);
          }
          print('   ↓ Pulled ${resolvedItems.length} items');
        }
      }
    } catch (e) {
      print('   ⚠️ Failed to pull items: $e');
    }
  }

  // ==========================================================================
  // INGREDIENTS SYNC (with UUID foreign keys)
  // ==========================================================================

  Future<void> syncIngredients() async {
    await _pushIngredients();
    await _pullIngredients();
  }

  Future<void> _pushIngredients() async {
    int totalPushed = 0;
    int totalDeleted = 0;
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
      final deleteIds = <String>[];

      for (final ingredient in unsynced) {
        if (ingredient.isDeleted && ingredient.cloudId != null) {
          deleteIds.add(ingredient.cloudId!);
          syncedIds.add(ingredient.id);
          continue;
        }

        if (!ingredient.isDeleted) {
          final cloudId = ingredient.cloudId ?? _uuid.v4();
          cloudIdMap[ingredient.id] = cloudId;
          _updateCache('ingredients', ingredient.id, cloudId);

          // ✅ Resolve commissary UUID
          final commissaryCloudId = _getCloudId('organizations', ingredient.commissaryId);

          if (commissaryCloudId == null) {
            print('   ⚠️ Skipping ingredient ${ingredient.id}: missing commissary UUID');
            continue;
          }

          batchData.add({
            'cloud_id': cloudId,
            'local_id': ingredient.id,
            'name': ingredient.name,
            'commissary_id': commissaryCloudId, // ✅ UUID
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
      }

      if (deleteIds.isNotEmpty) {
        await supabase.from('ingredients').delete().inFilter('cloud_id', deleteIds);
        totalDeleted += deleteIds.length;
      }

      if (batchData.isNotEmpty) {
        await supabase.from('ingredients').upsert(batchData, onConflict: 'cloud_id');
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.ingredientsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) print('   ↑ Pushed $totalPushed ingredients');
    if (totalDeleted > 0) print('   🗑️ Deleted $totalDeleted ingredients');
  }

  Future<void> _pullIngredients() async {
    try {
      final lastSync = _lastSuccessfulSync?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';
      
      final cloudIngredients = await supabase
          .from('ingredients')
          .select()
          .gte('last_updated', lastSync)
          .order('last_updated', ascending: false)
          .limit(1000);

      if (cloudIngredients.isNotEmpty) {
        // ✅ Resolve UUIDs back to local IDs
        final resolvedIngredients = <Map<String, dynamic>>[];
        
        for (final cloudIngredient in cloudIngredients) {
          final commissaryId = _findLocalIdByCloudId('organizations', cloudIngredient['commissary_id']);
          
          if (commissaryId == null) {
            print('   ⚠️ Skipping cloud ingredient ${cloudIngredient['cloud_id']}: missing local commissary');
            continue;
          }
          
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
      print('   ⚠️ Failed to pull ingredients: $e');
    }
  }

  // ==========================================================================
  // RECIPE INGREDIENTS SYNC (with UUID foreign keys)
  // ==========================================================================

  Future<void> syncRecipeIngredients() async {
    await _pushRecipeIngredients();
    await _pullRecipeIngredients();
  }

  Future<void> _pushRecipeIngredients() async {
    int totalPushed = 0;
    int totalDeleted = 0;
    int offset = 0;

    while (true) {
      final unsynced = await db.recipeIngredientsDao.getUnsyncedRecipeIngredients(
        limit: batchSize,
        offset: offset,
      );

      if (unsynced.isEmpty) break;

      final batchData = <Map<String, dynamic>>[];
      final syncedIds = <int>[];
      final cloudIdMap = <int, String>{};
      final deleteIds = <String>[];

      for (final recipe in unsynced) {
        if (recipe.isDeleted && recipe.cloudId != null) {
          deleteIds.add(recipe.cloudId!);
          syncedIds.add(recipe.id);
          continue;
        }

        if (!recipe.isDeleted) {
          final cloudId = recipe.cloudId ?? _uuid.v4();
          cloudIdMap[recipe.id] = cloudId;

          // ✅ Resolve item and ingredient UUIDs
          final itemCloudId = _getCloudId('items', recipe.itemId);
          final ingredientCloudId = _getCloudId('ingredients', recipe.ingredientId);

          if (itemCloudId == null || ingredientCloudId == null) {
            print('   ⚠️ Skipping recipe ${recipe.id}: missing foreign key UUIDs');
            continue;
          }

          batchData.add({
            'cloud_id': cloudId,
            'local_id': recipe.id,
            'item_id': itemCloudId, // ✅ UUID
            'ingredient_id': ingredientCloudId, // ✅ UUID
            'quantity_needed': recipe.quantityNeeded,
            'unit': recipe.unit,
            'notes': recipe.notes,
            'created_at': recipe.createdAt.toIso8601String(),
            'last_updated': recipe.lastUpdated.toIso8601String(),
            'is_deleted': recipe.isDeleted,
          });
          syncedIds.add(recipe.id);
        }
      }

      if (deleteIds.isNotEmpty) {
        await supabase.from('recipe_ingredients').delete().inFilter('cloud_id', deleteIds);
        totalDeleted += deleteIds.length;
      }

      if (batchData.isNotEmpty) {
        await supabase.from('recipe_ingredients').upsert(batchData, onConflict: 'cloud_id');
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.recipeIngredientsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) print('   ↑ Pushed $totalPushed recipe ingredients');
    if (totalDeleted > 0) print('   🗑️ Deleted $totalDeleted recipe ingredients');
  }

  Future<void> _pullRecipeIngredients() async {
    try {
      final lastSync = _lastSuccessfulSync?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';
      
      final cloudRecipes = await supabase
          .from('recipe_ingredients')
          .select()
          .gte('last_updated', lastSync)
          .order('last_updated', ascending: false)
          .limit(1000);

      if (cloudRecipes.isNotEmpty) {
        // ✅ Resolve UUIDs back to local IDs
        final resolvedRecipes = <Map<String, dynamic>>[];
        
        for (final cloudRecipe in cloudRecipes) {
          final itemId = _findLocalIdByCloudId('items', cloudRecipe['item_id']);
          final ingredientId = _findLocalIdByCloudId('ingredients', cloudRecipe['ingredient_id']);
          
          if (itemId == null || ingredientId == null) {
            print('   ⚠️ Skipping cloud recipe ${cloudRecipe['cloud_id']}: missing local foreign keys');
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
          print('   ↓ Pulled ${resolvedRecipes.length} recipe ingredients');
        }
      }
    } catch (e) {
      print('   ⚠️ Failed to pull recipe ingredients: $e');
    }
  }

  // ==========================================================================
  // STOCK REPLENISHMENT REQUESTS SYNC (with UUID foreign keys)
  // ==========================================================================

  Future<void> syncStockReplenishmentRequests() async {
    await _pushReplenishmentRequests();
    await _pullReplenishmentRequests();
  }

  Future<void> _pushReplenishmentRequests() async {
    int totalPushed = 0;
    int totalDeleted = 0;
    int offset = 0;

    while (true) {
      final unsynced = await db.stockReplenishmentRequestsDao.getUnsyncedRequests(
        limit: batchSize,
        offset: offset,
      );

      if (unsynced.isEmpty) break;

      final batchData = <Map<String, dynamic>>[];
      final syncedIds = <int>[];
      final cloudIdMap = <int, String>{};
      final deleteIds = <String>[];

      for (final request in unsynced) {
        if (request.isDeleted && request.cloudId != null) {
          deleteIds.add(request.cloudId!);
          syncedIds.add(request.id);
          continue;
        }

        if (!request.isDeleted) {
          final cloudId = request.cloudId ?? _uuid.v4();
          cloudIdMap[request.id] = cloudId;

          // ✅ Resolve all foreign key UUIDs
          final franchiseeCloudId = _getCloudId('organizations', request.franchiseeId);
          final commissaryCloudId = _getCloudId('organizations', request.commissaryId);
          final itemCloudId = _getCloudId('items', request.itemId);
          final requestedByCloudId = _getCloudId('users', request.requestedBy);
          final reviewedByCloudId = _getCloudId('users', request.reviewedBy);

          if (franchiseeCloudId == null || commissaryCloudId == null || 
              itemCloudId == null || requestedByCloudId == null) {
            print('   ⚠️ Skipping replenishment request ${request.id}: missing foreign key UUIDs');
            continue;
          }

          batchData.add({
            'cloud_id': cloudId,
            'local_id': request.id,
            'franchisee_id': franchiseeCloudId, // ✅ UUID
            'commissary_id': commissaryCloudId, // ✅ UUID
            'item_id': itemCloudId, // ✅ UUID
            'quantity_requested': request.quantityRequested,
            'status': request.status,
            'requested_by': requestedByCloudId, // ✅ UUID
            'requested_at': request.requestedAt.toIso8601String(),
            'reviewed_by': reviewedByCloudId, // ✅ UUID or null
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
      }

      if (deleteIds.isNotEmpty) {
        await supabase.from('stock_replenishment_requests').delete().inFilter('cloud_id', deleteIds);
        totalDeleted += deleteIds.length;
      }

      if (batchData.isNotEmpty) {
        await supabase.from('stock_replenishment_requests').upsert(batchData, onConflict: 'cloud_id');
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.stockReplenishmentRequestsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) print('   ↑ Pushed $totalPushed replenishment requests');
    if (totalDeleted > 0) print('   🗑️ Deleted $totalDeleted replenishment requests');
  }

  Future<void> _pullReplenishmentRequests() async {
    try {
      final lastSync = _lastSuccessfulSync?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';
      
      final cloudRequests = await supabase
          .from('stock_replenishment_requests')
          .select()
          .gte('last_updated', lastSync)
          .order('last_updated', ascending: false)
          .limit(1000);

      if (cloudRequests.isNotEmpty) {
        // ✅ Resolve UUIDs back to local IDs
        final resolvedRequests = <Map<String, dynamic>>[];
        
        for (final cloudRequest in cloudRequests) {
          final franchiseeId = _findLocalIdByCloudId('organizations', cloudRequest['franchisee_id']);
          final commissaryId = _findLocalIdByCloudId('organizations', cloudRequest['commissary_id']);
          final itemId = _findLocalIdByCloudId('items', cloudRequest['item_id']);
          final requestedById = _findLocalIdByCloudId('users', cloudRequest['requested_by']);
          final reviewedById = _findLocalIdByCloudId('users', cloudRequest['reviewed_by']);
          
          if (franchiseeId == null || commissaryId == null || itemId == null || requestedById == null) {
            print('   ⚠️ Skipping cloud replenishment request ${cloudRequest['cloud_id']}: missing local foreign keys');
            continue;
          }
          
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
      print('   ⚠️ Failed to pull replenishment requests: $e');
    }
  }

  // ==========================================================================
  // STOCK CHANGE REQUESTS SYNC (with UUID foreign keys)
  // ==========================================================================

  Future<void> syncStockChangeRequests() async {
    await _pushChangeRequests();
    await _pullChangeRequests();
  }

  Future<void> _pushChangeRequests() async {
    int totalPushed = 0;
    int totalDeleted = 0;
    int offset = 0;

    while (true) {
      final unsynced = await db.stockChangeRequestsDao.getUnsyncedChangeRequests(
        limit: batchSize,
        offset: offset,
      );

      if (unsynced.isEmpty) break;

      final batchData = <Map<String, dynamic>>[];
      final syncedIds = <int>[];
      final cloudIdMap = <int, String>{};
      final deleteIds = <String>[];

      for (final request in unsynced) {
        if (request.isDeleted && request.cloudId != null) {
          deleteIds.add(request.cloudId!);
          syncedIds.add(request.id);
          continue;
        }

        if (!request.isDeleted) {
          final cloudId = request.cloudId ?? _uuid.v4();
          cloudIdMap[request.id] = cloudId;

          // ✅ Resolve all foreign key UUIDs
          final franchiseeCloudId = _getCloudId('organizations', request.franchiseeId);
          final itemCloudId = _getCloudId('items', request.itemId);
          final requestedByCloudId = _getCloudId('users', request.requestedBy);
          final reviewedByCloudId = _getCloudId('users', request.reviewedBy);

          if (franchiseeCloudId == null || itemCloudId == null || requestedByCloudId == null) {
            print('   ⚠️ Skipping change request ${request.id}: missing foreign key UUIDs');
            continue;
          }

          batchData.add({
            'cloud_id': cloudId,
            'local_id': request.id,
            'franchisee_id': franchiseeCloudId, // ✅ UUID
            'item_id': itemCloudId, // ✅ UUID
            'change_type': request.changeType,
            'quantity': request.quantity,
            'status': request.status,
            'requested_by': requestedByCloudId, // ✅ UUID
            'requested_at': request.requestedAt.toIso8601String(),
            'submitted_at': request.submittedAt?.toIso8601String(),
            'reviewed_by': reviewedByCloudId, // ✅ UUID or null
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
      }

      if (deleteIds.isNotEmpty) {
        await supabase.from('stock_change_requests').delete().inFilter('cloud_id', deleteIds);
        totalDeleted += deleteIds.length;
      }

      if (batchData.isNotEmpty) {
        await supabase.from('stock_change_requests').upsert(batchData, onConflict: 'cloud_id');
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.stockChangeRequestsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) print('   ↑ Pushed $totalPushed change requests');
    if (totalDeleted > 0) print('   🗑️ Deleted $totalDeleted change requests');
  }

  Future<void> _pullChangeRequests() async {
    try {
      final lastSync = _lastSuccessfulSync?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';
      
      final cloudRequests = await supabase
          .from('stock_change_requests')
          .select()
          .gte('last_updated', lastSync)
          .order('last_updated', ascending: false)
          .limit(1000);

      if (cloudRequests.isNotEmpty) {
        // ✅ Resolve UUIDs back to local IDs
        final resolvedRequests = <Map<String, dynamic>>[];
        
        for (final cloudRequest in cloudRequests) {
          final franchiseeId = _findLocalIdByCloudId('organizations', cloudRequest['franchisee_id']);
          final itemId = _findLocalIdByCloudId('items', cloudRequest['item_id']);
          final requestedById = _findLocalIdByCloudId('users', cloudRequest['requested_by']);
          final reviewedById = _findLocalIdByCloudId('users', cloudRequest['reviewed_by']);
          
          if (franchiseeId == null || itemId == null || requestedById == null) {
            print('   ⚠️ Skipping cloud change request ${cloudRequest['cloud_id']}: missing local foreign keys');
            continue;
          }
          
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
      print('   ⚠️ Failed to pull change requests: $e');
    }
  }

  // ==========================================================================
  // UTILITIES
  // ==========================================================================

  /// ✅ Cleanup deleted records from local database
  Future<void> _cleanupDeletedRecords() async {
    try {
      print('🧹 Cleaning up deleted records...');
      
      final itemsCleanedCount = await db.itemsDao.cleanupDeletedItems();
      final usersCleanedCount = await db.usersDao.cleanupDeletedUsers();
      final rolesCleanedCount = await db.rolesDao.cleanupDeletedRoles();
      final categoriesCleanedCount = await db.categoriesDao.cleanupDeletedCategories();
      
      final totalCleaned = itemsCleanedCount + usersCleanedCount + rolesCleanedCount + categoriesCleanedCount;
      
      if (totalCleaned > 0) {
        print('✅ Cleaned up $totalCleaned deleted records');
      }
    } catch (e) {
      print('❌ Error cleaning up deleted records: $e');
    }
  }

  Future<void> syncImmediate() async {
    print('⚡ Immediate sync requested');
    await syncAll();
  }

  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final unsyncedItemCount = await db.itemsDao.getUnsyncedItemCount();
      final unsyncedUserCount = await db.usersDao.getUnsyncedUserCount();
      final unsyncedRoleCount = await db.rolesDao.getUnsyncedRoleCount();
      final unsyncedOrgCount = await db.organizationsDao.getUnsyncedOrganizationCount();
      final unsyncedIngredientCount = await db.ingredientsDao.getUnsyncedIngredientCount();
      final unsyncedRecipeCount = await db.recipeIngredientsDao.getUnsyncedRecipeIngredientCount();
      final unsyncedReplenishmentCount = await db.stockReplenishmentRequestsDao.getUnsyncedRequestCount();
      final unsyncedChangeCount = await db.stockChangeRequestsDao.getUnsyncedChangeRequestCount();
      
      return {
        'unsynced_items': unsyncedItemCount,
        'unsynced_users': unsyncedUserCount,
        'unsynced_roles': unsyncedRoleCount,
        'unsynced_organizations': unsyncedOrgCount,
        'unsynced_ingredients': unsyncedIngredientCount,
        'unsynced_recipes': unsyncedRecipeCount,
        'unsynced_replenishment_requests': unsyncedReplenishmentCount,
        'unsynced_change_requests': unsyncedChangeCount,
        'total_unsynced': unsyncedItemCount + unsyncedUserCount + unsyncedRoleCount + 
                         unsyncedOrgCount + unsyncedIngredientCount + unsyncedRecipeCount +
                         unsyncedReplenishmentCount + unsyncedChangeCount,
        'is_syncing': _isSyncing,
        'is_online': _isOnline,
        'last_sync': _lastSuccessfulSync?.toIso8601String() ?? 'Never',
        'cache_size': _cloudIdCache.values.fold(0, (sum, map) => sum + map.length),
      };
    } catch (e) {
      print('❌ Error getting sync status: $e');
      return {
        'error': e.toString(),
        'is_syncing': _isSyncing,
        'is_online': _isOnline,
      };
    }
  }

  void dispose() {
    _syncTimer?.cancel();
    print('🛑 Sync service disposed');
  }
}