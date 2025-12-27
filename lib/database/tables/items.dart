// lib/database/tables/items.dart
import 'package:drift/drift.dart';
import 'categories.dart';
import 'organizations.dart';

/// Items table - Final products/menu items that are sold to customers
///
/// Business Flow:
/// 1. Commissary creates items using ingredients (via RecipeIngredients)
/// 2. Commissary produces items and sets available stock
/// 3. Franchisee requests items from commissary
/// 4. Franchisee receives items, sets their own price, and sells to customers
/// 5. Employees track sold/spoiled items
///
/// Key Difference from Ingredients:
/// - Ingredients: Raw materials (stock + spoilage, NO sold)
/// - Items: Final products (stock + spoilage + sold)
class Items extends Table {
  /// Primary key
  IntColumn get id => integer().autoIncrement()();

  /// Item name (e.g., "Fried Chicken Meal", "Burger Combo")
  TextColumn get name => text().withLength(min: 1, max: 200)();

  /// Optional category for filtering (e.g., "Food", "Beverages")
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();

  /// Which organization owns this item
  /// - If commissary: This is the master item that can be ordered
  /// - If franchisee: This is their local copy with their own price
  IntColumn get organizationId => integer().references(Organizations, #id)();

  /// For franchisee items: Reference to the commissary's master item
  /// For commissary items: NULL (they are the master)
  IntColumn get masterItemId => integer().nullable().references(Items, #id)();

  /// Current stock quantity
  IntColumn get stock => integer().withDefault(const Constant(0))();

  /// Total sold quantity (cumulative)
  IntColumn get sold => integer().withDefault(const Constant(0))();

  /// Total spoiled quantity (cumulative)
  IntColumn get spoilage => integer().withDefault(const Constant(0))();

  /// Price set by franchisee (for their customers)
  /// Commissary items may not have a price (only franchisee sets retail price)
  RealColumn get price => real().nullable()();

  /// Cost per unit (for franchisee to know their cost from commissary)
  RealColumn get costPrice => real().nullable()();

  /// Unit of measurement (e.g., "piece", "serving", "box")
  TextColumn get unit =>
      text().withLength(min: 1, max: 50).withDefault(const Constant('piece'))();

  /// Minimum stock threshold for low stock alerts
  IntColumn get minimumStock => integer().nullable()();

  /// Optional description
  TextColumn get description => text().nullable().withLength(max: 1000)();

  /// Track when item was created/modified
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get lastUpdated =>
      dateTime().clientDefault(() => DateTime.now())();

  /// Soft delete
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Sync fields for cloud synchronization
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get cloudId => text().nullable()();
}
