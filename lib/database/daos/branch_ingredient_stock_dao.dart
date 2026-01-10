// lib/database/daos/branch_ingredient_stock_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/branch_ingredient_stock.dart';
import '../tables/ingredients.dart';
import '../tables/organizations.dart';

part 'branch_ingredient_stock_dao.g.dart';

/// Model for ingredient stock with ingredient details
class BranchIngredientWithDetails {
  final BranchIngredientStockData stock;
  final Ingredient ingredient;
  final Organization? organization;

  BranchIngredientWithDetails({
    required this.stock,
    required this.ingredient,
    this.organization,
  });

  String get name => ingredient.name;
  String get unit => ingredient.unit;
  double get quantity => stock.quantity;
  double? get minimumStock => stock.minimumStock;
  bool get isLowStock =>
      stock.minimumStock != null && stock.quantity <= stock.minimumStock!;
}

@DriftAccessor(tables: [BranchIngredientStock, Ingredients, Organizations])
class BranchIngredientStockDao extends DatabaseAccessor<AppDatabase>
    with _$BranchIngredientStockDaoMixin {
  BranchIngredientStockDao(super.db);

  // ═══════════════════════════════════════════════════════════════════════════
  // CRUD OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get all ingredient stocks for a branch
  Future<List<BranchIngredientStockData>> getStocksForBranch(
      int organizationId) async {
    return await (select(branchIngredientStock)
          ..where((t) => t.organizationId.equals(organizationId)))
        .get();
  }

  /// Get stock for a specific ingredient at a branch
  Future<BranchIngredientStockData?> getStock({
    required int organizationId,
    required int ingredientId,
  }) async {
    return await (select(branchIngredientStock)
          ..where((t) => t.organizationId.equals(organizationId))
          ..where((t) => t.ingredientId.equals(ingredientId)))
        .getSingleOrNull();
  }

  /// Get ingredient stocks with full ingredient details
  Future<List<BranchIngredientWithDetails>> getStocksWithDetails(
      int organizationId) async {
    final query = select(branchIngredientStock).join([
      innerJoin(
        ingredients,
        ingredients.id.equalsExp(branchIngredientStock.ingredientId),
      ),
    ])
      ..where(branchIngredientStock.organizationId.equals(organizationId));

    final results = await query.get();

    return results.map((row) {
      return BranchIngredientWithDetails(
        stock: row.readTable(branchIngredientStock),
        ingredient: row.readTable(ingredients),
      );
    }).toList();
  }

  /// Watch ingredient stocks for real-time UI updates
  Stream<List<BranchIngredientWithDetails>> watchStocksWithDetails(
      int organizationId) {
    final query = select(branchIngredientStock).join([
      innerJoin(
        ingredients,
        ingredients.id.equalsExp(branchIngredientStock.ingredientId),
      ),
    ])
      ..where(branchIngredientStock.organizationId.equals(organizationId))
      ..orderBy([OrderingTerm.asc(ingredients.name)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return BranchIngredientWithDetails(
          stock: row.readTable(branchIngredientStock),
          ingredient: row.readTable(ingredients),
        );
      }).toList();
    });
  }

  /// Insert or update stock for an ingredient at a branch
  Future<int> upsertStock(BranchIngredientStockCompanion stock) async {
    return into(branchIngredientStock).insertOnConflictUpdate(stock);
  }

  /// Update quantity (e.g., after receiving delivery or consumption)
  Future<void> updateQuantity({
    required int organizationId,
    required int ingredientId,
    required double newQuantity,
  }) async {
    await (update(branchIngredientStock)
          ..where((t) => t.organizationId.equals(organizationId))
          ..where((t) => t.ingredientId.equals(ingredientId)))
        .write(BranchIngredientStockCompanion(
      quantity: Value(newQuantity),
      lastUpdated: Value(DateTime.now()),
      isSynced: const Value(false),
    ));
  }

  /// Add to current quantity (for receiving stock)
  Future<void> addStock({
    required int organizationId,
    required int ingredientId,
    required double quantityToAdd,
  }) async {
    final current = await getStock(
      organizationId: organizationId,
      ingredientId: ingredientId,
    );

    if (current != null) {
      await (update(branchIngredientStock)
            ..where((t) => t.id.equals(current.id)))
          .write(BranchIngredientStockCompanion(
        quantity: Value(current.quantity + quantityToAdd),
        lastReceivedAt: Value(DateTime.now()),
        lastReceivedQuantity: Value(quantityToAdd),
        lastUpdated: Value(DateTime.now()),
        isSynced: const Value(false),
      ));
    } else {
      // Create new stock record
      await into(branchIngredientStock).insert(
        BranchIngredientStockCompanion.insert(
          organizationId: organizationId,
          ingredientId: ingredientId,
          quantity: Value(quantityToAdd),
          lastReceivedAt: Value(DateTime.now()),
          lastReceivedQuantity: Value(quantityToAdd),
        ),
      );
    }
  }

  /// Deduct from current quantity (for consumption)
  Future<bool> consumeStock({
    required int organizationId,
    required int ingredientId,
    required double quantityToConsume,
  }) async {
    final current = await getStock(
      organizationId: organizationId,
      ingredientId: ingredientId,
    );

    if (current == null || current.quantity < quantityToConsume) {
      return false; // Insufficient stock
    }

    await (update(branchIngredientStock)
          ..where((t) => t.id.equals(current.id)))
        .write(BranchIngredientStockCompanion(
      quantity: Value(current.quantity - quantityToConsume),
      lastUpdated: Value(DateTime.now()),
      isSynced: const Value(false),
    ));

    return true;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BULK OPERATIONS - For receiving deliveries
  // ═══════════════════════════════════════════════════════════════════════════

  /// Initialize stock for all ingredients at a branch (when branch is created)
  Future<void> initializeStockForBranch({
    required int organizationId,
    required int commissaryId,
  }) async {
    // Get all ingredients from commissary
    final commissaryIngredients = await (select(ingredients)
          ..where((t) => t.commissaryId.equals(commissaryId))
          ..where((t) => t.isDeleted.equals(false)))
        .get();

    // Create stock records for each ingredient (quantity 0)
    await batch((batch) {
      batch.insertAll(
        branchIngredientStock,
        commissaryIngredients.map((ing) {
          return BranchIngredientStockCompanion.insert(
            organizationId: organizationId,
            ingredientId: ing.id,
            quantity: const Value(0.0),
          );
        }).toList(),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  /// Get low stock ingredients for a branch
  Future<List<BranchIngredientWithDetails>> getLowStockIngredients(
      int organizationId) async {
    final all = await getStocksWithDetails(organizationId);
    return all.where((s) => s.isLowStock).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COMMISSARY VIEW - See all branches' ingredient levels
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get ingredient stock levels across all branches (for commissary)
  Future<List<Map<String, dynamic>>> getNetworkIngredientLevels(
      int ingredientId) async {
    final results = await customSelect(
      '''
      SELECT 
        o.id as org_id,
        o.name as org_name,
        bis.quantity,
        bis.minimum_stock,
        bis.last_received_at
      FROM branch_ingredient_stock bis
      INNER JOIN organizations o ON bis.organization_id = o.id
      WHERE bis.ingredient_id = ?
      ORDER BY bis.quantity ASC
      ''',
      variables: [Variable.withInt(ingredientId)],
    ).get();

    return results.map((row) {
      return {
        'organizationId': row.read<int>('org_id'),
        'organizationName': row.read<String>('org_name'),
        'quantity': row.read<double>('quantity'),
        'minimumStock': row.read<double?>('minimum_stock'),
        'lastReceivedAt': row.read<DateTime?>('last_received_at'),
      };
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SYNC OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get unsynced stock records
  Future<List<BranchIngredientStockData>> getUnsyncedStocks({
    int limit = 100,
  }) async {
    return await (select(branchIngredientStock)
          ..where((t) => t.isSynced.equals(false))
          ..limit(limit))
        .get();
  }

  /// Mark stocks as synced
  Future<void> markAsSynced(List<int> ids) async {
    await (update(branchIngredientStock)..where((t) => t.id.isIn(ids)))
        .write(const BranchIngredientStockCompanion(isSynced: Value(true)));
  }

  /// Update cloud ID after sync
  Future<void> updateCloudId(int localId, String cloudId) async {
    await (update(branchIngredientStock)..where((t) => t.id.equals(localId)))
        .write(BranchIngredientStockCompanion(
      cloudId: Value(cloudId),
      isSynced: const Value(true),
    ));
  }
}
