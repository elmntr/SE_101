// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_sales_summary_dao.dart';

// ignore_for_file: type=lint
mixin _$DailySalesSummaryDaoMixin on DatabaseAccessor<AppDatabase> {
  $OrganizationsTable get organizations => attachedDatabase.organizations;
  $CategoriesTable get categories => attachedDatabase.categories;
  $ItemsTable get items => attachedDatabase.items;
  $DailySalesSummaryTable get dailySalesSummary =>
      attachedDatabase.dailySalesSummary;
  DailySalesSummaryDaoManager get managers => DailySalesSummaryDaoManager(this);
}

class DailySalesSummaryDaoManager {
  final _$DailySalesSummaryDaoMixin _db;
  DailySalesSummaryDaoManager(this._db);
  $$OrganizationsTableTableManager get organizations =>
      $$OrganizationsTableTableManager(_db.attachedDatabase, _db.organizations);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
  $$DailySalesSummaryTableTableManager get dailySalesSummary =>
      $$DailySalesSummaryTableTableManager(
        _db.attachedDatabase,
        _db.dailySalesSummary,
      );
}
