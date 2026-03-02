// lib/services/sync/descriptors/branch_stock_descriptor.dart

import '../table_sync_descriptor.dart';
import '../sync_conflict.dart';

/// Descriptor for BranchIngredientStock table sync
/// 
/// Tier 3: Depends on Organizations, Ingredients
/// Push: Franchisees push their ingredient stock levels
final branchIngredientStockDescriptor = TableSyncDescriptor(
  tableName: 'branch_ingredient_stock',
  cloudTableName: 'branch_ingredient_stock',
  conflictResolution: ConflictResolution.lastWriteWins,
  dependencyTier: 3,
  organizationField: 'organization_id',
  
  // Franchisees push their stock levels
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
      localField: 'ingredientId',
      cloudField: 'ingredient_id',
      referenceTable: 'ingredients',
      required: true,
      cloudUsesUuid: true,
    ),
  ],
  
  fieldMappings: [
    FieldMapping.simple('stock', 'stock'),
    FieldMapping.simple('spoilage', 'spoilage'),
    FieldMapping.simple('minimumStock', 'minimum_stock'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('lastUpdated', 'last_updated'),
  ],
);

/// Descriptor for BranchItemStock table sync
/// 
/// Tier 3: Depends on Organizations, Items
/// Push: Franchisees push their item stock levels
final branchItemStockDescriptor = TableSyncDescriptor(
  tableName: 'branch_item_stock',
  cloudTableName: 'branch_item_stock',
  conflictResolution: ConflictResolution.lastWriteWins,
  dependencyTier: 3,
  organizationField: 'organization_id',
  softDeleteField: 'is_deleted',
  
  // Only franchisee devices push their own stock.
  // Commissary must NOT push branch_item_stock — it doesn't own those rows
  // and Supabase RLS will reject any insert/update under a franchisee org_id
  // made with a commissary JWT (error 42501).
  canPush: (orgType) => orgType == 'franchisee',
  
  foreignKeys: [
    ForeignKeyMapping(
      localField: 'organizationId',
      cloudField: 'organization_id',
      referenceTable: 'organizations',
      required: true,
      cloudUsesUuid: true,
    ),
    ForeignKeyMapping(
      localField: 'itemId',
      cloudField: 'item_id',
      referenceTable: 'items',
      required: true,
      cloudUsesUuid: true,
    ),
  ],
  
  fieldMappings: [
    FieldMapping.simple('stock', 'stock'),
    FieldMapping.simple('sold', 'sold'),
    FieldMapping.simple('spoilage', 'spoilage'),
    FieldMapping.simple('price', 'price'),
    FieldMapping.simple('costPrice', 'cost_price'),
    FieldMapping.simple('minimumStock', 'minimum_stock'),
    FieldMapping.boolean('isDeleted', 'is_deleted'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('lastUpdated', 'last_updated'),
  ],
);
