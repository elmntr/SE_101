// lib/database/tables/daily_sales_summary.dart
import 'package:drift/drift.dart';
import 'items.dart';
import 'organizations.dart';

/// DailySalesSummary table - Aggregated daily sales data per item per branch
///
/// Purpose:
/// 1. Storage-efficient historical sales tracking (one row per item per day per branch)
/// 2. Fast queries for reports without scanning all StockChangeRequests
/// 3. Keeps Supabase storage minimal while enabling trend analysis
///
/// Data Flow:
/// 1. Throughout the day, sales are tracked in StockChangeRequests (real-time)
/// 2. At end of day (or periodically), aggregate into DailySalesSummary
/// 3. Old StockChangeRequests can be archived/deleted after aggregation
/// 4. Commissary queries this table for network-wide sales reports
class DailySalesSummary extends Table {
  /// Primary key
  IntColumn get id => integer().autoIncrement()();

  /// Which branch this summary belongs to
  IntColumn get organizationId => integer().references(Organizations, #id)();

  /// Which item was sold
  IntColumn get itemId => integer().references(Items, #id)();

  /// The date this summary covers (stored as date only, no time)
  DateTimeColumn get summaryDate => dateTime()();

  /// Total quantity sold on this date
  IntColumn get quantitySold => integer().withDefault(const Constant(0))();

  /// Total quantity spoiled on this date
  IntColumn get quantitySpoiled => integer().withDefault(const Constant(0))();

  /// Total revenue from sales (quantitySold * price at time of sale)
  RealColumn get revenue => real().withDefault(const Constant(0.0))();

  /// Total cost of goods sold (quantitySold * costPrice)
  /// Used by commissary to track profit margins
  RealColumn get costOfGoodsSold => real().withDefault(const Constant(0.0))();

  /// Gross profit for this day (revenue - costOfGoodsSold)
  RealColumn get grossProfit => real().withDefault(const Constant(0.0))();

  /// Number of transactions that contributed to this summary
  IntColumn get transactionCount => integer().withDefault(const Constant(0))();

  /// Opening stock at start of day (for reconciliation)
  IntColumn get openingStock => integer().nullable()();

  /// Closing stock at end of day (for reconciliation)
  IntColumn get closingStock => integer().nullable()();

  /// Track when summary was created/modified
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get lastUpdated =>
      dateTime().clientDefault(() => DateTime.now())();

  /// Sync fields for cloud synchronization
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get cloudId => text().nullable()();

  /// Ensure one summary per item per branch per day
  @override
  List<Set<Column>> get uniqueKeys => [
        {organizationId, itemId, summaryDate},
      ];
}
