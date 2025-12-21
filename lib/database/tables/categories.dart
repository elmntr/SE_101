// lib/database/tables/categories.dart
import 'package:drift/drift.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 100).unique()();

  TextColumn get description => text().nullable().withLength(max: 500)();

  // Track when category was created/modified
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get lastUpdated =>
      dateTime().clientDefault(() => DateTime.now())();

  // Soft delete
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  
}
