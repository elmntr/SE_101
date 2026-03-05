// lib/database/daos/ingredients_dao.dart
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/ingredients.dart';
import '../tables/organizations.dart';

part 'ingredients_dao.g.dart';

/// IngredientsDao â€” manages raw materials/ingredients for the commissary.
///
/// Local schema is aligned to Supabase:
///   stock / criticalLevel   â†’ REAL (double precision)
///   isActive                â†’ true = visible  (was isDeleted = false)
///   needsSync               â†’ true = pending  (was isSynced = false)
///   cloudId                 â†’ NOT NULL, UNIQUE
@DriftAccessor(tables: [Ingredients, Organizations])
class IngredientsDao extends DatabaseAccessor<AppDatabase>
    with _$IngredientsDaoMixin {
  IngredientsDao(super.db);

  static const _uuid = Uuid();
  static const int defaultPageSize = 50;
  static const int maxPageSize = 100;

  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  /// Get all active ingredients with optional filters and pagination.
  Future<List<Ingredient>> getAllIngredients({
    int? limit,
    int offset = 0,
    String? searchQuery,
    int? commissaryId,
    IngredientSortOrder sortOrder = IngredientSortOrder.nameAsc,
  }) async {
    try {
      final query = select(ingredients)
        ..where((t) => t.isActive.equals(true));

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query.where((t) => t.name.contains(searchQuery));
      }

      if (commissaryId != null) {
        query.where((t) => t.commissaryId.equals(commissaryId));
      }

      query.orderBy([
        (t) {
          switch (sortOrder) {
            case IngredientSortOrder.nameAsc:
              return OrderingTerm(expression: t.name, mode: OrderingMode.asc);
            case IngredientSortOrder.nameDesc:
              return OrderingTerm(expression: t.name, mode: OrderingMode.desc);
            case IngredientSortOrder.stockAsc:
              return OrderingTerm(expression: t.stock, mode: OrderingMode.asc);
            case IngredientSortOrder.stockDesc:
              return OrderingTerm(expression: t.stock, mode: OrderingMode.desc);
            case IngredientSortOrder.newestFirst:
              return OrderingTerm(
                  expression: t.createdAt, mode: OrderingMode.desc);
            case IngredientSortOrder.oldestFirst:
              return OrderingTerm(
                  expression: t.createdAt, mode: OrderingMode.asc);
          }
        },
      ]);

      if (limit != null) {
        final safeLimit = limit > maxPageSize ? maxPageSize : limit;
        query.limit(safeLimit, offset: offset);
      }

      return await query.get();
    } catch (e) {
      rethrow;
    }
  }

  /// Total count of active ingredients (for pagination).
  Future<int> getIngredientCount({
    String? searchQuery,
    int? commissaryId,
  }) async {
    try {
      final query = selectOnly(ingredients)
        ..addColumns([ingredients.id.count()])
        ..where(ingredients.isActive.equals(true));

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query.where(ingredients.name.contains(searchQuery));
      }

      if (commissaryId != null) {
        query.where(ingredients.commissaryId.equals(commissaryId));
      }

      final result = await query.getSingle();
      return result.read(ingredients.id.count()) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Real-time stream of active ingredients for a commissary.
  Stream<List<Ingredient>> watchAllIngredients({
    int limit = defaultPageSize,
    int offset = 0,
    int? commissaryId,
  }) {
    try {
      final query = select(ingredients)
        ..where((t) => t.isActive.equals(true));

      if (commissaryId != null) {
        query.where((t) => t.commissaryId.equals(commissaryId));
      }

      query
        ..orderBy([(t) => OrderingTerm(expression: t.name)])
        ..limit(limit, offset: offset);

      return query.watch();
    } catch (e) {
      return Stream.value([]);
    }
  }

  /// Get ingredient by local ID.
  Future<Ingredient?> getIngredientById(int id) async {
    try {
      return await (select(ingredients)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
    } catch (e) {
      return null;
    }
  }

  /// Get ingredient by cloud UUID.
  Future<Ingredient?> getIngredientByCloudId(String cloudId) async {
    try {
      return await (select(ingredients)
            ..where((t) => t.cloudId.equals(cloudId)))
          .getSingleOrNull();
    } catch (e) {
      return null;
    }
  }

  /// Get ingredient by name (case-insensitive) within a commissary.
  Future<Ingredient?> getIngredientByName(
    String name, {
    int? commissaryId,
  }) async {
    try {
      final query = select(ingredients)
        ..where((t) =>
            t.name.lower().equals(name.toLowerCase()) &
            t.isActive.equals(true));

      if (commissaryId != null) {
        query.where((t) => t.commissaryId.equals(commissaryId));
      }

      return await query.getSingleOrNull();
    } catch (e) {
      return null;
    }
  }

  /// Ingredients whose stock is at or below their critical level.
  Future<List<Ingredient>> getLowStockIngredients({int? commissaryId}) async {
    try {
      final query = '''
        SELECT * FROM ingredients
        WHERE is_active = 1
        AND critical_level IS NOT NULL
        AND stock <= critical_level
        ${commissaryId != null ? 'AND commissary_id = ?' : ''}
        ORDER BY stock ASC
      ''';

      final results = await customSelect(
        query,
        variables:
            commissaryId != null ? [Variable.withInt(commissaryId)] : [],
        readsFrom: {ingredients},
      ).get();

      return results.map((row) => Ingredient(
            id: row.read<int>('id'),
            cloudId: row.read<String>('cloud_id'),
            name: row.read<String>('name'),
            commissaryId: row.read<int>('commissary_id'),
            stock: row.read<double>('stock'),
            unit: row.read<String>('unit'),
            criticalLevel: row.readNullable<double>('critical_level'),
            costPerUnit: row.read<double>('cost_per_unit'),
            isActive: row.read<bool>('is_active'),
            needsSync: row.read<bool>('needs_sync'),
            createdAt: row.read<DateTime>('created_at'),
            lastUpdated: row.read<DateTime>('last_updated'),
            updatedAt: row.read<DateTime>('updated_at'),
            lastSyncedAt: row.readNullable<DateTime>('last_synced_at'),
          )).toList();
    } catch (e) {
      return [];
    }
  }

  /// Ingredients with zero stock.
  Future<List<Ingredient>> getOutOfStockIngredients(
      {int? commissaryId}) async {
    try {
      final query = select(ingredients)
        ..where(
            (t) => t.isActive.equals(true) & t.stock.isSmallerOrEqualValue(0));

      if (commissaryId != null) {
        query.where((t) => t.commissaryId.equals(commissaryId));
      }

      query.orderBy([(t) => OrderingTerm(expression: t.name)]);
      return await query.get();
    } catch (e) {
      return [];
    }
  }

  // ============================================================================
  // WRITE OPERATIONS
  // ============================================================================

  /// Insert a new ingredient. Auto-generates a cloudId UUID if not supplied.
  ///
  /// Throws if an active ingredient with the same name already exists.
  Future<int> insertIngredient({
    required String name,
    required int commissaryId,
    double stock = 0,
    String? unit,
    double? criticalLevel,
    double costPerUnit = 0,
    String? cloudId,
  }) async {
    try {
      final existing = await getIngredientByName(name,
          commissaryId: commissaryId);
      if (existing != null) {
        throw Exception('An ingredient with the name "$name" already exists');
      }

      return await into(ingredients).insert(
        IngredientsCompanion.insert(
          cloudId: cloudId ?? _uuid.v4(),
          name: name,
          commissaryId: commissaryId,
          stock: Value(stock),
          unit: Value(unit ?? 'pieces'),
          criticalLevel: Value(criticalLevel),
          costPerUnit: Value(costPerUnit),
          needsSync: const Value(true),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Batch insert from a list of companions (used by the form dialog save path).
  Future<void> insertIngredients(
      List<IngredientsCompanion> ingredientsList) async {
    try {
      await db.batch((batch) {
        batch.insertAll(ingredients, ingredientsList);
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Replace an ingredient row entirely (sets needsSync=true, updatedAt=now).
  Future<bool> updateIngredient(Ingredient ingredient) async {
    try {
      final updated = ingredient.copyWith(
        needsSync: true,
        lastUpdated: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );
      return await update(ingredients).replace(updated);
    } catch (e) {
      return false;
    }
  }

  // ============================================================================
  // STOCK MANAGEMENT
  // ============================================================================

  /// Atomically add stock (e.g., after a replenishment delivery).
  Future<bool> addStock(int ingredientId, double quantity) async {
    if (quantity <= 0) throw ArgumentError('Quantity must be positive');
    try {
      final result = await customUpdate(
        'UPDATE ingredients SET '
        'stock = stock + ?, '
        'last_updated = ?, '
        'updated_at = ?, '
        'needs_sync = 1 '
        'WHERE id = ?',
        updates: {ingredients},
        variables: [
          Variable.withReal(quantity),
          Variable.withDateTime(DateTime.now().toUtc()),
          Variable.withDateTime(DateTime.now().toUtc()),
          Variable.withInt(ingredientId),
        ],
      );
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  /// Atomically deduct stock (e.g., used in production). Returns false if
  /// insufficient stock.
  Future<bool> deductStock(int ingredientId, double quantity) async {
    if (quantity <= 0) throw ArgumentError('Quantity must be positive');
    try {
      final result = await customUpdate(
        'UPDATE ingredients SET '
        'stock = stock - ?, '
        'last_updated = ?, '
        'updated_at = ?, '
        'needs_sync = 1 '
        'WHERE id = ? AND stock >= ?',
        updates: {ingredients},
        variables: [
          Variable.withReal(quantity),
          Variable.withDateTime(DateTime.now().toUtc()),
          Variable.withDateTime(DateTime.now().toUtc()),
          Variable.withInt(ingredientId),
          Variable.withReal(quantity),
        ],
      );
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  /// Overwrite stock level directly.
  Future<bool> updateStock(int ingredientId, double newStock) async {
    if (newStock < 0) throw ArgumentError('Stock cannot be negative');
    try {
      final result =
          await (update(ingredients)..where((t) => t.id.equals(ingredientId)))
              .write(IngredientsCompanion(
        stock: Value(newStock),
        lastUpdated: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
        needsSync: const Value(true),
      ));
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  // ============================================================================
  // DELETE OPERATIONS
  // ============================================================================

  /// Soft-delete: marks isActive=false. Blocked if ingredient is in any recipe.
  Future<bool> softDeleteIngredient(int id) async {
    try {
      final recipeCount = await _getRecipeUsageCount(id);
      if (recipeCount > 0) {
        throw Exception('Ingredient is used in $recipeCount recipe(s)');
      }

      final result =
          await (update(ingredients)..where((t) => t.id.equals(id))).write(
        IngredientsCompanion(
          isActive: const Value(false),
          needsSync: const Value(true),
          lastUpdated: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      return result > 0;
    } catch (e) {
      rethrow;
    }
  }

  Future<int> _getRecipeUsageCount(int ingredientId) async {
    try {
      final query = selectOnly(db.recipeIngredients)
        ..addColumns([db.recipeIngredients.id.count()])
        ..where(db.recipeIngredients.ingredientId.equals(ingredientId) &
            db.recipeIngredients.isDeleted.equals(false));
      final result = await query.getSingle();
      return result.read(db.recipeIngredients.id.count()) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// Rows that need to be pushed to Supabase (needsSync = true).
  Future<List<Ingredient>> getUnsyncedIngredients(
      {int limit = 100, int offset = 0}) async {
    try {
      return await (select(ingredients)
            ..where((t) => t.needsSync.equals(true))
            ..limit(limit, offset: offset))
          .get();
    } catch (e) {
      return [];
    }
  }

  /// Count of rows pending push.
  Future<int> getUnsyncedIngredientCount() async {
    try {
      final query = selectOnly(ingredients)
        ..addColumns([ingredients.id.count()])
        ..where(ingredients.needsSync.equals(true));
      final result = await query.getSingle();
      return result.read(ingredients.id.count()) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Mark rows as synced (needsSync=false, lastSyncedAt=now).
  Future<void> markAsSynced(List<int> ingredientIds,
      {Map<int, String>? cloudIds}) async {
    try {
      await db.batch((batch) {
        for (final id in ingredientIds) {
          batch.update(
            ingredients,
            IngredientsCompanion(
              needsSync: const Value(false),
              lastSyncedAt: Value(DateTime.now().toUtc()),
              cloudId: cloudIds != null && cloudIds.containsKey(id)
                  ? Value(cloudIds[id]!)
                  : const Value.absent(),
            ),
            where: (t) => t.id.equals(id),
          );
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Batch upsert records pulled from Supabase.
  Future<void> upsertBatchFromCloud(
      List<Map<String, dynamic>> cloudIngredients) async {
    try {
      await db.transaction(() async {
        for (final row in cloudIngredients) {
          // toLocalFormat() converts keys to camelCase and DateTime fields to
          // actual DateTime objects. Accept both camelCase (from sync engine)
          // and snake_case (direct cloud) keys for resilience.
          final id = row['id'] as int?;
          final cloudId = (row['cloudId'] ?? row['cloud_id']) as String?;
          final name = (row['name']) as String?;
          final commissaryId =
              (row['commissaryId'] ?? row['commissary_id']) as int?;

          if (id == null || cloudId == null || name == null ||
              commissaryId == null) {
            // Skip malformed records
            continue;
          }

          final rawStock = row['stock'] as num?;
          final rawCritical =
              (row['criticalLevel'] ?? row['critical_level']) as num?;
          final rawCost =
              (row['costPerUnit'] ?? row['cost_per_unit']) as num?;
          final isActive =
              (row['isActive'] ?? row['is_active']) as bool? ?? true;
          final needsSync =
              (row['needsSync'] ?? row['needs_sync']) as bool? ?? false;

          // DateTime fields: already DateTime if coming from toLocalFormat,
          // otherwise parse from string.
          DateTime _toDateTime(dynamic v, DateTime fallback) {
            if (v is DateTime) return v.toUtc();
            if (v is String) return DateTime.parse(v).toUtc();
            return fallback;
          }

          final now = DateTime.now().toUtc();
          final createdAt = _toDateTime(
              row['createdAt'] ?? row['created_at'], now);
          final lastUpdated = _toDateTime(
              row['lastUpdated'] ?? row['last_updated'], now);
          final updatedAt = _toDateTime(
              row['updatedAt'] ?? row['updated_at'], lastUpdated);
          final lastSyncedRaw =
              row['lastSyncedAt'] ?? row['last_synced_at'];
          final lastSyncedAt = lastSyncedRaw != null
              ? _toDateTime(lastSyncedRaw, now)
              : null;

          await upsertFromCloud(
            id: id,
            cloudId: cloudId,
            name: name,
            commissaryId: commissaryId,
            stock: rawStock?.toDouble() ?? 0.0,
            unit: row['unit'] as String? ?? 'pieces',
            criticalLevel: rawCritical?.toDouble(),
            costPerUnit: rawCost?.toDouble() ?? 0.0,
            isActive: isActive,
            needsSync: needsSync,
            createdAt: createdAt,
            lastUpdated: lastUpdated,
            updatedAt: updatedAt,
            lastSyncedAt: lastSyncedAt,
          );
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Upsert a single record from Supabase.
  Future<void> upsertFromCloud({
    required int id,
    required String cloudId,
    required String name,
    required int commissaryId,
    required double stock,
    required String unit,
    double? criticalLevel,
    required double costPerUnit,
    required bool isActive,
    required bool needsSync,
    required DateTime createdAt,
    required DateTime lastUpdated,
    required DateTime updatedAt,
    DateTime? lastSyncedAt,
  }) async {
    try {
      await into(ingredients).insertOnConflictUpdate(
        IngredientsCompanion.insert(
          id: Value(id),
          cloudId: cloudId,
          name: name,
          commissaryId: commissaryId,
          stock: Value(stock),
          unit: Value(unit),
          criticalLevel: Value(criticalLevel),
          costPerUnit: Value(costPerUnit),
          isActive: Value(isActive),
          needsSync: Value(needsSync),
          createdAt: Value(createdAt),
          lastUpdated: Value(lastUpdated),
          updatedAt: Value(updatedAt),
          lastSyncedAt: Value(lastSyncedAt),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}

/// Sort options for ingredient lists.
enum IngredientSortOrder {
  nameAsc,
  nameDesc,
  stockAsc,
  stockDesc,
  newestFirst,
  oldestFirst,
}

