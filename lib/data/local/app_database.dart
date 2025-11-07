import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables/items.dart';

part 'app_database.g.dart'; // generated file

@DriftDatabase(tables: [Items])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ---- CRUD Methods ----

  Future<List<Item>> getAllItems() => select(items).get();

  Stream<List<Item>> watchAllItems() => select(items).watch();

  Future<int> insertItem(ItemsCompanion item) => into(items).insert(item);

  Future<bool> updateItemData(Item item) => update(items).replace(item);

  Future<int> deleteItemById(int id) =>
      (delete(items)..where((t) => t.id.equals(id))).go();

  // Optional helper to clear db
  Future<void> clearAll() async {
    await delete(items).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'inventory.db'));
    return NativeDatabase.createInBackground(file);
  });
}
