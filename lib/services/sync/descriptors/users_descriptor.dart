// lib/services/sync/descriptors/users_descriptor.dart

import '../table_sync_descriptor.dart';
import '../sync_conflict.dart';

/// Descriptor for Users table sync
/// 
/// Tier 2: Depends on Organizations, Roles
/// Push: Both commissary and franchisee can push their own users
final usersDescriptor = TableSyncDescriptor(
  tableName: 'users',
  cloudTableName: 'users',
  conflictResolution: ConflictResolution.lastWriteWins,
  dependencyTier: 2,
  organizationField: 'organization_id',
  incrementalSync: false, // Always full refresh to ensure all users are synced
  
  // All org types can push their own users
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
      localField: 'roleId',
      cloudField: 'role_id',
      referenceTable: 'roles',
      required: true,
      cloudUsesUuid: true,
    ),
  ],
  
  fieldMappings: [
    FieldMapping.simple('email', 'email'),
    FieldMapping.simple('username', 'username'),
    FieldMapping.simple('password', 'password'),
    FieldMapping.simple('phone', 'phone'),
    FieldMapping.simple('fullName', 'full_name'),
    FieldMapping.boolean('isActive', 'is_active'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('lastUpdated', 'last_updated'),
  ],
);
