import 'package:drift/drift.dart';

class Items extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 255)();

  IntColumn get stock => integer().withDefault(const Constant(0))();

  IntColumn get sold => integer().withDefault(const Constant(0))();

  IntColumn get spoilage => integer().withDefault(const Constant(0))();

  DateTimeColumn get lastUpdated =>
      dateTime().withDefault(currentDateAndTime)();

  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
