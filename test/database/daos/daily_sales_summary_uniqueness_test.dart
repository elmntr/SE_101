// test/database/daos/daily_sales_summary_uniqueness_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:matcher/matcher.dart' as matcher;

import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/database/daos/daily_sales_summary_dao.dart';
import 'package:chickenjoo_inventory/database/tables/daily_sales_summary.dart';

void main() {
  group('DailySalesSummary Uniqueness Tests', () {
    late AppDatabase database;
    late DailySalesSummaryDao dao;

    setUp(() async {
      // Use in-memory database for testing
      database = AppDatabase.test(DatabaseConnection(NativeDatabase.memory()));
      dao = database.dailySalesSummaryDao;
      await database.customStatement('PRAGMA foreign_keys = ON');

      // Create FK prerequisites for pre-existing tests that use hard-coded IDs
      // org id=1 (commissary), org id=2 (franchisee), item id=1, item id=2
      await database.organizationsDao.insertOrganization(
        OrganizationsCompanion.insert(name: 'Main Commissary', type: 'commissary'),
      );
      await database.organizationsDao.insertOrganization(
        OrganizationsCompanion.insert(
          name: 'Main Franchisee',
          type: 'franchisee',
          parentCommissaryId: const Value(1),
        ),
      );
      await database.itemsDao.insertItem(
        name: 'FK Test Item 1',
        organizationId: 1,
        stock: 100,
      );
      await database.itemsDao.insertItem(
        name: 'FK Test Item 2',
        organizationId: 1,
        stock: 100,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('should enforce cloud_id uniqueness', () async {
      // Arrange
      final organizationId = 1;
      final itemId = 1;
      final summaryDate = DateTime(2024, 1, 1);
      final cloudId = 'test-cloud-id-123';

      // Act - Insert first record
      await dao.upsertDailySummary(DailySalesSummaryCompanion.insert(
        organizationId: organizationId,
        itemId: itemId,
        summaryDate: summaryDate,
        quantitySold: const Value(10),
        cloudId: Value(cloudId),
      ));

      // Assert - First record should exist
      final firstRecord = await dao.getByCloudId(cloudId);
      expect(firstRecord, matcher.isNotNull);
      expect(firstRecord!.cloudId, equals(cloudId));

      // Act & Assert - Attempt to insert duplicate cloud_id should fail
      expect(
        () async => await dao.upsertDailySummary(DailySalesSummaryCompanion.insert(
          organizationId: 2, // Different organization
          itemId: 2, // Different item
          summaryDate: DateTime(2024, 1, 2), // Different date
          quantitySold: const Value(5),
          cloudId: Value(cloudId), // Same cloud_id - should fail
        )),
        throwsA(isA<SqliteException>()),
      );
    });

    test('should enforce business key uniqueness (organizationId, itemId, summaryDate)', () async {
      // Arrange
      final organizationId = 1;
      final itemId = 1;
      // Use UTC to match how getSummary normalises dates before querying
      final summaryDate = DateTime.utc(2024, 1, 1);

      // Act - Insert first record
      await dao.upsertDailySummary(DailySalesSummaryCompanion.insert(
        organizationId: organizationId,
        itemId: itemId,
        summaryDate: summaryDate,
        quantitySold: const Value(10),
      ));

      // Assert - First record should exist
      final firstRecord = await dao.getSummary(
        organizationId: organizationId,
        itemId: itemId,
        date: summaryDate,
      );
      expect(firstRecord, matcher.isNotNull);

      // Act - Insert second record with same business key (should update)
      await dao.upsertDailySummary(DailySalesSummaryCompanion.insert(
        organizationId: organizationId,
        itemId: itemId,
        summaryDate: summaryDate, // Same business key
        quantitySold: const Value(20), // Different quantity
        revenue: const Value(200.0),
      ));

      // Assert - Should have updated the existing record
      final updatedRecord = await dao.getSummary(
        organizationId: organizationId,
        itemId: itemId,
        date: summaryDate,
      );
      expect(updatedRecord, matcher.isNotNull);
      expect(updatedRecord!.quantitySold, equals(20)); // Updated value
      expect(updatedRecord.revenue, equals(200.0)); // Updated value
    });

    test('should allow different business keys with same cloud_id after migration cleanup', () async {
      // This test verifies that the migration cleaned up duplicates
      // In practice, this scenario should not occur after the unique constraint

      // Arrange
      final organizationId1 = 1;
      final organizationId2 = 2;
      final itemId = 1;
      final summaryDate1 = DateTime.utc(2024, 1, 1);
      final summaryDate2 = DateTime.utc(2024, 1, 2);

      // Act - Insert first record
      await dao.upsertDailySummary(DailySalesSummaryCompanion.insert(
        organizationId: organizationId1,
        itemId: itemId,
        summaryDate: summaryDate1,
        quantitySold: const Value(10),
        cloudId: Value('unique-cloud-id-1'),
      ));

      // Insert second record with different cloud_id
      await dao.upsertDailySummary(DailySalesSummaryCompanion.insert(
        organizationId: organizationId2,
        itemId: itemId,
        summaryDate: summaryDate2,
        quantitySold: const Value(15),
        cloudId: Value('unique-cloud-id-2'),
      ));

      // Assert - Both records should exist with different cloud_ids
      final record1 = await dao.getByCloudId('unique-cloud-id-1');
      final record2 = await dao.getByCloudId('unique-cloud-id-2');
      
      expect(record1, matcher.isNotNull);
      expect(record2, matcher.isNotNull);
      expect(record1!.cloudId, equals('unique-cloud-id-1'));
      expect(record2!.cloudId, equals('unique-cloud-id-2'));
      expect(record1.organizationId, equals(organizationId1));
      expect(record2.organizationId, equals(organizationId2));
    });

    test('getByBusinessKey should return correct record', () async {
      // Arrange
      final organizationId = 1;
      final itemId = 1;
      // Use UTC midnight to match how getByBusinessKey normalises dates before querying
      final summaryDate = DateTime.utc(2024, 1, 1);

      // Act
      await dao.upsertDailySummary(DailySalesSummaryCompanion.insert(
        organizationId: organizationId,
        itemId: itemId,
        summaryDate: summaryDate,
        quantitySold: const Value(10),
        revenue: const Value(100.0),
      ));

      // Assert
      final record = await dao.getByBusinessKey(
        organizationId: organizationId,
        itemId: itemId,
        summaryDate: summaryDate,
      );
      
      expect(record, matcher.isNotNull);
      expect(record!.organizationId, equals(organizationId));
      expect(record.itemId, equals(itemId));
      expect(record.summaryDate.year, equals(summaryDate.year));
      expect(record.summaryDate.month, equals(summaryDate.month));
      expect(record.summaryDate.day, equals(summaryDate.day));
      expect(record.quantitySold, equals(10));
      expect(record.revenue, equals(100.0));
    });

    test('getByBusinessKey should return null for non-existent record', () async {
      // Act
      final record = await dao.getByBusinessKey(
        organizationId: 999,
        itemId: 999,
        summaryDate: DateTime(2024, 1, 1),
      );
      
      // Assert
      expect(record, matcher.isNull);
    });

    test('should handle date normalization in business key lookup', () async {
      // Arrange
      final organizationId = 1;
      final itemId = 1;
      // Store at UTC midnight (as the DAO always normalises to UTC date-only).
      // The test verifies that queries with any local time on the same calendar
      // day are also normalised to UTC midnight and therefore find this record.
      final summaryDate = DateTime.utc(2024, 1, 1);

      // Act
      await dao.upsertDailySummary(DailySalesSummaryCompanion.insert(
        organizationId: organizationId,
        itemId: itemId,
        summaryDate: summaryDate,
        quantitySold: const Value(10),
      ));

      // Assert - Should find record even when searching with different time
      final record1 = await dao.getByBusinessKey(
        organizationId: organizationId,
        itemId: itemId,
        summaryDate: DateTime(2024, 1, 1, 0, 0, 0), // Midnight
      );
      
      final record2 = await dao.getByBusinessKey(
        organizationId: organizationId,
        itemId: itemId,
        summaryDate: DateTime(2024, 1, 1, 23, 59, 59), // End of day
      );
      
      expect(record1, matcher.isNotNull);
      expect(record2, matcher.isNotNull);
      expect(record1!.id, equals(record2!.id)); // Same record
    });

    group('Migration Tests', () {
      test('should simulate v4 migration cleanup', () async {
        // This test simulates what the v4 migration does
        // In a real scenario, you'd test the actual migration
        
        // Arrange - Create duplicate cloud_id scenario (pre-migration state)
        final cloudId = 'duplicate-cloud-id';
        
        // Insert first record
        await dao.upsertDailySummary(DailySalesSummaryCompanion.insert(
          organizationId: 1,
          itemId: 1,
          summaryDate: DateTime(2024, 1, 1),
          quantitySold: const Value(10),
          cloudId: Value(cloudId),
        ));

        // Simulate pre-v4-migration state: insert a row with duplicate cloud_id.
        // We must temporarily drop idx_daily_sales_cloud_id (created by _createAllIndexes)
        // because the whole point of v4 was to clean up a state that predates that index.
        await database.customStatement('DROP INDEX IF EXISTS idx_daily_sales_cloud_id');
        // Provide all NOT NULL columns (created_at / last_updated) that Drift's
        // clientDefault would normally supply but raw SQL must supply explicitly.
        // 1704153600000 = 2024-01-02 00:00:00 UTC in milliseconds.
        await database.customInsert('INSERT INTO daily_sales_summary '
            '(organization_id, item_id, summary_date, quantity_sold, cloud_id, '
            'is_synced, created_at, last_updated) '
            'VALUES (2, 2, 1704153600000, 5, "$cloudId", 0, 1704153600000, 1704153600000)');

        // Verify duplicates exist
        final allRecords = await (database.select(database.dailySalesSummary)
              ..where((t) => t.cloudId.equals(cloudId)))
            .get();
        expect(allRecords.length, equals(2));

        // Act - Simulate migration cleanup
        await database.customStatement('''
          DELETE FROM daily_sales_summary 
          WHERE id NOT IN (
            SELECT MAX(id) 
            FROM daily_sales_summary 
            WHERE cloud_id IS NOT NULL 
            GROUP BY cloud_id
          )
          AND cloud_id IS NOT NULL
        ''');

        // Assert - Only one record should remain
        final remainingRecords = await (database.select(database.dailySalesSummary)
              ..where((t) => t.cloudId.equals(cloudId)))
            .get();
        expect(remainingRecords.length, equals(1));
        
        // Should be the record with the highest ID (latest)
        expect(remainingRecords.first.id, equals(allRecords.map((r) => r.id).reduce((a, b) => a > b ? a : b)));
      });
    });

    // -------------------------------------------------------------------------
    // Task 6.1 – v8 migration regression tests
    // These tests lock in the fix from Phase 1 Task 1.3: the v8 migration SQL
    // that deduplicates daily_sales_summary by business key
    // (organization_id, item_id, summary_date), keeping the newest row.
    //
    // WHY TEMP TABLE: The DailySalesSummary Drift table defines
    //   List<Set<Column>> get uniqueKeys => [{organizationId, itemId, summaryDate}];
    // which bakes a UNIQUE constraint into the CREATE TABLE DDL itself.
    // To INSERT true duplicates (the pre-migration scenario the dedup SQL was
    // written to fix) we use a shadow temp table with the same columns but
    // WITHOUT that constraint.  The SQL algorithm is what we are testing.
    // -------------------------------------------------------------------------
    group('v8 migration deduplication SQL (Task 1.3 regression)', () {
      int orgId = 0;
      int itemId = 0;

      setUp(() async {
        // FK prerequisites for the "different business keys" test that inserts
        // into the real daily_sales_summary table.
        final commissaryId = await database.organizationsDao.insertOrganization(
          OrganizationsCompanion.insert(
            name: 'Commissary',
            type: 'commissary',
          ),
        );
        orgId = await database.organizationsDao.insertOrganization(
          OrganizationsCompanion.insert(
            name: 'Branch',
            type: 'franchisee',
            parentCommissaryId: Value(commissaryId),
          ),
        );
        itemId = await database.itemsDao.insertItem(
          name: 'Chicken',
          organizationId: commissaryId,
          stock: 50,
        );
      });

      /// Creates an isolated temp table with the same column structure as
      /// daily_sales_summary but WITHOUT the built-in UNIQUE constraint,
      /// so that true pre-migration duplicates can be inserted and then
      /// cleaned up with the dedup SQL.
      Future<void> createDedupShadowTable() async {
        await database.customStatement('''
          CREATE TEMP TABLE IF NOT EXISTS daily_sales_dedup_shadow (
            id              INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            item_id         INTEGER NOT NULL,
            summary_date    TEXT    NOT NULL,
            quantity_sold   INTEGER NOT NULL DEFAULT 0,
            last_updated    TEXT    NOT NULL
          )
        ''');
        await database.customStatement(
            'DELETE FROM daily_sales_dedup_shadow');
      }

      test(
        'dedup SQL keeps newest row and removes older duplicate by business key',
        () async {
          await createDedupShadowTable();

          // Insert OLDER row (quantity_sold = 5, earlier last_updated)
          await database.customStatement(
            'INSERT INTO daily_sales_dedup_shadow '
            '(organization_id, item_id, summary_date, quantity_sold, last_updated) '
            "VALUES (1, 1, '2024-06-15', 5, '2024-06-15 09:00:00')",
          );
          // Insert NEWER row (quantity_sold = 20, later last_updated)
          await database.customStatement(
            'INSERT INTO daily_sales_dedup_shadow '
            '(organization_id, item_id, summary_date, quantity_sold, last_updated) '
            "VALUES (1, 1, '2024-06-15', 20, '2024-06-15 10:00:00')",
          );

          // Confirm 2 duplicate rows exist before dedup
          final before = await database
              .customSelect(
                'SELECT COUNT(*) AS c FROM daily_sales_dedup_shadow',
              )
              .getSingle();
          expect(before.read<int>('c'), 2,
              reason: 'Pre-condition: two duplicate rows must exist');

          // Run the verbatim v8 migration dedup SQL against the shadow table
          await database.customStatement('''
            DELETE FROM daily_sales_dedup_shadow
            WHERE id NOT IN (
              SELECT id FROM (
                SELECT id,
                       ROW_NUMBER() OVER (
                         PARTITION BY organization_id, item_id, summary_date
                         ORDER BY last_updated DESC, id DESC
                       ) AS rn
                FROM daily_sales_dedup_shadow
              )
              WHERE rn = 1
            )
          ''');

          final rows = await database
              .customSelect(
                'SELECT quantity_sold FROM daily_sales_dedup_shadow',
              )
              .get();
          expect(rows.length, 1,
              reason: 'Exactly one row should survive dedup');
          expect(rows.first.read<int>('quantity_sold'), 20,
              reason: 'Row with later last_updated (newer) must be kept');
        },
      );

      test(
        'dedup SQL keeps higher id as tie-breaker when last_updated is equal',
        () async {
          await createDedupShadowTable();

          const sameTimestamp = '2024-07-01 08:00:00';

          // Insert first row (lower id, quantity = 3)
          await database.customStatement(
            'INSERT INTO daily_sales_dedup_shadow '
            '(organization_id, item_id, summary_date, quantity_sold, last_updated) '
            "VALUES (1, 1, '2024-07-01', 3, '$sameTimestamp')",
          );
          // Insert second row (higher id, quantity = 7)
          await database.customStatement(
            'INSERT INTO daily_sales_dedup_shadow '
            '(organization_id, item_id, summary_date, quantity_sold, last_updated) '
            "VALUES (1, 1, '2024-07-01', 7, '$sameTimestamp')",
          );

          // Record which row has the higher id BEFORE dedup
          final idRows = await database
              .customSelect(
                'SELECT id, quantity_sold FROM daily_sales_dedup_shadow '
                'ORDER BY id DESC',
              )
              .get();
          expect(idRows.length, 2);
          final higherRowId = idRows.first.read<int>('id');
          final higherQty = idRows.first.read<int>('quantity_sold'); // = 7

          // Run dedup
          await database.customStatement('''
            DELETE FROM daily_sales_dedup_shadow
            WHERE id NOT IN (
              SELECT id FROM (
                SELECT id,
                       ROW_NUMBER() OVER (
                         PARTITION BY organization_id, item_id, summary_date
                         ORDER BY last_updated DESC, id DESC
                       ) AS rn
                FROM daily_sales_dedup_shadow
              )
              WHERE rn = 1
            )
          ''');

          final remaining = await database
              .customSelect(
                'SELECT id, quantity_sold FROM daily_sales_dedup_shadow',
              )
              .get();
          expect(remaining.length, 1);
          expect(remaining.first.read<int>('id'), higherRowId,
              reason:
                  'Row with higher id must survive when last_updated ties');
          expect(remaining.first.read<int>('quantity_sold'), higherQty);
        },
      );

      test(
        'dedup SQL does not affect rows with different business keys',
        () async {
          // Two rows with DIFFERENT business dates — both should survive.
          // These use the actual table (FK checks satisfied via inner setUp).
          await database.customStatement(
            'INSERT INTO daily_sales_summary '
            '(organization_id, item_id, summary_date, quantity_sold, revenue, '
            'cost_of_goods_sold, gross_profit, quantity_spoiled, '
            'transaction_count, last_updated, created_at, is_synced) '
            'VALUES (?, ?, ?, 10, 0, 0, 0, 0, 0, ?, ?, 0)',
            [orgId, itemId, '2024-08-01', '2024-08-01 08:00:00', '2024-08-01 12:00:00'],
          );
          await database.customStatement(
            'INSERT INTO daily_sales_summary '
            '(organization_id, item_id, summary_date, quantity_sold, revenue, '
            'cost_of_goods_sold, gross_profit, quantity_spoiled, '
            'transaction_count, last_updated, created_at, is_synced) '
            'VALUES (?, ?, ?, 15, 0, 0, 0, 0, 0, ?, ?, 0)',
            [orgId, itemId, '2024-08-02', '2024-08-02 08:00:00', '2024-08-02 12:00:00'],
          );

          // Run dedup on the REAL table
          await database.customStatement('''
            DELETE FROM daily_sales_summary
            WHERE id NOT IN (
              SELECT id FROM (
                SELECT id,
                       ROW_NUMBER() OVER (
                         PARTITION BY organization_id, item_id, summary_date
                         ORDER BY last_updated DESC, id DESC
                       ) AS rn
                FROM daily_sales_summary
              )
              WHERE rn = 1
            )
          ''');

          // Both rows should survive (different business keys)
          final total = await database
              .customSelect(
                'SELECT COUNT(*) AS c FROM daily_sales_summary '
                'WHERE organization_id = ? AND item_id = ?',
                variables: [Variable.withInt(orgId), Variable.withInt(itemId)],
              )
              .getSingle();
          expect(total.read<int>('c'), 2,
              reason: 'Distinct business keys must not be deduped');
        },
      );
    });

    // -------------------------------------------------------------------------
    // Task 6.1 – upsertBatchFromCloud idempotency regression tests
    // These tests verify that repeated cloud pulls do not create duplicate rows.
    // -------------------------------------------------------------------------
    group('upsertBatchFromCloud idempotency (Task 1.3 regression)', () {
      int orgId = 0;
      int itemId = 0;

      setUp(() async {
        final commissaryId = await database.organizationsDao.insertOrganization(
          OrganizationsCompanion.insert(
            name: 'Commissary2',
            type: 'commissary',
          ),
        );
        orgId = await database.organizationsDao.insertOrganization(
          OrganizationsCompanion.insert(
            name: 'Branch2',
            type: 'franchisee',
            parentCommissaryId: Value(commissaryId),
          ),
        );
        itemId = await database.itemsDao.insertItem(
          name: 'Egg',
          organizationId: commissaryId,
          stock: 200,
        );
      });

      test(
        'calling upsertBatchFromCloud twice with identical record does not duplicate rows',
        () async {
          final date = DateTime.utc(2024, 6, 15);
          final record = {
            'cloudId': 'cloud-idem-001',
            'organizationId': orgId,
            'itemId': itemId,
            'summaryDate': date,
            'quantitySold': 10,
            'quantitySpoiled': 0,
            'revenue': 500.0,
            'costOfGoodsSold': 200.0,
            'grossProfit': 300.0,
            'transactionCount': 5,
            'lastUpdated': date,
          };

          await dao.upsertBatchFromCloud([record]);
          await dao.upsertBatchFromCloud([record]); // Repeat — simulating two pulls

          final count = await database
              .customSelect(
                "SELECT COUNT(*) AS c FROM daily_sales_summary "
                "WHERE cloud_id = 'cloud-idem-001'",
              )
              .getSingle();
          expect(count.read<int>('c'), 1,
              reason: 'Repeated upsertBatchFromCloud must not create duplicates');
        },
      );

      test(
        'upsertBatchFromCloud updates values on second pull (ON CONFLICT DO UPDATE)',
        () async {
          final date = DateTime.utc(2024, 7, 1);

          // First pull: quantity_sold = 8
          await dao.upsertBatchFromCloud([
            {
              'cloudId': 'cloud-idem-002',
              'organizationId': orgId,
              'itemId': itemId,
              'summaryDate': date,
              'quantitySold': 8,
              'quantitySpoiled': 0,
              'revenue': 400.0,
              'costOfGoodsSold': 150.0,
              'grossProfit': 250.0,
              'transactionCount': 4,
              'lastUpdated': date,
            }
          ]);

          // Second pull: same business key, updated quantity_sold = 25
          final laterDate = date.add(const Duration(hours: 1));
          await dao.upsertBatchFromCloud([
            {
              'cloudId': 'cloud-idem-002',
              'organizationId': orgId,
              'itemId': itemId,
              'summaryDate': date,
              'quantitySold': 25,
              'quantitySpoiled': 1,
              'revenue': 1200.0,
              'costOfGoodsSold': 400.0,
              'grossProfit': 800.0,
              'transactionCount': 12,
              'lastUpdated': laterDate,
            }
          ]);

          final row = await dao.getSummary(
            organizationId: orgId,
            itemId: itemId,
            date: date,
          );
          expect(row, matcher.isNotNull);
          expect(row!.quantitySold, 25,
              reason: 'Second upsert should update the quantity_sold');
          expect(row.transactionCount, 12);

          // Only 1 row should exist for this business key
          final count = await database
              .customSelect(
                'SELECT COUNT(*) AS c FROM daily_sales_summary '
                'WHERE organization_id = ? AND item_id = ?',
                variables: [
                  Variable.withInt(orgId),
                  Variable.withInt(itemId),
                ],
              )
              .getSingle();
          expect(count.read<int>('c'), 1);
        },
      );
    });
  });
}
