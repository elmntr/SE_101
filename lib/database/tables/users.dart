// lib/database/tables/users.dart
import 'package:drift/drift.dart';
import 'roles.dart';
import 'organizations.dart';

/// Users table - Represents all users in the system
///
/// User Types by Organization:
/// 1. Commissary Users:
///    - Manage ingredients
///    - Create items/recipes
///    - Review franchisee replenishment requests
///
/// 2. Franchisee Users (Owners/Managers):
///    - Request items from commissary
///    - Set prices for items
///    - Review employee stock change requests
///    - View reports
///
/// 3. Franchisee Employees:
///    - Record sold/spoiled items
///    - Submit stock change requests
///    - Limited access based on role
class Users extends Table {
  /// Primary key
  IntColumn get id => integer().autoIncrement()();

  /// Unique username for login
  TextColumn get username => text().unique().withLength(min: 3, max: 100)();

  /// Unique email for login and notifications
  TextColumn get email => text().unique().withLength(max: 200)();

  /// Hashed password
  TextColumn get password => text()();

  /// Optional phone number
  TextColumn get phone => text().nullable().withLength(max: 50)();

  /// Which organization this user belongs to
  /// - Commissary users → commissary organization
  /// - Franchisee owner/manager → franchisee organization
  /// - Franchisee employee → franchisee organization
  IntColumn get organizationId => integer().references(Organizations, #id)();

  /// Role defines permissions (from Roles table)
  IntColumn get roleId => integer().references(Roles, #id)();

  /// Full name of user
  TextColumn get fullName => text().nullable().withLength(max: 200)();

  /// Active status (for soft delete)
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Track when user was created/modified
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastUpdated =>
      dateTime().withDefault(currentDateAndTime)();

  /// Sync fields for cloud synchronization
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get cloudId => text().nullable()();
}
