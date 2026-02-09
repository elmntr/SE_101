// test/integration/realtime_sync_integration_test.dart
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/native.dart';
import 'package:chickenjoo_inventory/services/realtime_stock_request_service.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';

import 'realtime_sync_integration_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SupabaseClient>(),
])
void main() {
  late AppDatabase db;
  late MockSupabaseClient mockSupabase;
  late RealtimeStockRequestService service;
  late TestableRealtimeChannel testChannel;

  setUp(() async {
    // Create in-memory database for testing
    db = AppDatabase.test(NativeDatabase.memory());
    mockSupabase = MockSupabaseClient();
    testChannel = TestableRealtimeChannel();
    
    when(mockSupabase.channel(any)).thenReturn(testChannel);
    when(mockSupabase.removeChannel(any)).thenAnswer((_) async => 'ok');
    
    service = RealtimeStockRequestService(
      supabase: mockSupabase,
      db: db,
    );
  });

  tearDown(() async {
    service.dispose();
    await db.close();
  });

  group('Realtime Sync Integration Tests', () {
    test('should emit event when approval received via realtime', () async {
      // Arrange
      final receivedEvents = <StockRequestEvent>[];
      final subscription = service.eventStream.listen((event) {
        receivedEvents.add(event);
      });
      
      await service.attach('test-franchisee-id');
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Act - Simulate a realtime approval event
      testChannel.simulateUpdateEvent(
        oldRecord: {
          'cloud_id': 'request-123',
          'franchisee_id': 'test-franchisee-id',
          'item_id': 'item-456',
          'quantity_requested': 50,
          'status': 'pending',
          'last_updated': DateTime.now().toIso8601String(),
        },
        newRecord: {
          'cloud_id': 'request-123',
          'franchisee_id': 'test-franchisee-id',
          'item_id': 'item-456',
          'quantity_requested': 50,
          'status': 'approved',
          'last_updated': DateTime.now().toIso8601String(),
        },
      );
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Assert
      expect(receivedEvents.length, greaterThanOrEqualTo(1));
      final approvalEvent = receivedEvents.firstWhere(
        (e) => e.newStatus == 'approved',
        orElse: () => throw Exception('No approval event found'),
      );
      expect(approvalEvent.cloudId, equals('request-123'));
      expect(approvalEvent.isApproved, isTrue);
      
      await subscription.cancel();
    });

    test('should trigger sync callback after debounce period', () async {
      // Arrange
      int syncCallCount = 0;
      service.syncCallback = () async {
        syncCallCount++;
      };
      
      await service.attach('test-franchisee-id');
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Act - Simulate multiple rapid events
      for (int i = 0; i < 5; i++) {
        testChannel.simulateUpdateEvent(
          oldRecord: {
            'cloud_id': 'request-$i',
            'franchisee_id': 'test-franchisee-id',
            'status': 'pending',
            'last_updated': DateTime.now().toIso8601String(),
          },
          newRecord: {
            'cloud_id': 'request-$i',
            'franchisee_id': 'test-franchisee-id',
            'status': 'approved',
            'last_updated': DateTime.now().toIso8601String(),
          },
        );
      }
      
      // Wait for debounce (500ms) plus some buffer
      await Future.delayed(const Duration(milliseconds: 700));
      
      // Assert - Should only sync once due to debouncing
      expect(syncCallCount, equals(1));
    });

    test('should not trigger sync for same status updates', () async {
      // Arrange
      int syncCallCount = 0;
      service.syncCallback = () async {
        syncCallCount++;
      };
      
      await service.attach('test-franchisee-id');
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Act - Simulate update with same status
      testChannel.simulateUpdateEvent(
        oldRecord: {
          'cloud_id': 'request-123',
          'franchisee_id': 'test-franchisee-id',
          'status': 'approved',
          'last_updated': DateTime.now().toIso8601String(),
        },
        newRecord: {
          'cloud_id': 'request-123',
          'franchisee_id': 'test-franchisee-id',
          'status': 'approved', // Same status
          'last_updated': DateTime.now().toIso8601String(),
        },
      );
      
      await Future.delayed(const Duration(milliseconds: 700));
      
      // Assert - Should not sync for same status
      expect(syncCallCount, equals(0));
    });

    test('should handle connection lifecycle correctly', () async {
      // Arrange
      final statuses = <RealtimeConnectionStatus>[];
      final subscription = service.statusStream.listen((status) {
        statuses.add(status);
      });
      
      // Act
      await service.attach('test-franchisee-id');
      await Future.delayed(const Duration(milliseconds: 100));
      
      await service.pause();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await service.resume();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await service.detach();
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Assert
      expect(statuses, contains(RealtimeConnectionStatus.connecting));
      expect(statuses, contains(RealtimeConnectionStatus.connected));
      expect(statuses, contains(RealtimeConnectionStatus.disconnected));
      
      await subscription.cancel();
    });

    test('should handle rejection events', () async {
      // Arrange
      final receivedEvents = <StockRequestEvent>[];
      final subscription = service.eventStream.listen((event) {
        receivedEvents.add(event);
      });
      
      await service.attach('test-franchisee-id');
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Act - Simulate rejection
      testChannel.simulateUpdateEvent(
        oldRecord: {
          'cloud_id': 'request-456',
          'franchisee_id': 'test-franchisee-id',
          'status': 'pending',
          'last_updated': DateTime.now().toIso8601String(),
        },
        newRecord: {
          'cloud_id': 'request-456',
          'franchisee_id': 'test-franchisee-id',
          'status': 'rejected',
          'last_updated': DateTime.now().toIso8601String(),
        },
      );
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Assert
      expect(receivedEvents.any((e) => e.isRejected), isTrue);
      
      await subscription.cancel();
    });

    test('should maintain reference count across multiple screens', () async {
      // Act
      await service.attach('test-franchisee-id');
      expect(service.activeScreenCount, equals(1));
      expect(service.status, equals(RealtimeConnectionStatus.connected));
      
      await service.attach('test-franchisee-id');
      expect(service.activeScreenCount, equals(2));
      
      await service.detach();
      expect(service.activeScreenCount, equals(1));
      // Should still be connected since one screen is still attached
      expect(service.status, equals(RealtimeConnectionStatus.connected));
      
      await service.detach();
      expect(service.activeScreenCount, equals(0));
      expect(service.status, equals(RealtimeConnectionStatus.disconnected));
    });
  });
}

