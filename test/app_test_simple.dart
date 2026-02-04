import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:chickenjoo_inventory/app.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/database/daos/organizations_dao.dart';
import 'package:chickenjoo_inventory/services/supabase_sync_service_v2.dart';
import 'package:chickenjoo_inventory/screen/login/login_screen.dart';

import 'app_test_simple.mocks.dart';

@GenerateMocks([
  UserData,
  SupabaseAuthService,
  AppDatabase,
  SupabaseSyncServiceV2,
  OrganizationsDao,
])
void main() {
  group('app.dart Tests', () {
    late MockUserData mockUserData;
    late MockSupabaseAuthService mockAuthService;
    late MockAppDatabase mockDatabase;
    late MockSupabaseSyncServiceV2 mockSyncService;
    late MockOrganizationsDao mockOrganizationsDao;

    setUp(() {
      mockUserData = MockUserData();
      mockAuthService = MockSupabaseAuthService();
      mockDatabase = MockAppDatabase();
      mockSyncService = MockSupabaseSyncServiceV2();
      mockOrganizationsDao = MockOrganizationsDao();

      // Setup default mock behaviors
      when(mockUserData.id).thenReturn(1);
      when(mockUserData.username).thenReturn('testuser');
      when(mockUserData.email).thenReturn('test@example.com');
      when(mockUserData.organizationId).thenReturn(1);
      when(mockUserData.organizationCloudId).thenReturn('org-cloud-123');
      when(mockUserData.organizationType).thenReturn('commissary');
      when(mockUserData.organizationName).thenReturn('Test Organization');
      when(mockUserData.roleId).thenReturn(1);
      when(mockUserData.roleName).thenReturn('Admin');
      when(mockUserData.isFranchisee).thenReturn(false);
      when(mockUserData.isCommissary).thenReturn(true);

      // Stub DAOs
      when(mockDatabase.organizationsDao).thenReturn(mockOrganizationsDao);
      when(mockOrganizationsDao.getOrganizationById(any)).thenAnswer((_) async => null);

      // Default mock for sync service initialization
      when(mockSyncService.initialize(
        organizationId: anyNamed('organizationId'),
        organizationCloudId: anyNamed('organizationCloudId'),
        organizationType: anyNamed('organizationType'),
        parentCommissaryId: anyNamed('parentCommissaryId'),
        parentCommissaryCloudId: anyNamed('parentCommissaryCloudId'),
      )).thenAnswer((_) async {});

      // Stub Auth service
      when(mockAuthService.restoreSession()).thenAnswer((_) async => AuthResult.failure('No session'));
      when(mockAuthService.currentUser).thenReturn(null);
      when(mockAuthService.dispose()).thenReturn(null);
      when(mockSyncService.dispose()).thenReturn(null);
      when(mockDatabase.close()).thenAnswer((_) async => true);

      // Initialize AppGlobals with mocks
      AppGlobals.instance.initialize(
        database: mockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
      );
    });

    // Happy Path Tests (7)
    testWidgets('MyApp should build without errors', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MyApp());

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Inventory System'), findsOneWidget);
    });

    testWidgets('should navigate to login screen as initial route', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MyApp());

      // Assert
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('should set correct theme configuration', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MyApp());

      // Assert
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.colorScheme.brightness, Brightness.light);
      expect(materialApp.theme?.useMaterial3, true);
      expect(materialApp.debugShowCheckedModeBanner, false);
    });

    testWidgets('should reinitialize sync service for commissary user', (WidgetTester tester) async {
      // Arrange
      when(mockUserData.isFranchisee).thenReturn(false);

      // Act
      reinitializeSyncWithUserContext(mockUserData);

      // Assert
      final orgId = mockUserData.organizationId;
      final orgCloudId = mockUserData.organizationCloudId;
      final orgType = mockUserData.organizationType;
      
      verify(mockSyncService.initialize(
        organizationId: orgId,
        organizationCloudId: orgCloudId,
        organizationType: orgType,
        parentCommissaryId: null,
        parentCommissaryCloudId: null,
      )).called(1);
    });

    testWidgets('should handle franchisee user without parent commissary', (WidgetTester tester) async {
      // Arrange
      when(mockUserData.isFranchisee).thenReturn(true);

      // Act
      reinitializeSyncWithUserContext(mockUserData);

      // Assert
      final orgId = mockUserData.organizationId;
      final orgCloudId = mockUserData.organizationCloudId;
      final orgType = mockUserData.organizationType;

      verify(mockSyncService.initialize(
        organizationId: orgId,
        organizationCloudId: orgCloudId,
        organizationType: orgType,
        parentCommissaryId: null,
        parentCommissaryCloudId: null,
      )).called(1);
    });

    testWidgets('should handle route generation correctly', (WidgetTester tester) async {
      // Arrange
      AppGlobals.instance.initialize(
        database: mockDatabase,
        syncService: mockSyncService,
        authService: mockAuthService,
      );
      // Act
      await tester.pumpWidget(const MyApp());
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Test home route generation
      final route = materialApp.onGenerateRoute!(RouteSettings(name: '/home', arguments: mockUserData));

      // Assert
      expect(route, isA<MaterialPageRoute>());
    });

    testWidgets('should provide access to MyApp state', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MyApp());
      final context = tester.element(find.byType(MaterialApp));

      // Assert
      expect(MyApp.of(context), isNotNull);
    });

    // Unhappy Path Tests (8)
    testWidgets('should redirect to login when userData is null', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MyApp());
      
      // Try to navigate to home without userData
      MyApp.of(tester.element(find.byType(MaterialApp)))!.navigator.pushNamed('/home');
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('should handle sync service reinitialization errors', (WidgetTester tester) async {
      // Arrange
      when(mockSyncService.initialize(
        organizationId: anyNamed('organizationId'),
        organizationCloudId: anyNamed('organizationCloudId'),
        organizationType: anyNamed('organizationType'),
        parentCommissaryId: anyNamed('parentCommissaryId'),
        parentCommissaryCloudId: anyNamed('parentCommissaryCloudId'),
      )).thenThrow(Exception('Sync service failed'));

      // Act & Assert
      expect(() {
        reinitializeSyncWithUserContext(mockUserData);
      }, returnsNormally); // Should handle error gracefully
    });

    testWidgets('should handle null organization cloud ID', (WidgetTester tester) async {
      // Arrange
      final userDataWithNullCloudId = MockUserData();
      when(userDataWithNullCloudId.id).thenReturn(1);
      when(userDataWithNullCloudId.username).thenReturn('testuser');
      when(userDataWithNullCloudId.email).thenReturn('test@example.com');
      when(userDataWithNullCloudId.organizationId).thenReturn(1);
      when(userDataWithNullCloudId.organizationCloudId).thenReturn(null);
      when(userDataWithNullCloudId.organizationType).thenReturn('commissary');
      when(userDataWithNullCloudId.organizationName).thenReturn('Test Organization');
      when(userDataWithNullCloudId.roleId).thenReturn(1);
      when(userDataWithNullCloudId.roleName).thenReturn('Admin');
      when(userDataWithNullCloudId.isFranchisee).thenReturn(false);
      when(userDataWithNullCloudId.isCommissary).thenReturn(true);

      // Act
      reinitializeSyncWithUserContext(userDataWithNullCloudId);

      // Assert
      final orgId = userDataWithNullCloudId.organizationId;
      final orgType = userDataWithNullCloudId.organizationType;

      verify(mockSyncService.initialize(
        organizationId: orgId,
        organizationCloudId: null,
        organizationType: orgType,
        parentCommissaryId: null,
        parentCommissaryCloudId: null,
      )).called(1);
    });

    testWidgets('should handle empty username', (WidgetTester tester) async {
      // Arrange
      when(mockUserData.username).thenReturn('');

      // Act
      reinitializeSyncWithUserContext(mockUserData);

      // Assert
      verify(mockSyncService.initialize(
        organizationId: anyNamed('organizationId'),
        organizationCloudId: anyNamed('organizationCloudId'),
        organizationType: anyNamed('organizationType'),
        parentCommissaryId: anyNamed('parentCommissaryId'),
        parentCommissaryCloudId: anyNamed('parentCommissaryCloudId'),
      )).called(1);
    });

    testWidgets('should handle invalid route names', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const MyApp());
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Act
      final route = materialApp.onGenerateRoute!(const RouteSettings(name: '/invalid'));

      // Assert
      expect(route, isNull);
    });

    testWidgets('should handle AppGlobals already initialized', (WidgetTester tester) async {
      // Act & Assert
      expect(() {
        reinitializeSyncWithUserContext(mockUserData);
      }, returnsNormally);
    });

    testWidgets('should handle null context in MyApp.of', (WidgetTester tester) async {
      // Act & Assert
      expect(() => MyApp.of(null), returnsNormally);
    });

    testWidgets('should handle database errors during organization lookup', (WidgetTester tester) async {
      // Arrange
      when(mockUserData.isFranchisee).thenReturn(true);
      when(mockDatabase.organizationsDao).thenThrow(Exception('Database error'));
      // Act & Assert
      expect(() {
        reinitializeSyncWithUserContext(mockUserData);
      }, returnsNormally); // Should handle error gracefully
    });
  });
}
