// lib/database/app_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'tables/items.dart';
import 'tables/users.dart';
import 'tables/roles.dart';
import 'tables/categories.dart';

import 'daos/items_dao.dart';
import 'daos/users_dao.dart';
import 'daos/roles_dao.dart';
import 'daos/categories_dao.dart';
import 'package:flutter/foundation.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Items, Users, Roles, Categories], 
  daos: [ItemsDao, UsersDao, RolesDao, CategoriesDao]
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4; // ✅ Incremented for new indexes

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createIndexes(m);
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 4) {
          // Migration for version 2: Add indexes
          await _createIndexes(m);
        }
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
        
      },
    );
  }

  /// ✅ Create database indexes for performance
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
    
    print('✅ Database indexes created');
  }

  /// ✅ Seed database - now runs in parallel
  

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