// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organizations_dao.dart';

// ignore_for_file: type=lint
mixin _$OrganizationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $OrganizationsTable get organizations => attachedDatabase.organizations;
  OrganizationsDaoManager get managers => OrganizationsDaoManager(this);
}

class OrganizationsDaoManager {
  final _$OrganizationsDaoMixin _db;
  OrganizationsDaoManager(this._db);
  $$OrganizationsTableTableManager get organizations =>
      $$OrganizationsTableTableManager(_db.attachedDatabase, _db.organizations);
}
