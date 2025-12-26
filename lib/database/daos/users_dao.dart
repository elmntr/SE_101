// lib/database/daos/users_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/users.dart';
import '../tables/roles.dart';
import '../models/user_with_role.dart';
import '../tables/organizations.dart';

part 'users_dao.g.dart';

@DriftAccessor(tables: [Users, Roles, Organizations])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  static const int defaultPageSize = 50;

  // ✅ Get all users with pagination
  Future<List<User>> getAllUsers({
    int? limit,
    int offset = 0,
    bool? isActive,
  }) async {
    try {
      final query = select(users);

      if (isActive != null) {
        query.where((t) => t.isActive.equals(isActive));
      }

      query.orderBy([(t) => OrderingTerm(expression: t.username)]);

      if (limit != null) {
        query.limit(limit, offset: offset);
      }

      return await query.get();
    } catch (e) {
      print('❌ Error fetching users: $e');
      return [];
    }
  }

  /// ✅ Count users
  Future<int> getUserCount({bool? isActive}) async {
    try {
      final query = selectOnly(users)..addColumns([users.id.count()]);

      if (isActive != null) {
        query.where(users.isActive.equals(isActive));
      }

      final result = await query.getSingle();
      return result.read(users.id.count()) ?? 0;
    } catch (e) {
      print('❌ Error counting users: $e');
      return 0;
    }
  }

  /// ✅ Watch users with pagination
  Stream<List<User>> watchAllUsers({
    int limit = defaultPageSize,
    int offset = 0,
  }) {
    try {
      return (select(users)
            ..orderBy([(t) => OrderingTerm(expression: t.username)])
            ..limit(limit, offset: offset))
          .watch();
    } catch (e) {
      print('❌ Error watching users: $e');
      return Stream.value([]);
    }
  }

  /// ✅ Watch users by organization (for branch isolation)
  Stream<List<User>> watchUsersByOrganization(int organizationId) {
    try {
      return (select(users)
        ..where((t) => t.organizationId.equals(organizationId))
        ..where((t) => t.isActive.equals(true))
        ..orderBy([(t) => OrderingTerm(expression: t.username)]))
        .watch();
    } catch (e) {
      print('❌ Error watching users by organization: $e');
      return Stream.value([]);
    }
  }

  /// ✅ FIXED: Insert user with password hashing
  Future<int> insertUser(UsersCompanion user) async {
    try {
      // Hash the password before inserting
      final hashedPassword = user.password.present
          ? hashPassword(user.password.value)
          : throw ArgumentError('Password is required');

      return await into(users).insert(
        user.copyWith(
          password: Value(hashedPassword), // ✅ Store hashed password
          isSynced: Value(false),
        ),
      );
    } catch (e) {
      print('❌ Error inserting user: $e');
      rethrow;
    }
  }

  /// ✅ Batch insert users
  Future<void> insertUsers(List<UsersCompanion> usersList) async {
    try {
      await db.batch((batch) {
        for (final userCompanion in usersList) {
          // Hash each password
          final hashedPassword = userCompanion.password.present
              ? hashPassword(userCompanion.password.value)
              : throw ArgumentError('Password is required');

          batch.insert(
            users,
            userCompanion.copyWith(
              password: Value(hashedPassword),
              isSynced: Value(false),
            ),
          );
        }
      });
    } catch (e) {
      print('❌ Error batch inserting users: $e');
      rethrow;
    }
  }

  /// ✅ Update an existing user
  Future<bool> updateUser(User user) async {
    try {
      final updated = user.copyWith(
        isSynced: false,
        lastUpdated: DateTime.now(),
      );
      return await update(users).replace(updated);
    } catch (e) {
      print('❌ Error updating user: $e');
      return false;
    }
  }

  /// ✅ Update user password
  Future<bool> updateUserPassword(int userId, String hashedPassword) async {
    try {
      final result = await (update(users)..where((t) => t.id.equals(userId)))
        .write(UsersCompanion(
          password: Value(hashedPassword),
          lastUpdated: Value(DateTime.now()),
          isSynced: Value(false),
        ));
      return result > 0;
    } catch (e) {
      print('❌ Error updating password: $e');
      return false;
    }
  }

  /// ✅ Get a single user by ID
  Future<User?> getUserById(int id) async {
    try {
      return await (select(
        users,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching user by ID: $e');
      return null;
    }
  }

  /// ✅ Get user by username
  Future<User?> getUserByUsername(String username) async {
    try {
      return await (select(
        users,
      )..where((t) => t.username.equals(username))).getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching user by username: $e');
      return null;
    }
  }

  /// ✅ Get user by email
  Future<User?> getUserByEmail(String email) async {
    try {
      return await (select(
        users,
      )..where((t) => t.email.equals(email))).getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching user by email: $e');
      return null;
    }
  }

  /// ✅ Get user by email and organization (for offline login)
  Future<User?> getUserByEmailAndOrganization(String email, int organizationId) async {
    try {
      return await (select(users)
        ..where((t) => t.email.equals(email) & t.organizationId.equals(organizationId) & t.isActive.equals(true)))
        .getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching user by email and organization: $e');
      return null;
    }
  }

  /// ✅ Get user by email and organization cloud ID (for offline login with cloud ID)
  Future<User?> getUserByEmailAndOrganizationCloudId(String email, String organizationCloudId) async {
    try {
      // First get the organization by cloud ID
      final org = await (select(db.organizations)
        ..where((t) => t.cloudId.equals(organizationCloudId)))
        .getSingleOrNull();
      
      if (org == null) return null;
      
      return await getUserByEmailAndOrganization(email, org.id);
    } catch (e) {
      print('❌ Error fetching user by email and org cloud ID: $e');
      return null;
    }
  }

  /// ✅ Get users for a specific organization
  Future<List<User>> getUsersByOrganization(
    int organizationId, {
    int? limit,
    int offset = 0,
    bool? isActive,
  }) async {
    try {
      final query = select(users)
        ..where((t) => t.organizationId.equals(organizationId));

      if (isActive != null) {
        query.where((t) => t.isActive.equals(isActive));
      }

      query.orderBy([(t) => OrderingTerm(expression: t.username)]);

      if (limit != null) {
        query.limit(limit, offset: offset);
      }

      return await query.get();
    } catch (e) {
      print('❌ Error fetching users by organization: $e');
      return [];
    }
  }

  /// ✅ PERMANENT DELETE: Hard-delete user from local and mark for cloud deletion
  Future<bool> deleteUserById(int id) async {
    try {
      // Get user to check if it has cloudId
      final user = await getUserById(id);
      if (user == null) {
        print('⚠️ User $id not found');
        return false;
      }

      // If user has cloudId, mark as inactive and unsynced first
      // This signals the sync service to delete from cloud
      if (user.cloudId != null && user.isActive) {
        await (update(users)..where((t) => t.id.equals(id))).write(
          UsersCompanion(
            isActive: Value(false),
            isSynced: Value(false),
            lastUpdated: Value(DateTime.now()),
          ),
        );
        print(
          '📤 User $id marked for cloud deletion (cloudId: ${user.cloudId})',
        );
      }

      // Then permanently delete from local database
      final result = await (delete(users)..where((t) => t.id.equals(id))).go();

      if (result > 0) {
        print('✅ User $id permanently deleted from local database');
      }

      return result > 0;
    } catch (e) {
      print('❌ Error deleting user: $e');
      return false;
    }
  }

  /// ✅ Soft delete user (deactivate)
  Future<bool> deactivateUser(int id) async {
    try {
      final result = await (update(users)..where((t) => t.id.equals(id))).write(
        UsersCompanion(
          isActive: Value(false),
          lastUpdated: Value(DateTime.now()),
          isSynced: Value(false),
        ),
      );
      return result > 0;
    } catch (e) {
      print('❌ Error deactivating user: $e');
      return false;
    }
  }

  // ============================================================================
  // JOIN: USERS WITH ROLES
  // ============================================================================

  /// ✅ Get users with roles (paginated)
  Future<List<UserWithRole>> getUsersWithRoles({
    int? limit,
    int offset = 0,
    bool? isActive,
  }) async {
    try {
      final query = select(
        users,
      ).join([leftOuterJoin(roles, roles.id.equalsExp(users.roleId))]);

      if (isActive != null) {
        query.where(users.isActive.equals(isActive));
      }

      query.orderBy([OrderingTerm(expression: users.username)]);

      if (limit != null) {
        query.limit(limit, offset: offset);
      }

      final results = await query.get();

      return results.map((row) {
        final u = row.readTable(users);
        final r = row.readTableOrNull(roles);
        return UserWithRole(user: u, role: r);
      }).toList();
    } catch (e) {
      print('❌ Error fetching users with roles: $e');
      return [];
    }
  }

  /// ✅ Watch users with roles
  Stream<List<UserWithRole>> watchUsersWithRoles({
    int limit = defaultPageSize,
    int offset = 0,
  }) {
    try {
      final query =
          select(
              users,
            ).join([leftOuterJoin(roles, roles.id.equalsExp(users.roleId))])
            ..orderBy([OrderingTerm(expression: users.username)])
            ..limit(limit, offset: offset);

      return query.watch().map((rows) {
        return rows.map((row) {
          final u = row.readTable(users);
          final r = row.readTableOrNull(roles);
          return UserWithRole(user: u, role: r);
        }).toList();
      });
    } catch (e) {
      print('❌ Error watching users with roles: $e');
      return Stream.value([]);
    }
  }

  // ============================================================================
  // AUTHENTICATION
  // ============================================================================

  Future<User?> authenticate(String email, String password) async {
    try {
      // First find user by email
      final user = await (select(users)
        ..where((u) => u.email.equals(email) & u.isActive.equals(true)))
        .getSingleOrNull();
      
      if (user == null) return null;
      
      // Verify password using the stored hash (with per-user salt)
      if (verifyPassword(password, user.password)) {
        return user;
      }
      return null;
    } catch (e) {
      print('❌ Authentication failed: $e');
      return null;
    }
  }

  /// ✅ Verify password for user by ID
  Future<bool> verifyUserPassword(int userId, String password) async {
    try {
      final user = await getUserById(userId);
      if (user == null) return false;
      
      // Use verifyPassword from app_database.dart (handles salt extraction)
      return verifyPassword(password, user.password);
    } catch (e) {
      print('❌ Password verification failed: $e');
      return false;
    }
  }

  /// ✅ Update user password (always hashes)
  Future<bool> updatePassword(int userId, String newPassword) async {
    try {
      final hashedPassword = hashPassword(newPassword);

      final result = await (update(users)..where((t) => t.id.equals(userId)))
          .write(
            UsersCompanion(
              password: Value(hashedPassword),
              lastUpdated: Value(DateTime.now()),
              isSynced: Value(false),
            ),
          );

      return result > 0;
    } catch (e) {
      print('❌ Error updating password: $e');
      return false;
    }
  }

  /// ✅ Update user password hash directly (for offline login support)
  /// Used when we already have the hashed password
  Future<bool> updatePasswordHash(int userId, String hashedPassword) async {
    try {
      final result = await (update(users)..where((t) => t.id.equals(userId)))
        .write(UsersCompanion(
          password: Value(hashedPassword),
          lastUpdated: Value(DateTime.now()),
          // Don't mark as unsynced - this is just local cache for offline
        ));
      
      return result > 0;
    } catch (e) {
      print('❌ Error updating password hash: $e');
      return false;
    }
  }

  // ============================================================================
  // ROLE ASSIGNMENT
  // ============================================================================

  /// ✅ Update a user's roleId
  Future<bool> assignRoleToUser(int userId, int roleId) async {
    try {
      final result = await (update(users)..where((t) => t.id.equals(userId)))
          .write(
            UsersCompanion(
              roleId: Value(roleId),
              isSynced: Value(false),
              lastUpdated: Value(DateTime.now()),
            ),
          );

      return result > 0;
    } catch (e) {
      print('❌ Error assigning role: $e');
      return false;
    }
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// ✅ Get unsynced users (paginated)
  Future<List<User>> getUnsyncedUsers({int limit = 100, int offset = 0}) async {
    try {
      return await (select(users)
            ..where((t) => t.isSynced.equals(false))
            ..limit(limit, offset: offset))
          .get();
    } catch (e) {
      print('❌ Error fetching unsynced users: $e');
      return [];
    }
  }

  /// ✅ Count unsynced users
  Future<int> getUnsyncedUserCount() async {
    try {
      final query = selectOnly(users)
        ..addColumns([users.id.count()])
        ..where(users.isSynced.equals(false));

      final result = await query.getSingle();
      return result.read(users.id.count()) ?? 0;
    } catch (e) {
      print('❌ Error counting unsynced users: $e');
      return 0;
    }
  }

  /// ✅ Mark users as synced (batch)
  Future<void> markAsSynced(
    List<int> userIds, {
    Map<int, String>? cloudIds,
  }) async {
    try {
      await db.batch((batch) {
        for (final id in userIds) {
          batch.update(
            users,
            UsersCompanion(
              isSynced: Value(true),
              cloudId: Value(cloudIds?[id]),
            ),
            where: (t) => t.id.equals(id),
          );
        }
      });
    } catch (e) {
      print('❌ Error marking users as synced: $e');
      rethrow;
    }
  }

  // /// ✅ Batch upsert from cloud
  /// ✅ FIXED: Batch upsert from cloud with ALL new columns
  Future<void> upsertBatchFromCloud(
    List<Map<String, dynamic>> cloudUsers,
  ) async {
    try {
      await db.transaction(() async {
        for (final cloudUser in cloudUsers) {
          await upsertFromCloud(
            id: cloudUser['local_id'],
            email: cloudUser['email'],
            username: cloudUser['username'],
            password: cloudUser['password'], // Already hashed from cloud
            phone: cloudUser['phone'],
            organizationId: cloudUser['organization_id'], // ✅ NEW - Required
            roleId: cloudUser['role_id'],
            fullName: cloudUser['full_name'], // ✅ NEW - Optional
            isActive: cloudUser['is_active'],
            createdAt: DateTime.parse(cloudUser['created_at']),
            lastUpdated: DateTime.parse(cloudUser['last_updated']),
            cloudId: cloudUser['cloud_id'],
          );
        }
      });
    } catch (e) {
      print('❌ Error batch upserting users from cloud: $e');
      rethrow;
    }
  }

  /// ✅ Upsert from cloud (password is already hashed)
  Future<void> upsertFromCloud({
    required int id,
    required String email,
    required String username,
    required String password,
    String? phone,
    required int organizationId, // ✅ NEW
    required int roleId,
    String? fullName, // ✅ NEW
    required bool isActive,
    required DateTime createdAt,
    required DateTime lastUpdated,
    required String cloudId,
  }) async {
    try {
      await into(users).insertOnConflictUpdate(
        UsersCompanion.insert(
          id: Value(id),
          email: email,
          username: username,
          password: password,
          phone: Value(phone),
          organizationId: organizationId, // ✅ NEW
          roleId: roleId,
          fullName: Value(fullName), // ✅ NEW
          isActive: Value(isActive),
          createdAt: Value(createdAt),
          lastUpdated: Value(lastUpdated),
          isSynced: Value(true),
          cloudId: Value(cloudId),
        ),
      );
    } catch (e) {
      print('❌ Error upserting user from cloud: $e');
      rethrow;
    }
  }

  /// ✅ Get user by cloud ID
  Future<User?> getUserByCloudId(String cloudId) async {
    try {
      return await (select(
        users,
      )..where((t) => t.cloudId.equals(cloudId))).getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching user by cloud ID: $e');
      return null;
    }
  }

  /// ✅ Hash all existing passwords (run once to fix existing data)
  Future<void> hashAllExistingPasswords() async {
    final allUsers = await getAllUsers();
    int hashedCount = 0;

    for (final user in allUsers) {
      // Check if password is already in new format (contains '$' separator)
      // New format: "salt$hash" (32 + 1 + 64 = 97 chars)
      if (!user.password.contains('\$')) {
        final hashed = hashPassword(user.password);
        await (update(users)..where((t) => t.id.equals(user.id))).write(
          UsersCompanion(
            password: Value(hashed),
            isSynced: Value(false), // Mark for re-sync
          ),
        );
        hashedCount++;
      }
    }

    print('✅ Hashed $hashedCount existing passwords');
  }

  /// ✅ Clean up inactive users that are synced (after cloud deletion)
  Future<int> cleanupDeletedUsers() async {
    try {
      final result = await (delete(
        users,
      )..where((t) => t.isActive.equals(false) & t.isSynced.equals(true))).go();

      if (result > 0) {
        print('🧹 Cleaned up $result inactive users from local database');
      }

      return result;
    } catch (e) {
      print('❌ Error cleaning up deleted users: $e');
      return 0;
    }
  }
}
