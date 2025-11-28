import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables/items.dart';
import 'tables/users.dart';
import 'tables/roles.dart';

import 'package:flutter/foundation.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Items, Users, Roles])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (Migrator m) async {
    await m.createAll();
  },

  onUpgrade: (Migrator m, int from, int to) async {
    final executor = m.database.executor;

    // Helper: table exists?
    Future<bool> tableExists(String table) async {
      final result = await executor.runSelect(
        'SELECT name FROM sqlite_master WHERE type = ? AND name = ?',
        ['table', table],
      );
      return result.isNotEmpty;
    }

    // Helper: column exists?
    Future<bool> columnExists(String table, String column) async {
      final columns = await executor.runSelect(
        'PRAGMA table_info($table)',
        [], // PRAGMA takes NO parameters → empty list required
      );
      return columns.any((c) => c['name'] == column);
    }

    // ----------- v2 MIGRATION: Users table -----------
    if (!await tableExists('users')) {
      await m.createTable(users);
    }

    // ----------- v3 MIGRATION: Roles table + new user columns -----------
    if (!await tableExists('roles')) {
      await m.createTable(roles);
    }

    // Add `name` column if missing
    if (!await columnExists('users', 'name')) {
      await m.addColumn(users, users.name);
    }

    // Add `phone` column if missing
    if (!await columnExists('users', 'phone')) {
      await m.addColumn(users, users.phone);
    }
  },
);


  Future<List<Item>> getAllItems() => select(items).get();
  Stream<List<Item>> watchAllItems() => select(items).watch();
  Future<int> insertItem(ItemsCompanion item) => into(items).insert(item);
  Future<bool> updateItemData(Item item) => update(items).replace(item);
  Future<int> deleteItemById(int id) =>
      (delete(items)..where((t) => t.id.equals(id))).go();

  Future<void> clearAll() async {
    await delete(items).go();
  }

  Future<int> insertRole(RolesCompanion role) => into(roles).insert(role);
  Future<List<Role>> getAllRoles() => select(roles).get();
  Stream<List<Role>> watchAllRoles() => select(roles).watch();
  Future<Role?> getRoleByName(String name) {
    return (select(roles)..where((tbl) => tbl.name.equals(name))).getSingleOrNull();
  }

  Future<bool> deleteRoleById(int id) async {
    final role = await (select(roles)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (role == null) return false;

    final inUse = await (select(users)..where((tbl) => tbl.role.equals(role.name))).get();
    if (inUse.isNotEmpty) {
      return false;
    }

    await (delete(roles)..where((tbl) => tbl.id.equals(id))).go();
    return true;
  }

  Future<int> insertUser(UsersCompanion user) => into(users).insert(user);
  Future<int> deleteUserById(int id) =>
      (delete(users)..where((tbl) => tbl.id.equals(id))).go();
  Stream<List<User>> watchAllUsers() => select(users).watch();
  Future<int> assignRoleToUser(int userId, String roleName) =>
      (update(users)..where((tbl) => tbl.id.equals(userId))).write(
        UsersCompanion(role: Value(roleName)),
      );

  Future<User?> authenticateUser(String email, String password) {
    return (select(users)
          ..where((tbl) => tbl.email.equals(email) & tbl.password.equals(password)))
        .getSingleOrNull();
  }

  Future<User?> findUserById(int id) {
    return (select(users)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> seedDefaultAccounts() async {
    await seedDefaultRoles();

    final existingAdmin =
        await (select(users)..where((tbl) => tbl.email.equals('admin@chickenjoo.com')))
            .getSingleOrNull();
    if (existingAdmin == null) {
      await insertUser(
        UsersCompanion.insert(
          email: 'admin@chickenjoo.com',
          name: const Value('Administrator'),
          phone: const Value('0000000000'),
          password: 'admin123',
          role: 'admin',
        ),
      );
    }

    final existingEmployee =
        await (select(users)
              ..where((tbl) => tbl.email.equals('employee@chickenjoo.com')))
            .getSingleOrNull();
    if (existingEmployee == null) {
      await insertUser(
        UsersCompanion.insert(
          email: 'employee@chickenjoo.com',
          name: const Value('Sample Employee'),
          phone: const Value('09123456789'),
          password: 'employee123',
          role: 'employee',
        ),
      );
    }
  }

  Future<void> seedDefaultRoles() async {
    final adminRole =
        await (select(roles)..where((tbl) => tbl.name.equals('admin'))).getSingleOrNull();
    if (adminRole == null) {
      await insertRole(
        RolesCompanion.insert(
          name: 'admin',
          canViewInventory: const Value(true),
          canAddInventory: const Value(true),
          canEditInventory: const Value(true),
          canDeleteInventory: const Value(true),
          canManageEmployees: const Value(true),
          canManageRoles: const Value(true),
          canViewReports: const Value(true),
          canAccessSettings: const Value(true),
        ),
      );
    }

    final employeeRole =
        await (select(roles)..where((tbl) => tbl.name.equals('employee'))).getSingleOrNull();
    if (employeeRole == null) {
      await insertRole(
        RolesCompanion.insert(
          name: 'employee',
        ),
      );
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    File file;
    if (kDebugMode) {
      // Easy access during development
      file = File('inventory.db'); 
    } else {
      // Normal path for release
      final dbFolder = await getApplicationDocumentsDirectory();
      file = File(p.join(dbFolder.path, 'inventory.db'));
    }
    return NativeDatabase.createInBackground(file);
  });
}


