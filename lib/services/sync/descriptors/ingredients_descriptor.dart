// lib/services/sync/descriptors/ingredients_descriptor.dart

import '../table_sync_descriptor.dart';
import '../sync_conflict.dart';

/// Descriptor for Ingredients table sync
/// 
/// Tier 2: Depends on Organizations (commissary), Categories
/// Push: Only commissary can push ingredients
/// Note: commissary_id is stored as INTEGER in Supabase (not UUID)
final ingredientsDescriptor = TableSyncDescriptor(
  tableName: 'ingredients',
  cloudTableName: 'ingredients',
  conflictResolution: ConflictResolution.lastWriteWins,
  dependencyTier: 2,
  softDeleteField: 'is_deleted',
  
  // Only commissary creates ingredients
  canPush: (orgType) => orgType == 'commissary',
  
  foreignKeys: [
    // NOTE: commissary_id is INTEGER in Supabase, not UUID
    ForeignKeyMapping(
      localField: 'commissaryId',
      cloudField: 'commissary_id',
      referenceTable: 'organizations',
      required: true,
      cloudUsesUuid: false, // Integer, not UUID
    ),
    ForeignKeyMapping(
      localField: 'categoryId',
      cloudField: 'category_id',
      referenceTable: 'categories',
      required: false,
      cloudUsesUuid: true,
    ),
  ],
  
  fieldMappings: [
    FieldMapping.simple('name', 'name'),
    FieldMapping.simple('stock', 'stock'),
    FieldMapping.simple('spoilage', 'spoilage'),
    FieldMapping.simple('unit', 'unit'),
    FieldMapping.simple('minimumStock', 'minimum_stock'),
    FieldMapping.simple('description', 'description'),
    FieldMapping.boolean('isDeleted', 'is_deleted'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('lastUpdated', 'last_updated'),
  ],
);
