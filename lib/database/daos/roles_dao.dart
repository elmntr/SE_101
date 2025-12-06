// lib/database/daos/roles_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/roles.dart';

part 'roles_dao.g.dart';

/// DAO (Data Access Object) for the Roles table.
/// This class provides clean, reusable, and testable database operations.
@DriftAccessor(tables: [Roles])
class RolesDao extends DatabaseAccessor<AppDatabase> with _$RolesDaoMixin {
  /// Constructor that gives this DAO access to the main AppDatabase instance.
  RolesDao(AppDatabase db) : super(db);

  /// Fetch all roles from the database (one-time read).
  Future<List<Role>> getAllRoles() => select(roles).get();

  /// Listen to changes in the roles table.
  /// UI will rebuild automatically when data changes.
  Stream<List<Role>> watchAllRoles() => select(roles).watch();

  /// Insert a new role into the database.
  /// Uses RolesCompanion because Drift requires Companions for inserts.
  Future<int> insertRole(RolesCompanion role) => into(roles).insert(role);

  /// Update an existing role.
  /// Drift automatically matches by primary key (id) when replacing.
  Future<bool> updateRole(Role role) => update(roles).replace(role);

  /// Delete a role based on its ID.
  Future<int> deleteRoleById(int id) =>
      (delete(roles)..where((t) => t.id.equals(id))).go();

  /// Find a role by its name (e.g., "admin", "user").
  /// Returns null if no role matches.
  Future<Role?> getRoleByName(String roleName) async {
    return (select(roles)..where((r) => r.name.equals(roleName)))
        .getSingleOrNull();
  }

  /// Find a role using its numeric ID.
  Future<Role?> getRoleById(int id) {
    return (select(roles)..where((r) => r.id.equals(id))).getSingleOrNull();
  }
}
