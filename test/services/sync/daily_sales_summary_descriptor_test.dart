// test/services/sync/daily_sales_summary_descriptor_test.dart

import 'package:flutter_test/flutter_test.dart';

import '../../../lib/services/sync/descriptors/daily_sales_summary_descriptor.dart';
import '../../../lib/services/sync/table_sync_descriptor.dart';
import '../../../lib/services/sync/sync_conflict.dart';

void main() {
  group('DailySalesSummaryDescriptor Tests', () {
    test('should have correct configuration for business key conflict resolution', () {
      // Assert
      expect(dailySalesSummaryDescriptor.tableName, equals('daily_sales_summary'));
      expect(dailySalesSummaryDescriptor.cloudTableName, equals('daily_sales_summary'));
      expect(dailySalesSummaryDescriptor.conflictResolution, equals(ConflictResolution.lastWriteWins));
      expect(dailySalesSummaryDescriptor.dependencyTier, equals(4));
      expect(dailySalesSummaryDescriptor.incrementalSync, isTrue);
      expect(dailySalesSummaryDescriptor.pullLimit, equals(500));
      
      // Business key configuration
      expect(dailySalesSummaryDescriptor.businessKeyFields, 
             equals(['organizationId', 'itemId', 'summaryDate']));
      expect(dailySalesSummaryDescriptor.businessKeyFields.length, equals(3));
      
      // Organization field
      expect(dailySalesSummaryDescriptor.organizationField, equals('organization_id'));
      
      // Push permissions
      expect(dailySalesSummaryDescriptor.canPushFor('franchisee'), isTrue);
      expect(dailySalesSummaryDescriptor.canPushFor('commissary'), isTrue);
      expect(dailySalesSummaryDescriptor.canPushFor(null), isTrue);
    });

    test('should have correct foreign key mappings', () {
      // Assert
      expect(dailySalesSummaryDescriptor.foreignKeys.length, equals(2));
      
      final orgFk = dailySalesSummaryDescriptor.foreignKeys[0];
      expect(orgFk.localField, equals('organizationId'));
      expect(orgFk.cloudField, equals('organization_id'));
      expect(orgFk.referenceTable, equals('organizations'));
      expect(orgFk.required, isTrue);
      expect(orgFk.cloudUsesUuid, isTrue);
      
      final itemFk = dailySalesSummaryDescriptor.foreignKeys[1];
      expect(itemFk.localField, equals('itemId'));
      expect(itemFk.cloudField, equals('item_id'));
      expect(itemFk.referenceTable, equals('items'));
      expect(itemFk.required, isTrue);
      expect(itemFk.cloudUsesUuid, isTrue);
    });

    test('should have correct field mappings', () {
      // Assert
      expect(dailySalesSummaryDescriptor.fieldMappings.length, equals(9));
      
      // Check business key field mapping
      final summaryDateMapping = dailySalesSummaryDescriptor.fieldMappings
          .firstWhere((mapping) => mapping.localField == 'summaryDate');
      expect(summaryDateMapping.cloudField, equals('summary_date'));
      
      // Check sales metrics mappings
      final quantitySoldMapping = dailySalesSummaryDescriptor.fieldMappings
          .firstWhere((mapping) => mapping.localField == 'quantitySold');
      expect(quantitySoldMapping.cloudField, equals('quantity_sold'));
      
      final revenueMapping = dailySalesSummaryDescriptor.fieldMappings
          .firstWhere((mapping) => mapping.localField == 'revenue');
      expect(revenueMapping.cloudField, equals('revenue'));
      
      // Check timestamp mappings
      final createdAtMapping = dailySalesSummaryDescriptor.fieldMappings
          .firstWhere((mapping) => mapping.localField == 'createdAt');
      expect(createdAtMapping.cloudField, equals('created_at'));
      
      final lastUpdatedMapping = dailySalesSummaryDescriptor.fieldMappings
          .firstWhere((mapping) => mapping.localField == 'lastUpdated');
      expect(lastUpdatedMapping.cloudField, equals('last_updated'));
    });

    test('should convert local to cloud format correctly', () {
      // Arrange
      final localData = {
        'organizationId': 1,
        'itemId': 2,
        'summaryDate': DateTime(2024, 1, 1, 15, 30, 45),
        'quantitySold': 10,
        'quantitySpoiled': 2,
        'revenue': 150.0,
        'costOfGoodsSold': 75.0,
        'grossProfit': 75.0,
        'transactionCount': 8,
        'openingStock': 20,
        'closingStock': 8,
        'createdAt': DateTime(2024, 1, 1, 10, 0, 0),
        'lastUpdated': DateTime(2024, 1, 1, 16, 0, 0),
      };

      // Mock getCloudId function
      String? getCloudId(String table, int? localId) {
        if (table == 'organizations' && localId == 1) return 'org-uuid-123';
        if (table == 'items' && localId == 2) return 'item-uuid-456';
        return null;
      }

      // Act
      final cloudData = dailySalesSummaryDescriptor.toCloudFormat(
        localData,
        getCloudId: getCloudId,
        cloudIdValue: 'test-cloud-id-789',
      );

      // Assert
      expect(cloudData['cloud_id'], equals('test-cloud-id-789'));
      expect(cloudData['organization_id'], equals('org-uuid-123'));
      expect(cloudData['item_id'], equals('item-uuid-456'));
      expect(cloudData['summary_date'], equals('2024-01-01T15:30:45.000Z'));
      expect(cloudData['quantity_sold'], equals(10));
      expect(cloudData['quantity_spoiled'], equals(2));
      expect(cloudData['revenue'], equals(150.0));
      expect(cloudData['cost_of_goods_sold'], equals(75.0));
      expect(cloudData['gross_profit'], equals(75.0));
      expect(cloudData['transaction_count'], equals(8));
      expect(cloudData['opening_stock'], equals(20));
      expect(cloudData['closing_stock'], equals(8));
      expect(cloudData['created_at'], equals('2024-01-01T10:00:00.000Z'));
      expect(cloudData['last_updated'], equals('2024-01-01T16:00:00.000Z'));
    });

    test('should convert cloud to local format correctly', () {
      // Arrange
      final cloudData = {
        'cloud_id': 'test-cloud-id-789',
        'organization_id': 'org-uuid-123',
        'item_id': 'item-uuid-456',
        'summary_date': '2024-01-01T15:30:45.000Z',
        'quantity_sold': 10,
        'quantity_spoiled': 2,
        'revenue': 150.0,
        'cost_of_goods_sold': 75.0,
        'gross_profit': 75.0,
        'transaction_count': 8,
        'opening_stock': 20,
        'closing_stock': 8,
        'created_at': '2024-01-01T10:00:00.000Z',
        'last_updated': '2024-01-01T16:00:00.000Z',
      };

      // Mock getLocalId function
      int? getLocalId(String table, String? cloudId) {
        if (table == 'organizations' && cloudId == 'org-uuid-123') return 1;
        if (table == 'items' && cloudId == 'item-uuid-456') return 2;
        return null;
      }

      // Act
      final localData = dailySalesSummaryDescriptor.toLocalFormat(
        cloudData,
        getLocalId: getLocalId,
      );

      // Assert
      expect(localData['cloudId'], equals('test-cloud-id-789'));
      expect(localData['organizationId'], equals(1));
      expect(localData['itemId'], equals(2));
      expect(localData['summaryDate'], isA<DateTime>());
      expect(localData['summaryDate'].year, equals(2024));
      expect(localData['summaryDate'].month, equals(1));
      expect(localData['summaryDate'].day, equals(1));
      expect(localData['quantitySold'], equals(10));
      expect(localData['quantitySpoiled'], equals(2));
      expect(localData['revenue'], equals(150.0));
      expect(localData['costOfGoodsSold'], equals(75.0));
      expect(localData['grossProfit'], equals(75.0));
      expect(localData['transactionCount'], equals(8));
      expect(localData['openingStock'], equals(20));
      expect(localData['closingStock'], equals(8));
      expect(localData['createdAt'], isA<DateTime>());
      expect(localData['lastUpdated'], isA<DateTime>());
    });

    test('should return empty map when FK resolution fails', () {
      // Arrange
      final cloudData = {
        'cloud_id': 'test-cloud-id-789',
        'organization_id': 'unknown-org-uuid',
        'item_id': 'unknown-item-uuid',
        'summary_date': '2024-01-01T15:30:45.000Z',
        'quantity_sold': 10,
      };

      // Mock getLocalId function that returns null (FK not found)
      int? getLocalId(String table, String? cloudId) => null;

      // Act
      final localData = dailySalesSummaryDescriptor.toLocalFormat(
        cloudData,
        getLocalId: getLocalId,
      );

      // Assert
      expect(localData, isEmpty); // Should return empty map when FK resolution fails
    });

    test('should handle optional FK gracefully', () {
      // This test verifies that if we had optional FKs, they would be handled correctly
      // Currently all FKs are required for daily_sales_summary
      
      // Arrange
      final cloudData = {
        'cloud_id': 'test-cloud-id-789',
        'organization_id': 'org-uuid-123',
        'item_id': 'item-uuid-456',
        'summary_date': '2024-01-01T15:30:45.000Z',
        'quantity_sold': 10,
      };

      // Mock getLocalId function
      int? getLocalId(String table, String? cloudId) {
        if (table == 'organizations' && cloudId == 'org-uuid-123') return 1;
        if (table == 'items' && cloudId == 'item-uuid-456') return 2;
        return null;
      }

      // Act
      final localData = dailySalesSummaryDescriptor.toLocalFormat(
        cloudData,
        getLocalId: getLocalId,
      );

      // Assert
      expect(localData, isNotEmpty);
      expect(localData['organizationId'], equals(1));
      expect(localData['itemId'], equals(2));
    });
  });
}
