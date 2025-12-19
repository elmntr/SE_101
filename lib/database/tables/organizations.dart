// lib/database/tables/organizations.dart
import 'package:drift/drift.dart';

/// Organizations table - Represents business entities (Commissary or Franchisee)
/// 
/// Business Flow:
/// - ONE Commissary organization supplies ingredients and items
/// - MANY Franchisee organizations order from commissary and sell to customers
/// 
/// Example:
/// - Organization: "Main Commissary" (type: commissary)
/// - Organization: "Branch Makati" (type: franchisee, parent: Main Commissary)
/// - Organization: "Branch Quezon City" (type: franchisee, parent: Main Commissary)
class Organizations extends Table {
  /// Primary key
  IntColumn get id => integer().autoIncrement()();
  
  /// Organization name (e.g., "Main Commissary", "Branch Makati")
  TextColumn get name => text().withLength(min: 3, max: 200)();
  
  /// Type of organization: 'commissary' or 'franchisee'
  /// - commissary: Creates ingredients and items, supplies franchisees
  /// - franchisee: Orders from commissary, sells to customers
  TextColumn get type => text().withLength(min: 3, max: 50)();
  
  /// For franchisees: Reference to parent commissary
  /// For commissary: NULL (they are the top-level)
  IntColumn get parentCommissaryId => integer().nullable().references(Organizations, #id)();
  
  /// Contact information
  TextColumn get contactPerson => text().nullable().withLength(max: 200)();
  TextColumn get phone => text().nullable().withLength(max: 50)();
  TextColumn get email => text().nullable().withLength(max: 200)();
  
  /// Physical address
  TextColumn get address => text().nullable().withLength(max: 500)();
  
  /// Track when organization was created/modified
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get lastUpdated => dateTime().clientDefault(() => DateTime.now())();
  
  /// Active status (for soft delete)
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  /// Sync fields for cloud synchronization
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get cloudId => text().nullable()();
}