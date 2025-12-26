// lib/database/daos/organizations_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/organizations.dart';

part 'organizations_dao.g.dart';

/// OrganizationsDao - Manage commissary and franchisee organizations
///
/// Business Logic:
/// - One commissary can have many franchisees
/// - Franchisees must reference a parent commissary
/// - Commissary organizations have type='commissary', parentCommissaryId=NULL
/// - Franchisee organizations have type='franchisee', parentCommissaryId=(commissary id)
@DriftAccessor(tables: [Organizations])
class OrganizationsDao extends DatabaseAccessor<AppDatabase>
    with _$OrganizationsDaoMixin {
  OrganizationsDao(super.db);

  static const int defaultPageSize = 50;

  // ============================================================================
  // BASIC CRUD OPERATIONS
  // ============================================================================

  /// ✅ Get all organizations with pagination
  Future<List<Organization>> getAllOrganizations({
    int? limit,
    int offset = 0,
    String? type, // Filter by 'commissary' or 'franchisee'
    bool? isActive,
  }) async {
    try {
      final query = select(organizations);

      if (type != null) {
        query.where((t) => t.type.equals(type));
      }

      if (isActive != null) {
        query.where((t) => t.isActive.equals(isActive));
      }

      query.orderBy([(t) => OrderingTerm(expression: t.name)]);

      if (limit != null) {
        query.limit(limit, offset: offset);
      }

      return await query.get();
    } catch (e) {
      print('❌ Error fetching organizations: $e');
      return [];
    }
  }

  /// ✅ Count organizations
  Future<int> getOrganizationCount({String? type, bool? isActive}) async {
    try {
      final query = selectOnly(organizations)
        ..addColumns([organizations.id.count()]);

      if (type != null) {
        query.where(organizations.type.equals(type));
      }

      if (isActive != null) {
        query.where(organizations.isActive.equals(isActive));
      }

      final result = await query.getSingle();
      return result.read(organizations.id.count()) ?? 0;
    } catch (e) {
      print('❌ Error counting organizations: $e');
      return 0;
    }
  }

  /// ✅ Watch all organizations (real-time updates)
  Stream<List<Organization>> watchAllOrganizations({
    int limit = defaultPageSize,
    int offset = 0,
  }) {
    try {
      return (select(organizations)
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm(expression: t.name)])
            ..limit(limit, offset: offset))
          .watch();
    } catch (e) {
      print('❌ Error watching organizations: $e');
      return Stream.value([]);
    }
  }

  /// ✅ Insert a new organization
  Future<int> insertOrganization(OrganizationsCompanion organization) async {
    try {
      // Validate type
      if (organization.type.present) {
        final type = organization.type.value;
        if (type != 'commissary' && type != 'franchisee') {
          throw ArgumentError(
            'Organization type must be "commissary" or "franchisee"',
          );
        }

        // Franchisees must have a parent commissary
        if (type == 'franchisee' && !organization.parentCommissaryId.present) {
          throw ArgumentError('Franchisee must have a parent commissary');
        }
      }

      return await into(
        organizations,
      ).insert(organization.copyWith(isSynced: Value(false)));
    } catch (e) {
      print('❌ Error inserting organization: $e');
      rethrow;
    }
  }

  /// ✅ Batch insert organizations
  Future<void> insertOrganizations(
    List<OrganizationsCompanion> organizationsList,
  ) async {
    try {
      await db.batch((batch) {
        for (final org in organizationsList) {
          batch.insert(organizations, org.copyWith(isSynced: Value(false)));
        }
      });
    } catch (e) {
      print('❌ Error batch inserting organizations: $e');
      rethrow;
    }
  }

  /// ✅ Update an existing organization
  Future<bool> updateOrganization(Organization organization) async {
    try {
      final updated = organization.copyWith(
        isSynced: false,
        lastUpdated: DateTime.now(),
      );
      return await update(organizations).replace(updated);
    } catch (e) {
      print('❌ Error updating organization: $e');
      return false;
    }
  }

  /// ✅ Get organization by ID
  Future<Organization?> getOrganizationById(int id) async {
    try {
      return await (select(
        organizations,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching organization by ID: $e');
      return null;
    }
  }

  /// ✅ Get organization by name
  Future<Organization?> getOrganizationByName(String name) async {
    try {
      return await (select(organizations)
            ..where((t) => t.name.equals(name) & t.isActive.equals(true)))
          .getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching organization by name: $e');
      return null;
    }
  }

  /// ✅ Get organizations by type (for branch list dropdown)
  Future<List<Organization>> getOrganizationsByType(
    String type, {
    bool? isActive,
  }) async {
    try {
      final query = select(organizations)
        ..where((t) => t.type.equals(type));
      
      if (isActive != null) {
        query.where((t) => t.isActive.equals(isActive));
      }
      
      query.orderBy([(t) => OrderingTerm(expression: t.name)]);
      
      return await query.get();
    } catch (e) {
      print('❌ Error fetching organizations by type: $e');
      return [];
    }
  }

  /// ✅ Soft delete organization (deactivate)
  Future<bool> deactivateOrganization(int id) async {
    try {
      // Check if organization has active users or items
      final userCount = await _getActiveUserCount(id);
      final itemCount = await _getActiveItemCount(id);

      if (userCount > 0 || itemCount > 0) {
        print(
          '⚠️ Cannot deactivate organization $id: has $userCount users and $itemCount items',
        );
        throw Exception(
          'Organization has $userCount active user(s) and $itemCount item(s)',
        );
      }

      final result =
          await (update(organizations)..where((t) => t.id.equals(id))).write(
            OrganizationsCompanion(
              isActive: Value(false),
              lastUpdated: Value(DateTime.now()),
              isSynced: Value(false),
            ),
          );

      return result > 0;
    } catch (e) {
      print('❌ Error deactivating organization: $e');
      rethrow;
    }
  }

  /// ✅ Reactivate organization
  Future<bool> reactivateOrganization(int id) async {
    try {
      final result =
          await (update(organizations)..where((t) => t.id.equals(id))).write(
            OrganizationsCompanion(
              isActive: Value(true),
              lastUpdated: Value(DateTime.now()),
              isSynced: Value(false),
            ),
          );

      return result > 0;
    } catch (e) {
      print('❌ Error reactivating organization: $e');
      return false;
    }
  }

  // ============================================================================
  // COMMISSARY-SPECIFIC QUERIES
  // ============================================================================

  /// ✅ Get all commissary organizations
  Future<List<Organization>> getAllCommissaries({
    int? limit,
    int offset = 0,
  }) async {
    try {
      return await getAllOrganizations(
        limit: limit,
        offset: offset,
        type: 'commissary',
        isActive: true,
      );
    } catch (e) {
      print('❌ Error fetching commissaries: $e');
      return [];
    }
  }

  /// ✅ Get the main/primary commissary (usually the first one)
  Future<Organization?> getMainCommissary() async {
    try {
      return await (select(organizations)
            ..where(
              (t) => t.type.equals('commissary') & t.isActive.equals(true),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt)])
            ..limit(1))
          .getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching main commissary: $e');
      return null;
    }
  }

  // ============================================================================
  // FRANCHISEE-SPECIFIC QUERIES
  // ============================================================================

  /// ✅ Get all franchisees
  Future<List<Organization>> getAllFranchisees({
    int? limit,
    int offset = 0,
    int? parentCommissaryId,
  }) async {
    try {
      final query = select(organizations)
        ..where((t) => t.type.equals('franchisee') & t.isActive.equals(true));

      if (parentCommissaryId != null) {
        query.where((t) => t.parentCommissaryId.equals(parentCommissaryId));
      }

      query.orderBy([(t) => OrderingTerm(expression: t.name)]);

      if (limit != null) {
        query.limit(limit, offset: offset);
      }

      return await query.get();
    } catch (e) {
      print('❌ Error fetching franchisees: $e');
      return [];
    }
  }

  /// ✅ Get franchisees for a specific commissary
  Future<List<Organization>> getFranchiseesByCommissary(
    int commissaryId,
  ) async {
    try {
      return await (select(organizations)
            ..where(
              (t) =>
                  t.type.equals('franchisee') &
                  t.parentCommissaryId.equals(commissaryId) &
                  t.isActive.equals(true),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.name)]))
          .get();
    } catch (e) {
      print('❌ Error fetching franchisees by commissary: $e');
      return [];
    }
  }

  /// ✅ Count franchisees under a commissary
  Future<int> getFranchiseeCount(int commissaryId) async {
    try {
      final query = selectOnly(organizations)
        ..addColumns([organizations.id.count()])
        ..where(
          organizations.type.equals('franchisee') &
              organizations.parentCommissaryId.equals(commissaryId) &
              organizations.isActive.equals(true),
        );

      final result = await query.getSingle();
      return result.read(organizations.id.count()) ?? 0;
    } catch (e) {
      print('❌ Error counting franchisees: $e');
      return 0;
    }
  }

  // ============================================================================
  // RELATIONSHIP QUERIES
  // ============================================================================

  /// ✅ Check if organization has active users
  Future<int> _getActiveUserCount(int organizationId) async {
    try {
      final query = selectOnly(db.users)
        ..addColumns([db.users.id.count()])
        ..where(
          db.users.organizationId.equals(organizationId) &
              db.users.isActive.equals(true),
        );

      final result = await query.getSingle();
      return result.read(db.users.id.count()) ?? 0;
    } catch (e) {
      print('❌ Error checking user count: $e');
      return 0;
    }
  }

  /// ✅ Check if organization has active items
  Future<int> _getActiveItemCount(int organizationId) async {
    try {
      final query = selectOnly(db.items)
        ..addColumns([db.items.id.count()])
        ..where(
          db.items.organizationId.equals(organizationId) &
              db.items.isDeleted.equals(false),
        );

      final result = await query.getSingle();
      return result.read(db.items.id.count()) ?? 0;
    } catch (e) {
      print('❌ Error checking item count: $e');
      return 0;
    }
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// ✅ Get unsynced organizations (paginated)
  Future<List<Organization>> getUnsyncedOrganizations({
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      return await (select(organizations)
            ..where((t) => t.isSynced.equals(false))
            ..limit(limit, offset: offset))
          .get();
    } catch (e) {
      print('❌ Error fetching unsynced organizations: $e');
      return [];
    }
  }

  /// ✅ Count unsynced organizations
  Future<int> getUnsyncedOrganizationCount() async {
    try {
      final query = selectOnly(organizations)
        ..addColumns([organizations.id.count()])
        ..where(organizations.isSynced.equals(false));

      final result = await query.getSingle();
      return result.read(organizations.id.count()) ?? 0;
    } catch (e) {
      print('❌ Error counting unsynced organizations: $e');
      return 0;
    }
  }

  /// ✅ Mark organizations as synced (batch)
  Future<void> markAsSynced(
    List<int> organizationIds, {
    Map<int, String>? cloudIds,
  }) async {
    try {
      await db.batch((batch) {
        for (final id in organizationIds) {
          batch.update(
            organizations,
            OrganizationsCompanion(
              isSynced: Value(true),
              cloudId: Value(cloudIds?[id]),
            ),
            where: (t) => t.id.equals(id),
          );
        }
      });
    } catch (e) {
      print('❌ Error marking organizations as synced: $e');
      rethrow;
    }
  }

  /// ✅ Batch upsert from cloud
  /// ✅ Batch upsert from cloud
Future<void> upsertBatchFromCloud(List<Map<String, dynamic>> cloudOrganizations) async {
  try {
    await db.transaction(() async {
      for (final cloudOrg in cloudOrganizations) {
        await upsertFromCloud(
          id: cloudOrg['local_id'] ?? 0,
          name: cloudOrg['name'] ?? 'Unknown Organization',
          type: cloudOrg['type'] ?? 'commissary',
          parentCommissaryId: cloudOrg['parent_commissary_id'], // ✅ Can be null
          contactPerson: cloudOrg['contact_person'], // ✅ Already nullable (String?)
          phone: cloudOrg['phone'],
          email: cloudOrg['email'],
          address: cloudOrg['address'],
          isActive: cloudOrg['is_active'] ?? true, // ✅ Default to true
          createdAt: DateTime.tryParse(cloudOrg['created_at'] ?? '') ?? DateTime.now(), // ✅ Safe parse
          lastUpdated: DateTime.tryParse(cloudOrg['last_updated'] ?? '') ?? DateTime.now(), // ✅ Safe parse
          cloudId: cloudOrg['cloud_id'] ?? '', // ✅ Default to empty string
        );
      }
    });
  } catch (e) {
    print('❌ Error batch upserting organizations from cloud: $e');
    rethrow;
  }
}

  /// ✅ Upsert from cloud (individual)
  Future<void> upsertFromCloud({
    required int id,
    required String name,
    required String type,
    int? parentCommissaryId,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    required bool isActive,
    required DateTime createdAt,
    required DateTime lastUpdated,
    required String cloudId,
  }) async {
    try {
      await into(organizations).insertOnConflictUpdate(
        OrganizationsCompanion.insert(
          id: Value(id),
          name: name,
          type: type,
          parentCommissaryId: Value(parentCommissaryId),
          contactPerson: Value(contactPerson),
          phone: Value(phone),
          email: Value(email),
          address: Value(address),
          isActive: Value(isActive),
          createdAt: Value(createdAt),
          lastUpdated: Value(lastUpdated),
          isSynced: Value(true),
          cloudId: Value(cloudId),
        ),
      );
    } catch (e) {
      print('❌ Error upserting organization from cloud: $e');
      rethrow;
    }
  }

  /// ✅ Get organization by cloud ID
  Future<Organization?> getOrganizationByCloudId(String cloudId) async {
    try {
      return await (select(
        organizations,
      )..where((t) => t.cloudId.equals(cloudId))).getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching organization by cloud ID: $e');
      return null;
    }
  }
}
