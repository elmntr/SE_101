// lib/services/supabase_sync_service.dart
import 'dart:async';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';

class SupabaseSyncService {
  final AppDatabase db;
  final SupabaseClient supabase;
  Timer? _syncTimer;
  bool _isSyncing = false;
  
  // ✅ Configuration
  static const Duration syncInterval = Duration(minutes: 10);
  static const int batchSize = 50; // Process 50 items at a time
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

  /// ✅ Initialize sync service
  Future<void> initialize() async {
    print('🚀 Initializing sync service...');
    
    try {
      // Start periodic sync
      startPeriodicSync();
      
      // Listen to connectivity changes
      Connectivity().onConnectivityChanged.listen((result) {
        final isOnline = result != ConnectivityResult.none;
        onConnectivityChanged?.call(isOnline);
        
        if (isOnline) {
          print('🌐 Network restored, triggering sync...');
          syncAll();
        }
      });
      
      // Initial sync attempt
      await syncAll();
    } catch (e) {
      print('❌ Failed to initialize sync service: $e');
      onSyncError?.call('Initialization failed: $e');
    }
  }

  /// ✅ Start periodic background sync
  void startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(syncInterval, (_) {
      syncAll();
    });
    print('⏰ Periodic sync started (every ${syncInterval.inMinutes} minutes)');
  }

  /// ✅ Stop periodic sync
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    print('⏸️ Periodic sync stopped');
  }

  /// ✅ Main sync method with retry logic
  Future<void> syncAll() async {
    if (_isSyncing) {
      print('⏳ Sync already in progress, skipping...');
      return;
    }

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        _isSyncing = true;
        onSyncStatusChanged?.call('Syncing...');
        
        // Check internet connectivity
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          print('🔵 No internet connection, sync skipped');
          onSyncStatusChanged?.call('Offline');
          return;
        }

        print('🔄 Starting sync (attempt $attempt/$maxRetries)...');
        
        // Sync in order: Roles → Users → Items → Categories
        await _syncWithProgress([
          () => syncRoles(),
          () => syncUsers(),
          () => syncItems(),
          () => syncCategories(),
        ]);
        
        print('✅ Sync completed successfully');
        onSyncStatusChanged?.call('Synced');
        return; // Success, exit retry loop
        
      } catch (e) {
        print('❌ Sync attempt $attempt failed: $e');
        
        if (attempt == maxRetries) {
          // Final attempt failed
          onSyncError?.call('Sync failed after $maxRetries attempts: $e');
          onSyncStatusChanged?.call('Sync failed');
        } else {
          // Wait before retrying with exponential backoff
          final delay = initialRetryDelay * pow(2, attempt - 1);
          print('⏳ Retrying in ${delay.inSeconds} seconds...');
          await Future.delayed(delay);
        }
      } finally {
        _isSyncing = false;
      }
    }
  }

  /// ✅ Execute sync steps with progress tracking
  Future<void> _syncWithProgress(List<Future<void> Function()> steps) async {
    for (int i = 0; i < steps.length; i++) {
      await steps[i]();
      final progress = (i + 1) / steps.length;
      onSyncProgress?.call(progress);
    }
  }

  // ==========================================================================
  // ITEMS SYNC
  // ==========================================================================

  /// ✅ Sync Items table with batch operations and cloud deletion
  Future<void> syncItems() async {
    try {
      print('📦 Syncing items...');
      
      // PUSH: Upload unsynced items in batches (includes deletions)
      await _pushItems();
      
      // PULL: Download changes from cloud
      await _pullItems();
      
      print('   ✅ Items sync complete');
    } catch (e) {
      print('   ❌ Items sync failed: $e');
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

    print('   ↑ Pushing batch of ${unsyncedItems.length} items...');

    // Prepare batch data
    final List<Map<String, dynamic>> batchData = [];
    final List<int> syncedIds = [];
    final Map<int, String> cloudIdMap = {};

    for (final item in unsyncedItems) {
      if (item.isDeleted && item.cloudId != null) {
        // ✅ CLOUD DELETION
        try {
          await supabase
              .from('items')
              .delete()
              .eq('cloud_id', item.cloudId!);

          syncedIds.add(item.id);
          totalDeleted++;

          print(
              '   🗑️  Deleted item ${item.id} from cloud (cloudId: ${item.cloudId})');
        } catch (e) {
          print('   ⚠️ Failed to delete item ${item.id} from cloud: $e');
        }
      } else if (!item.isDeleted) {
        final cloudId = item.cloudId ?? _uuid.v4();
        cloudIdMap[item.id] = cloudId;

        batchData.add({
          'local_id': item.id,
          'cloud_id': cloudId,
          'name': item.name,
          'category_id': item.categoryId,
          'stock': item.stock,
          'sold': item.sold,
          'spoilage': item.spoilage,
          'created_at': item.createdAt.toIso8601String(),
          'last_updated': item.lastUpdated.toIso8601String(),
          'is_deleted': item.isDeleted,
        });

        syncedIds.add(item.id);
      }
    }

    // ✅ Batch upsert (non-deleted items)
    if (batchData.isNotEmpty) {
      try {
        await supabase.from('items').upsert(batchData);
        totalPushed += batchData.length;
      } catch (e) {
        print('   ⚠️ Batch upsert failed: $e');
      }
    }

    // ✅ CRITICAL FIX:
    // Always mark synced (includes deletions-only batches)
    if (syncedIds.isNotEmpty) {
      await db.itemsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
    }

    offset += batchSize;
  }

  if (totalPushed > 0) {
    print('   ✔ Pushed $totalPushed items');
  }
  if (totalDeleted > 0) {
    print('   ✔ Deleted $totalDeleted items from cloud');
  }
}


  Future<void> _pullItems() async {
    try {
      print('   ↓ Pulling items from cloud...');
      
      // Get latest timestamp from local DB
      final latestLocal = await db.customSelect(
        'SELECT MAX(last_updated) as max_updated FROM items',
        readsFrom: {db.items},
      ).getSingleOrNull();
      
      // Build query to get only newer items
      var query = supabase
        .from('items')
        .select()
        .order('last_updated', ascending: false);
      
      final cloudItems = await query.limit(1000); // Limit for safety
      
      if (cloudItems.isEmpty) {
        print('   ℹ️ No new items from cloud');
        return;
      }
      
      // ✅ Batch process cloud items
      final List<Map<String, dynamic>> itemsToUpsert = [];
      
      for (final cloudItem in cloudItems) {
        itemsToUpsert.add(cloudItem);
        
        // Process in batches
        if (itemsToUpsert.length >= batchSize) {
          await db.itemsDao.upsertBatchFromCloud(itemsToUpsert);
          itemsToUpsert.clear();
        }
      }
      
      // Process remaining items
      if (itemsToUpsert.isNotEmpty) {
        await db.itemsDao.upsertBatchFromCloud(itemsToUpsert);
      }
      
      print('   ✔ Pulled ${cloudItems.length} items from cloud');
    } catch (e) {
      print('   ⚠️ Failed to pull items: $e');
      throw e;
    }
  }

  // ==========================================================================
  // USERS SYNC
  // ==========================================================================

  Future<void> syncUsers() async {
    try {
      print('👥 Syncing users...');
      await _pushUsers();
      await _pullUsers();
      print('   ✅ Users sync complete');
    } catch (e) {
      print('   ❌ Users sync failed: $e');
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
        // ✅ CLOUD DELETION: If user is inactive and has cloudId, delete from cloud
        if (!user.isActive && user.cloudId != null) {
          try {
            await supabase
              .from('users')
              .delete()
              .eq('cloud_id', user.cloudId!);
            syncedIds.add(user.id);
            totalDeleted++;
            print('   🗑️  Deleted user ${user.id} from cloud (cloudId: ${user.cloudId})');
          } catch (e) {
            print('   ⚠️ Failed to delete user ${user.id} from cloud: $e');
          }
          continue;
        }
        
        // Only sync active users
        if (user.isActive) {
          final cloudId = user.cloudId ?? _uuid.v4();
          cloudIdMap[user.id] = cloudId;
          
          batchData.add({
            'local_id': user.id,
            'cloud_id': cloudId,
            'email': user.email,
            'username': user.username,
            'password': user.password, // ⚠️ Should be hashed
            'phone': user.phone,
            'role_id': user.roleId,
            'is_active': user.isActive,
            'created_at': user.createdAt.toIso8601String(),
            'last_updated': user.lastUpdated.toIso8601String(),
          });
          syncedIds.add(user.id);
        }
      }
      
      if (batchData.isNotEmpty) {
        try {
          await supabase.from('users').upsert(batchData);
          await db.usersDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
          totalPushed += syncedIds.length;
        } catch (e) {
          print('   ⚠️ User batch upsert failed: $e');
        }
      }
      
      offset += batchSize;
    }
    
    if (totalPushed > 0) {
      print('   ✔ Pushed $totalPushed users');
    }
    if (totalDeleted > 0) {
      print('   ✔ Deleted $totalDeleted users from cloud');
    }
  }

  Future<void> _pullUsers() async {
    try {
      final cloudUsers = await supabase
        .from('users')
        .select()
        .order('last_updated', ascending: false)
        .limit(1000);
      
      if (cloudUsers.isNotEmpty) {
        await db.usersDao.upsertBatchFromCloud(cloudUsers);
        print('   ✔ Pulled ${cloudUsers.length} users');
      }
    } catch (e) {
      print('   ⚠️ Failed to pull users: $e');
    }
  }

  // ==========================================================================
  // ROLES SYNC
  // ==========================================================================

  Future<void> syncRoles() async {
    try {
      print('🔑 Syncing roles...');
      await _pushRoles();
      await _pullRoles();
      print('   ✅ Roles sync complete');
    } catch (e) {
      print('   ❌ Roles sync failed: $e');
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
        // ✅ CLOUD DELETION: If role is inactive and has cloudId, delete from cloud
        if (!role.isActive && role.cloudId != null && !role.isSystemRole) {
          try {
            await supabase
              .from('roles')
              .delete()
              .eq('cloud_id', role.cloudId!);
            syncedIds.add(role.id);
            totalDeleted++;
            print('   🗑️  Deleted role ${role.id} from cloud (cloudId: ${role.cloudId})');
          } catch (e) {
            print('   ⚠️ Failed to delete role ${role.id} from cloud: $e');
          }
          continue;
        }
        
        // Only sync active roles
        if (role.isActive) {
          final cloudId = role.cloudId ?? _uuid.v4();
          cloudIdMap[role.id] = cloudId;
          
          batchData.add({
            'local_id': role.id,
            'cloud_id': cloudId,
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
      
      if (batchData.isNotEmpty) {
        try {
          await supabase.from('roles').upsert(batchData);
          await db.rolesDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
          totalPushed += syncedIds.length;
        } catch (e) {
          print('   ⚠️ Role batch upsert failed: $e');
        }
      }
      
      offset += batchSize;
    }
    
    if (totalPushed > 0) {
      print('   ✔ Pushed $totalPushed roles');
    }
    if (totalDeleted > 0) {
      print('   ✔ Deleted $totalDeleted roles from cloud');
    }
  }

  Future<void> _pullRoles() async {
    try {
      final cloudRoles = await supabase
        .from('roles')
        .select()
        .order('last_updated', ascending: false)
        .limit(1000);
      
      if (cloudRoles.isNotEmpty) {
        await db.rolesDao.upsertBatchFromCloud(cloudRoles);
        print('   ✔ Pulled ${cloudRoles.length} roles');
      }
    } catch (e) {
      print('   ⚠️ Failed to pull roles: $e');
    }
  }

  // ==========================================================================
  // CATEGORIES SYNC
  // ==========================================================================

  Future<void> syncCategories() async {
    try {
      print('📂 Syncing categories...');
      await _pushCategories();
      await _pullCategories();
      print('   ✅ Categories sync complete');
    } catch (e) {
      print('   ❌ Categories sync failed: $e');
    }
  }

  Future<void> _pushCategories() async {
    // Note: Categories table needs isSynced and cloudId columns added
    // This is a placeholder implementation
    print('   ℹ️ Category push not yet fully implemented (needs sync fields)');
  }

  Future<void> _pullCategories() async {
    // Note: Categories table needs isSynced and cloudId columns added
    // This is a placeholder implementation
    print('   ℹ️ Category pull not yet fully implemented (needs sync fields)');
  }

  // ==========================================================================
  // UTILITIES
  // ==========================================================================

  /// ✅ Trigger immediate sync
  Future<void> syncImmediate() async {
    print('⚡ Immediate sync requested');
    await syncAll();
  }

  /// ✅ Quick sync for specific table only
  Future<void> syncItemsOnly() async {
    if (_isSyncing) {
      print('⏳ Sync already in progress');
      return;
    }
    
    try {
      _isSyncing = true;
      onSyncStatusChanged?.call('Syncing items...');
      await syncItems();
      print('✅ Items synced');
      onSyncStatusChanged?.call('Synced');
    } catch (e) {
      print('❌ Items sync failed: $e');
      onSyncError?.call(e.toString());
    } finally {
      _isSyncing = false;
    }
  }

  /// ✅ Get sync status with detailed counts
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final unsyncedItemCount = await db.itemsDao.getUnsyncedItemCount();
      final unsyncedUserCount = await db.usersDao.getUnsyncedUserCount();
      final unsyncedRoleCount = await db.rolesDao.getUnsyncedRoleCount();
      
      return {
        'unsynced_items': unsyncedItemCount,
        'unsynced_users': unsyncedUserCount,
        'unsynced_roles': unsyncedRoleCount,
        'total_unsynced': unsyncedItemCount + unsyncedUserCount + unsyncedRoleCount,
        'is_syncing': _isSyncing,
        'last_sync': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ Error getting sync status: $e');
      return {
        'error': e.toString(),
        'is_syncing': _isSyncing,
      };
    }
  }

  /// ✅ Cleanup deleted records from local database after successful cloud deletion
  Future<void> cleanupLocalDeletedRecords() async {
    try {
      print('🧹 Cleaning up local deleted records...');
      
      final itemsCleanedCount = await db.itemsDao.cleanupDeletedItems();
      final usersCleanedCount = await db.usersDao.cleanupDeletedUsers();
      final rolesCleanedCount = await db.rolesDao.cleanupDeletedRoles();
      final categoriesCleanedCount = await db.categoriesDao.cleanupDeletedCategories();
      
      final totalCleaned = itemsCleanedCount + usersCleanedCount + rolesCleanedCount + categoriesCleanedCount;
      
      if (totalCleaned > 0) {
        print('✅ Cleaned up $totalCleaned records from local database');
      } else {
        print('ℹ️ No records to clean up');
      }
    } catch (e) {
      print('❌ Error cleaning up deleted records: $e');
    }
  }

  /// ✅ Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    print('🛑 Sync service disposed');
  }
}