import 'package:flutter_test/flutter_test.dart';
import 'package:chickenjoo_inventory/services/sync/table_sync_descriptor.dart';
import 'package:chickenjoo_inventory/services/sync/sync_conflict.dart';
import 'package:chickenjoo_inventory/services/sync/descriptors/organizations_descriptor.dart';

void main() {
  group('organizationsDescriptor', () {
    test('1. should have correct table name', () {
      expect(organizationsDescriptor.tableName, equals('organizations'));
    });

    test('2. should have correct cloud table name', () {
      expect(organizationsDescriptor.cloudTableName, equals('organizations'));
    });

    test('3. should use lastWriteWins conflict resolution', () {
      expect(organizationsDescriptor.conflictResolution, equals(ConflictResolution.lastWriteWins));
    });

    test('4. should be dependency tier 1', () {
      expect(organizationsDescriptor.dependencyTier, equals(1));
    });

    test('5. should not use incremental sync', () {
      expect(organizationsDescriptor.incrementalSync, isFalse);
    });

    test('6. canPush should return true for commissary', () {
      expect(organizationsDescriptor.canPush!('commissary'), isTrue);
    });

    test('7. canPush should return false for franchisee', () {
      expect(organizationsDescriptor.canPush!('franchisee'), isFalse);
    });

    test('8. should have one foreign key mapping', () {
      expect(organizationsDescriptor.foreignKeys.length, equals(1));
    });

    test('9. foreign key should reference organizations (self-referencing)', () {
      final fk = organizationsDescriptor.foreignKeys.first;
      expect(fk.referenceTable, equals('organizations'));
      expect(fk.localField, equals('parentCommissaryId'));
      expect(fk.cloudField, equals('parent_commissary_id'));
    });

    test('10. foreign key should not be required', () {
      final fk = organizationsDescriptor.foreignKeys.first;
      expect(fk.required, isFalse);
    });

    test('11. foreign key should use cloud UUID', () {
      final fk = organizationsDescriptor.foreignKeys.first;
      expect(fk.cloudUsesUuid, isTrue);
    });

    test('12. should have field mappings for name', () {
      final nameMapping = organizationsDescriptor.fieldMappings
          .where((m) => m.localField == 'name')
          .firstOrNull;
      expect(nameMapping, isNotNull);
      expect(nameMapping!.cloudField, equals('name'));
    });

    test('13. should have field mapping for type', () {
      final typeMapping = organizationsDescriptor.fieldMappings
          .where((m) => m.localField == 'type')
          .firstOrNull;
      expect(typeMapping, isNotNull);
      expect(typeMapping!.cloudField, equals('type'));
    });

    test('14. should have boolean mapping for isActive', () {
      final activeMapping = organizationsDescriptor.fieldMappings
          .where((m) => m.localField == 'isActive')
          .firstOrNull;
      expect(activeMapping, isNotNull);
      expect(activeMapping!.cloudField, equals('is_active'));
    });

    test('15. should have dateTime mappings for timestamps', () {
      final createdAtMapping = organizationsDescriptor.fieldMappings
          .where((m) => m.localField == 'createdAt')
          .firstOrNull;
      final lastUpdatedMapping = organizationsDescriptor.fieldMappings
          .where((m) => m.localField == 'lastUpdated')
          .firstOrNull;
      expect(createdAtMapping, isNotNull);
      expect(lastUpdatedMapping, isNotNull);
      expect(createdAtMapping!.cloudField, equals('created_at'));
      expect(lastUpdatedMapping!.cloudField, equals('last_updated'));
    });
  });
}
