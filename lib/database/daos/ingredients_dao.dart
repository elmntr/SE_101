// lib/database/daos/ingredients_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/ingredients.dart';
import '../tables/categories.dart';
import '../tables/organizations.dart';

part 'ingredients_dao.g.dart';

/// IngredientsDao - Manage raw materials/ingredients for commissary
///
/// Business Logic:
/// - Only commissary can create/manage ingredients
/// - Ingredients have stock and spoilage (NO sold - they're not sold directly)
/// - Ingredients are used in recipes to create items
/// - Track stock levels for alerts when low
@DriftAccessor(tables: [Ingredients, Categories, Organizations])
class IngredientsDao extends DatabaseAccessor<AppDatabase>
    with _$IngredientsDaoMixin {
  IngredientsDao(super.db);

  static const int defaultPageSize = 50;
  static const int maxPageSize = 100;

  // ============================================================================
  // BASIC CRUD OPERATIONS
  // ============================================================================

  /// ✅ Get all ingredients with pagination
  Future<List<Ingredient>> getAllIngredients({
    int? limit,
    int offset = 0,
    String? searchQuery,
    int? categoryId,
    int? commissaryId,
    IngredientSortOrder sortOrder = IngredientSortOrder.nameAsc,
  }) async {
    try {
      final query = select(ingredients)
        ..where((t) => t.isDeleted.equals(false));

      // Search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query.where((t) => t.name.contains(searchQuery));
      }

      // Category filter
      if (categoryId != null) {
        query.where((t) => t.categoryId.equals(categoryId));
      }

      // Commissary filter
      if (commissaryId != null) {
        query.where((t) => t.commissaryId.equals(commissaryId));
      }

      // Sorting
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
                expression: t.createdAt,
                mode: OrderingMode.desc,
              );
            case IngredientSortOrder.oldestFirst:
              return OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.asc,
              );
          }
        },
      ]);

      // Pagination
      if (limit != null) {
        final safeLimit = limit > maxPageSize ? maxPageSize : limit;
        query.limit(safeLimit, offset: offset);
      }

      return await query.get();
    } catch (e) {
      print('❌ Error fetching ingredients: $e');
      rethrow;
    }
  }

  /// ✅ Get total count for pagination
  Future<int> getIngredientCount({
    String? searchQuery,
    int? categoryId,
    int? commissaryId,
  }) async {
    try {
      final query = selectOnly(ingredients)
        ..addColumns([ingredients.id.count()])
        ..where(ingredients.isDeleted.equals(false));

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query.where(ingredients.name.contains(searchQuery));
      }

      if (categoryId != null) {
        query.where(ingredients.categoryId.equals(categoryId));
      }

      if (commissaryId != null) {
        query.where(ingredients.commissaryId.equals(commissaryId));
      }

      final result = await query.getSingle();
      return result.read(ingredients.id.count()) ?? 0;
    } catch (e) {
      print('❌ Error counting ingredients: $e');
      return 0;
    }
  }

  /// ✅ Watch ingredients (real-time updates)
  Stream<List<Ingredient>> watchAllIngredients({
    int limit = defaultPageSize,
    int offset = 0,
    int? commissaryId,
  }) {
    try {
      final query = select(ingredients)
        ..where((t) => t.isDeleted.equals(false));

      if (commissaryId != null) {
        query.where((t) => t.commissaryId.equals(commissaryId));
      }

      query
        ..orderBy([(t) => OrderingTerm(expression: t.name)])
        ..limit(limit, offset: offset);

      return query.watch();
    } catch (e) {
      print('❌ Error watching ingredients: $e');
      return Stream.value([]);
    }
  }

  /// ✅ Insert a new ingredient
  /// Throws an exception if an ingredient with the same name already exists
  Future<int> insertIngredient({
    required String name,
    required int commissaryId,
    int stock = 0,
    int? categoryId,
    String? unit,
    int? minimumStock,
    String? description,
    String? cloudId,
  }) async {
    try {
      // Check for duplicate ingredient name
      final existingIngredient = await getIngredientByName(
        name,
        commissaryId: commissaryId,
      );
      if (existingIngredient != null) {
        throw Exception('An ingredient with the name "$name" already exists');
      }

      return await into(ingredients).insert(
        IngredientsCompanion.insert(
          name: name,
          commissaryId: commissaryId,
          stock: Value(stock),
          categoryId: Value(categoryId),
          unit: Value(unit ?? 'pieces'),
          minimumStock: Value(minimumStock),
          description: Value(description),
          isSynced: Value(false),
          cloudId: Value(cloudId),
        ),
      );
    } catch (e) {
      print('❌ Error inserting ingredient: $e');
      rethrow;
    }
  }

  /// ✅ Batch insert ingredients
  Future<void> insertIngredients(
    List<IngredientsCompanion> ingredientsList,
  ) async {
    try {
      await db.batch((batch) {
        batch.insertAll(ingredients, ingredientsList);
      });
    } catch (e) {
      print('❌ Error batch inserting ingredients: $e');
      rethrow;
    }
  }

  /// ✅ Update an existing ingredient
  Future<bool> updateIngredient(Ingredient ingredient) async {
    try {
      final updated = ingredient.copyWith(
        isSynced: false,
        lastUpdated: DateTime.now(),
      );
      return await update(ingredients).replace(updated);
    } catch (e) {
      print('❌ Error updating ingredient: $e');
      return false;
    }
  }

  /// ✅ Get ingredient by ID
  Future<Ingredient?> getIngredientById(int id) async {
    try {
      return await (select(
        ingredients,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching ingredient by ID: $e');
      return null;
    }
  }

  /// ✅ Get ingredient by name (case-insensitive)
  Future<Ingredient?> getIngredientByName(
    String name, {
    int? commissaryId,
  }) async {
    try {
      final query = select(ingredients)
        ..where((t) => t.name.lower().equals(name.toLowerCase()) & t.isDeleted.equals(false));

      if (commissaryId != null) {
        query.where((t) => t.commissaryId.equals(commissaryId));
      }

      return await query.getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching ingredient by name: $e');
      return null;
    }
  }

  // ============================================================================
  // STOCK MANAGEMENT
  // ============================================================================

  /// ✅ ATOMIC: Add stock (for replenishment/receiving)
  Future<bool> addStock(int ingredientId, int quantity) async {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be positive');
    }

    try {
      final result = await customUpdate(
        'UPDATE ingredients SET '
        'stock = stock + ?, '
        'last_updated = ?, '
        'is_synced = 0 '
        'WHERE id = ?',
        updates: {ingredients},
        variables: [
          Variable.withInt(quantity),
          Variable.withDateTime(DateTime.now()),
          Variable.withInt(ingredientId),
        ],
      );

      return result > 0;
    } catch (e) {
      print('❌ Error adding ingredient stock: $e');
      return false;
    }
  }

  /// ✅ ATOMIC: Deduct stock (when used in recipes)
  Future<bool> deductStock(int ingredientId, int quantity) async {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be positive');
    }

    try {
      final result = await customUpdate(
        'UPDATE ingredients SET '
        'stock = stock - ?, '
        'last_updated = ?, '
        'is_synced = 0 '
        'WHERE id = ? AND stock >= ?',
        updates: {ingredients},
        variables: [
          Variable.withInt(quantity),
          Variable.withDateTime(DateTime.now()),
          Variable.withInt(ingredientId),
          Variable.withInt(quantity),
        ],
      );

      if (result == 0) {
        print('⚠️ Insufficient stock for ingredient $ingredientId');
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Error deducting ingredient stock: $e');
      return false;
    }
  }

  /// ✅ ATOMIC: Add spoilage and deduct from stock
  Future<bool> addSpoilage(int ingredientId, int quantity) async {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be positive');
    }

    try {
      final result = await customUpdate(
        'UPDATE ingredients SET '
        'spoilage = spoilage + ?, '
        'stock = stock - ?, '
        'last_updated = ?, '
        'is_synced = 0 '
        'WHERE id = ? AND stock >= ?',
        updates: {ingredients},
        variables: [
          Variable.withInt(quantity),
          Variable.withInt(quantity),
          Variable.withDateTime(DateTime.now()),
          Variable.withInt(ingredientId),
          Variable.withInt(quantity),
        ],
      );

      if (result == 0) {
        print('⚠️ Insufficient stock for ingredient $ingredientId');
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Error adding ingredient spoilage: $e');
      return false;
    }
  }

  /// ✅ Update stock directly (with validation)
  Future<bool> updateStock(int ingredientId, int newStock) async {
    if (newStock < 0) {
      throw ArgumentError('Stock cannot be negative');
    }

    try {
      final result =
          await (update(
            ingredients,
          )..where((t) => t.id.equals(ingredientId))).write(
            IngredientsCompanion(
              stock: Value(newStock),
              lastUpdated: Value(DateTime.now()),
              isSynced: Value(false),
            ),
          );
      return result > 0;
    } catch (e) {
      print('❌ Error updating ingredient stock: $e');
      return false;
    }
  }

  // ============================================================================
  // LOW STOCK ALERTS
  // ============================================================================

  /// ✅ Get low stock ingredients
  Future<List<Ingredient>> getLowStockIngredients({int? commissaryId}) async {
    try {
      final query =
          '''
        SELECT * FROM ingredients
        WHERE is_deleted = 0
        AND minimum_stock IS NOT NULL
        AND stock <= minimum_stock
        ${commissaryId != null ? 'AND commissary_id = ?' : ''}
        ORDER BY stock ASC
      ''';

      final results = await customSelect(
        query,
        variables: commissaryId != null ? [Variable.withInt(commissaryId)] : [],
        readsFrom: {ingredients},
      ).get();

      return results.map((row) {
        return Ingredient(
          id: row.read<int>('id'),
          name: row.read<String>('name'),
          commissaryId: row.read<int>('commissary_id'),
          stock: row.read<int>('stock'),
          spoilage: row.read<int>('spoilage'),
          unit: row.read<String>('unit'),
          categoryId: row.readNullable<int>('category_id'),
          minimumStock: row.readNullable<int>('minimum_stock'),
          description: row.readNullable<String>('description'),
          createdAt: row.read<DateTime>('created_at'),
          lastUpdated: row.read<DateTime>('last_updated'),
          isDeleted: row.read<bool>('is_deleted'),
          isSynced: row.read<bool>('is_synced'),
          cloudId: row.readNullable<String>('cloud_id'),
        );
      }).toList();
    } catch (e) {
      print('❌ Error fetching low stock ingredients: $e');
      return [];
    }
  }

  /// ✅ Get out of stock ingredients
  Future<List<Ingredient>> getOutOfStockIngredients({int? commissaryId}) async {
    try {
      final query = select(ingredients)
        ..where((t) => t.isDeleted.equals(false) & t.stock.equals(0));

      if (commissaryId != null) {
        query.where((t) => t.commissaryId.equals(commissaryId));
      }

      query.orderBy([(t) => OrderingTerm(expression: t.name)]);

      return await query.get();
    } catch (e) {
      print('❌ Error fetching out of stock ingredients: $e');
      return [];
    }
  }

  // ============================================================================
  // DELETE OPERATIONS
  // ============================================================================

  /// ✅ Soft delete ingredient
  Future<bool> softDeleteIngredient(int id) async {
    try {
      // Check if ingredient is used in any recipes
      final recipeCount = await _getRecipeUsageCount(id);
      if (recipeCount > 0) {
        print(
          '⚠️ Cannot delete ingredient $id: used in $recipeCount recipe(s)',
        );
        throw Exception('Ingredient is used in $recipeCount recipe(s)');
      }

      final result = await (update(ingredients)..where((t) => t.id.equals(id)))
          .write(
            IngredientsCompanion(
              isDeleted: Value(true),
              isSynced: Value(false),
              lastUpdated: Value(DateTime.now()),
            ),
          );

      return result > 0;
    } catch (e) {
      print('❌ Error soft deleting ingredient: $e');
      rethrow;
    }
  }

  /// ✅ Check if ingredient is used in any recipes
  Future<int> _getRecipeUsageCount(int ingredientId) async {
    try {
      final query = selectOnly(db.recipeIngredients)
        ..addColumns([db.recipeIngredients.id.count()])
        ..where(
          db.recipeIngredients.ingredientId.equals(ingredientId) &
              db.recipeIngredients.isDeleted.equals(false),
        );

      final result = await query.getSingle();
      return result.read(db.recipeIngredients.id.count()) ?? 0;
    } catch (e) {
      print('❌ Error checking recipe usage: $e');
      return 0;
    }
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// ✅ Get unsynced ingredients (paginated)
  Future<List<Ingredient>> getUnsyncedIngredients({
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      return await (select(ingredients)
            ..where((t) => t.isSynced.equals(false))
            ..limit(limit, offset: offset))
          .get();
    } catch (e) {
      print('❌ Error fetching unsynced ingredients: $e');
      return [];
    }
  }

  /// ✅ Count unsynced ingredients
  Future<int> getUnsyncedIngredientCount() async {
    try {
      final query = selectOnly(ingredients)
        ..addColumns([ingredients.id.count()])
        ..where(ingredients.isSynced.equals(false));

      final result = await query.getSingle();
      return result.read(ingredients.id.count()) ?? 0;
    } catch (e) {
      print('❌ Error counting unsynced ingredients: $e');
      return 0;
    }
  }

  /// ✅ Mark ingredients as synced (batch)
  Future<void> markAsSynced(
    List<int> ingredientIds, {
    Map<int, String>? cloudIds,
  }) async {
    try {
      await db.batch((batch) {
        for (final id in ingredientIds) {
          batch.update(
            ingredients,
            IngredientsCompanion(
              isSynced: Value(true),
              cloudId: Value(cloudIds?[id]),
            ),
            where: (t) => t.id.equals(id),
          );
        }
      });
    } catch (e) {
      print('❌ Error marking ingredients as synced: $e');
      rethrow;
    }
  }

  /// ✅ Batch upsert from cloud
  Future<void> upsertBatchFromCloud(
    List<Map<String, dynamic>> cloudIngredients,
  ) async {
    try {
      await db.transaction(() async {
        for (final cloudIngredient in cloudIngredients) {
          // Map Supabase column names to local column names
          final stockValue = cloudIngredient['stock'];
          final criticalLevel = cloudIngredient['critical_level'];
          
          await upsertFromCloud(
            id: cloudIngredient['id'] ?? cloudIngredient['local_id'],  // Supabase uses 'id'
            name: cloudIngredient['name'],
            commissaryId: cloudIngredient['commissary_id'],
            stock: stockValue is num ? stockValue.toInt() : 0,  // Convert double to int
            spoilage: cloudIngredient['spoilage'] ?? 0,  // Default to 0 if not in Supabase
            unit: cloudIngredient['unit'],
            categoryId: cloudIngredient['category_id'],
            minimumStock: criticalLevel is num ? criticalLevel.toInt() : null,  // Map critical_level to minimumStock
            description: cloudIngredient['description'],
            createdAt: DateTime.parse(cloudIngredient['created_at']),
            lastUpdated: DateTime.parse(cloudIngredient['last_updated']),
            isDeleted: cloudIngredient['is_deleted'] ?? cloudIngredient['is_active'] == false,
            cloudId: cloudIngredient['cloud_id'],
          );
        }
      });
    } catch (e) {
      print('❌ Error batch upserting ingredients from cloud: $e');
      rethrow;
    }
  }

  /// ✅ Upsert from cloud (individual)
  Future<void> upsertFromCloud({
    required int id,
    required String name,
    required int commissaryId,
    required int stock,
    required int spoilage,
    required String unit,
    int? categoryId,
    int? minimumStock,
    String? description,
    required DateTime createdAt,
    required DateTime lastUpdated,
    required bool isDeleted,
    required String cloudId,
  }) async {
    try {
      await into(ingredients).insertOnConflictUpdate(
        IngredientsCompanion.insert(
          id: Value(id),
          name: name,
          commissaryId: commissaryId,
          stock: Value(stock),
          spoilage: Value(spoilage),
          unit: Value(unit),
          categoryId: Value(categoryId),
          minimumStock: Value(minimumStock),
          description: Value(description),
          createdAt: Value(createdAt),
          lastUpdated: Value(lastUpdated),
          isDeleted: Value(isDeleted),
          isSynced: Value(true),
          cloudId: Value(cloudId),
        ),
      );
    } catch (e) {
      print('❌ Error upserting ingredient from cloud: $e');
      rethrow;
    }
  }

  /// ✅ Get ingredient by cloud ID
  Future<Ingredient?> getIngredientByCloudId(String cloudId) async {
    try {
      return await (select(
        ingredients,
      )..where((t) => t.cloudId.equals(cloudId))).getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching ingredient by cloud ID: $e');
      return null;
    }
  }
}

/// ✅ Sorting options for ingredients
enum IngredientSortOrder {
  nameAsc,
  nameDesc,
  stockAsc,
  stockDesc,
  newestFirst,
  oldestFirst,
}
