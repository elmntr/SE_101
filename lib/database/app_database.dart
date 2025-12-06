// lib/database/app_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

// Table imports
import 'tables/items.dart';
import 'tables/users.dart';
import 'tables/roles.dart';
import 'tables/categories.dart'; // ✅ ADD THIS

// DAO imports
import 'daos/items_dao.dart';
import 'daos/users_dao.dart';
import 'daos/roles_dao.dart';
import 'daos/categories_dao.dart'; // ✅ ADD THIS

// Model imports
import 'models/user_with_role.dart';
import 'models/item_with_category.dart'; // ✅ ADD THIS

// Seeder imports
import 'seeders/database_seeder.dart';

// Connection import
import 'database_connection.dart' as localDB;

part 'app_database.g.dart';

/// Main database class - handles database connection and schema versioning
@DriftDatabase(
  tables: [Items, Users, Roles, Categories], // ✅ Add Categories
  daos: [ItemsDao, UsersDao, RolesDao, CategoriesDao] // ✅ Add CategoriesDao
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// IMPORTANT: Change this to 2 since you're adding a new table and column
  @override
  int get schemaVersion => 2; // ✅ CHANGED FROM 1 TO 2

  /// Migration strategy
  

  Future<void> seedDatabase() async {
    await DatabaseSeeder.seed(this);
  }
}

LazyDatabase _openConnection() => localDB.DatabaseConnection.open();
Future<void> deleteDatabaseFile() => localDB.DatabaseConnection.deleteDatabase();