// lib/database/daos/items_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/items.dart';
import '../tables/categories.dart';
import '../models/item_with_category.dart';
import '../tables/organizations.dart';

part 'items_dao.g.dart';

@DriftAccessor(tables: [Items, Categories, Organizations])
class ItemsDao extends DatabaseAccessor<AppDatabase> with _$ItemsDaoMixin {
  ItemsDao(super.db);

  // ✅ Pagination parameters
  static const int defaultPageSize = 50;
  static const int maxPageSize = 100;

  /// ✅ Get items with pagination
  Future<List<Item>> getAllItems({
    int? limit,
    int offset = 0,
    String? searchQuery,
    int? categoryId,
    ItemSortOrder sortOrder = ItemSortOrder.nameAsc,
  }) async {
    try {
      final query = select(items)..where((t) => t.isDeleted.equals(false));

      // Search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query.where((t) => t.name.contains(searchQuery));
      }

      // Category filter
      if (categoryId != null) {
        query.where((t) => t.categoryId.equals(categoryId));
      }

      // Sorting
      query.orderBy([
        (t) {
          switch (sortOrder) {
            case ItemSortOrder.nameAsc:
              return OrderingTerm(expression: t.name, mode: OrderingMode.asc);
            case ItemSortOrder.nameDesc:
              return OrderingTerm(expression: t.name, mode: OrderingMode.desc);
            case ItemSortOrder.stockAsc:
              return OrderingTerm(expression: t.stock, mode: OrderingMode.asc);
            case ItemSortOrder.stockDesc:
              return OrderingTerm(expression: t.stock, mode: OrderingMode.desc);
            case ItemSortOrder.newestFirst:
              return OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.desc,
              );
            case ItemSortOrder.oldestFirst:
              return OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.asc,
              );
          }
        },
      ]);

      // Pagination
      if (limit != null) {
        final safeLimit = limit > maxPageSize ? maxPageSize : limit;
        query.limit(safeLimit, offset: offset);
      }

      return await query.get();
    } catch (e) {
      print('❌ Error fetching items: $e');
      rethrow;
    }
  }

  /// ✅ Get total count for pagination
  Future<int> getItemCount({String? searchQuery, int? categoryId}) async {
    try {
      final query = selectOnly(items)
        ..addColumns([items.id.count()])
        ..where(items.isDeleted.equals(false));

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query.where(items.name.contains(searchQuery));
      }

      if (categoryId != null) {
        query.where(items.categoryId.equals(categoryId));
      }

      final result = await query.getSingle();
      return result.read(items.id.count()) ?? 0;
    } catch (e) {
      print('❌ Error counting items: $e');
      return 0;
    }
  }

  /// ✅ Watch items with pagination (for UI)
  Stream<List<Item>> watchAllItems({
    int limit = defaultPageSize,
    int offset = 0,
  }) {
    try {
      final query = select(items)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm(expression: t.name)])
        ..limit(limit, offset: offset);

      return query.watch();
    } catch (e) {
      print('❌ Error watching items: $e');
      return Stream.value([]);
    }
  }

  /// ✅ Get unsynced items with pagination for efficient sync
  Future<List<Item>> getUnsyncedItems({int limit = 100, int offset = 0}) async {
    try {
      return await (select(items)
            ..where((t) => t.isSynced.equals(false))
            ..limit(limit))
          .get();
    } catch (e) {
      print('❌ Error fetching unsynced items: $e');
      return [];
    }
  }

  /// ✅ Count unsynced items
  Future<int> getUnsyncedItemCount() async {
    try {
      final query = selectOnly(items)
        ..addColumns([items.id.count()])
        ..where(items.isSynced.equals(false));

      final result = await query.getSingle();
      return result.read(items.id.count()) ?? 0;
    } catch (e) {
      print('❌ Error counting unsynced items: $e');
      return 0;
    }
  }

  /// ✅ Get items with categories (paginated)
  Future<List<ItemWithCategory>> getItemsWithCategories({
    int? limit,
    int offset = 0,
    String? searchQuery,
    int? categoryId,
  }) async {
    try {
      final query = select(items).join([
        leftOuterJoin(categories, categories.id.equalsExp(items.categoryId)),
      ])..where(items.isDeleted.equals(false));

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query.where(items.name.contains(searchQuery));
      }

      if (categoryId != null) {
        query.where(items.categoryId.equals(categoryId));
      }

      query.orderBy([OrderingTerm(expression: items.name)]);

      if (limit != null) {
        query.limit(limit, offset: offset);
      }

      final results = await query.get();
      return results.map((row) {
        final item = row.readTable(items);
        final category = row.readTableOrNull(categories);
        return ItemWithCategory(item: item, category: category);
      }).toList();
    } catch (e) {
      print('❌ Error fetching items with categories: $e');
      return [];
    }
  }

  /// ✅ Watch items with categories (paginated)
  Stream<List<ItemWithCategory>> watchItemsWithCategories({
    int limit = defaultPageSize,
    int offset = 0,
  }) {
    try {
      final query =
          select(items).join([
              leftOuterJoin(
                categories,
                categories.id.equalsExp(items.categoryId),
              ),
            ])
            ..where(items.isDeleted.equals(false))
            ..orderBy([OrderingTerm(expression: items.name)])
            ..limit(limit, offset: offset);

      return query.watch().map((rows) {
        return rows.map((row) {
          final item = row.readTable(items);
          final category = row.readTableOrNull(categories);
          return ItemWithCategory(item: item, category: category);
        }).toList();
      });
    } catch (e) {
      print('❌ Error watching items with categories: $e');
      return Stream.value([]);
    }
  }

  /// ✅ Get item by name (case-insensitive)
  Future<Item?> getItemByName(
    String name, {
    int? organizationId,
  }) async {
    try {
      final query = select(items)
        ..where((t) => t.name.lower().equals(name.toLowerCase()) & t.isDeleted.equals(false));

      if (organizationId != null) {
        query.where((t) => t.organizationId.equals(organizationId));
      }

      return await query.getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching item by name: $e');
      return null;
    }
  }

  /// ✅ Insert a new item with error handling
  /// Throws an exception if an item with the same name already exists in the organization
  Future<int> insertItem({
    required String name,
    required int organizationId, // ✅ NEW - Required
    int stock = 0,
    int? categoryId,
    int? masterItemId, // ✅ NEW - For franchisee items
    double? price, // ✅ NEW - Franchisee's selling price
    double? costPrice, // ✅ NEW - Cost from commissary
    String? unit, // ✅ NEW - Unit of measurement
    int? minimumStock, // ✅ NEW - Low stock threshold
    String? description, // ✅ NEW - Item description
    String? cloudId,
  }) async {
    try {
      // Check for duplicate item name within the organization
      final existingItem = await getItemByName(
        name,
        organizationId: organizationId,
      );
      if (existingItem != null) {
        throw Exception('A product with the name "$name" already exists');
      }

      return await into(items).insert(
        ItemsCompanion.insert(
          name: name,
          organizationId: organizationId, // ✅ NEW
          categoryId: Value(categoryId),
          masterItemId: Value(masterItemId), // ✅ NEW
          stock: Value(stock),
          price: Value(price), // ✅ NEW
          costPrice: Value(costPrice), // ✅ NEW
          unit: Value(unit ?? 'piece'), // ✅ NEW with default
          minimumStock: Value(minimumStock), // ✅ NEW
          description: Value(description), // ✅ NEW
          isSynced: Value(false),
          cloudId: Value(cloudId),
        ),
      );
    } catch (e) {
      print('❌ Error inserting item: $e');
      rethrow;
    }
  }

  /// ✅ Batch insert for efficiency
  Future<void> insertItems(List<ItemsCompanion> itemsList) async {
    try {
      await db.batch((batch) {
        batch.insertAll(items, itemsList);
      });
    } catch (e) {
      print('❌ Error batch inserting items: $e');
      rethrow;
    }
  }

  /// ✅ Update an existing item
  Future<bool> updateItem(Item item) async {
    try {
      final updated = item.copyWith(
        isSynced: false,
        lastUpdated: DateTime.now(),
      );
      return await update(items).replace(updated);
    } catch (e) {
      print('❌ Error updating item: $e');
      return false;
    }
  }

  /// ✅ Get item by ID
  Future<Item?> getItemById(int id) async {
    try {
      return await (select(
        items,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching item by ID: $e');
      return null;
    }
  }

  Future<List<Item>> getItemsByOrganization(
    int organizationId, {
    int? limit,
    int offset = 0,
  }) async {
    try {
      final query = select(items)
        ..where(
          (t) =>
              t.organizationId.equals(organizationId) &
              t.isDeleted.equals(false),
        )
        ..orderBy([(t) => OrderingTerm(expression: t.name)]);

      if (limit != null) {
        query.limit(limit, offset: offset);
      }

      return await query.get();
    } catch (e) {
      print('❌ Error fetching items by organization: $e');
      return [];
    }
  }

  /// ✅ Get franchisee items (items with masterItemId)
  Future<List<Item>> getFranchiseeItems(int franchiseeId) async {
    try {
      return await (select(items)
            ..where(
              (t) =>
                  t.organizationId.equals(franchiseeId) &
                  t.masterItemId.isNotNull() &
                  t.isDeleted.equals(false),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.name)]))
          .get();
    } catch (e) {
      print('❌ Error fetching franchisee items: $e');
      return [];
    }
  }

  /// ✅ Get commissary master items (items without masterItemId)
  Future<List<Item>> getCommissaryMasterItems(int commissaryId) async {
    try {
      return await (select(items)
            ..where(
              (t) =>
                  t.organizationId.equals(commissaryId) &
                  t.masterItemId.isNull() &
                  t.isDeleted.equals(false),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.name)]))
          .get();
    } catch (e) {
      print('❌ Error fetching commissary master items: $e');
      return [];
    }
  }

  /// ✅ Assign category to item
  Future<bool> assignCategory(int itemId, int? categoryId) async {
    try {
      final result = await (update(items)..where((t) => t.id.equals(itemId)))
          .write(
            ItemsCompanion(
              categoryId: Value(categoryId),
              lastUpdated: Value(DateTime.now()),
              isSynced: Value(false),
            ),
          );
      return result > 0;
    } catch (e) {
      print('❌ Error assigning category: $e');
      return false;
    }
  }

  /// ✅ ATOMIC: Add sold quantity and deduct from stock (single query)
  Future<bool> addSold(int itemId, int quantity) async {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be positive');
    }

    try {
      // ✅ Use SQL expression for atomic update
      final result = await customUpdate(
        'UPDATE items SET '
        'sold = sold + ?, '
        'stock = stock - ?, '
        'last_updated = ?, '
        'is_synced = 0 '
        'WHERE id = ? AND stock >= ?',
        updates: {items},
        variables: [
          Variable.withInt(quantity),
          Variable.withInt(quantity),
          Variable.withDateTime(DateTime.now()),
          Variable.withInt(itemId),
          Variable.withInt(quantity),
        ],
      );

      if (result == 0) {
        print('⚠️ Insufficient stock for item $itemId');
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Error adding sold: $e');
      return false;
    }
  }

  /// ✅ ATOMIC: Add spoilage quantity and deduct from stock
  Future<bool> addSpoilage(int itemId, int quantity) async {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be positive');
    }

    try {
      final result = await customUpdate(
        'UPDATE items SET '
        'spoilage = spoilage + ?, '
        'stock = stock - ?, '
        'last_updated = ?, '
        'is_synced = 0 '
        'WHERE id = ? AND stock >= ?',
        updates: {items},
        variables: [
          Variable.withInt(quantity),
          Variable.withInt(quantity),
          Variable.withDateTime(DateTime.now()),
          Variable.withInt(itemId),
          Variable.withInt(quantity),
        ],
      );

      if (result == 0) {
        print('⚠️ Insufficient stock for item $itemId');
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Error adding spoilage: $e');
      return false;
    }
  }

  /// ✅ ATOMIC: Add stock (for replenishment)
  Future<bool> addStock(int itemId, int quantity) async {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be positive');
    }

    try {
      final result = await customUpdate(
        'UPDATE items SET '
        'stock = stock + ?, '
        'last_updated = ?, '
        'is_synced = 0 '
        'WHERE id = ?',
        updates: {items},
        variables: [
          Variable.withInt(quantity),
          Variable.withDateTime(DateTime.now()),
          Variable.withInt(itemId),
        ],
      );

      return result > 0;
    } catch (e) {
      print('❌ Error adding stock: $e');
      return false;
    }
  }

  /// ✅ Update stock directly (with validation)
  Future<bool> updateStock(int itemId, int newStock) async {
    if (newStock < 0) {
      throw ArgumentError('Stock cannot be negative');
    }

    try {
      final result = await (update(items)..where((t) => t.id.equals(itemId)))
          .write(
            ItemsCompanion(
              stock: Value(newStock),
              lastUpdated: Value(DateTime.now()),
              isSynced: Value(false),
            ),
          );
      return result > 0;
    } catch (e) {
      print('❌ Error updating stock: $e');
      return false;
    }
  }

  /// ✅ Soft delete item (marks as deleted, will be cleaned up by sync)
  Future<bool> softDeleteItem(int id) async {
    try {
      final result = await (update(items)..where((t) => t.id.equals(id))).write(
        ItemsCompanion(
          isDeleted: Value(true),
          isSynced: Value(false), // Mark for sync to delete from cloud
          lastUpdated: Value(DateTime.now()),
        ),
      );
      return result > 0;
    } catch (e) {
      print('❌ Error soft deleting item: $e');
      return false;
    }
  }

  /// ✅ PERMANENT DELETE: Hard-delete item from local database
  /// Note: Cloud deletion is handled by sync service when it detects isDeleted=true
  Future<bool> deleteItem(int id) async {
    try {
      final result = await (update(items)..where((t) => t.id.equals(id))).write(
        ItemsCompanion(
          isDeleted: const Value(true),
          isSynced: const Value(false),
          lastUpdated: Value(DateTime.now()),
        ),
      );

      return result > 0;
    } catch (e) {
      print('❌ Error soft deleting item: $e');
      return false;
    }
  }

  /// ✅ Mark items as synced (batch operation)
  Future<void> markAsSynced(
    List<int> itemIds, {
    Map<int, String>? cloudIds,
  }) async {
    try {
      await db.batch((batch) {
        for (final id in itemIds) {
          batch.update(
            items,
            ItemsCompanion(
              isSynced: Value(true),
              cloudId: Value(cloudIds?[id]),
            ),
            where: (t) => t.id.equals(id),
          );
        }
      });
    } catch (e) {
      print('❌ Error marking items as synced: $e');
      rethrow;
    }
  }

  /// ✅ Batch upsert from cloud
  /// ✅ FIXED: Batch upsert from cloud with ALL new columns
  /// Uses cloud_id for conflict resolution, not local_id
  Future<void> upsertBatchFromCloud(
    List<Map<String, dynamic>> cloudItems,
  ) async {
    try {
      await db.transaction(() async {
        for (final cloudItem in cloudItems) {
          // Map Supabase column names to local column names
          final stockValue = cloudItem['stock'];
          final criticalLevel = cloudItem['critical_level'] ?? cloudItem['minimum_stock'];
          final costValue = cloudItem['cost'] ?? cloudItem['cost_price'];
          
          await upsertFromCloud(
            cloudId: cloudItem['cloud_id'],
            name: cloudItem['name'],
            organizationId: cloudItem['organization_id'],
            stock: stockValue is num ? stockValue.toInt() : 0,
            sold: (cloudItem['sold'] as num?)?.toInt() ?? 0,
            spoilage: (cloudItem['spoilage'] as num?)?.toInt() ?? 0,
            categoryId: cloudItem['category_id'],
            masterItemId: cloudItem['master_item_id'],
            price: cloudItem['price'] is String 
                ? double.tryParse(cloudItem['price']) 
                : (cloudItem['price'] as num?)?.toDouble(),
            costPrice: costValue is String
                ? double.tryParse(costValue)
                : (costValue as num?)?.toDouble(),
            unit: cloudItem['unit'],
            minimumStock: criticalLevel is num ? criticalLevel.toInt() : null,  // Map critical_level
            description: cloudItem['description'],
            createdAt: DateTime.parse(cloudItem['created_at']),
            lastUpdated: DateTime.parse(cloudItem['last_updated']),
            isDeleted: cloudItem['is_deleted'] ?? (cloudItem['is_active'] == false),
          );
        }
      });
    } catch (e) {
      print('❌ Error batch upserting from cloud: $e');
      rethrow;
    }
  }

  /// Upsert a single item from cloud using cloud_id for conflict resolution
  Future<void> upsertFromCloud({
    required String cloudId,
    required String name,
    required int organizationId, // ✅ NEW
    required int stock,
    required int sold,
    required int spoilage,
    int? categoryId,
    int? masterItemId, // ✅ NEW
    double? price, // ✅ NEW
    double? costPrice, // ✅ NEW
    String? unit, // ✅ NEW
    int? minimumStock, // ✅ NEW
    String? description, // ✅ NEW
    required DateTime createdAt,
    required DateTime lastUpdated,
    required bool isDeleted,
  }) async {
    try {
      // First check if item exists by cloud_id
      final existing = await getItemByCloudId(cloudId);
      
      if (existing != null) {
        // Update existing item
        await (update(items)..where((t) => t.cloudId.equals(cloudId))).write(
          ItemsCompanion(
            name: Value(name),
            organizationId: Value(organizationId),
            categoryId: Value(categoryId),
            masterItemId: Value(masterItemId),
            stock: Value(stock),
            sold: Value(sold),
            spoilage: Value(spoilage),
            price: Value(price),
            costPrice: Value(costPrice),
            unit: Value(unit ?? 'piece'),
            minimumStock: Value(minimumStock),
            description: Value(description),
            createdAt: Value(createdAt),
            lastUpdated: Value(lastUpdated),
            isDeleted: Value(isDeleted),
            isSynced: Value(true),
          ),
        );
      } else {
        // Insert new item (let database auto-generate id)
        await into(items).insert(
          ItemsCompanion.insert(
            name: name,
            organizationId: organizationId,
            categoryId: Value(categoryId),
            masterItemId: Value(masterItemId),
            stock: Value(stock),
            sold: Value(sold),
            spoilage: Value(spoilage),
            price: Value(price),
            costPrice: Value(costPrice),
            unit: Value(unit ?? 'piece'),
            minimumStock: Value(minimumStock),
            description: Value(description),
            createdAt: Value(createdAt),
            lastUpdated: Value(lastUpdated),
            isDeleted: Value(isDeleted),
            isSynced: Value(true),
            cloudId: Value(cloudId),
          ),
        );
      }
    } catch (e) {
      print('❌ Error upserting item from cloud: $e');
      rethrow;
    }
  }

  /// ✅ Get item by cloud ID
  Future<Item?> getItemByCloudId(String cloudId) async {
    try {
      return await (select(
        items,
      )..where((t) => t.cloudId.equals(cloudId))).getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching item by cloud ID: $e');
      return null;
    }
  }

  /// ✅ Get low stock items (useful for alerts)
  Future<List<Item>> getLowStockItems(int threshold) async {
    try {
      return await (select(items)
            ..where(
              (t) =>
                  t.isDeleted.equals(false) &
                  t.stock.isSmallerThanValue(threshold),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.stock)]))
          .get();
    } catch (e) {
      print('❌ Error fetching low stock items: $e');
      return [];
    }
  }

  /// ✅ Clean up locally deleted items (after cloud sync confirms deletion)
  Future<int> cleanupDeletedItems() async {
    try {
      final result = await (delete(
        items,
      )..where((t) => t.isDeleted.equals(true) & t.isSynced.equals(true))).go();

      if (result > 0) {
        print('🧹 Cleaned up $result deleted items from local database');
      }

      return result;
    } catch (e) {
      print('❌ Error cleaning up deleted items: $e');
      return 0;
    }
  }
}


/// ✅ Sorting options for items
enum ItemSortOrder {
  nameAsc,
  nameDesc,
  stockAsc,
  stockDesc,
  newestFirst,
  oldestFirst,
}
