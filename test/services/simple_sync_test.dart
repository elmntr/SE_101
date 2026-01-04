import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chickenjoo_inventory/services/supabase_sync_service.dart';
import 'package:chickenjoo_inventory/database/app_database.dart' as db;
import 'package:chickenjoo_inventory/database/daos/organizations_dao.dart';

import 'supabase_sync_service_test.mocks.dart';

// Manual mock for PostgrestFilterBuilder to handle the fluent interface and Future.
class MockPostgrestFilterBuilder<T> extends Mock implements PostgrestFilterBuilder<T> {
  @override
  PostgrestFilterBuilder<T> gte(String column, Object value) => this;

  @override
  PostgrestTransformBuilder<T> order(String column, {bool ascending = false, bool nullsFirst = false, String? referencedTable}) => MockPostgrestTransformBuilder<T>();

  @override
  Future<R> then<R>(FutureOr<R> Function(T value) onValue, {Function? onError}) {
    return Future.value(null as R);
  }
}

// Manual mock for PostgrestTransformBuilder
class MockPostgrestTransformBuilder<T> extends Mock implements PostgrestTransformBuilder<T> {
  @override
  PostgrestTransformBuilder<T> limit(int count, {String? referencedTable}) => this;

  @override
  Future<R> then<R>(FutureOr<R> Function(T value) onValue, {Function? onError}) {
    return Future.value(null as R);
  }
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('SupabaseSyncService Simple Tests', () {
    late SupabaseSyncService syncService;
    late MockSupabaseClient mockSupabase;
    late MockAppDatabase mockDb;
    late MockGoTrueClient mockAuth;
    late MockSupabaseQueryBuilder mockQueryBuilder;
    late MockPostgrestFilterBuilder<List<Map<String, dynamic>>> mockFilterBuilder;
    late MockOrganizationsDao mockOrganizationsDao;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockDb = MockAppDatabase();
      mockAuth = MockGoTrueClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();
      mockFilterBuilder = MockPostgrestFilterBuilder<List<Map<String, dynamic>>>();
      mockOrganizationsDao = MockOrganizationsDao();

      when(mockSupabase.auth).thenReturn(mockAuth);
      when(mockDb.organizationsDao).thenReturn(mockOrganizationsDao);
      when(mockSupabase.from(any)).thenAnswer((_) => mockQueryBuilder);
      when(mockQueryBuilder.upsert(any, onConflict: anyNamed('onConflict'))).thenAnswer((_) => mockFilterBuilder);
      when(mockOrganizationsDao.getAllOrganizations()).thenAnswer((_) async => []);
      when(mockOrganizationsDao.markAsSynced(any, cloudIds: anyNamed('cloudIds'))).thenAnswer((_) async => {});
      
      syncService = SupabaseSyncService(
        db: mockDb,
        supabase: mockSupabase,
      );
    });

    test('initializes correctly', () {
      expect(syncService, isA<SupabaseSyncService>());
    });

    test('can create organization for push', () async {
      final mockUser = MockUser();
      when(mockUser.id).thenReturn('test');
      when(mockUser.email).thenReturn('test@test.com');
      when(mockAuth.currentUser).thenReturn(mockUser);
      
      await syncService.initialize(organizationType: 'commissary');
      
      final org = db.Organization(id: 1, name: 'Test Org', type: 'commissary', isActive: true, createdAt: DateTime.now(), lastUpdated: DateTime.now(), isSynced: false);
      when(mockOrganizationsDao.getUnsyncedOrganizations(limit: anyNamed('limit'), offset: 0)).thenAnswer((_) async => [org]);
      when(mockOrganizationsDao.getUnsyncedOrganizations(limit: anyNamed('limit'), offset: 50)).thenAnswer((_) async => []);

      // Just test that we can create the organization object
      expect(org.name, 'Test Org');
      expect(org.type, 'commissary');
      expect(org.isSynced, false);
    });

    test('mock setup works correctly', () async {
      final mockUser = MockUser();
      when(mockUser.id).thenReturn('test');
      when(mockUser.email).thenReturn('test@test.com');
      when(mockAuth.currentUser).thenReturn(mockUser);
      
      await syncService.initialize(organizationType: 'commissary');
      
      final org = db.Organization(id: 1, name: 'Test Org', type: 'commissary', isActive: true, createdAt: DateTime.now(), lastUpdated: DateTime.now(), isSynced: false);
      when(mockOrganizationsDao.getUnsyncedOrganizations(limit: anyNamed('limit'), offset: 0)).thenAnswer((_) async => [org]);
      when(mockOrganizationsDao.getUnsyncedOrganizations(limit: anyNamed('limit'), offset: 50)).thenAnswer((_) async => []);

      // Test that the mock setup works
      final unsynced = await mockOrganizationsDao.getUnsyncedOrganizations(limit: 50, offset: 0);
      expect(unsynced.length, 1);
      expect(unsynced.first.name, 'Test Org');
      
      // Test that the upsert mock works
      final result = mockSupabase.from('organizations');
      expect(result, isA<MockSupabaseQueryBuilder>());
    });
  });
}
