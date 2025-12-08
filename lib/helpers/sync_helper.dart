// lib/helpers/sync_helper.dart
import '../app_globals.dart';

/// Helper to trigger sync after database operations
class SyncHelper {
  /// Sync immediately after adding/updating an item
  static Future<void> syncAfterItemChange() async {
    try {
      await syncService.syncItemsOnly();
      print('✅ Item synced to cloud');
    } catch (e) {
      print('⚠️ Could not sync item: $e');
      // Item will sync in the next periodic sync (10 minutes)
    }
  }
  
  /// Sync all tables
  static Future<void> syncAll() async {
    try {
      await syncService.syncImmediate();
      print('✅ All data synced to cloud');
    } catch (e) {
      print('⚠️ Could not sync: $e');
    }
  }
}