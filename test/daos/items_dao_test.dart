// test/daos/items_dao_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import '../database/test_database.dart';
import 'package:chickenjoo_inventory/database/daos/items_dao.dart';

void main() {
  late AppDatabase db;
  late ItemsDao itemsDao;
  late int commissaryId;
  late int orgId;

  setUp(() async {
    db = createTestDatabase();
    itemsDao = db.itemsDao;
    commissaryId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Test Commissary',
        type: 'commissary',
      ),
    );
    orgId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Test Franchisee',
        type: 'franchisee',
        parentCommissaryId: Value(commissaryId),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('1. Insert item successfully', () async {
    final id = await itemsDao.insertItem(name: 'Burger', organizationId: orgId);
    final item = await itemsDao.getItemById(id);
    expect(item, isNotNull);
    expect(item!.name, 'Burger');
    expect(item.organizationId, orgId);
  });

  test('2. Get all items returns inserted items', () async {
    await itemsDao.insertItem(name: 'Fries', organizationId: orgId);
    await itemsDao.insertItem(name: 'Soda', organizationId: orgId);
    final allItems = await itemsDao.getAllItems();
    expect(allItems.length, 2);
  });

  test('3. Update item changes its properties', () async {
    final id = await itemsDao.insertItem(
      name: 'Pizza',
      organizationId: orgId,
      price: 10.0,
    );
    final item = (await itemsDao.getItemById(id))!;
    await itemsDao.updateItem(
      item.copyWith(name: 'Calzone', price: Value(12.5)),
    );
    final updated = await itemsDao.getItemById(id);
    expect(updated!.name, 'Calzone');
    expect(updated.price, 12.5);
  });

  test('4. Soft delete marks item as deleted', () async {
    final id = await itemsDao.insertItem(name: 'Salad', organizationId: orgId);
    await itemsDao.softDeleteItem(id);
    final item = await itemsDao.getItemById(id);
    expect(item!.isDeleted, isTrue);
  });

  test('5. Get all items ignores soft-deleted ones', () async {
    await itemsDao.insertItem(name: 'Visible', organizationId: orgId);
    final idToDelete = await itemsDao.insertItem(
      name: 'Invisible',
      organizationId: orgId,
    );
    await itemsDao.softDeleteItem(idToDelete);
    final items = await itemsDao.getAllItems();
    expect(items.length, 1);
    expect(items.first.name, 'Visible');
  });

  test('6. Add stock increases stock quantity', () async {
    final id = await itemsDao.insertItem(
      name: 'Taco',
      organizationId: orgId,
      stock: 20,
    );
    await itemsDao.addStock(id, 10);
    final item = await itemsDao.getItemById(id);
    expect(item!.stock, 30);
  });

  test('7. Add sold decreases stock and increases sold', () async {
    final id = await itemsDao.insertItem(
      name: 'Burrito',
      organizationId: orgId,
      stock: 50,
    );
    await itemsDao.addSold(id, 5);
    final item = await itemsDao.getItemById(id);
    expect(item!.stock, 45);
    expect(item.sold, 5);
  });

  test('8. Add sold fails with insufficient stock', () async {
    final id = await itemsDao.insertItem(
      name: 'Nachos',
      organizationId: orgId,
      stock: 2,
    );
    final success = await itemsDao.addSold(id, 5);
    expect(success, isFalse);
    final item = await itemsDao.getItemById(id);
    expect(item!.stock, 2);
    expect(item.sold, 0);
  });

  test('9. Add spoilage decreases stock and increases spoilage', () async {
    final id = await itemsDao.insertItem(
      name: 'Enchilada',
      organizationId: orgId,
      stock: 30,
    );
    await itemsDao.addSpoilage(id, 3);
    final item = await itemsDao.getItemById(id);
    expect(item!.stock, 27);
    expect(item.spoilage, 3);
  });

  test('10. Get items with categories returns correct data', () async {
    final catId = await db.categoriesDao.insertCategory(name: 'Mexican');
    await itemsDao.insertItem(
      name: 'Quesadilla',
      organizationId: orgId,
      categoryId: catId,
    );
    await itemsDao.insertItem(name: 'Uncategorized', organizationId: orgId);

    final itemsWithCat = await itemsDao.getItemsWithCategories();
    final categorized = itemsWithCat.firstWhere(
      (iwc) => iwc.item.name == 'Quesadilla',
    );
    final uncategorized = itemsWithCat.firstWhere(
      (iwc) => iwc.item.name == 'Uncategorized',
    );

    expect(categorized.category, isNotNull);
    expect(categorized.category!.name, 'Mexican');
    expect(uncategorized.category, isNull);
  });

  test('11. Get low stock items returns items below threshold', () async {
    await itemsDao.insertItem(
      name: 'Low Stock',
      organizationId: orgId,
      stock: 5,
    );
    await itemsDao.insertItem(
      name: 'High Stock',
      organizationId: orgId,
      stock: 20,
    );
    final lowStock = await itemsDao.getLowStockItems(10);
    expect(lowStock.length, 1);
    expect(lowStock.first.name, 'Low Stock');
  });

  test('12. Assign category updates the item', () async {
    final catId = await db.categoriesDao.insertCategory(name: 'Main Course');
    final itemId = await itemsDao.insertItem(
      name: 'Steak',
      organizationId: orgId,
    );
    await itemsDao.assignCategory(itemId, catId);
    final item = await itemsDao.getItemById(itemId);
    expect(item!.categoryId, catId);
  });

  test('13. Get items by organization filters correctly', () async {
    final org2Id = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Other Franchisee',
        type: 'franchisee',
        parentCommissaryId: Value(commissaryId),
      ),
    );
    await itemsDao.insertItem(name: 'Item A', organizationId: orgId);
    await itemsDao.insertItem(name: 'Item B', organizationId: org2Id);

    final org1Items = await itemsDao.getItemsByOrganization(orgId);
    expect(org1Items.length, 1);
    expect(org1Items.first.name, 'Item A');
  });

  test('14. Get unsynced item count is correct', () async {
    final id1 = await itemsDao.insertItem(name: 'A', organizationId: orgId);
    final id2 = await itemsDao.insertItem(name: 'B', organizationId: orgId);
    await itemsDao.markAsSynced([id1]);

    final count = await itemsDao.getUnsyncedItemCount();
    expect(count, 1);
    final unsynced = await itemsDao.getUnsyncedItems();
    expect(unsynced.first.id, id2);
  });

  test('15. Permanent delete marks item as deleted and unsynced', () async {
    final id = await itemsDao.insertItem(
      name: 'To Delete',
      organizationId: orgId,
    );
    await itemsDao.markAsSynced([id]); // Mark as synced first
    await itemsDao.deleteItem(id);

    final item = await itemsDao.getItemById(id);
    expect(item, isNotNull);
    expect(item!.isDeleted, isTrue);
    expect(item.isSynced, isFalse); // Should be marked for cloud deletion
  });

  test('16. Get item count works with search query', () async {
    await itemsDao.insertItem(name: 'Chicken Sandwich', organizationId: orgId);
    await itemsDao.insertItem(name: 'Chicken Nuggets', organizationId: orgId);
    await itemsDao.insertItem(name: 'Beef Burger', organizationId: orgId);

    final count = await itemsDao.getItemCount(searchQuery: 'Chicken');
    expect(count, 2);
  });
}
