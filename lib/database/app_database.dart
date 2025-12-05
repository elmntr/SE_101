// lib/database/app_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/items.dart';
import 'tables/users.dart';
import 'tables/roles.dart';

import 'daos/items_dao.dart';
import 'daos/users_dao.dart';
import 'daos/roles_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Items, Users, Roles], daos: [ItemsDao, UsersDao, RolesDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Expose DAOs for convenience
  ItemsDao get itemsDao => ItemsDao(this);
  UsersDao get usersDao => UsersDao(this);
  RolesDao get rolesDao => RolesDao(this);
}

// Open the sqlite file in the application documents directory
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final docs = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(docs.path, 'app_inventory.db'));
    return NativeDatabase(dbFile);
  });
}

// Helper class for JOIN queries
class UserWithRole {
  final User user;
  final Role? role;

  UserWithRole({required this.user, required this.role});

  // Use username directly since firstName/lastName don't exist
  String get displayName => user.username;
}
