// test/daos/ingredients_dao_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import '../database/test_database.dart';
import 'package:chickenjoo_inventory/database/daos/ingredients_dao.dart';

void main() {
  late AppDatabase db;
  late IngredientsDao ingredientsDao;
  late int commissaryId;

  setUp(() async {
    db = createTestDatabase();
    ingredientsDao = db.ingredientsDao;
    commissaryId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Main Commissary', type: 'commissary'),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('1. Insert ingredient successfully', () async {
    final id = await ingredientsDao.insertIngredient(name: 'Flour', commissaryId: commissaryId);
    final ingredient = await ingredientsDao.getIngredientById(id);
    expect(ingredient, isNotNull);
    expect(ingredient!.name, 'Flour');
    expect(ingredient.commissaryId, commissaryId);
  });

  test('2. Get all ingredients returns inserted ingredients', () async {
    await ingredientsDao.insertIngredient(name: 'Sugar', commissaryId: commissaryId);
    await ingredientsDao.insertIngredient(name: 'Salt', commissaryId: commissaryId);
    final allIngredients = await ingredientsDao.getAllIngredients();
    expect(allIngredients.length, 2);
  });

  test('3. Update ingredient changes its properties', () async {
    final id = await ingredientsDao.insertIngredient(name: 'Butter', commissaryId: commissaryId);
    final ingredient = (await ingredientsDao.getIngredientById(id))!;
    await ingredientsDao.updateIngredient(ingredient.copyWith(name: 'Margarine', stock: 100));
    final updated = await ingredientsDao.getIngredientById(id);
    expect(updated!.name, 'Margarine');
    expect(updated.stock, 100);
  });

  test('4. Soft delete marks ingredient as deleted', () async {
    final id = await ingredientsDao.insertIngredient(name: 'Yeast', commissaryId: commissaryId);
    await ingredientsDao.softDeleteIngredient(id);
    final ingredient = await ingredientsDao.getIngredientById(id);
    expect(ingredient!.isDeleted, isTrue);
  });

  test('5. Get all ingredients ignores soft-deleted ones', () async {
    await ingredientsDao.insertIngredient(name: 'Visible', commissaryId: commissaryId);
    final idToDelete = await ingredientsDao.insertIngredient(name: 'Invisible', commissaryId: commissaryId);
    await ingredientsDao.softDeleteIngredient(idToDelete);
    final ingredients = await ingredientsDao.getAllIngredients();
    expect(ingredients.length, 1);
    expect(ingredients.first.name, 'Visible');
  });

  test('6. Add stock increases stock quantity', () async {
    final id = await ingredientsDao.insertIngredient(name: 'Milk', commissaryId: commissaryId, stock: 50);
    await ingredientsDao.addStock(id, 25);
    final ingredient = await ingredientsDao.getIngredientById(id);
    expect(ingredient!.stock, 75);
  });

  test('7. Deduct stock decreases stock quantity', () async {
    final id = await ingredientsDao.insertIngredient(name: 'Eggs', commissaryId: commissaryId, stock: 100);
    await ingredientsDao.deductStock(id, 30);
    final ingredient = await ingredientsDao.getIngredientById(id);
    expect(ingredient!.stock, 70);
  });

  test('8. Deduct stock fails with insufficient stock', () async {
    final id = await ingredientsDao.insertIngredient(name: 'Chocolate', commissaryId: commissaryId, stock: 10);
    final success = await ingredientsDao.deductStock(id, 20);
    expect(success, isFalse);
    final ingredient = await ingredientsDao.getIngredientById(id);
    expect(ingredient!.stock, 10);
  });

  test('9. Add spoilage decreases stock and increases spoilage', () async {
    final id = await ingredientsDao.insertIngredient(name: 'Tomatoes', commissaryId: commissaryId, stock: 50);
    await ingredientsDao.addSpoilage(id, 5);
    final ingredient = await ingredientsDao.getIngredientById(id);
    expect(ingredient!.stock, 45);
    expect(ingredient.spoilage, 5);
  });

  test('10. Get low stock ingredients returns correct items', () async {
    await ingredientsDao.insertIngredient(name: 'Low Stock', commissaryId: commissaryId, stock: 5, minimumStock: 10);
    await ingredientsDao.insertIngredient(name: 'OK Stock', commissaryId: commissaryId, stock: 15, minimumStock: 10);
    await ingredientsDao.insertIngredient(name: 'No Min Stock', commissaryId: commissaryId, stock: 1);

    final lowStockItems = await ingredientsDao.getLowStockIngredients();
    expect(lowStockItems.length, 1);
    expect(lowStockItems.first.name, 'Low Stock');
  });

  test('11. Get out of stock ingredients returns correct items', () async {
    await ingredientsDao.insertIngredient(name: 'Out of Stock', commissaryId: commissaryId, stock: 0);
    await ingredientsDao.insertIngredient(name: 'In Stock', commissaryId: commissaryId, stock: 1);
    final outOfStock = await ingredientsDao.getOutOfStockIngredients();
    expect(outOfStock.length, 1);
    expect(outOfStock.first.name, 'Out of Stock');
  });

  test('12. Soft delete fails if ingredient is used in a recipe', () async {
    final orgId = await db.organizationsDao.insertOrganization(OrganizationsCompanion.insert(name: 'Org', type: 'franchisee', parentCommissaryId: Value(commissaryId)));
    final itemId = await db.itemsDao.insertItem(name: 'Cake', organizationId: orgId);
    final ingredientId = await ingredientsDao.insertIngredient(name: 'Flour', commissaryId: commissaryId);
    await db.recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredientId, quantityNeeded: 1.0, unit: 'kg');

    expect(() => ingredientsDao.softDeleteIngredient(ingredientId), throwsException);
  });

  test('13. Get ingredient by name finds the correct ingredient', () async {
    await ingredientsDao.insertIngredient(name: 'FindMe', commissaryId: commissaryId);
    final ingredient = await ingredientsDao.getIngredientByName('FindMe', commissaryId: commissaryId);
    expect(ingredient, isNotNull);
    expect(ingredient!.name, 'FindMe');
  });

  test('14. Filter by category ID in getAllIngredients works', () async {
    final cat1Id = await db.categoriesDao.insertCategory(name: 'Dairy');
    final cat2Id = await db.categoriesDao.insertCategory(name: 'Bakery');
    await ingredientsDao.insertIngredient(name: 'Milk', commissaryId: commissaryId, categoryId: cat1Id);
    await ingredientsDao.insertIngredient(name: 'Bread', commissaryId: commissaryId, categoryId: cat2Id);

    final dairyItems = await ingredientsDao.getAllIngredients(categoryId: cat1Id);
    expect(dairyItems.length, 1);
    expect(dairyItems.first.name, 'Milk');
  });

  test('15. Sort order in getAllIngredients works (by stock desc)', () async {
    await ingredientsDao.insertIngredient(name: 'A', commissaryId: commissaryId, stock: 10);
    await ingredientsDao.insertIngredient(name: 'B', commissaryId: commissaryId, stock: 30);
    await ingredientsDao.insertIngredient(name: 'C', commissaryId: commissaryId, stock: 20);

    final sorted = await ingredientsDao.getAllIngredients(sortOrder: IngredientSortOrder.stockDesc);
    expect(sorted.map((i) => i.name).toList(), ['B', 'C', 'A']);
  });

  test('16. Get ingredient count works with filters', () async {
    final cat1Id = await db.categoriesDao.insertCategory(name: 'Dairy');
    await ingredientsDao.insertIngredient(name: 'Milk', commissaryId: commissaryId, categoryId: cat1Id);
    await ingredientsDao.insertIngredient(name: 'Cheese', commissaryId: commissaryId, categoryId: cat1Id);
    await ingredientsDao.insertIngredient(name: 'Bread', commissaryId: commissaryId);

    final count = await ingredientsDao.getIngredientCount(categoryId: cat1Id);
    expect(count, 2);
  });
}
