// lib/helpers/sync_helper.dart
import '../app_globals.dart';

/// Helper to trigger sync after database operations
/// 
/// Usage:
/// - After creating/updating items: await SyncHelper.syncAfterItemChange();
/// - After any database operation: await SyncHelper.syncAll();
/// 
/// Note: Respects the enableCloudSync flag - won't sync if cloud sync is disabled
class SyncHelper {
  /// Sync immediately after adding/updating an item
  static Future<void> syncAfterItemChange() async {
    // ✅ Check if cloud sync is enabled
    if (!syncService.enableCloudSync) {
      print('ℹ️ Cloud sync disabled, skipping item sync');
      return;
    }
    
    try {
      await syncService.syncImmediate(); // Use syncImmediate instead of syncItemsOnly
      print('✅ Item synced to cloud');
    } catch (e) {
      print('⚠️ Could not sync item: $e');
      // Item will sync in the next periodic sync (10 minutes)
    }
  }
  
  /// Sync all tables
  static Future<void> syncAll() async {
    // ✅ Check if cloud sync is enabled
    if (!syncService.enableCloudSync) {
      print('ℹ️ Cloud sync disabled, skipping sync');
      return;
    }
    
    try {
      await syncService.syncImmediate();
      print('✅ All data synced to cloud');
    } catch (e) {
      print('⚠️ Could not sync: $e');
    }
  }
  
  /// ✅ NEW: Sync specific table types
  static Future<void> syncOrganizations() async {
    if (!syncService.enableCloudSync) {
      print('ℹ️ Cloud sync disabled, skipping organizations sync');
      return;
    }
    
    try {
      await syncService.syncOrganizations();
      print('✅ Organizations synced to cloud');
    } catch (e) {
      print('⚠️ Could not sync organizations: $e');
    }
  }
  
  static Future<void> syncIngredients() async {
    if (!syncService.enableCloudSync) {
      print('ℹ️ Cloud sync disabled, skipping ingredients sync');
      return;
    }
    
    try {
      await syncService.syncIngredients();
      print('✅ Ingredients synced to cloud');
    } catch (e) {
      print('⚠️ Could not sync ingredients: $e');
    }
  }
  
  static Future<void> syncStockRequests() async {
    if (!syncService.enableCloudSync) {
      print('ℹ️ Cloud sync disabled, skipping stock requests sync');
      return;
    }
    
    try {
      await syncService.syncStockReplenishmentRequests();
      await syncService.syncStockChangeRequests();
      print('✅ Stock requests synced to cloud');
    } catch (e) {
      print('⚠️ Could not sync stock requests: $e');
    }
  }
  
  /// ✅ NEW: Get sync status
  static Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      return await syncService.getSyncStatus();
    } catch (e) {
      print('⚠️ Could not get sync status: $e');
      return {'error': e.toString()};
    }
  }
  
  /// ✅ NEW: Check if there are unsynced changes
  static Future<bool> hasUnsyncedChanges() async {
    try {
      final status = await syncService.getSyncStatus();
      
      if (status.containsKey('mode') && status['mode'] == 'offline') {
        return false; // Offline mode, no sync needed
      }
      
      final totalUnsynced = status['total_unsynced'] ?? 0;
      return totalUnsynced > 0;
    } catch (e) {
      print('⚠️ Could not check unsynced changes: $e');
      return false;
    }
  }
  
  /// ✅ NEW: Enable/disable cloud sync
  static void setCloudSyncEnabled(bool enabled) {
    syncService.enableCloudSync = enabled;
    
    if (enabled) {
      print('✅ Cloud sync enabled');
      syncService.startPeriodicSync();
    } else {
      print('⚠️ Cloud sync disabled');
      syncService.stopPeriodicSync();
    }
  }
  
  /// ✅ NEW: Check if cloud sync is enabled
  static bool isCloudSyncEnabled() {
    return syncService.enableCloudSync;
  }
}