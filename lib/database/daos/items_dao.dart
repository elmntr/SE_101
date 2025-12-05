// lib/database/daos/items_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/items.dart';

part 'items_dao.g.dart';

@DriftAccessor(tables: [Items])
class ItemsDao extends DatabaseAccessor<AppDatabase> with _$ItemsDaoMixin {
  ItemsDao(AppDatabase db) : super(db);

  /// Query all non-deleted items
  Future<List<Item>> getAllItems() async {
    final queryResult = await (select(items)..where((t) => t.isDeleted.equals(false))).get();
    return queryResult.map((row) => safeItemFromRow(row.toColumns(true))).toList();
  }

  /// Watch items for UI updates
  Stream<List<Item>> watchAllItems() {
    return (select(items)..where((t) => t.isDeleted.equals(false))).watch();
  }

  /// Insert a new item (compatible with .insert constructor)
  Future<int> insertItem({required String name, int stock = 0}) {
    return into(items).insert(
      ItemsCompanion.insert(
        name: name,
        stock: Value(stock),
      ),
    );
  }

  /// Update an existing item
  Future<bool> updateItem(Item item) => update(items).replace(item);

  /// Soft-delete item
  Future<int> softDeleteItem(int id) =>
      (update(items)..where((t) => t.id.equals(id)))
          .write(ItemsCompanion(isDeleted: Value(true)));

  /// Hard-delete item
  Future<int> deleteItem(int id) => (delete(items)..where((t) => t.id.equals(id))).go();

  /// Safely map database row to Item
  Item safeItemFromRow(Map<String, dynamic> data, {String? tablePrefix}) {
  final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';

  int readIntSafe(String key) {
    final value = data['$effectivePrefix$key'];
    if (value == null) return 0;
    return value is int ? value : int.tryParse(value.toString()) ?? 0;
  }

  DateTime readDateTimeSafe(String key) {
    final value = data['$effectivePrefix$key'];
    if (value == null) return DateTime.now();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  bool readBoolSafe(String key) {
    final value = data['$effectivePrefix$key'];
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    return value.toString() == 'true';
  }

  String readStringSafe(String key) {
  final value = data['$effectivePrefix$key'];

  if (value == null) return 'Unnamed';              // fallback if null
  if (value is String) return value;                // already a string
  if (value is Variable<String>) return value.value ?? 'Unnamed'; // unwrap Variable safely
  return value.toString();                          // fallback for other types
}


  return Item(
    id: readIntSafe('id'),
    name: readStringSafe('name'),   // use the new safe string reader
    stock: readIntSafe('stock'),
    sold: readIntSafe('sold'),
    spoilage: readIntSafe('spoilage'),
    createdAt: readDateTimeSafe('created_at'),
    lastUpdated: readDateTimeSafe('last_updated'),
    isSynced: readBoolSafe('is_synced'),
    isDeleted: readBoolSafe('is_deleted'),
  );
}

  
}
