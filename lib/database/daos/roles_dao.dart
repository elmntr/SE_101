// lib/database/daos/roles_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/roles.dart';

part 'roles_dao.g.dart';

@DriftAccessor(tables: [Roles])
class RolesDao extends DatabaseAccessor<AppDatabase> with _$RolesDaoMixin {
  RolesDao(super.db);

  static const int defaultPageSize = 50;

  // ============================================================================
  // BASIC CRUD OPERATIONS
  // ============================================================================

  /// ✅ Fetch all roles with pagination
  Future<List<Role>> getAllRoles({
    int? limit,
    int offset = 0,
    bool? isActive,
  }) async {
    try {
      final query = select(roles);

      if (isActive != null) {
        query.where((t) => t.isActive.equals(isActive));
      }

      query.orderBy([(t) => OrderingTerm(expression: t.name)]);

      if (limit != null) {
        query.limit(limit, offset: offset);
      }

      return await query.get();
    } catch (e) {
      //print('❌ Error fetching roles: $e');
      return [];
    }
  }

  /// ✅ Count total roles
  Future<int> getRoleCount({bool? isActive}) async {
    try {
      final query = selectOnly(roles)..addColumns([roles.id.count()]);

      if (isActive != null) {
        query.where(roles.isActive.equals(isActive));
      }

      final result = await query.getSingle();
      return result.read(roles.id.count()) ?? 0;
    } catch (e) {
      //print('❌ Error counting roles: $e');
      return 0;
    }
  }

  /// ✅ Watch roles with pagination
  Stream<List<Role>> watchAllRoles({
    int limit = defaultPageSize,
    int offset = 0,
  }) {
    try {
      return (select(roles)
            ..orderBy([(t) => OrderingTerm(expression: t.name)])
            ..limit(limit, offset: offset))
          .watch();
    } catch (e) {
      //print('❌ Error watching roles: $e');
      return Stream.value([]);
    }
  }

  /// ✅ Insert a new role
  Future<int> insertRole(RolesCompanion role) async {
    try {
      return await into(roles).insert(role.copyWith(isSynced: Value(false)));
    } catch (e) {
      //print('❌ Error inserting role: $e');
      rethrow;
    }
  }

  /// ✅ Batch insert roles
  Future<void> insertRoles(List<RolesCompanion> rolesList) async {
    try {
      await db.batch((batch) {
        batch.insertAll(roles, rolesList);
      });
    } catch (e) {
      //print('❌ Error batch inserting roles: $e');
      rethrow;
    }
  }

  /// ✅ Update an existing role
  Future<bool> updateRole(Role role) async {
    try {
      final updated = role.copyWith(
        isSynced: false,
        lastUpdated: DateTime.now().toUtc(),
      );
      return await update(roles).replace(updated);
    } catch (e) {
      //print('❌ Error updating role: $e');
      return false;
    }
  }

  /// ✅ PERMANENT DELETE: Delete a role by ID from local and mark for cloud deletion
  Future<bool> deleteRoleById(int id) async {
    try {
      // Check if role is in use
      final usageCount = await _getRoleUsageCount(id);
      if (usageCount > 0) {
        //print('⚠️ Cannot delete role $id: used by $usageCount users');
        throw Exception('Role is currently assigned to $usageCount user(s)');
      }

      // Get role to check if it has cloudId
      final role = await getRoleById(id);
      if (role == null) {
        //print('⚠️ Role $id not found');
        return false;
      }

      // Check if it's a system role
      if (role.isSystemRole) {
        //print('⚠️ Cannot delete system role $id');
        throw Exception('System roles cannot be deleted');
      }

      // If role has cloudId, mark as inactive and unsynced first
      // This signals the sync service to delete from cloud
      if (role.cloudId != null && role.isActive) {
        await (update(roles)..where((t) => t.id.equals(id))).write(
          RolesCompanion(
            isActive: Value(false),
            isSynced: Value(false),
            lastUpdated: Value(DateTime.now().toUtc()),
          ),
        );
        //print(
        //  '📤 Role $id marked for cloud deletion (cloudId: ${role.cloudId})'
        //);
      }

      // Then permanently delete from local database
      final result = await (delete(roles)..where((t) => t.id.equals(id))).go();

      if (result > 0) {
        //print('✅ Role $id permanently deleted from local database');
      }

      return result > 0;
    } catch (e) {
      //print('❌ Error deleting role: $e');
      rethrow;
    }
  }

