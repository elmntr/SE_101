import 'package:drift/drift.dart';

// ADDED: Defines role-level permissions controlling navigation and actions.
class Roles extends Table {
  IntColumn get id => integer().autoIncrement()();

  // ADDED: Unique role name referenced by user accounts.
  TextColumn get name => text().withLength(min: 3, max: 100).unique()();

  // ADDED: Permission flags aligned with the access list in the employee UI.
  BoolColumn get canViewInventory => boolean().withDefault(const Constant(false))();
  BoolColumn get canAddInventory => boolean().withDefault(const Constant(false))();
  BoolColumn get canEditInventory => boolean().withDefault(const Constant(false))();
  BoolColumn get canDeleteInventory => boolean().withDefault(const Constant(false))();
  BoolColumn get canManageEmployees => boolean().withDefault(const Constant(false))();
  BoolColumn get canManageRoles => boolean().withDefault(const Constant(false))();
  BoolColumn get canViewReports => boolean().withDefault(const Constant(false))();
  BoolColumn get canAccessSettings => boolean().withDefault(const Constant(false))();
}

