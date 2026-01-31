// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_item_stock_dao.dart';

// ignore_for_file: type=lint
mixin _$BranchItemStockDaoMixin on DatabaseAccessor<AppDatabase> {
  $OrganizationsTable get organizations => attachedDatabase.organizations;
  $CategoriesTable get categories => attachedDatabase.categories;
  $ItemsTable get items => attachedDatabase.items;
  $BranchItemStockTable get branchItemStock => attachedDatabase.branchItemStock;
  BranchItemStockDaoManager get managers => BranchItemStockDaoManager(this);
}

class BranchItemStockDaoManager {
  final _$BranchItemStockDaoMixin _db;
  BranchItemStockDaoManager(this._db);
  $$OrganizationsTableTableManager get organizations =>
      $$OrganizationsTableTableManager(_db.attachedDatabase, _db.organizations);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
  $$BranchItemStockTableTableManager get branchItemStock =>
      $$BranchItemStockTableTableManager(
        _db.attachedDatabase,
        _db.branchItemStock,
      );
}
