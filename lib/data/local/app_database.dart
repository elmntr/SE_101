import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables/items.dart';
import 'tables/users.dart'; // ADDED: Users table definition for authentication data.
import 'tables/roles.dart'; // ADDED: Roles table definition for permission management.

part 'app_database.g.dart'; // generated file

// ADDED: Registered `Users` and `Roles` alongside `Items` so Drift can manage account storage.
@DriftDatabase(tables: [Items, Users, Roles])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3; // UPDATED: Bump schema to account for the new Users & Roles tables.

  @override
  MigrationStrategy get migration => MigrationStrategy(
        // ADDED: Ensure all tables exist on initial creation.
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        // ADDED: Create or alter tables when upgrading from older schemas.
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(users);
          }
          if (from < 3) {
            await m.createTable(roles);
            await m.addColumn(users, users.name);
            await m.addColumn(users, users.phone);
          }
        },
      );

  // ---- CRUD Methods ----

  Future<List<Item>> getAllItems() => select(items).get();

  Stream<List<Item>> watchAllItems() => select(items).watch();

  Future<int> insertItem(ItemsCompanion item) => into(items).insert(item);

  Future<bool> updateItemData(Item item) => update(items).replace(item);

  Future<int> deleteItemById(int id) =>
      (delete(items)..where((t) => t.id.equals(id))).go();

  // Optional helper to clear db
  Future<void> clearAll() async {
    await delete(items).go();
  }

  // ---- Role Management Methods ----

  // ADDED: Inserts a new role definition.
  Future<int> insertRole(RolesCompanion role) => into(roles).insert(role);

  // ADDED: Returns all roles for listing.
  Future<List<Role>> getAllRoles() => select(roles).get();

  // ADDED: Watches role updates to keep the UI in sync.
  Stream<List<Role>> watchAllRoles() => select(roles).watch();

  // ADDED: Fetches a role by name, returning null when missing.
  Future<Role?> getRoleByName(String name) {
    return (select(roles)..where((tbl) => tbl.name.equals(name))).getSingleOrNull();
  }

  // ADDED: Removes a role if no users depend on it; returns true on success.
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

  // ---- User Management Methods ----

  // ADDED: Inserts a new user account row.
  Future<int> insertUser(UsersCompanion user) => into(users).insert(user);

  // ADDED: Removes a user account by id.
  Future<int> deleteUserById(int id) =>
      (delete(users)..where((tbl) => tbl.id.equals(id))).go();

  // ADDED: Watches user updates to keep admin UI current.
  Stream<List<User>> watchAllUsers() => select(users).watch();

  // ADDED: Updates role binding for a user.
  Future<int> assignRoleToUser(int userId, String roleName) =>
      (update(users)..where((tbl) => tbl.id.equals(userId))).write(
        UsersCompanion(role: Value(roleName)),
      );

  // ADDED: Returns the user matching email/password or null if credentials are invalid.
  Future<User?> authenticateUser(String email, String password) {
    return (select(users)
          ..where((tbl) => tbl.email.equals(email) & tbl.password.equals(password)))
        .getSingleOrNull();
  }

  // ADDED: Lookup helper so UI can load the full account after authentication.
  Future<User?> findUserById(int id) {
    return (select(users)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // ADDED: Ensures the database has at least one admin and one employee for demos/tests.
  Future<void> seedDefaultAccounts() async {
    await seedDefaultRoles();

    final existingAdmin = await (select(users)..where((tbl) => tbl.email.equals('admin@chickenjoo.com'))).getSingleOrNull();
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

    final existingEmployee = await (select(users)..where((tbl) => tbl.email.equals('employee@chickenjoo.com'))).getSingleOrNull();
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

  // ADDED: Seeds admin & employee roles with default permissions.
  Future<void> seedDefaultRoles() async {
    final adminRole = await (select(roles)..where((tbl) => tbl.name.equals('admin'))).getSingleOrNull();
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

    final employeeRole = await (select(roles)..where((tbl) => tbl.name.equals('employee'))).getSingleOrNull();
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
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'inventory.db'));
    return NativeDatabase.createInBackground(file);
  });
}
