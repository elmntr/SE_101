// lib/services/sync/table_sync_descriptor.dart

import 'sync_conflict.dart';

/// Foreign key mapping definition
class ForeignKeyMapping {
  /// The local field name (e.g., 'organizationId')
  final String localField;

  /// The cloud field name (e.g., 'organization_id')
  final String cloudField;

  /// The referenced table name for UUID resolution (e.g., 'organizations')
  final String referenceTable;

  /// Whether the FK is required (null = skip record if not resolved)
  final bool required;

  /// If true, the cloud stores UUID; if false, cloud stores integer
  final bool cloudUsesUuid;

  const ForeignKeyMapping({
    required this.localField,
    required this.cloudField,
    required this.referenceTable,
    this.required = true,
    this.cloudUsesUuid = true,
  });
}

/// Field mapping between local and cloud representations
class FieldMapping {
  /// Local field name (Dart camelCase)
  final String localField;

  /// Cloud field name (snake_case)
  final String cloudField;

  /// Transform function for local → cloud
  final dynamic Function(dynamic value)? toCloud;

  /// Transform function for cloud → local
  final dynamic Function(dynamic value)? fromCloud;

  /// Whether this field should be included in push operations
  final bool pushable;

  /// Whether this field should be included in pull operations
  final bool pullable;

  const FieldMapping({
    required this.localField,
    required this.cloudField,
    this.toCloud,
    this.fromCloud,
    this.pushable = true,
    this.pullable = true,
  });

  /// Simple field mapping (same name transformation: camelCase ↔ snake_case)
  factory FieldMapping.simple(String localField, String cloudField) {
    return FieldMapping(localField: localField, cloudField: cloudField);
  }

  /// DateTime field mapping
  factory FieldMapping.dateTime(String localField, String cloudField) {
    return FieldMapping(
      localField: localField,
      cloudField: cloudField,
      toCloud: (v) =>
          v is DateTime ? v.toUtc().toIso8601String() : v?.toString(),
      fromCloud: (v) =>
          v != null ? DateTime.parse(v.toString()).toLocal() : null,
    );
  }

  /// Boolean field mapping (handles int/bool conversion)
  factory FieldMapping.boolean(String localField, String cloudField) {
    return FieldMapping(
      localField: localField,
      cloudField: cloudField,
      toCloud: (v) => v == true || v == 1,
      fromCloud: (v) => v == true || v == 1,
    );
  }
}

/// Descriptor defining how to sync a specific table
class TableSyncDescriptor<T> {
  /// Local table name (for logging/caching)
  final String tableName;

  /// Cloud table name in Supabase
  final String cloudTableName;

  /// Conflict resolution strategy for this table
  final ConflictResolution conflictResolution;

  /// Whether this entity can be pushed to cloud
  /// (e.g., franchisees can't push organizations)
  final bool Function(String? orgType)? canPush;

  /// Foreign key mappings for UUID resolution
  final List<ForeignKeyMapping> foreignKeys;

  /// Field mappings between local and cloud
  final List<FieldMapping> fieldMappings;

  /// Business key fields for conflict resolution (alternative to cloud_id)
  final List<String> businessKeyFields;

  /// Status field name for statusAware resolution (null if not applicable)
  final String? statusField;

  /// Organization field for RLS filtering
  final String? organizationField;

  /// Soft delete field name (null if hard delete)
  final String? softDeleteField;

  /// Whether to use incremental sync (based on lastUpdated) or full refresh
  final bool incrementalSync;

  /// Sync dependency tier (lower tiers sync first)
  final int dependencyTier;

  /// Maximum records to pull per request
  final int pullLimit;

  /// Batch size for push operations
  final int pushBatchSize;

  const TableSyncDescriptor({
    required this.tableName,
    required this.cloudTableName,
    this.conflictResolution = ConflictResolution.lastWriteWins,
    this.canPush,
    this.foreignKeys = const [],
    this.fieldMappings = const [],
    this.businessKeyFields = const [],
    this.statusField,
    this.organizationField,
    this.softDeleteField = 'is_deleted',
    this.incrementalSync = true,
    this.dependencyTier = 1,
    this.pullLimit = 500,
    this.pushBatchSize = 50,
  });

  /// Check if push is allowed for the given organization type
  bool canPushFor(String? organizationType) {
    if (canPush == null) return true;
    return canPush!(organizationType);
  }

  /// Get cloud field name for a local field
  String? getCloudFieldName(String localField) {
    for (final mapping in fieldMappings) {
      if (mapping.localField == localField) {
        return mapping.cloudField;
      }
    }
    // Default: convert camelCase to snake_case
    return _camelToSnake(localField);
  }

