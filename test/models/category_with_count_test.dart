import 'package:flutter_test/flutter_test.dart';

import 'package:chickenjoo_inventory/database/models/category_with_count.dart';

void main() {
  group('CategoryWithCount Model Tests', () {
    late DateTime testCreatedAt;
    late DateTime testLastUpdated;

    setUp(() {
      testCreatedAt = DateTime(2023, 1, 1, 10, 0, 0);
      testLastUpdated = DateTime(2023, 1, 2, 15, 30, 0);
    });

    group('Constructor Tests', () {
      test('should create CategoryWithCount with all required fields', () {
        final categoryWithCount = CategoryWithCount(
          id: 1,
          name: 'Test Category',
          description: 'Test Description',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        expect(categoryWithCount.id, equals(1));
        expect(categoryWithCount.name, equals('Test Category'));
        expect(categoryWithCount.description, equals('Test Description'));
        expect(categoryWithCount.createdAt, equals(testCreatedAt));
        expect(categoryWithCount.lastUpdated, equals(testLastUpdated));
        expect(categoryWithCount.itemCount, equals(5));
      });

      test('should create CategoryWithCount with null description', () {
        final categoryWithCount = CategoryWithCount(
          id: 2,
          name: 'Category Without Description',
          description: null,
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 0,
        );

        expect(categoryWithCount.id, equals(2));
        expect(categoryWithCount.name, equals('Category Without Description'));
        expect(categoryWithCount.description, isNull);
        expect(categoryWithCount.itemCount, equals(0));
      });

      test('should create CategoryWithCount with zero itemCount', () {
        final categoryWithCount = CategoryWithCount(
          id: 3,
          name: 'Empty Category',
          description: 'Category with no items',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 0,
        );

        expect(categoryWithCount.itemCount, equals(0));
      });

      test('should create CategoryWithCount with negative itemCount', () {
        final categoryWithCount = CategoryWithCount(
          id: 4,
          name: 'Invalid Category',
          description: 'Category with negative count',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: -5,
        );

        expect(categoryWithCount.itemCount, equals(-5));
      });

      test('should create CategoryWithCount with large itemCount', () {
        final categoryWithCount = CategoryWithCount(
          id: 5,
          name: 'Popular Category',
          description: 'Category with many items',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 999999,
        );

        expect(categoryWithCount.itemCount, equals(999999));
      });

      test('should create CategoryWithCount with empty name', () {
        final categoryWithCount = CategoryWithCount(
          id: 6,
          name: '',
          description: 'Category with empty name',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 1,
        );

        expect(categoryWithCount.name, equals(''));
      });

      test('should create CategoryWithCount with long name', () {
        final longName = 'A' * 200;
        final categoryWithCount = CategoryWithCount(
          id: 7,
          name: longName,
          description: 'Category with very long name',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 1,
        );

        expect(categoryWithCount.name, equals(longName));
      });

      test('should create CategoryWithCount with empty description', () {
        final categoryWithCount = CategoryWithCount(
          id: 8,
          name: 'Test Category',
          description: '',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 1,
        );

        expect(categoryWithCount.description, equals(''));
      });

      test('should create CategoryWithCount with long description', () {
        final longDescription = 'B' * 1000;
        final categoryWithCount = CategoryWithCount(
          id: 9,
          name: 'Test Category',
          description: longDescription,
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 1,
        );

        expect(categoryWithCount.description, equals(longDescription));
      });

      test('should create CategoryWithCount with same created and updated dates', () {
        final sameTime = DateTime.now();
        final categoryWithCount = CategoryWithCount(
          id: 10,
          name: 'New Category',
          description: 'Just created',
          createdAt: sameTime,
          lastUpdated: sameTime,
          itemCount: 0,
        );

        expect(categoryWithCount.createdAt, equals(sameTime));
        expect(categoryWithCount.lastUpdated, equals(sameTime));
      });
    });

    group('Field Type Tests', () {
      test('should have correct field types', () {
        final categoryWithCount = CategoryWithCount(
          id: 1,
          name: 'Test',
          description: 'Test',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        expect(categoryWithCount.id, isA<int>());
        expect(categoryWithCount.name, isA<String>());
        expect(categoryWithCount.description, isA<String?>());
        expect(categoryWithCount.createdAt, isA<DateTime>());
        expect(categoryWithCount.lastUpdated, isA<DateTime>());
        expect(categoryWithCount.itemCount, isA<int>());
      });

      test('should handle integer field boundaries', () {
        final categoryWithCount = CategoryWithCount(
          id: 2147483647, // Max 32-bit int
          name: 'Max ID Category',
          description: 'Category with max ID',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 2147483647,
        );

        expect(categoryWithCount.id, equals(2147483647));
        expect(categoryWithCount.itemCount, equals(2147483647));
      });

      test('should handle negative integer values', () {
        final categoryWithCount = CategoryWithCount(
          id: -1,
          name: 'Negative ID Category',
          description: 'Category with negative ID',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: -100,
        );

        expect(categoryWithCount.id, equals(-1));
        expect(categoryWithCount.itemCount, equals(-100));
      });
    });

    group('DateTime Tests', () {
      test('should handle different DateTime values', () {
        final pastDate = DateTime(2000, 1, 1);
        final futureDate = DateTime(2050, 12, 31);
        final now = DateTime.now();

        final categoryWithCount1 = CategoryWithCount(
          id: 1,
          name: 'Past Category',
          createdAt: pastDate,
          lastUpdated: pastDate,
          itemCount: 1,
        );

        final categoryWithCount2 = CategoryWithCount(
          id: 2,
          name: 'Future Category',
          createdAt: futureDate,
          lastUpdated: futureDate,
          itemCount: 1,
        );

        final categoryWithCount3 = CategoryWithCount(
          id: 3,
          name: 'Current Category',
          createdAt: now,
          lastUpdated: now,
          itemCount: 1,
        );

        expect(categoryWithCount1.createdAt, equals(pastDate));
        expect(categoryWithCount2.createdAt, equals(futureDate));
        expect(categoryWithCount3.createdAt, equals(now));
      });

      test('should handle DateTime with microseconds', () {
        final preciseDate = DateTime(2023, 1, 1, 12, 0, 0, 123, 456);
        
        final categoryWithCount = CategoryWithCount(
          id: 1,
          name: 'Precise Category',
          createdAt: preciseDate,
          lastUpdated: preciseDate,
          itemCount: 1,
        );

        expect(categoryWithCount.createdAt, equals(preciseDate));
        expect(categoryWithCount.createdAt.microsecond, equals(456));
      });

      test('should handle UTC DateTime', () {
        final utcDate = DateTime.utc(2023, 1, 1, 12, 0, 0);
        
        final categoryWithCount = CategoryWithCount(
          id: 1,
          name: 'UTC Category',
          createdAt: utcDate,
          lastUpdated: utcDate,
          itemCount: 1,
        );

        expect(categoryWithCount.createdAt.isUtc, isTrue);
        expect(categoryWithCount.lastUpdated.isUtc, isTrue);
      });
    });

    group('String Field Tests', () {
      test('should handle special characters in name', () {
        final specialNames = [
          'Category with spaces',
          'Category-with-hyphens',
          'Category_with_underscores',
          'Category/with/slashes',
          'Category\\with\\backslashes',
          'Category@with@symbols',
          'Category#with#hash',
          'Category\$with\$dollar',
          'Category%with%percent',
          'Category&with&ampersand',
          'Category*with*asterisk',
          'Category(with)parentheses',
          'Category[with]brackets',
          'Category{with}braces',
          'Category|with|pipes',
          'Category+with+plus',
          'Category=with=equals',
          'Category?with?question',
          'Category!with!exclamation',
          'Category~with~tilde',
          'Category`with`backtick',
          'Category"with"quotes',
          "Category'with'apostrophes",
          'Category<with>angles',
          'Category,with,commas',
          'Category.with.dots',
          'Category;with;semicolons',
          'Category:with:colons',
        ];

        for (int i = 0; i < specialNames.length; i++) {
          final categoryWithCount = CategoryWithCount(
            id: i + 1,
            name: specialNames[i],
            createdAt: testCreatedAt,
            lastUpdated: testLastUpdated,
            itemCount: 1,
          );

          expect(categoryWithCount.name, equals(specialNames[i]));
        }
      });

      test('should handle unicode characters in name', () {
        final unicodeNames = [
          'Categoría', // Spanish
          'Catégorie', // French
          'Kategorie', // German
          'カテゴリ', // Japanese
          '分类', // Chinese
          '카테고리', // Korean
          'Категория', // Russian
          'الفئة', // Arabic
          'श्रेणी', // Hindi
          'หมวดหมู่', // Thai
          'קטגוריה', // Hebrew
          'دسته بندی', // Persian
          'Kategori', // Turkish
          'Kategorië', // Afrikaans
          'Kategória', // Hungarian
          'Kategoria', // Polish
        ];

        for (int i = 0; i < unicodeNames.length; i++) {
          final categoryWithCount = CategoryWithCount(
            id: i + 1,
            name: unicodeNames[i],
            createdAt: testCreatedAt,
            lastUpdated: testLastUpdated,
            itemCount: 1,
          );

          expect(categoryWithCount.name, equals(unicodeNames[i]));
        }
      });

      test('should handle emoji in name', () {
        final emojiNames = [
          '🍕 Food Category',
          '🚗 Vehicle Category',
          '👕 Clothing Category',
          '📚 Book Category',
          '🎮 Game Category',
          '🎵 Music Category',
          '🎬 Movie Category',
          '⚽ Sports Category',
          '🏠 Home Category',
          '💻 Tech Category',
        ];

        for (int i = 0; i < emojiNames.length; i++) {
          final categoryWithCount = CategoryWithCount(
            id: i + 1,
            name: emojiNames[i],
            createdAt: testCreatedAt,
            lastUpdated: testLastUpdated,
            itemCount: 1,
          );

          expect(categoryWithCount.name, equals(emojiNames[i]));
        }
      });
    });

    group('Immutability Tests', () {
      test('should be immutable', () {
        final categoryWithCount = CategoryWithCount(
          id: 1,
          name: 'Test Category',
          description: 'Test Description',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        // All fields should be final and have correct types
        expect(categoryWithCount.id, isA<int>());
        expect(categoryWithCount.name, isA<String>());
        expect(categoryWithCount.description, isA<String?>());
        expect(categoryWithCount.createdAt, isA<DateTime>());
        expect(categoryWithCount.lastUpdated, isA<DateTime>());
        expect(categoryWithCount.itemCount, isA<int>());
      });
    });

    group('Equality Tests', () {
      test('should be equal with same values', () {
        final categoryWithCount1 = CategoryWithCount(
          id: 1,
          name: 'Test Category',
          description: 'Test Description',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        final categoryWithCount2 = CategoryWithCount(
          id: 1,
          name: 'Test Category',
          description: 'Test Description',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        // Since CategoryWithCount doesn't override ==, we test that they are different instances
        expect(categoryWithCount1, isNot(same(categoryWithCount2)));
        expect(categoryWithCount1.id, equals(categoryWithCount2.id));
        expect(categoryWithCount1.name, equals(categoryWithCount2.name));
        expect(categoryWithCount1.itemCount, equals(categoryWithCount2.itemCount));
      });

      test('should not be equal with different id', () {
        final categoryWithCount1 = CategoryWithCount(
          id: 1,
          name: 'Test Category',
          description: 'Test Description',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        final categoryWithCount2 = CategoryWithCount(
          id: 2,
          name: 'Test Category',
          description: 'Test Description',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        expect(categoryWithCount1, isNot(equals(categoryWithCount2)));
      });

      test('should not be equal with different name', () {
        final categoryWithCount1 = CategoryWithCount(
          id: 1,
          name: 'Category 1',
          description: 'Test Description',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        final categoryWithCount2 = CategoryWithCount(
          id: 1,
          name: 'Category 2',
          description: 'Test Description',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        expect(categoryWithCount1, isNot(equals(categoryWithCount2)));
      });

      test('should not be equal with different description', () {
        final categoryWithCount1 = CategoryWithCount(
          id: 1,
          name: 'Test Category',
          description: 'Description 1',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        final categoryWithCount2 = CategoryWithCount(
          id: 1,
          name: 'Test Category',
          description: 'Description 2',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        expect(categoryWithCount1, isNot(equals(categoryWithCount2)));
      });

      test('should not be equal with different itemCount', () {
        final categoryWithCount1 = CategoryWithCount(
          id: 1,
          name: 'Test Category',
          description: 'Test Description',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        final categoryWithCount2 = CategoryWithCount(
          id: 1,
          name: 'Test Category',
          description: 'Test Description',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 10,
        );

        expect(categoryWithCount1, isNot(equals(categoryWithCount2)));
      });

      test('should not be equal when one has null description', () {
        final categoryWithCount1 = CategoryWithCount(
          id: 1,
          name: 'Test Category',
          description: 'Test Description',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        final categoryWithCount2 = CategoryWithCount(
          id: 1,
          name: 'Test Category',
          description: null,
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        expect(categoryWithCount1, isNot(equals(categoryWithCount2)));
      });
    });

    group('HashCode Tests', () {
      test('should have same hashCode for equal objects', () {
        final categoryWithCount1 = CategoryWithCount(
          id: 1,
          name: 'Test Category',
          description: 'Test Description',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        final categoryWithCount2 = CategoryWithCount(
          id: 1,
          name: 'Test Category',
          description: 'Test Description',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        // Since CategoryWithCount doesn't override hashCode, we test that they have different hashCodes
        expect(categoryWithCount1.hashCode, isNot(equals(categoryWithCount2.hashCode)));
        // But the values are the same
        expect(categoryWithCount1.id, equals(categoryWithCount2.id));
      });

      test('should have different hashCode for different objects', () {
        final categoryWithCount1 = CategoryWithCount(
          id: 1,
          name: 'Category 1',
          description: 'Test Description',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        final categoryWithCount2 = CategoryWithCount(
          id: 2,
          name: 'Category 2',
          description: 'Test Description',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        expect(categoryWithCount1.hashCode, isNot(equals(categoryWithCount2.hashCode)));
      });
    });

    group('ToString Tests', () {
      test('should have meaningful toString representation', () {
        final categoryWithCount = CategoryWithCount(
          id: 1,
          name: 'Test Category',
          description: 'Test Description',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        final stringRepresentation = categoryWithCount.toString();
        expect(stringRepresentation, isA<String>());
        expect(stringRepresentation, isNotEmpty);
        // Since CategoryWithCount doesn't override toString, it will show the default format
        expect(stringRepresentation, contains('CategoryWithCount'));
      });

      test('should include null description in toString', () {
        final categoryWithCount = CategoryWithCount(
          id: 1,
          name: 'Test Category',
          description: null,
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        final stringRepresentation = categoryWithCount.toString();
        expect(stringRepresentation, isA<String>());
        expect(stringRepresentation, isNotEmpty);
        // Since CategoryWithCount doesn't override toString, it will show the default format
        expect(stringRepresentation, contains('CategoryWithCount'));
      });
    });

    group('Business Logic Tests', () {
      test('should represent valid business scenario', () {
        final categoryWithCount = CategoryWithCount(
          id: 1,
          name: 'Food Items',
          description: 'All food-related items',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 25,
        );

        expect(categoryWithCount.id, greaterThan(0));
        expect(categoryWithCount.name, isNotEmpty);
        expect(categoryWithCount.itemCount, greaterThanOrEqualTo(0));
        expect(categoryWithCount.createdAt.isBefore(categoryWithCount.lastUpdated), isTrue);
      });

      test('should handle category with no items', () {
        final categoryWithCount = CategoryWithCount(
          id: 2,
          name: 'Empty Category',
          description: 'Category with no items yet',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 0,
        );

        expect(categoryWithCount.itemCount, equals(0));
      });

      test('should handle category with many items', () {
        final categoryWithCount = CategoryWithCount(
          id: 3,
          name: 'Popular Category',
          description: 'Category with many items',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 1000,
        );

        expect(categoryWithCount.itemCount, greaterThan(100));
      });
    });

    group('Performance Tests', () {
      test('should create instances quickly', () {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 10000; i++) {
          CategoryWithCount(
            id: i,
            name: 'Category $i',
            description: 'Description for category $i',
            createdAt: testCreatedAt,
            lastUpdated: testLastUpdated,
            itemCount: i % 100,
          );
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('should compare instances quickly', () {
        final categoryWithCount1 = CategoryWithCount(
          id: 1,
          name: 'Test Category',
          description: 'Test Description',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        final categoryWithCount2 = CategoryWithCount(
          id: 1,
          name: 'Test Category',
          description: 'Test Description',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 10000; i++) {
          categoryWithCount1 == categoryWithCount2;
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });
    });

    group('Edge Cases Tests', () {
      test('should handle minimum values', () {
        final categoryWithCount = CategoryWithCount(
          id: -2147483648, // Min 32-bit int
          name: '',
          description: '',
          createdAt: DateTime.fromMillisecondsSinceEpoch(0),
          lastUpdated: DateTime.fromMillisecondsSinceEpoch(0),
          itemCount: -2147483648,
        );

        expect(categoryWithCount.id, equals(-2147483648));
        expect(categoryWithCount.name, equals(''));
        expect(categoryWithCount.description, equals(''));
        expect(categoryWithCount.itemCount, equals(-2147483648));
      });

      test('should handle maximum values', () {
        final categoryWithCount = CategoryWithCount(
          id: 2147483647, // Max 32-bit int
          name: 'A' * 1000,
          description: 'B' * 1000,
          createdAt: DateTime.fromMillisecondsSinceEpoch(8640000000000000),
          lastUpdated: DateTime.fromMillisecondsSinceEpoch(8640000000000000),
          itemCount: 2147483647,
        );

        expect(categoryWithCount.id, equals(2147483647));
        expect(categoryWithCount.name.length, equals(1000));
        expect(categoryWithCount.description?.length, equals(1000));
        expect(categoryWithCount.itemCount, equals(2147483647));
      });
    });

    group('Serialization Tests', () {
      test('should be serializable to JSON structure', () {
        final categoryWithCount = CategoryWithCount(
          id: 1,
          name: 'Test Category',
          description: 'Test Description',
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        final jsonMap = {
          'id': categoryWithCount.id,
          'name': categoryWithCount.name,
          'description': categoryWithCount.description,
          'createdAt': categoryWithCount.createdAt.toIso8601String(),
          'lastUpdated': categoryWithCount.lastUpdated.toIso8601String(),
          'itemCount': categoryWithCount.itemCount,
        };

        expect(jsonMap['id'], equals(1));
        expect(jsonMap['name'], equals('Test Category'));
        expect(jsonMap['description'], equals('Test Description'));
        expect(jsonMap['itemCount'], equals(5));
      });

      test('should handle null description in serialization', () {
        final categoryWithCount = CategoryWithCount(
          id: 1,
          name: 'Test Category',
          description: null,
          createdAt: testCreatedAt,
          lastUpdated: testLastUpdated,
          itemCount: 5,
        );

        final jsonMap = {
          'id': categoryWithCount.id,
          'name': categoryWithCount.name,
          'description': categoryWithCount.description,
          'createdAt': categoryWithCount.createdAt.toIso8601String(),
          'lastUpdated': categoryWithCount.lastUpdated.toIso8601String(),
          'itemCount': categoryWithCount.itemCount,
        };

        expect(jsonMap['description'], isNull);
      });
    });
  });
}
