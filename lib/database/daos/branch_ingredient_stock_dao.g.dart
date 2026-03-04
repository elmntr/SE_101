// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_ingredient_stock_dao.dart';

// ignore_for_file: type=lint
mixin _$BranchIngredientStockDaoMixin on DatabaseAccessor<AppDatabase> {
  $OrganizationsTable get organizations => attachedDatabase.organizations;
  $IngredientsTable get ingredients => attachedDatabase.ingredients;
  $BranchIngredientStockTable get branchIngredientStock =>
      attachedDatabase.branchIngredientStock;
  BranchIngredientStockDaoManager get managers =>
      BranchIngredientStockDaoManager(this);
}

class BranchIngredientStockDaoManager {
  final _$BranchIngredientStockDaoMixin _db;
  BranchIngredientStockDaoManager(this._db);
  $$OrganizationsTableTableManager get organizations =>
      $$OrganizationsTableTableManager(_db.attachedDatabase, _db.organizations);
  $$IngredientsTableTableManager get ingredients =>
      $$IngredientsTableTableManager(_db.attachedDatabase, _db.ingredients);
  $$BranchIngredientStockTableTableManager get branchIngredientStock =>
      $$BranchIngredientStockTableTableManager(
        _db.attachedDatabase,
        _db.branchIngredientStock,
      );
}
