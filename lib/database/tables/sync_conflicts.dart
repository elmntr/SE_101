// lib/database/tables/sync_conflicts.dart

import 'package:drift/drift.dart';

/// Table for storing sync conflicts for audit and manual resolution
///
/// When a conflict is detected during sync (both local and cloud modified),
/// it's logged here for review. Conflicts are auto-deleted after 30 days
/// if resolved.
@DataClassName('SyncConflict')
class SyncConflicts extends Table {
  /// Primary key
  IntColumn get id => integer().autoIncrement()();

  /// The table where the conflict occurred (e.g., 'items', 'users')
  /// Named 'sourceTable' to avoid conflict with Drift's Table.tableName
  TextColumn get sourceTable => text().withLength(min: 1, max: 100)();

  /// The cloud_id of the conflicting record
  TextColumn get cloudId => text().withLength(min: 1, max: 100)();

  /// JSON-encoded local record data at time of conflict
  TextColumn get localData => text()();

  /// JSON-encoded cloud record data at time of conflict
  TextColumn get cloudData => text()();

  /// Type of conflict (bothModified, localDeletedCloudModified, etc.)
  TextColumn get conflictType => text().withLength(min: 1, max: 50)();

  /// Resolution applied (localWins, cloudWins, merged, manual)
  TextColumn get resolution => text().nullable().withLength(max: 50)();

  /// Organization ID for filtering conflicts by org (franchisee sees their own)
  IntColumn get organizationId => integer().nullable()();

  /// When the conflict was detected
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();

  /// When the conflict was resolved (null = unresolved)
  DateTimeColumn get resolvedAt => dateTime().nullable()();

  /// Additional notes from manual resolution
  TextColumn get notes => text().nullable().withLength(max: 1000)();
}
