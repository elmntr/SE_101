// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_change_requests_dao.dart';

// ignore_for_file: type=lint
mixin _$StockChangeRequestsDaoMixin on DatabaseAccessor<AppDatabase> {
  $OrganizationsTable get organizations => attachedDatabase.organizations;
  $CategoriesTable get categories => attachedDatabase.categories;
  $ItemsTable get items => attachedDatabase.items;
  $RolesTable get roles => attachedDatabase.roles;
  $UsersTable get users => attachedDatabase.users;
  $StockChangeRequestsTable get stockChangeRequests =>
      attachedDatabase.stockChangeRequests;
  StockChangeRequestsDaoManager get managers =>
      StockChangeRequestsDaoManager(this);
}

class StockChangeRequestsDaoManager {
  final _$StockChangeRequestsDaoMixin _db;
  StockChangeRequestsDaoManager(this._db);
  $$OrganizationsTableTableManager get organizations =>
      $$OrganizationsTableTableManager(_db.attachedDatabase, _db.organizations);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
  $$RolesTableTableManager get roles =>
      $$RolesTableTableManager(_db.attachedDatabase, _db.roles);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$StockChangeRequestsTableTableManager get stockChangeRequests =>
      $$StockChangeRequestsTableTableManager(
        _db.attachedDatabase,
        _db.stockChangeRequests,
      );
}