  /// ✅ Soft delete (deactivate) a role
  Future<bool> deactivateRole(int id) async {
    try {
      final result = await (update(roles)..where((t) => t.id.equals(id))).write(
        RolesCompanion(
          isActive: Value(false),
          lastUpdated: Value(DateTime.now().toUtc()),
          isSynced: Value(false),
        ),
      );
      return result > 0;
    } catch (e) {
      //print('❌ Error deactivating role: $e');
      return false;
    }
  }

  /// ✅ Check how many users are using this role
  Future<int> _getRoleUsageCount(int roleId) async {
    try {
      final query = selectOnly(db.users)
        ..addColumns([db.users.id.count()])
        ..where(db.users.roleId.equals(roleId));

      final result = await query.getSingle();
      return result.read(db.users.id.count()) ?? 0;
    } catch (e) {
      //print('❌ Error checking role usage: $e');
      return 0;
    }
  }

  /// ✅ Find a role by its name
  Future<Role?> getRoleByName(String roleName) async {
    try {
      return await (select(
        roles,
      )..where((r) => r.name.equals(roleName))).getSingleOrNull();
    } catch (e) {
      //print('❌ Error fetching role by name: $e');
      return null;
    }
  }

  /// ✅ Find a role by ID
  Future<Role?> getRoleById(int id) async {
    try {
      return await (select(
        roles,
      )..where((r) => r.id.equals(id))).getSingleOrNull();
    } catch (e) {
      //print('❌ Error fetching role by ID: $e');
      return null;
    }
  }

  // ============================================================================
  // PERMISSION QUERIES
  // ============================================================================

  /// ✅ Get roles with specific permission
  Future<List<Role>> getRolesWithPermission(String permission) async {
    try {
      final query = select(roles)
        ..where((t) {
          switch (permission) {
            case 'view_inventory':
              return t.canViewInventory.equals(true);
            case 'add_inventory':
              return t.canAddInventory.equals(true);
            case 'edit_inventory':
              return t.canEditInventory.equals(true);
            case 'delete_inventory':
              return t.canDeleteInventory.equals(true);
            case 'view_reports':
              return t.canViewReports.equals(true);
            case 'export_data':
              return t.canExportData.equals(true);
            case 'access_settings':
              return t.canAccessSettings.equals(true);
            case 'manage_employees':
              return t.canManageEmployees.equals(true);
            case 'manage_roles':
              return t.canManageRoles.equals(true);
            default:
              return t.isActive.equals(true);
          }
        });

      return await query.get();
    } catch (e) {
      //print('❌ Error fetching roles with permission: $e');
      return [];
    }
  }

  /// ✅ Get system roles (cannot be deleted)
  Future<List<Role>> getSystemRoles() async {
    try {
      return await (select(
        roles,
      )..where((t) => t.isSystemRole.equals(true))).get();
    } catch (e) {
      //print('❌ Error fetching system roles: $e');
      return [];
    }
  }

