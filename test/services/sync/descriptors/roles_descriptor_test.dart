import 'package:flutter_test/flutter_test.dart';
import 'package:chickenjoo_inventory/services/sync/table_sync_descriptor.dart';
import 'package:chickenjoo_inventory/services/sync/sync_conflict.dart';
import 'package:chickenjoo_inventory/services/sync/descriptors/roles_descriptor.dart';

void main() {
  group('rolesDescriptor', () {
    test('1. should have correct table name', () {
      expect(rolesDescriptor.tableName, equals('roles'));
    });

    test('2. should have correct cloud table name', () {
      expect(rolesDescriptor.cloudTableName, equals('roles'));
    });

    test('3. should use lastWriteWins conflict resolution', () {
      expect(rolesDescriptor.conflictResolution, equals(ConflictResolution.lastWriteWins));
    });

    test('4. should be dependency tier 1', () {
      expect(rolesDescriptor.dependencyTier, equals(1));
    });

    test('5. should not use incremental sync', () {
      expect(rolesDescriptor.incrementalSync, isFalse);
    });

    test('6. canPush should return true for commissary', () {
      expect(rolesDescriptor.canPush!('commissary'), isTrue);
    });

    test('7. canPush should return false for franchisee', () {
      expect(rolesDescriptor.canPush!('franchisee'), isFalse);
    });

    test('8. should have no foreign keys', () {
      expect(rolesDescriptor.foreignKeys, isEmpty);
    });

    test('9. should have field mapping for name', () {
      final mapping = rolesDescriptor.fieldMappings
          .where((m) => m.localField == 'name')
          .firstOrNull;
      expect(mapping, isNotNull);
      expect(mapping!.cloudField, equals('name'));
    });

    test('10. should have field mapping for description', () {
      final mapping = rolesDescriptor.fieldMappings
          .where((m) => m.localField == 'description')
          .firstOrNull;
      expect(mapping, isNotNull);
      expect(mapping!.cloudField, equals('description'));
    });

    test('11. should have boolean mapping for canViewInventory', () {
      final mapping = rolesDescriptor.fieldMappings
          .where((m) => m.localField == 'canViewInventory')
          .firstOrNull;
      expect(mapping, isNotNull);
      expect(mapping!.cloudField, equals('can_view_inventory'));
    });

    test('12. should have boolean mapping for canManageEmployees', () {
      final mapping = rolesDescriptor.fieldMappings
          .where((m) => m.localField == 'canManageEmployees')
          .firstOrNull;
      expect(mapping, isNotNull);
      expect(mapping!.cloudField, equals('can_manage_employees'));
    });

    test('13. should have boolean mapping for isSystemRole', () {
      final mapping = rolesDescriptor.fieldMappings
          .where((m) => m.localField == 'isSystemRole')
          .firstOrNull;
      expect(mapping, isNotNull);
      expect(mapping!.cloudField, equals('is_system_role'));
    });

    test('14. should have 16 field mappings total', () {
      expect(rolesDescriptor.fieldMappings.length, equals(16));
    });

    test('15. should have dateTime mapping for createdAt and lastUpdated', () {
      final createdAt = rolesDescriptor.fieldMappings
          .where((m) => m.localField == 'createdAt')
          .firstOrNull;
      final lastUpdated = rolesDescriptor.fieldMappings
          .where((m) => m.localField == 'lastUpdated')
          .firstOrNull;
      expect(createdAt, isNotNull);
      expect(lastUpdated, isNotNull);
      expect(createdAt!.cloudField, equals('created_at'));
      expect(lastUpdated!.cloudField, equals('last_updated'));
    });
  });
}
