// lib/helpers/sync_helper.dart
import '../app_globals.dart';

/// Helper to trigger sync after database operations
/// Updated to support new multi-table sync service
class SyncHelper {
  // ==========================================================================
  // IMMEDIATE TABLE-SPECIFIC SYNCS
  // ==========================================================================

  /// Sync immediately after adding/updating organizations
  static Future<void> syncAfterOrganizationChange() async {
    try {
      await syncService.syncOrganizations();
      print('✅ Organization synced to cloud');
    } catch (e) {
      print('⚠️ Could not sync organization: $e');
      // Organization will sync in the next periodic sync (10 minutes)
    }
  }

  /// Sync immediately after adding/updating items
  static Future<void> syncAfterItemChange() async {
    try {
      await syncService.syncItems();
      print('✅ Item synced to cloud');
    } catch (e) {
      print('⚠️ Could not sync item: $e');
      // Item will sync in the next periodic sync (10 minutes)
    }
  }

  /// Sync immediately after adding/updating ingredients
  static Future<void> syncAfterIngredientChange() async {
    try {
      await syncService.syncIngredients();
      print('✅ Ingredient synced to cloud');
    } catch (e) {
      print('⚠️ Could not sync ingredient: $e');
      // Ingredient will sync in the next periodic sync (10 minutes)
    }
  }

  /// Sync immediately after adding/updating recipe ingredients
  static Future<void> syncAfterRecipeChange() async {
    try {
      await syncService.syncRecipeIngredients();
      print('✅ Recipe synced to cloud');
    } catch (e) {
      print('⚠️ Could not sync recipe: $e');
      // Recipe will sync in the next periodic sync (10 minutes)
    }
  }

  /// Sync immediately after creating/updating stock replenishment request
  static Future<void> syncAfterReplenishmentRequest() async {
    try {
      await syncService.syncStockReplenishmentRequests();
      print('✅ Replenishment request synced to cloud');
    } catch (e) {
      print('⚠️ Could not sync replenishment request: $e');
      // Request will sync in the next periodic sync (10 minutes)
    }
  }

  /// Sync immediately after creating/updating stock change request
  static Future<void> syncAfterStockChange() async {
    try {
      await syncService.syncStockChangeRequests();
      print('✅ Stock change request synced to cloud');
    } catch (e) {
      print('⚠️ Could not sync stock change request: $e');
      // Request will sync in the next periodic sync (10 minutes)
    }
  }

  /// Sync immediately after adding/updating users
  static Future<void> syncAfterUserChange() async {
    try {
      await syncService.syncUsers();
      print('✅ User synced to cloud');
    } catch (e) {
      print('⚠️ Could not sync user: $e');
      // User will sync in the next periodic sync (10 minutes)
    }
  }

  /// Sync immediately after adding/updating roles
  static Future<void> syncAfterRoleChange() async {
    try {
      await syncService.syncRoles();
      print('✅ Role synced to cloud');
    } catch (e) {
      print('⚠️ Could not sync role: $e');
      // Role will sync in the next periodic sync (10 minutes)
    }
  }

  /// Sync immediately after adding/updating categories
  // static Future<void> syncAfterCategoryChange() async {
  //   try {
  //     await syncService.syncCategories();
  //     print('✅ Category synced to cloud');
  //   } catch (e) {
  //     print('⚠️ Could not sync category: $e');
  //     // Category will sync in the next periodic sync (10 minutes)
  //   }
  // }
  
  // ==========================================================================
  // BULK SYNC OPERATIONS
  // ==========================================================================

  /// Sync all tables (full sync)
  static Future<void> syncAll() async {
    try {
      await syncService.syncImmediate();
      print('✅ All data synced to cloud');
    } catch (e) {
      print('⚠️ Could not sync: $e');
    }
  }

  /// Get current sync status for all tables
  static Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      return await syncService.getSyncStatus();
    } catch (e) {
      print('⚠️ Could not get sync status: $e');
      return {'error': e.toString(), 'is_syncing': false};
    }
  }

  /// Clean up deleted records from local database (after cloud deletion)
  // static Future<void> cleanupDeletedRecords() async {
  //   try {
  //     await syncService.cleanupLocalDeletedRecords();
  //     print('✅ Deleted records cleaned up');
  //   } catch (e) {
  //     print('⚠️ Could not cleanup deleted records: $e');
  //   }
  // }
  
  // ==========================================================================
  // BATCH OPERATION HELPERS
  // ==========================================================================

  /// Sync after batch item operations (e.g., bulk import)
  static Future<void> syncAfterBatchItemChanges() async {
    await syncAfterItemChange();
  }

  /// Sync after batch user operations (e.g., employee import)
  static Future<void> syncAfterBatchUserChanges() async {
    await syncAfterUserChange();
  }

  /// Sync multiple related tables in dependency order
  /// Useful when you've made changes to multiple related entities
  static Future<void> syncRelatedTables({
    bool syncOrganizations = false,
    bool syncCategories = false,
    bool syncRoles = false,
    bool syncUsers = false,
    bool syncItems = false,
    bool syncIngredients = false,
    bool syncRecipes = false,
    bool syncReplenishmentRequests = false,
    bool syncStockChangeRequests = false,
  }) async {
    try {
      // Sync in dependency order
      if (syncOrganizations) await syncService.syncOrganizations();
      if (syncRoles) await syncService.syncRoles();
      if (syncUsers) await syncService.syncUsers();
      if (syncItems) await syncService.syncItems();
      if (syncIngredients) await syncService.syncIngredients();
      if (syncRecipes) await syncService.syncRecipeIngredients();
      if (syncReplenishmentRequests)
        await syncService.syncStockReplenishmentRequests();
      if (syncStockChangeRequests) await syncService.syncStockChangeRequests();

      print('✅ Related tables synced to cloud');
    } catch (e) {
      print('⚠️ Could not sync related tables: $e');
    }
  }

  // ==========================================================================
  // UTILITY METHODS
  // ==========================================================================

  /// Check if sync is currently in progress
  static Future<bool> isSyncing() async {
    final status = await getSyncStatus();
    return status['is_syncing'] == true;
  }

  /// Get total unsynced records count across all tables
  static Future<int> getTotalUnsyncedCount() async {
    final status = await getSyncStatus();
    return status['total_unsynced'] ?? 0;
  }

  /// Get unsynced count for a specific table
  static Future<int> getUnsyncedCount(String table) async {
    final status = await getSyncStatus();
    final key = 'unsynced_$table';
    return status[key] ?? 0;
  }

  /// Wait for current sync to complete (with timeout)
  static Future<void> waitForSyncComplete({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final startTime = DateTime.now();

    while (await isSyncing()) {
      if (DateTime.now().difference(startTime) > timeout) {
        print('⚠️ Sync wait timeout after ${timeout.inSeconds} seconds');
        break;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}
