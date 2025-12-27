// test/daos/categories_dao_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import '../database/test_database.dart';
import 'package:chickenjoo_inventory/database/daos/categories_dao.dart';

void main() {
  late AppDatabase db;
  late CategoriesDao categoriesDao;

  setUp(() {
    db = createTestDatabase();
    categoriesDao = db.categoriesDao;
  });

  tearDown(() async {
    await db.close();
  });

  test('1. Insert category successfully', () async {
    final id = await categoriesDao.insertCategory(name: 'Snacks');
    final category = await categoriesDao.getCategoryById(id);
    expect(category, isNotNull);
    expect(category!.name, 'Snacks');
  });

  test('2. Get all categories returns inserted categories', () async {
    await categoriesDao.insertCategory(name: 'Drinks');
    await categoriesDao.insertCategory(name: 'Desserts');
    final allCategories = await categoriesDao.getAllCategories();
    expect(allCategories.length, 2);
    expect(
      allCategories.map((c) => c.name),
      containsAll(['Drinks', 'Desserts']),
    );
  });

  test('3. Update category changes its name', () async {
    final id = await categoriesDao.insertCategory(name: 'Initial');
    final category = (await categoriesDao.getCategoryById(id))!;
    await categoriesDao.updateCategory(category.copyWith(name: 'Updated'));
    final updatedCategory = await categoriesDao.getCategoryById(id);
    expect(updatedCategory!.name, 'Updated');
  });

  test('4. Soft delete category marks it as deleted', () async {
    final id = await categoriesDao.insertCategory(name: 'To Delete');
    await categoriesDao.softDeleteCategory(id);
    final category = await categoriesDao.getCategoryById(id);
    expect(category, isNotNull);
    expect(category!.isDeleted, isTrue);
  });

  test('5. Get all categories ignores soft-deleted ones', () async {
    await categoriesDao.insertCategory(name: 'Visible');
    final idToDelete = await categoriesDao.insertCategory(name: 'Invisible');
    await categoriesDao.softDeleteCategory(idToDelete);
    final categories = await categoriesDao.getAllCategories();
    expect(categories.length, 1);
    expect(categories.first.name, 'Visible');
  });

  test('6. Restore category un-marks it as deleted', () async {
    final id = await categoriesDao.insertCategory(name: 'To Restore');
    await categoriesDao.softDeleteCategory(id);
    await categoriesDao.restoreCategory(id);
    final category = await categoriesDao.getCategoryById(id);
    expect(category!.isDeleted, isFalse);
  });

  test('7. Get category by name finds the correct category', () async {
    await categoriesDao.insertCategory(name: 'FindMe');
    final category = await categoriesDao.getCategoryByName('FindMe');
    expect(category, isNotNull);
    expect(category!.name, 'FindMe');
  });

  test('8. Get category by name returns null for non-existent name', () async {
    final category = await categoriesDao.getCategoryByName('NotFound');
    expect(category, isNull);
  });

  test(
    '9. Get category count reflects number of non-deleted categories',
    () async {
      await categoriesDao.insertCategory(name: 'One');
      await categoriesDao.insertCategory(name: 'Two');
      final id = await categoriesDao.insertCategory(name: 'Three');
      await categoriesDao.softDeleteCategory(id);
      final count = await categoriesDao.getCategoryCount();
      expect(count, 2);
    },
  );

  test('10. Batch insert adds multiple categories', () async {
    final companions = [
      CategoriesCompanion.insert(name: 'Batch 1'),
      CategoriesCompanion.insert(name: 'Batch 2'),
    ];
    await categoriesDao.insertCategories(companions);
    final count = await categoriesDao.getCategoryCount();
    expect(count, 2);
  });

  test('11. Soft delete fails if category has items', () async {
    final categoryId = await categoriesDao.insertCategory(
      name: 'Category with Items',
    );
    final commissaryId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Commissary', type: 'commissary'),
    );
    final orgId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Org',
        type: 'franchisee',
        parentCommissaryId: Value(commissaryId),
      ),
    );
    await db.itemsDao.insertItem(
      name: 'Test Item',
      organizationId: orgId,
      categoryId: categoryId,
    );

    expect(() => categoriesDao.softDeleteCategory(categoryId), throwsException);
  });

  test('12. Permanent delete fails if category has items', () async {
    final categoryId = await categoriesDao.insertCategory(
      name: 'Category with Items',
    );
    final commissaryId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Commissary', type: 'commissary'),
    );
    final orgId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Org',
        type: 'franchisee',
        parentCommissaryId: Value(commissaryId),
      ),
    );
    await db.itemsDao.insertItem(
      name: 'Test Item',
      organizationId: orgId,
      categoryId: categoryId,
    );

    expect(() => categoriesDao.deleteCategory(categoryId), throwsException);
  });

  test('13. Permanent delete succeeds for empty category', () async {
    final categoryId = await categoriesDao.insertCategory(
      name: 'Empty Category',
    );
    final success = await categoriesDao.deleteCategory(categoryId);
    expect(success, isTrue);
    final category = await categoriesDao.getCategoryById(categoryId);
    expect(category, isNull);
  });

  test('14. Get empty categories returns categories with no items', () async {
    final cat1Id = await categoriesDao.insertCategory(name: 'Has Item');
    await categoriesDao.insertCategory(name: 'Is Empty');
    final commissaryId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Commissary', type: 'commissary'),
    );
    final orgId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Org',
        type: 'franchisee',
        parentCommissaryId: Value(commissaryId),
      ),
    );
    await db.itemsDao.insertItem(
      name: 'Test Item',
      organizationId: orgId,
      categoryId: cat1Id,
    );

    final emptyCategories = await categoriesDao.getEmptyCategories();
    expect(emptyCategories.length, 1);
    expect(emptyCategories.first.name, 'Is Empty');
  });

  test('15. Get categories with item counts returns correct counts', () async {
    final cat1Id = await categoriesDao.insertCategory(name: 'One Item');
    final cat2Id = await categoriesDao.insertCategory(name: 'Two Items');
    await categoriesDao.insertCategory(name: 'Zero Items');
    final commissaryId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Commissary', type: 'commissary'),
    );
    final orgId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Org',
        type: 'franchisee',
        parentCommissaryId: Value(commissaryId),
      ),
    );

    await db.itemsDao.insertItem(
      name: 'Item A',
      organizationId: orgId,
      categoryId: cat1Id,
    );
    await db.itemsDao.insertItem(
      name: 'Item B',
      organizationId: orgId,
      categoryId: cat2Id,
    );
    await db.itemsDao.insertItem(
      name: 'Item C',
      organizationId: orgId,
      categoryId: cat2Id,
    );

    final results = await categoriesDao.getCategoriesWithItemCounts();
    final oneItemCat = results.firstWhere((c) => c.name == 'One Item');
    final twoItemsCat = results.firstWhere((c) => c.name == 'Two Items');
    final zeroItemsCat = results.firstWhere((c) => c.name == 'Zero Items');

    expect(oneItemCat.itemCount, 1);
    expect(twoItemsCat.itemCount, 2);
    expect(zeroItemsCat.itemCount, 0);
  });

  test('16. Search query in getAllCategories filters results', () async {
    await categoriesDao.insertCategory(name: 'Apple Pie');
    await categoriesDao.insertCategory(name: 'Apple Juice');
    await categoriesDao.insertCategory(name: 'Banana Pie');

    final results = await categoriesDao.getAllCategories(searchQuery: 'Apple');
    expect(results.length, 2);
    expect(
      results.map((c) => c.name),
      containsAll(['Apple Pie', 'Apple Juice']),
    );
  });
}
