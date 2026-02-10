import 'package:flutter_test/flutter_test.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/database/models/user_with_role.dart';

void main() {
  group('UserWithRole', () {
    final now = DateTime.now();

    User _createUser({
      int id = 1,
      String username = 'testuser',
      String email = 'test@example.com',
      String? phone,
      String password = 'pw',
      int organizationId = 1,
      int roleId = 1,
      String? cloudId,
    }) {
      return User(
        id: id,
        username: username,
        email: email,
        phone: phone,
        password: password,
        organizationId: organizationId,
        roleId: roleId,
        isActive: true,
        createdAt: now,
        lastUpdated: now,
        isSynced: false,
        cloudId: cloudId,
      );
    }

    Role _createRole({
      int id = 1,
      String name = 'Admin',
      String? description,
    }) {
      return Role(
        id: id,
        name: name,
        description: description,
        canViewInventory: true,
        canAddInventory: true,
        canEditInventory: true,
        canDeleteInventory: true,
        canViewReports: true,
        canExportData: true,
        canAccessSettings: true,
        canManageEmployees: true,
        canManageRoles: true,
        isSystemRole: false,
        isActive: true,
        createdAt: now,
        lastUpdated: now,
        isSynced: false,
        cloudId: null,
      );
    }

    test('1. should create instance with user and role', () {
      final user = _createUser();
      final role = _createRole();
      final userWithRole = UserWithRole(user: user, role: role);

      expect(userWithRole.user, equals(user));
      expect(userWithRole.role, equals(role));
    });

    test('2. should create instance with null role', () {
      final user = _createUser();
      final userWithRole = UserWithRole(user: user, role: null);

      expect(userWithRole.user, equals(user));
      expect(userWithRole.role, isNull);
    });

    test('3. displayName returns username', () {
      final user = _createUser(username: 'john_doe');
      final userWithRole = UserWithRole(user: user, role: null);

      expect(userWithRole.displayName, equals('john_doe'));
    });

    test('4. displayName works with role present', () {
      final user = _createUser(username: 'admin_user');
      final role = _createRole(name: 'Admin');
      final userWithRole = UserWithRole(user: user, role: role);

      expect(userWithRole.displayName, equals('admin_user'));
    });

    test('5. should expose user email', () {
      final user = _createUser(email: 'john@test.com');
      final userWithRole = UserWithRole(user: user, role: null);

      expect(userWithRole.user.email, equals('john@test.com'));
    });

    test('6. should expose role name', () {
      final user = _createUser();
      final role = _createRole(name: 'Manager');
      final userWithRole = UserWithRole(user: user, role: role);

      expect(userWithRole.role!.name, equals('Manager'));
    });

    test('7. should handle user with empty email', () {
      final user = _createUser(email: '');
      final userWithRole = UserWithRole(user: user, role: null);

      expect(userWithRole.user.email, isEmpty);
    });

    test('8. should handle user with phone number', () {
      final user = _createUser(phone: '+639123456789');
      final userWithRole = UserWithRole(user: user, role: null);

      expect(userWithRole.user.phone, equals('+639123456789'));
    });

    test('9. should handle role with all permissions', () {
      final user = _createUser();
      final role = _createRole();
      final userWithRole = UserWithRole(user: user, role: role);

      expect(userWithRole.role!.canViewInventory, isTrue);
      expect(userWithRole.role!.canManageRoles, isTrue);
      expect(userWithRole.role!.canManageEmployees, isTrue);
    });

    test('10. should preserve user id', () {
      final user = _createUser(id: 42);
      final userWithRole = UserWithRole(user: user, role: null);

      expect(userWithRole.user.id, equals(42));
    });

    test('11. should preserve role id', () {
      final user = _createUser();
      final role = _createRole(id: 5);
      final userWithRole = UserWithRole(user: user, role: role);

      expect(userWithRole.role!.id, equals(5));
    });

    test('12. should handle user with cloudId', () {
      final user = _createUser(cloudId: 'cloud-uuid-123');
      final userWithRole = UserWithRole(user: user, role: null);

      expect(userWithRole.user.cloudId, equals('cloud-uuid-123'));
    });

    test('13. should handle user with organization id', () {
      final user = _createUser(organizationId: 7);
      final userWithRole = UserWithRole(user: user, role: null);

      expect(userWithRole.user.organizationId, equals(7));
    });

    test('14. displayName reflects different usernames', () {
      final user1 = _createUser(username: 'alice');
      final user2 = _createUser(username: 'bob');
      final uwr1 = UserWithRole(user: user1, role: null);
      final uwr2 = UserWithRole(user: user2, role: null);

      expect(uwr1.displayName, equals('alice'));
      expect(uwr2.displayName, equals('bob'));
      expect(uwr1.displayName, isNot(equals(uwr2.displayName)));
    });

    test('15. should handle role with description', () {
      final user = _createUser();
      final role = _createRole(name: 'Cashier', description: 'Handles transactions');
      final userWithRole = UserWithRole(user: user, role: role);

      expect(userWithRole.role!.name, equals('Cashier'));
      expect(userWithRole.role!.description, equals('Handles transactions'));
    });
  });
}
