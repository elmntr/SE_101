// lib/database/daos/items_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/items.dart';
import '../tables/categories.dart';
import '../models/item_with_category.dart';

part 'items_dao.g.dart';

@DriftAccessor(tables: [Items, Categories])
class ItemsDao extends DatabaseAccessor<AppDatabase> with _$ItemsDaoMixin {
  ItemsDao(AppDatabase db) : super(db);

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
      final query = select(items)
        ..where((t) => t.isDeleted.equals(false));
      
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
              return OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc);
            case ItemSortOrder.oldestFirst:
              return OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc);
          }
        }
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
  Future<int> getItemCount({
    String? searchQuery,
    int? categoryId,
  }) async {
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
  Future<List<Item>> getUnsyncedItems({
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      return await (select(items)
        ..where((t) => t.isSynced.equals(false))
        ..limit(limit, offset: offset))
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
      ])
        ..where(items.isDeleted.equals(false));

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
      final query = select(items).join([
        leftOuterJoin(categories, categories.id.equalsExp(items.categoryId)),
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

  /// ✅ Insert a new item with error handling
  Future<int> insertItem({
    required String name, 
    int stock = 0,
    int? categoryId,
    String? cloudId,
  }) async {
    try {
      return await into(items).insert(
        ItemsCompanion.insert(
          name: name,
          categoryId: Value(categoryId),
          stock: Value(stock),
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
      return await (select(items)
        ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching item by ID: $e');
      return null;
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
      final result = await (update(items)..where((t) => t.id.equals(id)))
        .write(ItemsCompanion(
          isDeleted: Value(true),
          isSynced: Value(false), // Mark for sync to delete from cloud
          lastUpdated: Value(DateTime.now()),
        ));
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
      // First, mark as deleted and unsynced so sync service knows to delete from cloud
      final item = await getItemById(id);
      if (item == null) {
        print('⚠️ Item $id not found');
        return false;
      }

      // If item has cloudId, mark for sync deletion first
      if (item.cloudId != null && !item.isDeleted) {
        await softDeleteItem(id);
        print('📤 Item $id marked for cloud deletion (cloudId: ${item.cloudId})');
      }
      
      // Then permanently delete from local database
      final result = await (delete(items)..where((t) => t.id.equals(id))).go();
      
      if (result > 0) {
        print('✅ Item $id permanently deleted from local database');
      }
      
      return result > 0;
    } catch (e) {
      print('❌ Error deleting item: $e');
      return false;
    }
  }

  /// ✅ Mark items as synced (batch operation)
  Future<void> markAsSynced(List<int> itemIds, {Map<int, String>? cloudIds}) async {
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
  Future<void> upsertBatchFromCloud(List<Map<String, dynamic>> cloudItems) async {
    try {
      await db.transaction(() async {
        for (final cloudItem in cloudItems) {
          await upsertFromCloud(
            id: cloudItem['local_id'],
            name: cloudItem['name'],
            stock: cloudItem['stock'],
            sold: cloudItem['sold'] ?? 0,
            spoilage: cloudItem['spoilage'] ?? 0,
            categoryId: cloudItem['category_id'],
            createdAt: DateTime.parse(cloudItem['created_at']),
            lastUpdated: DateTime.parse(cloudItem['last_updated']),
            isDeleted: cloudItem['is_deleted'] ?? false,
            cloudId: cloudItem['cloud_id'],
          );
        }
      });
    } catch (e) {
      print('❌ Error batch upserting from cloud: $e');
      rethrow;
    }
  }

  /// ✅ Upsert from cloud (individual)
  Future<void> upsertFromCloud({
    required int id,
    required String name,
    required int stock,
    required int sold,
    required int spoilage,
    int? categoryId,
    required DateTime createdAt,
    required DateTime lastUpdated,
    required bool isDeleted,
    required String cloudId,
  }) async {
    try {
      await into(items).insertOnConflictUpdate(
        ItemsCompanion.insert(
          id: Value(id),
          name: name,
          categoryId: Value(categoryId),
          stock: Value(stock),
          sold: Value(sold),
          spoilage: Value(spoilage),
          createdAt: Value(createdAt),
          lastUpdated: Value(lastUpdated),
          isDeleted: Value(isDeleted),
          isSynced: Value(true),
          cloudId: Value(cloudId),
        ),
      );
    } catch (e) {
      print('❌ Error upserting item from cloud: $e');
      rethrow;
    }
  }

  /// ✅ Get item by cloud ID
  Future<Item?> getItemByCloudId(String cloudId) async {
    try {
      return await (select(items)..where((t) => t.cloudId.equals(cloudId)))
        .getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching item by cloud ID: $e');
      return null;
    }
  }

  /// ✅ Get low stock items (useful for alerts)
  Future<List<Item>> getLowStockItems(int threshold) async {
    try {
      return await (select(items)
        ..where((t) => 
          t.isDeleted.equals(false) & 
          t.stock.isSmallerThanValue(threshold))
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
      final result = await (delete(items)
        ..where((t) => t.isDeleted.equals(true) & t.isSynced.equals(true)))
        .go();
      
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