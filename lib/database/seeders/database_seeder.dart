// lib/database/seeders/database_seeder.dart
import '../app_database.dart';
import 'admin_seeder.dart';
import 'employee_seeder.dart';
import 'items_seeder.dart';

/// Responsible for seeding all initial database data
class DatabaseSeeder {
  /// Coordinates all seeding operations
  static Future<void> seed(AppDatabase db) async {
    await AdminSeeder.seed(db);
    await EmployeeSeeder.seed(db);
    await ItemsSeeder.seed(db);
  }
}