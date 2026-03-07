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
          ..where((t) => t.isActive.equals(true)))
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

  /// Get all records (including soft-deleted) for UUID cache building
  Future<List<BranchIngredientStockData>> getAllBranchIngredientStocks() {
    return select(branchIngredientStock).get();
  }

  /// Get unsynced stock records
  Future<List<BranchIngredientStockData>> getUnsyncedStocks({
    int limit = 100,
    int offset = 0,
  }) async {
    return await (select(branchIngredientStock)
          ..where((t) => t.isSynced.equals(false))
          ..limit(limit, offset: offset))
        .get();
  }

  /// Get a stock record by its cloud ID
  Future<BranchIngredientStockData?> getByCloudId(String cloudId) {
    return (select(branchIngredientStock)
          ..where((t) => t.cloudId.equals(cloudId)))
        .getSingleOrNull();
  }

  /// Mark stocks as synced
  Future<void> markAsSynced(List<int> ids, {Map<int, String>? cloudIds}) async {
    for (final id in ids) {
      final companion = BranchIngredientStockCompanion(
        isSynced: const Value(true),
        cloudId: cloudIds?[id] != null ? Value(cloudIds![id]) : const Value.absent(),
      );
      await (update(branchIngredientStock)..where((t) => t.id.equals(id)))
          .write(companion);
    }
  }

  /// Update cloud ID after sync
  Future<void> updateCloudId(int localId, String cloudId) async {
    await (update(branchIngredientStock)..where((t) => t.id.equals(localId)))
        .write(BranchIngredientStockCompanion(
      cloudId: Value(cloudId),
      isSynced: const Value(true),
    ));
  }

  /// Upsert from cloud (for sync)
  /// Supports both camelCase (from toLocalFormat) and snake_case keys
  Future<void> upsertFromCloud(Map<String, dynamic> data, {int? existingId}) async {
    final cloudId = (data['cloudId'] ?? data['cloud_id']) as String;
    final organizationId = data['organizationId'] ?? data['organization_id'];
    final ingredientId = data['ingredientId'] ?? data['ingredient_id'];

    // Use pre-fetched hint if available; otherwise query by cloudId then business key
    int? resolvedId = existingId;
    if (resolvedId == null) {
      var existing = await (select(branchIngredientStock)
            ..where((t) => t.cloudId.equals(cloudId)))
          .getSingleOrNull();

      // If not found by cloudId, try business key (organizationId, ingredientId)
      if (existing == null && organizationId != null && ingredientId != null) {
        existing = await (select(branchIngredientStock)
              ..where((t) => t.organizationId.equals(organizationId as int))
              ..where((t) => t.ingredientId.equals(ingredientId as int)))
            .getSingleOrNull();
      }
      resolvedId = existing?.id;
    }

    final quantityVal = data['quantity'] ?? data['stock'];
    final minimumStockVal = data['minimumStock'] ?? data['minimum_stock'];
    final lastUpdatedVal = data['lastUpdated'] ?? data['last_updated'];

    final companion = BranchIngredientStockCompanion(
      organizationId: Value(organizationId as int),
      ingredientId: Value(ingredientId as int),
      quantity: Value((quantityVal as num?)?.toDouble() ?? 0.0),
      minimumStock: minimumStockVal != null
          ? Value((minimumStockVal as num).toDouble())
          : const Value.absent(),
      lastUpdated: lastUpdatedVal is DateTime
          ? Value(lastUpdatedVal)
          : lastUpdatedVal is String
              ? Value(DateTime.parse(lastUpdatedVal))
              : Value(DateTime.now()),
      isSynced: const Value(true),
      cloudId: Value(cloudId),
    );

    if (resolvedId != null) {
      final existingId = resolvedId;
      await (update(branchIngredientStock)
            ..where((t) => t.id.equals(existingId)))
          .write(companion);
    } else {
      await into(branchIngredientStock).insert(companion);
    }
  }

  /// Batch upsert from cloud
  Future<void> upsertBatchFromCloud(List<Map<String, dynamic>> dataList) async {
    if (dataList.isEmpty) return;
    // Pre-fetch existing records by cloudId and business key in one query
    final byCloudId = <String, int>{};
    final byBusinessKey = <(int, int), int>{};
    final existingRows = await (selectOnly(branchIngredientStock)
          ..addColumns([
            branchIngredientStock.id,
            branchIngredientStock.cloudId,
            branchIngredientStock.organizationId,
            branchIngredientStock.ingredientId,
          ]))
        .get();
    for (final row in existingRows) {
      final lid = row.read(branchIngredientStock.id);
      if (lid == null) continue;
      final cid = row.read(branchIngredientStock.cloudId);
      if (cid != null) byCloudId[cid] = lid;
      final orgId = row.read(branchIngredientStock.organizationId);
      final ingId = row.read(branchIngredientStock.ingredientId);
      if (orgId != null && ingId != null) byBusinessKey[(orgId, ingId)] = lid;
    }

    for (final data in dataList) {
      final cloudId = (data['cloudId'] ?? data['cloud_id'])?.toString();
      final orgId = data['organizationId'] ?? data['organization_id'];
      final ingId = data['ingredientId'] ?? data['ingredient_id'];
      final existingId = (cloudId != null ? byCloudId[cloudId] : null) ??
          (orgId != null && ingId != null
              ? byBusinessKey[(orgId as int, ingId as int)]
              : null);
      await upsertFromCloud(data, existingId: existingId);
    }
  }
}
