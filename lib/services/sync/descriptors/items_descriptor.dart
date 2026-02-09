// lib/services/sync/descriptors/items_descriptor.dart

import '../table_sync_descriptor.dart';
import '../sync_conflict.dart';

/// Descriptor for Items table sync
/// 
/// Tier 2: Depends on Organizations, Categories
/// Push: Both commissary and franchisee can push items
/// Note: Franchisees create local copies of commissary master items
final itemsDescriptor = TableSyncDescriptor(
  tableName: 'items',
  cloudTableName: 'items',
  conflictResolution: ConflictResolution.lastWriteWins,
  dependencyTier: 2,
  organizationField: 'organization_id',
  softDeleteField: 'is_deleted',
  incrementalSync: false, // Full refresh to ensure all master items are synced
  pullLimit: 1000,
  
  // Both can push their own items
  canPush: (orgType) => true,
  
  foreignKeys: [
    ForeignKeyMapping(
      localField: 'organizationId',
      cloudField: 'organization_id',
      referenceTable: 'organizations',
      required: true,
      cloudUsesUuid: true,
    ),
    ForeignKeyMapping(
      localField: 'categoryId',
      cloudField: 'category_id',
      referenceTable: 'categories',
      required: false,
      cloudUsesUuid: true, // category_id is UUID in Supabase (references categories.cloud_id)
    ),
    ForeignKeyMapping(
      localField: 'masterItemId',
      cloudField: 'master_item_id',
      referenceTable: 'items',
      required: false,
      cloudUsesUuid: true, // master_item_id is TEXT (cloud_id) in cloud
    ),
  ],
  
  fieldMappings: [
    FieldMapping.simple('name', 'name'),
    FieldMapping.simple('stock', 'stock'),
    FieldMapping.simple('sold', 'sold'),
    FieldMapping.simple('spoilage', 'spoilage'),
    FieldMapping.simple('price', 'price'),
    FieldMapping.simple('costPrice', 'cost_price'),
    FieldMapping.simple('unit', 'unit'),
    FieldMapping.simple('minimumStock', 'minimum_stock'),
    FieldMapping.simple('description', 'description'),
    FieldMapping.boolean('isDeleted', 'is_deleted'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('lastUpdated', 'last_updated'),
  ],
);
