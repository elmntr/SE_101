// lib/database/daos/recipe_ingredients_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/recipe_ingredients.dart';
import '../tables/items.dart';
import '../tables/ingredients.dart';

part 'recipe_ingredients_dao.g.dart';

/// RecipeIngredientsDao - Manage recipe compositions (what ingredients make up each item)
///
/// Business Logic:
/// - Links Items (final products) to Ingredients (raw materials)
/// - Tracks quantity of each ingredient needed per item
/// - Used to calculate ingredient requirements when producing items
/// - Used to check if enough ingredients are available
@DriftAccessor(tables: [RecipeIngredients, Items, Ingredients])
class RecipeIngredientsDao extends DatabaseAccessor<AppDatabase>
    with _$RecipeIngredientsDaoMixin {
  RecipeIngredientsDao(super.db);

  static const int defaultPageSize = 50;

  // ============================================================================
  // BASIC CRUD OPERATIONS
  // ============================================================================

  /// ✅ Get all recipe ingredients with pagination
  Future<List<RecipeIngredient>> getAllRecipeIngredients({
    int? limit,
    int offset = 0,
    int? itemId,
    int? ingredientId,
  }) async {
    try {
      final query = select(recipeIngredients)
        ..where((t) => t.isDeleted.equals(false));

      if (itemId != null) {
        query.where((t) => t.itemId.equals(itemId));
      }

      if (ingredientId != null) {
        query.where((t) => t.ingredientId.equals(ingredientId));
      }

      query.orderBy([(t) => OrderingTerm(expression: t.id)]);

      if (limit != null) {
        query.limit(limit, offset: offset);
      }

      return await query.get();
    } catch (e) {
      //print('❌ Error fetching recipe ingredients: $e');
      return [];
    }
  }

  /// ✅ Get ingredients for a specific item/recipe
  Future<List<RecipeIngredient>> getIngredientsForItem(int itemId) async {
    try {
      return await (select(recipeIngredients)
            ..where((t) => t.itemId.equals(itemId) & t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.id)]))
          .get();
    } catch (e) {
      //print('❌ Error fetching ingredients for item: $e');
      return [];
    }
  }

  /// ✅ Watch ingredients for a specific item (real-time updates)
  Stream<List<RecipeIngredient>> watchIngredientsForItem(int itemId) {
    try {
      return (select(recipeIngredients)
            ..where((t) => t.itemId.equals(itemId) & t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.id)]))
          .watch();
    } catch (e) {
      //print('❌ Error watching ingredients for item: $e');
      return Stream.value([]);
    }
  }

  /// ✅ Get items that use a specific ingredient
  Future<List<RecipeIngredient>> getItemsUsingIngredient(
    int ingredientId,
  ) async {
    try {
      return await (select(recipeIngredients)
            ..where(
              (t) =>
                  t.ingredientId.equals(ingredientId) &
                  t.isDeleted.equals(false),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.id)]))
          .get();
    } catch (e) {
      //print('❌ Error fetching items using ingredient: $e');
      return [];
    }
  }

  /// ✅ Insert a new recipe ingredient
  Future<int> insertRecipeIngredient({
    required int itemId,
    required int ingredientId,
    required double quantityNeeded,
    required String unit,
    String? notes,
    String? cloudId,
  }) async {
    try {
      return await into(recipeIngredients).insert(
        RecipeIngredientsCompanion.insert(
          itemId: itemId,
          ingredientId: ingredientId,
          quantityNeeded: quantityNeeded,
          unit: unit,
          notes: Value(notes),
          isSynced: Value(false),
          cloudId: Value(cloudId),
        ),
      );
    } catch (e) {
      //print('❌ Error inserting recipe ingredient: $e');
      rethrow;
    }
  }

  /// ✅ Batch insert recipe ingredients (for creating complete recipes)
  Future<void> insertRecipeIngredients(
    List<RecipeIngredientsCompanion> recipeIngredientsList,
  ) async {
    try {
      await db.batch((batch) {
        batch.insertAll(recipeIngredients, recipeIngredientsList);
      });
    } catch (e) {
      //print('❌ Error batch inserting recipe ingredients: $e');
      rethrow;
    }
  }

  /// ✅ Update an existing recipe ingredient
  Future<bool> updateRecipeIngredient(RecipeIngredient recipeIngredient) async {
    try {
      final updated = recipeIngredient.copyWith(
        isSynced: false,
        lastUpdated: DateTime.now().toUtc(),
      );
      return await update(recipeIngredients).replace(updated);
    } catch (e) {
      //print('❌ Error updating recipe ingredient: $e');
      return false;
    }
  }

  /// ✅ Get recipe ingredient by ID
  Future<RecipeIngredient?> getRecipeIngredientById(int id) async {
    try {
      return await (select(
        recipeIngredients,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
    } catch (e) {
      //print('❌ Error fetching recipe ingredient by ID: $e');
      return null;
    }
  }

  /// ✅ Soft delete recipe ingredient
  Future<bool> softDeleteRecipeIngredient(int id) async {
    try {
      final result =
          await (update(
            recipeIngredients,
          )..where((t) => t.id.equals(id))).write(
            RecipeIngredientsCompanion(
              isDeleted: Value(true),
              isSynced: Value(false),
              lastUpdated: Value(DateTime.now().toUtc()),
            ),
          );
      return result > 0;
    } catch (e) {
      //print('❌ Error soft deleting recipe ingredient: $e');
      return false;
    }
  }

  /// ✅ Delete all recipe ingredients for an item
  Future<int> deleteAllForItem(int itemId) async {
    try {
      final result =
          await (update(
            recipeIngredients,
          )..where((t) => t.itemId.equals(itemId))).write(
            RecipeIngredientsCompanion(
              isDeleted: Value(true),
              isSynced: Value(false),
              lastUpdated: Value(DateTime.now().toUtc()),
            ),
          );
      return result;
    } catch (e) {
      //print('❌ Error deleting recipe ingredients for item: $e');
      return 0;
    }
  }

  // ============================================================================
  // PRODUCTION CALCULATIONS
  // ============================================================================

  /// ✅ Calculate total ingredient requirements for producing X items
  Future<Map<int, double>> calculateIngredientRequirements(
    int itemId,
    int quantityToProduce,
  ) async {
    try {
      final recipeIngredientsList = await getIngredientsForItem(itemId);

      final requirements = <int, double>{};
      for (final ri in recipeIngredientsList) {
        requirements[ri.ingredientId] = ri.quantityNeeded * quantityToProduce;
      }

      return requirements;
    } catch (e) {
      //print('❌ Error calculating ingredient requirements: $e');
      return {};
    }
  }

  /// ✅ Check if enough ingredients are available to produce X items
  Future<bool> canProduceItems(int itemId, int quantityToProduce) async {
    try {
      final requirements = await calculateIngredientRequirements(
        itemId,
        quantityToProduce,
      );

      for (final entry in requirements.entries) {
        final ingredientId = entry.key;
        final requiredQuantity = entry.value;

        final ingredient = await db.ingredientsDao.getIngredientById(
          ingredientId,
        );
        if (ingredient == null || ingredient.stock < requiredQuantity) {
          //print(
          //  '⚠️ Insufficient ingredient stock: ID $ingredientId (need $requiredQuantity, have ${ingredient?.stock ?? 0})'
          //);
          return false;
        }
      }

      return true;
    } catch (e) {
      //print('❌ Error checking ingredient availability: $e');
      return false;
    }
  }

  /// ✅ Deduct ingredients when producing items
  Future<bool> deductIngredientsForProduction(
    int itemId,
    int quantityProduced,
  ) async {
    try {
      final requirements = await calculateIngredientRequirements(
        itemId,
        quantityProduced,
      );

      // First check if all ingredients are available
      if (!await canProduceItems(itemId, quantityProduced)) {
        return false;
      }

      // Deduct ingredients in a transaction
      return await db.transaction(() async {
        for (final entry in requirements.entries) {
          final ingredientId = entry.key;
          final quantity = entry.value;

          final success = await db.ingredientsDao.deductStock(
            ingredientId,
            quantity,
          );
          if (!success) {
            throw Exception('Failed to deduct ingredient $ingredientId');
          }
        }
        return true;
      });
    } catch (e) {
      //print('❌ Error deducting ingredients: $e');
      return false;
    }
  }

  // ============================================================================
  // RECIPE MANAGEMENT
  // ============================================================================

  /// ✅ Replace entire recipe for an item (atomic operation)
  Future<bool> replaceRecipeForItem(
    int itemId,
    List<RecipeIngredientsCompanion> newRecipe,
  ) async {
    try {
      return await db.transaction(() async {
        // Delete old recipe
        await deleteAllForItem(itemId);

        // Insert new recipe
        await insertRecipeIngredients(newRecipe);

        return true;
      });
    } catch (e) {
      //print('❌ Error replacing recipe: $e');
      return false;
    }
  }

  /// ✅ Get recipe summary (formatted for display)
  Future<String> getRecipeSummary(int itemId) async {
    try {
      final recipeIngredientsList = await getIngredientsForItem(itemId);

      if (recipeIngredientsList.isEmpty) {
        return 'No recipe defined';
      }

      final lines = <String>[];
      for (final ri in recipeIngredientsList) {
        final ingredient = await db.ingredientsDao.getIngredientById(
          ri.ingredientId,
        );
        if (ingredient != null) {
          lines.add('${ri.quantityNeeded} ${ri.unit} ${ingredient.name}');
        }
      }

      return lines.join('\n');
    } catch (e) {
      //print('❌ Error getting recipe summary: $e');
      return 'Error loading recipe';
    }
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// ✅ Get unsynced recipe ingredients (paginated)
  Future<List<RecipeIngredient>> getUnsyncedRecipeIngredients({
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      return await (select(recipeIngredients)
            ..where((t) => t.isSynced.equals(false))
            ..limit(limit, offset: offset))
          .get();
    } catch (e) {
      //print('❌ Error fetching unsynced recipe ingredients: $e');
      return [];
    }
  }

  /// ✅ Count unsynced recipe ingredients
  Future<int> getUnsyncedRecipeIngredientCount() async {
    try {
      final query = selectOnly(recipeIngredients)
        ..addColumns([recipeIngredients.id.count()])
        ..where(recipeIngredients.isSynced.equals(false));

      final result = await query.getSingle();
      return result.read(recipeIngredients.id.count()) ?? 0;
    } catch (e) {
      //print('❌ Error counting unsynced recipe ingredients: $e');
      return 0;
    }
  }

  /// ✅ Mark recipe ingredients as synced (batch)
  Future<void> markAsSynced(
    List<int> recipeIngredientIds, {
    Map<int, String>? cloudIds,
  }) async {
    try {
      await db.batch((batch) {
        for (final id in recipeIngredientIds) {
          batch.update(
            recipeIngredients,
            RecipeIngredientsCompanion(
              isSynced: Value(true),
              cloudId: Value(cloudIds?[id]),
            ),
            where: (t) => t.id.equals(id),
          );
        }
      });
    } catch (e) {
      //print('❌ Error marking recipe ingredients as synced: $e');
      rethrow;
    }
  }

  /// ✅ Batch upsert from cloud
  Future<void> upsertBatchFromCloud(
    List<Map<String, dynamic>> cloudRecipeIngredients,
  ) async {
    try {
      await db.transaction(() async {
        for (final cloudRI in cloudRecipeIngredients) {
          // Map Supabase column names to local column names
          final quantityValue =
              cloudRI['quantity_needed'] ?? cloudRI['quantity'];

          await upsertFromCloud(
            id: cloudRI['id'] ?? cloudRI['local_id'], // Supabase uses 'id'
            itemId: cloudRI['item_id'],
            ingredientId: cloudRI['ingredient_id'],
            quantityNeeded: quantityValue is num
                ? quantityValue.toDouble()
                : 0.0,
            unit: cloudRI['unit'] ?? 'piece',
            notes: cloudRI['notes'],
            createdAt: DateTime.parse(cloudRI['created_at']),
            lastUpdated: DateTime.parse(cloudRI['last_updated']),
            isDeleted: cloudRI['is_deleted'] ?? false,
            cloudId: cloudRI['cloud_id'],
          );
        }
      });
    } catch (e) {
      //print('❌ Error batch upserting recipe ingredients from cloud: $e');
      rethrow;
    }
  }

  /// ✅ Upsert from cloud (individual)
  Future<void> upsertFromCloud({
    required int id,
    required int itemId,
    required int ingredientId,
    required double quantityNeeded,
    required String unit,
    String? notes,
    required DateTime createdAt,
    required DateTime lastUpdated,
    required bool isDeleted,
    required String cloudId,
  }) async {
    try {
      await into(recipeIngredients).insertOnConflictUpdate(
        RecipeIngredientsCompanion.insert(
          id: Value(id),
          itemId: itemId,
          ingredientId: ingredientId,
          quantityNeeded: quantityNeeded,
          unit: unit,
          notes: Value(notes),
          createdAt: Value(createdAt),
          lastUpdated: Value(lastUpdated),
          isDeleted: Value(isDeleted),
          isSynced: Value(true),
          cloudId: Value(cloudId),
        ),
      );
    } catch (e) {
      //print('❌ Error upserting recipe ingredient from cloud: $e');
      rethrow;
    }
  }

  /// ✅ Get recipe ingredient by cloud ID
  Future<RecipeIngredient?> getRecipeIngredientByCloudId(String cloudId) async {
    try {
      return await (select(
        recipeIngredients,
      )..where((t) => t.cloudId.equals(cloudId))).getSingleOrNull();
    } catch (e) {
      //print('❌ Error fetching recipe ingredient by cloud ID: $e');
      return null;
    }
  }
}
