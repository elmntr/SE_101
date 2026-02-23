// lib/database/daos/daily_sales_summary_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/daily_sales_summary.dart';
import '../tables/items.dart';
import '../tables/organizations.dart';
import '../../utils/app_logger.dart';

part 'daily_sales_summary_dao.g.dart';

@DriftAccessor(tables: [DailySalesSummary, Items, Organizations])
class DailySalesSummaryDao extends DatabaseAccessor<AppDatabase>
    with _$DailySalesSummaryDaoMixin {
  DailySalesSummaryDao(super.db);

  // ═══════════════════════════════════════════════════════════════════════════
  // CRUD OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Insert or update a daily sales summary
  Future<int> upsertDailySummary(DailySalesSummaryCompanion summary) async {
    return into(dailySalesSummary).insertOnConflictUpdate(summary);
  }

  /// Get summary for a specific item on a specific date for a branch
  Future<DailySalesSummaryData?> getSummary({
    required int organizationId,
    required int itemId,
    required DateTime date,
  }) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return await (select(dailySalesSummary)
          ..where((t) => t.organizationId.equals(organizationId))
          ..where((t) => t.itemId.equals(itemId))
          ..where((t) => t.summaryDate.equals(normalizedDate)))
        .getSingleOrNull();
  }

  /// Get all summaries for a branch on a specific date
  Future<List<DailySalesSummaryData>> getSummariesForDate({
    required int organizationId,
    required DateTime date,
  }) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return await (select(dailySalesSummary)
          ..where((t) => t.organizationId.equals(organizationId))
          ..where((t) => t.summaryDate.equals(normalizedDate)))
        .get();
  }

  /// Get summaries for a date range
  Future<List<DailySalesSummaryData>> getSummariesForDateRange({
    required int organizationId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    return await (select(dailySalesSummary)
          ..where((t) => t.organizationId.equals(organizationId))
          ..where((t) => t.summaryDate.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.summaryDate)]))
        .get();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AGGREGATION - For creating summaries from StockChangeRequests
  // ═══════════════════════════════════════════════════════════════════════════

  /// Create or update today's summary for an item after a sale
  Future<void> recordSale({
    required int organizationId,
    required int itemId,
    required int quantity,
    required double unitPrice,
    required double unitCost,
    int? currentStock,
  }) async {
    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);

    final existing = await getSummary(
      organizationId: organizationId,
      itemId: itemId,
      date: normalizedDate,
    );

    final revenue = quantity * unitPrice;
    final cost = quantity * unitCost;

    if (existing != null) {
      // Update existing summary
      await (update(dailySalesSummary)
            ..where((t) => t.id.equals(existing.id)))
          .write(DailySalesSummaryCompanion(
        quantitySold: Value(existing.quantitySold + quantity),
        revenue: Value(existing.revenue + revenue),
        costOfGoodsSold: Value(existing.costOfGoodsSold + cost),
        grossProfit: Value(existing.grossProfit + (revenue - cost)),
        transactionCount: Value(existing.transactionCount + 1),
        closingStock: currentStock != null ? Value(currentStock) : const Value.absent(),
        lastUpdated: Value(DateTime.now()),
        isSynced: const Value(false),
      ));
    } else {
      // Insert new summary
      await into(dailySalesSummary).insert(DailySalesSummaryCompanion.insert(
        organizationId: organizationId,
        itemId: itemId,
        summaryDate: normalizedDate,
        quantitySold: Value(quantity),
        revenue: Value(revenue),
        costOfGoodsSold: Value(cost),
        grossProfit: Value(revenue - cost),
        transactionCount: const Value(1),
        openingStock: currentStock != null ? Value(currentStock + quantity) : const Value.absent(),
        closingStock: currentStock != null ? Value(currentStock) : const Value.absent(),
      ));
    }
  }

  /// Record spoilage for today's summary
  Future<void> recordSpoilage({
    required int organizationId,
    required int itemId,
    required int quantity,
    int? currentStock,
  }) async {
    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);

    final existing = await getSummary(
      organizationId: organizationId,
      itemId: itemId,
      date: normalizedDate,
    );

    if (existing != null) {
      await (update(dailySalesSummary)
            ..where((t) => t.id.equals(existing.id)))
          .write(DailySalesSummaryCompanion(
        quantitySpoiled: Value(existing.quantitySpoiled + quantity),
        closingStock: currentStock != null ? Value(currentStock) : const Value.absent(),
        lastUpdated: Value(DateTime.now()),
        isSynced: const Value(false),
      ));
    } else {
      await into(dailySalesSummary).insert(DailySalesSummaryCompanion.insert(
        organizationId: organizationId,
        itemId: itemId,
        summaryDate: normalizedDate,
        quantitySpoiled: Value(quantity),
        openingStock: currentStock != null ? Value(currentStock + quantity) : const Value.absent(),
        closingStock: currentStock != null ? Value(currentStock) : const Value.absent(),
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REPORTING QUERIES - For commissary dashboard
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get total sales for all branches on a specific date (commissary view)
  Future<Map<String, dynamic>> getNetworkTotalsForDate(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    final query = selectOnly(dailySalesSummary)
      ..addColumns([
        dailySalesSummary.quantitySold.sum(),
        dailySalesSummary.quantitySpoiled.sum(),
        dailySalesSummary.revenue.sum(),
        dailySalesSummary.costOfGoodsSold.sum(),
        dailySalesSummary.grossProfit.sum(),
        dailySalesSummary.transactionCount.sum(),
      ])
      ..where(dailySalesSummary.summaryDate.equals(normalizedDate));

    final result = await query.getSingle();
    
    return {
      'totalSold': result.read(dailySalesSummary.quantitySold.sum()) ?? 0,
      'totalSpoiled': result.read(dailySalesSummary.quantitySpoiled.sum()) ?? 0,
      'totalRevenue': result.read(dailySalesSummary.revenue.sum()) ?? 0.0,
      'totalCost': result.read(dailySalesSummary.costOfGoodsSold.sum()) ?? 0.0,
      'totalProfit': result.read(dailySalesSummary.grossProfit.sum()) ?? 0.0,
      'totalTransactions': result.read(dailySalesSummary.transactionCount.sum()) ?? 0,
    };
  }

  /// Get sales breakdown by branch for a date range
  Future<List<Map<String, dynamic>>> getSalesByBranch({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    // Using raw SQL for complex aggregation
    final results = await customSelect(
      '''
      SELECT 
        o.id as org_id,
        o.name as org_name,
        SUM(dss.quantity_sold) as total_sold,
        SUM(dss.revenue) as total_revenue,
        SUM(dss.gross_profit) as total_profit
      FROM daily_sales_summary dss
      INNER JOIN organizations o ON dss.organization_id = o.id
      WHERE dss.summary_date BETWEEN ? AND ?
      GROUP BY o.id, o.name
      ORDER BY total_revenue DESC
      ''',
      variables: [Variable.withDateTime(start), Variable.withDateTime(end)],
    ).get();

    return results.map((row) => {
      'organizationId': row.read<int>('org_id'),
      'organizationName': row.read<String>('org_name'),
      'totalSold': row.readNullable<int>('total_sold') ?? 0,
      'totalRevenue': row.readNullable<double>('total_revenue') ?? 0.0,
      'totalProfit': row.readNullable<double>('total_profit') ?? 0.0,
    }).toList();
  }

  /// Get top selling items across all branches
  Future<List<Map<String, dynamic>>> getTopSellingItems({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  }) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    final results = await customSelect(
      '''
      SELECT 
        i.id as item_id,
        i.name as item_name,
        SUM(dss.quantity_sold) as total_sold,
        SUM(dss.revenue) as total_revenue
      FROM daily_sales_summary dss
      INNER JOIN items i ON dss.item_id = i.id
      WHERE dss.summary_date BETWEEN ? AND ?
      GROUP BY i.id, i.name
      ORDER BY total_sold DESC
      LIMIT ?
      ''',
      variables: [
        Variable.withDateTime(start),
        Variable.withDateTime(end),
        Variable.withInt(limit),
      ],
    ).get();

    return results.map((row) => {
      'itemId': row.read<int>('item_id'),
      'itemName': row.read<String>('item_name'),
      'totalSold': row.readNullable<int>('total_sold') ?? 0,
      'totalRevenue': row.readNullable<double>('total_revenue') ?? 0.0,
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SYNC OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get unsynced summaries
  Future<List<DailySalesSummaryData>> getUnsyncedSummaries({
    int limit = 100,
    int offset = 0,
  }) async {
    return await (select(dailySalesSummary)
          ..where((t) => t.isSynced.equals(false))
          ..limit(limit, offset: offset))
        .get();
  }

  /// Mark summaries as synced
  Future<void> markAsSynced(List<int> ids, {Map<int, String>? cloudIds}) async {
    if (cloudIds != null) {
      await batch((batch) {
        for (final id in ids) {
          final cloudId = cloudIds[id];
          if (cloudId != null) {
            batch.update(
              dailySalesSummary,
              DailySalesSummaryCompanion(
                isSynced: const Value(true),
                cloudId: Value(cloudId),
              ),
              where: (t) => t.id.equals(id),
            );
          } else {
             batch.update(
              dailySalesSummary,
              const DailySalesSummaryCompanion(isSynced: Value(true)),
              where: (t) => t.id.equals(id),
            );
          }
        }
      });
    } else {
      await (update(dailySalesSummary)..where((t) => t.id.isIn(ids)))
          .write(const DailySalesSummaryCompanion(isSynced: Value(true)));
    }
  }

  /// Update cloud ID after sync (Legacy helper, prefer markAsSynced with map)
  Future<void> updateCloudId(int localId, String cloudId) async {
    await (update(dailySalesSummary)..where((t) => t.id.equals(localId)))
        .write(DailySalesSummaryCompanion(
      cloudId: Value(cloudId),
      isSynced: const Value(true),
    ));
  }

  /// Get summary by cloud ID
  Future<DailySalesSummaryData?> getByCloudId(String cloudId) async {
    return await (select(dailySalesSummary)
          ..where((t) => t.cloudId.equals(cloudId)))
        .getSingleOrNull();
  }

  /// Get summary by business key (organizationId, itemId, summaryDate) for conflict resolution
  Future<DailySalesSummaryData?> getByBusinessKey({
    required int organizationId,
    required int itemId,
    required DateTime summaryDate,
  }) async {
    final normalizedDate = DateTime(summaryDate.year, summaryDate.month, summaryDate.day);
    return await (select(dailySalesSummary)
          ..where((t) => t.organizationId.equals(organizationId))
          ..where((t) => t.itemId.equals(itemId))
          ..where((t) => t.summaryDate.equals(normalizedDate)))
        .getSingleOrNull();
  }

  /// Upsert batch from cloud
Future<void> upsertBatchFromCloud(List<Map<String, dynamic>> records) async {
  await batch((batch) {
    for (final record in records) {
      final cloudId = record['cloudId'] as String;

      final organizationId = record['organizationId'] as int?;
      final itemId = record['itemId'] as int?;

      if (organizationId == null || itemId == null) {
        AppLogger.sync('⚠️ Skipping daily_sales_summary record: Missing required fields');
        continue;
      }

      final summaryDate = record['summaryDate'] as DateTime;
      final resolvedLastUpdated =
          (record['lastUpdated'] as DateTime?) ?? DateTime.now();

      batch.insert(
        dailySalesSummary,
        DailySalesSummaryCompanion.insert(
          organizationId: organizationId,
          itemId: itemId,
          summaryDate: summaryDate,
          quantitySold: Value(record['quantitySold'] as int? ?? 0),
          quantitySpoiled: Value(record['quantitySpoiled'] as int? ?? 0),
          revenue: Value(record['revenue'] as double? ?? 0.0),
          costOfGoodsSold: Value(record['costOfGoodsSold'] as double? ?? 0.0),
          grossProfit: Value(record['grossProfit'] as double? ?? 0.0),
          transactionCount: Value(record['transactionCount'] as int? ?? 0),
          cloudId: Value(cloudId),
          lastUpdated: Value(resolvedLastUpdated),
          isSynced: const Value(true),
        ),
        onConflict: DoUpdate(
          (old) => DailySalesSummaryCompanion(
            quantitySold: Value(record['quantitySold'] as int? ?? 0),
            quantitySpoiled: Value(record['quantitySpoiled'] as int? ?? 0),
            revenue: Value(record['revenue'] as double? ?? 0.0),
            costOfGoodsSold: Value(record['costOfGoodsSold'] as double? ?? 0.0),
            grossProfit: Value(record['grossProfit'] as double? ?? 0.0),
            transactionCount: Value(record['transactionCount'] as int? ?? 0),
            lastUpdated: Value(resolvedLastUpdated),
            isSynced: const Value(true),
          ),
        ),
      );
    }
  });
}

  /// Watch today's summaries for real-time UI updates
  Stream<List<DailySalesSummaryData>> watchTodaySummaries(int organizationId) {
    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);
    
    return (select(dailySalesSummary)
          ..where((t) => t.organizationId.equals(organizationId))
          ..where((t) => t.summaryDate.equals(normalizedDate)))
        .watch();
  }
}
