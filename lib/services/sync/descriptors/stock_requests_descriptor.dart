// lib/services/sync/descriptors/stock_requests_descriptor.dart

import '../table_sync_descriptor.dart';
import '../sync_conflict.dart';

/// Descriptor for StockReplenishmentRequests table sync
/// 
/// Tier 4: Depends on Organizations, Items, Users
/// Push: Both commissary and franchisee can push/update requests
/// Conflict: Status-aware (more advanced status wins)
final replenishmentRequestsDescriptor = TableSyncDescriptor(
  tableName: 'stock_replenishment_requests',
  cloudTableName: 'stock_replenishment_requests',
  conflictResolution: ConflictResolution.statusAware,
  dependencyTier: 4,
  statusField: 'status',
  softDeleteField: 'is_deleted',
  
  // Both can push requests (franchisee creates, commissary reviews)
  canPush: (orgType) => true,
  
  foreignKeys: [
    ForeignKeyMapping(
      localField: 'franchiseeId',
      cloudField: 'franchisee_id',
      referenceTable: 'organizations',
      required: true,
      cloudUsesUuid: true,
    ),
    ForeignKeyMapping(
      localField: 'commissaryId',
      cloudField: 'commissary_id',
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
    ForeignKeyMapping(
      localField: 'requestedBy',
      cloudField: 'requested_by',
      referenceTable: 'users',
      required: true,
      cloudUsesUuid: true,
    ),
    ForeignKeyMapping(
      localField: 'reviewedBy',
      cloudField: 'reviewed_by',
      referenceTable: 'users',
      required: false,
      cloudUsesUuid: true,
    ),
  ],
  
  fieldMappings: [
    FieldMapping.simple('quantityRequested', 'quantity_requested'),
    FieldMapping.simple('status', 'status'),
    FieldMapping.dateTime('requestedAt', 'requested_at'),
    FieldMapping.dateTime('reviewedAt', 'reviewed_at'),
    FieldMapping.dateTime('deliveryDate', 'delivery_date'),
    FieldMapping.simple('franchiseeNotes', 'franchisee_notes'),
    FieldMapping.simple('commissaryNotes', 'commissary_notes'),
    FieldMapping.boolean('isDeleted', 'is_deleted'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('lastUpdated', 'last_updated'),
  ],
);

/// Descriptor for StockChangeRequests table sync
/// 
/// Tier 4: Depends on Organizations, Items, Users
/// Push: Franchisees push change requests
/// Conflict: Status-aware (more advanced status wins)
final changeRequestsDescriptor = TableSyncDescriptor(
  tableName: 'stock_change_requests',
  cloudTableName: 'stock_change_requests',
  conflictResolution: ConflictResolution.statusAware,
  dependencyTier: 4,
  statusField: 'status',
  softDeleteField: 'is_deleted',
  
  // Franchisees push their change requests
  canPush: (orgType) => true,
  
  foreignKeys: [
    ForeignKeyMapping(
      localField: 'franchiseeId',
      cloudField: 'franchisee_id',
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
    ForeignKeyMapping(
      localField: 'requestedBy',
      cloudField: 'requested_by',
      referenceTable: 'users',
      required: true,
      cloudUsesUuid: true,
    ),
    ForeignKeyMapping(
      localField: 'reviewedBy',
      cloudField: 'reviewed_by',
      referenceTable: 'users',
      required: false,
      cloudUsesUuid: true,
    ),
  ],
  
  fieldMappings: [
    FieldMapping.simple('changeType', 'change_type'),
    FieldMapping.simple('quantity', 'quantity'),
    FieldMapping.simple('status', 'status'),
    FieldMapping.dateTime('requestedAt', 'requested_at'),
    FieldMapping.dateTime('reviewedAt', 'reviewed_at'),
    FieldMapping.simple('originalStock', 'original_stock'),
    FieldMapping.simple('reason', 'reason'),
    FieldMapping.simple('reviewerNotes', 'reviewer_notes'),
    FieldMapping.boolean('isDeleted', 'is_deleted'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('lastUpdated', 'last_updated'),
  ],
);
