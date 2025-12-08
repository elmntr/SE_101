// lib/services/supabase_sync_service.dart
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/app_database.dart';

class SupabaseSyncService {
  final AppDatabase db;
  final SupabaseClient supabase;
  Timer? _syncTimer;
  bool _isSyncing = false;
  
  // Sync every 10 minutes
  static const Duration syncInterval = Duration(minutes: 10);
  
  // Callbacks for UI updates
  Function(bool isOnline)? onConnectivityChanged;
  Function(String status)? onSyncStatusChanged;
  Function(String error)? onSyncError;
  
  SupabaseSyncService({
    required this.db,
    required this.supabase,
    this.onConnectivityChanged,
    this.onSyncStatusChanged,
    this.onSyncError,
  });

  /// Initialize sync service
  Future<void> initialize() async {
    print('🚀 Initializing sync service...');
    
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
  }

  /// Start periodic background sync
  void startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(syncInterval, (_) {
      syncAll();
    });
    print('⏰ Periodic sync started (every ${syncInterval.inMinutes} minutes)');
  }

  /// Stop periodic sync
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    print('⏸️ Periodic sync stopped');
  }

  /// Main sync method - syncs all tables
  Future<void> syncAll() async {
    if (_isSyncing) {
      print('⏳ Sync already in progress, skipping...');
      return;
    }

    try {
      _isSyncing = true;
      onSyncStatusChanged?.call('Syncing...');
      
      // Check internet connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print('📵 No internet connection, sync skipped');
        onSyncStatusChanged?.call('Offline');
        return;
      }

      print('🔄 Starting sync...');
      
      // Sync in order: Roles → Users → Items
      await syncRoles();
      await syncUsers();
      await syncItems();
      
      print('✅ Sync completed successfully');
      onSyncStatusChanged?.call('Synced');
    } catch (e) {
      print('❌ Sync failed: $e');
      onSyncError?.call(e.toString());
      onSyncStatusChanged?.call('Sync failed');
      // Don't throw - let the app continue working offline
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync Items table
  Future<void> syncItems() async {
    try {
      print('📦 Syncing items...');
      
      // 1. PUSH: Upload unsynced local items to cloud
      final unsyncedItems = await db.itemsDao.getUnsyncedItems();
      print('   → Pushing ${unsyncedItems.length} unsynced items');
      
      for (final item in unsyncedItems) {
        try {
          if (item.isDeleted) {
            // Delete from cloud if it exists
            if (item.cloudId != null) {
              await supabase
                  .from('items')
                  .delete()
                  .eq('cloud_id', item.cloudId!);
            }
          } else {
            // Upsert to cloud
            final cloudData = {
              'local_id': item.id,
              'cloud_id': item.cloudId ?? _generateUUID(),
              'name': item.name,
              'stock': item.stock,
              'sold': item.sold,
              'spoilage': item.spoilage,
              'created_at': item.createdAt.toIso8601String(),
              'last_updated': item.lastUpdated.toIso8601String(),
              'is_deleted': item.isDeleted,
            };
            
            final response = await supabase
                .from('items')
                .upsert(cloudData)
                .select()
                .single();
            
            // Mark as synced locally with cloud ID
            await db.itemsDao.markAsSynced(
              item.id,
              cloudId: response['cloud_id'],
            );
          }
          
          print('   ✓ Item ${item.id} (${item.name}) synced');
        } catch (e) {
          print('   ✗ Failed to sync item ${item.id}: $e');
          // Continue with next item
        }
      }
      
      // 2. PULL: Download changes from cloud
      print('   → Pulling items from cloud...');
      final cloudItems = await supabase
          .from('items')
          .select()
          .order('last_updated', ascending: false);
      
      for (final cloudItem in cloudItems) {
        try {
          final cloudId = cloudItem['cloud_id'] as String;
          final localItem = await db.itemsDao.getItemByCloudId(cloudId);
          
          final cloudUpdated = DateTime.parse(cloudItem['last_updated']);
          
          if (localItem == null) {
            // New item from cloud - insert locally
            await db.itemsDao.upsertFromCloud(
              id: cloudItem['local_id'],
              name: cloudItem['name'],
              stock: cloudItem['stock'],
              sold: cloudItem['sold'] ?? 0,
              spoilage: cloudItem['spoilage'] ?? 0,
              createdAt: DateTime.parse(cloudItem['created_at']),
              lastUpdated: cloudUpdated,
              isDeleted: cloudItem['is_deleted'] ?? false,
              cloudId: cloudId,
            );
            print('   ✓ New item from cloud: ${cloudItem['name']}');
          } else if (cloudUpdated.isAfter(localItem.lastUpdated)) {
            // Cloud version is newer - update local
            await db.itemsDao.upsertFromCloud(
              id: localItem.id,
              name: cloudItem['name'],
              stock: cloudItem['stock'],
              sold: cloudItem['sold'] ?? 0,
              spoilage: cloudItem['spoilage'] ?? 0,
              createdAt: localItem.createdAt,
              lastUpdated: cloudUpdated,
              isDeleted: cloudItem['is_deleted'] ?? false,
              cloudId: cloudId,
            );
            print('   ✓ Updated item from cloud: ${cloudItem['name']}');
          }
        } catch (e) {
          print('   ✗ Failed to process cloud item: $e');
        }
      }
      
      print('   ✅ Items sync complete');
    } catch (e) {
      print('   ❌ Items sync failed: $e');
      rethrow;
    }
  }

  /// Sync Users table
  Future<void> syncUsers() async {
    try {
      print('👥 Syncing users...');
      
      final unsyncedUsers = await db.usersDao.getUnsyncedUsers();
      print('   → Pushing ${unsyncedUsers.length} unsynced users');
      
      for (final user in unsyncedUsers) {
        try {
          final cloudData = {
            'local_id': user.id,
            'cloud_id': user.cloudId ?? _generateUUID(),
            'email': user.email,
            'username': user.username,
            'password': user.password, // ⚠️ Consider hashing!
            'phone': user.phone,
            'role_id': user.roleId,
            'is_active': user.isActive,
            'created_at': user.createdAt.toIso8601String(),
            'last_updated': user.lastUpdated.toIso8601String(),
          };
          
          final response = await supabase
              .from('users')
              .upsert(cloudData)
              .select()
              .single();
          
          await db.usersDao.markAsSynced(
            user.id,
            cloudId: response['cloud_id'],
          );
          
          print('   ✓ User ${user.username} synced');
        } catch (e) {
          print('   ✗ Failed to sync user ${user.id}: $e');
        }
      }
      
      print('   ✅ Users sync complete');
    } catch (e) {
      print('   ❌ Users sync failed: $e');
    }
  }

  /// Sync Roles table
  Future<void> syncRoles() async {
    try {
      print('🔐 Syncing roles...');
      
      final unsyncedRoles = await db.rolesDao.getUnsyncedRoles();
      print('   → Pushing ${unsyncedRoles.length} unsynced roles');
      
      for (final role in unsyncedRoles) {
        try {
          final cloudData = {
            'local_id': role.id,
            'cloud_id': role.cloudId ?? _generateUUID(),
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
          };
          
          final response = await supabase
              .from('roles')
              .upsert(cloudData)
              .select()
              .single();
          
          await db.rolesDao.markAsSynced(
            role.id,
            cloudId: response['cloud_id'],
          );
          
          print('   ✓ Role ${role.name} synced');
        } catch (e) {
          print('   ✗ Failed to sync role ${role.id}: $e');
        }
      }
      
      print('   ✅ Roles sync complete');
    } catch (e) {
      print('   ❌ Roles sync failed: $e');
    }
  }

  /// Trigger immediate sync (call after create/update/delete)
  Future<void> syncImmediate() async {
    print('⚡ Immediate sync requested');
    await syncAll();
  }

  /// Quick sync for specific table only
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

  /// Generate UUID for cloud records
  String _generateUUID() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        (1000 + DateTime.now().microsecond).toString();
  }

  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final unsyncedItems = await db.itemsDao.getUnsyncedItems();
    final unsyncedUsers = await db.usersDao.getUnsyncedUsers();
    final unsyncedRoles = await db.rolesDao.getUnsyncedRoles();
    
    return {
      'unsynced_items': unsyncedItems.length,
      'unsynced_users': unsyncedUsers.length,
      'unsynced_roles': unsyncedRoles.length,
      'total_unsynced': unsyncedItems.length + 
                        unsyncedUsers.length + 
                        unsyncedRoles.length,
      'is_syncing': _isSyncing,
    };
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    print('🛑 Sync service disposed');
  }
}