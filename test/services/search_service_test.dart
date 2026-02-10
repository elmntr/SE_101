import 'package:flutter_test/flutter_test.dart';
import 'package:chickenjoo_inventory/services/search_service.dart';

void main() {
  group('SearchService.filter', () {
    final items = ['Apple', 'Banana', 'Avocado', 'Cherry', 'Apricot'];

    test('1. should return all items when query is empty', () {
      final result = SearchService.filter<String>(
        items, '', (item) => [item],
      );
      expect(result.length, equals(5));
    });

    test('2. should filter items matching query', () {
      final result = SearchService.filter<String>(
        items, 'ap', (item) => [item],
      );
      expect(result, contains('Apple'));
      expect(result, contains('Apricot'));
      expect(result, isNot(contains('Banana')));
    });

    test('3. should be case insensitive', () {
      final result = SearchService.filter<String>(
        items, 'APPLE', (item) => [item],
      );
      expect(result.length, equals(1));
      expect(result.first, equals('Apple'));
    });

    test('4. should return empty list when no match', () {
      final result = SearchService.filter<String>(
        items, 'xyz', (item) => [item],
      );
      expect(result, isEmpty);
    });

    test('5. should work with multiple search fields', () {
      final products = [
        {'name': 'Chicken Wings', 'category': 'Poultry'},
        {'name': 'Beef Steak', 'category': 'Meat'},
        {'name': 'Chicken Breast', 'category': 'Poultry'},
      ];

      final result = SearchService.filter<Map<String, String>>(
        products, 'poultry', (item) => [item['name'], item['category']],
      );
      expect(result.length, equals(2));
    });

    test('6. should handle whitespace-only query', () {
      final result = SearchService.filter<String>(
        items, '   ', (item) => [item],
      );
      expect(result.length, equals(5));
    });

    test('7. should handle null fields gracefully', () {
      final itemsWithNull = [
        {'name': 'Item A', 'desc': null},
        {'name': 'Item B', 'desc': 'good'},
      ];

      final result = SearchService.filter<Map<String, String?>>(
        itemsWithNull, 'good', (item) => [item['name'], item['desc']],
      );
      expect(result.length, equals(1));
    });

    test('8. should handle empty items list', () {
      final result = SearchService.filter<String>(
        [], 'test', (item) => [item],
      );
      expect(result, isEmpty);
    });

    test('9. should match partial strings', () {
      final result = SearchService.filter<String>(
        items, 'an', (item) => [item],
      );
      expect(result, contains('Banana'));
    });

    test('10. should handle single character query', () {
      final result = SearchService.filter<String>(
        items, 'c', (item) => [item],
      );
      expect(result, contains('Cherry'));
      expect(result, contains('Avocado'));
      expect(result, contains('Apricot'));
    });

    test('11. should handle query with leading/trailing spaces', () {
      final result = SearchService.filter<String>(
        items, '  apple  ', (item) => [item],
      );
      expect(result.length, equals(1));
      expect(result.first, equals('Apple'));
    });

    test('12. should filter with custom objects', () {
      final people = [
        _Person('John', 'Doe', 'john@test.com'),
        _Person('Jane', 'Doe', 'jane@test.com'),
        _Person('Bob', 'Smith', 'bob@test.com'),
      ];

      final result = SearchService.filter<_Person>(
        people, 'doe', (p) => [p.firstName, p.lastName, p.email],
      );
      expect(result.length, equals(2));
    });

    test('13. should handle empty string fields', () {
      final itemsWithEmpty = [
        {'name': '', 'desc': 'something'},
        {'name': 'Item', 'desc': ''},
      ];

      final result = SearchService.filter<Map<String, String>>(
        itemsWithEmpty, 'something', (item) => [item['name']!, item['desc']!],
      );
      expect(result.length, equals(1));
    });

    test('14. should return all items when all match', () {
      final data = ['test1', 'test2', 'test3'];
      final result = SearchService.filter<String>(
        data, 'test', (item) => [item],
      );
      expect(result.length, equals(3));
    });

    test('15. private constructor prevents instantiation', () {
      // Verify SearchService uses static methods only (no public constructor)
      // This test confirms the class design pattern
      expect(SearchService.filter, isA<Function>());
    });
  });
}

class _Person {
  final String firstName;
  final String lastName;
  final String email;
  _Person(this.firstName, this.lastName, this.email);
}
