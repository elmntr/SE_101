// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'items_dao.dart';

// ignore_for_file: type=lint
mixin _$ItemsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $OrganizationsTable get organizations => attachedDatabase.organizations;
  $ItemsTable get items => attachedDatabase.items;
  ItemsDaoManager get managers => ItemsDaoManager(this);
}

class ItemsDaoManager {
  final _$ItemsDaoMixin _db;
  ItemsDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$OrganizationsTableTableManager get organizations =>
      $$OrganizationsTableTableManager(_db.attachedDatabase, _db.organizations);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
}
