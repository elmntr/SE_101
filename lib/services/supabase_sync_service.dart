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
  
  /// ✅ OFFLINE TESTING FLAG
  /// Set to false to test everything locally without cloud operations
  /// 
  /// Usage:
  /// syncService.enableCloudSync = false; // Disable cloud sync
  /// syncService.enableCloudSync = true;  // Enable cloud sync (default)
  bool enableCloudSync = true;
  
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
    
    if (!enableCloudSync) {
      print('⚠️ CLOUD SYNC DISABLED - Running in offline mode');
      onSyncStatusChanged?.call('Offline mode');
      return;
    }
    
    try {
      // Start periodic sync
      startPeriodicSync();
      
      // Listen to connectivity changes
      Connectivity().onConnectivityChanged.listen((result) {
        final isOnline = result != ConnectivityResult.none;
        onConnectivityChanged?.call(isOnline);
        
        if (isOnline && enableCloudSync) {
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
    if (!enableCloudSync) {
      print('⚠️ Cloud sync disabled, periodic sync not started');
      return;
    }
    
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
    if (!enableCloudSync) {
      print('⚠️ Cloud sync disabled, skipping sync');
      onSyncStatusChanged?.call('Offline mode');
      return;
    }
    
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
        
        // Sync in order: Organizations → Roles → Users → Items → Categories → Ingredients → RecipeIngredients → Requests
        await _syncWithProgress([
          () => syncOrganizations(),
          () => syncRoles(),
          () => syncUsers(),
          () => syncItems(),
          () => syncCategories(),
          () => syncIngredients(),
          () => syncRecipeIngredients(),
          () => syncStockReplenishmentRequests(),
          () => syncStockChangeRequests(),
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
  // ORGANIZATIONS SYNC
  // ==========================================================================

  Future<void> syncOrganizations() async {
    if (!enableCloudSync) return;
    
    try {
      print('🏢 Syncing organizations...');
      await _pushOrganizations();
      await _pullOrganizations();
      print('   ✅ Organizations sync complete');
    } catch (e) {
      print('   ❌ Organizations sync failed: $e');
    }
  }

  Future<void> _pushOrganizations() async {
    if (!enableCloudSync) return;
    
    int offset = 0;
    int totalPushed = 0;
    
    while (true) {
      final unsyncedOrgs = await db.organizationsDao.getUnsyncedOrganizations(
        limit: batchSize,
        offset: offset,
      );
      
      if (unsyncedOrgs.isEmpty) break;
      
      final List<Map<String, dynamic>> batchData = [];
      final List<int> syncedIds = [];
      final Map<int, String> cloudIdMap = {};
      
      for (final org in unsyncedOrgs) {
        if (org.isActive) {
          final cloudId = org.cloudId ?? _uuid.v4();
          cloudIdMap[org.id] = cloudId;
          
          batchData.add({
            'local_id': org.id,
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
        try {
          await supabase.from('organizations').upsert(batchData);
          await db.organizationsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
          totalPushed += syncedIds.length;
        } catch (e) {
          print('   ⚠️ Organization batch upsert failed: $e');
        }
      }
      
      offset += batchSize;
    }
    
    if (totalPushed > 0) {
      print('   ✔ Pushed $totalPushed organizations');
    }
  }

  Future<void> _pullOrganizations() async {
    if (!enableCloudSync) return;
    
    try {
      final cloudOrgs = await supabase
        .from('organizations')
        .select()
        .order('last_updated', ascending: false)
        .limit(1000);
      
      if (cloudOrgs.isNotEmpty) {
        await db.organizationsDao.upsertBatchFromCloud(cloudOrgs);
        print('   ✔ Pulled ${cloudOrgs.length} organizations');
      }
    } catch (e) {
      print('   ⚠️ Failed to pull organizations: $e');
    }
  }

  // ==========================================================================
  // INGREDIENTS SYNC
  // ==========================================================================

  Future<void> syncIngredients() async {
    if (!enableCloudSync) return;
    
    try {
      print('🥬 Syncing ingredients...');
      await _pushIngredients();
      await _pullIngredients();
      print('   ✅ Ingredients sync complete');
    } catch (e) {
      print('   ❌ Ingredients sync failed: $e');
    }
  }

  Future<void> _pushIngredients() async {
    if (!enableCloudSync) return;
    
    int offset = 0;
    int totalPushed = 0;
    int totalDeleted = 0;
    
    while (true) {
      final unsyncedIngredients = await db.ingredientsDao.getUnsyncedIngredients(
        limit: batchSize,
        offset: offset,
      );
      
      if (unsyncedIngredients.isEmpty) break;
      
      final List<Map<String, dynamic>> batchData = [];
      final List<int> syncedIds = [];
      final Map<int, String> cloudIdMap = {};
      
      for (final ingredient in unsyncedIngredients) {
        if (ingredient.isDeleted && ingredient.cloudId != null) {
          try {
            await supabase
              .from('ingredients')
              .delete()
              .eq('cloud_id', ingredient.cloudId!);
            syncedIds.add(ingredient.id);
            totalDeleted++;
          } catch (e) {
            print('   ⚠️ Failed to delete ingredient ${ingredient.id}: $e');
          }
        } else if (!ingredient.isDeleted) {
          final cloudId = ingredient.cloudId ?? _uuid.v4();
          cloudIdMap[ingredient.id] = cloudId;
          
          batchData.add({
            'local_id': ingredient.id,
            'cloud_id': cloudId,
            'name': ingredient.name,
            'commissary_id': ingredient.commissaryId,
            'category_id': ingredient.categoryId,
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
        try {
          await supabase.from('ingredients').upsert(batchData);
        } catch (e) {
          print('   ⚠️ Ingredient batch upsert failed: $e');
        }
      }
      
      if (syncedIds.isNotEmpty) {
        await db.ingredientsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }
      
      offset += batchSize;
    }
    
    if (totalPushed > 0) {
      print('   ✔ Pushed $totalPushed ingredients');
    }
    if (totalDeleted > 0) {
      print('   ✔ Deleted $totalDeleted ingredients from cloud');
    }
  }

  Future<void> _pullIngredients() async {
    if (!enableCloudSync) return;
    
    try {
      final cloudIngredients = await supabase
        .from('ingredients')
        .select()
        .order('last_updated', ascending: false)
        .limit(1000);
      
      if (cloudIngredients.isNotEmpty) {
        await db.ingredientsDao.upsertBatchFromCloud(cloudIngredients);
        print('   ✔ Pulled ${cloudIngredients.length} ingredients');
      }
    } catch (e) {
      print('   ⚠️ Failed to pull ingredients: $e');
    }
  }

  // ==========================================================================
  // RECIPE INGREDIENTS SYNC
  // ==========================================================================

  Future<void> syncRecipeIngredients() async {
    if (!enableCloudSync) return;
    
    try {
      print('📝 Syncing recipe ingredients...');
      await _pushRecipeIngredients();
      await _pullRecipeIngredients();
      print('   ✅ Recipe ingredients sync complete');
    } catch (e) {
      print('   ❌ Recipe ingredients sync failed: $e');
    }
  }

  Future<void> _pushRecipeIngredients() async {
    if (!enableCloudSync) return;
    
    int offset = 0;
    int totalPushed = 0;
    int totalDeleted = 0;
    
    while (true) {
      final unsyncedRecipeIngredients = await db.recipeIngredientsDao.getUnsyncedRecipeIngredients(
        limit: batchSize,
        offset: offset,
      );
      
      if (unsyncedRecipeIngredients.isEmpty) break;
      
      final List<Map<String, dynamic>> batchData = [];
      final List<int> syncedIds = [];
      final Map<int, String> cloudIdMap = {};
      
      for (final ri in unsyncedRecipeIngredients) {
        if (ri.isDeleted && ri.cloudId != null) {
          try {
            await supabase
              .from('recipe_ingredients')
              .delete()
              .eq('cloud_id', ri.cloudId!);
            syncedIds.add(ri.id);
            totalDeleted++;
          } catch (e) {
            print('   ⚠️ Failed to delete recipe ingredient ${ri.id}: $e');
          }
        } else if (!ri.isDeleted) {
          final cloudId = ri.cloudId ?? _uuid.v4();
          cloudIdMap[ri.id] = cloudId;
          
          batchData.add({
            'local_id': ri.id,
            'cloud_id': cloudId,
            'item_id': ri.itemId,
            'ingredient_id': ri.ingredientId,
            'quantity_needed': ri.quantityNeeded,
            'unit': ri.unit,
            'notes': ri.notes,
            'created_at': ri.createdAt.toIso8601String(),
            'last_updated': ri.lastUpdated.toIso8601String(),
            'is_deleted': ri.isDeleted,
          });
          syncedIds.add(ri.id);
        }
      }
      
      if (batchData.isNotEmpty) {
        try {
          await supabase.from('recipe_ingredients').upsert(batchData);
        } catch (e) {
          print('   ⚠️ Recipe ingredient batch upsert failed: $e');
        }
      }
      
      if (syncedIds.isNotEmpty) {
        await db.recipeIngredientsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }
      
      offset += batchSize;
    }
    
    if (totalPushed > 0) {
      print('   ✔ Pushed $totalPushed recipe ingredients');
    }
    if (totalDeleted > 0) {
      print('   ✔ Deleted $totalDeleted recipe ingredients from cloud');
    }
  }

  Future<void> _pullRecipeIngredients() async {
    if (!enableCloudSync) return;
    
    try {
      final cloudRecipeIngredients = await supabase
        .from('recipe_ingredients')
        .select()
        .order('last_updated', ascending: false)
        .limit(1000);
      
      if (cloudRecipeIngredients.isNotEmpty) {
        await db.recipeIngredientsDao.upsertBatchFromCloud(cloudRecipeIngredients);
        print('   ✔ Pulled ${cloudRecipeIngredients.length} recipe ingredients');
      }
    } catch (e) {
      print('   ⚠️ Failed to pull recipe ingredients: $e');
    }
  }

  // ==========================================================================
  // STOCK REPLENISHMENT REQUESTS SYNC
  // ==========================================================================

  Future<void> syncStockReplenishmentRequests() async {
    if (!enableCloudSync) return;
    
    try {
      print('📋 Syncing stock replenishment requests...');
      await _pushStockReplenishmentRequests();
      await _pullStockReplenishmentRequests();
      print('   ✅ Stock replenishment requests sync complete');
    } catch (e) {
      print('   ❌ Stock replenishment requests sync failed: $e');
    }
  }

  Future<void> _pushStockReplenishmentRequests() async {
    if (!enableCloudSync) return;
    
    int offset = 0;
    int totalPushed = 0;
    int totalDeleted = 0;
    
    while (true) {
      final unsyncedRequests = await db.stockReplenishmentRequestsDao.getUnsyncedRequests(
        limit: batchSize,
        offset: offset,
      );
      
      if (unsyncedRequests.isEmpty) break;
      
      final List<Map<String, dynamic>> batchData = [];
      final List<int> syncedIds = [];
      final Map<int, String> cloudIdMap = {};
      
      for (final request in unsyncedRequests) {
        if (request.isDeleted && request.cloudId != null) {
          try {
            await supabase
              .from('stock_replenishment_requests')
              .delete()
              .eq('cloud_id', request.cloudId!);
            syncedIds.add(request.id);
            totalDeleted++;
          } catch (e) {
            print('   ⚠️ Failed to delete request ${request.id}: $e');
          }
        } else if (!request.isDeleted) {
          final cloudId = request.cloudId ?? _uuid.v4();
          cloudIdMap[request.id] = cloudId;
          
          batchData.add({
            'local_id': request.id,
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
        try {
          await supabase.from('stock_replenishment_requests').upsert(batchData);
        } catch (e) {
          print('   ⚠️ Request batch upsert failed: $e');
        }
      }
      
      if (syncedIds.isNotEmpty) {
        await db.stockReplenishmentRequestsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }
      
      offset += batchSize;
    }
    
    if (totalPushed > 0) {
      print('   ✔ Pushed $totalPushed stock replenishment requests');
    }
    if (totalDeleted > 0) {
      print('   ✔ Deleted $totalDeleted stock replenishment requests from cloud');
    }
  }

  Future<void> _pullStockReplenishmentRequests() async {
    if (!enableCloudSync) return;
    
    try {
      final cloudRequests = await supabase
        .from('stock_replenishment_requests')
        .select()
        .order('last_updated', ascending: false)
        .limit(1000);
      
      if (cloudRequests.isNotEmpty) {
        await db.stockReplenishmentRequestsDao.upsertBatchFromCloud(cloudRequests);
        print('   ✔ Pulled ${cloudRequests.length} stock replenishment requests');
      }
    } catch (e) {
      print('   ⚠️ Failed to pull stock replenishment requests: $e');
    }
  }

  // ==========================================================================
  // STOCK CHANGE REQUESTS SYNC
  // ==========================================================================

  Future<void> syncStockChangeRequests() async {
    if (!enableCloudSync) return;
    
    try {
      print('✏️ Syncing stock change requests...');
      await _pushStockChangeRequests();
      await _pullStockChangeRequests();
      print('   ✅ Stock change requests sync complete');
    } catch (e) {
      print('   ❌ Stock change requests sync failed: $e');
    }
  }

  Future<void> _pushStockChangeRequests() async {
    if (!enableCloudSync) return;
    
    int offset = 0;
    int totalPushed = 0;
    int totalDeleted = 0;
    
    while (true) {
      final unsyncedRequests = await db.stockChangeRequestsDao.getUnsyncedChangeRequests(
        limit: batchSize,
        offset: offset,
      );
      
      if (unsyncedRequests.isEmpty) break;
      
      final List<Map<String, dynamic>> batchData = [];
      final List<int> syncedIds = [];
      final Map<int, String> cloudIdMap = {};
      
      for (final request in unsyncedRequests) {
        if (request.isDeleted && request.cloudId != null) {
          try {
            await supabase
              .from('stock_change_requests')
              .delete()
              .eq('cloud_id', request.cloudId!);
            syncedIds.add(request.id);
            totalDeleted++;
          } catch (e) {
            print('   ⚠️ Failed to delete change request ${request.id}: $e');
          }
        } else if (!request.isDeleted) {
          final cloudId = request.cloudId ?? _uuid.v4();
          cloudIdMap[request.id] = cloudId;
          
          batchData.add({
            'local_id': request.id,
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
        try {
          await supabase.from('stock_change_requests').upsert(batchData);
        } catch (e) {
          print('   ⚠️ Change request batch upsert failed: $e');
        }
      }
      
      if (syncedIds.isNotEmpty) {
        await db.stockChangeRequestsDao.markAsSynced(syncedIds, cloudIds: cloudIdMap);
      }
      
      offset += batchSize;
    }
    
    if (totalPushed > 0) {
      print('   ✔ Pushed $totalPushed stock change requests');
    }
    if (totalDeleted > 0) {
      print('   ✔ Deleted $totalDeleted stock change requests from cloud');
    }
  }

  Future<void> _pullStockChangeRequests() async {
    if (!enableCloudSync) return;
    
    try {
      final cloudRequests = await supabase
        .from('stock_change_requests')
        .select()
        .order('last_updated', ascending: false)
        .limit(1000);
      
      if (cloudRequests.isNotEmpty) {
        await db.stockChangeRequestsDao.upsertBatchFromCloud(cloudRequests);
        print('   ✔ Pulled ${cloudRequests.length} stock change requests');
      }
    } catch (e) {
      print('   ⚠️ Failed to pull stock change requests: $e');
    }
  }

  // ==========================================================================
  // ITEMS SYNC (UPDATED for new columns)
  // ==========================================================================

  Future<void> syncItems() async {
    if (!enableCloudSync) return;
    
    try {
      print('📦 Syncing items...');
      await _pushItems();
      await _pullItems();
      print('   ✅ Items sync complete');
    } catch (e) {
      print('   ❌ Items sync failed: $e');
      rethrow;
    }
  }

  Future<void> _pushItems() async {
    if (!enableCloudSync) return;
    
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
            await supabase
                .from('items')
                .delete()
                .eq('cloud_id', item.cloudId!);

            syncedIds.add(item.id);
            totalDeleted++;
          } catch (e) {
            print('   ⚠️ Failed to delete item ${item.id}: $e');
          }
        } else if (!item.isDeleted) {
          final cloudId = item.cloudId ?? _uuid.v4();
          cloudIdMap[item.id] = cloudId;

          batchData.add({
            'local_id': item.id,
            'cloud_id': cloudId,
            'name': item.name,
            'organization_id': item.organizationId,
            'category_id': item.categoryId,
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
        try {
          await supabase.from('items').upsert(batchData);
          totalPushed += batchData.length;
        } catch (e) {
          print('   ⚠️ Batch upsert failed: $e');
        }
      }

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
    if (!enableCloudSync) return;
    
    try {
      final cloudItems = await supabase
        .from('items')
        .select()
        .order('last_updated', ascending: false)
        .limit(1000);
      
      if (cloudItems.isNotEmpty) {
        //await db.itemsDao.upsertBatchFromCloud(cloudItems);
        print('   ✔ Pulled ${cloudItems.length} items');
      }
    } catch (e) {
      print('   ⚠️ Failed to pull items: $e');
    }
  }

  // ==========================================================================
  // USERS SYNC (UPDATED for new columns)
  // ==========================================================================

  Future<void> syncUsers() async {
    if (!enableCloudSync) return;
    
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
    if (!enableCloudSync) return;
    
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
            print('   ⚠️ Failed to delete user ${user.id}: $e');
          }
          continue;
        }
        
        if (user.isActive) {
          final cloudId = user.cloudId ?? _uuid.v4();
          cloudIdMap[user.id] = cloudId;
          
          batchData.add({
            'local_id': user.id,
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
    if (!enableCloudSync) return;
    
    try {
      final cloudUsers = await supabase
        .from('users')
        .select()
        .order('last_updated', ascending: false)
        .limit(1000);
      
      if (cloudUsers.isNotEmpty) {
        //await db.usersDao.upsertBatchFromCloud(cloudUsers);
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
    if (!enableCloudSync) return;
    
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
    if (!enableCloudSync) return;
    
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
            print('   ⚠️ Failed to delete role ${role.id}: $e');
          }
          continue;
        }
        
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
    if (!enableCloudSync) return;
    
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
    if (!enableCloudSync) return;
    
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
    if (!enableCloudSync) return;
    // Categories sync needs isSynced and cloudId columns
    print('   ℹ️ Category push not yet fully implemented (needs sync fields)');
  }

  Future<void> _pullCategories() async {
    if (!enableCloudSync) return;
    // Categories sync needs isSynced and cloudId columns
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

  /// ✅ Get sync status with detailed counts
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      if (!enableCloudSync) {
        return {
          'mode': 'offline',
          'is_syncing': false,
          'message': 'Cloud sync is disabled',
        };
      }
      
      final unsyncedItemCount = await db.itemsDao.getUnsyncedItemCount();
      final unsyncedUserCount = await db.usersDao.getUnsyncedUserCount();
      final unsyncedRoleCount = await db.rolesDao.getUnsyncedRoleCount();
      final unsyncedOrgCount = await db.organizationsDao.getUnsyncedOrganizationCount();
      final unsyncedIngredientCount = await db.ingredientsDao.getUnsyncedIngredientCount();
      final unsyncedRecipeIngredientCount = await db.recipeIngredientsDao.getUnsyncedRecipeIngredientCount();
      final unsyncedReplenishmentCount = await db.stockReplenishmentRequestsDao.getUnsyncedRequestCount();
      final unsyncedChangeCount = await db.stockChangeRequestsDao.getUnsyncedChangeRequestCount();
      
      final totalUnsynced = unsyncedItemCount + unsyncedUserCount + unsyncedRoleCount +
          unsyncedOrgCount + unsyncedIngredientCount + unsyncedRecipeIngredientCount +
          unsyncedReplenishmentCount + unsyncedChangeCount;
      
      return {
        'unsynced_organizations': unsyncedOrgCount,
        'unsynced_items': unsyncedItemCount,
        'unsynced_users': unsyncedUserCount,
        'unsynced_roles': unsyncedRoleCount,
        'unsynced_ingredients': unsyncedIngredientCount,
        'unsynced_recipe_ingredients': unsyncedRecipeIngredientCount,
        'unsynced_replenishment_requests': unsyncedReplenishmentCount,
        'unsynced_change_requests': unsyncedChangeCount,
        'total_unsynced': totalUnsynced,
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

  /// ✅ Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    print('🛑 Sync service disposed');
  }
}