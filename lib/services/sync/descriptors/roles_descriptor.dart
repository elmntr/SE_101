// lib/services/sync/descriptors/roles_descriptor.dart

import '../table_sync_descriptor.dart';
import '../sync_conflict.dart';

/// Descriptor for Roles table sync
/// 
/// Tier 1: No FK dependencies
/// Push: Only commissary can push roles
final rolesDescriptor = TableSyncDescriptor(
  tableName: 'roles',
  cloudTableName: 'roles',
  conflictResolution: ConflictResolution.lastWriteWins,
  dependencyTier: 1,
  incrementalSync: false, // Always full refresh to ensure all roles are available for FK resolution
  
  // Only commissary can create/modify roles
  canPush: (orgType) => orgType == 'commissary',
  
  foreignKeys: [], // No FKs
  
  fieldMappings: [
    FieldMapping.simple('localId', 'local_id'), // Map cloud's local_id for upsert lookup
    FieldMapping.simple('name', 'name'),
    FieldMapping.simple('description', 'description'),
    FieldMapping.boolean('canViewInventory', 'can_view_inventory'),
    FieldMapping.boolean('canAddInventory', 'can_add_inventory'),
    FieldMapping.boolean('canEditInventory', 'can_edit_inventory'),
    FieldMapping.boolean('canDeleteInventory', 'can_delete_inventory'),
    FieldMapping.boolean('canViewReports', 'can_view_reports'),
    FieldMapping.boolean('canExportData', 'can_export_data'),
    FieldMapping.boolean('canAccessSettings', 'can_access_settings'),
    FieldMapping.boolean('canManageEmployees', 'can_manage_employees'),
    FieldMapping.boolean('canManageRoles', 'can_manage_roles'),
    FieldMapping.boolean('isSystemRole', 'is_system_role'),
    FieldMapping.boolean('isActive', 'is_active'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('lastUpdated', 'last_updated'),
  ],
);
