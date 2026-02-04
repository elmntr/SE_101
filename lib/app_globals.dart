// lib/app_globals.dart
import 'package:flutter/foundation.dart';
import 'database/app_database.dart';
import 'services/supabase_sync_service_v2.dart';
import 'services/supabase_auth_service.dart';

/// Global notifier that fires when sync completes
/// Screens can listen to this to refresh their data
final syncCompleteNotifier = ValueNotifier<int>(0);

/// Notify all listeners that sync has completed
void notifySyncComplete() {
  syncCompleteNotifier.value++;
}

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
  SupabaseSyncServiceV2? _syncService;
  SupabaseSyncServiceV2 get syncService {
    if (_syncService == null) {
      throw StateError(
        'SyncService not initialized. Call AppGlobals.initialize() first.',
      );
    }
    return _syncService!;
  }

  // Auth service instance
  SupabaseAuthService? _authService;
  SupabaseAuthService get authService {
    if (_authService == null) {
      throw StateError(
        'AuthService not initialized. Call AppGlobals.initialize() first.',
      );
    }
    return _authService!;
  }

  // Check if initialized
  bool get isInitialized => _database != null && _syncService != null && _authService != null;

  // Initialize method
  void initialize({
    required AppDatabase database,
    required SupabaseSyncServiceV2 syncService,
    required SupabaseAuthService authService,
  }) {
    _database = database;
    _syncService = syncService;
    _authService = authService;
  }

  // Dispose method
  void dispose() {
    _authService?.dispose();
    _syncService?.dispose();
    _database?.close();
    _database = null;
    _syncService = null;
    _authService = null;
  }
}

// Convenience getters for easier access throughout your app
AppDatabase get database => AppGlobals.instance.database;
SupabaseSyncServiceV2 get syncService => AppGlobals.instance.syncService;
SupabaseAuthService get authService => AppGlobals.instance.authService;
