// test/services/sync/sync_conflict_test.dart

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

import 'package:chickenjoo_inventory/services/sync/sync_conflict.dart';

void main() {
  group('ConflictResolution enum', () {
    test('should have all expected values', () {
      expect(ConflictResolution.values.length, 5);
      expect(ConflictResolution.values, contains(ConflictResolution.lastWriteWins));
      expect(ConflictResolution.values, contains(ConflictResolution.cloudWins));
      expect(ConflictResolution.values, contains(ConflictResolution.localWins));
      expect(ConflictResolution.values, contains(ConflictResolution.statusAware));
      expect(ConflictResolution.values, contains(ConflictResolution.manual));
    });
  });

  group('ConflictType enum', () {
    test('should have all expected values', () {
      expect(ConflictType.values.length, 4);
      expect(ConflictType.values, contains(ConflictType.bothModified));
      expect(ConflictType.values, contains(ConflictType.localDeletedCloudModified));
      expect(ConflictType.values, contains(ConflictType.cloudDeletedLocalModified));
      expect(ConflictType.values, contains(ConflictType.statusConflict));
    });
  });

  group('StatusHierarchy', () {
    group('compare', () {
      test('approved should be higher than rejected', () {
        expect(StatusHierarchy.compare('approved', 'rejected'), greaterThan(0));
      });

      test('rejected should be higher than pending', () {
        expect(StatusHierarchy.compare('rejected', 'pending'), greaterThan(0));
      });

      test('pending should be higher than draft', () {
        expect(StatusHierarchy.compare('pending', 'draft'), greaterThan(0));
      });

      test('same status should compare equal', () {
        expect(StatusHierarchy.compare('approved', 'approved'), equals(0));
        expect(StatusHierarchy.compare('pending', 'pending'), equals(0));
      });

      test('unknown status should have lower priority', () {
        expect(StatusHierarchy.compare('approved', 'unknown'), greaterThan(0));
        expect(StatusHierarchy.compare('unknown', 'approved'), lessThan(0));
      });

      test('null status should have lower priority', () {
        expect(StatusHierarchy.compare('approved', null), greaterThan(0));
        expect(StatusHierarchy.compare(null, 'approved'), lessThan(0));
      });
    });

    group('isMoreAdvanced', () {
      test('approved is more advanced than all others', () {
        expect(StatusHierarchy.isMoreAdvanced('approved', 'rejected'), isTrue);
        expect(StatusHierarchy.isMoreAdvanced('approved', 'pending'), isTrue);
        expect(StatusHierarchy.isMoreAdvanced('approved', 'draft'), isTrue);
      });

      test('rejected is more advanced than pending and draft', () {
        expect(StatusHierarchy.isMoreAdvanced('rejected', 'pending'), isTrue);
        expect(StatusHierarchy.isMoreAdvanced('rejected', 'draft'), isTrue);
      });

      test('rejected is not more advanced than approved', () {
        expect(StatusHierarchy.isMoreAdvanced('rejected', 'approved'), isFalse);
      });

      test('pending is more advanced than draft', () {
        expect(StatusHierarchy.isMoreAdvanced('pending', 'draft'), isTrue);
      });

      test('pending is not more advanced than rejected or approved', () {
        expect(StatusHierarchy.isMoreAdvanced('pending', 'rejected'), isFalse);
        expect(StatusHierarchy.isMoreAdvanced('pending', 'approved'), isFalse);
      });

      test('same status is not more advanced', () {
        expect(StatusHierarchy.isMoreAdvanced('approved', 'approved'), isFalse);
        expect(StatusHierarchy.isMoreAdvanced('pending', 'pending'), isFalse);
      });

      test('null status handling', () {
        expect(StatusHierarchy.isMoreAdvanced('approved', null), isTrue);
        expect(StatusHierarchy.isMoreAdvanced(null, 'approved'), isFalse);
        expect(StatusHierarchy.isMoreAdvanced(null, null), isFalse);
      });
    });
  });

  group('SyncConflictRecord', () {
    test('should create with required fields', () {
      final record = SyncConflictRecord(
        tableName: 'items',
        cloudId: 'uuid-123',
        localData: {'name': 'Local Item'},
        cloudData: {'name': 'Cloud Item'},
        conflictType: ConflictType.bothModified,
      );

      expect(record.tableName, 'items');
      expect(record.cloudId, 'uuid-123');
      expect(record.localData, {'name': 'Local Item'});
      expect(record.cloudData, {'name': 'Cloud Item'});
      expect(record.conflictType, ConflictType.bothModified);
      expect(record.id, isNull);
      expect(record.resolution, isNull);
      expect(record.resolvedAt, isNull);
      expect(record.createdAt, isNotNull);
    });

    test('should create with all fields', () {
      final createdAt = DateTime(2024, 1, 15, 10, 30);
      final resolvedAt = DateTime(2024, 1, 15, 11, 0);

      final record = SyncConflictRecord(
        id: 42,
        tableName: 'users',
        cloudId: 'uuid-456',
        localData: {'email': 'local@test.com'},
        cloudData: {'email': 'cloud@test.com'},
        conflictType: ConflictType.statusConflict,
        resolution: 'cloudWins',
        organizationId: 5,
        createdAt: createdAt,
        resolvedAt: resolvedAt,
      );

      expect(record.id, 42);
      expect(record.tableName, 'users');
      expect(record.organizationId, 5);
      expect(record.resolution, 'cloudWins');
      expect(record.createdAt, createdAt);
      expect(record.resolvedAt, resolvedAt);
    });

    group('fromDb factory', () {
      test('should parse valid database row', () {
        final row = {
          'id': 1,
          'table_name': 'items',
          'cloud_id': 'uuid-789',
          'local_data': '{"name": "Local"}',
          'cloud_data': '{"name": "Cloud"}',
          'conflict_type': 'bothModified',
          'resolution': 'localWins',
          'organization_id': 3,
          'created_at': '2024-01-15T10:30:00.000Z',
          'resolved_at': '2024-01-15T11:00:00.000Z',
        };

        final record = SyncConflictRecord.fromDb(row);

        expect(record.id, 1);
        expect(record.tableName, 'items');
        expect(record.cloudId, 'uuid-789');
        expect(record.localData, {'name': 'Local'});
        expect(record.cloudData, {'name': 'Cloud'});
        expect(record.conflictType, ConflictType.bothModified);
        expect(record.resolution, 'localWins');
        expect(record.organizationId, 3);
        expect(record.resolvedAt, isNotNull);
      });

      test('should handle Map input for JSON fields', () {
        final row = {
          'id': 1,
          'table_name': 'items',
          'cloud_id': 'uuid-789',
          'local_data': {'name': 'Local'},
          'cloud_data': {'name': 'Cloud'},
          'conflict_type': 'bothModified',
          'resolution': null,
          'organization_id': null,
          'created_at': '2024-01-15T10:30:00.000Z',
          'resolved_at': null,
        };

        final record = SyncConflictRecord.fromDb(row);
        expect(record.localData, {'name': 'Local'});
        expect(record.cloudData, {'name': 'Cloud'});
      });

      test('should handle null JSON fields', () {
        final row = {
          'id': 1,
          'table_name': 'items',
          'cloud_id': 'uuid-789',
          'local_data': null,
          'cloud_data': null,
          'conflict_type': 'bothModified',
          'resolution': null,
          'organization_id': null,
          'created_at': '2024-01-15T10:30:00.000Z',
          'resolved_at': null,
        };

        final record = SyncConflictRecord.fromDb(row);
        expect(record.localData, {});
        expect(record.cloudData, {});
      });

      test('should fallback to bothModified for unknown conflict type', () {
        final row = {
          'id': 1,
          'table_name': 'items',
          'cloud_id': 'uuid-789',
          'local_data': '{}',
          'cloud_data': '{}',
          'conflict_type': 'unknownType',
          'resolution': null,
          'organization_id': null,
          'created_at': '2024-01-15T10:30:00.000Z',
          'resolved_at': null,
        };

        final record = SyncConflictRecord.fromDb(row);
        expect(record.conflictType, ConflictType.bothModified);
      });
    });

    group('toDbMap', () {
      test('should convert to database map', () {
        final record = SyncConflictRecord(
          tableName: 'items',
          cloudId: 'uuid-123',
          localData: {'name': 'Local'},
          cloudData: {'name': 'Cloud'},
          conflictType: ConflictType.bothModified,
          organizationId: 5,
        );

        final map = record.toDbMap();

        expect(map['table_name'], 'items');
        expect(map['cloud_id'], 'uuid-123');
        expect(map['conflict_type'], 'bothModified');
        expect(map['organization_id'], 5);
        expect(json.decode(map['local_data']), {'name': 'Local'});
        expect(json.decode(map['cloud_data']), {'name': 'Cloud'});
      });
    });

    group('isResolved', () {
      test('should return false for unresolved conflict', () {
        final record = SyncConflictRecord(
          tableName: 'items',
          cloudId: 'uuid-123',
          localData: {},
          cloudData: {},
          conflictType: ConflictType.bothModified,
        );

        expect(record.isResolved, isFalse);
      });

      test('should return true for resolved conflict', () {
        final record = SyncConflictRecord(
          tableName: 'items',
          cloudId: 'uuid-123',
          localData: {},
          cloudData: {},
          conflictType: ConflictType.bothModified,
          resolvedAt: DateTime.now(),
        );

        expect(record.isResolved, isTrue);
      });
    });

    group('summary', () {
      test('should generate human-readable summary', () {
        final record = SyncConflictRecord(
          tableName: 'items',
          cloudId: 'uuid-123',
          localData: {'last_updated': '2024-01-15'},
          cloudData: {'last_updated': '2024-01-16'},
          conflictType: ConflictType.bothModified,
        );

        expect(record.summary, contains('items'));
        expect(record.summary, contains('conflict'));
      });
    });
  });

  group('JsonEncoder', () {
    const encoder = JsonEncoder();

    test('should encode simple map', () {
      final result = encoder.convert({'name': 'Test', 'value': 123});
      expect(result, contains('"name":"Test"'));
      expect(result, contains('"value":123'));
    });

    test('should encode nested maps', () {
      final result = encoder.convert({
        'outer': {'inner': 'value'}
      });
      expect(result, contains('"outer":{'));
    });

    test('should encode arrays', () {
      final result = encoder.convert({'items': [1, 2, 3]});
      expect(result, contains('[1,2,3]'));
    });

    test('should escape special characters in strings', () {
      final result = encoder.convert({'text': 'line1\nline2'});
      expect(result, contains('\\n'));
    });
  });

  group('JsonDecoder', () {
    const decoder = JsonDecoder();

    test('should decode simple JSON object', () {
      final result = decoder.convert('{"name":"Test","value":123}');
      expect(result, isA<Map>());
      expect(result['name'], 'Test');
      expect(result['value'], 123);
    });

    test('should decode nested objects', () {
      final result = decoder.convert('{"outer":{"inner":"value"}}');
      expect(result['outer']['inner'], 'value');
    });

    test('should decode arrays', () {
      final result = decoder.convert('{"items":[1,2,3]}');
      expect(result['items'], [1, 2, 3]);
    });

    test('should decode boolean values', () {
      final result = decoder.convert('{"active":true,"deleted":false}');
      expect(result['active'], isTrue);
      expect(result['deleted'], isFalse);
    });

    test('should decode null values', () {
      final result = decoder.convert('{"value":null}');
      expect(result['value'], isNull);
    });

    test('should decode floating point numbers', () {
      final result = decoder.convert('{"price":19.99}');
      expect(result['price'], 19.99);
    });
  });
}
