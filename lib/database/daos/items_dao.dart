// lib/database/daos/items_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/items.dart';
import '../tables/categories.dart'; // ✅ Import categories
import '../models/item_with_category.dart';

part 'items_dao.g.dart';

@DriftAccessor(tables: [Items, Categories]) // ✅ Add Categories
class ItemsDao extends DatabaseAccessor<AppDatabase> with _$ItemsDaoMixin {
  ItemsDao(AppDatabase db) : super(db);

  /// Query all non-deleted items
  Future<List<Item>> getAllItems() async {
    return await (select(items)..where((t) => t.isDeleted.equals(false))).get();
  }

  /// Watch items for UI updates
  Stream<List<Item>> watchAllItems() {
    return (select(items)..where((t) => t.isDeleted.equals(false))).watch();
  }

  /// ✅ NEW: Get items with their category info
  Future<List<ItemWithCategory>> getItemsWithCategories() async {
    final query = select(items).join([
      leftOuterJoin(categories, categories.id.equalsExp(items.categoryId)),
    ])..where(items.isDeleted.equals(false));

    final results = await query.get();
    return results.map((row) {
      final item = row.readTable(items);
      final category = row.readTableOrNull(categories);
      return ItemWithCategory(item: item, category: category);
    }).toList();
  }

  /// ✅ NEW: Watch items with categories for real-time updates
  Stream<List<ItemWithCategory>> watchItemsWithCategories() {
    final query = select(items).join([
      leftOuterJoin(categories, categories.id.equalsExp(items.categoryId)),
    ])..where(items.isDeleted.equals(false));

    return query.watch().map((rows) {
      return rows.map((row) {
        final item = row.readTable(items);
        final category = row.readTableOrNull(categories);
        return ItemWithCategory(item: item, category: category);
      }).toList();
    });
  }

  /// Insert a new item with optional category
  Future<int> insertItem({
    required String name, 
    int stock = 0, 
    int? categoryId
  }) {
    return into(items).insert(
      ItemsCompanion.insert(
        name: name,
        stock: Value(stock),
        categoryId: Value(categoryId), // ✅ Add category
      ),
    );
  }

  /// Update an existing item
  Future<bool> updateItem(Item item) => update(items).replace(item);

  /// ✅ NEW: Assign category to item
  Future<int> assignCategory(int itemId, int? categoryId) {
    return (update(items)..where((t) => t.id.equals(itemId))).write(
      ItemsCompanion(
        categoryId: Value(categoryId),
        lastUpdated: Value(DateTime.now()),
      ),
    );
  }

  /// Add sold quantity and deduct from stock
  Future<int> addSold(int itemId, int quantity) async {
    final item = await (select(items)..where((t) => t.id.equals(itemId))).getSingle();
    
    return (update(items)..where((t) => t.id.equals(itemId))).write(
      ItemsCompanion(
        sold: Value(item.sold + quantity),
        stock: Value(item.stock - quantity),
        lastUpdated: Value(DateTime.now()),
      ),
    );
  }

  /// Add spoilage quantity and deduct from stock
  Future<int> addSpoilage(int itemId, int quantity) async {
    final item = await (select(items)..where((t) => t.id.equals(itemId))).getSingle();
    
    return (update(items)..where((t) => t.id.equals(itemId))).write(
      ItemsCompanion(
        spoilage: Value(item.spoilage + quantity),
        stock: Value(item.stock - quantity),
        lastUpdated: Value(DateTime.now()),
      ),
    );
  }

  /// Update stock directly (for adding new stock/replenishment)
  Future<int> updateStock(int itemId, int newStock) async {
    return (update(items)..where((t) => t.id.equals(itemId))).write(
      ItemsCompanion(
        stock: Value(newStock),
        lastUpdated: Value(DateTime.now()),
      ),
    );
  }

  /// Add stock (for replenishment)
  Future<int> addStock(int itemId, int quantity) async {
    final item = await (select(items)..where((t) => t.id.equals(itemId))).getSingle();
    
    return (update(items)..where((t) => t.id.equals(itemId))).write(
      ItemsCompanion(
        stock: Value(item.stock + quantity),
        lastUpdated: Value(DateTime.now()),
      ),
    );
  }

  /// Soft-delete item
  Future<int> softDeleteItem(int id) =>
      (update(items)..where((t) => t.id.equals(id)))
          .write(ItemsCompanion(isDeleted: Value(true)));

  /// Hard-delete item
  Future<int> deleteItem(int id) => (delete(items)..where((t) => t.id.equals(id))).go();
}