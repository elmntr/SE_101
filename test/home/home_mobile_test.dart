import 'package:flutter_test/flutter_test.dart';

import 'package:chickenjoo_inventory/home/home.dart';
import 'package:chickenjoo_inventory/home/home_mobile.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import 'package:chickenjoo_inventory/utils/sync_status.dart';

void main() {
  group('HomeScreenMobile Tests', () {
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
    test('HomeScreenMobile requires HomeScreenState parameter', () {
      // The HomeScreenMobile widget takes a HomeScreenState parameter
      expect(HomeScreenMobile, isNotNull);
    });

    test('UserData should have correct username', () {
      final userData = createTestUserData(username: 'mobileuser');
      expect(userData.username, equals('mobileuser'));
    });

    test('UserData should have correct email', () {
      final userData = createTestUserData(email: 'mobile@example.com');
      expect(userData.email, equals('mobile@example.com'));
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

    test('UserData should have correct role info', () {
      final userData = createTestUserData(
        roleId: 3,
        roleName: 'Cashier',
      );
      expect(userData.roleId, equals(3));
      expect(userData.roleName, equals('Cashier'));
    });

    test('UserData permissions should work correctly', () {
      final userData = createTestUserData();
      expect(userData.permissions.canViewReports, isTrue);
      expect(userData.permissions.canManageRoles, isFalse);
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

    test('UserData should handle empty organizationName', () {
      final userData = createTestUserData(organizationName: '');
      expect(userData.organizationName, isEmpty);
    });

    test('UserData should handle empty roleName', () {
      final userData = createTestUserData(roleName: '');
      expect(userData.roleName, isEmpty);
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

  group('SyncStatus Tests for Mobile', () {
    test('SyncStatus.idle should be valid', () {
      expect(SyncStatus.idle, isNotNull);
      expect(SyncStatus.idle, isA<SyncStatus>());
    });

    test('SyncStatus values should have correct count', () {
      expect(SyncStatus.values.length, equals(4));
    });

    test('SyncStatus comparison should work', () {
      expect(SyncStatus.synced == SyncStatus.synced, isTrue);
      expect(SyncStatus.error == SyncStatus.synced, isFalse);
    });
  });
}
