// lib/database/app_database.dart
import 'dart:io';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// ✅ Import existing tables
import 'tables/categories.dart';
import 'tables/roles.dart';

// ✅ Import NEW tables
import 'tables/organizations.dart';
import 'tables/ingredients.dart';
import 'tables/recipe_ingredients.dart';
import 'tables/stock_replenishment_requests.dart';
import 'tables/stock_change_requests.dart';

// ✅ Import MODIFIED tables
import 'tables/items.dart';
import 'tables/users.dart';

// ✅ Import existing DAOs
import 'daos/categories_dao.dart';
import 'daos/roles_dao.dart';

// ✅ Import MODIFIED DAOs
import 'daos/items_dao.dart';
import 'daos/users_dao.dart';

// ✅ Import NEW DAOs
import 'daos/organizations_dao.dart';
import 'daos/ingredients_dao.dart';
import 'daos/recipe_ingredients_dao.dart';
import 'daos/stock_replenishment_requests_dao.dart';
import 'daos/stock_change_requests_dao.dart';

import 'package:flutter/foundation.dart';

part 'app_database.g.dart';

/// ✅ Complete database with all 9 tables
@DriftDatabase(
  tables: [
    // Core tables
    Organizations,
    Categories,
    Roles,
    Users,

    // Inventory tables
    Items,
    Ingredients,
    RecipeIngredients,

    // Request tables
    StockReplenishmentRequests,
    StockChangeRequests,
  ],
  daos: [
    // Core DAOs
    OrganizationsDao,
    CategoriesDao,
    RolesDao,
    UsersDao,

    // Inventory DAOs
    ItemsDao,
    IngredientsDao,
    RecipeIngredientsDao,

    // Request DAOs
    StockReplenishmentRequestsDao,
    StockChangeRequestsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  final bool _seedData;

  AppDatabase({bool seedData = true})
    : _seedData = seedData,
      super(_openConnection());

  AppDatabase.test(super.executor) : _seedData = false;

  @override
  int get schemaVersion => 1; // Start fresh at version 1

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        print(' Creating fresh database...');

        // Create all tables
        await m.createAll();

        // Create indexes
        await _createAllIndexes();

        // Seed initial data
        if (_seedData) {
          await _seedInitialData();
        }

        print(' Database created successfully!');
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// ✅ Create all indexes for optimal performance
  Future<void> _createAllIndexes() async {
    print('📑 Creating indexes...');

    // Organizations indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_organizations_type ON organizations(type) WHERE is_active = 1',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_organizations_parent ON organizations(parent_commissary_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_organizations_cloud_id ON organizations(cloud_id)',
    );

    // Categories indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_categories_deleted ON categories(is_deleted)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_categories_name ON categories(name) WHERE is_deleted = 0',
    );

    // Roles indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_roles_name ON roles(name)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_roles_active ON roles(is_active)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_roles_cloud_id ON roles(cloud_id)',
    );

    // Users indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_users_username ON users(username)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_users_organization ON users(organization_id) WHERE is_active = 1',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_users_role ON users(role_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_users_cloud_id ON users(cloud_id)',
    );

    // Items indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_items_category ON items(category_id) WHERE is_deleted = 0',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_items_organization ON items(organization_id) WHERE is_deleted = 0',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_items_master ON items(master_item_id) WHERE is_deleted = 0',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_items_sync ON items(is_synced) WHERE is_deleted = 0',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_items_cloud_id ON items(cloud_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_items_updated ON items(last_updated DESC)',
    );

    // Ingredients indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_ingredients_commissary ON ingredients(commissary_id) WHERE is_deleted = 0',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_ingredients_category ON ingredients(category_id) WHERE is_deleted = 0',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_ingredients_cloud_id ON ingredients(cloud_id)',
    );

    // Recipe Ingredients indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_item ON recipe_ingredients(item_id) WHERE is_deleted = 0',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_ingredient ON recipe_ingredients(ingredient_id) WHERE is_deleted = 0',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_cloud_id ON recipe_ingredients(cloud_id)',
    );

    // Stock Replenishment Requests indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_replenishment_franchisee ON stock_replenishment_requests(franchisee_id, status) WHERE is_deleted = 0',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_replenishment_commissary ON stock_replenishment_requests(commissary_id, status) WHERE is_deleted = 0',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_replenishment_status ON stock_replenishment_requests(status) WHERE is_deleted = 0',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_replenishment_cloud_id ON stock_replenishment_requests(cloud_id)',
    );

    // Stock Change Requests indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_stock_changes_franchisee ON stock_change_requests(franchisee_id, status) WHERE is_deleted = 0',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_stock_changes_item ON stock_change_requests(item_id, status) WHERE is_deleted = 0',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_stock_changes_requested_by ON stock_change_requests(requested_by) WHERE is_deleted = 0',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_stock_changes_cloud_id ON stock_change_requests(cloud_id)',
    );

    print('✅ All indexes created');
  }

  /// ✅ Seed initial data (commissary, roles, admin user)
  Future<void> _seedInitialData() async {
    print('🌱 Seeding initial data...');

    try {
      // 1. Create Main Commissary organization
      final commissaryId = await organizationsDao.insertOrganization(
        OrganizationsCompanion.insert(
          name: 'Main Commissary',
          type: 'commissary',
          parentCommissaryId: const Value(null),
          contactPerson: const Value('Commissary Manager'),
          email: const Value('commissary@example.com'),
          phone: const Value('+63-123-4567'),
        ),
      );
      print('✅ Created Main Commissary (ID: $commissaryId)');

      // 2. Create default roles
      final adminRoleId = await rolesDao.insertRole(
        RolesCompanion.insert(
          name: 'Admin',
          description: const Value('Full system access'),
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

      await rolesDao.insertRole(
        RolesCompanion.insert(
          name: 'Manager',
          description: const Value('Management level access'),
          canViewInventory: const Value(true),
          canAddInventory: const Value(true),
          canEditInventory: const Value(true),
          canDeleteInventory: const Value(false),
          canViewReports: const Value(true),
          canExportData: const Value(true),
          canAccessSettings: const Value(true),
          canManageEmployees: const Value(true),
          canManageRoles: const Value(false),
          isSystemRole: const Value(true),
        ),
      );

      await rolesDao.insertRole(
        RolesCompanion.insert(
          name: 'Employee',
          description: const Value('Basic employee access'),
          canViewInventory: const Value(true),
          canAddInventory: const Value(false),
          canEditInventory: const Value(true),
          canDeleteInventory: const Value(false),
          canViewReports: const Value(false),
          canExportData: const Value(false),
          canAccessSettings: const Value(false),
          canManageEmployees: const Value(false),
          canManageRoles: const Value(false),
          isSystemRole: const Value(true),
        ),
      );

      await rolesDao.insertRole(
        RolesCompanion.insert(
          name: 'Viewer',
          description: const Value('Read-only access'),
          canViewInventory: const Value(true),
          canAddInventory: const Value(false),
          canEditInventory: const Value(false),
          canDeleteInventory: const Value(false),
          canViewReports: const Value(true),
          canExportData: const Value(false),
          canAccessSettings: const Value(false),
          canManageEmployees: const Value(false),
          canManageRoles: const Value(false),
          isSystemRole: const Value(true),
        ),
      );

      print('✅ Created 4 default roles');

      // 3. Create admin user
      await usersDao.insertUser(
        UsersCompanion.insert(
          username: 'admin',
          email: 'admin@example.com',
          password: 'admin123', // Will be hashed in DAO
          organizationId: commissaryId,
          roleId: adminRoleId,
          fullName: const Value('System Administrator'),
          phone: const Value('+63-123-4567'),
          isActive: const Value(true),
        ),
      );
      print('✅ Created admin user (username: admin, password: admin123)');

      // 4. Create sample categories
      await categoriesDao.insertCategory(
        name: 'Food',
        description: 'Food items',
      );
      await categoriesDao.insertCategory(
        name: 'Beverages',
        description: 'Drink items',
      );
      await categoriesDao.insertCategory(
        name: 'Raw Materials',
        description: 'Ingredients and supplies',
      );
      print('✅ Created 3 sample categories');

      print('✅ Initial data seeded successfully!');
      print('');
      print('═══════════════════════════════════════════');
      print('  🎉 DATABASE READY!');
      print('═══════════════════════════════════════════');
      print('  Login credentials:');
      print('  Username: admin');
      print('  Password: admin123');
      print('═══════════════════════════════════════════');
    } catch (e, stackTrace) {
      print('❌ Error seeding initial data: $e');
      print('Stack trace: $stackTrace');
      rethrow; // Rethrow to prevent app from starting with incomplete data
    }
  }

  /// ✅ Execute multiple statements in a transaction
  Future<T> executeInTransaction<T>(Future<T> Function() action) async {
    return await transaction(() async {
      try {
        return await action();
      } catch (e) {
        print('❌ Transaction failed: $e');
        rethrow;
      }
    });
  }
}

/// ✅ Secure database location using path_provider
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Use secure app documents directory
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_inventory.db'));

    if (!file.existsSync()) {
      file.createSync(recursive: true);
      print('📁 Creating new database at ${file.path}');
    } else {
      print('📁 Using existing database at ${file.path}');
    }

    final nativeDb = NativeDatabase.createInBackground(
      file,
      logStatements: kDebugMode, // ✅ Only log in debug mode
      setup: (db) {
        // ✅ Performance optimizations
        db.execute('PRAGMA journal_mode=WAL;');
        db.execute('PRAGMA synchronous=NORMAL;');
        db.execute('PRAGMA temp_store=MEMORY;');
        db.execute('PRAGMA cache_size=-32000;'); // 32MB cache
        db.execute('PRAGMA page_size=4096;');
      },
    );

    return nativeDb;
  });
}

