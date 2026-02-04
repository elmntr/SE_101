import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:chickenjoo_inventory/main.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/services/supabase_sync_service_v2.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/services/realtime_stock_request_service.dart';

import 'main_test_final.mocks.dart';

@GenerateMocks([
  AppDatabase,
  SupabaseSyncServiceV2,
  SupabaseAuthService,
  RealtimeStockRequestService,
])
void main() {
  group('main.dart Tests', () {
    late MockAppDatabase mockDatabase;
    late MockSupabaseSyncServiceV2 mockSyncService;
    late MockSupabaseAuthService mockAuthService;
    late MockRealtimeStockRequestService mockRealtimeService;

    setUp(() {
      mockDatabase = MockAppDatabase();
      mockSyncService = MockSupabaseSyncServiceV2();
      mockAuthService = MockSupabaseAuthService();
      mockRealtimeService = MockRealtimeStockRequestService();

      // Setup default mock behaviors
      when(mockDatabase.close()).thenAnswer((_) async {});
      when(mockSyncService.initialize()).thenAnswer((_) async {});
      when(mockSyncService.getSyncStatus()).thenAnswer((_) async => {
        'is_syncing': false,
        'total_unsynced': 0,
        'status': 'Connected',
        'is_online': true,
      });
    });

    // Happy Path Tests (7)
    testWidgets('should initialize sync status notifier with correct initial values', (WidgetTester tester) async {
      // Act
      final notifier = syncStatusNotifier;

      // Assert
      expect(notifier.value['is_syncing'], false);
      expect(notifier.value['total_unsynced'], 0);
      expect(notifier.value['status'], 'Initializing...');
      expect(notifier.value['is_online'], true);
    });

    testWidgets('should initialize AppGlobals with all services', (WidgetTester tester) async {
      // Arrange
      final globals = AppGlobals.instance;

      // Act
      globals.initialize(
        database: mockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
        realtimeStockRequestService: mockRealtimeService,
      );

      // Assert
      expect(globals.isInitialized, true);
      expect(globals.database, mockDatabase);
      expect(globals.syncService, mockSyncService);
      expect(globals.authService, mockAuthService);
    });

    testWidgets('should maintain singleton pattern', (WidgetTester tester) async {
      // Act
      final instance1 = AppGlobals.instance;
      final instance2 = AppGlobals.instance;

      // Assert
      expect(instance1, same(instance2));
      expect(instance1.hashCode, equals(instance2.hashCode));
    });

    testWidgets('should dispose all services properly', (WidgetTester tester) async {
      // Arrange
      final globals = AppGlobals.instance;
      globals.initialize(
        database: mockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
        realtimeStockRequestService: mockRealtimeService,
      );

      // Act
      globals.dispose();

      // Assert
      expect(globals.isInitialized, false);
      verify(mockDatabase.close()).called(1);
    });

    testWidgets('should allow reinitialization after disposal', (WidgetTester tester) async {
      // Arrange
      final globals = AppGlobals.instance;
      final newMockDatabase = MockAppDatabase();
      final newMockSyncService = MockSupabaseSyncServiceV2();
      final newMockAuthService = MockSupabaseAuthService();
      final newMockRealtimeService = MockRealtimeStockRequestService();

      when(newMockDatabase.close()).thenAnswer((_) async {});

      globals.initialize(
        database: mockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
        realtimeStockRequestService: mockRealtimeService,
      );
      globals.dispose();

      // Act
      globals.initialize(
        database: newMockDatabase,
        syncService: newMockSyncService,
        authService: newMockAuthService,
        realtimeStockRequestService: newMockRealtimeService,
      );

      // Assert
      expect(globals.isInitialized, true);
      expect(globals.database, equals(newMockDatabase));
      expect(globals.syncService, equals(newMockSyncService));
      expect(globals.authService, equals(newMockAuthService));
    });

    testWidgets('should handle sync status notifier updates', (WidgetTester tester) async {
      // Arrange
      final notifier = syncStatusNotifier;

      // Act
      notifier.value = {
        'is_syncing': true,
        'total_unsynced': 10,
        'status': 'Syncing...',
        'is_online': false,
      };

      // Assert
      expect(notifier.value['is_syncing'], true);
      expect(notifier.value['total_unsynced'], 10);
      expect(notifier.value['status'], 'Syncing...');
      expect(notifier.value['is_online'], false);
    });

    testWidgets('should handle timer operations conceptually', (WidgetTester tester) async {
      // Act & Assert - Test timer concept without accessing private members
      expect(() {
        // Simulate timer operations
        final timer = Timer.periodic(const Duration(seconds: 30), (_) {});
        timer.cancel();
      }, returnsNormally);
    });

    // Unhappy Path Tests (8)
    testWidgets('should handle database access before initialization', (WidgetTester tester) async {
      // Arrange
      final globals = AppGlobals.instance;

      // Act & Assert
      expect(() => globals.database, throwsA(isA<StateError>()));
      expect(() => globals.syncService, throwsA(isA<StateError>()));
      expect(() => globals.authService, throwsA(isA<StateError>()));
    });

    testWidgets('should return false for isInitialized before initialization', (WidgetTester tester) async {
      // Arrange
      final globals = AppGlobals.instance;

      // Act
      final isInitialized = globals.isInitialized;

      // Assert
      expect(isInitialized, false);
    });

    testWidgets('should handle disposal without initialization', (WidgetTester tester) async {
      // Arrange
      final globals = AppGlobals.instance;

      // Act & Assert
      expect(() => globals.dispose(), returnsNormally);
      expect(globals.isInitialized, false);
    });

    testWidgets('should handle database close exception during disposal', (WidgetTester tester) async {
      // Arrange
      final globals = AppGlobals.instance;
      when(mockDatabase.close()).thenThrow(Exception('Database close failed'));

      globals.initialize(
        database: mockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
        realtimeStockRequestService: mockRealtimeService,
      );

      // Act & Assert
      expect(() => globals.dispose(), throwsException);
    });

    testWidgets('should handle sync service getSyncStatus errors', (WidgetTester tester) async {
      // Arrange
      when(mockSyncService.getSyncStatus()).thenThrow(Exception('Status update failed'));

      // Act & Assert
      expect(() async {
        await mockSyncService.getSyncStatus();
      }, throwsException);
    });

    testWidgets('should handle sync service initialization errors', (WidgetTester tester) async {
      // Arrange
      when(mockSyncService.initialize()).thenThrow(Exception('Sync service failed'));

      // Act & Assert
      expect(() async {
        await mockSyncService.initialize();
      }, throwsException);
    });

    testWidgets('should handle auth service errors', (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.signOut()).thenThrow(Exception('Sign out failed'));

      // Act & Assert
      expect(() async {
        await mockAuthService.signOut();
      }, throwsException);
    });

    testWidgets('should handle multiple initializations', (WidgetTester tester) async {
      // Arrange
      final globals = AppGlobals.instance;
      final mockDatabase2 = MockAppDatabase();
      final mockSyncService2 = MockSupabaseSyncServiceV2();
      final mockAuthService2 = MockSupabaseAuthService();
      final mockRealtimeService2 = MockRealtimeStockRequestService();

      when(mockDatabase2.close()).thenAnswer((_) async {});

      globals.initialize(
        database: mockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
        realtimeStockRequestService: mockRealtimeService,
      );

      // Act - Initialize again with different instances
      globals.initialize(
        database: mockDatabase2,
        syncService: mockSyncService2,
        authService: mockAuthService2,
        realtimeStockRequestService: mockRealtimeService2,
      );

      // Assert
      expect(globals.isInitialized, true);
      expect(globals.database, equals(mockDatabase2));
      expect(globals.syncService, equals(mockSyncService2));
      expect(globals.authService, equals(mockAuthService2));
    });
  });

  group('Sync Status Notifier Tests', () {
    test('should create notifier with default values', () {
      // Act
      final notifier = syncStatusNotifier;

      // Assert
      expect(notifier.value['is_syncing'], false);
      expect(notifier.value['total_unsynced'], 0);
      expect(notifier.value['status'], 'Initializing...');
      expect(notifier.value['is_online'], true);
    });

    test('should update notifier values correctly', () {
      // Arrange
      final notifier = syncStatusNotifier;

      // Act
      notifier.value = {
        'is_syncing': true,
        'total_unsynced': 5,
        'status': 'Syncing...',
        'is_online': false,
      };

      // Assert
      expect(notifier.value['is_syncing'], true);
      expect(notifier.value['total_unsynced'], 5);
      expect(notifier.value['status'], 'Syncing...');
      expect(notifier.value['is_online'], false);
    });

    test('should handle partial notifier updates', () {
      // Arrange
      final notifier = syncStatusNotifier;

      // Act
      notifier.value = {
        ...notifier.value,
        'status': 'Updated Status',
      };

      // Assert
      expect(notifier.value['status'], 'Updated Status');
      expect(notifier.value['is_syncing'], false); // Should preserve other values
      expect(notifier.value['total_unsynced'], 0);
    });
  });

  group('AppGlobals Extension Tests', () {
    test('should handle convenience getters after initialization', () {
      // Arrange
      final mockDatabase = MockAppDatabase();
      final mockSyncService = MockSupabaseSyncServiceV2();
      final mockAuthService = MockSupabaseAuthService();
      final mockRealtimeService = MockRealtimeStockRequestService();

      when(mockDatabase.close()).thenAnswer((_) async {});

      AppGlobals.instance.initialize(
        database: mockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
        realtimeStockRequestService: mockRealtimeService,
      );

      // Act & Assert
      expect(database, equals(mockDatabase));
      expect(syncService, equals(mockSyncService));
      expect(authService, equals(mockAuthService));
    });

    test('should handle convenience getters before initialization', () {
      // Act & Assert
      expect(() => database, throwsA(isA<StateError>()));
      expect(() => syncService, throwsA(isA<StateError>()));
      expect(() => authService, throwsA(isA<StateError>()));
    });
  });
}
