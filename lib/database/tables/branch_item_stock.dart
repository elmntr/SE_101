// lib/database/tables/branch_item_stock.dart
import 'package:drift/drift.dart';
import 'items.dart';
import 'organizations.dart';

/// BranchItemStock table - Per-branch item inventory
///
/// Purpose:
/// This table enables the multi-branch inventory system where:
/// 1. Commissary maintains a master catalog of items (in Items table)
/// 2. Each branch tracks their own stock levels independently
/// 3. Sales, spoilage, and stock movements are per-branch
///
/// Business Flow:
/// 1. Commissary creates master item in Items table (master_item_id = NULL)
/// 2. When franchisee syncs, they get a BranchItemStock record for each master item
/// 3. Franchisee receives items → update stock in BranchItemStock
/// 4. Franchisee sells/spoils items → update sold/spoilage in BranchItemStock
/// 5. Commissary can view all branches' stock levels
///
/// Key Difference from Items table:
/// - Items: Master product catalog (name, description, recipe, etc.)
/// - BranchItemStock: Per-branch quantities (stock, sold, spoilage, price)
///
/// This design:
/// - Avoids duplicating item metadata across branches
/// - Allows branch-specific pricing
/// - Enables easy network-wide inventory queries
class BranchItemStock extends Table {
  /// Primary key
  IntColumn get id => integer().autoIncrement()();

  /// Which branch owns this stock
  IntColumn get organizationId => integer().references(Organizations, #id)();

  /// Reference to master item (for name, description, recipe, etc.)
  IntColumn get itemId => integer().references(Items, #id)();

  /// Current stock quantity at this branch
  IntColumn get stock => integer().withDefault(const Constant(0))();

  /// Total sold quantity (can be cumulative or daily-reset)
  IntColumn get sold => integer().withDefault(const Constant(0))();

  /// Total spoiled quantity
  IntColumn get spoilage => integer().withDefault(const Constant(0))();

  /// Branch-specific selling price (overrides master item price if set)
  RealColumn get price => real().nullable()();

  /// Branch-specific cost price (what they pay commissary)
  RealColumn get costPrice => real().nullable()();

  /// Minimum stock level for low stock alerts
  IntColumn get minimumStock => integer().nullable()();

  /// Last time this branch received a delivery of this item
  DateTimeColumn get lastReceivedAt => dateTime().nullable()();

  /// Quantity from last delivery
  IntColumn get lastReceivedQuantity => integer().nullable()();

  /// Track when record was created/modified
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get lastUpdated =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();

  /// Soft delete
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Sync fields for cloud synchronization
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get cloudId => text().nullable()();

  /// Ensure one stock record per item per branch
  @override
  List<Set<Column>> get uniqueKeys => [
    {organizationId, itemId},
  ];
}
