import 'package:drift/drift.dart';
import 'categories.dart'; // ✅ Import categories

class Items extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  IntColumn get sold => integer().withDefault(const Constant(0))();  // ✅ default 0
  IntColumn get spoilage => integer().withDefault(const Constant(0))(); // ✅ default 0
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get lastUpdated => dateTime().clientDefault(() => DateTime.now())();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get cloudId => text().nullable()();
}

