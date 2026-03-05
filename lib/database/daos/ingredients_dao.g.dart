// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredients_dao.dart';

// ignore_for_file: type=lint
mixin _$IngredientsDaoMixin on DatabaseAccessor<AppDatabase> {
  $OrganizationsTable get organizations => attachedDatabase.organizations;
  $IngredientsTable get ingredients => attachedDatabase.ingredients;
  IngredientsDaoManager get managers => IngredientsDaoManager(this);
}

class IngredientsDaoManager {
  final _$IngredientsDaoMixin _db;
  IngredientsDaoManager(this._db);
  $$OrganizationsTableTableManager get organizations =>
      $$OrganizationsTableTableManager(_db.attachedDatabase, _db.organizations);
  $$IngredientsTableTableManager get ingredients =>
      $$IngredientsTableTableManager(_db.attachedDatabase, _db.ingredients);
}