  /// Get local field name for a cloud field
  String? getLocalFieldName(String cloudField) {
    for (final mapping in fieldMappings) {
      if (mapping.cloudField == cloudField) {
        return mapping.localField;
      }
    }
    // Default: convert snake_case to camelCase
    return _snakeToCamel(cloudField);
  }

  /// Convert local record to cloud format
  Map<String, dynamic> toCloudFormat(
    Map<String, dynamic> localData, {
    required String? Function(String table, int? localId) getCloudId,
    required String cloudIdValue,
  }) {
    final cloudData = <String, dynamic>{'cloud_id': cloudIdValue};

    // Map regular fields
    for (final mapping in fieldMappings) {
      if (!mapping.pushable) continue;

      final localValue = localData[mapping.localField];
      if (localValue != null) {
        cloudData[mapping.cloudField] = mapping.toCloud != null
            ? mapping.toCloud!(localValue)
            : localValue;
      }
    }

    // Map foreign keys
    for (final fk in foreignKeys) {
      final localId = localData[fk.localField] as int?;
      if (fk.cloudUsesUuid) {
        final cloudId = getCloudId(fk.referenceTable, localId);
        if (cloudId != null) {
          cloudData[fk.cloudField] = cloudId;
        } else if (fk.required) {
          // Skip this record - required FK not resolved
          return {};
        }
      } else {
        // Cloud uses integer directly
        cloudData[fk.cloudField] = localId;
      }
    }

    return cloudData;
  }

  /// Convert cloud record to local format
  Map<String, dynamic> toLocalFormat(
    Map<String, dynamic> cloudData, {
    required int? Function(String table, String? cloudId) getLocalId,
  }) {
    final localData = <String, dynamic>{};

    // Keep cloud_id for reference
    localData['cloudId'] = cloudData['cloud_id'];

    // Map regular fields
    for (final mapping in fieldMappings) {
      if (!mapping.pullable) continue;

      final cloudValue = cloudData[mapping.cloudField];
      if (cloudValue != null) {
        localData[mapping.localField] = mapping.fromCloud != null
            ? mapping.fromCloud!(cloudValue)
            : cloudValue;
      }
    }

    // Map foreign keys
    for (final fk in foreignKeys) {
      if (fk.cloudUsesUuid) {
        final cloudId = cloudData[fk.cloudField]?.toString();
        final localId = getLocalId(fk.referenceTable, cloudId);
        if (localId != null) {
          localData[fk.localField] = localId;
        } else if (fk.required && cloudId != null) {
          // Skip this record - required FK not resolved
          // Log which FK failed for debugging
          //print('⚠️ FK resolution failed for $tableName:');
          //print('   - Reference: ${fk.referenceTable}.${fk.cloudField}');
          //print('   - Cloud ID: $cloudId');
          //print('   - Record cloud_id: ${cloudData['cloud_id']}');
          //print('   - Record name: ${cloudData['name'] ?? 'N/A'}');
          return {};
        } else if (!fk.required) {
          // Optional FK - set to null if not resolved
          localData[fk.localField] = null;
        }
      } else {
        // Cloud uses integer directly
        localData[fk.localField] = cloudData[fk.cloudField];
      }
    }

    return localData;
  }

  /// Convert camelCase to snake_case
  static String _camelToSnake(String input) {
    return input.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }

  /// Convert snake_case to camelCase
  static String _snakeToCamel(String input) {
    return input.replaceAllMapped(
      RegExp(r'_([a-z])'),
      (match) => match.group(1)!.toUpperCase(),
    );
  }
}

/// DAO interface that sync-compatible DAOs should implement
abstract class SyncableDao<T> {
  /// Get unsynced records with pagination
  Future<List<T>> getUnsyncedRecords({int limit = 50, int offset = 0});

  /// Get count of unsynced records
  Future<int> getUnsyncedCount();

  /// Mark records as synced with their cloud IDs
  Future<void> markAsSynced(List<int> ids, {Map<int, String>? cloudIds});

  /// Upsert batch from cloud data
  Future<void> upsertBatchFromCloud(List<Map<String, dynamic>> records);

  /// Get record by cloud ID for conflict detection
  Future<T?> getByCloudId(String cloudId);

  /// Get local ID from cloud ID
  Future<int?> getLocalIdFromCloudId(String cloudId);
}

/// Extension for common field mappings
extension CommonFieldMappings on List<FieldMapping> {
  /// Add standard sync fields (createdAt, lastUpdated, isSynced, cloudId)
  static List<FieldMapping> withSyncFields(List<FieldMapping> fields) {
    return [
      ...fields,
      FieldMapping.dateTime('createdAt', 'created_at'),
      FieldMapping.dateTime('lastUpdated', 'last_updated'),
    ];
  }

  /// Add soft delete field
  static List<FieldMapping> withSoftDelete(List<FieldMapping> fields) {
    return [...fields, FieldMapping.boolean('isDeleted', 'is_deleted')];
  }
}
