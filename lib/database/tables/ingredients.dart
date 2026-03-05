// lib/database/tables/ingredients.dart
import 'package:drift/drift.dart';
import 'organizations.dart';

/// Ingredients table — aligned to Supabase schema.
///
/// Cloud schema: ingredients (id, cloud_id, name, unit, stock, critical_level,
///   cost_per_unit, commissary_id, is_active, created_at, updated_at,
///   last_synced_at, needs_sync, last_updated)
class Ingredients extends Table {
  /// Primary key — matches Supabase serial PK
  IntColumn get id => integer().autoIncrement()();

  /// UUID synced with Supabase — NOT NULL, UNIQUE (matches cloud constraint)
  TextColumn get cloudId => text()();

  /// Ingredient name (e.g., "Chicken Breast", "Garlic", "Soy Sauce")
  TextColumn get name => text().withLength(min: 1, max: 200)();

  /// Which commissary owns this ingredient (INTEGER FK, not UUID)
  IntColumn get commissaryId => integer().references(Organizations, #id)();

  /// Current stock quantity — REAL to match Supabase double precision
  RealColumn get stock => real().withDefault(const Constant(0.0))();

  /// Unit of measurement (e.g., "kg", "pieces", "liters", "grams")
  TextColumn get unit => text()
      .withLength(min: 1, max: 50)
      .withDefault(const Constant('pieces'))();

  /// Low-stock threshold — matches Supabase critical_level (replaces minimum_stock)
  RealColumn get criticalLevel => real().nullable()();

  /// Cost per unit — matches Supabase cost_per_unit
  RealColumn get costPerUnit => real().withDefault(const Constant(0.0))();

  /// Active flag — inverse of old is_deleted, matches Supabase is_active
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Pending sync flag — inverse of old is_synced, matches Supabase needs_sync
  BoolColumn get needsSync => boolean().withDefault(const Constant(true))();

  /// Creation timestamp
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();

  /// Last local modification timestamp — matches Supabase last_updated
  DateTimeColumn get lastUpdated =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();

  /// Last write timestamp (may be updated by Supabase trigger)
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();

  /// Last time this row was confirmed by the cloud
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {cloudId},
      ];
}
