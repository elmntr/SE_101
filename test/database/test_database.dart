// test/database/test_database.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';

/// Creates a temporary in-memory database for testing purposes.
///
/// This allows tests to run in isolation without affecting the real database.
AppDatabase createTestDatabase() {
  // The in-memory database is automatically created and destroyed with each test.
  final db = AppDatabase.test(NativeDatabase.memory());

  // It's crucial to close the database when the test is done to release resources.
  addTearDown(db.close);

  return db;
}
