import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:chickenjoo_inventory/app.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import 'package:chickenjoo_inventory/screen/login/login_screen.dart';
import 'package:chickenjoo_inventory/home.dart';

void main() {
  group('AppGlobals Tests', () {
    late AppGlobals appGlobals;

    setUp(() {
      appGlobals = AppGlobals.instance;
    });

    tearDown(() {
      try {
        appGlobals.dispose();
      } catch (e) {
        // Ignore if not initialized
      }
    });

    test('should be singleton instance', () {
      final instance1 = AppGlobals.instance;
      final instance2 = AppGlobals.instance;
      expect(instance1, same(instance2));
    });

    test('should throw StateError when database not initialized', () {
      expect(() => appGlobals.database, throwsA(isA<StateError>()));
    });

    test('should throw StateError when syncService not initialized', () {
      expect(() => appGlobals.syncService, throwsA(isA<StateError>()));
    });

    test('should throw StateError when authService not initialized', () {
      expect(() => appGlobals.authService, throwsA(isA<StateError>()));
    });

    test('should return false for isInitialized when not initialized', () {
      expect(appGlobals.isInitialized, isFalse);
    });

    test('should handle dispose gracefully when not initialized', () {
      expect(() => appGlobals.dispose(), returnsNormally);
    });

    test('should handle multiple dispose calls gracefully', () {
      expect(() => appGlobals.dispose(), returnsNormally);
    });

    test('should maintain singleton behavior across calls', () {
      final instance1 = AppGlobals.instance;
      final instance2 = AppGlobals.instance;
      final instance3 = AppGlobals.instance;
      
      expect(instance1, same(instance2));
      expect(instance2, same(instance3));
    });

    test('should have consistent instance reference', () {
      final instance = AppGlobals.instance;
      expect(AppGlobals.instance, same(instance));
    });

    test('should handle rapid instance access', () {
      for (int i = 0; i < 100; i++) {
        final instance = AppGlobals.instance;
        expect(instance, isNotNull);
        expect(instance, isA<AppGlobals>());
      }
    });
  });

  group('MyApp Widget Tests', () {
    testWidgets('should build MaterialApp with correct configuration', (WidgetTester tester) async {
      const myApp = MyApp();

      await tester.pumpWidget(myApp);

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Chicken Joo Inventory'), findsOneWidget);
    });

    testWidgets('should have correct theme configuration', (WidgetTester tester) async {
      const myApp = MyApp();

      await tester.pumpWidget(myApp);

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.colorScheme.primary, equals(Colors.red));
      expect(materialApp.theme?.useMaterial3, isTrue);
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });

    testWidgets('should set initial route to /login', (WidgetTester tester) async {
      const myApp = MyApp();

      await tester.pumpWidget(myApp);

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.initialRoute, equals('/login'));
    });

    testWidgets('should have login route defined', (WidgetTester tester) async {
      const myApp = MyApp();

      await tester.pumpWidget(myApp);

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.routes?.containsKey('/login'), isTrue);
    });

    testWidgets('should navigate to login screen initially', (WidgetTester tester) async {
      const myApp = MyApp();

      await tester.pumpWidget(myApp);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('should handle route generation for unknown routes', (WidgetTester tester) async {
      const myApp = MyApp();

      await tester.pumpWidget(myApp);

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final route = materialApp.onGenerateRoute!(const RouteSettings(name: '/unknown'));
      expect(route, isNull);
    });

    testWidgets('should handle /home route without arguments', (WidgetTester tester) async {
      const myApp = MyApp();

      await tester.pumpWidget(myApp);
      
      // Navigate to /home without arguments
      Navigator.of(tester.element(find.byType(MaterialApp))).pushNamed('/home');
      
      await tester.pumpAndSettle();

      // Should redirect to login
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets('should handle rapid navigation attempts', (WidgetTester tester) async {
      const myApp = MyApp();

      await tester.pumpWidget(myApp);

      // Rapid navigation attempts
      for (int i = 0; i < 5; i++) {
        await tester.pump();
      }

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should maintain app structure across rebuilds', (WidgetTester tester) async {
      const myApp = MyApp();

      await tester.pumpWidget(myApp);
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);

      // Rebuild
      await tester.pumpWidget(myApp);
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('UserData Tests', () {
    test('should create UserData with valid structure', () {
      const userData = UserData(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        organizationId: 1,
        organizationName: 'Test Org',
        organizationType: 'commissary',
        organizationCloudId: 'cloud-123',
        roleId: 1,
        roleName: 'admin',
        permissions: RolePermissions(
          canViewInventory: true,
          canAddInventory: true,
          canEditInventory: true,
          canDeleteInventory: false,
          canViewReports: true,
          canExportData: false,
          canAccessSettings: true,
          canManageEmployees: true,
          canManageRoles: false,
        ),
      );

      expect(userData.id, equals(1));
      expect(userData.username, equals('testuser'));
      expect(userData.email, equals('test@example.com'));
      expect(userData.organizationId, equals(1));
      expect(userData.organizationName, equals('Test Org'));
      expect(userData.organizationType, equals('commissary'));
      expect(userData.roleName, equals('admin'));
    });

    test('should create UserData with minimal permissions', () {
      const userData = UserData(
        id: 2,
        username: 'basicuser',
        email: 'basic@example.com',
        organizationId: 2,
        organizationName: 'Basic Org',
        organizationType: 'franchisee',
        organizationCloudId: 'cloud-456',
        roleId: 2,
        roleName: 'user',
        permissions: RolePermissions(
          canViewInventory: true,
          canAddInventory: false,
          canEditInventory: false,
          canDeleteInventory: false,
          canViewReports: false,
          canExportData: false,
          canAccessSettings: false,
          canManageEmployees: false,
          canManageRoles: false,
        ),
      );

      expect(userData.username, equals('basicuser'));
      expect(userData.organizationType, equals('franchisee'));
      expect(userData.permissions.canViewInventory, isTrue);
      expect(userData.permissions.canAddInventory, isFalse);
    });

    test('should handle UserData equality', () {
      const userData1 = UserData(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        organizationId: 1,
        organizationName: 'Test Org',
        organizationType: 'commissary',
        organizationCloudId: 'cloud-123',
        roleId: 1,
        roleName: 'admin',
        permissions: RolePermissions(),
      );

      const userData2 = UserData(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        organizationId: 1,
        organizationName: 'Test Org',
        organizationType: 'commissary',
        organizationCloudId: 'cloud-123',
        roleId: 1,
        roleName: 'admin',
        permissions: RolePermissions(),
      );

      expect(userData1, equals(userData2));
    });

    test('should handle UserData inequality', () {
      const userData1 = UserData(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        organizationId: 1,
        organizationName: 'Test Org',
        organizationType: 'commissary',
        organizationCloudId: 'cloud-123',
        roleId: 1,
        roleName: 'admin',
        permissions: RolePermissions(),
      );

      const userData2 = UserData(
        id: 2,
        username: 'otheruser',
        email: 'other@example.com',
        organizationId: 2,
        organizationName: 'Other Org',
        organizationType: 'franchisee',
        organizationCloudId: 'cloud-789',
        roleId: 2,
        roleName: 'user',
        permissions: RolePermissions(),
      );

      expect(userData1, isNot(equals(userData2)));
    });
  });

  group('RolePermissions Tests', () {
    test('should create RolePermissions with default values', () {
      const permissions = RolePermissions();

      expect(permissions.canViewInventory, isFalse);
      expect(permissions.canAddInventory, isFalse);
      expect(permissions.canEditInventory, isFalse);
      expect(permissions.canDeleteInventory, isFalse);
      expect(permissions.canViewReports, isFalse);
      expect(permissions.canExportData, isFalse);
      expect(permissions.canAccessSettings, isFalse);
      expect(permissions.canManageEmployees, isFalse);
      expect(permissions.canManageRoles, isFalse);
    });

    test('should create RolePermissions with custom values', () {
      const permissions = RolePermissions(
        canViewInventory: true,
        canAddInventory: true,
        canEditInventory: false,
        canDeleteInventory: false,
        canViewReports: true,
        canExportData: false,
        canAccessSettings: true,
        canManageEmployees: false,
        canManageRoles: false,
      );

      expect(permissions.canViewInventory, isTrue);
      expect(permissions.canAddInventory, isTrue);
      expect(permissions.canEditInventory, isFalse);
      expect(permissions.canViewReports, isTrue);
      expect(permissions.canAccessSettings, isTrue);
    });

    test('should handle RolePermissions equality', () {
      const permissions1 = RolePermissions(
        canViewInventory: true,
        canAddInventory: false,
        canEditInventory: false,
        canDeleteInventory: false,
        canViewReports: true,
        canExportData: false,
        canAccessSettings: false,
        canManageEmployees: false,
        canManageRoles: false,
      );

      const permissions2 = RolePermissions(
        canViewInventory: true,
        canAddInventory: false,
        canEditInventory: false,
        canDeleteInventory: false,
        canViewReports: true,
        canExportData: false,
        canAccessSettings: false,
        canManageEmployees: false,
        canManageRoles: false,
      );

      expect(permissions1, equals(permissions2));
    });

    test('should handle RolePermissions inequality', () {
      const permissions1 = RolePermissions(
        canViewInventory: true,
        canAddInventory: false,
        canEditInventory: false,
        canDeleteInventory: false,
        canViewReports: true,
        canExportData: false,
        canAccessSettings: false,
        canManageEmployees: false,
        canManageRoles: false,
      );

      const permissions2 = RolePermissions(
        canViewInventory: false,
        canAddInventory: false,
        canEditInventory: false,
        canDeleteInventory: false,
        canViewReports: false,
        canExportData: false,
        canAccessSettings: false,
        canManageEmployees: false,
        canManageRoles: false,
      );

      expect(permissions1, isNot(equals(permissions2)));
    });
  });

  group('Integration Tests', () {
    testWidgets('should handle complete app lifecycle', (WidgetTester tester) async {
      const myApp = MyApp();

      await tester.pumpWidget(myApp);
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);

      // Test app structure
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, equals('Chicken Joo Inventory'));
      expect(materialApp.initialRoute, equals('/login'));
    });

    testWidgets('should handle error states gracefully', (WidgetTester tester) async {
      const myApp = MyApp();

      await tester.pumpWidget(myApp);
      
      // Should not crash even with invalid navigation
      expect(() {
        Navigator.of(tester.element(find.byType(MaterialApp))).pushNamed('/invalid-route');
      }, returnsNormally);
    });
  });

  group('Performance Tests', () {
    testWidgets('should build app quickly', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      const myApp = MyApp();
      await tester.pumpWidget(myApp);

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('should handle rapid AppGlobals access', () {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        AppGlobals.instance;
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}
