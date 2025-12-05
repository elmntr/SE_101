// lib/database/local/database_provider.dart
import 'package:chickenjoo_inventory/database/app_database.dart';


class DatabaseProvider {
  // Private constructor
  DatabaseProvider._();

  // Single instance of AppDatabase
  static final AppDatabase instance = AppDatabase();
}
