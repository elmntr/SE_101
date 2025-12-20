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

  // âœ… Configuration
  static const Duration syncInterval = Duration(minutes: 10);
  static const int batchSize = 50;
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
      startPeriodicSync();

      Connectivity().onConnectivityChanged.listen((result) {
        final isOnline = result != ConnectivityResult.none;
        onConnectivityChanged?.call(isOnline);

        if (isOnline) {
          print('ðŸŒ Network restored, triggering sync...');
          syncAll();
        }
      });

      await syncAll();
    } catch (e) {
      print('âŒ Failed to initialize sync service: $e');
      onSyncError?.call('Initialization failed: $e');
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
      print('â³ Sync already in progress, skipping...');
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
  // ORGANIZATIONS SYNC
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

          batchData.add({
            'id': org.id,
            'cloud_id': cloudId,
            'name': org.name,
            'type': org.type,
            'parent_commissary_id': org.parentCommissaryId,
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

      if (batchData.isNotEmpty) {
        await supabase.from('organizations').upsert(batchData);
        await db.organizationsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
        totalPushed += batchData.length;
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
        await db.organizationsDao.upsertBatchFromCloud(cloudOrgs);
        print('   âœ" Pulled ${cloudOrgs.length} organizations');
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

      for (final ingredient in unsynced) {
        if (ingredient.isDeleted && ingredient.cloudId != null) {
          try {
            await supabase
                .from('ingredients')
                .delete()
                .eq('cloud_id', ingredient.cloudId!);
            syncedIds.add(ingredient.id);
            totalDeleted++;
          } catch (e) {
            print('   âš ï¸ Failed to delete ingredient ${ingredient.id}: $e');
          }
        } else if (!ingredient.isDeleted) {
          final cloudId = ingredient.cloudId ?? _uuid.v4();
          cloudIdMap[ingredient.id] = cloudId;

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
    if (totalDeleted > 0)
      print('   âœ" Deleted $totalDeleted ingredients from cloud');
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
  // RECIPE INGREDIENTS SYNC
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
      final unsynced = await db.recipeIngredientsDao
          .getUnsyncedRecipeIngredients(limit: batchSize, offset: offset);

      if (unsynced.isEmpty) break;

      final List<Map<String, dynamic>> batchData = [];
      final List<int> syncedIds = [];
      final Map<int, String> cloudIdMap = {};

      for (final recipeIngredient in unsynced) {
        if (recipeIngredient.isDeleted && recipeIngredient.cloudId != null) {
          try {
            await supabase
                .from('recipe_ingredients')
                .delete()
                .eq('cloud_id', recipeIngredient.cloudId!);
            syncedIds.add(recipeIngredient.id);
            totalDeleted++;
          } catch (e) {
            print(
              '   âš ï¸ Failed to delete recipe ingredient ${recipeIngredient.id}: $e',
            );
          }
        } else if (!recipeIngredient.isDeleted) {
          final cloudId = recipeIngredient.cloudId ?? _uuid.v4();
          cloudIdMap[recipeIngredient.id] = cloudId;

          batchData.add({
            'id': recipeIngredient.id,
            'cloud_id': cloudId,
            'item_id': recipeIngredient.itemId,
            'ingredient_id': recipeIngredient.ingredientId,
            'quantity_needed': recipeIngredient.quantityNeeded,
            'unit': recipeIngredient.unit,
            'notes': recipeIngredient.notes,
            'created_at': recipeIngredient.createdAt.toIso8601String(),
            'last_updated': recipeIngredient.lastUpdated.toIso8601String(),
            'is_deleted': recipeIngredient.isDeleted,
          });
          syncedIds.add(recipeIngredient.id);
        }
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

    if (totalPushed > 0) print('   âœ" Pushed $totalPushed recipe ingredients');
    if (totalDeleted > 0)
      print('   âœ" Deleted $totalDeleted recipe ingredients from cloud');
  }

  Future<void> _pullRecipeIngredients() async {
    try {
      final cloudRecipes = await supabase
          .from('recipe_ingredients')
          .select()
          .order('last_updated', ascending: false)
          .limit(1000);

      if (cloudRecipes.isNotEmpty) {
        await db.recipeIngredientsDao.upsertBatchFromCloud(cloudRecipes);
        print('   âœ" Pulled ${cloudRecipes.length} recipe ingredients');
      }
    } catch (e) {
      print('   âš ï¸ Failed to pull recipe ingredients: $e');
    }
  }

  // ==========================================================================
  // STOCK REPLENISHMENT REQUESTS SYNC
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
      final unsynced = await db.stockReplenishmentRequestsDao
          .getUnsyncedRequests(limit: batchSize, offset: offset);

      if (unsynced.isEmpty) break;

      final List<Map<String, dynamic>> batchData = [];
      final List<int> syncedIds = [];
      final Map<int, String> cloudIdMap = {};

      for (final request in unsynced) {
        if (request.isDeleted && request.cloudId != null) {
          try {
            await supabase
                .from('stock_replenishment_requests')
                .delete()
                .eq('cloud_id', request.cloudId!);
            syncedIds.add(request.id);
            totalDeleted++;
          } catch (e) {
            print(
              '   âš ï¸ Failed to delete replenishment request ${request.id}: $e',
            );
          }
        } else if (!request.isDeleted) {
          final cloudId = request.cloudId ?? _uuid.v4();
          cloudIdMap[request.id] = cloudId;

          batchData.add({
            'id': request.id,
            'cloud_id': cloudId,
            'franchisee_id': request.franchiseeId,
            'commissary_id': request.commissaryId,
            'item_id': request.itemId,
            'quantity_requested': request.quantityRequested,
            'status': request.status,
            'requested_by': request.requestedBy,
            'requested_at': request.requestedAt.toIso8601String(),
            'reviewed_by': request.reviewedBy,
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

    if (totalPushed > 0)
      print('   âœ" Pushed $totalPushed replenishment requests');
    if (totalDeleted > 0)
      print('   âœ" Deleted $totalDeleted replenishment requests from cloud');
  }

  Future<void> _pullReplenishmentRequests() async {
    try {
      final cloudRequests = await supabase
          .from('stock_replenishment_requests')
          .select()
          .order('last_updated', ascending: false)
          .limit(1000);

      if (cloudRequests.isNotEmpty) {
        await db.stockReplenishmentRequestsDao.upsertBatchFromCloud(
          cloudRequests,
        );
        print('   âœ" Pulled ${cloudRequests.length} replenishment requests');
      }
    } catch (e) {
      print('   âš ï¸ Failed to pull replenishment requests: $e');
    }
  }

  // ==========================================================================
  // STOCK CHANGE REQUESTS SYNC
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
      final unsynced = await db.stockChangeRequestsDao
          .getUnsyncedChangeRequests(limit: batchSize, offset: offset);

      if (unsynced.isEmpty) break;

      final List<Map<String, dynamic>> batchData = [];
      final List<int> syncedIds = [];
      final Map<int, String> cloudIdMap = {};

      for (final request in unsynced) {
        if (request.isDeleted && request.cloudId != null) {
          try {
            await supabase
                .from('stock_change_requests')
                .delete()
                .eq('cloud_id', request.cloudId!);
            syncedIds.add(request.id);
            totalDeleted++;
          } catch (e) {
            print('   âš ï¸ Failed to delete change request ${request.id}: $e');
          }
        } else if (!request.isDeleted) {
          final cloudId = request.cloudId ?? _uuid.v4();
          cloudIdMap[request.id] = cloudId;

          batchData.add({
            'id': request.id,
            'cloud_id': cloudId,
            'franchisee_id': request.franchiseeId,
            'item_id': request.itemId,
            'change_type': request.changeType,
            'quantity': request.quantity,
            'status': request.status,
            'requested_by': request.requestedBy,
            'requested_at': request.requestedAt.toIso8601String(),
            'submitted_at': request.submittedAt?.toIso8601String(),
            'reviewed_by': request.reviewedBy,
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

    if (totalPushed > 0) print('   âœ" Pushed $totalPushed change requests');
    if (totalDeleted > 0)
      print('   âœ" Deleted $totalDeleted change requests from cloud');
  }

  Future<void> _pullChangeRequests() async {
    try {
      final cloudRequests = await supabase
          .from('stock_change_requests')
          .select()
          .order('last_updated', ascending: false)
          .limit(1000);

      if (cloudRequests.isNotEmpty) {
        await db.stockChangeRequestsDao.upsertBatchFromCloud(cloudRequests);
        print('   âœ" Pulled ${cloudRequests.length} change requests');
      }
    } catch (e) {
      print('   âš ï¸ Failed to pull change requests: $e');
    }
  }

  // ==========================================================================
  // ITEMS SYNC (UPDATED WITH NEW FIELDS)
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

      for (final item in unsyncedItems) {
        if (item.isDeleted && item.cloudId != null) {
          try {
            await supabase.from('items').delete().eq('cloud_id', item.cloudId!);
            syncedIds.add(item.id);
            totalDeleted++;
          } catch (e) {
            print('   âš ï¸ Failed to delete item ${item.id}: $e');
          }
        } else if (!item.isDeleted) {
          final cloudId = item.cloudId ?? _uuid.v4();
          cloudIdMap[item.id] = cloudId;

          batchData.add({
            'id': item.id,
            'cloud_id': cloudId,
            'name': item.name,
            'category_id': item.categoryId,
            'organization_id': item.organizationId,
            'master_item_id': item.masterItemId,
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
    if (totalDeleted > 0)
      print('   âœ" Deleted $totalDeleted items from cloud');
  }

  Future<void> _pullItems() async {
    try {
      final cloudItems = await supabase
          .from('items')
          .select()
          .order('last_updated', ascending: false)
          .limit(1000);

      if (cloudItems.isNotEmpty) {
        await db.itemsDao.upsertBatchFromCloud(cloudItems);
        print('   âœ" Pulled ${cloudItems.length} items');
      }
    } catch (e) {
      print('   âš ï¸ Failed to pull items: $e');
    }
  }

  // ==========================================================================
  // USERS SYNC (UPDATED WITH NEW FIELDS)
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
            await supabase.from('users').delete().eq('cloud_id', user.cloudId!);
            syncedIds.add(user.id);
            totalDeleted++;
          } catch (e) {
            print('   âš ï¸ Failed to delete user ${user.id}: $e');
          }
          continue;
        }

        if (user.isActive) {
          final cloudId = user.cloudId ?? _uuid.v4();
          cloudIdMap[user.id] = cloudId;

          batchData.add({
            'id': user.id,
            'cloud_id': cloudId,
            'email': user.email,
            'username': user.username,
            'password': user.password,
            'phone': user.phone,
            'organization_id': user.organizationId,
            'role_id': user.roleId,
            'full_name': user.fullName,
            'is_active': user.isActive,
            'created_at': user.createdAt.toIso8601String(),
            'last_updated': user.lastUpdated.toIso8601String(),
          });
          syncedIds.add(user.id);
        }
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
    if (totalDeleted > 0)
      print('   âœ" Deleted $totalDeleted users from cloud');
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
        print('   âœ" Pulled ${cloudUsers.length} users');
      }
    } catch (e) {
      print('   âš ï¸ Failed to pull users: $e');
    }
  }

  // ==========================================================================
  // ROLES SYNC (UNCHANGED)
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
            await supabase.from('roles').delete().eq('cloud_id', role.cloudId!);
            syncedIds.add(role.id);
            totalDeleted++;
          } catch (e) {
            print('   âš ï¸ Failed to delete role ${role.id}: $e');
          }
          continue;
        }

        if (role.isActive) {
          final cloudId = role.cloudId ?? _uuid.v4();
          cloudIdMap[role.id] = cloudId;

          batchData.add({
            'id': role.id,
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
        await supabase.from('roles').upsert(batchData);
        totalPushed += batchData.length;
      }

      if (syncedIds.isNotEmpty) {
        await db.rolesDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }

      offset += batchSize;
    }

    if (totalPushed > 0) print('   âœ" Pushed $totalPushed roles');
    if (totalDeleted > 0)
      print('   âœ" Deleted $totalDeleted roles from cloud');
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
        print('   âœ" Pulled ${cloudRoles.length} roles');
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
      print(
        '   â„¹ï¸ Category sync not yet fully implemented (needs sync fields)',
      );
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
      final unsyncedOrgCount = await db.organizationsDao
          .getUnsyncedOrganizationCount();
      final unsyncedIngredientCount = await db.ingredientsDao
          .getUnsyncedIngredientCount();
      final unsyncedRecipeCount = await db.recipeIngredientsDao
          .getUnsyncedRecipeIngredientCount();
      final unsyncedReplenishmentCount = await db.stockReplenishmentRequestsDao
          .getUnsyncedRequestCount();
      final unsyncedChangeCount = await db.stockChangeRequestsDao
          .getUnsyncedChangeRequestCount();

      return {
        'unsynced_items': unsyncedItemCount,
        'unsynced_users': unsyncedUserCount,
        'unsynced_roles': unsyncedRoleCount,
        'unsynced_organizations': unsyncedOrgCount,
        'unsynced_ingredients': unsyncedIngredientCount,
        'unsynced_recipes': unsyncedRecipeCount,
        'unsynced_replenishment_requests': unsyncedReplenishmentCount,
        'unsynced_change_requests': unsyncedChangeCount,
        'total_unsynced':
            unsyncedItemCount +
            unsyncedUserCount +
            unsyncedRoleCount +
            unsyncedOrgCount +
            unsyncedIngredientCount +
            unsyncedRecipeCount +
            unsyncedReplenishmentCount +
            unsyncedChangeCount,
        'is_syncing': _isSyncing,
        'last_sync': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('âŒ Error getting sync status: $e');
      return {'error': e.toString(), 'is_syncing': _isSyncing};
    }
  }

  Future<void> cleanupLocalDeletedRecords() async {
    try {
      print('ðŸ§¹ Cleaning up local deleted records...');

      final itemsCleanedCount = await db.itemsDao.cleanupDeletedItems();
      final usersCleanedCount = await db.usersDao.cleanupDeletedUsers();
      final rolesCleanedCount = await db.rolesDao.cleanupDeletedRoles();
      final categoriesCleanedCount = await db.categoriesDao
          .cleanupDeletedCategories();

      final totalCleaned =
          itemsCleanedCount +
          usersCleanedCount +
          rolesCleanedCount +
          categoriesCleanedCount;

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
