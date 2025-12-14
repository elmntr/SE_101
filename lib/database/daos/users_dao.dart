// lib/database/daos/users_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/users.dart';
import '../tables/roles.dart';
import '../models/user_with_role.dart';


part 'users_dao.g.dart';

@DriftAccessor(tables: [Users, Roles])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(AppDatabase db) : super(db);

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
      final query = selectOnly(users)
        ..addColumns([users.id.count()]);
      
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

  Future<int> insertUser(UsersCompanion user) async {
    try {
      return await into(users).insert(
        user.copyWith(
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
        batch.insertAll(users, usersList);
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

  /// ✅ Get a single user by ID
  Future<User?> getUserById(int id) async {
    try {
      return await (select(users)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching user by ID: $e');
      return null;
    }
  }

  /// ✅ Get user by username
  Future<User?> getUserByUsername(String username) async {
    try {
      return await (select(users)..where((t) => t.username.equals(username)))
        .getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching user by username: $e');
      return null;
    }
  }

  /// ✅ Get user by email
  Future<User?> getUserByEmail(String email) async {
    try {
      return await (select(users)..where((t) => t.email.equals(email)))
        .getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching user by email: $e');
      return null;
    }
  }

  /// ✅ Delete a user by its ID
  Future<bool> deleteUserById(int id) async {
    try {
      final result = await (delete(users)..where((t) => t.id.equals(id))).go();
      return result > 0;
    } catch (e) {
      print('❌ Error deleting user: $e');
      return false;
    }
  }

  /// ✅ Soft delete user (deactivate)
  Future<bool> deactivateUser(int id) async {
    try {
      final result = await (update(users)..where((t) => t.id.equals(id)))
        .write(UsersCompanion(
          isActive: Value(false),
          lastUpdated: Value(DateTime.now()),
          isSynced: Value(false),
        ));
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
      final query = select(users).join([
        leftOuterJoin(roles, roles.id.equalsExp(users.roleId)),
      ]);

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
      final query = select(users).join([
        leftOuterJoin(roles, roles.id.equalsExp(users.roleId)),
      ])
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
      // Import the hash function from app_database.dart
      final hashedPassword = hashPassword(password);
      
      return await (select(users)
        ..where((u) =>
          u.email.equals(email) &
          u.password.equals(hashedPassword) &
          u.isActive.equals(true)))
        .getSingleOrNull();
    } catch (e) {
      print('❌ Authentication failed: $e');
      return null;
    }
  }


  /// ✅ Verify password for user
  Future<bool> verifyPassword(int userId, String password) async {
    try {
      final user = await getUserById(userId);
      if (user == null) return false;
      
      final hashedPassword = hashPassword(password);
      return user.password == hashedPassword;
    } catch (e) {
      print('❌ Password verification failed: $e');
      return false;
    }
  }

  /// ✅ Update user password
  Future<bool> updatePassword(int userId, String newPassword) async {
    try {
      final hashedPassword = hashPassword(newPassword);
      
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

  // ============================================================================
  // ROLE ASSIGNMENT
  // ============================================================================

  /// ✅ Update a user's roleId
  Future<bool> assignRoleToUser(int userId, int roleId) async {
    try {
      final result = await (update(users)..where((t) => t.id.equals(userId)))
        .write(UsersCompanion(
          roleId: Value(roleId),
          isSynced: Value(false),
          lastUpdated: Value(DateTime.now()),
        ));
      
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
  Future<List<User>> getUnsyncedUsers({
    int limit = 100,
    int offset = 0,
  }) async {
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
  Future<void> markAsSynced(List<int> userIds, {Map<int, String>? cloudIds}) async {
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

  /// ✅ Batch upsert from cloud
  Future<void> upsertBatchFromCloud(List<Map<String, dynamic>> cloudUsers) async {
    try {
      await db.transaction(() async {
        for (final cloudUser in cloudUsers) {
          await upsertFromCloud(
            id: cloudUser['local_id'],
            email: cloudUser['email'],
            username: cloudUser['username'],
            password: cloudUser['password'],
            phone: cloudUser['phone'],
            roleId: cloudUser['role_id'],
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

  Future<void> upsertFromCloud({
  required int id,
  required String email,
  required String username,
  required String password, // already hashed
  String? phone,
  required int roleId,
  required bool isActive,
  required DateTime createdAt,
  required DateTime lastUpdated,
  required String cloudId,
}) async {
  try {
    // Use password as-is; do NOT hash
    await into(users).insertOnConflictUpdate(
      UsersCompanion.insert(
        id: Value(id),
        email: email,
        username: username,
        password: password, // ⬅️ do not hash
        phone: Value(phone),
        roleId: roleId,
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
      return await (select(users)..where((t) => t.cloudId.equals(cloudId)))
        .getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching user by cloud ID: $e');
      return null;
    }
  }

  Future<void> hashAllExistingPasswords() async {
  final allUsers = await getAllUsers();
  for (final user in allUsers) {
    final hashed = hashPassword(user.password);
    if (user.password != hashed) {
      await updatePassword(user.id, user.password); // uses existing updatePassword
    }
  }
  print('✅ All existing passwords hashed.');
}

  
}