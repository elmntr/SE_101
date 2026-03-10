// test/services/sync/auth_bootstrap_identity_test.dart
//
// Task 6.1d – Auth bootstrap identity-mapping regression tests (Task 1.5 fix)
//
// Task 1.5 fixed a critical bug: _pullUserFromCloud was storing the Supabase
// Auth UID (authUser.id) as the local user's cloud_id instead of the value
// from the users table's own `cloud_id` column (userResponse['cloud_id']).
//
// These tests verify at the DAO level that:
//   1. upsertFromCloud stores the users-table cloud_id, not the auth UID.
//   2. getUserByCloudId correctly retrieves users by users.cloud_id.
//   3. A lookup by auth UID (which differs from users.cloud_id) returns null.
//
// Uses an in-memory Drift database — no Supabase network calls.

import 'package:flutter_test/flutter_test.dart';

import 'package:chickenjoo_inventory/database/app_database.dart';

import '../../database/test_database.dart';

void main() {
  group('Auth Bootstrap Identity Mapping (Task 1.5 regression)', () {
    late AppDatabase db;

    // Shared FK prerequisites
    late int orgId;
    late int roleId;

    setUp(() async {
      db = createTestDatabase();

      // Insert a commissary org (required FK for roles and users)
      orgId = await db.organizationsDao.insertOrganization(
        OrganizationsCompanion.insert(
          name: 'Test Commissary',
          type: 'commissary',
        ),
      );

      // Insert a role (required FK for users)
      roleId = await db.rolesDao.insertRole(
        RolesCompanion.insert(name: 'Admin'),
      );
    });

    // ------------------------------------------------------------------ //
    // Core identity separation test

    test(
      'upsertFromCloud stores users.cloud_id, not the Supabase auth UID',
      () async {
        // These two UUIDs represent distinct concepts:
        //   usersCloudId – the UUID in the `cloud_id` column of the users table
        //   authUid       – the UUID that Supabase Auth assigns to the user
        // After Task 1.5, _pullUserFromCloud stores usersCloudId (not authUid).
        const usersCloudId = 'users-table-cloud-uuid-abc123';
        const authUid = 'auth-uid-completely-different-xyz789';

        await db.usersDao.upsertFromCloud(
          id: 0,
          email: 'alice@example.com',
          username: 'alice',
          organizationId: orgId,
          roleId: roleId,
          isActive: true,
          createdAt: DateTime.utc(2024, 1, 1),
          lastUpdated: DateTime.utc(2024, 1, 1),
          cloudId: usersCloudId, // users table cloud_id — NOT auth.id
        );

        // Lookup by the users-table cloud_id must succeed
        final byUsersCloudId = await db.usersDao.getUserByCloudId(usersCloudId);
        expect(byUsersCloudId, isNotNull,
            reason: 'User should be findable by users.cloud_id');
        expect(byUsersCloudId!.cloudId, usersCloudId);
        expect(byUsersCloudId.email, 'alice@example.com');

        // Lookup by the auth UID must fail (they are different UUIDs)
        final byAuthUid = await db.usersDao.getUserByCloudId(authUid);
        expect(byAuthUid, isNull,
            reason:
                'Auth UID is separate from users.cloud_id — must NOT match');
      },
    );

    // ------------------------------------------------------------------ //
    // _findLocalUser Priority 1 scenario:
    // When the stored cloudId happens to equal the auth UID (legacy data or
    // commissary-user edge case), getUserByCloudId still finds the user.

    test(
      'getUserByCloudId finds user when cloudId equals the auth UID (legacy path)',
      () async {
        // In some legacy scenarios the two UUIDs can coincide.
        // Priority-1 lookup in _findLocalUser compares user.cloudId == authUser.id.
        const sharedId = 'same-uuid-for-both-auth-and-users-table';

        await db.usersDao.upsertFromCloud(
          id: 0,
          email: 'bob@example.com',
          username: 'bob',
          organizationId: orgId,
          roleId: roleId,
          isActive: true,
          createdAt: DateTime.utc(2024, 2, 1),
          lastUpdated: DateTime.utc(2024, 2, 1),
          cloudId: sharedId,
        );

        final user = await db.usersDao.getUserByCloudId(sharedId);
        expect(user, isNotNull,
            reason: 'User stored with cloudId == authUid should be found');
        expect(user!.cloudId, sharedId);
      },
    );

    // ------------------------------------------------------------------ //
    // Two users with distinct cloudIds should be independently resolvable.

    test(
      'two users with different cloud_ids are independently resolvable',
      () async {
        const cloudIdA = 'cloud-user-a-uuid';
        const cloudIdB = 'cloud-user-b-uuid';

        await db.usersDao.upsertFromCloud(
          id: 0,
          email: 'userA@example.com',
          username: 'userA',
          organizationId: orgId,
          roleId: roleId,
          isActive: true,
          createdAt: DateTime.utc(2024, 3, 1),
          lastUpdated: DateTime.utc(2024, 3, 1),
          cloudId: cloudIdA,
        );

        await db.usersDao.upsertFromCloud(
          id: 0,
          email: 'userB@example.com',
          username: 'userB',
          organizationId: orgId,
          roleId: roleId,
          isActive: true,
          createdAt: DateTime.utc(2024, 3, 1),
          lastUpdated: DateTime.utc(2024, 3, 1),
          cloudId: cloudIdB,
        );

        final a = await db.usersDao.getUserByCloudId(cloudIdA);
        final b = await db.usersDao.getUserByCloudId(cloudIdB);

        expect(a, isNotNull);
        expect(b, isNotNull);
        expect(a!.email, 'userA@example.com');
        expect(b!.email, 'userB@example.com');
        expect(a.cloudId, cloudIdA);
        expect(b.cloudId, cloudIdB);
      },
    );

    // ------------------------------------------------------------------ //
    // upsertFromCloud called twice (re-pull from cloud) updates cloudId.

    test(
      'second upsertFromCloud call updates cloudId without creating a duplicate user',
      () async {
        const firstCloudId = 'cloud-first-pull-uuid';
        const secondCloudId = 'cloud-second-pull-uuid'; // new UUID on re-pull

        // First pull
        await db.usersDao.upsertFromCloud(
          id: 0,
          email: 'charlie@example.com',
          username: 'charlie',
          organizationId: orgId,
          roleId: roleId,
          isActive: true,
          createdAt: DateTime.utc(2024, 4, 1),
          lastUpdated: DateTime.utc(2024, 4, 1),
          cloudId: firstCloudId,
        );

        // Second pull — same email, updated cloudId
        await db.usersDao.upsertFromCloud(
          id: 0,
          email: 'charlie@example.com',
          username: 'charlie_updated',
          organizationId: orgId,
          roleId: roleId,
          isActive: true,
          createdAt: DateTime.utc(2024, 4, 1),
          lastUpdated: DateTime.utc(2024, 4, 2),
          cloudId: secondCloudId,
        );

        // Only one user with this email should exist
        final allUsers = await db.usersDao.getAllUsers();
        final charlies =
            allUsers.where((u) => u.email == 'charlie@example.com').toList();
        expect(charlies.length, 1,
            reason: 'Re-pull must not create a duplicate user row');

        // cloudId should be updated to the latest value
        expect(charlies.first.cloudId, secondCloudId);

        // Old cloudId no longer resolves this user
        final oldLookup = await db.usersDao.getUserByCloudId(firstCloudId);
        expect(oldLookup, isNull,
            reason: 'Old cloudId should no longer match after update');

        // New cloudId resolves correctly
        final newLookup = await db.usersDao.getUserByCloudId(secondCloudId);
        expect(newLookup, isNotNull);
        expect(newLookup!.username, 'charlie_updated');
      },
    );
  });
}
