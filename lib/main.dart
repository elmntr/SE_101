// lib/main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

import 'package:chickenjoo_inventory/database/app_database.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_sync_service_v2.dart';
import 'services/supabase_auth_service.dart';
import 'services/realtime_stock_request_service.dart';
import 'app_globals.dart';
import 'app.dart';
import 'package:path_provider/path_provider.dart';
import 'utils/app_logger.dart';

import 'package:path/path.dart' as p;

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
  // Desktop window size setup
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Chicken Joo Inventory');
    setWindowMinSize(const Size(1280, 720));
    setWindowMaxSize(const Size(1920, 1080));
  }

  // -------------------------------------------------------------
  // CLEAN DATABASE FOR FRESH START (one-time)
  // Comment out after first run if you want to keep local data
  // -------------------------------------------------------------
  //await deleteOldDatabase();

  // -------------------------------------------------------------
  // DATABASE INITIALIZATION
  // -------------------------------------------------------------
  AppLogger.database('Initializing database...');
  final db = AppDatabase();

  // -------------------------------------------------------------
  // SUPABASE INITIALIZATION
  // -------------------------------------------------------------
  AppLogger.info('☁️ Initializing Supabase...');
  SupabaseConfig.printConfigStatus(); // Debug: Show config status

  try {
    AppLogger.websocket('🔌 SUPABASE INIT  starting...');
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    AppLogger.info('✅ Supabase initialized');
    AppLogger.websocket('🔌 SUPABASE INIT  complete');
  } catch (e) {
    AppLogger.warning('Supabase initialization failed: $e');
    AppLogger.info('📱 App will work in offline-only mode');
  }

  // -------------------------------------------------------------
  // SYNC SERVICE INITIALIZATION
  // -------------------------------------------------------------
  AppLogger.sync('Initializing sync service v2...');

  final sync = SupabaseSyncServiceV2(
    db: db,
    supabase: Supabase.instance.client,
    onConnectivityChanged: (isOnline) {
      AppLogger.connectivity(isOnline ? 'Online ✅' : 'Offline 📵');
      final current = syncStatusNotifier.value;
      final newStatus = isOnline ? 'Online' : 'Offline';
      if (current['is_online'] != isOnline || current['status'] != newStatus) {
        syncStatusNotifier.value = {
          ...current,
          'is_online': isOnline,
          'status': newStatus,
        };
      }
    },
    onSyncStatusChanged: (status) {
      AppLogger.sync('Sync status: $status');
      final current = syncStatusNotifier.value;
      if (current['status'] != status) {
        syncStatusNotifier.value = {...current, 'status': status};
      }
    },
    onSyncError: (error) {
      AppLogger.error('Sync error: $error');
      final truncated =
          'Error: ${error.length > 30 ? error.substring(0, 30) : error}...';
      final current = syncStatusNotifier.value;
      if (current['status'] != truncated) {
        syncStatusNotifier.value = {...current, 'status': truncated};
      }
    },
  );

  // -------------------------------------------------------------
  // APP GLOBALS INITIALIZATION
  // -------------------------------------------------------------
  final authService = SupabaseAuthService(
    supabase: Supabase.instance.client,
    database: db,
  );

  // Initialize realtime stock request service
  AppLogger.websocket('🔌 REALTIME SERVICE  creating instance');
  final realtimeStockRequestService = RealtimeStockRequestService(
    supabase: Supabase.instance.client,
    db: db,
  );

  // Wire up sync callback for realtime service - use FORCE FULL sync
  realtimeStockRequestService.syncCallback = () async {
    await sync.forceFullSyncReplenishmentRequests();
    await sync.syncBranchItemStock();
    notifySyncComplete();
  };
  
  AppGlobals.instance.initialize(
    database: db,
    syncService: sync,
    authService: authService,
    realtimeStockRequestService: realtimeStockRequestService,
  );
  AppLogger.info('✅ AppGlobals initialized');

  // -------------------------------------------------------------
  // AUTH STATE LISTENER - Clear sync context on logout
  // -------------------------------------------------------------
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    final user = data.session?.user;
    
    if (event == AuthChangeEvent.signedOut || user == null) {
      AppLogger.auth('🔒 Auth loss detected in main.dart - clearing sync context');
      sync.clearOrganizationContext();
    }
  });

  // Non-blocking sync service start
  sync
      .initialize()
      .then((_) {
        AppLogger.info('✅ Sync service initialized');
        AppLogger.websocket('🔌 SYNC SERVICE  initialized (from main.dart non-blocking)');
      })
      .catchError((e) {
        AppLogger.warning('Sync service initialization failed: $e');
        AppLogger.info('📱 App will continue in offline mode');
      });

  // -------------------------------------------------------------
  // RUN APPLICATION
  // -------------------------------------------------------------
  runApp(const MyApp());
}


Future<void> deleteOldDatabase() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'app_inventory.db'));
  if (await file.exists()) {
    await file.delete();
    AppLogger.database('Old database deleted');
  }
}
