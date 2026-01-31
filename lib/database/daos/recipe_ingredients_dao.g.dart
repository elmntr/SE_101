// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_ingredients_dao.dart';

// ignore_for_file: type=lint
mixin _$RecipeIngredientsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $OrganizationsTable get organizations => attachedDatabase.organizations;
  $ItemsTable get items => attachedDatabase.items;
  $IngredientsTable get ingredients => attachedDatabase.ingredients;
  $RecipeIngredientsTable get recipeIngredients =>
      attachedDatabase.recipeIngredients;
  RecipeIngredientsDaoManager get managers => RecipeIngredientsDaoManager(this);
}

class RecipeIngredientsDaoManager {
  final _$RecipeIngredientsDaoMixin _db;
  RecipeIngredientsDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$OrganizationsTableTableManager get organizations =>
      $$OrganizationsTableTableManager(_db.attachedDatabase, _db.organizations);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
  $$IngredientsTableTableManager get ingredients =>
      $$IngredientsTableTableManager(_db.attachedDatabase, _db.ingredients);
  $$RecipeIngredientsTableTableManager get recipeIngredients =>
      $$RecipeIngredientsTableTableManager(
        _db.attachedDatabase,
        _db.recipeIngredients,
      );
}
