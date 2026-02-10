// lib/database/tables/stock_replenishment_requests.dart
import 'package:drift/drift.dart';
import 'items.dart';
import 'organizations.dart';
import 'users.dart';

/// StockReplenishmentRequests table - Franchisee requests items from Commissary
class StockReplenishmentRequests extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// ✅ FIXED: Added @ReferenceName to distinguish franchisee vs commissary
  @ReferenceName('franchiseeReplenishmentRequests')
  IntColumn get franchiseeId => integer().references(Organizations, #id)();

  @ReferenceName('commissaryReplenishmentRequests')
  IntColumn get commissaryId => integer().references(Organizations, #id)();

  IntColumn get itemId => integer().references(Items, #id)();

  IntColumn get quantityRequested => integer()();

  TextColumn get status => text()
      .withLength(min: 3, max: 50)
      .withDefault(const Constant('pending'))();

  /// ✅ FIXED: Added @ReferenceName to distinguish requester vs reviewer
  @ReferenceName('replenishmentRequester')
  IntColumn get requestedBy => integer().references(Users, #id)();

  DateTimeColumn get requestedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();

  @ReferenceName('replenishmentReviewer')
  IntColumn get reviewedBy => integer().nullable().references(Users, #id)();

  DateTimeColumn get reviewedAt => dateTime().nullable()();

  DateTimeColumn get deliveryDate => dateTime().nullable()();

  TextColumn get franchiseeNotes => text().nullable().withLength(max: 1000)();

  TextColumn get commissaryNotes => text().nullable().withLength(max: 1000)();

  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get lastUpdated =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get cloudId => text().nullable()();
}
