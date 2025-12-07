// lib/database/database_provider.dart
import 'app_database.dart';

class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._internal();
  static AppDatabase? _database;

  DatabaseProvider._internal();

  static DatabaseProvider get instance => _instance;

  // ✅ This is what you should use to get the database
  static AppDatabase get database {
    
      _database = AppDatabase();
    
    
    return _database!;
  }
}