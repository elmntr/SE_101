import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chickenjoo_inventory/home/home.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import 'package:chickenjoo_inventory/utils/sync_status.dart';

void main() {
  group('HomeScreen Tests', () {
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
    test('should create HomeScreen with required user', () {
      // Arrange
      final userData = createTestUserData();
      final widget = HomeScreen(signedInUser: userData);

      // Assert
      expect(widget.signedInUser, equals(userData));
    });

    test('should have correct signedInUser data', () {
      // Arrange
      final userData = createTestUserData(
        username: 'admin',
        email: 'admin@example.com',
      );
      final widget = HomeScreen(signedInUser: userData);

      // Assert
      expect(widget.signedInUser.username, equals('admin'));
      expect(widget.signedInUser.email, equals('admin@example.com'));
    });

    test('should identify commissary user type correctly', () {
      // Arrange
      final userData = createTestUserData(organizationType: 'commissary');
      
      // Assert
      expect(userData.isCommissary, isTrue);
      expect(userData.isFranchisee, isFalse);
    });

    test('should identify franchisee user type correctly', () {
      // Arrange
      final userData = createTestUserData(organizationType: 'franchisee');
      
      // Assert
      expect(userData.isCommissary, isFalse);
      expect(userData.isFranchisee, isTrue);
    });

    test('should have permissions from UserData', () {
      // Arrange
      final userData = createTestUserData();
      
      // Assert
      expect(userData.permissions.canViewInventory, isTrue);
      expect(userData.permissions.canAddInventory, isTrue);
      expect(userData.permissions.canDeleteInventory, isFalse);
    });

    test('should have organization info from UserData', () {
      // Arrange
      final userData = createTestUserData(
        organizationId: 2,
        organizationName: 'Test Org',
      );
      
      // Assert
      expect(userData.organizationId, equals(2));
      expect(userData.organizationName, equals('Test Org'));
    });

    test('should have role info from UserData', () {
      // Arrange
      final userData = createTestUserData(
        roleId: 3,
        roleName: 'Manager',
      );
      
      // Assert
      expect(userData.roleId, equals(3));
      expect(userData.roleName, equals('Manager'));
    });

    // Negative Tests (8)
    test('should handle empty username', () {
      // Arrange
      final userData = createTestUserData(username: '');
      
      // Assert
      expect(userData.username, isEmpty);
    });

    test('should handle empty email', () {
      // Arrange
      final userData = createTestUserData(email: '');
      
      // Assert
      expect(userData.email, isEmpty);
    });

    test('should handle null fullName', () {
      // Arrange
      final userData = createTestUserData(fullName: null);
      
      // Assert
      expect(userData.fullName, isNull);
    });

    test('should handle null phone', () {
      // Arrange
      final userData = createTestUserData(phone: null);
      
      // Assert
      expect(userData.phone, isNull);
    });

    test('should handle zero organizationId', () {
      // Arrange
      final userData = createTestUserData(organizationId: 0);
      
      // Assert
      expect(userData.organizationId, equals(0));
    });

    test('should handle zero roleId', () {
      // Arrange
      final userData = createTestUserData(roleId: 0);
      
      // Assert
      expect(userData.roleId, equals(0));
    });

    test('should handle null cloudId', () {
      // Arrange
      final userData = createTestUserData(cloudId: null);
      
      // Assert
      expect(userData.cloudId, isNull);
    });

    test('should handle null authUserId', () {
      // Arrange
      final userData = createTestUserData(authUserId: null);
      
      // Assert
      expect(userData.authUserId, isNull);
    });
  });

  group('SyncStatus Tests', () {
    // Positive Tests
    test('should have correct SyncStatus values', () {
      expect(SyncStatus.idle, isNotNull);
      expect(SyncStatus.syncing, isNotNull);
      expect(SyncStatus.synced, isNotNull);
      expect(SyncStatus.error, isNotNull);
    });

    test('should compare SyncStatus values correctly', () {
      expect(SyncStatus.idle == SyncStatus.idle, isTrue);
      expect(SyncStatus.syncing == SyncStatus.syncing, isTrue);
    });

    // Negative Tests
    test('should differentiate between SyncStatus values', () {
      expect(SyncStatus.idle == SyncStatus.syncing, isFalse);
      expect(SyncStatus.synced == SyncStatus.error, isFalse);
    });
  });
}
