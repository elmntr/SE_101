// lib/database/tables/recipe_ingredients.dart
import 'package:drift/drift.dart';
import 'items.dart';
import 'ingredients.dart';

/// RecipeIngredients table - Junction table linking Items (recipes) to Ingredients
///
/// Business Flow:
/// 1. Commissary creates an Item (e.g., "Fried Chicken Meal")
/// 2. Commissary specifies which ingredients make up that item:
///    - 200g Chicken Breast
///    - 50ml Cooking Oil
///    - 10g Garlic
/// 3. When producing items, system deducts ingredients from stock
///
/// Example:
/// itemId: 5 (Fried Chicken Meal)
/// ingredientId: 1 (Chicken Breast), quantityNeeded: 200, unit: "g"
/// ingredientId: 3 (Cooking Oil), quantityNeeded: 50, unit: "ml"
class RecipeIngredients extends Table {
  /// Primary key
  IntColumn get id => integer().autoIncrement()();

  /// Reference to the Item/Recipe (final product)
  IntColumn get itemId =>
      integer().references(Items, #id, onDelete: KeyAction.cascade)();

  /// Reference to the Ingredient (raw material)
  IntColumn get ingredientId =>
      integer().references(Ingredients, #id, onDelete: KeyAction.cascade)();

  /// How much of this ingredient is needed for ONE unit of the item
  /// Example: 200 grams of chicken breast per fried chicken meal
  RealColumn get quantityNeeded => real()();

  /// Unit of measurement for this ingredient in the recipe
  /// Should match or be convertible to ingredient's base unit
  /// Example: "g" for grams, "ml" for milliliters, "pieces"
  TextColumn get unit => text().withLength(min: 1, max: 50)();

  /// Optional notes (e.g., "Cut into strips", "Marinate for 2 hours")
  TextColumn get notes => text().nullable().withLength(max: 500)();

  /// Track when this recipe ingredient was added/modified
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get lastUpdated =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();

  /// Soft delete (in case ingredient is removed from recipe)
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Sync fields for cloud synchronization
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get cloudId => text().nullable()();
}
