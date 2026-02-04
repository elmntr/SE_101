// lib/database/daos/sync_conflicts_dao.dart

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sync_conflicts.dart';

part 'sync_conflicts_dao.g.dart';

@DriftAccessor(tables: [SyncConflicts])
class SyncConflictsDao extends DatabaseAccessor<AppDatabase>
    with _$SyncConflictsDaoMixin {
  SyncConflictsDao(super.db);

  /// Log a new conflict
  Future<int> logConflict({
    required String sourceTable,
    required String cloudId,
    required String localData,
    required String cloudData,
    required String conflictType,
    int? organizationId,
  }) async {
    return await into(syncConflicts).insert(
      SyncConflictsCompanion.insert(
        sourceTable: sourceTable,
        cloudId: cloudId,
        localData: localData,
        cloudData: cloudData,
        conflictType: conflictType,
        organizationId: Value(organizationId),
      ),
    );
  }

  /// Get all unresolved conflicts (optionally filtered by organization)
  Future<List<SyncConflict>> getUnresolvedConflicts({int? organizationId}) async {
    final query = select(syncConflicts)
      ..where((t) => t.resolvedAt.isNull());

    if (organizationId != null) {
      query.where((t) => t.organizationId.equals(organizationId));
    }

    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

    return await query.get();
  }

  /// Get all conflicts (resolved and unresolved) for an organization
  Future<List<SyncConflict>> getAllConflicts({
    int? organizationId,
    bool includeResolved = true,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = select(syncConflicts);

    if (organizationId != null) {
      query.where((t) => t.organizationId.equals(organizationId));
    }
    
    if (!includeResolved) {
      query.where((t) => t.resolvedAt.isNull());
    }

    query
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit, offset: offset);

    return await query.get();
  }

  /// Get conflict count
  Future<int> getUnresolvedConflictCount({int? organizationId}) async {
    final query = selectOnly(syncConflicts)
      ..addColumns([syncConflicts.id.count()])
      ..where(syncConflicts.resolvedAt.isNull());

    if (organizationId != null) {
      query.where(syncConflicts.organizationId.equals(organizationId));
    }

    final result = await query.getSingle();
    return result.read(syncConflicts.id.count()) ?? 0;
  }

  /// Get conflict by ID
  Future<SyncConflict?> getConflictById(int id) async {
    return await (select(syncConflicts)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Check if a conflict already exists for this record
  Future<SyncConflict?> getExistingConflict({
    required String sourceTable,
    required String cloudId,
  }) async {
    return await (select(syncConflicts)
          ..where((t) =>
              t.sourceTable.equals(sourceTable) &
              t.cloudId.equals(cloudId) &
              t.resolvedAt.isNull()))
        .getSingleOrNull();
  }

  /// Mark conflict as resolved
  Future<bool> markResolved({
    required int id,
    required String resolution,
    String? notes,
  }) async {
    final rowsAffected = await (update(syncConflicts)
          ..where((t) => t.id.equals(id)))
        .write(
      SyncConflictsCompanion(
        resolution: Value(resolution),
        resolvedAt: Value(DateTime.now()),
        notes: Value(notes),
      ),
    );
    return rowsAffected > 0;
  }

  /// Resolve conflict by keeping local version
  Future<bool> resolveKeepLocal({
    required int id,
    String? notes,
  }) async {
    return await markResolved(
      id: id,
      resolution: 'localWins',
      notes: notes,
    );
  }

  /// Resolve conflict by keeping cloud version
  Future<bool> resolveKeepCloud({
    required int id,
    String? notes,
  }) async {
    return await markResolved(
      id: id,
      resolution: 'cloudWins',
      notes: notes,
    );
  }

  /// Clean up old resolved conflicts (older than specified days)
  Future<int> cleanupOldConflicts({int days = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    return await (delete(syncConflicts)
          ..where((t) =>
              t.resolvedAt.isNotNull() & t.resolvedAt.isSmallerThanValue(cutoffDate)))
        .go();
  }

  /// Delete a specific conflict
  Future<bool> deleteConflict(int id) async {
    final rowsDeleted =
        await (delete(syncConflicts)..where((t) => t.id.equals(id))).go();
    return rowsDeleted > 0;
  }

  /// Delete all resolved conflicts
  Future<int> deleteAllResolved() async {
    return await (delete(syncConflicts)..where((t) => t.resolvedAt.isNotNull()))
        .go();
  }

  /// Watch unresolved conflicts (for UI)
  Stream<List<SyncConflict>> watchUnresolvedConflicts({int? organizationId}) {
    final query = select(syncConflicts)
      ..where((t) => t.resolvedAt.isNull());

    if (organizationId != null) {
      query.where((t) => t.organizationId.equals(organizationId));
    }

    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

    return query.watch();
  }

  /// Watch unresolved conflict count (for badges)
  Stream<int> watchUnresolvedCount({int? organizationId}) {
    return watchUnresolvedConflicts(organizationId: organizationId)
        .map((conflicts) => conflicts.length);
  }

  /// Get conflicts grouped by table
  Future<Map<String, List<SyncConflict>>> getConflictsGroupedByTable({
    int? organizationId,
  }) async {
    final conflicts = await getUnresolvedConflicts(organizationId: organizationId);
    final grouped = <String, List<SyncConflict>>{};

    for (final conflict in conflicts) {
      grouped.putIfAbsent(conflict.sourceTable, () => []).add(conflict);
    }

    return grouped;
  }
}
