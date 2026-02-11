import 'package:flutter_test/flutter_test.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/database/models/item_with_branch_stock.dart';

void main() {
  group('ItemWithBranchStock', () {
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

    BranchItemStockData _createBranchStock({
      int id = 1,
      int organizationId = 2,
      int itemId = 1,
      int stock = 20,
      int sold = 10,
      int spoilage = 2,
      double? price = 120.0,
      double? costPrice = 60.0,
      int? minimumStock = 3,
      DateTime? lastReceivedAt,
      int? lastReceivedQuantity,
      String? cloudId,
    }) {
      return BranchItemStockData(
        id: id,
        organizationId: organizationId,
        itemId: itemId,
        stock: stock,
        sold: sold,
        spoilage: spoilage,
        price: price,
        costPrice: costPrice,
        minimumStock: minimumStock,
        lastReceivedAt: lastReceivedAt,
        lastReceivedQuantity: lastReceivedQuantity,
        createdAt: now,
        lastUpdated: now,
        isDeleted: false,
        isSynced: false,
        cloudId: cloudId,
      );
    }

    test('1. should create instance with item only (no branch stock)', () {
      final item = _createItem();
      final iwbs = ItemWithBranchStock(item: item);

      expect(iwbs.item, equals(item));
      expect(iwbs.branchStock, isNull);
      expect(iwbs.hasBranchStock, isFalse);
    });

    test('2. should create instance with item and branch stock', () {
      final item = _createItem();
      final branchStock = _createBranchStock();
      final iwbs = ItemWithBranchStock(item: item, branchStock: branchStock);

      expect(iwbs.hasBranchStock, isTrue);
      expect(iwbs.branchStock, equals(branchStock));
    });

    test('3. name getter returns item name', () {
      final item = _createItem(name: 'Chicken Wings');
      final iwbs = ItemWithBranchStock(item: item);

      expect(iwbs.name, equals('Chicken Wings'));
    });

    test('4. id getter returns item id', () {
      final item = _createItem(id: 42);
      final iwbs = ItemWithBranchStock(item: item);

      expect(iwbs.id, equals(42));
    });

    test('5. stock returns branch stock when present', () {
      final item = _createItem(stock: 10);
      final branchStock = _createBranchStock(stock: 20);
      final iwbs = ItemWithBranchStock(item: item, branchStock: branchStock);

      expect(iwbs.stock, equals(20));
    });

    test('6. stock returns 0 when no branch stock', () {
      final item = _createItem(stock: 10);
      final iwbs = ItemWithBranchStock(item: item);

      expect(iwbs.stock, equals(0));
    });

    test('7. price falls back to item price when branch has no price', () {
      final item = _createItem(price: 100.0);
      final branchStock = _createBranchStock(price: null);
      final iwbs = ItemWithBranchStock(item: item, branchStock: branchStock);

      expect(iwbs.price, equals(100.0));
    });

    test('8. price uses branch price when available', () {
      final item = _createItem(price: 100.0);
      final branchStock = _createBranchStock(price: 150.0);
      final iwbs = ItemWithBranchStock(item: item, branchStock: branchStock);

      expect(iwbs.price, equals(150.0));
    });

    test('9. isLowStock returns true when stock <= minimumStock', () {
      final item = _createItem();
      final branchStock = _createBranchStock(stock: 2, minimumStock: 5);
      final iwbs = ItemWithBranchStock(item: item, branchStock: branchStock);

      expect(iwbs.isLowStock, isTrue);
    });

    test('10. isLowStock returns false when minimumStock is null', () {
      final item = _createItem(minimumStock: null);
      final branchStock = _createBranchStock(stock: 2, minimumStock: null);
      final iwbs = ItemWithBranchStock(item: item, branchStock: branchStock);

      expect(iwbs.isLowStock, isFalse);
    });

    test('11. isOutOfStock returns true when stock is 0', () {
      final item = _createItem();
      final branchStock = _createBranchStock(stock: 0);
      final iwbs = ItemWithBranchStock(item: item, branchStock: branchStock);

      expect(iwbs.isOutOfStock, isTrue);
    });

    test('12. grossRevenue calculated correctly', () {
      final item = _createItem();
      final branchStock = _createBranchStock(price: 100.0, sold: 10);
      final iwbs = ItemWithBranchStock(item: item, branchStock: branchStock);

      expect(iwbs.grossRevenue, equals(1000.0));
    });

    test('13. spoilageCost calculated correctly', () {
      final item = _createItem();
      final branchStock = _createBranchStock(costPrice: 50.0, spoilage: 3);
      final iwbs = ItemWithBranchStock(item: item, branchStock: branchStock);

      expect(iwbs.spoilageCost, equals(150.0));
    });

    test('14. categoryName returns Uncategorized when category is null', () {
      final item = _createItem();
      final iwbs = ItemWithBranchStock(item: item, category: null);

      expect(iwbs.categoryName, equals('Uncategorized'));
    });

    test('15. toString returns descriptive string', () {
      final item = _createItem(name: 'Burger');
      final branchStock = _createBranchStock(stock: 15, sold: 7, spoilage: 1);
      final iwbs = ItemWithBranchStock(item: item, branchStock: branchStock);

      final str = iwbs.toString();
      expect(str, contains('Burger'));
      expect(str, contains('15'));
      expect(str, contains('hasBranchStock: true'));
    });
  });

  group('BranchStockSummary', () {
    test('1. should create instance with all fields', () {
      final summary = BranchStockSummary(
        organizationId: 1,
        branchName: 'Branch A',
        stock: 100,
        sold: 50,
        spoilage: 5,
        price: 99.99,
      );

      expect(summary.organizationId, equals(1));
      expect(summary.branchName, equals('Branch A'));
      expect(summary.stock, equals(100));
      expect(summary.sold, equals(50));
      expect(summary.spoilage, equals(5));
      expect(summary.price, equals(99.99));
    });

    test('2. should handle null price', () {
      final summary = BranchStockSummary(
        organizationId: 1,
        branchName: 'Branch B',
        stock: 0,
        sold: 0,
        spoilage: 0,
      );

      expect(summary.price, isNull);
    });
  });

  group('ItemWithAllBranchesStock', () {
    final now = DateTime.now();

    test('1. totalStock sums across branches', () {
      final item = Item(
        id: 1, name: 'Fries', unit: 'pcs', stock: 0, sold: 0, spoilage: 0,
        organizationId: 1, createdAt: now, lastUpdated: now,
        isSynced: false, isDeleted: false,
      );
      final branches = [
        BranchStockSummary(organizationId: 1, branchName: 'A', stock: 10, sold: 5, spoilage: 1),
        BranchStockSummary(organizationId: 2, branchName: 'B', stock: 20, sold: 10, spoilage: 2),
      ];
      final iwabs = ItemWithAllBranchesStock(item: item, branchStocks: branches);

      expect(iwabs.totalStock, equals(30));
      expect(iwabs.totalSold, equals(15));
      expect(iwabs.totalSpoilage, equals(3));
      expect(iwabs.branchCount, equals(2));
    });
  });
}
