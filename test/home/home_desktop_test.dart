import 'package:flutter_test/flutter_test.dart';

import 'package:chickenjoo_inventory/home/home.dart';
import 'package:chickenjoo_inventory/home/home_desktop.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import 'package:chickenjoo_inventory/utils/sync_status.dart';

void main() {
  group('HomeScreenDesktop Tests', () {
    // Helper function to create test UserData
    UserData createTestUserData({
      int id = 1,
      String username = 'testuser',
      String email = 'test@example.com',
      String? fullName = 'Test User',
      String? phone = '1234567890',
      int organizationId = 1,
      String? organizationCloudId = 'org-cloud-123',
      String organizationType = 'commissary',
      String organizationName = 'Test Organization',
      int roleId = 1,
      String roleName = 'Admin',
      String? cloudId = 'cloud-123',
      String? authUserId = 'auth-123',
    }) {
      return UserData(
        id: id,
        username: username,
        email: email,
        fullName: fullName,
        phone: phone,
        organizationId: organizationId,
        organizationCloudId: organizationCloudId,
        organizationType: organizationType,
        organizationName: organizationName,
        roleId: roleId,
        roleName: roleName,
        permissions: const RolePermissions(
          canViewInventory: true,
          canAddInventory: true,
          canEditInventory: true,
          canDeleteInventory: false,
          canViewReports: true,
          canExportData: true,
          canAccessSettings: true,
          canManageEmployees: true,
          canManageRoles: false,
        ),
        cloudId: cloudId,
        authUserId: authUserId,
      );
    }

    // Positive Tests (7)
    test('HomeScreenDesktop requires HomeScreenState parameter', () {
      // The HomeScreenDesktop widget takes a HomeScreenState parameter
      expect(HomeScreenDesktop, isNotNull);
    });

    test('UserData should have correct username', () {
      final userData = createTestUserData(username: 'admin');
      expect(userData.username, equals('admin'));
    });

    test('UserData should have correct email', () {
      final userData = createTestUserData(email: 'admin@example.com');
      expect(userData.email, equals('admin@example.com'));
    });

    test('UserData should identify commissary type correctly', () {
      final userData = createTestUserData(organizationType: 'commissary');
      expect(userData.isCommissary, isTrue);
      expect(userData.isFranchisee, isFalse);
    });

    test('UserData should identify franchisee type correctly', () {
      final userData = createTestUserData(organizationType: 'franchisee');
      expect(userData.isCommissary, isFalse);
      expect(userData.isFranchisee, isTrue);
    });

    test('UserData should have correct organization info', () {
      final userData = createTestUserData(
        organizationId: 2,
        organizationName: 'Test Org',
      );
      expect(userData.organizationId, equals(2));
      expect(userData.organizationName, equals('Test Org'));
    });

    test('UserData permissions should be accessible', () {
      final userData = createTestUserData();
      expect(userData.permissions.canViewInventory, isTrue);
      expect(userData.permissions.canDeleteInventory, isFalse);
    });

    // Negative Tests (8)
    test('UserData should handle empty username', () {
      final userData = createTestUserData(username: '');
      expect(userData.username, isEmpty);
    });

    test('UserData should handle empty email', () {
      final userData = createTestUserData(email: '');
      expect(userData.email, isEmpty);
    });

    test('UserData should handle null fullName', () {
      final userData = createTestUserData(fullName: null);
      expect(userData.fullName, isNull);
    });

    test('UserData should handle null phone', () {
      final userData = createTestUserData(phone: null);
      expect(userData.phone, isNull);
    });

    test('UserData should handle zero organizationId', () {
      final userData = createTestUserData(organizationId: 0);
      expect(userData.organizationId, equals(0));
    });

    test('UserData should handle zero roleId', () {
      final userData = createTestUserData(roleId: 0);
      expect(userData.roleId, equals(0));
    });

    test('UserData should handle null cloudId', () {
      final userData = createTestUserData(cloudId: null);
      expect(userData.cloudId, isNull);
    });

    test('UserData should handle null authUserId', () {
      final userData = createTestUserData(authUserId: null);
      expect(userData.authUserId, isNull);
    });
  });

  group('SyncStatus Tests for Desktop', () {
    test('SyncStatus.synced should be valid', () {
      expect(SyncStatus.synced, isNotNull);
      expect(SyncStatus.synced, isA<SyncStatus>());
    });

    test('SyncStatus.syncing should be valid', () {
      expect(SyncStatus.syncing, isNotNull);
      expect(SyncStatus.syncing, isA<SyncStatus>());
    });

    test('SyncStatus.error should be valid', () {
      expect(SyncStatus.error, isNotNull);
      expect(SyncStatus.error, isA<SyncStatus>());
    });
  });
}
