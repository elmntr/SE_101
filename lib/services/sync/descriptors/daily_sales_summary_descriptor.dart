// lib/services/sync/descriptors/daily_sales_summary_descriptor.dart

import '../table_sync_descriptor.dart';
import '../sync_conflict.dart';

/// Descriptor for DailySalesSummary table sync
///
/// Tier 3: Depends on Organizations, Items
/// Push: Franchisees push their daily summaries to cloud
/// Pull: Franchisees pull their own summaries (mostly for backup/restore)
///
/// Key Features:
/// - Unique per (organization_id, item_id, summary_date)
/// - Idempotent upsert by cloud_id
final dailySalesSummaryDescriptor = TableSyncDescriptor(
  tableName: 'daily_sales_summary',
  cloudTableName: 'daily_sales_summary',
  conflictResolution: ConflictResolution.lastWriteWins,
  dependencyTier: 4, // Sync after items/ingredients/stock
  incrementalSync: true,
  pullLimit: 500,
  
  // Franchisees can push their own summaries
  canPush: (orgType) => true,
  
  // RLS handles organization filtering
  organizationField: 'organization_id',
  
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
    // Business key (part of unique constraint)
    FieldMapping.dateTime('summaryDate', 'summary_date'),
    
    // Sales metrics
    FieldMapping.simple('quantitySold', 'quantity_sold'),
    FieldMapping.simple('quantitySpoiled', 'quantity_spoiled'),
    FieldMapping.simple('revenue', 'revenue'),
    FieldMapping.simple('costOfGoodsSold', 'cost_of_goods_sold'),
    FieldMapping.simple('grossProfit', 'gross_profit'),
    FieldMapping.simple('transactionCount', 'transaction_count'),
    
    // Stock reconciliation
    FieldMapping.simple('openingStock', 'opening_stock'),
    FieldMapping.simple('closingStock', 'closing_stock'),
    
    // Timestamps (standard sync fields)
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('lastUpdated', 'last_updated'),
    
    // Soft delete (if applicable, though summaries usually aren't deleted)
    // FieldMapping.boolean('isDeleted', 'is_deleted'), 
  ],
  
  // No soft delete field in this table currently, but if we add it later:
  // softDeleteField: 'is_deleted',
);
