// lib/app_globals.dart
import 'database/app_database.dart';
import 'services/supabase_sync_service.dart';

class AppGlobals {
  // Private constructor
  AppGlobals._();

  // Singleton instance
  static final AppGlobals instance = AppGlobals._();

  // Database instance
  AppDatabase? _database;
  AppDatabase get database {
    if (_database == null) {
      throw StateError(
        'Database not initialized. Call AppGlobals.initialize() first.',
      );
    }
    return _database!;
  }

  // Sync service instance
  SupabaseSyncService? _syncService;
  SupabaseSyncService get syncService {
    if (_syncService == null) {
      throw StateError(
        'SyncService not initialized. Call AppGlobals.initialize() first.',
      );
    }
    return _syncService!;
  }

  // Check if initialized
  bool get isInitialized => _database != null && _syncService != null;

  // Initialize method
  void initialize({
    required AppDatabase database,
    required SupabaseSyncService syncService,
  }) {
    _database = database;
    _syncService = syncService;
  }

  // Dispose method
  void dispose() {
    _syncService?.dispose();
    _database?.close();
    _database = null;
    _syncService = null;
  }
}

// Convenience getters for easier access throughout your app
AppDatabase get database => AppGlobals.instance.database;
SupabaseSyncService get syncService => AppGlobals.instance.syncService;
