// test/daos/roles_dao_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import '../database/test_database.dart';
import 'package:chickenjoo_inventory/database/daos/roles_dao.dart';

void main() {
  late AppDatabase db;
  late RolesDao rolesDao;

  setUp(() {
    db = createTestDatabase();
    rolesDao = db.rolesDao;
  });

  tearDown(() async {
    await db.close();
  });

  test('1. Insert role successfully', () async {
    final id = await rolesDao.insertRole(
      RolesCompanion.insert(name: 'Cashier'),
    );
    final role = await rolesDao.getRoleById(id);
    expect(role, isNotNull);
    expect(role!.name, 'Cashier');
  });

  test('2. Get all roles returns inserted roles', () async {
    await rolesDao.insertRole(RolesCompanion.insert(name: 'Manager'));
    await rolesDao.insertRole(RolesCompanion.insert(name: 'Staff'));
    final allRoles = await rolesDao.getAllRoles();
    expect(allRoles.length, 2);
  });

  test('3. Update role changes its properties', () async {
    final id = await rolesDao.insertRole(
      RolesCompanion.insert(name: 'Old Name'),
    );
    final role = (await rolesDao.getRoleById(id))!;
    await rolesDao.updateRole(
      role.copyWith(name: 'New Name', canViewReports: true),
    );
    final updated = await rolesDao.getRoleById(id);
    expect(updated!.name, 'New Name');
    expect(updated.canViewReports, isTrue);
  });

  test('4. Deactivate role marks it as inactive', () async {
    final id = await rolesDao.insertRole(
      RolesCompanion.insert(name: 'To Deactivate'),
    );
    await rolesDao.deactivateRole(id);
    final role = await rolesDao.getRoleById(id);
    expect(role!.isActive, isFalse);
  });

  test('5. Get all roles with isActive=true ignores inactive roles', () async {
    await rolesDao.insertRole(RolesCompanion.insert(name: 'Active'));
    final idToDeactivate = await rolesDao.insertRole(
      RolesCompanion.insert(name: 'Inactive'),
    );
    await rolesDao.deactivateRole(idToDeactivate);
    final roles = await rolesDao.getAllRoles(isActive: true);
    expect(roles.length, 1);
    expect(roles.first.name, 'Active');
  });

  test('6. Delete role fails if it is in use', () async {
    final roleId = await rolesDao.insertRole(
      RolesCompanion.insert(name: 'In Use'),
    );
    final commissaryId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Commissary', type: 'commissary'),
    );
    final orgId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Org',
        type: 'franchisee',
        parentCommissaryId: Value(commissaryId),
      ),
    );
    await db.usersDao.insertUser(
      UsersCompanion.insert(
        username: 'test',
        email: 'a@b.c',
        password: 'pw',
        organizationId: orgId,
        roleId: roleId,
      ),
    );

    expect(() => rolesDao.deleteRoleById(roleId), throwsException);
  });

  test('7. Delete role fails for system roles', () async {
    final roleId = await rolesDao.insertRole(
      RolesCompanion.insert(name: 'System Role', isSystemRole: Value(true)),
    );
    expect(() => rolesDao.deleteRoleById(roleId), throwsException);
  });

  test('8. Delete role succeeds for unused, non-system role', () async {
    final roleId = await rolesDao.insertRole(
      RolesCompanion.insert(name: 'Unused'),
    );
    final success = await rolesDao.deleteRoleById(roleId);
    expect(success, isTrue);
    final role = await rolesDao.getRoleById(roleId);
    expect(role, isNull);
  });

  test('9. Get role by name finds the correct role', () async {
    await rolesDao.insertRole(RolesCompanion.insert(name: 'FindMe'));
    final role = await rolesDao.getRoleByName('FindMe');
    expect(role, isNotNull);
    expect(role!.name, 'FindMe');
  });

  test('10. Get system roles returns only system roles', () async {
    await rolesDao.insertRole(
      RolesCompanion.insert(name: 'System', isSystemRole: Value(true)),
    );
    await rolesDao.insertRole(RolesCompanion.insert(name: 'Custom'));
    final systemRoles = await rolesDao.getSystemRoles();
    expect(systemRoles.length, 1);
    expect(systemRoles.first.name, 'System');
  });

  test('11. Get custom roles returns only non-system roles', () async {
    await rolesDao.insertRole(
      RolesCompanion.insert(name: 'System', isSystemRole: Value(true)),
    );
    await rolesDao.insertRole(RolesCompanion.insert(name: 'Custom'));
    final customRoles = await rolesDao.getCustomRoles();
    expect(customRoles.length, 1);
    expect(customRoles.first.name, 'Custom');
  });

  test('12. Get roles with permission filters correctly', () async {
    await rolesDao.insertRole(
      RolesCompanion.insert(name: 'Viewer', canViewInventory: Value(true)),
    );
    await rolesDao.insertRole(
      RolesCompanion.insert(name: 'Editor', canEditInventory: Value(true)),
    );
    await rolesDao.insertRole(RolesCompanion.insert(name: 'NoPerms'));

    final viewers = await rolesDao.getRolesWithPermission('view_inventory');
    expect(viewers.length, 1);
    expect(viewers.first.name, 'Viewer');
  });

  test('13. Get role count works with filters', () async {
    await rolesDao.insertRole(RolesCompanion.insert(name: 'RoleA'));
    final id = await rolesDao.insertRole(RolesCompanion.insert(name: 'RoleB'));
    await rolesDao.deactivateRole(id);

    final count = await rolesDao.getRoleCount(isActive: true);
    expect(count, 1);
  });

  test('14. Batch insert adds multiple roles', () async {
    final companions = [
      RolesCompanion.insert(name: 'Batch 1'),
      RolesCompanion.insert(name: 'Batch 2'),
    ];
    await rolesDao.insertRoles(companions);
    final count = await rolesDao.getRoleCount();
    expect(count, 2);
  });

  test('15. Get unsynced count is correct', () async {
    final id1 = await rolesDao.insertRole(RolesCompanion.insert(name: 'RoleA'));
    await rolesDao.insertRole(RolesCompanion.insert(name: 'RoleB'));
    await rolesDao.markAsSynced([id1]);

    final count = await rolesDao.getUnsyncedRoleCount();
    expect(count, 1);
  });
}
