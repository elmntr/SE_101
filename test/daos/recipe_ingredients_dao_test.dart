// test/daos/recipe_ingredients_dao_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import '../database/test_database.dart';
import 'package:chickenjoo_inventory/database/daos/recipe_ingredients_dao.dart';

void main() {
  late AppDatabase db;
  late RecipeIngredientsDao recipeIngredientsDao;
  late int commissaryId;
  late int franchiseeId;
  late int itemId;
  late int ingredient1Id;
  late int ingredient2Id;

  setUp(() async {
    db = createTestDatabase();
    recipeIngredientsDao = db.recipeIngredientsDao;

    commissaryId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Commissary', type: 'commissary'),
    );
    franchiseeId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Franchisee', type: 'franchisee', parentCommissaryId: Value(commissaryId)),
    );
    itemId = await db.itemsDao.insertItem(name: 'Burger', organizationId: franchiseeId);
    ingredient1Id = await db.ingredientsDao.insertIngredient(name: 'Bun', commissaryId: commissaryId, stock: 100);
    ingredient2Id = await db.ingredientsDao.insertIngredient(name: 'Patty', commissaryId: commissaryId, stock: 50);
  });

  tearDown(() async {
    await db.close();
  });

  test('1. Insert recipe ingredient successfully', () async {
    final id = await recipeIngredientsDao.insertRecipeIngredient(
      itemId: itemId,
      ingredientId: ingredient1Id,
      quantityNeeded: 2,
      unit: 'pieces',
    );
    final recipe = await recipeIngredientsDao.getRecipeIngredientById(id);
    expect(recipe, isNotNull);
    expect(recipe!.itemId, itemId);
    expect(recipe.ingredientId, ingredient1Id);
    expect(recipe.quantityNeeded, 2);
  });

  test('2. Get ingredients for item returns correct list', () async {
    await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredient1Id, quantityNeeded: 2, unit: 'pieces');
    await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredient2Id, quantityNeeded: 1, unit: 'piece');
    final ingredients = await recipeIngredientsDao.getIngredientsForItem(itemId);
    expect(ingredients.length, 2);
    expect(ingredients.map((ri) => ri.ingredientId), containsAll([ingredient1Id, ingredient2Id]));
  });

  test('3. Update recipe ingredient changes its quantity', () async {
    final id = await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredient1Id, quantityNeeded: 2, unit: 'pieces');
    final recipe = (await recipeIngredientsDao.getRecipeIngredientById(id))!;
    await recipeIngredientsDao.updateRecipeIngredient(recipe.copyWith(quantityNeeded: 3.0));
    final updated = await recipeIngredientsDao.getRecipeIngredientById(id);
    expect(updated!.quantityNeeded, 3);
  });

  test('4. Soft delete marks recipe ingredient as deleted', () async {
    final id = await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredient1Id, quantityNeeded: 2, unit: 'pieces');
    await recipeIngredientsDao.softDeleteRecipeIngredient(id);
    final recipe = await recipeIngredientsDao.getRecipeIngredientById(id);
    expect(recipe!.isDeleted, isTrue);
  });

  test('5. Get ingredients for item ignores soft-deleted ones', () async {
    await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredient1Id, quantityNeeded: 2, unit: 'pieces');
    final idToDelete = await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredient2Id, quantityNeeded: 1, unit: 'piece');
    await recipeIngredientsDao.softDeleteRecipeIngredient(idToDelete);
    final ingredients = await recipeIngredientsDao.getIngredientsForItem(itemId);
    expect(ingredients.length, 1);
    expect(ingredients.first.ingredientId, ingredient1Id);
  });

  test('6. Get items using ingredient returns correct list', () async {
    final itemId2 = await db.itemsDao.insertItem(name: 'Double Burger', organizationId: franchiseeId);
    await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredient1Id, quantityNeeded: 2, unit: 'pieces');
    await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId2, ingredientId: ingredient1Id, quantityNeeded: 4, unit: 'pieces');
    final items = await recipeIngredientsDao.getItemsUsingIngredient(ingredient1Id);
    expect(items.length, 2);
    expect(items.map((ri) => ri.itemId), containsAll([itemId, itemId2]));
  });

  test('7. Delete all for item soft-deletes all ingredients for that recipe', () async {
    await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredient1Id, quantityNeeded: 2, unit: 'pieces');
    await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredient2Id, quantityNeeded: 1, unit: 'piece');
    await recipeIngredientsDao.deleteAllForItem(itemId);
    final ingredients = await recipeIngredientsDao.getIngredientsForItem(itemId);
    expect(ingredients.isEmpty, isTrue);
  });

  test('8. Calculate ingredient requirements works correctly', () async {
    await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredient1Id, quantityNeeded: 2, unit: 'pieces');
    await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredient2Id, quantityNeeded: 1.5, unit: 'piece');
    final requirements = await recipeIngredientsDao.calculateIngredientRequirements(itemId, 10);
    expect(requirements.length, 2);
    expect(requirements[ingredient1Id], 20);
    expect(requirements[ingredient2Id], 15);
  });

  test('9. Can produce items returns true when stock is sufficient', () async {
    await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredient1Id, quantityNeeded: 10, unit: 'pieces'); // Needs 100
    final canProduce = await recipeIngredientsDao.canProduceItems(itemId, 10);
    expect(canProduce, isTrue);
  });

  test('10. Can produce items returns false when stock is insufficient', () async {
    await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredient1Id, quantityNeeded: 20, unit: 'pieces'); // Needs 200, has 100
    final canProduce = await recipeIngredientsDao.canProduceItems(itemId, 10);
    expect(canProduce, isFalse);
  });

  test('11. Deduct ingredients for production updates ingredient stock', () async {
    await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredient1Id, quantityNeeded: 2, unit: 'pieces');
    await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredient2Id, quantityNeeded: 1, unit: 'piece');
    await recipeIngredientsDao.deductIngredientsForProduction(itemId, 5);

    final ing1 = await db.ingredientsDao.getIngredientById(ingredient1Id);
    final ing2 = await db.ingredientsDao.getIngredientById(ingredient2Id);

    expect(ing1!.stock, 90); // 100 - (2*5)
    expect(ing2!.stock, 45); // 50 - (1*5)
  });

  test('12. Deduct ingredients for production fails if stock is insufficient', () async {
    await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredient1Id, quantityNeeded: 101, unit: 'pieces');
    final success = await recipeIngredientsDao.deductIngredientsForProduction(itemId, 1);
    expect(success, isFalse);
    final ing1 = await db.ingredientsDao.getIngredientById(ingredient1Id);
    expect(ing1!.stock, 100); // Stock should not change
  });

  test('13. Replace recipe for item works correctly', () async {
    await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredient1Id, quantityNeeded: 1, unit: 'old');
    final newRecipe = [
      RecipeIngredientsCompanion.insert(itemId: itemId, ingredientId: ingredient2Id, quantityNeeded: 99, unit: 'new')
    ];
    await recipeIngredientsDao.replaceRecipeForItem(itemId, newRecipe);

    final ingredients = await recipeIngredientsDao.getIngredientsForItem(itemId);
    expect(ingredients.length, 1);
    expect(ingredients.first.ingredientId, ingredient2Id);
    expect(ingredients.first.quantityNeeded, 99);
  });

  test('14. Get recipe summary provides a formatted string', () async {
    await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredient1Id, quantityNeeded: 2, unit: 'pieces');
    await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredient2Id, quantityNeeded: 1, unit: 'patty');
    final summary = await recipeIngredientsDao.getRecipeSummary(itemId);
    expect(summary, contains('2.0 pieces Bun'));
    expect(summary, contains('1.0 patty Patty'));
  });

  test('15. Get unsynced count is correct', () async {
    final id1 = await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredient1Id, quantityNeeded: 1, unit: 'a');
    await recipeIngredientsDao.insertRecipeIngredient(itemId: itemId, ingredientId: ingredient2Id, quantityNeeded: 1, unit: 'b');
    await recipeIngredientsDao.markAsSynced([id1]);

    final count = await recipeIngredientsDao.getUnsyncedRecipeIngredientCount();
    expect(count, 1);
  });
}
