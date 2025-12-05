// lib/database/daos/items_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/items.dart';

part 'items_dao.g.dart';

@DriftAccessor(tables: [Items])
class ItemsDao extends DatabaseAccessor<AppDatabase> with _$ItemsDaoMixin {
  ItemsDao(AppDatabase db) : super(db);

  // Query all non-deleted items
  Future<List<Item>> getAllItems() {
    return (select(items)..where((t) => t.isDeleted.equals(false))).get();
  }

  // Watch items for UI (optional but common)
  Stream<List<Item>> watchAllItems() {
    return (select(items)..where((t) => t.isDeleted.equals(false))).watch();
  }

  Future<int> insertItem(ItemsCompanion entry) => into(items).insert(entry);

  Future<bool> updateItem(Item item) => update(items).replace(item);

  // Future<int> softDeleteItem(int id) =>
  //     (update(items)..where((t) => t.id.equals(id))).write(const ItemsCompanion(isDeleted: Value(true)));

  // Hard delete (keep if you used it in original code — otherwise you can avoid calling it)
  Future<int> deleteItem(int id) => (delete(items)..where((t) => t.id.equals(id))).go();
}
