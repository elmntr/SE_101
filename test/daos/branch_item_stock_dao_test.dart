// test/daos/branch_item_stock_dao_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import '../database/test_database.dart';
import 'package:chickenjoo_inventory/database/daos/branch_item_stock_dao.dart';

void main() {
  late AppDatabase db;
  late BranchItemStockDao dao;
  late int commissaryId;
  late int franchiseeId;
  late int itemId;

  setUp(() async {
    db = createTestDatabase();
    dao = db.branchItemStockDao;

    commissaryId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Main Commissary',
        type: 'commissary',
      ),
    );
    franchiseeId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Test Franchisee',
        type: 'franchisee',
        parentCommissaryId: Value(commissaryId),
      ),
    );
    // Master item owned by commissary
    itemId = await db.itemsDao.insertItem(
      name: 'Chicken Joy',
      organizationId: commissaryId,
      stock: 100,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('1. createStock inserts a new stock record', () async {
    final id = await dao.createStock(
      BranchItemStockCompanion.insert(
        organizationId: franchiseeId,
        itemId: itemId,
        stock: const Value(50),
      ),
    );
    expect(id, greaterThan(0));
  });

  test('2. getStockByOrganization returns stocks for an org', () async {
    await dao.createStock(
      BranchItemStockCompanion.insert(
        organizationId: franchiseeId,
        itemId: itemId,
        stock: const Value(50),
      ),
    );
    final stocks = await dao.getStockByOrganization(franchiseeId);
    expect(stocks.length, equals(1));
    expect(stocks.first.stock, equals(50));
  });

  test('3. getStockForItem returns stock for a specific item', () async {
    await dao.createStock(
      BranchItemStockCompanion.insert(
        organizationId: franchiseeId,
        itemId: itemId,
        stock: const Value(30),
      ),
    );
    final stock = await dao.getStockForItem(franchiseeId, itemId);
    expect(stock, isNotNull);
    expect(stock!.stock, equals(30));
  });

  test('4. getStockForItem returns null for non-existent stock', () async {
    final stock = await dao.getStockForItem(franchiseeId, 999);
    expect(stock, isNull);
  });

  test('5. getAllStock returns all non-deleted stocks', () async {
    await dao.createStock(
      BranchItemStockCompanion.insert(
        organizationId: franchiseeId,
        itemId: itemId,
        stock: const Value(50),
      ),
    );
    final allStock = await dao.getAllStock();
    expect(allStock, isNotEmpty);
  });

  test('6. getUnsyncedStock returns unsynced records', () async {
    await dao.createStock(
      BranchItemStockCompanion.insert(
        organizationId: franchiseeId,
        itemId: itemId,
        stock: const Value(50),
      ),
    );
    final unsynced = await dao.getUnsyncedStock();
    expect(unsynced, isNotEmpty);
    expect(unsynced.first.isSynced, isFalse);
  });

  test('7. getStockByOrganization returns empty for org with no stock', () async {
    final stocks = await dao.getStockByOrganization(999);
    expect(stocks, isEmpty);
  });

  test('8. createStock with default stock is 0', () async {
    final id = await dao.createStock(
      BranchItemStockCompanion.insert(
        organizationId: franchiseeId,
        itemId: itemId,
      ),
    );
    final stock = await dao.getStockForItem(franchiseeId, itemId);
    expect(stock, isNotNull);
    expect(stock!.stock, equals(0));
  });

  test('9. getItemsWithStockForBranch returns items with joined stock', () async {
    await dao.createStock(
      BranchItemStockCompanion.insert(
        organizationId: franchiseeId,
        itemId: itemId,
        stock: const Value(25),
      ),
    );
    final items = await dao.getItemsWithStockForBranch(
      franchiseeId,
      commissaryId,
    );
    expect(items, isNotEmpty);
    expect(items.first.item.name, equals('Chicken Joy'));
  });

  test('10. getItemsWithStockForBranch returns items even without stock record', () async {
    // No branch stock record created, but item exists
    final items = await dao.getItemsWithStockForBranch(
      franchiseeId,
      commissaryId,
    );
    expect(items, isNotEmpty);
    // Stock should be null (LEFT JOIN)
    expect(items.first.branchStock, isNull);
  });

  test('11. watchStockByOrganization returns a stream', () async {
    final stream = dao.watchStockByOrganization(franchiseeId);
    expect(stream, isA<Stream<List<BranchItemStockData>>>());
  });

  test('12. watchItemsWithStockForBranch returns a stream', () async {
    final stream = dao.watchItemsWithStockForBranch(
      franchiseeId,
      commissaryId,
    );
    expect(stream, isA<Stream>());
  });

  test('13. multiple items are returned sorted by name', () async {
    final itemId2 = await db.itemsDao.insertItem(
      name: 'Aloha Burger',
      organizationId: commissaryId,
      stock: 50,
    );
    await dao.createStock(
      BranchItemStockCompanion.insert(
        organizationId: franchiseeId,
        itemId: itemId,
        stock: const Value(10),
      ),
    );
    await dao.createStock(
      BranchItemStockCompanion.insert(
        organizationId: franchiseeId,
        itemId: itemId2,
        stock: const Value(20),
      ),
    );
    final items = await dao.getItemsWithStockForBranch(
      franchiseeId,
      commissaryId,
    );
    expect(items.length, equals(2));
    // Should be alphabetically sorted: Aloha Burger before Chicken Joy
    expect(items.first.item.name, equals('Aloha Burger'));
  });

  test('14. getStockByOrganization excludes deleted records', () async {
    await dao.createStock(
      BranchItemStockCompanion.insert(
        organizationId: franchiseeId,
        itemId: itemId,
        stock: const Value(50),
        isDeleted: const Value(true),
      ),
    );
    final stocks = await dao.getStockByOrganization(franchiseeId);
    expect(stocks, isEmpty);
  });

  test('15. createStock stores organizationId and itemId correctly', () async {
    await dao.createStock(
      BranchItemStockCompanion.insert(
        organizationId: franchiseeId,
        itemId: itemId,
        stock: const Value(99),
      ),
    );
    final stock = await dao.getStockForItem(franchiseeId, itemId);
    expect(stock!.organizationId, equals(franchiseeId));
    expect(stock.itemId, equals(itemId));
  });
}
