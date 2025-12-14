// lib/database/tables/roles.dart
import 'package:drift/drift.dart';

class Roles extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 3, max: 100).unique()();

  // Description helps explain what the role is for
  TextColumn get description => text().nullable().withLength(max: 500)();

  // Inventory permissions
  BoolColumn get canViewInventory => boolean().withDefault(const Constant(false))();
  BoolColumn get canAddInventory => boolean().withDefault(const Constant(false))();
  BoolColumn get canEditInventory => boolean().withDefault(const Constant(false))();
  BoolColumn get canDeleteInventory => boolean().withDefault(const Constant(false))();

  // Reporting & settings permissions
  BoolColumn get canViewReports => boolean().withDefault(const Constant(false))();
  BoolColumn get canExportData => boolean().withDefault(const Constant(false))();
  BoolColumn get canAccessSettings => boolean().withDefault(const Constant(false))();

  // Track role changes
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();

  // System roles cannot be deleted (Admin, Manager, etc.)
  BoolColumn get isSystemRole => boolean().withDefault(const Constant(false))();

  // Soft delete
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // Employee & role management permissions
  BoolColumn get canManageEmployees => boolean().withDefault(const Constant(false))();
  BoolColumn get canManageRoles => boolean().withDefault(const Constant(false))();

   // Sync fields
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get cloudId => text().nullable()();

}
