import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chickenjoo_inventory/services/realtime_sales_service.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';

import 'realtime_sales_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SupabaseClient>(),
  MockSpec<AppDatabase>(),
])
void main() {
  late MockSupabaseClient mockSupabase;
  late MockAppDatabase mockDb;
  late RealtimeSalesService service;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockDb = MockAppDatabase();
    service = RealtimeSalesService(
      supabase: mockSupabase,
      db: mockDb,
    );
  });

  group('RealtimeSalesService Tests', () {
    test('should create RealtimeSalesService', () {
      expect(service, isNotNull);
    });

    test('should have salesStream getter', () {
      expect(service.salesStream, isNotNull);
    });

    test('startListeningForCommissary should return Future', () {
      when(mockSupabase.channel(any)).thenReturn(FakeRealtimeChannel());
      final result = service.startListeningForCommissary();
      expect(result, isA<Future<void>>());
    });
  });
}

class FakeRealtimeChannel extends Fake implements RealtimeChannel {
  @override
  RealtimeChannel onPostgresChanges({
    required PostgresChangeEvent event,
    String? schema,
    String? table,
    PostgresChangeFilter? filter,
    required void Function(PostgresChangePayload payload) callback,
  }) {
    return this;
  }

  @override
  RealtimeChannel subscribe([
    void Function(RealtimeSubscribeStatus status, Object? error)? callback,
    Duration? timeout,
  ]) {
    callback?.call(RealtimeSubscribeStatus.subscribed, null);
    return this;
  }
}
