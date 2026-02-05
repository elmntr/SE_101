// lib/services/sync/descriptors/organizations_descriptor.dart

import '../table_sync_descriptor.dart';
import '../sync_conflict.dart';

/// Descriptor for Organizations table sync
/// 
/// Tier 1: No FK dependencies
/// Push: Only commissary can push organizations
final organizationsDescriptor = TableSyncDescriptor(
  tableName: 'organizations',
  cloudTableName: 'organizations',
  conflictResolution: ConflictResolution.lastWriteWins,
  dependencyTier: 1,
  incrementalSync: false, // Always full refresh to ensure all orgs are available for FK resolution
  
  // Only commissary can create organizations
  canPush: (orgType) => orgType == 'commissary',
  
  foreignKeys: [
    ForeignKeyMapping(
      localField: 'parentCommissaryId',
      cloudField: 'parent_commissary_id',
      referenceTable: 'organizations',
      required: false,
      cloudUsesUuid: true,
    ),
  ],
  
  fieldMappings: [
    FieldMapping.simple('localId', 'local_id'), // Map cloud's local_id for upsert lookup
    FieldMapping.simple('name', 'name'),
    FieldMapping.simple('type', 'type'),
    FieldMapping.simple('contactPerson', 'contact_person'),
    FieldMapping.simple('phone', 'phone'),
    FieldMapping.simple('email', 'email'),
    FieldMapping.simple('address', 'address'),
    FieldMapping.boolean('isActive', 'is_active'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('lastUpdated', 'last_updated'),
  ],
);
