import 'package:flutter_test/flutter_test.dart';

import 'package:chickenjoo_inventory/utils/sync_status.dart';

void main() {
  group('SyncStatus Enum Tests', () {
    group('Enum Values Tests', () {
      test('should have idle value', () {
        expect(SyncStatus.idle, isNotNull);
        expect(SyncStatus.idle, isA<SyncStatus>());
      });

      test('should have syncing value', () {
        expect(SyncStatus.syncing, isNotNull);
        expect(SyncStatus.syncing, isA<SyncStatus>());
      });

      test('should have synced value', () {
        expect(SyncStatus.synced, isNotNull);
        expect(SyncStatus.synced, isA<SyncStatus>());
      });

      test('should have error value', () {
        expect(SyncStatus.error, isNotNull);
        expect(SyncStatus.error, isA<SyncStatus>());
      });

      test('should have exactly 4 values', () {
        final allValues = SyncStatus.values;
        expect(allValues.length, equals(4));
      });

      test('should contain all expected values in values list', () {
        final allValues = SyncStatus.values;
        expect(allValues, contains(SyncStatus.idle));
        expect(allValues, contains(SyncStatus.syncing));
        expect(allValues, contains(SyncStatus.synced));
        expect(allValues, contains(SyncStatus.error));
      });

      test('should have correct index positions', () {
        expect(SyncStatus.idle.index, equals(0));
        expect(SyncStatus.syncing.index, equals(1));
        expect(SyncStatus.synced.index, equals(2));
        expect(SyncStatus.error.index, equals(3));
      });
    });

    // Negative Tests
    group('Enum Edge Cases Tests', () {
      test('should throw error for invalid enum name', () {
        expect(() => SyncStatus.values.byName('invalid'), throwsA(isA<ArgumentError>()));
      });

      test('should handle empty string byName', () {
        expect(() => SyncStatus.values.byName(''), throwsA(isA<ArgumentError>()));
      });

      test('should handle case-sensitive byName', () {
        expect(() => SyncStatus.values.byName('IDLE'), throwsA(isA<ArgumentError>()));
      });

      test('should handle whitespace in byName', () {
        expect(() => SyncStatus.values.byName(' idle'), throwsA(isA<ArgumentError>()));
      });

      test('should handle null-like strings correctly', () {
        expect(() => SyncStatus.values.byName('null'), throwsA(isA<ArgumentError>()));
      });

      test('should compare different values correctly', () {
        expect(SyncStatus.idle == SyncStatus.syncing, isFalse);
        expect(SyncStatus.syncing == SyncStatus.synced, isFalse);
        expect(SyncStatus.synced == SyncStatus.error, isFalse);
      });

      test('should handle out of range index access safely', () {
        expect(() => SyncStatus.values[100], throwsA(isA<RangeError>()));
      });

      test('should handle negative index access safely', () {
        expect(() => SyncStatus.values[-1], throwsA(isA<RangeError>()));
      });
    });
  });
}
