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
import 'package:flutter/foundation.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Items, Users, Roles], daos: [ItemsDao, UsersDao, RolesDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ✅ Call this AFTER database is fully initialized
  Future<void> seedDatabase() async {
    await seedAdminAccount(this);
    await seedTestEmployee(this);
    await seedTestItems(this);
  }
}

// ✅ NEW: Seed test items
Future<void> seedTestItems(AppDatabase db) async {
  final existingItems = await db.itemsDao.getAllItems();
  
  if (existingItems.isEmpty) {
    print('🌱 Seeding test items...');
    
    final testItems = [
      {'name': 'Chicken Breast', 'stock': 50, 'sold': 10, 'spoilage': 2},
      {'name': 'Chicken Thigh', 'stock': 40, 'sold': 15, 'spoilage': 1},
      {'name': 'Chicken Wings', 'stock': 30, 'sold': 20, 'spoilage': 3},
      {'name': 'Eggs (Dozen)', 'stock': 100, 'sold': 25, 'spoilage': 0},
      {'name': 'Cooking Oil (L)', 'stock': 20, 'sold': 5, 'spoilage': 0},
    ];
    
    for (final item in testItems) {
      await db.itemsDao.insertItem(
        name: item['name'] as String,
        stock: item['stock'] as int,
      );
    }
    
    print('✅ Test items seeded successfully');
  } else {
    print('📦 Items already exist in database (${existingItems.length} items)');
  }
}
Future<void> seedAdminAccount(AppDatabase db) async {
  // Check if admin role already exists
  final existingRoles = await db.rolesDao.getAllRoles();
  Role? adminRole = existingRoles.firstWhere(
    (r) => r.name == 'Admin',
    orElse: () => Role(
      id: 0,
      name: '',
      description: null,
      canViewInventory: false,
      canAddInventory: false,
      canEditInventory: false,
      canDeleteInventory: false,
      canViewReports: false,
      canExportData: false,
      canAccessSettings: false,
      isSystemRole: false,
      isActive: false,
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
      canManageEmployees: false,
      canManageRoles: false,
    ),
  );

  // Insert Admin role if it doesn't exist
  if (adminRole.id == 0) {
    print('🔧 Creating Admin role...');
    final roleId = await db.rolesDao.insertRole(
      RolesCompanion.insert(
        name: 'Admin',
        description: const Value('System Administrator with full access'),
        canViewInventory: const Value(true),
        canAddInventory: const Value(true),
        canEditInventory: const Value(true),
        canDeleteInventory: const Value(true),
        canViewReports: const Value(true),
        canExportData: const Value(true),
        canAccessSettings: const Value(true),
        canManageEmployees: const Value(true),
        canManageRoles: const Value(true),
        isSystemRole: const Value(true),
      ),
    );

    adminRole = (await db.rolesDao.getAllRoles())
        .firstWhere((r) => r.id == roleId);
    print('✅ Admin role created successfully');
  } else {
    print('👑 Admin role already exists');
  }

  // Check if admin user exists
  final existingUsers = await db.usersDao.getAllUsers();
  final adminExists = existingUsers.any((u) => u.username == 'admin');

  if (!adminExists) {
    print('🔧 Creating Admin user account...');
    await db.usersDao.insertUser(
      UsersCompanion.insert(
        username: 'admin',
        email: 'admin@commissary.com',
        password: 'admin123',
        roleId: adminRole.id,
        isActive: const Value(true),
      ),
    );
    print('✅ Admin account created successfully!');
    print('📧 Email: admin@commissary.com');
    print('🔑 Password: admin123');
    print('⚠️  IMPORTANT: Change this password after first login!');
  } else {
    print('👑 Admin user already exists');
  }
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

  // Insert the role if it didn't exist
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
  final existingUsers = await db.usersDao.getAllUsers();
  final alreadyExists = existingUsers.any((u) => u.username == 'employee');

  if (!alreadyExists) {
    await db.usersDao.insertUser(
      UsersCompanion.insert(
        username: 'employee',
        email: 'employee@example.com',
        password: 'password123',
        roleId: employeeRole.id,
        isActive: Value(true),
      ),
    );
    print('✅ Test employee account created: employee / password123');
  } else {
    print('👤 Employee user already exists');
  }
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

    // ✅ Return the connection WITHOUT creating a second database instance
    return nativeDb;
  });
}

// Helper class for JOIN queries
class UserWithRole {
  final User user;
  final Role? role;

  UserWithRole({required this.user, required this.role});

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