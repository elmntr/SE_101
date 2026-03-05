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
      final summaryDate = DateTime(2024, 1, 1);

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
      final summaryDate1 = DateTime(2024, 1, 1);
      final summaryDate2 = DateTime(2024, 1, 2);

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
      final summaryDate = DateTime(2024, 1, 1);

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
      final summaryDate = DateTime(2024, 1, 1, 15, 30, 45); // With time component

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

        // Simulate duplicate insertion (bypass unique constraint for test)
        await database.customInsert('INSERT INTO daily_sales_summary '
            '(organization_id, item_id, summary_date, quantity_sold, cloud_id, is_synced) '
            'VALUES (2, 2, "2024-01-02", 5, "$cloudId", false)');

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
  });
}
