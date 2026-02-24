import 'package:flutter_test/flutter_test.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/database/models/item_with_category.dart';

void main() {
  group('ItemWithCategory', () {
    final now = DateTime.now();

    Item _createItem({
      int id = 1,
      String name = 'Test Item',
      String? description,
      String unit = 'pcs',
      int stock = 10,
      int sold = 5,
      int spoilage = 1,
      double? price = 100.0,
      double? costPrice = 50.0,
      int? minimumStock = 5,
      int? categoryId,
      int organizationId = 1,
      String? cloudId,
    }) {
      return Item(
        id: id,
        name: name,
        description: description,
        unit: unit,
        stock: stock,
        sold: sold,
        spoilage: spoilage,
        price: price,
        costPrice: costPrice,
        minimumStock: minimumStock,
        categoryId: categoryId,
        organizationId: organizationId,
        createdAt: now,
        lastUpdated: now,
        isSynced: false,
        isDeleted: false,
        cloudId: cloudId,
      );
    }

    Category _createCategory({
      int id = 1,
      String name = 'Beverages',
      String? description,
    }) {
      return Category(
        id: id,
        name: name,
        description: description,
        createdAt: now,
        lastUpdated: now,
        isDeleted: false,
      );
    }

    test('1. should create instance with item and category', () {
      final item = _createItem();
      final category = _createCategory();
      final itemWithCategory = ItemWithCategory(item: item, category: category);

      expect(itemWithCategory.item, equals(item));
      expect(itemWithCategory.category, equals(category));
    });

    test('2. should create instance with null category', () {
      final item = _createItem();
      final itemWithCategory = ItemWithCategory(item: item, category: null);

      expect(itemWithCategory.item, equals(item));
      expect(itemWithCategory.category, isNull);
    });

    test('3. categoryName returns category name when category exists', () {
      final item = _createItem();
      final category = _createCategory(name: 'Food');
      final itemWithCategory = ItemWithCategory(item: item, category: category);

      expect(itemWithCategory.categoryName, equals('Food'));
    });

    test('4. categoryName returns Uncategorized when category is null', () {
      final item = _createItem();
      final itemWithCategory = ItemWithCategory(item: item, category: null);

      expect(itemWithCategory.categoryName, equals('Uncategorized'));
    });

    test('5. should expose item properties through item field', () {
      final item = _createItem(name: 'Chicken Wings', stock: 50, price: 250.0);
      final itemWithCategory = ItemWithCategory(item: item, category: null);

      expect(itemWithCategory.item.name, equals('Chicken Wings'));
      expect(itemWithCategory.item.stock, equals(50));
      expect(itemWithCategory.item.price, equals(250.0));
    });

    test('6. should handle category with description', () {
      final item = _createItem();
      final category = _createCategory(name: 'Drinks', description: 'All beverages');
      final itemWithCategory = ItemWithCategory(item: item, category: category);

      expect(itemWithCategory.category!.description, equals('All beverages'));
    });

    test('7. should handle category with null description', () {
      final item = _createItem();
      final category = _createCategory(name: 'Snacks', description: null);
      final itemWithCategory = ItemWithCategory(item: item, category: category);

      expect(itemWithCategory.category!.description, isNull);
    });

    test('8. should handle item with all optional fields null', () {
      final item = _createItem(
        description: null,
        price: null,
        costPrice: null,
        minimumStock: null,
        categoryId: null,
        cloudId: null,
      );
      final itemWithCategory = ItemWithCategory(item: item, category: null);

      expect(itemWithCategory.item.description, isNull);
      expect(itemWithCategory.item.price, isNull);
      expect(itemWithCategory.categoryName, equals('Uncategorized'));
    });

    test('9. should handle item with zero stock values', () {
      final item = _createItem(stock: 0, sold: 0, spoilage: 0);
      final category = _createCategory();
      final itemWithCategory = ItemWithCategory(item: item, category: category);

      expect(itemWithCategory.item.stock, equals(0));
      expect(itemWithCategory.item.sold, equals(0));
      expect(itemWithCategory.item.spoilage, equals(0));
    });

    test('10. should preserve item id', () {
      final item = _createItem(id: 42);
      final itemWithCategory = ItemWithCategory(item: item, category: null);

      expect(itemWithCategory.item.id, equals(42));
    });

    test('11. should handle item with cloudId', () {
      final item = _createItem(cloudId: 'uuid-123-abc');
      final itemWithCategory = ItemWithCategory(item: item, category: null);

      expect(itemWithCategory.item.cloudId, equals('uuid-123-abc'));
    });

    test('12. should handle category with different ids', () {
      final item = _createItem();
      final category = _createCategory(id: 99, name: 'Premium');
      final itemWithCategory = ItemWithCategory(item: item, category: category);

      expect(itemWithCategory.category!.id, equals(99));
      expect(itemWithCategory.categoryName, equals('Premium'));
    });

    test('13. two instances with same data should have same categoryName', () {
      final item1 = _createItem(id: 1);
      final item2 = _createItem(id: 2);
      final category = _createCategory(name: 'Frozen');
      final iwc1 = ItemWithCategory(item: item1, category: category);
      final iwc2 = ItemWithCategory(item: item2, category: category);

      expect(iwc1.categoryName, equals(iwc2.categoryName));
    });

    test('14. should handle item with large stock numbers', () {
      final item = _createItem(stock: 999999, sold: 500000, spoilage: 100);
      final itemWithCategory = ItemWithCategory(item: item, category: null);

      expect(itemWithCategory.item.stock, equals(999999));
      expect(itemWithCategory.item.sold, equals(500000));
    });

    test('15. should handle item with different units', () {
      final item = _createItem(unit: 'kg');
      final itemWithCategory = ItemWithCategory(item: item, category: null);

      expect(itemWithCategory.item.unit, equals('kg'));
    });
  });
}
