// lib/database/daos/users_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/users.dart';
import '../tables/roles.dart';

part 'users_dao.g.dart';

@DriftAccessor(tables: [Users, Roles])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(AppDatabase db) : super(db);

  Future<List<User>> getAllUsers() => select(users).get();
  Stream<List<User>> watchAllUsers() => select(users).watch();

  Future<int> insertUser(UsersCompanion user) => into(users).insert(user);

  Future<bool> updateUser(User user) => update(users).replace(user);

  Future<int> deleteUserById(int id) => (delete(users)..where((t) => t.id.equals(id))).go();

  // Example join helper retained from your project intent: get users with their role
  Future<List<UserWithRole>> getUsersWithRoles() async {
    final query = select(users).join([
      leftOuterJoin(roles, roles.id.equalsExp(users.roleId)),
    ]);

    final results = await query.get();
    return results.map((row) {
      final u = row.readTable(users);
      final r = row.readTableOrNull(roles);
      return UserWithRole(user: u, role: r);
    }).toList();
  }
  // ✅ NEW: authenticate method
  Future<User?> authenticate(String email, String password) {
    return (select(users)
          ..where((u) => u.email.equals(email) & u.password.equals(password)))
        .getSingleOrNull();
  }
  Future<int> assignRoleToUser(int userId, int roleId) {
  return (update(users)..where((tbl) => tbl.id.equals(userId))).write(
    UsersCompanion(roleId: Value(roleId)),
  );
}

}
