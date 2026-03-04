// lib/services/sync/descriptors/ingredients_descriptor.dart

import '../table_sync_descriptor.dart';
import '../sync_conflict.dart';

/// Sync descriptor for the Ingredients table.
///
/// Local ↔ Supabase column mapping (aligned in v6 migration):
///   cloudId        ↔ cloud_id            (TEXT NOT NULL UNIQUE)
///   name           ↔ name
///   commissaryId   ↔ commissary_id       (INTEGER, not UUID)
///   stock          ↔ stock               (REAL / double precision)
///   unit           ↔ unit
///   criticalLevel  ↔ critical_level      (REAL / double precision)
///   costPerUnit    ↔ cost_per_unit       (REAL / double precision)
///   isActive       ↔ is_active           (bool — NOT inverted)
///   needsSync      ↔ needs_sync          (bool — NOT inverted)
///   createdAt      ↔ created_at
///   lastUpdated    ↔ last_updated
///   updatedAt      ↔ updated_at
///   lastSyncedAt   ↔ last_synced_at
final ingredientsDescriptor = TableSyncDescriptor(
  tableName: 'ingredients',
  cloudTableName: 'ingredients',
  conflictResolution: ConflictResolution.lastWriteWins,
  dependencyTier: 2,

  /// Supabase uses is_active (no is_deleted column)
  softDeleteField: 'is_active',

  // Only commissary creates/manages ingredients
  canPush: (orgType) => orgType == 'commissary',

  foreignKeys: [
    // commissary_id is INTEGER in Supabase (not a UUID)
    ForeignKeyMapping(
      localField: 'commissaryId',
      cloudField: 'commissary_id',
      referenceTable: 'organizations',
      required: true,
      cloudUsesUuid: false,
    ),
  ],

  fieldMappings: [
    FieldMapping.simple('id', 'id'),
    FieldMapping.simple('name', 'name'),
    FieldMapping.simple('stock', 'stock'),
    FieldMapping.simple('unit', 'unit'),
    FieldMapping.simple('criticalLevel', 'critical_level'),
    FieldMapping.simple('costPerUnit', 'cost_per_unit'),
    FieldMapping.boolean('isActive', 'is_active'),
    FieldMapping.boolean('needsSync', 'needs_sync'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('lastUpdated', 'last_updated'),
    FieldMapping.dateTime('updatedAt', 'updated_at'),
    FieldMapping.dateTime('lastSyncedAt', 'last_synced_at'),
  ],
);
