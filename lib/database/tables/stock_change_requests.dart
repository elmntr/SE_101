// lib/database/tables/stock_change_requests.dart
import 'package:drift/drift.dart';
import 'items.dart';
import 'organizations.dart';
import 'users.dart';

/// StockChangeRequests table - Employee requests stock changes, Franchisee approves/rejects
class StockChangeRequests extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get franchiseeId => integer().references(Organizations, #id)();

  IntColumn get itemId => integer().references(Items, #id)();

  TextColumn get changeType => text().withLength(min: 3, max: 50)();

  IntColumn get quantity => integer()();

  TextColumn get status =>
      text().withLength(min: 3, max: 50).withDefault(const Constant('draft'))();

  /// ✅ FIXED: Added @ReferenceName to distinguish requester vs reviewer
  @ReferenceName('changeRequester')
  IntColumn get requestedBy => integer().references(Users, #id)();

  DateTimeColumn get requestedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();

  DateTimeColumn get submittedAt => dateTime().nullable()();

  @ReferenceName('changeReviewer')
  IntColumn get reviewedBy => integer().nullable().references(Users, #id)();

  DateTimeColumn get reviewedAt => dateTime().nullable()();

  TextColumn get reason => text().nullable().withLength(max: 1000)();

  TextColumn get reviewNotes => text().nullable().withLength(max: 1000)();

  IntColumn get originalStock => integer()();

  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get lastUpdated =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get cloudId => text().nullable()();
}
