// test/daos/users_dao_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import '../database/test_database.dart';
import 'package:chickenjoo_inventory/database/daos/users_dao.dart';

void main() {
  late AppDatabase db;
  late UsersDao usersDao;
  late int orgId;
  late int roleId;

  setUp(() async {
    db = createTestDatabase();
    usersDao = db.usersDao;
    final commissaryId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Test Commissary', type: 'commissary'),
    );
    orgId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Test Org', type: 'franchisee', parentCommissaryId: Value(commissaryId)),
    );
    roleId = await db.rolesDao.insertRole(RolesCompanion.insert(name: 'Test Role'));
  });

  tearDown(() async {
    await db.close();
  });

  // Helper to create a user companion
  UsersCompanion _createUser(String username, String email) {
    return UsersCompanion.insert(
      username: username,
      email: email,
      password: 'password123',
      organizationId: orgId,
      roleId: roleId,
    );
  }

  test('1. Insert user successfully hashes password', () async {
    final id = await usersDao.insertUser(_createUser('testuser', 'test@test.com'));
    final user = await usersDao.getUserById(id);
    expect(user, isNotNull);
    expect(user!.username, 'testuser');
    expect(user.password, isNot('password123'));
    expect(user.password.length, 64); // SHA-256 hash length
  });

  test('2. Get all users returns inserted users', () async {
    await usersDao.insertUser(_createUser('user1', 'user1@test.com'));
    await usersDao.insertUser(_createUser('user2', 'user2@test.com'));
    final allUsers = await usersDao.getAllUsers();
    expect(allUsers.length, 2);
  });

  test('3. Update user changes their properties', () async {
    final id = await usersDao.insertUser(_createUser('olduser', 'old@test.com'));
    final user = (await usersDao.getUserById(id))!;
    await usersDao.updateUser(user.copyWith(username: 'newuser'));
    final updated = await usersDao.getUserById(id);
    expect(updated!.username, 'newuser');
  });

  test('4. Deactivate user marks them as inactive', () async {
    final id = await usersDao.insertUser(_createUser('activeuser', 'active@test.com'));
    await usersDao.deactivateUser(id);
    final user = await usersDao.getUserById(id);
    expect(user!.isActive, isFalse);
  });

  test('5. Get all users with isActive=true ignores inactive users', () async {
    await usersDao.insertUser(_createUser('userA', 'a@test.com'));
    final idB = await usersDao.insertUser(_createUser('userB', 'b@test.com'));
    await usersDao.deactivateUser(idB);
    final activeUsers = await usersDao.getAllUsers(isActive: true);
    expect(activeUsers.length, 1);
    expect(activeUsers.first.username, 'userA');
  });

  test('6. Get user by username finds the correct user', () async {
    await usersDao.insertUser(_createUser('findme', 'find@me.com'));
    final user = await usersDao.getUserByUsername('findme');
    expect(user, isNotNull);
    expect(user!.email, 'find@me.com');
  });

  test('7. Get user by email finds the correct user', () async {
    await usersDao.insertUser(_createUser('findme', 'find@me.com'));
    final user = await usersDao.getUserByEmail('find@me.com');
    expect(user, isNotNull);
    expect(user!.username, 'findme');
  });

  test('8. Authenticate user succeeds with correct credentials', () async {
    await usersDao.insertUser(_createUser('authuser', 'auth@test.com'));
    final user = await usersDao.authenticate('auth@test.com', 'password123');
    expect(user, isNotNull);
    expect(user!.username, 'authuser');
  });

  test('9. Authenticate user fails with incorrect password', () async {
    await usersDao.insertUser(_createUser('authuser', 'auth@test.com'));
    final user = await usersDao.authenticate('auth@test.com', 'wrongpassword');
    expect(user, isNull);
  });

  test('10. Authenticate user fails for inactive user', () async {
    final id = await usersDao.insertUser(_createUser('authuser', 'auth@test.com'));
    await usersDao.deactivateUser(id);
    final user = await usersDao.authenticate('auth@test.com', 'password123');
    expect(user, isNull);
  });

  test('11. Update password changes the stored hash', () async {
    final id = await usersDao.insertUser(_createUser('pwchange', 'pw@change.com'));
    final oldUser = (await usersDao.getUserById(id))!;
    await usersDao.updatePassword(id, 'newpassword');
    final newUser = (await usersDao.getUserById(id))!;
    expect(newUser.password, isNot(oldUser.password));
    // Verify with new password
    final authenticated = await usersDao.authenticate('pw@change.com', 'newpassword');
    expect(authenticated, isNotNull);
  });

  test('12. Get users with roles includes role data', () async {
    await usersDao.insertUser(_createUser('userwithrole', 'role@test.com'));
    final usersWithRoles = await usersDao.getUsersWithRoles();
    expect(usersWithRoles.length, 1);
    expect(usersWithRoles.first.role, isNotNull);
    expect(usersWithRoles.first.role!.name, 'Test Role');
  });

  test('13. Assign role to user updates the user record', () async {
    final newRoleId = await db.rolesDao.insertRole(RolesCompanion.insert(name: 'New Role'));
    final userId = await usersDao.insertUser(_createUser('assignrole', 'assign@role.com'));
    await usersDao.assignRoleToUser(userId, newRoleId);
    final user = await usersDao.getUserById(userId);
    expect(user!.roleId, newRoleId);
  });

  test('14. Delete user permanently removes them', () async {
    final id = await usersDao.insertUser(_createUser('todelete', 'delete@me.com'));
    await usersDao.deleteUserById(id);
    final user = await usersDao.getUserById(id);
    expect(user, isNull);
  });

  test('15. Get user count works with filters', () async {
    await usersDao.insertUser(_createUser('userA', 'a@test.com'));
    final idB = await usersDao.insertUser(_createUser('userB', 'b@test.com'));
    await usersDao.deactivateUser(idB);
    final count = await usersDao.getUserCount(isActive: true);
    expect(count, 1);
  });

  test('16. Get unsynced user count is correct', () async {
    final id1 = await usersDao.insertUser(_createUser('user1', 'user1@test.com'));
    final id2 = await usersDao.insertUser(_createUser('user2', 'user2@test.com'));
    await usersDao.markAsSynced([id1]);
    final count = await usersDao.getUnsyncedUserCount();
    expect(count, 1);
    final unsynced = await usersDao.getUnsyncedUsers();
    expect(unsynced.first.id, id2);
  });
}
