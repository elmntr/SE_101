// lib/services/sync/descriptors/daily_sales_descriptor.dart

import '../table_sync_descriptor.dart';
import '../sync_conflict.dart';

/// Descriptor for DailySalesSummary table sync
/// 
/// Tier 4: Depends on Organizations, Items
/// Push: Franchisees push their daily sales summaries
final dailySalesDescriptor = TableSyncDescriptor(
  tableName: 'daily_sales_summary',
  cloudTableName: 'daily_sales_summary',
  conflictResolution: ConflictResolution.lastWriteWins,
  dependencyTier: 4,
  organizationField: 'organization_id',
  
  // Franchisees push their sales data
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
      localField: 'itemId',
      cloudField: 'item_id',
      referenceTable: 'items',
      required: true,
      cloudUsesUuid: true,
    ),
  ],
  
  fieldMappings: [
    FieldMapping.dateTime('date', 'date'),
    FieldMapping.simple('openingStock', 'opening_stock'),
    FieldMapping.simple('closingStock', 'closing_stock'),
    FieldMapping.simple('totalSold', 'total_sold'),
    FieldMapping.simple('totalSpoilage', 'total_spoilage'),
    FieldMapping.simple('restockReceived', 'restock_received'),
    FieldMapping.simple('totalRevenue', 'total_revenue'),
    FieldMapping.simple('notes', 'notes'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('lastUpdated', 'last_updated'),
  ],
);
