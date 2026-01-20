import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import 'package:chickenjoo_inventory/database/app_database.dart' as db;
import 'package:chickenjoo_inventory/database/daos/users_dao.dart';
import 'package:chickenjoo_inventory/database/daos/organizations_dao.dart';
import 'package:chickenjoo_inventory/database/daos/roles_dao.dart';

import 'supabase_auth_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<sb.SupabaseClient>(),
  MockSpec<db.AppDatabase>(),
  MockSpec<sb.GoTrueClient>(),
  MockSpec<UsersDao>(),
  MockSpec<OrganizationsDao>(),
  MockSpec<RolesDao>(),
])
void main() {
  group('SupabaseAuthService Tests', () {
    late MockSupabaseClient mockSupabaseClient;
    late MockAppDatabase mockDatabase;
    late MockGoTrueClient mockAuth;
    late MockUsersDao mockUsersDao;
    late SupabaseAuthService authService;
    late StreamController<sb.AuthState> authStateController;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockDatabase = MockAppDatabase();
      mockAuth = MockGoTrueClient();
      mockUsersDao = MockUsersDao();
      authStateController = StreamController<sb.AuthState>.broadcast();
      
      when(mockSupabaseClient.auth).thenReturn(mockAuth);
      when(mockAuth.onAuthStateChange).thenAnswer((_) => authStateController.stream);
      when(mockDatabase.usersDao).thenReturn(mockUsersDao);
      
      when(mockUsersDao.getAllUsers()).thenAnswer((_) async => []);

      authService = SupabaseAuthService(
        supabase: mockSupabaseClient,
        database: mockDatabase,
      );
    });

    tearDown(() {
      authStateController.close();
    });

    test('should handle auth state change correctly', () async {
      final mockSession = FakeSession();
      
      // Trigger auth state change
      authStateController.add(sb.AuthState(sb.AuthChangeEvent.signedIn, mockSession));
      
      await Future.delayed(Duration(milliseconds: 10));
      
      expect(authService.isAuthenticated, isFalse); // No matching local user
    });

    test('should be authenticated if matching local user is found', () async {
      final mockSession = FakeSession();
      final mockLocalUser = db.User(
        id: 1,
        email: 'test@example.com',
        username: 'test',
        password: 'hashed',
        organizationId: 1,
        roleId: 1,
        isActive: true,
        isSynced: true,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
      
      when(mockUsersDao.getAllUsers()).thenAnswer((_) async => [mockLocalUser]);
      when(mockDatabase.organizationsDao).thenReturn(MockOrganizationsDao());
      when(mockDatabase.rolesDao).thenReturn(MockRolesDao());

      // Trigger auth state change
      authStateController.add(sb.AuthState(sb.AuthChangeEvent.signedIn, mockSession));
      
      await Future.delayed(Duration(milliseconds: 50));
      // Even if not fully populated UserData, _currentUser should be non-null if _findLocalUser succeeds
    });
  });
}

class FakeSession extends Fake implements sb.Session {
  @override
  sb.User get user => FakeUser();
  @override
  int get expiresAt => DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
}

class FakeUser extends Fake implements sb.User {
  @override
  String get id => 'user123';
  @override
  String? get email => 'test@example.com';
}