/// Testable RealtimeChannel that allows simulating events
class TestableRealtimeChannel extends Fake implements RealtimeChannel {
  void Function(PostgresChangePayload)? _updateCallback;
  
  @override
  RealtimeChannel onPostgresChanges({
    required PostgresChangeEvent event,
    String? schema,
    String? table,
    PostgresChangeFilter? filter,
    required void Function(PostgresChangePayload payload) callback,
  }) {
    if (event == PostgresChangeEvent.update) {
      _updateCallback = callback;
    }
    return this;
  }

  @override
  RealtimeChannel subscribe([
    void Function(RealtimeSubscribeStatus status, Object? error)? callback,
    Duration? timeout,
  ]) {
    Future.microtask(() {
      callback?.call(RealtimeSubscribeStatus.subscribed, null);
    });
    return this;
  }
  
  /// Simulate a Postgres UPDATE event
  void simulateUpdateEvent({
    required Map<String, dynamic> oldRecord,
    required Map<String, dynamic> newRecord,
  }) {
    if (_updateCallback != null) {
      final payload = _TestPostgresChangePayload(
        oldRecord: oldRecord,
        newRecord: newRecord,
      );
      _updateCallback!(payload);
    }
  }
}

/// Test implementation of PostgresChangePayload
class _TestPostgresChangePayload implements PostgresChangePayload {
  @override
  final Map<String, dynamic> oldRecord;
  
  @override
  final Map<String, dynamic> newRecord;
  
  _TestPostgresChangePayload({
    required this.oldRecord,
    required this.newRecord,
  });

  @override
  List<String> get columns => newRecord.keys.toList();

  @override
  DateTime get commitTimestamp => DateTime.now();

  @override
  List<dynamic> get errors => [];

  @override
  PostgresChangeEvent get eventType => PostgresChangeEvent.update;

  @override
  String get schema => 'public';

  @override
  String get table => 'stock_replenishment_requests';
}
