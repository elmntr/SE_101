// lib/database/daos/roles_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/roles.dart';

part 'roles_dao.g.dart';

@DriftAccessor(tables: [Roles])
class RolesDao extends DatabaseAccessor<AppDatabase> with _$RolesDaoMixin {
  RolesDao(AppDatabase db) : super(db);

  Future<List<Role>> getAllRoles() => select(roles).get();
  Stream<List<Role>> watchAllRoles() => select(roles).watch();

  Future<int> insertRole(RolesCompanion role) => into(roles).insert(role);

  Future<bool> updateRole(Role role) => update(roles).replace(role);

  Future<int> deleteRoleById(int id) =>
      (delete(roles)..where((t) => t.id.equals(id))).go();
}
