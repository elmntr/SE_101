// lib/database/daos/users_dao.dart

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/users.dart';
import '../tables/roles.dart';
import '../models/user_with_role.dart';  

part 'users_dao.g.dart';

/// Data Access Object (DAO) for the `Users` table.
/// This class provides all operations for querying, inserting,
/// updating, deleting, and joining users with roles.
@DriftAccessor(tables: [Users, Roles])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  /// Constructor that provides this DAO access to the main AppDatabase instance.
  UsersDao(AppDatabase db) : super(db);

  // ---------------------------------------------------------------------------
  // BASIC CRUD OPERATIONS
  // ---------------------------------------------------------------------------

  /// Fetch all users (one-time read).
  Future<List<User>> getAllUsers() => select(users).get();

  /// Watch the users table and automatically update UI on changes.
  Stream<List<User>> watchAllUsers() => select(users).watch();

  /// Insert a new user.
  /// Drift requires a Companion class for inserts.
  /// ✅ UPDATED: Insert user - marks as unsynced
  Future<int> insertUser(UsersCompanion user) {
    return into(users).insert(
      user.copyWith(
        isSynced: Value(false),
      ),
    );
  }

  /// Update an existing user.
  /// `replace` updates the row that matches the primary key (id).
  /// ✅ UPDATED: Update user - marks as unsynced
  Future<bool> updateUser(User user) async {
    final updated = user.copyWith(
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
    return update(users).replace(updated);
  }

/// Get a single user by ID
  Future<User?> getUserById(int id) async {
    final query = select(users)..where((tbl) => tbl.id.equals(id));
    return query.getSingleOrNull(); // Returns null if not found
  }

  /// Delete a user by its ID.
  Future<int> deleteUserById(int id) =>
      (delete(users)..where((t) => t.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // JOIN: USERS WITH ROLES
  // ---------------------------------------------------------------------------

  /// Returns a list of users together with their associated role.
  ///
  /// This uses a LEFT OUTER JOIN because a user *may not have* a role.
  /// If the roleId is null or invalid, `role` will be null.
  Future<List<UserWithRole>> getUsersWithRoles() async {
    final query = select(users).join([
      leftOuterJoin(
        roles,
        roles.id.equalsExp(users.roleId),
      ),
    ]);

    final results = await query.get();

    return results.map((row) {
      final u = row.readTable(users);          // Parse user row
      final r = row.readTableOrNull(roles);    // Parse role row (nullable)
      return UserWithRole(user: u, role: r);
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // AUTHENTICATION
  // ---------------------------------------------------------------------------

  /// Validate user login by matching email + password.
  /// Returns `User` object if credentials are correct, otherwise null.
  ///
  /// In a real production system:
  /// - passwords should be hashed
  /// - comparisons should be secure
  Future<User?> authenticate(String email, String password) {
    return (select(users)
          ..where((u) =>
              u.email.equals(email) &
              u.password.equals(password)))
        .getSingleOrNull();
  }

  // ---------------------------------------------------------------------------
  // ROLE ASSIGNMENT
  // ---------------------------------------------------------------------------

  /// Update a user's `roleId` (assign or change a role).
  /// Only writes to the `roleId` column.
  Future<int> assignRoleToUser(int userId, int roleId) {
    return (update(users)..where((tbl) => tbl.id.equals(userId))).write(
      UsersCompanion(
        roleId: Value(roleId),
        isSynced: Value(false),
        lastUpdated: Value(DateTime.now()),
      ),
    );
  }

  /// ✅ NEW: Get unsynced users for sync service
  Future<List<User>> getUnsyncedUsers() async {
    return await (select(users)
      ..where((t) => t.isSynced.equals(false)))
      .get();
  }

  /// ✅ NEW: Mark user as synced
  Future<int> markAsSynced(int userId, {String? cloudId}) async {
    return (update(users)..where((t) => t.id.equals(userId))).write(
      UsersCompanion(
        isSynced: Value(true),
        cloudId: Value(cloudId),
      ),
    );
  }

  /// ✅ NEW: Upsert from cloud (used during sync pull)
  Future<void> upsertFromCloud({
    required int id,
    required String email,
    required String username,
    required String password,
    String? phone,
    required int roleId,
    required bool isActive,
    required DateTime createdAt,
    required DateTime lastUpdated,
    required String cloudId,
  }) async {
    final existing = await (select(users)..where((t) => t.id.equals(id)))
        .getSingleOrNull();

    if (existing == null) {
      // Insert new from cloud
      await into(users).insert(
        UsersCompanion.insert(
          id: Value(id),
          email: email,
          username: username,
          password: password,
          phone: Value(phone),
          roleId: roleId,
          isActive: Value(isActive),
          createdAt: Value(createdAt),
          lastUpdated: Value(lastUpdated),
          isSynced: Value(true),
          cloudId: Value(cloudId),
        ),
      );
    } else {
      // Update existing from cloud
      await (update(users)..where((t) => t.id.equals(id))).write(
        UsersCompanion(
          email: Value(email),
          username: Value(username),
          password: Value(password),
          phone: Value(phone),
          roleId: Value(roleId),
          isActive: Value(isActive),
          lastUpdated: Value(lastUpdated),
          isSynced: Value(true),
          cloudId: Value(cloudId),
        ),
      );
    }
  }

  /// ✅ NEW: Get user by cloud ID
  Future<User?> getUserByCloudId(String cloudId) async {
    return (select(users)..where((t) => t.cloudId.equals(cloudId)))
        .getSingleOrNull();
  }

  /// ✅ NEW: Get user by email (useful for sync)
  Future<User?> getUserByEmail(String email) async {
    return (select(users)..where((t) => t.email.equals(email)))
        .getSingleOrNull();
  }
}
