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
  
  // âœ… Configuration
  static const Duration syncInterval = Duration(minutes: 10);
  static const int batchSize = 100;
  static const int maxRetries = 3;
  static const Duration initialRetryDelay = Duration(seconds: 2);
  
  // Callbacks for UI updates
  Function(bool isOnline)? onConnectivityChanged;
  Function(String status)? onSyncStatusChanged;
  Function(String error)? onSyncError;
  Function(double progress)? onSyncProgress;
  
  final Uuid _uuid = Uuid();
  
  SupabaseSyncService({
    required this.db,
    required this.supabase,
    this.onConnectivityChanged,
    this.onSyncStatusChanged,
    this.onSyncError,
    this.onSyncProgress,
  });

  /// âœ… Initialize sync service
  Future<void> initialize() async {
    print('ðŸš€ Initializing sync service...');
    
    try {
      // Check initial connectivity
      _isOnline = await _checkConnectivity();
      onConnectivityChanged?.call(_isOnline);
      
      // Build UUID cache from local database
      await _buildCloudIdCache();
      
      // Start periodic sync
      startPeriodicSync();
      
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
      
      await syncAll();
    } catch (e) {
      print('âŒ Failed to initialize sync service: $e');
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
    print('â° Periodic sync started (every ${syncInterval.inMinutes} minutes)');
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
    print('â¸ï¸ Periodic sync stopped');
  }

  /// âœ… Main sync method with dependency-aware ordering
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
        
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          print('ðŸ"µ No internet connection, sync skipped');
          onSyncStatusChanged?.call('Offline');
          return;
        }

        print('ðŸ"„ Starting sync (attempt $attempt/$maxRetries)...');
        
        // âœ… Sync in dependency order
        await _syncWithProgress([
          () => syncOrganizations(),
          () => syncCategories(),
          () => syncRoles(),
          () => syncUsers(),
          () => syncItems(),
          () => syncIngredients(),
          () => syncRecipeIngredients(),
          () => syncStockReplenishmentRequests(),
          () => syncStockChangeRequests(),
        ]);
        
        print('âœ… Sync completed successfully');
        onSyncStatusChanged?.call('Synced');
        
        // ✅ Rebuild cache after successful sync
        await _buildCloudIdCache();
        
        // ✅ Cleanup old deleted records after successful sync
        await _cleanupDeletedRecords();
        
        return;
        
      } catch (e) {
        print('âŒ Sync attempt $attempt failed: $e');
        
        if (attempt == maxRetries) {
          onSyncError?.call('Sync failed after $maxRetries attempts: $e');
          onSyncStatusChanged?.call('Sync failed');
        } else {
          final delay = initialRetryDelay * pow(2, attempt - 1);
          print('â³ Retrying in ${delay.inSeconds} seconds...');
          await Future.delayed(delay);
        }
      } finally {
        _isSyncing = false;
      }
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
    int offset = 0;
    int totalPushed = 0;

    while (true) {
      final unsynced = await db.organizationsDao.getUnsyncedOrganizations(
        limit: batchSize,
        offset: offset,
      );

      if (unsynced.isEmpty) break;

      final List<Map<String, dynamic>> batchData = [];
      final List<int> syncedIds = [];
      final Map<int, String> cloudIdMap = {};

      for (final org in unsynced) {
        if (!org.isActive && org.cloudId != null) {
          // Cloud deletion handled by Supabase
          continue;
        }

        if (org.isActive) {
          final cloudId = org.cloudId ?? _uuid.v4();
          cloudIdMap[org.id] = cloudId;
          _updateCache('organizations', org.id, cloudId);

          // ✅ Resolve parent commissary UUID
          final parentCloudId = _getCloudId('organizations', org.parentCommissaryId);

          batchData.add({
            'id': org.id,
            'cloud_id': cloudId,
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

    if (totalPushed > 0) {
      print('   âœ" Pushed $totalPushed organizations');
    }
  }

  Future<void> _pullOrganizations() async {
    try {
      final cloudOrgs = await supabase
          .from('organizations')
          .select()
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
      print('   âš ï¸ Failed to pull organizations: $e');
    }
  }

  // ==========================================================================
  // INGREDIENTS SYNC
  // ==========================================================================

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
    int totalDeleted = 0;

    while (true) {
      final unsynced = await db.ingredientsDao.getUnsyncedIngredients(
        limit: batchSize,
        offset: offset,
      );

      if (unsynced.isEmpty) break;

      final List<Map<String, dynamic>> batchData = [];
      final List<int> syncedIds = [];
      final Map<int, String> cloudIdMap = {};

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
            'id': ingredient.id,
            'cloud_id': cloudId,
            'name': ingredient.name,
            'category_id': ingredient.categoryId,
            'commissary_id': ingredient.commissaryId,
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

      if (batchData.isNotEmpty) {
        await supabase.from('ingredients').upsert(batchData);
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.ingredientsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) print('   âœ" Pushed $totalPushed ingredients');
    if (totalDeleted > 0) print('   âœ" Deleted $totalDeleted ingredients from cloud');
  }

  Future<void> _pullIngredients() async {
    try {
      final cloudIngredients = await supabase
          .from('ingredients')
          .select()
          .order('last_updated', ascending: false)
          .limit(1000);

      if (cloudIngredients.isNotEmpty) {
        await db.ingredientsDao.upsertBatchFromCloud(cloudIngredients);
        print('   âœ" Pulled ${cloudIngredients.length} ingredients');
      }
    } catch (e) {
      print('   âš ï¸ Failed to pull ingredients: $e');
    }
  }

  // ==========================================================================
  // USERS SYNC (with UUID foreign keys)
  // ==========================================================================

  Future<void> syncRecipeIngredients() async {
    try {
      print('ðŸ"œ Syncing recipe ingredients...');
      await _pushRecipeIngredients();
      await _pullRecipeIngredients();
      print('   âœ… Recipe ingredients sync complete');
    } catch (e) {
      print('   âŒ Recipe ingredients sync failed: $e');
      rethrow;
    }
  }

  Future<void> _pushRecipeIngredients() async {
    int offset = 0;
    int totalPushed = 0;
    int totalDeleted = 0;

    while (true) {
      final unsynced = await db.recipeIngredientsDao.getUnsyncedRecipeIngredients(
        limit: batchSize,
        offset: offset,
      );

      if (unsynced.isEmpty) break;

      final List<Map<String, dynamic>> batchData = [];
      final List<int> syncedIds = [];
      final Map<int, String> cloudIdMap = {};

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
            'id': recipeIngredient.id,
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
        await supabase.from('recipe_ingredients').upsert(batchData);
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.recipeIngredientsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) print('   âœ" Pushed $totalPushed recipe ingredients');
    if (totalDeleted > 0) print('   âœ" Deleted $totalDeleted recipe ingredients from cloud');
  }

  Future<void> _pullRecipeIngredients() async {
    try {
      final cloudRecipes = await supabase
          .from('recipe_ingredients')
          .select()
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
      print('   âš ï¸ Failed to pull recipe ingredients: $e');
    }
  }

  // ==========================================================================
  // ITEMS SYNC (with UUID foreign keys)
  // ==========================================================================

  Future<void> syncStockReplenishmentRequests() async {
    try {
      print('ðŸ"¦ Syncing stock replenishment requests...');
      await _pushReplenishmentRequests();
      await _pullReplenishmentRequests();
      print('   âœ… Stock replenishment requests sync complete');
    } catch (e) {
      print('   âŒ Stock replenishment requests sync failed: $e');
      rethrow;
    }
  }

  Future<void> _pushReplenishmentRequests() async {
    int offset = 0;
    int totalPushed = 0;
    int totalDeleted = 0;

    while (true) {
      final unsynced = await db.stockReplenishmentRequestsDao.getUnsyncedRequests(
        limit: batchSize,
        offset: offset,
      );

      if (unsynced.isEmpty) break;

      final List<Map<String, dynamic>> batchData = [];
      final List<int> syncedIds = [];
      final Map<int, String> cloudIdMap = {};

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
            'id': request.id,
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
        await supabase.from('stock_replenishment_requests').upsert(batchData);
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.stockReplenishmentRequestsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) print('   âœ" Pushed $totalPushed replenishment requests');
    if (totalDeleted > 0) print('   âœ" Deleted $totalDeleted replenishment requests from cloud');
  }

  Future<void> _pullReplenishmentRequests() async {
    try {
      final cloudRequests = await supabase
          .from('stock_replenishment_requests')
          .select()
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
      print('   âš ï¸ Failed to pull replenishment requests: $e');
    }
  }

  // ==========================================================================
  // INGREDIENTS SYNC (with UUID foreign keys)
  // ==========================================================================

  Future<void> syncStockChangeRequests() async {
    try {
      print('ðŸ"„ Syncing stock change requests...');
      await _pushChangeRequests();
      await _pullChangeRequests();
      print('   âœ… Stock change requests sync complete');
    } catch (e) {
      print('   âŒ Stock change requests sync failed: $e');
      rethrow;
    }
  }

  Future<void> _pushChangeRequests() async {
    int offset = 0;
    int totalPushed = 0;
    int totalDeleted = 0;

    while (true) {
      final unsynced = await db.stockChangeRequestsDao.getUnsyncedChangeRequests(
        limit: batchSize,
        offset: offset,
      );

      if (unsynced.isEmpty) break;

      final List<Map<String, dynamic>> batchData = [];
      final List<int> syncedIds = [];
      final Map<int, String> cloudIdMap = {};

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
            'id': request.id,
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
        await supabase.from('stock_change_requests').upsert(batchData);
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.stockChangeRequestsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) print('   âœ" Pushed $totalPushed change requests');
    if (totalDeleted > 0) print('   âœ" Deleted $totalDeleted change requests from cloud');
  }

  Future<void> _pullChangeRequests() async {
    try {
      final cloudRequests = await supabase
          .from('stock_change_requests')
          .select()
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
      print('   âš ï¸ Failed to pull change requests: $e');
    }
  }

  // ==========================================================================
  // RECIPE INGREDIENTS SYNC (with UUID foreign keys)
  // ==========================================================================

  Future<void> syncItems() async {
    try {
      print('ðŸ"¦ Syncing items...');
      await _pushItems();
      await _pullItems();
      print('   âœ… Items sync complete');
    } catch (e) {
      print('   âŒ Items sync failed: $e');
      rethrow;
    }
  }

  Future<void> _pushItems() async {
    int offset = 0;
    int totalPushed = 0;
    int totalDeleted = 0;

    while (true) {
      final unsyncedItems = await db.itemsDao.getUnsyncedItems(
        limit: batchSize,
        offset: offset,
      );

      if (unsyncedItems.isEmpty) break;

      final List<Map<String, dynamic>> batchData = [];
      final List<int> syncedIds = [];
      final Map<int, String> cloudIdMap = {};

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
            'id': item.id,
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
        await supabase.from('items').upsert(batchData);
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.itemsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) print('   âœ" Pushed $totalPushed items');
    if (totalDeleted > 0) print('   âœ" Deleted $totalDeleted items from cloud');
  }

  Future<void> _pullItems() async {
    try {
      final cloudItems = await supabase
          .from('items')
          .select()
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
      print('   âš ï¸ Failed to pull items: $e');
    }
  }

  // ==========================================================================
  // STOCK REPLENISHMENT REQUESTS SYNC (with UUID foreign keys)
  // ==========================================================================

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
    int totalDeleted = 0;
    
    while (true) {
      final unsyncedUsers = await db.usersDao.getUnsyncedUsers(
        limit: batchSize,
        offset: offset,
      );
      
      if (unsyncedUsers.isEmpty) break;
      
      final List<Map<String, dynamic>> batchData = [];
      final List<int> syncedIds = [];
      final Map<int, String> cloudIdMap = {};
      
      for (final user in unsyncedUsers) {
        if (!user.isActive && user.cloudId != null) {
          try {
            await supabase
              .from('users')
              .delete()
              .eq('cloud_id', user.cloudId!);
            syncedIds.add(user.id);
            totalDeleted++;
          } catch (e) {
            print('   âš ï¸ Failed to delete user ${user.id}: $e');
          }
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
            'id': user.id,
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
        await supabase.from('users').upsert(batchData);
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.usersDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }
      
      offset += batchSize;
    }
    
    if (totalPushed > 0) print('   âœ" Pushed $totalPushed users');
    if (totalDeleted > 0) print('   âœ" Deleted $totalDeleted users from cloud');
  }

  Future<void> _pullUsers() async {
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
      print('   âš ï¸ Failed to pull users: $e');
    }
  }

  // ==========================================================================
  // STOCK CHANGE REQUESTS SYNC (with UUID foreign keys)
  // ==========================================================================

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
    int totalDeleted = 0;
    
    while (true) {
      final unsyncedRoles = await db.rolesDao.getUnsyncedRoles(
        limit: batchSize,
        offset: offset,
      );
      
      if (unsyncedRoles.isEmpty) break;
      
      final List<Map<String, dynamic>> batchData = [];
      final List<int> syncedIds = [];
      final Map<int, String> cloudIdMap = {};
      
      for (final role in unsyncedRoles) {
        if (!role.isActive && role.cloudId != null && !role.isSystemRole) {
          try {
            await supabase
              .from('roles')
              .delete()
              .eq('cloud_id', role.cloudId!);
            syncedIds.add(role.id);
            totalDeleted++;
          } catch (e) {
            print('   âš ï¸ Failed to delete role ${role.id}: $e');
          }
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
            'id': role.id,
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
        await supabase.from('roles').upsert(batchData);
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.rolesDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }
      
      offset += batchSize;
    }
    
    if (totalPushed > 0) print('   âœ" Pushed $totalPushed roles');
    if (totalDeleted > 0) print('   âœ" Deleted $totalDeleted roles from cloud');
  }

  Future<void> _pullRoles() async {
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
      print('   âš ï¸ Failed to pull roles: $e');
    }
  }

  // ==========================================================================
  // CATEGORIES SYNC (UNCHANGED)
  // ==========================================================================

  Future<void> syncCategories() async {
    try {
      print('ðŸ"‚ Syncing categories...');
      // Categories table needs sync fields added
      print('   â„¹ï¸ Category sync not yet fully implemented (needs sync fields)');
    } catch (e) {
      print('   âŒ Categories sync failed: $e');
    }
  }

  // ==========================================================================
  // UTILITIES
  // ==========================================================================

  Future<void> syncImmediate() async {
    print('âš¡ Immediate sync requested');
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
      print('âŒ Error getting sync status: $e');
      return {
        'error': e.toString(),
        'is_syncing': _isSyncing,
      };
    }
  }

  Future<void> cleanupLocalDeletedRecords() async {
    try {
      print('ðŸ§¹ Cleaning up local deleted records...');
      
      final itemsCleanedCount = await db.itemsDao.cleanupDeletedItems();
      final usersCleanedCount = await db.usersDao.cleanupDeletedUsers();
      final rolesCleanedCount = await db.rolesDao.cleanupDeletedRoles();
      final categoriesCleanedCount = await db.categoriesDao.cleanupDeletedCategories();
      
      final totalCleaned = itemsCleanedCount + usersCleanedCount + rolesCleanedCount + categoriesCleanedCount;
      
      if (totalCleaned > 0) {
        print('âœ… Cleaned up $totalCleaned records from local database');
      } else {
        print('â„¹ï¸ No records to clean up');
      }
    } catch (e) {
      print('âŒ Error cleaning up deleted records: $e');
    }
  }

  void dispose() {
    _syncTimer?.cancel();
    print('ðŸ› Sync service disposed');
  }
}