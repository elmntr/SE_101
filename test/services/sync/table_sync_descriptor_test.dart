// test/services/sync/table_sync_descriptor_test.dart

import 'package:flutter_test/flutter_test.dart';

import 'package:chickenjoo_inventory/services/sync/sync_conflict.dart';
import 'package:chickenjoo_inventory/services/sync/table_sync_descriptor.dart';

void main() {
  group('ForeignKeyMapping', () {
    test('should create with required fields', () {
      final fk = ForeignKeyMapping(
        localField: 'organizationId',
        cloudField: 'organization_id',
        referenceTable: 'organizations',
      );

      expect(fk.localField, 'organizationId');
      expect(fk.cloudField, 'organization_id');
      expect(fk.referenceTable, 'organizations');
      expect(fk.required, isTrue); // default
      expect(fk.cloudUsesUuid, isTrue); // default
    });

    test('should create with optional fields', () {
      final fk = ForeignKeyMapping(
        localField: 'commissaryId',
        cloudField: 'commissary_id',
        referenceTable: 'organizations',
        required: false,
        cloudUsesUuid: false,
      );

      expect(fk.required, isFalse);
      expect(fk.cloudUsesUuid, isFalse);
    });
  });

  group('FieldMapping', () {
    test('should create basic field mapping', () {
      final mapping = FieldMapping(
        localField: 'name',
        cloudField: 'name',
      );

      expect(mapping.localField, 'name');
      expect(mapping.cloudField, 'name');
      expect(mapping.pushable, isTrue); // default
      expect(mapping.pullable, isTrue); // default
      expect(mapping.toCloud, isNull);
      expect(mapping.fromCloud, isNull);
    });

    test('should create with transform functions', () {
      final mapping = FieldMapping(
        localField: 'status',
        cloudField: 'status',
        toCloud: (v) => v.toString().toUpperCase(),
        fromCloud: (v) => v.toString().toLowerCase(),
      );

      expect(mapping.toCloud!('pending'), 'PENDING');
      expect(mapping.fromCloud!('APPROVED'), 'approved');
    });

    test('should create with pushable/pullable flags', () {
      final mapping = FieldMapping(
        localField: 'localOnly',
        cloudField: 'local_only',
        pushable: false,
        pullable: true,
      );

      expect(mapping.pushable, isFalse);
      expect(mapping.pullable, isTrue);
    });

    group('factory FieldMapping.simple', () {
      test('should create simple mapping', () {
        final mapping = FieldMapping.simple('userName', 'user_name');
        expect(mapping.localField, 'userName');
        expect(mapping.cloudField, 'user_name');
      });
    });

    group('factory FieldMapping.dateTime', () {
      test('should convert DateTime to ISO string', () {
        final mapping = FieldMapping.dateTime('createdAt', 'created_at');
        final date = DateTime(2024, 1, 15, 10, 30);

        final cloudValue = mapping.toCloud!(date);
        expect(cloudValue, '2024-01-15T10:30:00.000');
      });

      test('should parse ISO string to DateTime', () {
        final mapping = FieldMapping.dateTime('createdAt', 'created_at');

        final localValue = mapping.fromCloud!('2024-01-15T10:30:00.000Z');
        expect(localValue, isA<DateTime>());
        expect((localValue as DateTime).year, 2024);
        expect(localValue.month, 1);
        expect(localValue.day, 15);
      });

      test('should handle null values', () {
        final mapping = FieldMapping.dateTime('lastUpdated', 'last_updated');
        expect(mapping.fromCloud!(null), isNull);
      });
    });

    group('factory FieldMapping.boolean', () {
      test('should convert bool to bool', () {
        final mapping = FieldMapping.boolean('isActive', 'is_active');

        expect(mapping.toCloud!(true), isTrue);
        expect(mapping.toCloud!(false), isFalse);
      });

      test('should convert int to bool', () {
        final mapping = FieldMapping.boolean('isActive', 'is_active');

        expect(mapping.toCloud!(1), isTrue);
        expect(mapping.toCloud!(0), isFalse);
        expect(mapping.fromCloud!(1), isTrue);
        expect(mapping.fromCloud!(0), isFalse);
      });
    });
  });

  group('TableSyncDescriptor', () {
    late TableSyncDescriptor<dynamic> descriptor;

    setUp(() {
      descriptor = TableSyncDescriptor(
        tableName: 'items',
        cloudTableName: 'items',
        conflictResolution: ConflictResolution.lastWriteWins,
        foreignKeys: [
          const ForeignKeyMapping(
            localField: 'organizationId',
            cloudField: 'organization_id',
            referenceTable: 'organizations',
          ),
        ],
        fieldMappings: [
          FieldMapping.simple('name', 'name'),
          FieldMapping.simple('description', 'description'),
          FieldMapping.simple('price', 'price'),
          FieldMapping.dateTime('createdAt', 'created_at'),
          FieldMapping.dateTime('lastUpdated', 'last_updated'),
          FieldMapping.boolean('isDeleted', 'is_deleted'),
        ],
        dependencyTier: 2,
      );
    });

    test('should create with all properties', () {
      expect(descriptor.tableName, 'items');
      expect(descriptor.cloudTableName, 'items');
      expect(descriptor.conflictResolution, ConflictResolution.lastWriteWins);
      expect(descriptor.foreignKeys.length, 1);
      expect(descriptor.fieldMappings.length, 6);
      expect(descriptor.dependencyTier, 2);
    });

    test('should have correct defaults', () {
      final defaultDescriptor = const TableSyncDescriptor(
        tableName: 'test',
        cloudTableName: 'test',
      );

      expect(defaultDescriptor.conflictResolution, ConflictResolution.lastWriteWins);
      expect(defaultDescriptor.incrementalSync, isTrue);
      expect(defaultDescriptor.pullLimit, 500);
      expect(defaultDescriptor.pushBatchSize, 50);
      expect(defaultDescriptor.softDeleteField, 'is_deleted');
      expect(defaultDescriptor.dependencyTier, 1);
    });

    group('canPushFor', () {
      test('should return true when canPush is null', () {
        final desc = const TableSyncDescriptor(
          tableName: 'items',
          cloudTableName: 'items',
        );

        expect(desc.canPushFor('commissary'), isTrue);
        expect(desc.canPushFor('franchisee'), isTrue);
        expect(desc.canPushFor(null), isTrue);
      });

      test('should delegate to canPush callback when provided', () {
        final desc = TableSyncDescriptor(
          tableName: 'items',
          cloudTableName: 'items',
          canPush: (orgType) => orgType == 'commissary',
        );

        expect(desc.canPushFor('commissary'), isTrue);
        expect(desc.canPushFor('franchisee'), isFalse);
      });
    });

    group('getCloudFieldName', () {
      test('should return mapped cloud field name', () {
        expect(descriptor.getCloudFieldName('name'), 'name');
        expect(descriptor.getCloudFieldName('createdAt'), 'created_at');
        expect(descriptor.getCloudFieldName('isDeleted'), 'is_deleted');
      });

      test('should convert unmapped camelCase to snake_case', () {
        expect(descriptor.getCloudFieldName('unmappedField'), 'unmapped_field');
        expect(descriptor.getCloudFieldName('myTestValue'), 'my_test_value');
      });
    });

    group('getLocalFieldName', () {
      test('should return mapped local field name', () {
        expect(descriptor.getLocalFieldName('name'), 'name');
        expect(descriptor.getLocalFieldName('created_at'), 'createdAt');
        expect(descriptor.getLocalFieldName('is_deleted'), 'isDeleted');
      });

      test('should convert unmapped snake_case to camelCase', () {
        expect(descriptor.getLocalFieldName('unmapped_field'), 'unmappedField');
        expect(descriptor.getLocalFieldName('my_test_value'), 'myTestValue');
      });
    });

    group('toCloudFormat', () {
      test('should convert local record to cloud format', () {
        final localData = {
          'id': 1,
          'name': 'Test Item',
          'description': 'A test item',
          'price': 100,
          'organizationId': 5,
          'createdAt': DateTime(2024, 1, 15),
          'lastUpdated': DateTime(2024, 1, 16),
          'isDeleted': false,
        };

        String? getCloudId(String table, int? localId) {
          if (table == 'organizations' && localId == 5) {
            return 'org-uuid-123';
          }
          return null;
        }

        final cloudData = descriptor.toCloudFormat(
          localData,
          getCloudId: getCloudId,
          cloudIdValue: 'item-uuid-456',
        );

        expect(cloudData['cloud_id'], 'item-uuid-456');
        expect(cloudData['name'], 'Test Item');
        expect(cloudData['description'], 'A test item');
        expect(cloudData['price'], 100);
        expect(cloudData['organization_id'], 'org-uuid-123');
        expect(cloudData['is_deleted'], isFalse);
        expect(cloudData['created_at'], '2024-01-15T00:00:00.000');
      });

      test('should return empty map when required FK not resolved', () {
        final localData = {
          'id': 1,
          'name': 'Test Item',
          'organizationId': 999, // FK not found
        };

        final cloudData = descriptor.toCloudFormat(
          localData,
          getCloudId: (_, __) => null,
          cloudIdValue: 'item-uuid-456',
        );

        expect(cloudData, isEmpty);
      });

      test('should skip optional FK when not resolved', () {
        final descWithOptionalFk = TableSyncDescriptor(
          tableName: 'items',
          cloudTableName: 'items',
          foreignKeys: [
            const ForeignKeyMapping(
              localField: 'categoryId',
              cloudField: 'category_id',
              referenceTable: 'categories',
              required: false,
            ),
          ],
          fieldMappings: [
            FieldMapping.simple('name', 'name'),
          ],
        );

        final localData = {
          'name': 'Test Item',
          'categoryId': null,
        };

        final cloudData = descWithOptionalFk.toCloudFormat(
          localData,
          getCloudId: (_, __) => null,
          cloudIdValue: 'item-uuid-456',
        );

        expect(cloudData.isNotEmpty, isTrue);
        expect(cloudData['name'], 'Test Item');
        expect(cloudData.containsKey('category_id'), isFalse);
      });

      test('should handle FK with cloudUsesUuid=false', () {
        final descWithIntFk = TableSyncDescriptor(
          tableName: 'ingredients',
          cloudTableName: 'ingredients',
          foreignKeys: [
            const ForeignKeyMapping(
              localField: 'commissaryId',
              cloudField: 'commissary_id',
              referenceTable: 'organizations',
              cloudUsesUuid: false,
            ),
          ],
          fieldMappings: [
            FieldMapping.simple('name', 'name'),
          ],
        );

        final localData = {
          'name': 'Test Ingredient',
          'commissaryId': 5,
        };

        final cloudData = descWithIntFk.toCloudFormat(
          localData,
          getCloudId: (_, __) => null, // Shouldn't be called
          cloudIdValue: 'ing-uuid-789',
        );

        expect(cloudData['commissary_id'], 5); // Integer, not UUID
      });

      test('should skip non-pushable fields', () {
        final descWithNonPushable = TableSyncDescriptor(
          tableName: 'items',
          cloudTableName: 'items',
          fieldMappings: [
            FieldMapping.simple('name', 'name'),
            const FieldMapping(
              localField: 'localOnlyField',
              cloudField: 'local_only_field',
              pushable: false,
            ),
          ],
        );

        final localData = {
          'name': 'Test',
          'localOnlyField': 'should not appear',
        };

        final cloudData = descWithNonPushable.toCloudFormat(
          localData,
          getCloudId: (_, __) => null,
          cloudIdValue: 'uuid',
        );

        expect(cloudData['name'], 'Test');
        expect(cloudData.containsKey('local_only_field'), isFalse);
      });
    });

    group('toLocalFormat', () {
      test('should convert cloud record to local format', () {
        final cloudData = {
          'cloud_id': 'item-uuid-456',
          'name': 'Cloud Item',
          'description': 'From cloud',
          'price': 200,
          'organization_id': 'org-uuid-123',
          'created_at': '2024-01-15T00:00:00.000Z',
          'last_updated': '2024-01-16T00:00:00.000Z',
          'is_deleted': true,
        };

        int? getLocalId(String table, String? cloudId) {
          if (table == 'organizations' && cloudId == 'org-uuid-123') {
            return 5;
          }
          return null;
        }

        final localData = descriptor.toLocalFormat(
          cloudData,
          getLocalId: getLocalId,
        );

        expect(localData['cloudId'], 'item-uuid-456');
        expect(localData['name'], 'Cloud Item');
        expect(localData['description'], 'From cloud');
        expect(localData['price'], 200);
        expect(localData['organizationId'], 5);
        expect(localData['isDeleted'], isTrue);
        expect(localData['createdAt'], isA<DateTime>());
      });

      test('should return empty map when required FK not resolved', () {
        final cloudData = {
          'cloud_id': 'item-uuid-456',
          'name': 'Cloud Item',
          'organization_id': 'unknown-org-uuid',
        };

        final localData = descriptor.toLocalFormat(
          cloudData,
          getLocalId: (_, __) => null,
        );

        expect(localData, isEmpty);
      });

      test('should skip optional FK when not resolved', () {
        final descWithOptionalFk = TableSyncDescriptor(
          tableName: 'items',
          cloudTableName: 'items',
          foreignKeys: [
            const ForeignKeyMapping(
              localField: 'categoryId',
              cloudField: 'category_id',
              referenceTable: 'categories',
              required: false,
            ),
          ],
          fieldMappings: [
            FieldMapping.simple('name', 'name'),
          ],
        );

        final cloudData = {
          'cloud_id': 'item-uuid-456',
          'name': 'Cloud Item',
          'category_id': null,
        };

        final localData = descWithOptionalFk.toLocalFormat(
          cloudData,
          getLocalId: (_, __) => null,
        );

        expect(localData.isNotEmpty, isTrue);
        expect(localData['name'], 'Cloud Item');
      });

      test('should handle FK with cloudUsesUuid=false', () {
        final descWithIntFk = TableSyncDescriptor(
          tableName: 'ingredients',
          cloudTableName: 'ingredients',
          foreignKeys: [
            const ForeignKeyMapping(
              localField: 'commissaryId',
              cloudField: 'commissary_id',
              referenceTable: 'organizations',
              cloudUsesUuid: false,
            ),
          ],
          fieldMappings: [
            FieldMapping.simple('name', 'name'),
          ],
        );

        final cloudData = {
          'cloud_id': 'ing-uuid-789',
          'name': 'Cloud Ingredient',
          'commissary_id': 5,
        };

        final localData = descWithIntFk.toLocalFormat(
          cloudData,
          getLocalId: (_, __) => null, // Shouldn't be called for int FK
        );

        expect(localData['commissaryId'], 5); // Integer directly
      });

      test('should skip non-pullable fields', () {
        final descWithNonPullable = TableSyncDescriptor(
          tableName: 'items',
          cloudTableName: 'items',
          fieldMappings: [
            FieldMapping.simple('name', 'name'),
            const FieldMapping(
              localField: 'cloudOnlyField',
              cloudField: 'cloud_only_field',
              pullable: false,
            ),
          ],
        );

        final cloudData = {
          'cloud_id': 'uuid',
          'name': 'Test',
          'cloud_only_field': 'should not appear',
        };

        final localData = descWithNonPullable.toLocalFormat(
          cloudData,
          getLocalId: (_, __) => null,
        );

        expect(localData['name'], 'Test');
        expect(localData.containsKey('cloudOnlyField'), isFalse);
      });
    });
  });

  group('String case conversion', () {
    // Test the static helpers indirectly through getCloudFieldName/getLocalFieldName

    test('camelCase to snake_case conversions', () {
      final desc = const TableSyncDescriptor(
        tableName: 'test',
        cloudTableName: 'test',
      );

      // Simple cases
      expect(desc.getCloudFieldName('myField'), 'my_field');
      expect(desc.getCloudFieldName('userName'), 'user_name');

      // Multiple capitals
      expect(desc.getCloudFieldName('myLongFieldName'), 'my_long_field_name');

      // No capitals
      expect(desc.getCloudFieldName('name'), 'name');

      // Starting with lowercase
      expect(desc.getCloudFieldName('organizationId'), 'organization_id');
    });

    test('snake_case to camelCase conversions', () {
      final desc = const TableSyncDescriptor(
        tableName: 'test',
        cloudTableName: 'test',
      );

      // Simple cases
      expect(desc.getLocalFieldName('my_field'), 'myField');
      expect(desc.getLocalFieldName('user_name'), 'userName');

      // Multiple underscores
      expect(desc.getLocalFieldName('my_long_field_name'), 'myLongFieldName');

      // No underscores
      expect(desc.getLocalFieldName('name'), 'name');

      // UUID field
      expect(desc.getLocalFieldName('organization_id'), 'organizationId');
    });
  });

  group('CommonFieldMappings extension', () {
    test('withSyncFields should add standard fields', () {
      final baseFields = [
        FieldMapping.simple('name', 'name'),
      ];

      final withSync = CommonFieldMappings.withSyncFields(baseFields);

      expect(withSync.length, 3);
      expect(withSync.any((f) => f.localField == 'createdAt'), isTrue);
      expect(withSync.any((f) => f.localField == 'lastUpdated'), isTrue);
    });

    test('withSoftDelete should add is_deleted field', () {
      final baseFields = [
        FieldMapping.simple('name', 'name'),
      ];

      final withDelete = CommonFieldMappings.withSoftDelete(baseFields);

      expect(withDelete.length, 2);
      expect(withDelete.any((f) => f.localField == 'isDeleted'), isTrue);
    });
  });
}
