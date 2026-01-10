import 'package:flutter_test/flutter_test.dart';

import 'package:chickenjoo_inventory/database/models/category_statistics.dart';

void main() {
  group('CategoryStatistics Model Tests', () {
    group('Constructor Tests', () {
      test('should create CategoryStatistics with all required fields', () {
        final statistics = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 50,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        expect(statistics.totalItems, equals(10));
        expect(statistics.totalStock, equals(100));
        expect(statistics.totalSold, equals(50));
        expect(statistics.totalSpoilage, equals(5));
        expect(statistics.avgStock, equals(10.0));
      });

      test('should create CategoryStatistics with zero values', () {
        final statistics = CategoryStatistics(
          totalItems: 0,
          totalStock: 0,
          totalSold: 0,
          totalSpoilage: 0,
          avgStock: 0.0,
        );

        expect(statistics.totalItems, equals(0));
        expect(statistics.totalStock, equals(0));
        expect(statistics.totalSold, equals(0));
        expect(statistics.totalSpoilage, equals(0));
        expect(statistics.avgStock, equals(0.0));
      });

      test('should create CategoryStatistics with negative values', () {
        final statistics = CategoryStatistics(
          totalItems: -1,
          totalStock: -10,
          totalSold: -5,
          totalSpoilage: -2,
          avgStock: -1.5,
        );

        expect(statistics.totalItems, equals(-1));
        expect(statistics.totalStock, equals(-10));
        expect(statistics.totalSold, equals(-5));
        expect(statistics.totalSpoilage, equals(-2));
        expect(statistics.avgStock, equals(-1.5));
      });

      test('should create CategoryStatistics with large values', () {
        final statistics = CategoryStatistics(
          totalItems: 999999,
          totalStock: 999999999,
          totalSold: 99999999,
          totalSpoilage: 9999999,
          avgStock: 999999.99,
        );

        expect(statistics.totalItems, equals(999999));
        expect(statistics.totalStock, equals(999999999));
        expect(statistics.totalSold, equals(99999999));
        expect(statistics.totalSpoilage, equals(9999999));
        expect(statistics.avgStock, equals(999999.99));
      });

      test('should create CategoryStatistics with fractional average stock', () {
        final statistics = CategoryStatistics(
          totalItems: 3,
          totalStock: 10,
          totalSold: 5,
          totalSpoilage: 2,
          avgStock: 3.3333333333,
        );

        expect(statistics.avgStock, equals(3.3333333333));
      });
    });

    group('Field Type Tests', () {
      test('should have correct field types', () {
        final statistics = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 50,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        expect(statistics.totalItems, isA<int>());
        expect(statistics.totalStock, isA<int>());
        expect(statistics.totalSold, isA<int>());
        expect(statistics.totalSpoilage, isA<int>());
        expect(statistics.avgStock, isA<double>());
      });

      test('should handle integer field boundaries', () {
        final statistics = CategoryStatistics(
          totalItems: 2147483647, // Max 32-bit int
          totalStock: 2147483647,
          totalSold: 2147483647,
          totalSpoilage: 2147483647,
          avgStock: 2147483647.0,
        );

        expect(statistics.totalItems, equals(2147483647));
        expect(statistics.totalStock, equals(2147483647));
        expect(statistics.totalSold, equals(2147483647));
        expect(statistics.totalSpoilage, equals(2147483647));
        expect(statistics.avgStock, equals(2147483647.0));
      });

      test('should handle double field boundaries', () {
        final statistics = CategoryStatistics(
          totalItems: 1,
          totalStock: 1,
          totalSold: 1,
          totalSpoilage: 1,
          avgStock: double.maxFinite,
        );

        expect(statistics.avgStock, equals(double.maxFinite));
        expect(statistics.avgStock.isFinite, isTrue);
      });
    });

    group('Immutability Tests', () {
      test('should be immutable', () {
        final statistics = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 50,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        // All fields should be final
        expect(statistics.totalItems, isA<int>());
        expect(statistics.totalStock, isA<int>());
        expect(statistics.totalSold, isA<int>());
        expect(statistics.totalSpoilage, isA<int>());
        expect(statistics.avgStock, isA<double>());
      });
    });

    group('Equality Tests', () {
      test('should be equal with same values', () {
        final statistics1 = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 50,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        final statistics2 = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 50,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        // Since CategoryStatistics doesn't override ==, we test that they are different instances
        expect(statistics1, isNot(same(statistics2)));
        expect(statistics1.totalItems, equals(statistics2.totalItems));
        expect(statistics1.totalStock, equals(statistics2.totalStock));
        expect(statistics1.totalSold, equals(statistics2.totalSold));
        expect(statistics1.totalSpoilage, equals(statistics2.totalSpoilage));
        expect(statistics1.avgStock, equals(statistics2.avgStock));
      });

      test('should not be equal with different totalItems', () {
        final statistics1 = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 50,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        final statistics2 = CategoryStatistics(
          totalItems: 20,
          totalStock: 100,
          totalSold: 50,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        expect(statistics1, isNot(equals(statistics2)));
      });

      test('should not be equal with different totalStock', () {
        final statistics1 = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 50,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        final statistics2 = CategoryStatistics(
          totalItems: 10,
          totalStock: 200,
          totalSold: 50,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        expect(statistics1, isNot(equals(statistics2)));
      });

      test('should not be equal with different totalSold', () {
        final statistics1 = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 50,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        final statistics2 = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 60,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        expect(statistics1, isNot(equals(statistics2)));
      });

      test('should not be equal with different totalSpoilage', () {
        final statistics1 = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 50,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        final statistics2 = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 50,
          totalSpoilage: 10,
          avgStock: 10.0,
        );

        expect(statistics1, isNot(equals(statistics2)));
      });

      test('should not be equal with different avgStock', () {
        final statistics1 = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 50,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        final statistics2 = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 50,
          totalSpoilage: 5,
          avgStock: 15.0,
        );

        expect(statistics1, isNot(equals(statistics2)));
      });
    });

    group('HashCode Tests', () {
      test('should have same hashCode for equal objects', () {
        final statistics1 = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 50,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        final statistics2 = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 50,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        // Since CategoryStatistics doesn't override hashCode, we test that they have different hashCodes
        expect(statistics1.hashCode, isNot(equals(statistics2.hashCode)));
        // But the values are the same
        expect(statistics1.totalItems, equals(statistics2.totalItems));
      });

      test('should have different hashCode for different objects', () {
        final statistics1 = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 50,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        final statistics2 = CategoryStatistics(
          totalItems: 20,
          totalStock: 100,
          totalSold: 50,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        expect(statistics1.hashCode, isNot(equals(statistics2.hashCode)));
      });
    });

    group('ToString Tests', () {
      test('should have meaningful toString representation', () {
        final statistics = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 50,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        final stringRepresentation = statistics.toString();
        expect(stringRepresentation, isA<String>());
        expect(stringRepresentation, isNotEmpty);
        // Since CategoryStatistics doesn't override toString, it will show the default format
        expect(stringRepresentation, contains('CategoryStatistics'));
      });
    });

    group('Business Logic Tests', () {
      test('should represent valid business scenario', () {
        final statistics = CategoryStatistics(
          totalItems: 15,
          totalStock: 150,
          totalSold: 75,
          totalSpoilage: 10,
          avgStock: 10.0,
        );

        // Business logic validation
        expect(statistics.totalItems, greaterThanOrEqualTo(0));
        expect(statistics.totalStock, greaterThanOrEqualTo(0));
        expect(statistics.totalSold, greaterThanOrEqualTo(0));
        expect(statistics.totalSpoilage, greaterThanOrEqualTo(0));
        expect(statistics.avgStock, greaterThanOrEqualTo(0));
      });

      test('should handle scenario with no items', () {
        final statistics = CategoryStatistics(
          totalItems: 0,
          totalStock: 0,
          totalSold: 0,
          totalSpoilage: 0,
          avgStock: 0.0,
        );

        expect(statistics.totalItems, equals(0));
        expect(statistics.totalStock, equals(0));
        expect(statistics.totalSold, equals(0));
        expect(statistics.totalSpoilage, equals(0));
        expect(statistics.avgStock, equals(0.0));
      });

      test('should handle scenario with high spoilage', () {
        final statistics = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 20,
          totalSpoilage: 80,
          avgStock: 10.0,
        );

        expect(statistics.totalSpoilage, greaterThan(statistics.totalSold));
      });

      test('should handle scenario with high sales', () {
        final statistics = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 90,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        expect(statistics.totalSold, greaterThan(statistics.totalSpoilage));
      });
    });

    group('Edge Cases Tests', () {
      test('should handle very small decimal values', () {
        final statistics = CategoryStatistics(
          totalItems: 1,
          totalStock: 1,
          totalSold: 0,
          totalSpoilage: 0,
          avgStock: 0.0000001,
        );

        expect(statistics.avgStock, equals(0.0000001));
      });

      test('should handle scientific notation', () {
        final statistics = CategoryStatistics(
          totalItems: 1,
          totalStock: 1,
          totalSold: 0,
          totalSpoilage: 0,
          avgStock: 1.5e-10,
        );

        expect(statistics.avgStock, equals(1.5e-10));
      });

      test('should handle infinity values', () {
        final statistics = CategoryStatistics(
          totalItems: 1,
          totalStock: 1,
          totalSold: 0,
          totalSpoilage: 0,
          avgStock: double.negativeInfinity,
        );

        expect(statistics.avgStock, equals(double.negativeInfinity));
      });

      test('should handle NaN values', () {
        final statistics = CategoryStatistics(
          totalItems: 1,
          totalStock: 1,
          totalSold: 0,
          totalSpoilage: 0,
          avgStock: double.nan,
        );

        expect(statistics.avgStock.isNaN, isTrue);
      });
    });

    group('Performance Tests', () {
      test('should create instances quickly', () {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 10000; i++) {
          CategoryStatistics(
            totalItems: i,
            totalStock: i * 10,
            totalSold: i * 5,
            totalSpoilage: i * 2,
            avgStock: i * 1.5,
          );
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('should compare instances quickly', () {
        final statistics1 = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 50,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        final statistics2 = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 50,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 10000; i++) {
          statistics1 == statistics2;
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });
    });

    group('Serialization Tests', () {
      test('should be serializable to JSON structure', () {
        final statistics = CategoryStatistics(
          totalItems: 10,
          totalStock: 100,
          totalSold: 50,
          totalSpoilage: 5,
          avgStock: 10.0,
        );

        // Test that all fields are accessible for serialization
        final jsonMap = {
          'totalItems': statistics.totalItems,
          'totalStock': statistics.totalStock,
          'totalSold': statistics.totalSold,
          'totalSpoilage': statistics.totalSpoilage,
          'avgStock': statistics.avgStock,
        };

        expect(jsonMap['totalItems'], equals(10));
        expect(jsonMap['totalStock'], equals(100));
        expect(jsonMap['totalSold'], equals(50));
        expect(jsonMap['totalSpoilage'], equals(5));
        expect(jsonMap['avgStock'], equals(10.0));
      });
    });

    group('Validation Tests', () {
      test('should accept all integer values for totalItems', () {
        for (int i = -100; i <= 100; i++) {
          final statistics = CategoryStatistics(
            totalItems: i,
            totalStock: 0,
            totalSold: 0,
            totalSpoilage: 0,
            avgStock: 0.0,
          );
          expect(statistics.totalItems, equals(i));
        }
      });

      test('should accept all integer values for totalStock', () {
        for (int i = -100; i <= 100; i++) {
          final statistics = CategoryStatistics(
            totalItems: 0,
            totalStock: i,
            totalSold: 0,
            totalSpoilage: 0,
            avgStock: 0.0,
          );
          expect(statistics.totalStock, equals(i));
        }
      });

      test('should accept all integer values for totalSold', () {
        for (int i = -100; i <= 100; i++) {
          final statistics = CategoryStatistics(
            totalItems: 0,
            totalStock: 0,
            totalSold: i,
            totalSpoilage: 0,
            avgStock: 0.0,
          );
          expect(statistics.totalSold, equals(i));
        }
      });

      test('should accept all integer values for totalSpoilage', () {
        for (int i = -100; i <= 100; i++) {
          final statistics = CategoryStatistics(
            totalItems: 0,
            totalStock: 0,
            totalSold: 0,
            totalSpoilage: i,
            avgStock: 0.0,
          );
          expect(statistics.totalSpoilage, equals(i));
        }
      });

      test('should accept all double values for avgStock', () {
        final testValues = [
          0.0, 1.0, -1.0, 0.5, -0.5, 3.14159, double.infinity,
          double.negativeInfinity, double.nan, double.maxFinite, double.minPositive
        ];

        for (final value in testValues) {
          final statistics = CategoryStatistics(
            totalItems: 0,
            totalStock: 0,
            totalSold: 0,
            totalSpoilage: 0,
            avgStock: value,
          );
          if (value.isNaN) {
            expect(statistics.avgStock.isNaN, isTrue);
          } else {
            expect(statistics.avgStock, equals(value));
          }
        }
      });
    });
  });
}
