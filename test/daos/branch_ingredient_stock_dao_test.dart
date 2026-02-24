// test/daos/branch_ingredient_stock_dao_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import '../database/test_database.dart';
import 'package:chickenjoo_inventory/database/daos/branch_ingredient_stock_dao.dart';

void main() {
  late AppDatabase db;
  late BranchIngredientStockDao dao;
  late int orgId;
  late int ingredientId;
  late int commissaryId;

  setUp(() async {
    db = createTestDatabase();
    dao = db.branchIngredientStockDao;

    commissaryId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Main Commissary',
        type: 'commissary',
      ),
    );
    orgId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Test Branch',
        type: 'franchisee',
        parentCommissaryId: Value(commissaryId),
      ),
    );
    ingredientId = await db.ingredientsDao.insertIngredient(
      name: 'Flour',
      commissaryId: commissaryId,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('1. upsertStock inserts a new stock record', () async {
    final id = await dao.upsertStock(
      BranchIngredientStockCompanion.insert(
        organizationId: orgId,
        ingredientId: ingredientId,
        quantity: const Value(50.0),
      ),
    );
    expect(id, greaterThan(0));
  });

  test('2. getStocksForBranch returns stocks for specified org', () async {
    await dao.upsertStock(
      BranchIngredientStockCompanion.insert(
        organizationId: orgId,
        ingredientId: ingredientId,
        quantity: const Value(50.0),
      ),
    );
    final stocks = await dao.getStocksForBranch(orgId);
    expect(stocks.length, equals(1));
    expect(stocks.first.quantity, equals(50.0));
  });

  test('3. getStock returns specific ingredient stock', () async {
    await dao.upsertStock(
      BranchIngredientStockCompanion.insert(
        organizationId: orgId,
        ingredientId: ingredientId,
        quantity: const Value(75.0),
      ),
    );
    final stock = await dao.getStock(
      organizationId: orgId,
      ingredientId: ingredientId,
    );
    expect(stock, isNotNull);
    expect(stock!.quantity, equals(75.0));
  });

  test('4. getStock returns null for non-existent stock', () async {
    final stock = await dao.getStock(
      organizationId: orgId,
      ingredientId: 999,
    );
    expect(stock, isNull);
  });

  test('5. updateQuantity changes the quantity', () async {
    await dao.upsertStock(
      BranchIngredientStockCompanion.insert(
        organizationId: orgId,
        ingredientId: ingredientId,
        quantity: const Value(50.0),
      ),
    );
    await dao.updateQuantity(
      organizationId: orgId,
      ingredientId: ingredientId,
      newQuantity: 25.0,
    );
    final stock = await dao.getStock(
      organizationId: orgId,
      ingredientId: ingredientId,
    );
    expect(stock!.quantity, equals(25.0));
  });

  test('6. addStock increases quantity on existing record', () async {
    await dao.upsertStock(
      BranchIngredientStockCompanion.insert(
        organizationId: orgId,
        ingredientId: ingredientId,
        quantity: const Value(50.0),
      ),
    );
    await dao.addStock(
      organizationId: orgId,
      ingredientId: ingredientId,
      quantityToAdd: 30.0,
    );
    final stock = await dao.getStock(
      organizationId: orgId,
      ingredientId: ingredientId,
    );
    expect(stock!.quantity, equals(80.0));
  });

  test('7. addStock creates new record when none exists', () async {
    final ing2 = await db.ingredientsDao.insertIngredient(
      name: 'Sugar',
      commissaryId: commissaryId,
    );
    await dao.addStock(
      organizationId: orgId,
      ingredientId: ing2,
      quantityToAdd: 10.0,
    );
    final stock = await dao.getStock(
      organizationId: orgId,
      ingredientId: ing2,
    );
    expect(stock, isNotNull);
    expect(stock!.quantity, equals(10.0));
  });

  test('8. consumeStock deducts quantity', () async {
    await dao.upsertStock(
      BranchIngredientStockCompanion.insert(
        organizationId: orgId,
        ingredientId: ingredientId,
        quantity: const Value(50.0),
      ),
    );
    final success = await dao.consumeStock(
      organizationId: orgId,
      ingredientId: ingredientId,
      quantityToConsume: 20.0,
    );
    expect(success, isTrue);
    final stock = await dao.getStock(
      organizationId: orgId,
      ingredientId: ingredientId,
    );
    expect(stock!.quantity, equals(30.0));
  });

  test('9. consumeStock returns false when insufficient stock', () async {
    await dao.upsertStock(
      BranchIngredientStockCompanion.insert(
        organizationId: orgId,
        ingredientId: ingredientId,
        quantity: const Value(5.0),
      ),
    );
    final success = await dao.consumeStock(
      organizationId: orgId,
      ingredientId: ingredientId,
      quantityToConsume: 10.0,
    );
    expect(success, isFalse);
  });

  test('10. consumeStock returns false when no stock record', () async {
    final success = await dao.consumeStock(
      organizationId: orgId,
      ingredientId: 999,
      quantityToConsume: 1.0,
    );
    expect(success, isFalse);
  });

  test('11. getStocksWithDetails returns joined data', () async {
    await dao.upsertStock(
      BranchIngredientStockCompanion.insert(
        organizationId: orgId,
        ingredientId: ingredientId,
        quantity: const Value(40.0),
      ),
    );
    final details = await dao.getStocksWithDetails(orgId);
    expect(details.length, equals(1));
    expect(details.first.name, equals('Flour'));
    expect(details.first.quantity, equals(40.0));
  });

  test('12. BranchIngredientWithDetails.isLowStock detects low stock', () async {
    await dao.upsertStock(
      BranchIngredientStockCompanion.insert(
        organizationId: orgId,
        ingredientId: ingredientId,
        quantity: const Value(3.0),
        minimumStock: const Value(10.0),
      ),
    );
    final details = await dao.getStocksWithDetails(orgId);
    expect(details.first.isLowStock, isTrue);
  });

  test('13. BranchIngredientWithDetails.isLowStock false when above min', () async {
    await dao.upsertStock(
      BranchIngredientStockCompanion.insert(
        organizationId: orgId,
        ingredientId: ingredientId,
        quantity: const Value(50.0),
        minimumStock: const Value(10.0),
      ),
    );
    final details = await dao.getStocksWithDetails(orgId);
    expect(details.first.isLowStock, isFalse);
  });

  test('14. getUnsyncedStocks returns unsynced records', () async {
    await dao.upsertStock(
      BranchIngredientStockCompanion.insert(
        organizationId: orgId,
        ingredientId: ingredientId,
        quantity: const Value(50.0),
      ),
    );
    final unsynced = await dao.getUnsyncedStocks();
    expect(unsynced, isNotEmpty);
  });

  test('15. markAsSynced flags records as synced', () async {
    final id = await dao.upsertStock(
      BranchIngredientStockCompanion.insert(
        organizationId: orgId,
        ingredientId: ingredientId,
        quantity: const Value(50.0),
      ),
    );
    await dao.markAsSynced([id]);
    final unsynced = await dao.getUnsyncedStocks();
    expect(unsynced, isEmpty);
  });
}