  /// ✅ Get custom roles (can be modified/deleted)
  Future<List<Role>> getCustomRoles() async {
    try {
      return await (select(
        roles,
      )..where((t) => t.isSystemRole.equals(false))).get();
    } catch (e) {
      //print('❌ Error fetching custom roles: $e');
      return [];
    }
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// ✅ Get unsynced roles (paginated)
  Future<List<Role>> getUnsyncedRoles({int limit = 100, int offset = 0}) async {
    try {
      return await (select(roles)
            ..where((t) => t.isSynced.equals(false))
            ..limit(limit, offset: offset))
          .get();
    } catch (e) {
      //print('❌ Error fetching unsynced roles: $e');
      return [];
    }
  }

  /// ✅ Count unsynced roles
  Future<int> getUnsyncedRoleCount() async {
    try {
      final query = selectOnly(roles)
        ..addColumns([roles.id.count()])
        ..where(roles.isSynced.equals(false));

      final result = await query.getSingle();
      return result.read(roles.id.count()) ?? 0;
    } catch (e) {
      //print('❌ Error counting unsynced roles: $e');
      return 0;
    }
  }

  /// ✅ Mark roles as synced (batch)
  Future<void> markAsSynced(
    List<int> roleIds, {
    Map<int, String>? cloudIds,
  }) async {
    try {
      await db.batch((batch) {
        for (final id in roleIds) {
          batch.update(
            roles,
            RolesCompanion(
              isSynced: Value(true),
              cloudId: Value(cloudIds?[id]),
            ),
            where: (t) => t.id.equals(id),
          );
        }
      });
    } catch (e) {
      //print('❌ Error marking roles as synced: $e');
      rethrow;
    }
  }

  /// ✅ Batch upsert from cloud
  /// Expects data from toLocalFormat (camelCase keys) or raw cloud data (snake_case)
  Future<void> upsertBatchFromCloud(
    List<Map<String, dynamic>> cloudRoles,
  ) async {
    try {
      await db.transaction(() async {
        for (final cloudRole in cloudRoles) {
          // Support both camelCase (from toLocalFormat) and snake_case (raw cloud) keys
          await upsertFromCloud(
            id: cloudRole['localId'] ?? cloudRole['local_id'] ?? 0,
            name: cloudRole['name'] ?? 'Unknown Role',
            description: cloudRole['description'],
            canViewInventory:
                cloudRole['canViewInventory'] ??
                cloudRole['can_view_inventory'] ??
                false,
            canAddInventory:
                cloudRole['canAddInventory'] ??
                cloudRole['can_add_inventory'] ??
                false,
            canEditInventory:
                cloudRole['canEditInventory'] ??
                cloudRole['can_edit_inventory'] ??
                false,
            canDeleteInventory:
                cloudRole['canDeleteInventory'] ??
                cloudRole['can_delete_inventory'] ??
                false,
            canViewReports:
                cloudRole['canViewReports'] ??
                cloudRole['can_view_reports'] ??
                false,
            canExportData:
                cloudRole['canExportData'] ??
                cloudRole['can_export_data'] ??
                false,
            canAccessSettings:
                cloudRole['canAccessSettings'] ??
                cloudRole['can_access_settings'] ??
                false,
            canManageEmployees:
                cloudRole['canManageEmployees'] ??
                cloudRole['can_manage_employees'] ??
                false,
            canManageRoles:
                cloudRole['canManageRoles'] ??
                cloudRole['can_manage_roles'] ??
                false,
            isSystemRole:
                cloudRole['isSystemRole'] ??
                cloudRole['is_system_role'] ??
                false,
            isActive: cloudRole['isActive'] ?? cloudRole['is_active'] ?? true,
            createdAt: _parseDateTime(
              cloudRole['createdAt'] ?? cloudRole['created_at'],
            ),
            lastUpdated: _parseDateTime(
              cloudRole['lastUpdated'] ?? cloudRole['last_updated'],
            ),
            cloudId: cloudRole['cloudId'] ?? cloudRole['cloud_id'] ?? '',
          );
        }
      });
    } catch (e) {
      //print('❌ Error batch upserting roles from cloud: $e');
      rethrow;
    }
  }

  /// Helper to parse DateTime from various formats
  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

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
    try {
      // ✅ First, try to find existing role by name
      final existingRole = await getRoleByName(name);

      if (existingRole != null) {
        // ✅ Update existing role instead of inserting
        await (update(roles)..where((t) => t.id.equals(existingRole.id))).write(
          RolesCompanion(
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
      } else {
        // ✅ Insert new role
        await into(roles).insert(
          RolesCompanion.insert(
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
      }
    } catch (e) {
      //print('❌ Error upserting role from cloud: $e');
      rethrow;
    }
  }

  /// ✅ Get role by cloud ID
  Future<Role?> getRoleByCloudId(String cloudId) async {
    try {
      return await (select(
        roles,
      )..where((t) => t.cloudId.equals(cloudId))).getSingleOrNull();
    } catch (e) {
      //print('❌ Error fetching role by cloud ID: $e');
      return null;
    }
  }

  /// ✅ Clean up inactive roles that are synced (after cloud deletion)
  Future<int> cleanupDeletedRoles() async {
    try {
      final result =
          await (delete(roles)..where(
                (t) =>
                    t.isActive.equals(false) &
                    t.isSynced.equals(true) &
                    t.isSystemRole.equals(false),
              )) // Never delete system roles
              .go();

      if (result > 0) {
        //print('🧹 Cleaned up $result inactive roles from local database');
      }

      return result;
    } catch (e) {
      //print('❌ Error cleaning up deleted roles: $e');
      return 0;
    }
  }
}
