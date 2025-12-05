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
import 'package:flutter/foundation.dart'; // kDebugMode
part 'app_database.g.dart';

@DriftDatabase(tables: [Items, Users, Roles], daos: [ItemsDao, UsersDao, RolesDao])

class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forSeeding(QueryExecutor executor) : super(executor);
  

  @override
  int get schemaVersion => 1;

  // Expose DAOs for convenience
  
}
Future<void> seedTestEmployee(AppDatabase db) async {
  // Check if role already exists
  final existingRoles = await db.rolesDao.getAllRoles();
  Role? employeeRole = existingRoles.firstWhere(
    (r) => r.name == 'employee',
    orElse: () => Role(
      id: 0,
      name: 'employee',
      description: 'Test Employee Role',
      canViewInventory: true,
      canAddInventory: true,
      canEditInventory: true,
      canDeleteInventory: false,
      canViewReports: false,
      canExportData: false,
      canAccessSettings: false,
      isSystemRole: false,
      isActive: true,
      
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
      canManageEmployees: false,
      canManageRoles: false
    ),
  );

  // Insert the role if it didn’t exist
  if (employeeRole.id == 0) {
    final roleId = await db.rolesDao.insertRole(
      RolesCompanion.insert(
        name: 'employee',
        description: Value('Test Employee Role'),
        canViewInventory: Value(true),
        canAddInventory: Value(true),
        canEditInventory: Value(true),
        canDeleteInventory: Value(false),
        canViewReports: Value(false),
        canExportData: Value(false),
        canAccessSettings: Value(false),
      ),
    );

    employeeRole = (await db.rolesDao.getAllRoles())
        .firstWhere((r) => r.id == roleId);
  }

  // Check if user exists
  final users = await db.usersDao.getAllUsers();
  final existingUser =
      users.firstWhere((u) => u.username == 'test_employee', orElse: () => User(
        id: 0,
        username: 'test_employee',
        email: 'employee@test.com',
        password: '123456',
        phone: '',
        roleId: employeeRole!.id,
        isActive: true,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      ));
       // 2️⃣ Insert a test employee user
  final existingUsers = await db.usersDao.getAllUsers();
  final alreadyExists = existingUsers.any((u) => u.username == 'employee');

  if (!alreadyExists) {
    await db.usersDao.insertUser(
      UsersCompanion.insert(
        username: 'employee',
        email: 'employee@example.com',
        password: 'password123',
        roleId: employeeRole.id, // ✅ non-null
        isActive: Value(true),
      ),
    );
  }

  

  print('✅ Test employee account created: test_employee / 123456');
}

// Open the sqlite file in the application documents directory
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFile = File('app_inventory.db');
    

    if (!dbFile.existsSync()) {
      dbFile.createSync();
      print('DEBUG: Database file created at ${dbFile.path}');
    } else {
      print('DEBUG: Using existing database at ${dbFile.path}');
    }

    final nativeDb = NativeDatabase.createInBackground(
      dbFile,
      logStatements: true,
      setup: (db) {
        db.execute('PRAGMA journal_mode=WAL;');
        db.execute('PRAGMA synchronous=NORMAL;');
      },
    );

    // ✅ Seed test data automatically after DB opens
    final appDb = AppDatabase.forSeeding(nativeDb);
    seedTestEmployee(appDb);

    return nativeDb;
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
Future<void> deleteDatabaseFile() async {
  final dbFile = File('app_inventory.db');
  if (await dbFile.exists()) {
    await dbFile.delete();
    print('Database file deleted.');
  } else {
    print('Database file does not exist.');
  }

  
}


