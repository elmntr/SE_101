// lib/database/database_connection.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Responsible for opening and configuring the database connection
class DatabaseConnection {

  static LazyDatabase open(){
    return LazyDatabase(() async {
    // Get the app's documents directory (writable on all platforms)
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_inventory.db'));
    return NativeDatabase(file);
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
  static Future<void> deleteOldDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'app_inventory.db'));
  if (await file.exists()) {
    await file.delete();
    print('✅ Old database deleted at: ${file.path}');
  }
}
  
}

// For PC Deubugging, Not Allowed in Android, DONT DELETE
/// Opens a lazy database connection to the SQLite file
  // static LazyDatabase open() {
  //   return LazyDatabase(() async {
  //     final dbFile = File('app_inventory.db');

  //     if (!dbFile.existsSync()) {
  //       dbFile.createSync();
  //       print('DEBUG: Database file created at ${dbFile.path}');
  //     } else {
  //       print('DEBUG: Using existing database at ${dbFile.path}');
  //     }

  //     final nativeDb = NativeDatabase.createInBackground(
  //       dbFile,
  //       logStatements: true,
  //       setup: (db) {
  //         // Enable Write-Ahead Logging for better concurrency
  //         db.execute('PRAGMA journal_mode=WAL;');
  //         // Set synchronous mode to NORMAL for better performance
  //         db.execute('PRAGMA synchronous=NORMAL;');
  //       },
  //     );

  //     return nativeDb;
  //   });
  // }