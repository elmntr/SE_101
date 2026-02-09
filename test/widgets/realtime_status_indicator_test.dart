// test/widgets/realtime_status_indicator_test.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chickenjoo_inventory/services/realtime_stock_request_service.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/widgets/realtime_status_indicator.dart';

@GenerateNiceMocks([
  MockSpec<SupabaseClient>(),
  MockSpec<AppDatabase>(),
])
import 'realtime_status_indicator_test.mocks.dart';

/// A fake RealtimeStockRequestService that exposes controllable status.
class FakeRealtimeService extends RealtimeStockRequestService {
  final StreamController<RealtimeConnectionStatus> _fakeStatusController =
      StreamController<RealtimeConnectionStatus>.broadcast();
  RealtimeConnectionStatus _fakeStatus = RealtimeConnectionStatus.disconnected;

  FakeRealtimeService({
    required super.supabase,
    required super.db,
  });

  @override
  RealtimeConnectionStatus get status => _fakeStatus;

  @override
  Stream<RealtimeConnectionStatus> get statusStream =>
      _fakeStatusController.stream;

  void setStatus(RealtimeConnectionStatus newStatus) {
    _fakeStatus = newStatus;
    _fakeStatusController.add(newStatus);
  }

  void dispose() {
    _fakeStatusController.close();
  }
}

void main() {
  late FakeRealtimeService fakeService;
  late MockSupabaseClient mockSupabase;
  late MockAppDatabase mockDb;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockDb = MockAppDatabase();
    fakeService = FakeRealtimeService(
      supabase: mockSupabase,
      db: mockDb,
    );
  });

  tearDown(() {
    fakeService.dispose();
  });

  Widget buildWidget({bool compact = false, VoidCallback? onTap}) {
    return MaterialApp(
      home: Scaffold(
        body: RealtimeStatusIndicator(
          service: fakeService,
          compact: compact,
          onTap: onTap,
        ),
      ),
    );
  }

  testWidgets('1. renders without crashing', (tester) async {
    await tester.pumpWidget(buildWidget());
    expect(find.byType(RealtimeStatusIndicator), findsOneWidget);
  });

  testWidgets('2. shows OFFLINE text when disconnected', (tester) async {
    fakeService.setStatus(RealtimeConnectionStatus.disconnected);
    await tester.pumpWidget(buildWidget());
    await tester.pump();
    expect(find.text('OFFLINE'), findsOneWidget);
  });

  testWidgets('3. shows wifi_off icon when disconnected', (tester) async {
    fakeService.setStatus(RealtimeConnectionStatus.disconnected);
    await tester.pumpWidget(buildWidget());
    await tester.pump();
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
  });

  testWidgets('4. updates to LIVE text when connected', (tester) async {
    await tester.pumpWidget(buildWidget());
    fakeService.setStatus(RealtimeConnectionStatus.connected);
    await tester.pump();
    expect(find.text('LIVE'), findsOneWidget);
  });

  testWidgets('5. shows wifi icon when connected', (tester) async {
    await tester.pumpWidget(buildWidget());
    fakeService.setStatus(RealtimeConnectionStatus.connected);
    await tester.pump();
    expect(find.byIcon(Icons.wifi), findsOneWidget);
  });

  testWidgets('6. shows POLLING text when polling', (tester) async {
    await tester.pumpWidget(buildWidget());
    fakeService.setStatus(RealtimeConnectionStatus.polling);
    await tester.pump();
    expect(find.text('POLLING'), findsOneWidget);
  });

  testWidgets('7. shows update icon when polling', (tester) async {
    await tester.pumpWidget(buildWidget());
    fakeService.setStatus(RealtimeConnectionStatus.polling);
    await tester.pump();
    expect(find.byIcon(Icons.update), findsOneWidget);
  });

  testWidgets('8. shows CONNECTING text when connecting', (tester) async {
    await tester.pumpWidget(buildWidget());
    fakeService.setStatus(RealtimeConnectionStatus.connecting);
    await tester.pump();
    expect(find.text('CONNECTING'), findsOneWidget);
  });

  testWidgets('9. shows sync icon when connecting', (tester) async {
    await tester.pumpWidget(buildWidget());
    fakeService.setStatus(RealtimeConnectionStatus.connecting);
    await tester.pump();
    expect(find.byIcon(Icons.sync), findsOneWidget);
  });

  testWidgets('10. shows RECONNECTING text when reconnecting', (tester) async {
    await tester.pumpWidget(buildWidget());
    fakeService.setStatus(RealtimeConnectionStatus.reconnecting);
    await tester.pump();
    expect(find.text('RECONNECTING'), findsOneWidget);
  });

  testWidgets('11. compact mode does not show status text', (tester) async {
    fakeService.setStatus(RealtimeConnectionStatus.disconnected);
    await tester.pumpWidget(buildWidget(compact: true));
    await tester.pump();
    expect(find.text('OFFLINE'), findsNothing);
  });

  testWidgets('12. compact mode still renders icon', (tester) async {
    fakeService.setStatus(RealtimeConnectionStatus.disconnected);
    await tester.pumpWidget(buildWidget(compact: true));
    await tester.pump();
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
  });

  testWidgets('13. onTap callback is triggered', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(buildWidget(onTap: () => tapped = true));
    await tester.pump();
    await tester.tap(find.byType(GestureDetector).first);
    expect(tapped, isTrue);
  });

  testWidgets('14. has Tooltip widget', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pump();
    expect(find.byType(Tooltip), findsOneWidget);
  });

  testWidgets('15. non-compact mode shows Row with icon and text', (tester) async {
    fakeService.setStatus(RealtimeConnectionStatus.connected);
    await tester.pumpWidget(buildWidget());
    await tester.pump();
    expect(find.byType(Row), findsWidgets);
    expect(find.text('LIVE'), findsOneWidget);
    expect(find.byIcon(Icons.wifi), findsOneWidget);
  });
}
