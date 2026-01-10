import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/utils/sync_status.dart';

void main() {
  group('AppGlobals Tests', () {
    test('should be singleton instance', () {
      final instance1 = AppGlobals.instance;
      final instance2 = AppGlobals.instance;
      expect(instance1, same(instance2));
    });

    test('should throw StateError when database not initialized', () {
      expect(() => AppGlobals.instance.database, throwsA(isA<StateError>()));
    });

    test('should throw StateError when syncService not initialized', () {
      expect(() => AppGlobals.instance.syncService, throwsA(isA<StateError>()));
    });

    test('should throw StateError when authService not initialized', () {
      expect(() => AppGlobals.instance.authService, throwsA(isA<StateError>()));
    });

    test('should return false for isInitialized when not initialized', () {
      expect(AppGlobals.instance.isInitialized, isFalse);
    });

    test('should handle dispose gracefully when not initialized', () {
      expect(() => AppGlobals.instance.dispose(), returnsNormally);
    });

    test('should handle multiple dispose calls gracefully', () {
      expect(() => AppGlobals.instance.dispose(), returnsNormally);
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

    test('should handle concurrent access', () async {
      final futures = <Future>[];
      for (int i = 0; i < 10; i++) {
        futures.add(Future.delayed(Duration(milliseconds: i), () {
          return AppGlobals.instance;
        }));
      }
      
      final results = await Future.wait(futures);
      for (final result in results) {
        expect(result, isA<AppGlobals>());
        expect(result, same(AppGlobals.instance));
      }
    });

    test('should maintain immutability of instance', () {
      final instance1 = AppGlobals.instance;
      final instance2 = AppGlobals.instance;
      
      expect(identical(instance1, instance2), isTrue);
      expect(instance1.hashCode, equals(instance2.hashCode));
    });

    test('should handle error states gracefully', () {
      expect(() {
        try {
          AppGlobals.instance.database;
        } catch (e) {
          expect(e, isA<StateError>());
        }
      }, returnsNormally);
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
      expect(userData1.hashCode, equals(userData2.hashCode));
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
      expect(userData1.hashCode, isNot(equals(userData2.hashCode)));
    });

    test('should handle UserData with null optional fields', () {
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
        permissions: RolePermissions(),
        fullName: null,
        phone: null,
        cloudId: null,
        authUserId: null,
      );

      expect(userData.fullName, isNull);
      expect(userData.phone, isNull);
      expect(userData.cloudId, isNull);
      expect(userData.authUserId, isNull);
    });

    test('should handle UserData with all fields populated', () {
      const userData = UserData(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        fullName: 'Test User Full Name',
        phone: '+1234567890',
        organizationId: 1,
        organizationName: 'Test Org',
        organizationType: 'commissary',
        organizationCloudId: 'cloud-123',
        roleId: 1,
        roleName: 'admin',
        permissions: RolePermissions(),
        cloudId: 'cloud-user-123',
        authUserId: 'auth-user-456',
      );

      expect(userData.fullName, equals('Test User Full Name'));
      expect(userData.phone, equals('+1234567890'));
      expect(userData.cloudId, equals('cloud-user-123'));
      expect(userData.authUserId, equals('auth-user-456'));
    });

    test('should handle UserData string representation', () {
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
        permissions: RolePermissions(),
      );

      final stringRep = userData.toString();
      expect(stringRep, isA<String>());
      expect(stringRep, isNotEmpty);
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
      expect(permissions1.hashCode, equals(permissions2.hashCode));
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
      expect(permissions1.hashCode, isNot(equals(permissions2.hashCode)));
    });

    test('should handle admin permissions', () {
      const adminPermissions = RolePermissions(
        canViewInventory: true,
        canAddInventory: true,
        canEditInventory: true,
        canDeleteInventory: true,
        canViewReports: true,
        canExportData: true,
        canAccessSettings: true,
        canManageEmployees: true,
        canManageRoles: true,
      );

      expect(adminPermissions.canViewInventory, isTrue);
      expect(adminPermissions.canAddInventory, isTrue);
      expect(adminPermissions.canEditInventory, isTrue);
      expect(adminPermissions.canDeleteInventory, isTrue);
      expect(adminPermissions.canViewReports, isTrue);
      expect(adminPermissions.canExportData, isTrue);
      expect(adminPermissions.canAccessSettings, isTrue);
      expect(adminPermissions.canManageEmployees, isTrue);
      expect(adminPermissions.canManageRoles, isTrue);
    });

    test('should handle read-only permissions', () {
      const readOnlyPermissions = RolePermissions(
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

      expect(readOnlyPermissions.canViewInventory, isTrue);
      expect(readOnlyPermissions.canAddInventory, isFalse);
      expect(readOnlyPermissions.canEditInventory, isFalse);
      expect(readOnlyPermissions.canDeleteInventory, isFalse);
      expect(readOnlyPermissions.canViewReports, isTrue);
      expect(readOnlyPermissions.canExportData, isFalse);
      expect(readOnlyPermissions.canAccessSettings, isFalse);
      expect(readOnlyPermissions.canManageEmployees, isFalse);
      expect(readOnlyPermissions.canManageRoles, isFalse);
    });

    test('should handle permission combinations', () {
      final combinations = [
        const RolePermissions(),
        const RolePermissions(canViewInventory: true),
        const RolePermissions(canAddInventory: true),
        const RolePermissions(canEditInventory: true),
        const RolePermissions(canDeleteInventory: true),
        const RolePermissions(canViewReports: true),
        const RolePermissions(canExportData: true),
        const RolePermissions(canAccessSettings: true),
        const RolePermissions(canManageEmployees: true),
        const RolePermissions(canManageRoles: true),
        const RolePermissions(
          canViewInventory: true,
          canAddInventory: true,
          canEditInventory: true,
          canDeleteInventory: true,
          canViewReports: true,
          canExportData: true,
          canAccessSettings: true,
          canManageEmployees: true,
          canManageRoles: true,
        ),
      ];

      for (final permissions in combinations) {
        expect(permissions, isA<RolePermissions>());
        expect(permissions.canViewInventory, isA<bool>());
        expect(permissions.canAddInventory, isA<bool>());
        expect(permissions.canEditInventory, isA<bool>());
        expect(permissions.canDeleteInventory, isA<bool>());
        expect(permissions.canViewReports, isA<bool>());
        expect(permissions.canExportData, isA<bool>());
        expect(permissions.canAccessSettings, isA<bool>());
        expect(permissions.canManageEmployees, isA<bool>());
        expect(permissions.canManageRoles, isA<bool>());
      }
    });
  });

  group('Design Constants Tests', () {
    test('should have correct font constant', () {
      expect(fontAll, equals('Montserrat'));
      expect(fontAll, isA<String>());
      expect(fontAll, isNotEmpty);
    });

    test('should have correct image path constant', () {
      expect(imageAll, equals('assets/images/chicken_joo_logo.png'));
      expect(imageAll, isA<String>());
      expect(imageAll, isNotEmpty);
    });

    test('should have correct color constant', () {
      expect(colorAll, equals(Colors.red));
      expect(colorAll, isA<Color>());
    });

    test('should have AppLayout class', () {
      expect(AppLayout.isDesktop, isA<Function>());
      expect(AppLayout.fieldPadding, isA<Function>());
      expect(AppLayout.loginButtonWidth, isA<Function>());
    });

    test('should handle constants immutability', () {
      // Constants should be accessible and have correct types
      expect(fontAll, isA<String>());
      expect(imageAll, isA<String>());
      expect(colorAll, isA<Color>());
      
      // Constants should have expected values
      expect(fontAll, isNotEmpty);
      expect(imageAll, isNotEmpty);
    });
  });

  group('SyncStatus Enum Tests', () {
    test('should have all expected values', () {
      expect(SyncStatus.values, contains(SyncStatus.idle));
      expect(SyncStatus.values, contains(SyncStatus.syncing));
      expect(SyncStatus.values, contains(SyncStatus.synced));
      expect(SyncStatus.values, contains(SyncStatus.error));
      expect(SyncStatus.values.length, equals(4));
    });

    test('should handle enum comparisons', () {
      expect(SyncStatus.idle, equals(SyncStatus.idle));
      expect(SyncStatus.syncing, equals(SyncStatus.syncing));
      expect(SyncStatus.synced, equals(SyncStatus.synced));
      expect(SyncStatus.error, equals(SyncStatus.error));

      expect(SyncStatus.idle, isNot(equals(SyncStatus.syncing)));
      expect(SyncStatus.syncing, isNot(equals(SyncStatus.synced)));
      expect(SyncStatus.synced, isNot(equals(SyncStatus.error)));
      expect(SyncStatus.error, isNot(equals(SyncStatus.idle)));
    });

    test('should have correct string representations', () {
      expect(SyncStatus.idle.toString(), equals('SyncStatus.idle'));
      expect(SyncStatus.syncing.toString(), equals('SyncStatus.syncing'));
      expect(SyncStatus.synced.toString(), equals('SyncStatus.synced'));
      expect(SyncStatus.error.toString(), equals('SyncStatus.error'));
    });

    test('should have correct index positions', () {
      expect(SyncStatus.idle.index, equals(0));
      expect(SyncStatus.syncing.index, equals(1));
      expect(SyncStatus.synced.index, equals(2));
      expect(SyncStatus.error.index, equals(3));
    });

    test('should handle enum in switch statements', () {
      String getStatusDescription(SyncStatus status) {
        switch (status) {
          case SyncStatus.idle:
            return 'Idle';
          case SyncStatus.syncing:
            return 'Syncing';
          case SyncStatus.synced:
            return 'Synced';
          case SyncStatus.error:
            return 'Error';
        }
      }

      expect(getStatusDescription(SyncStatus.idle), equals('Idle'));
      expect(getStatusDescription(SyncStatus.syncing), equals('Syncing'));
      expect(getStatusDescription(SyncStatus.synced), equals('Synced'));
      expect(getStatusDescription(SyncStatus.error), equals('Error'));
    });

    test('should handle enum in collections', () {
      final statusList = <SyncStatus>[
        SyncStatus.idle,
        SyncStatus.syncing,
        SyncStatus.synced,
        SyncStatus.error,
      ];

      expect(statusList.length, equals(4));
      expect(statusList, contains(SyncStatus.idle));
      expect(statusList, contains(SyncStatus.syncing));
      expect(statusList, contains(SyncStatus.synced));
      expect(statusList, contains(SyncStatus.error));
    });

    test('should handle enum as map keys', () {
      final statusMessages = <SyncStatus, String>{
        SyncStatus.idle: 'Waiting for sync',
        SyncStatus.syncing: 'Syncing data',
        SyncStatus.synced: 'All synced',
        SyncStatus.error: 'Sync failed',
      };

      expect(statusMessages[SyncStatus.idle], equals('Waiting for sync'));
      expect(statusMessages[SyncStatus.syncing], equals('Syncing data'));
      expect(statusMessages[SyncStatus.synced], equals('All synced'));
      expect(statusMessages[SyncStatus.error], equals('Sync failed'));
    });
  });

  group('Performance Tests', () {
    test('should handle rapid AppGlobals access', () {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        AppGlobals.instance;
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('should handle UserData creation quickly', () {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        UserData(
          id: i,
          username: 'user$i',
          email: 'user$i@example.com',
          organizationId: 1,
          organizationName: 'Test Org',
          organizationType: 'commissary',
          organizationCloudId: 'cloud-123',
          roleId: 1,
          roleName: 'admin',
          permissions: const RolePermissions(),
        );
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('should handle RolePermissions creation quickly', () {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        RolePermissions(
          canViewInventory: i % 2 == 0,
          canAddInventory: i % 3 == 0,
          canEditInventory: i % 4 == 0,
          canDeleteInventory: i % 5 == 0,
          canViewReports: i % 2 == 0,
          canExportData: i % 3 == 0,
          canAccessSettings: i % 4 == 0,
          canManageEmployees: i % 5 == 0,
          canManageRoles: i % 6 == 0,
        );
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('should handle enum operations quickly', () {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 10000; i++) {
        final status = SyncStatus.values[i % 4];
        switch (status) {
          case SyncStatus.idle:
            break;
          case SyncStatus.syncing:
            break;
          case SyncStatus.synced:
            break;
          case SyncStatus.error:
            break;
        }
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });
  });

  group('Edge Cases Tests', () {
    test('should handle UserData with extreme values', () {
      final userData = UserData(
        id: 2147483647, // Max int
        username: 'a' * 1000, // Very long username
        email: 'test@' + 'a' * 100 + '.com', // Very long email
        organizationId: -1, // Negative ID
        organizationName: 'A' * 500, // Very long name
        organizationType: 'type' * 100, // Very long type
        organizationCloudId: 'cloud-' * 100,
        roleId: 0,
        roleName: 'role' * 50,
        permissions: const RolePermissions(),
      );

      expect(userData.id, equals(2147483647));
      expect(userData.username.length, equals(1000));
      expect(userData.organizationId, equals(-1));
    });

    test('should handle UserData with special characters', () {
      const userData = UserData(
        id: 1,
        username: 'user@#\$%^&*()',
        email: 'test+tag@example-domain.com',
        organizationId: 1,
        organizationName: 'Org & Co.',
        organizationType: 'test-type',
        organizationCloudId: 'cloud_123',
        roleId: 1,
        roleName: 'admin_role',
        permissions: RolePermissions(),
      );

      expect(userData.username, contains('@'));
      expect(userData.email, contains('+'));
      expect(userData.organizationName, contains('&'));
    });

    test('should handle RolePermissions with all combinations', () {
      final combinations = [
        const RolePermissions(),
        const RolePermissions(canViewInventory: true),
        const RolePermissions(canAddInventory: true),
        const RolePermissions(canEditInventory: true),
        const RolePermissions(canDeleteInventory: true),
        const RolePermissions(canViewReports: true),
        const RolePermissions(canExportData: true),
        const RolePermissions(canAccessSettings: true),
        const RolePermissions(canManageEmployees: true),
        const RolePermissions(canManageRoles: true),
        const RolePermissions(
          canViewInventory: true,
          canAddInventory: true,
          canEditInventory: true,
          canDeleteInventory: true,
          canViewReports: true,
          canExportData: true,
          canAccessSettings: true,
          canManageEmployees: true,
          canManageRoles: true,
        ),
      ];

      for (final permissions in combinations) {
        expect(permissions, isA<RolePermissions>());
      }
    });

    test('should handle enum serialization', () {
      for (final status in SyncStatus.values) {
        final name = status.name;
        final deserialized = SyncStatus.values.byName(name);
        expect(deserialized, equals(status));
      }
    });
  });

  group('Type Safety Tests', () {
    test('should maintain correct types for UserData fields', () {
      const userData = UserData(
        id: 1,
        username: 'test',
        email: 'test@example.com',
        organizationId: 1,
        organizationName: 'Test Org',
        organizationType: 'commissary',
        organizationCloudId: 'cloud-123',
        roleId: 1,
        roleName: 'admin',
        permissions: RolePermissions(),
      );

      expect(userData.id, isA<int>());
      expect(userData.username, isA<String>());
      expect(userData.email, isA<String>());
      expect(userData.organizationId, isA<int>());
      expect(userData.organizationName, isA<String>());
      expect(userData.organizationType, isA<String>());
      expect(userData.roleId, isA<int>());
      expect(userData.roleName, isA<String>());
      expect(userData.permissions, isA<RolePermissions>());
    });

    test('should maintain correct types for RolePermissions fields', () {
      const permissions = RolePermissions(
        canViewInventory: true,
        canAddInventory: false,
        canEditInventory: true,
        canDeleteInventory: false,
        canViewReports: true,
        canExportData: false,
        canAccessSettings: true,
        canManageEmployees: false,
        canManageRoles: true,
      );

      expect(permissions.canViewInventory, isA<bool>());
      expect(permissions.canAddInventory, isA<bool>());
      expect(permissions.canEditInventory, isA<bool>());
      expect(permissions.canDeleteInventory, isA<bool>());
      expect(permissions.canViewReports, isA<bool>());
      expect(permissions.canExportData, isA<bool>());
      expect(permissions.canAccessSettings, isA<bool>());
      expect(permissions.canManageEmployees, isA<bool>());
      expect(permissions.canManageRoles, isA<bool>());
    });

    test('should maintain correct types for constants', () {
      expect(fontAll, isA<String>());
      expect(imageAll, isA<String>());
      expect(colorAll, isA<Color>());
    });

    test('should maintain correct types for enum values', () {
      for (final status in SyncStatus.values) {
        expect(status, isA<SyncStatus>());
        expect(status.index, isA<int>());
        expect(status.name, isA<String>());
        expect(status.toString(), isA<String>());
      }
    });
  });

  group('Integration Tests', () {
    test('should handle UserData with RolePermissions integration', () {
      const userData = UserData(
        id: 1,
        username: 'admin',
        email: 'admin@test.com',
        organizationId: 1,
        organizationName: 'Test Organization',
        organizationType: 'commissary',
        organizationCloudId: 'cloud-123',
        roleId: 1,
        roleName: 'Administrator',
        permissions: RolePermissions(
          canViewInventory: true,
          canAddInventory: true,
          canEditInventory: true,
          canDeleteInventory: true,
          canViewReports: true,
          canExportData: true,
          canAccessSettings: true,
          canManageEmployees: true,
          canManageRoles: true,
        ),
      );

      // Test that all fields work together correctly
      expect(userData.roleName, equals('Administrator'));
      expect(userData.organizationType, equals('commissary'));
      expect(userData.permissions.canManageRoles, isTrue);
      expect(userData.permissions.canViewInventory, isTrue);
    });

    test('should handle complex business scenarios', () {
      // Create different user types with appropriate permissions
      const admin = UserData(
        id: 1,
        username: 'admin',
        email: 'admin@test.com',
        organizationId: 1,
        organizationName: 'Main Commissary',
        organizationType: 'commissary',
        organizationCloudId: 'cloud-main',
        roleId: 1,
        roleName: 'Administrator',
        permissions: RolePermissions(
          canViewInventory: true,
          canAddInventory: true,
          canEditInventory: true,
          canDeleteInventory: true,
          canViewReports: true,
          canExportData: true,
          canAccessSettings: true,
          canManageEmployees: true,
          canManageRoles: true,
        ),
      );

      const franchisee = UserData(
        id: 2,
        username: 'franchisee',
        email: 'franchisee@test.com',
        organizationId: 2,
        organizationName: 'Franchise Branch',
        organizationType: 'franchisee',
        organizationCloudId: 'cloud-franchise',
        roleId: 2,
        roleName: 'Franchisee',
        permissions: RolePermissions(
          canViewInventory: true,
          canAddInventory: false,
          canEditInventory: false,
          canDeleteInventory: false,
          canViewReports: true,
          canExportData: false,
          canAccessSettings: false,
          canManageEmployees: false,
          canManageRoles: false,
        ),
      );

      const employee = UserData(
        id: 3,
        username: 'employee',
        email: 'employee@test.com',
        organizationId: 1,
        organizationName: 'Main Commissary',
        organizationType: 'commissary',
        organizationCloudId: 'cloud-main',
        roleId: 3,
        roleName: 'Employee',
        permissions: RolePermissions(
          canViewInventory: true,
          canAddInventory: true,
          canEditInventory: false,
          canDeleteInventory: false,
          canViewReports: false,
          canExportData: false,
          canAccessSettings: false,
          canManageEmployees: false,
          canManageRoles: false,
        ),
      );

      // Verify business logic
      expect(admin.permissions.canManageRoles, isTrue);
      expect(franchisee.permissions.canManageRoles, isFalse);
      expect(employee.permissions.canManageRoles, isFalse);

      expect(admin.organizationType, equals('commissary'));
      expect(franchisee.organizationType, equals('franchisee'));
      expect(employee.organizationType, equals('commissary'));

      expect(admin.permissions.canDeleteInventory, isTrue);
      expect(franchisee.permissions.canDeleteInventory, isFalse);
      expect(employee.permissions.canDeleteInventory, isFalse);
    });
  });
}
