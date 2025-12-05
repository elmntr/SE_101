// lib/database/tables/items.dart
import 'package:drift/drift.dart';

class Items extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 255)();

  // Optional description for better inventory tracking
  TextColumn get description => text().nullable().withLength(max: 1000)();

  // SKU/Barcode for product identification
  TextColumn get sku => text().nullable().withLength(max: 100)();

  // current stock count
  IntColumn get stock => integer().withDefault(const Constant(0))();

  // Separate creation and update timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();

  // Synced flag for remote sync processes
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  // Soft delete flag instead of hard deletes
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>>? get uniqueKeys => [
        {sku}, // SKU should be unique if provided
      ];
}
