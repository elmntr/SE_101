// lib/main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

import 'package:chickenjoo_inventory/database/seeders/admin_seeder.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/database/database_connection.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_sync_service.dart';
import 'app_globals.dart'; // ✅ Import AppGlobals
import 'app.dart';

// Sync status notifier for UI updates
final syncStatusNotifier = ValueNotifier<Map<String, dynamic>>({
  'is_syncing': false,
  'total_unsynced': 0,
  'status': 'Initializing...',
  'is_online': true,
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Chicken Joo Inventory');
    setWindowMinSize(const Size(1280, 720));
    setWindowMaxSize(const Size(1920, 1080));
  }
  
  //await DatabaseConnection.deleteOldDatabase();
  //await DatabaseConnection.deleteDatabase();
  
  // ✅ Create database instance ONCE
  print('🗄️ Initializing database...');
  final db = AppDatabase();
  
  // Seed admin account - pass the same instance
  await AdminSeeder.seed(db); // admin@commissary.com ; admin123
  
  // ✅ Optional: Seed test data (comment out if you don't have this method)
  // await db.seedDatabase();
  
  // Initialize Supabase
  print('☁️ Initializing Supabase...');
  bool supabaseInitialized = false;
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    print('✅ Supabase initialized');
    supabaseInitialized = true;
  } catch (e) {
    print('⚠️ Supabase initialization failed: $e');
    print('📱 App will work in offline-only mode');
  }
  
  // ✅ Initialize sync service as local variable first
  print('🔄 Initializing sync service...');
  final sync = SupabaseSyncService(
    db: db,
    supabase: Supabase.instance.client,
    onConnectivityChanged: (isOnline) {
      print('📡 Connectivity: ${isOnline ? "Online ✅" : "Offline 📵"}');
      syncStatusNotifier.value = {
        ...syncStatusNotifier.value,
        'is_online': isOnline,
        'status': isOnline ? 'Online' : 'Offline',
      };
    },
    onSyncStatusChanged: (status) {
      print('🔄 Sync status: $status');
      syncStatusNotifier.value = {
        ...syncStatusNotifier.value,
        'status': status,
      };
    },
    onSyncError: (error) {
      print('❌ Sync error: $error');
      syncStatusNotifier.value = {
        ...syncStatusNotifier.value,
        'status': 'Error: ${error.length > 30 ? error.substring(0, 30) : error}...',
      };
    },
  );
  
  // ✅ Initialize AppGlobals with instances
  AppGlobals.instance.initialize(
    database: db,
    syncService: sync,
  );
  print('✅ AppGlobals initialized');
  
  // Initialize sync (non-blocking)
  sync.initialize().then((_) {
    print('✅ Sync service initialized');
    _updateSyncStatus();
  }).catchError((e) {
    print('⚠️ Sync service initialization failed: $e');
    print('📱 App will continue in offline mode');
  });
  
  // Periodic sync status updates for UI
  _startSyncStatusUpdates();

  runApp(const MyApp());
}

/// Update sync status periodically
void _startSyncStatusUpdates() {
  Future.delayed(const Duration(seconds: 30), () async {
    await _updateSyncStatus();
    _startSyncStatusUpdates(); // Recursive call for continuous updates
  });
}

/// Update the sync status notifier
Future<void> _updateSyncStatus() async {
  try {
    // ✅ Check if initialized before accessing
    if (AppGlobals.instance.isInitialized) {
      final status = await syncService.getSyncStatus();
      syncStatusNotifier.value = {
        ...syncStatusNotifier.value,
        ...status,
      };
    }
  } catch (e) {
    print('Error updating sync status: $e');
  }
}