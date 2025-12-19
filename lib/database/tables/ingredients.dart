// lib/database/tables/ingredients.dart
import 'package:drift/drift.dart';
import 'categories.dart';
import 'organizations.dart';

/// Ingredients table - Raw materials managed by commissary
/// 
/// Business Flow:
/// 1. Commissary creates ingredients (e.g., "Chicken Breast", "Cooking Oil")
/// 2. These ingredients are used to create Items/Recipes
/// 3. Ingredients track stock and spoilage (but NOT sold - they're not sold directly)
/// 
/// Key Difference from Items:
/// - Ingredients: Raw materials, have stock + spoilage (NO sold)
/// - Items: Final products, have stock + spoilage + sold
class Ingredients extends Table {
  /// Primary key
  IntColumn get id => integer().autoIncrement()();
  
  /// Ingredient name (e.g., "Chicken Breast", "Garlic", "Soy Sauce")
  TextColumn get name => text().withLength(min: 1, max: 200)();
  
  /// Optional category for organization (e.g., "Poultry", "Vegetables", "Spices")
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  
  /// Which commissary owns this ingredient
  /// Only commissary-type organizations can create ingredients
  IntColumn get commissaryId => integer().references(Organizations, #id)();
  
  /// Current stock quantity (in base unit)
  IntColumn get stock => integer().withDefault(const Constant(0))();
  
  /// Spoiled quantity (deducted from stock when recorded)
  IntColumn get spoilage => integer().withDefault(const Constant(0))();
  
  /// Unit of measurement (e.g., "kg", "pieces", "liters", "grams")
  TextColumn get unit => text().withLength(min: 1, max: 50).withDefault(const Constant('pieces'))();
  
  /// Minimum stock threshold for alerts (e.g., alert when stock < 10)
  IntColumn get minimumStock => integer().nullable()();
  
  /// Optional description or notes
  TextColumn get description => text().nullable().withLength(max: 500)();
  
  /// Track when ingredient was created/modified
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get lastUpdated => dateTime().clientDefault(() => DateTime.now())();
  
  /// Soft delete
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  
  /// Sync fields for cloud synchronization
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get cloudId => text().nullable()();
}