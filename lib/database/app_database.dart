// lib/database/app_database.dart
import 'dart:io';
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

// ✅ Import MODIFIED tables (replace old imports)
import 'tables/items.dart'; // Modified version with organizationId, price, etc.
import 'tables/users.dart'; // Modified version with organizationId

// ✅ Import existing DAOs
import 'daos/categories_dao.dart';
import 'daos/roles_dao.dart';

// ✅ Import MODIFIED DAOs (you'll need to update these)
import 'daos/items_dao.dart';
import 'daos/users_dao.dart';

// ✅ Import NEW DAOs (you'll need to create these)
import 'daos/organizations_dao.dart';
import 'daos/ingredients_dao.dart';
import 'daos/recipe_ingredients_dao.dart';
import 'daos/stock_replenishment_requests_dao.dart';
import 'daos/stock_change_requests_dao.dart';

import 'package:flutter/foundation.dart';

part 'app_database.g.dart';

/// ✅ Updated database with all new tables and DAOs
@DriftDatabase(
  tables: [
    // Existing tables
    Categories,
    Roles,
    
    // NEW tables
    Organizations,
    Ingredients,
    RecipeIngredients,
    StockReplenishmentRequests,
    StockChangeRequests,
    
    // MODIFIED tables
    Items,
    Users,
  ],
  daos: [
    // Existing DAOs
    CategoriesDao,
    RolesDao,
    
    // NEW DAOs
    OrganizationsDao,
    IngredientsDao,
    RecipeIngredientsDao,
    StockReplenishmentRequestsDao,
    StockChangeRequestsDao,
    
    // MODIFIED DAOs
    ItemsDao,
    UsersDao,
  ]
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5; // ✅ Incremented from 4 to 5 for new tables

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        // Create all tables
        await m.createAll();
        
        // Create indexes
        await _createIndexes(m);
        
        // Seed initial data
        await _seedInitialData();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // ✅ Migration from version 4 to 5
        if (from < 5) {
          print('📦 Migrating database from v$from to v$to...');
          
          // Step 1: Create new tables
          await m.createTable(organizations);
          await m.createTable(ingredients);
          await m.createTable(recipeIngredients);
          await m.createTable(stockReplenishmentRequests);
          await m.createTable(stockChangeRequests);
          
          // Step 2: Add new columns to existing tables
          await m.addColumn(items, items.organizationId);
          await m.addColumn(items, items.masterItemId);
          await m.addColumn(items, items.price);
          await m.addColumn(items, items.costPrice);
          await m.addColumn(items, items.unit);
          await m.addColumn(items, items.minimumStock);
          await m.addColumn(items, items.description);
          
          await m.addColumn(users, users.organizationId);
          await m.addColumn(users, users.fullName);
          
          // Step 3: Create indexes for new tables
          await _createNewIndexes(m);
          
          // Step 4: Migrate existing data
          await _migrateExistingData();
          
          print('✅ Migration to v5 completed');
        }
        
        // Legacy migrations
        if (from < 4) {
          await _createIndexes(m);
        }
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// ✅ Create indexes for ALL tables
  Future<void> _createIndexes(Migrator m) async {
    // Items indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_items_category ON items(category_id) WHERE is_deleted = 0'
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_items_sync ON items(is_synced) WHERE is_deleted = 0'
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_items_cloud_id ON items(cloud_id)'
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_items_updated ON items(last_updated DESC)'
    );
    
    // Users indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)'
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_users_role ON users(role_id)'
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_users_cloud_id ON users(cloud_id)'
    );
    
    // Roles indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_roles_name ON roles(name)'
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_roles_cloud_id ON roles(cloud_id)'
    );
    
    // Categories indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_categories_deleted ON categories(is_deleted)'
    );
    
    print('✅ Legacy indexes created');
  }

  /// ✅ Create indexes for NEW tables
  Future<void> _createNewIndexes(Migrator m) async {
    // Organizations indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_organizations_type ON organizations(type) WHERE is_active = 1'
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_organizations_parent ON organizations(parent_commissary_id)'
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_organizations_cloud_id ON organizations(cloud_id)'
    );
    
    // Ingredients indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_ingredients_commissary ON ingredients(commissary_id) WHERE is_deleted = 0'
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_ingredients_category ON ingredients(category_id) WHERE is_deleted = 0'
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_ingredients_cloud_id ON ingredients(cloud_id)'
    );
    
    // RecipeIngredients indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_item ON recipe_ingredients(item_id) WHERE is_deleted = 0'
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_ingredient ON recipe_ingredients(ingredient_id) WHERE is_deleted = 0'
    );
    
    // StockReplenishmentRequests indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_replenishment_franchisee ON stock_replenishment_requests(franchisee_id, status) WHERE is_deleted = 0'
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_replenishment_commissary ON stock_replenishment_requests(commissary_id, status) WHERE is_deleted = 0'
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_replenishment_status ON stock_replenishment_requests(status) WHERE is_deleted = 0'
    );
    
    // StockChangeRequests indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_stock_changes_franchisee ON stock_change_requests(franchisee_id, status) WHERE is_deleted = 0'
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_stock_changes_item ON stock_change_requests(item_id, status) WHERE is_deleted = 0'
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_stock_changes_requested_by ON stock_change_requests(requested_by) WHERE is_deleted = 0'
    );
    
    // Items new column indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_items_organization ON items(organization_id) WHERE is_deleted = 0'
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_items_master ON items(master_item_id) WHERE is_deleted = 0'
    );
    
    // Users new column index
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_users_organization ON users(organization_id) WHERE is_active = 1'
    );
    
    print('✅ New table indexes created');
  }

  /// ✅ Seed initial data (organizations, roles, test users)
  Future<void> _seedInitialData() async {
    print('🌱 Seeding initial data...');
    
    try {
      // Check if already seeded
      final existingOrgs = await organizationsDao.getAllOrganizations(limit: 1);
      if (existingOrgs.isNotEmpty) {
        print('ℹ️ Database already seeded, skipping...');
        return;
      }
      
      // 1. Create default commissary organization
      final commissaryId = await organizationsDao.insertOrganization(
        OrganizationsCompanion.insert(
          name: 'Main Commissary',
          type: 'commissary',
          parentCommissaryId: Value(null),
          contactPerson: Value('Commissary Manager'),
          email: Value('commissary@example.com'),
          phone: Value('+63-123-4567'),
        ),
      );
      print('✅ Created Main Commissary (ID: $commissaryId)');
      
      // 2. Create default roles if they don't exist
      final existingRoles = await rolesDao.getAllRoles(limit: 1);
      if (existingRoles.isEmpty) {
        // Commissary Admin role
        final commissaryAdminRoleId = await rolesDao.insertRole(
          RolesCompanion.insert(
            name: 'commissary_admin',
            description: Value('Full access to commissary operations'),
            canViewInventory: Value(true),
            canAddInventory: Value(true),
            canEditInventory: Value(true),
            canDeleteInventory: Value(true),
            canViewReports: Value(true),
            canExportData: Value(true),
            canAccessSettings: Value(true),
            canManageEmployees: Value(true),
            canManageRoles: Value(true),
            isSystemRole: Value(true),
          ),
        );
        
        // Franchisee Owner role
        final franchiseeOwnerRoleId = await rolesDao.insertRole(
          RolesCompanion.insert(
            name: 'franchisee_owner',
            description: Value('Full access to franchisee operations'),
            canViewInventory: Value(true),
            canAddInventory: Value(true),
            canEditInventory: Value(true),
            canDeleteInventory: Value(false),
            canViewReports: Value(true),
            canExportData: Value(true),
            canAccessSettings: Value(true),
            canManageEmployees: Value(true),
            canManageRoles: Value(false),
            isSystemRole: Value(true),
          ),
        );
        
        // Employee role
        final employeeRoleId = await rolesDao.insertRole(
          RolesCompanion.insert(
            name: 'employee',
            description: Value('Basic employee access'),
            canViewInventory: Value(true),
            canAddInventory: Value(false),
            canEditInventory: Value(true),
            canDeleteInventory: Value(false),
            canViewReports: Value(false),
            canExportData: Value(false),
            canAccessSettings: Value(false),
            canManageEmployees: Value(false),
            canManageRoles: Value(false),
            isSystemRole: Value(true),
          ),
        );
        
        print('✅ Created default roles');
        
        // 3. Create test commissary admin user
        final roles = await rolesDao.getAllRoles();
        final commissaryAdminRole = roles.firstWhere((r) => r.name == 'commissary_admin');
        
        await usersDao.insertUser(
          UsersCompanion.insert(
            username: 'commissary_admin',
            email: 'admin@commissary.com',
            password: 'admin123', // Will be hashed in DAO
            organizationId: commissaryId,
            roleId: commissaryAdminRole.id,
            fullName: Value('Commissary Administrator'),
            isActive: Value(true),
          ),
        );
        print('✅ Created commissary admin user (username: commissary_admin, password: admin123)');
      }
      
      print('✅ Initial data seeded successfully');
    } catch (e) {
      print('❌ Error seeding initial data: $e');
      // Don't rethrow - continue even if seeding fails
    }
  }

  /// ✅ Migrate existing data from old schema to new schema
  Future<void> _migrateExistingData() async {
    print('🔄 Migrating existing data...');
    
    try {
      // Get or create default commissary
      final orgs = await organizationsDao.getAllOrganizations(limit: 1);
      int defaultCommissaryId;
      
      if (orgs.isEmpty) {
        // Create default commissary if none exists
        defaultCommissaryId = await organizationsDao.insertOrganization(
          OrganizationsCompanion.insert(
            name: 'Default Commissary',
            type: 'commissary',
            parentCommissaryId: Value(null),
          ),
        );
        print('✅ Created default commissary for migration');
      } else {
        defaultCommissaryId = orgs.first.id;
        print('✅ Using existing commissary (ID: $defaultCommissaryId)');
      }
      
      // Update all existing items to belong to default commissary
      await customUpdate(
        'UPDATE items SET organization_id = ? WHERE organization_id IS NULL',
        updates: {items},
        variables: [Variable.withInt(defaultCommissaryId)],
      );
      
      // Update all existing users to belong to default commissary
      await customUpdate(
        'UPDATE users SET organization_id = ? WHERE organization_id IS NULL',
        updates: {users},
        variables: [Variable.withInt(defaultCommissaryId)],
      );
      
      print('✅ Existing data migrated to default commissary');
    } catch (e) {
      print('❌ Error migrating existing data: $e');
      // Don't rethrow - let migration continue
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
      print('📁 Database created at ${file.path}');
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

/// ✅ Hash password using SHA-256
String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

/// ✅ Verify password hash
bool verifyPassword(String password, String hashedPassword) {
  return hashPassword(password) == hashedPassword;
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