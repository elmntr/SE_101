// lib/database/database_connection.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// Responsible for opening and configuring the database connection
class DatabaseConnection {
  /// Opens a lazy database connection to the SQLite file
  static LazyDatabase open() {
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
          // Enable Write-Ahead Logging for better concurrency
          db.execute('PRAGMA journal_mode=WAL;');
          // Set synchronous mode to NORMAL for better performance
          db.execute('PRAGMA synchronous=NORMAL;');
        },
      );

      return nativeDb;
    });
  }

  /// Deletes the database file completely
  /// ⚠️ WARNING: This will DELETE ALL DATA - use with caution!
  static Future<void> deleteDatabase() async {
    final dbFile = File('app_inventory.db');
    if (await dbFile.exists()) {
      await dbFile.delete();
      print('Database file deleted.');
    } else {
      print('Database file does not exist.');
    }
  }
}