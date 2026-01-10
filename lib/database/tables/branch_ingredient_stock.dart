// lib/database/tables/branch_ingredient_stock.dart
import 'package:drift/drift.dart';
import 'ingredients.dart';
import 'organizations.dart';

/// BranchIngredientStock table - Per-branch ingredient inventory
///
/// Purpose:
/// 1. Each branch tracks their own ingredient stock independently
/// 2. Commissary distributes ingredients to branches
/// 3. Branches consume ingredients when making items (if applicable)
///
/// Storage Efficiency:
/// - Only stores branch-specific data (quantity, dates)
/// - Ingredient name, unit, description come from master Ingredients table
/// - No duplication of ingredient metadata per branch
///
/// Data Flow:
/// 1. Commissary creates master ingredient in Ingredients table
/// 2. When distributing to branch, create/update BranchIngredientStock row
/// 3. Branch uses ingredients → updates their own stock quantity
/// 4. Commissary can view all branches' ingredient levels
class BranchIngredientStock extends Table {
  /// Primary key
  IntColumn get id => integer().autoIncrement()();

  /// Which branch owns this stock
  IntColumn get organizationId => integer().references(Organizations, #id)();

  /// Reference to master ingredient (for name, unit, etc.)
  IntColumn get ingredientId => integer().references(Ingredients, #id)();

  /// Current stock quantity at this branch
  RealColumn get quantity => real().withDefault(const Constant(0.0))();

  /// Minimum stock level for alerts
  RealColumn get minimumStock => real().nullable()();

  /// Last time this branch received a delivery of this ingredient
  DateTimeColumn get lastReceivedAt => dateTime().nullable()();

  /// Quantity from last delivery
  RealColumn get lastReceivedQuantity => real().nullable()();

  /// Track when record was created/modified
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get lastUpdated =>
      dateTime().clientDefault(() => DateTime.now())();

  /// Sync fields for cloud synchronization
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get cloudId => text().nullable()();

  /// Ensure one stock record per ingredient per branch
  @override
  List<Set<Column>> get uniqueKeys => [
        {organizationId, ingredientId},
      ];
}
