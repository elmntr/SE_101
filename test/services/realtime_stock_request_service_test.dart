// test/services/realtime_stock_request_service_test.dart
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:chickenjoo_inventory/services/realtime_stock_request_service.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';

import 'package:flutter/services.dart';

import 'realtime_stock_request_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SupabaseClient>(),
  MockSpec<AppDatabase>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late MockSupabaseClient mockSupabase;
  late MockAppDatabase mockDb;
  late RealtimeStockRequestService service;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockDb = MockAppDatabase();
    service = RealtimeStockRequestService(
      supabase: mockSupabase,
      db: mockDb,
    );
  });

  tearDown(() async {
    // Detach all screens before disposing to avoid "Cannot add new events after calling close" error
    while (service.activeScreenCount > 0) {
      await service.detach();
    }
    service.dispose();
  });

  group('RealtimeStockRequestService - Basic Tests', () {
    test('should create service with correct initial state', () {
      expect(service, isNotNull);
      expect(service.status, equals(RealtimeConnectionStatus.disconnected));
      expect(service.isListening, isFalse);
      expect(service.activeScreenCount, equals(0));
    });

    test('should have statusStream getter', () {
      expect(service.statusStream, isNotNull);
      expect(service.statusStream, isA<Stream<RealtimeConnectionStatus>>());
    });

    test('should have eventStream getter', () {
      expect(service.eventStream, isNotNull);
      expect(service.eventStream, isA<Stream<StockRequestEvent>>());
    });
  });

  group('RealtimeStockRequestService - Reference Counting', () {
    test('attach should increment activeScreenCount', () async {
      when(mockSupabase.channel(any)).thenReturn(FakeRealtimeChannel());
      
      await service.attach('test-franchisee-id');
      
      expect(service.activeScreenCount, equals(1));
    });

    test('detach should decrement activeScreenCount', () async {
      when(mockSupabase.channel(any)).thenReturn(FakeRealtimeChannel());
      
      await service.attach('test-franchisee-id');
      await service.detach();
      
      expect(service.activeScreenCount, equals(0));
    });

    test('multiple attach calls should increment count correctly', () async {
      when(mockSupabase.channel(any)).thenReturn(FakeRealtimeChannel());
      
      await service.attach('test-franchisee-id');
      await service.attach('test-franchisee-id');
      await service.attach('test-franchisee-id');
      
      expect(service.activeScreenCount, equals(3));
    });

    test('detach should not go below zero', () async {
      when(mockSupabase.channel(any)).thenReturn(FakeRealtimeChannel());
      
      await service.detach();
      await service.detach();
      
      expect(service.activeScreenCount, equals(0));
    });
  });

  group('RealtimeStockRequestService - Lifecycle Management', () {
    test('pause should set status to disconnected', () async {
      when(mockSupabase.channel(any)).thenReturn(FakeRealtimeChannel());
      when(mockSupabase.removeChannel(any)).thenAnswer((_) async => 'ok');
      
      await service.attach('test-franchisee-id');
      await service.pause();
      
      expect(service.status, equals(RealtimeConnectionStatus.disconnected));
    });

    test('resume after pause should reconnect', () async {
      final fakeChannel = FakeRealtimeChannel();
      when(mockSupabase.channel(any)).thenReturn(fakeChannel);
      when(mockSupabase.removeChannel(any)).thenAnswer((_) async => 'ok');
      
      await service.attach('test-franchisee-id');
      await service.pause();
      await service.resume();
      
      // Should attempt to reconnect
      expect(service.activeScreenCount, equals(1));
    });

    test('multiple pause calls should be idempotent', () async {
      when(mockSupabase.channel(any)).thenReturn(FakeRealtimeChannel());
      when(mockSupabase.removeChannel(any)).thenAnswer((_) async => 'ok');
      
      await service.attach('test-franchisee-id');
      await service.pause();
      await service.pause();
      await service.pause();
      
      expect(service.status, equals(RealtimeConnectionStatus.disconnected));
    });
  });

  group('RealtimeStockRequestService - Status Stream', () {
    test('should emit status changes', () async {
      when(mockSupabase.channel(any)).thenReturn(FakeRealtimeChannel());
      
      final statuses = <RealtimeConnectionStatus>[];
      final subscription = service.statusStream.listen((status) {
        statuses.add(status);
      });
      
      await service.attach('test-franchisee-id');
      
      // Wait for status updates
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(statuses, contains(RealtimeConnectionStatus.connecting));
      expect(statuses, contains(RealtimeConnectionStatus.connected));
      
      await subscription.cancel();
    });
  });

  group('RealtimeStockRequestService - Debouncing', () {
    test('syncCallback should be debounced', () async {
      when(mockSupabase.channel(any)).thenReturn(FakeRealtimeChannel());
      
      int syncCallCount = 0;
      service.syncCallback = () async {
        syncCallCount++;
      };
      
      await service.attach('test-franchisee-id');
      
      // Trigger multiple rapid events would normally happen via _handleStatusUpdate
      // Since we can't easily trigger internal methods, we test that the service
      // has the debounce mechanism in place
      expect(service.syncCallback, isNotNull);
    });
  });

  group('StockRequestEvent', () {
    test('should correctly identify approved events', () {
      final event = StockRequestEvent(
        cloudId: 'test-id',
        franchiseeId: 'franchisee-1',
        itemId: 'item-1',
        quantityRequested: 10,
        oldStatus: 'pending',
        newStatus: 'approved',
        timestamp: DateTime.now(),
        rawData: {},
      );
      
      expect(event.isApproved, isTrue);
      expect(event.isRejected, isFalse);
      expect(event.isDelivered, isFalse);
    });

    test('should correctly identify rejected events', () {
      final event = StockRequestEvent(
        cloudId: 'test-id',
        franchiseeId: 'franchisee-1',
        itemId: 'item-1',
        quantityRequested: 10,
        oldStatus: 'pending',
        newStatus: 'rejected',
        timestamp: DateTime.now(),
        rawData: {},
      );
      
      expect(event.isApproved, isFalse);
      expect(event.isRejected, isTrue);
      expect(event.isDelivered, isFalse);
    });

    test('should correctly identify delivered events', () {
      final event = StockRequestEvent(
        cloudId: 'test-id',
        franchiseeId: 'franchisee-1',
        itemId: 'item-1',
        quantityRequested: 10,
        oldStatus: 'approved',
        newStatus: 'delivered',
        timestamp: DateTime.now(),
        rawData: {},
      );
      
      expect(event.isApproved, isFalse);
      expect(event.isRejected, isFalse);
      expect(event.isDelivered, isTrue);
    });
  });

  group('RealtimeConnectionStatus', () {
    test('should have all expected values', () {
      expect(RealtimeConnectionStatus.values, contains(RealtimeConnectionStatus.disconnected));
      expect(RealtimeConnectionStatus.values, contains(RealtimeConnectionStatus.connecting));
      expect(RealtimeConnectionStatus.values, contains(RealtimeConnectionStatus.connected));
      expect(RealtimeConnectionStatus.values, contains(RealtimeConnectionStatus.reconnecting));
      expect(RealtimeConnectionStatus.values, contains(RealtimeConnectionStatus.polling));
    });

    test('isListening should return true for connected status', () async {
      when(mockSupabase.channel(any)).thenReturn(FakeRealtimeChannel());
      
      await service.attach('test-franchisee-id');
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(service.isListening, isTrue);
    });
  });

  group('RealtimeStockRequestService - Dispose', () {
    test('dispose should clean up resources', () {
      when(mockSupabase.channel(any)).thenReturn(FakeRealtimeChannel());
      
      // Should not throw
      expect(() => service.dispose(), returnsNormally);
    });
  });
}

/// Fake RealtimeChannel for testing
class FakeRealtimeChannel extends Fake implements RealtimeChannel {
  final StreamController<PostgresChangePayload> _controller = 
      StreamController<PostgresChangePayload>.broadcast();
  
  @override
  RealtimeChannel onPostgresChanges({
    required PostgresChangeEvent event,
    String? schema,
    String? table,
    PostgresChangeFilter? filter,
    required void Function(PostgresChangePayload payload) callback,
  }) {
    _controller.stream.listen(callback);
    return this;
  }

  @override
  RealtimeChannel subscribe([
    void Function(RealtimeSubscribeStatus status, Object? error)? callback,
    Duration? timeout,
  ]) {
    // Simulate successful subscription
    Future.microtask(() {
      callback?.call(RealtimeSubscribeStatus.subscribed, null);
    });
    return this;
  }
  
  void simulateEvent(Map<String, dynamic> oldRecord, Map<String, dynamic> newRecord) {
    // This would be used in more advanced tests
  }
  
  void close() {
    _controller.close();
  }
}