/// Generate a cryptographically secure random salt
String _generateSalt([int length = 16]) {
  final random = Random.secure();
  final bytes = List<int>.generate(length, (_) => random.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

/// Hash password with a specific salt using PBKDF2
String _hashPasswordWithSalt(String password, String salt) {
  const int iterations = 100000; // Work factor
  const int keyLength = 32; // 32 bytes = 256-bit derived key

  final hmac = Hmac(sha256, utf8.encode(password));
  final saltBytes = utf8.encode(salt);

  // PBKDF2 block 1
  List<int> int32ToBytes(int i) {
    return <int>[
      (i >> 24) & 0xff,
      (i >> 16) & 0xff,
      (i >> 8) & 0xff,
      i & 0xff,
    ];
  }

  final blockIndexBytes = int32ToBytes(1);
  var u = hmac.convert([...saltBytes, ...blockIndexBytes]).bytes;
  final List<int> derivedBlock = List<int>.from(u);

  for (int i = 1; i < iterations; i++) {
    u = hmac.convert(u).bytes;
    for (int j = 0; j < derivedBlock.length; j++) {
      derivedBlock[j] ^= u[j];
    }
  }

  final dk = derivedBlock.sublist(0, keyLength);
  final hashHex = dk.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  return '$salt\$$hashHex'; // Format: salt$hash
}

/// ✅ Hash password using PBKDF2 with per-user random salt
/// Returns format: "salt$hash" where salt is 32-char hex, hash is 64-char hex
String hashPassword(String password) {
  final salt = _generateSalt();
  return _hashPasswordWithSalt(password, salt);
}

/// ✅ Verify password against stored hash
/// Handles format: "salt$hash"
bool verifyPassword(String password, String storedHash) {
  final parts = storedHash.split('\$');
  if (parts.length != 2) {
    print('⚠️ Invalid hash format (expected salt\$hash)');
    return false;
  }

  final salt = parts[0];
  final expectedFullHash = _hashPasswordWithSalt(password, salt);

  // Constant-time comparison to prevent timing attacks
  if (storedHash.length != expectedFullHash.length) return false;
  
  int result = 0;
  for (int i = 0; i < storedHash.length; i++) {
    result |= storedHash.codeUnitAt(i) ^ expectedFullHash.codeUnitAt(i);
  }
  return result == 0;
}

/// ✅ Safe database deletion with error handling
Future<void> deleteDatabaseFile() async {
  try {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_inventory.db'));

    if (await file.exists()) {
      await file.delete();
      print('🗑️ Database file deleted');
    } else {
      print('⚠️ Database file does not exist');
    }
  } catch (e) {
    print('❌ Error deleting database: $e');
    rethrow;
  }
}
