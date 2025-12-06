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
  Future<int> insertUser(UsersCompanion user) => into(users).insert(user);

  /// Update an existing user.
  /// `replace` updates the row that matches the primary key (id).
  Future<bool> updateUser(User user) => update(users).replace(user);

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
      UsersCompanion(roleId: Value(roleId)),
    );
  }
}
