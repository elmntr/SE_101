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
  Future<int> insertRole(RolesCompanion role) {
    return into(roles).insert(
      role.copyWith(
        isSynced: Value(false),
      ),
    );
  }

  /// Update an existing role.
  /// Drift automatically matches by primary key (id) when replacing.
  Future<bool> updateRole(Role role) async {
    final updated = role.copyWith(
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
    return update(roles).replace(updated);
  }

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

  /// ✅ NEW: Get unsynced roles for sync service
  Future<List<Role>> getUnsyncedRoles() async {
    return await (select(roles)
      ..where((t) => t.isSynced.equals(false)))
      .get();
  }

  /// ✅ NEW: Mark role as synced
  Future<int> markAsSynced(int roleId, {String? cloudId}) async {
    return (update(roles)..where((t) => t.id.equals(roleId))).write(
      RolesCompanion(
        isSynced: Value(true),
        cloudId: Value(cloudId),
      ),
    );
  }

  /// ✅ NEW: Upsert from cloud (used during sync pull)
  Future<void> upsertFromCloud({
    required int id,
    required String name,
    String? description,
    required bool canViewInventory,
    required bool canAddInventory,
    required bool canEditInventory,
    required bool canDeleteInventory,
    required bool canViewReports,
    required bool canExportData,
    required bool canAccessSettings,
    required bool canManageEmployees,
    required bool canManageRoles,
    required bool isSystemRole,
    required bool isActive,
    required DateTime createdAt,
    required DateTime lastUpdated,
    required String cloudId,
  }) async {
    final existing = await (select(roles)..where((t) => t.id.equals(id)))
        .getSingleOrNull();

    if (existing == null) {
      // Insert new from cloud
      await into(roles).insert(
        RolesCompanion.insert(
          id: Value(id),
          name: name,
          description: Value(description),
          canViewInventory: Value(canViewInventory),
          canAddInventory: Value(canAddInventory),
          canEditInventory: Value(canEditInventory),
          canDeleteInventory: Value(canDeleteInventory),
          canViewReports: Value(canViewReports),
          canExportData: Value(canExportData),
          canAccessSettings: Value(canAccessSettings),
          canManageEmployees: Value(canManageEmployees),
          canManageRoles: Value(canManageRoles),
          isSystemRole: Value(isSystemRole),
          isActive: Value(isActive),
          createdAt: Value(createdAt),
          lastUpdated: Value(lastUpdated),
          isSynced: Value(true),
          cloudId: Value(cloudId),
        ),
      );
    } else {
      // Update existing from cloud
      await (update(roles)..where((t) => t.id.equals(id))).write(
        RolesCompanion(
          name: Value(name),
          description: Value(description),
          canViewInventory: Value(canViewInventory),
          canAddInventory: Value(canAddInventory),
          canEditInventory: Value(canEditInventory),
          canDeleteInventory: Value(canDeleteInventory),
          canViewReports: Value(canViewReports),
          canExportData: Value(canExportData),
          canAccessSettings: Value(canAccessSettings),
          canManageEmployees: Value(canManageEmployees),
          canManageRoles: Value(canManageRoles),
          isSystemRole: Value(isSystemRole),
          isActive: Value(isActive),
          lastUpdated: Value(lastUpdated),
          isSynced: Value(true),
          cloudId: Value(cloudId),
        ),
      );
    }
  }

  /// ✅ NEW: Get role by cloud ID
  Future<Role?> getRoleByCloudId(String cloudId) async {
    return (select(roles)..where((t) => t.cloudId.equals(cloudId)))
        .getSingleOrNull();
  }
}
