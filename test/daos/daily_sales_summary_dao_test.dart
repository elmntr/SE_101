// test/daos/daily_sales_summary_dao_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import '../database/test_database.dart';
import 'package:chickenjoo_inventory/database/daos/daily_sales_summary_dao.dart';

void main() {
  late AppDatabase db;
  late DailySalesSummaryDao dao;
  late int orgId;
  late int itemId;
  late int commissaryId;

  setUp(() async {
    db = createTestDatabase();
    dao = db.dailySalesSummaryDao;

    // Set up required FK records - commissary first, then franchisee
    commissaryId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Main Commissary',
        type: 'commissary',
      ),
    );
    orgId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Test Branch',
        type: 'franchisee',
        parentCommissaryId: Value(commissaryId),
      ),
    );
    itemId = await db.itemsDao.insertItem(
      name: 'Test Item',
      organizationId: commissaryId,
      stock: 100,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('1. upsertDailySummary inserts a new record', () async {
    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);
    final id = await dao.upsertDailySummary(
      DailySalesSummaryCompanion.insert(
        organizationId: orgId,
        itemId: itemId,
        summaryDate: normalizedDate,
        quantitySold: const Value(10),
        revenue: const Value(500.0),
      ),
    );
    expect(id, greaterThan(0));
  });

  test('2. getSummary returns inserted summary', () async {
    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);
    await dao.upsertDailySummary(
      DailySalesSummaryCompanion.insert(
        organizationId: orgId,
        itemId: itemId,
        summaryDate: normalizedDate,
        quantitySold: const Value(5),
        revenue: const Value(250.0),
      ),
    );
    final result = await dao.getSummary(
      organizationId: orgId,
      itemId: itemId,
      date: normalizedDate,
    );
    expect(result, isNotNull);
    expect(result!.quantitySold, equals(5));
    expect(result.revenue, equals(250.0));
  });

  test('3. getSummary returns null for non-existent record', () async {
    final result = await dao.getSummary(
      organizationId: orgId,
      itemId: itemId,
      date: DateTime(2000, 1, 1),
    );
    expect(result, isNull);
  });

  test('4. getSummariesForDate returns all summaries for a date', () async {
    final date = DateTime(2024, 6, 15);
    // Create a second item
    final itemId2 = await db.itemsDao.insertItem(
      name: 'Item 2',
      organizationId: orgId,
      stock: 50,
    );
    await dao.upsertDailySummary(
      DailySalesSummaryCompanion.insert(
        organizationId: orgId,
        itemId: itemId,
        summaryDate: date,
      ),
    );
    await dao.upsertDailySummary(
      DailySalesSummaryCompanion.insert(
        organizationId: orgId,
        itemId: itemId2,
        summaryDate: date,
      ),
    );
    final results = await dao.getSummariesForDate(
      organizationId: orgId,
      date: date,
    );
    expect(results.length, equals(2));
  });

  test('5. getSummariesForDateRange returns summaries in range', () async {
    final date1 = DateTime(2024, 6, 10);
    final date2 = DateTime(2024, 6, 15);
    final date3 = DateTime(2024, 6, 20);
    await dao.upsertDailySummary(
      DailySalesSummaryCompanion.insert(
        organizationId: orgId,
        itemId: itemId,
        summaryDate: date1,
      ),
    );
    await dao.upsertDailySummary(
      DailySalesSummaryCompanion.insert(
        organizationId: orgId,
        itemId: itemId,
        summaryDate: date2,
      ),
    );
    await dao.upsertDailySummary(
      DailySalesSummaryCompanion.insert(
        organizationId: orgId,
        itemId: itemId,
        summaryDate: date3,
      ),
    );
    final results = await dao.getSummariesForDateRange(
      organizationId: orgId,
      startDate: DateTime(2024, 6, 9),
      endDate: DateTime(2024, 6, 16),
    );
    expect(results.length, equals(2));
  });

  test('6. getSummariesForDateRange orders by date descending', () async {
    final date1 = DateTime(2024, 6, 10);
    final date2 = DateTime(2024, 6, 15);
    await dao.upsertDailySummary(
      DailySalesSummaryCompanion.insert(
        organizationId: orgId,
        itemId: itemId,
        summaryDate: date1,
        quantitySold: const Value(1),
      ),
    );
    await dao.upsertDailySummary(
      DailySalesSummaryCompanion.insert(
        organizationId: orgId,
        itemId: itemId,
        summaryDate: date2,
        quantitySold: const Value(2),
      ),
    );
    final results = await dao.getSummariesForDateRange(
      organizationId: orgId,
      startDate: date1,
      endDate: date2,
    );
    // First result should be the later date
    expect(results.first.summaryDate.isAfter(results.last.summaryDate), isTrue);
  });

  test('7. getUnsyncedSummaries returns records with isSynced=false', () async {
    final date = DateTime(2024, 6, 15);
    await dao.upsertDailySummary(
      DailySalesSummaryCompanion.insert(
        organizationId: orgId,
        itemId: itemId,
        summaryDate: date,
      ),
    );
    final unsynced = await dao.getUnsyncedSummaries();
    expect(unsynced, isNotEmpty);
    expect(unsynced.first.isSynced, isFalse);
  });

  test('8. markAsSynced marks records as synced', () async {
    final date = DateTime(2024, 6, 15);
    final id = await dao.upsertDailySummary(
      DailySalesSummaryCompanion.insert(
        organizationId: orgId,
        itemId: itemId,
        summaryDate: date,
      ),
    );
    await dao.markAsSynced([id]);
    final unsynced = await dao.getUnsyncedSummaries();
    expect(unsynced, isEmpty);
  });

  test('9. updateCloudId sets cloudId and marks as synced', () async {
    final date = DateTime(2024, 6, 15);
    final id = await dao.upsertDailySummary(
      DailySalesSummaryCompanion.insert(
        organizationId: orgId,
        itemId: itemId,
        summaryDate: date,
      ),
    );
    await dao.updateCloudId(id, 'cloud-uuid-abc');
    final summary = await dao.getSummary(
      organizationId: orgId,
      itemId: itemId,
      date: date,
    );
    expect(summary!.cloudId, equals('cloud-uuid-abc'));
    expect(summary.isSynced, isTrue);
  });

  test('10. upsertDailySummary with defaults has zero quantities', () async {
    final date = DateTime(2024, 6, 15);
    await dao.upsertDailySummary(
      DailySalesSummaryCompanion.insert(
        organizationId: orgId,
        itemId: itemId,
        summaryDate: date,
      ),
    );
    final result = await dao.getSummary(
      organizationId: orgId,
      itemId: itemId,
      date: date,
    );
    expect(result!.quantitySold, equals(0));
    expect(result.quantitySpoiled, equals(0));
    expect(result.revenue, equals(0.0));
    expect(result.grossProfit, equals(0.0));
  });

  test('11. upsertDailySummary stores gross profit', () async {
    final date = DateTime(2024, 6, 15);
    await dao.upsertDailySummary(
      DailySalesSummaryCompanion.insert(
        organizationId: orgId,
        itemId: itemId,
        summaryDate: date,
        revenue: const Value(1000.0),
        costOfGoodsSold: const Value(600.0),
        grossProfit: const Value(400.0),
      ),
    );
    final result = await dao.getSummary(
      organizationId: orgId,
      itemId: itemId,
      date: date,
    );
    expect(result!.grossProfit, equals(400.0));
  });

  test('12. getNetworkTotalsForDate aggregates across all orgs', () async {
    final date = DateTime(2024, 6, 15);
    final orgId2 = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Branch 2',
        type: 'franchisee',
        parentCommissaryId: Value(commissaryId),
      ),
    );
    final itemId2 = await db.itemsDao.insertItem(
      name: 'Item Branch 2',
      organizationId: commissaryId,
      stock: 50,
    );
    await dao.upsertDailySummary(
      DailySalesSummaryCompanion.insert(
        organizationId: orgId,
        itemId: itemId,
        summaryDate: date,
        quantitySold: const Value(10),
        revenue: const Value(500.0),
      ),
    );
    await dao.upsertDailySummary(
      DailySalesSummaryCompanion.insert(
        organizationId: orgId2,
        itemId: itemId2,
        summaryDate: date,
        quantitySold: const Value(20),
        revenue: const Value(1000.0),
      ),
    );
    final totals = await dao.getNetworkTotalsForDate(date);
    expect(totals['totalSold'], equals(30));
    expect(totals['totalRevenue'], equals(1500.0));
  });

  test('13. watchTodaySummaries returns a stream', () async {
    final stream = dao.watchTodaySummaries(orgId);
    expect(stream, isA<Stream<List<DailySalesSummaryData>>>());
  });

  test('14. getSummariesForDate returns empty for no data', () async {
    final results = await dao.getSummariesForDate(
      organizationId: orgId,
      date: DateTime(2000, 1, 1),
    );
    expect(results, isEmpty);
  });

  test('15. upsertDailySummary stores opening and closing stock', () async {
    final date = DateTime(2024, 6, 15);
    await dao.upsertDailySummary(
      DailySalesSummaryCompanion.insert(
        organizationId: orgId,
        itemId: itemId,
        summaryDate: date,
        openingStock: const Value(100),
        closingStock: const Value(85),
      ),
    );
    final result = await dao.getSummary(
      organizationId: orgId,
      itemId: itemId,
      date: date,
    );
    expect(result!.openingStock, equals(100));
    expect(result.closingStock, equals(85));
  });
}
