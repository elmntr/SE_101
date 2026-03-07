// lib/database/daos/branch_item_stock_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/branch_item_stock.dart';
import '../tables/items.dart';
import '../tables/categories.dart';
import '../models/item_with_branch_stock.dart';

part 'branch_item_stock_dao.g.dart';

/// Data Access Object for BranchItemStock table
///
/// Handles all branch-specific inventory operations:
/// - CRUD for branch stock records
/// - Stock updates (receive, sell, spoil)
/// - Sync with Supabase
@DriftAccessor(tables: [BranchItemStock, Items, Categories])
class BranchItemStockDao extends DatabaseAccessor<AppDatabase>
    with _$BranchItemStockDaoMixin {
  BranchItemStockDao(super.db);

  // ============================================================================
  // JOINED QUERIES - Items with Branch Stock
  // ============================================================================

  /// Get all master items with branch-specific stock for a branch
  ///
  /// This is the main query for franchisee inventory view:
  /// - Loads all master items from commissary
  /// - LEFT JOINs with branch_item_stock to get branch's quantities
  /// - Items without branch stock records show with stock=0
  ///
  /// [branchId] - The organization ID of the franchisee branch
  /// [commissaryId] - The organization ID of the parent commissary (for master items)
  Future<List<ItemWithBranchStock>> getItemsWithStockForBranch(
    int branchId,
    int commissaryId,
  ) async {
    // Get master items from commissary (items where org = commissary AND master_item_id IS NULL)
    final query = select(db.items).join([
      leftOuterJoin(
        branchItemStock,
        branchItemStock.itemId.equalsExp(db.items.id) &
            branchItemStock.organizationId.equals(branchId) &
            branchItemStock.isDeleted.equals(false),
      ),
      leftOuterJoin(
        db.categories,
        db.categories.id.equalsExp(db.items.categoryId),
      ),
    ])
      ..where(db.items.organizationId.equals(commissaryId))
      ..where(db.items.masterItemId.isNull()) // Only master items
      ..where(db.items.isDeleted.equals(false))
      ..orderBy([OrderingTerm.asc(db.items.name)]);

    final results = await query.get();

    return results.map((row) {
      final item = row.readTable(db.items);
      final stock = row.readTableOrNull(branchItemStock);
      final category = row.readTableOrNull(db.categories);

      return ItemWithBranchStock(
        item: item,
        branchStock: stock,
        category: category,
      );
    }).toList();
  }

  /// Watch items with branch stock (reactive stream)
  Stream<List<ItemWithBranchStock>> watchItemsWithStockForBranch(
    int branchId,
    int commissaryId,
  ) {
    final query = select(db.items).join([
      leftOuterJoin(
        branchItemStock,
        branchItemStock.itemId.equalsExp(db.items.id) &
            branchItemStock.organizationId.equals(branchId) &
            branchItemStock.isDeleted.equals(false),
      ),
      leftOuterJoin(
        db.categories,
        db.categories.id.equalsExp(db.items.categoryId),
      ),
    ])
      ..where(db.items.organizationId.equals(commissaryId))
      ..where(db.items.masterItemId.isNull())
      ..where(db.items.isDeleted.equals(false))
      ..orderBy([OrderingTerm.asc(db.items.name)]);

    return query.watch().map((results) {
      return results.map((row) {
        final item = row.readTable(db.items);
        final stock = row.readTableOrNull(branchItemStock);
        final category = row.readTableOrNull(db.categories);

        return ItemWithBranchStock(
          item: item,
          branchStock: stock,
          category: category,
        );
      }).toList();
    });
  }

  /// Get low stock items for a branch (items below minimum threshold)
  Future<List<ItemWithBranchStock>> getLowStockItemsForBranch(
    int branchId,
    int commissaryId,
  ) async {
    final allItems = await getItemsWithStockForBranch(branchId, commissaryId);
    return allItems.where((item) => item.isLowStock).toList();
  }

  /// Get out of stock items for a branch
  Future<List<ItemWithBranchStock>> getOutOfStockItemsForBranch(
    int branchId,
    int commissaryId,
  ) async {
    final allItems = await getItemsWithStockForBranch(branchId, commissaryId);
    return allItems.where((item) => item.isOutOfStock).toList();
  }

  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  /// Get all stock records for an organization
  Future<List<BranchItemStockData>> getStockByOrganization(int orgId) {
    return (select(branchItemStock)
          ..where((s) => s.organizationId.equals(orgId))
          ..where((s) => s.isDeleted.equals(false))
          ..orderBy([(s) => OrderingTerm.asc(s.itemId)]))
        .get();
  }

  /// Get stock for a specific item at a specific branch
  Future<BranchItemStockData?> getStockForItem(int orgId, int itemId) {
    return (select(branchItemStock)
          ..where((s) => s.organizationId.equals(orgId))
          ..where((s) => s.itemId.equals(itemId))
          ..where((s) => s.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Get all stock records (for sync, excludes soft-deleted)
  Future<List<BranchItemStockData>> getAllStock() {
    return (select(branchItemStock)
          ..where((s) => s.isDeleted.equals(false)))
        .get();
  }

  /// Get all stock records including soft-deleted (for UUID cache building)
  Future<List<BranchItemStockData>> getAllBranchItemStocks() {
    return select(branchItemStock).get();
  }

  /// Get unsynced stock records
  Future<List<BranchItemStockData>> getUnsyncedStock({
    int limit = 50,
    int offset = 0,
  }) {
    return (select(branchItemStock)
          ..where((s) => s.isSynced.equals(false))
          ..limit(limit, offset: offset))
        .get();
  }

  /// Get low stock items for a branch
  Future<List<BranchItemStockData>> getLowStockItems(int orgId) {
    return customSelect(
      '''
      SELECT * FROM branch_item_stock 
      WHERE organization_id = ? 
        AND is_deleted = 0
        AND minimum_stock IS NOT NULL 
        AND stock <= minimum_stock
      ORDER BY stock ASC
      ''',
      variables: [Variable.withInt(orgId)],
      readsFrom: {branchItemStock},
    ).map((row) => branchItemStock.map(row.data)).get();
  }

  /// Count low stock items across all franchisees belonging to a commissary
  Future<int> getLowStockCountForCommissary(int commissaryId) async {
    try {
      final result = await customSelect(
        '''
        SELECT COUNT(*) AS cnt
        FROM branch_item_stock bis
        INNER JOIN organizations o ON bis.organization_id = o.id
        WHERE o.parent_commissary_id = ?
          AND o.is_active = 1
          AND bis.is_deleted = 0
          AND bis.minimum_stock IS NOT NULL
          AND bis.stock <= bis.minimum_stock
        ''',
        variables: [Variable.withInt(commissaryId)],
        readsFrom: {branchItemStock},
      ).getSingle();
      return (result.data['cnt'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Watch stock changes for a branch (reactive)
  Stream<List<BranchItemStockData>> watchStockByOrganization(int orgId) {
    return (select(branchItemStock)
          ..where((s) => s.organizationId.equals(orgId))
          ..where((s) => s.isDeleted.equals(false))
          ..orderBy([(s) => OrderingTerm.asc(s.itemId)]))
        .watch();
  }

  // ============================================================================
  // CREATE OPERATIONS
  // ============================================================================

  /// Create a new stock record
  Future<int> createStock(BranchItemStockCompanion stock) {
    return into(branchItemStock).insert(stock);
  }

  /// Initialize stock for a branch (create records for all master items)
  Future<int> initializeStockForBranch(int branchId, int commissaryId) async {
    // Get all master items from commissary
    final masterItems = await db.itemsDao.getCommissaryMasterItems(commissaryId);
    
    int created = 0;
    for (final item in masterItems) {
      // Check if stock already exists
      final existing = await getStockForItem(branchId, item.id);
      if (existing == null) {
        await createStock(BranchItemStockCompanion(
          organizationId: Value(branchId),
          itemId: Value(item.id),
          stock: const Value(0),
          sold: const Value(0),
          spoilage: const Value(0),
          isSynced: const Value(false),
        ));
        created++;
      }
    }
    return created;
  }

  // ============================================================================
  // UPDATE OPERATIONS
  // ============================================================================

  /// Update stock record
  Future<bool> updateStock(int id, BranchItemStockCompanion stock) {
    return (update(branchItemStock)..where((s) => s.id.equals(id)))
        .write(stock.copyWith(
          lastUpdated: Value(DateTime.now()),
          isSynced: const Value(false),
        ))
        .then((rows) => rows > 0);
  }

  /// Receive items (add to stock)
  Future<bool> receiveItems(int stockId, int quantity) async {
    final existing = await (select(branchItemStock)
          ..where((s) => s.id.equals(stockId)))
        .getSingleOrNull();

    if (existing == null) return false;

    return (update(branchItemStock)..where((s) => s.id.equals(stockId)))
        .write(BranchItemStockCompanion(
          stock: Value(existing.stock + quantity),
          lastReceivedAt: Value(DateTime.now()),
          lastReceivedQuantity: Value(quantity),
          lastUpdated: Value(DateTime.now()),
          isSynced: const Value(false),
        ))
        .then((rows) => rows > 0);
  }

  /// Record sale (decrease stock, increase sold)
  Future<bool> recordSale(int stockId, int quantity) async {
    final existing = await (select(branchItemStock)
          ..where((s) => s.id.equals(stockId)))
        .getSingleOrNull();

    if (existing == null) return false;
    if (existing.stock < quantity) return false; // Not enough stock

    return (update(branchItemStock)..where((s) => s.id.equals(stockId)))
        .write(BranchItemStockCompanion(
          stock: Value(existing.stock - quantity),
          sold: Value(existing.sold + quantity),
          lastUpdated: Value(DateTime.now()),
          isSynced: const Value(false),
        ))
        .then((rows) => rows > 0);
  }

  /// Record spoilage (decrease stock, increase spoilage)
  Future<bool> recordSpoilage(int stockId, int quantity) async {
    final existing = await (select(branchItemStock)
          ..where((s) => s.id.equals(stockId)))
        .getSingleOrNull();

    if (existing == null) return false;
    if (existing.stock < quantity) return false; // Not enough stock

    return (update(branchItemStock)..where((s) => s.id.equals(stockId)))
        .write(BranchItemStockCompanion(
          stock: Value(existing.stock - quantity),
          spoilage: Value(existing.spoilage + quantity),
          lastUpdated: Value(DateTime.now()),
          isSynced: const Value(false),
        ))
        .then((rows) => rows > 0);
  }

  /// Update branch-specific price
  Future<bool> updatePrice(int stockId, double price, {double? costPrice}) {
    return (update(branchItemStock)..where((s) => s.id.equals(stockId)))
        .write(BranchItemStockCompanion(
          price: Value(price),
          costPrice: costPrice != null ? Value(costPrice) : const Value.absent(),
          lastUpdated: Value(DateTime.now()),
          isSynced: const Value(false),
        ))
        .then((rows) => rows > 0);
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// Get a stock record by its cloud ID
  Future<BranchItemStockData?> getByCloudId(String cloudId) {
    return (select(branchItemStock)
          ..where((s) => s.cloudId.equals(cloudId)))
        .getSingleOrNull();
  }

  /// Mark records as synced
  Future<void> markAsSynced(List<int> ids, {Map<int, String>? cloudIds}) async {
    for (final id in ids) {
      final companion = BranchItemStockCompanion(
        isSynced: const Value(true),
        cloudId: cloudIds?[id] != null ? Value(cloudIds![id]) : const Value.absent(),
      );
      await (update(branchItemStock)..where((s) => s.id.equals(id)))
          .write(companion);
    }
  }

  /// Upsert from cloud (for sync)
  /// Supports both camelCase (from toLocalFormat) and snake_case keys
  Future<void> upsertFromCloud(Map<String, dynamic> data, {int? existingId}) async {
    final cloudId = (data['cloudId'] ?? data['cloud_id']) as String;
    final organizationId = data['organizationId'] ?? data['organization_id'];
    final itemId = data['itemId'] ?? data['item_id'];

    // Use pre-fetched hint if available; otherwise query by cloudId then business key
    int? resolvedId = existingId;
    if (resolvedId == null) {
      // Check if exists by cloud_id first
      var existing = await (select(branchItemStock)
            ..where((s) => s.cloudId.equals(cloudId)))
          .getSingleOrNull();

      // If not found by cloudId, try business key (organizationId, itemId)
      // This handles records created locally before sync assigned a cloudId
      if (existing == null && organizationId != null && itemId != null) {
        existing = await (select(branchItemStock)
              ..where((s) => s.organizationId.equals(organizationId as int))
              ..where((s) => s.itemId.equals(itemId as int))
              ..where((s) => s.isDeleted.equals(false)))
            .getSingleOrNull();
      }
      resolvedId = existing?.id;
    }

    final stockVal = data['stock'];
    final soldVal = data['sold'];
    final spoilageVal = data['spoilage'];
    final priceVal = data['price'] ?? data['price'];
    final costPriceVal = data['costPrice'] ?? data['cost_price'];
    final minimumStockVal = data['minimumStock'] ?? data['minimum_stock'];
    final lastUpdatedVal = data['lastUpdated'] ?? data['last_updated'];
    final isDeletedVal = data['isDeleted'] ?? data['is_deleted'];

    final companion = BranchItemStockCompanion(
      organizationId: Value(organizationId as int),
      itemId: Value(itemId as int),
      stock: Value(stockVal as int? ?? 0),
      sold: Value(soldVal as int? ?? 0),
      spoilage: Value(spoilageVal as int? ?? 0),
      price: priceVal != null ? Value((priceVal as num).toDouble()) : const Value.absent(),
      costPrice: costPriceVal != null ? Value((costPriceVal as num).toDouble()) : const Value.absent(),
      minimumStock: minimumStockVal != null ? Value(minimumStockVal as int) : const Value.absent(),
      lastUpdated: lastUpdatedVal is DateTime
          ? Value(lastUpdatedVal)
          : lastUpdatedVal is String
              ? Value(DateTime.parse(lastUpdatedVal))
              : Value(DateTime.now()),
      isDeleted: Value(isDeletedVal == true || isDeletedVal == 1),
      isSynced: const Value(true),
      cloudId: Value(cloudId),
    );

    if (resolvedId != null) {
      final eid = resolvedId;
      await (update(branchItemStock)..where((s) => s.id.equals(eid)))
          .write(companion);
    } else {
      await into(branchItemStock).insert(companion);
    }
  }

  /// Batch upsert from cloud
  Future<void> upsertBatchFromCloud(List<Map<String, dynamic>> dataList) async {
    if (dataList.isEmpty) return;
    // Pre-fetch existing records by cloudId and business key in one query
    final byCloudId = <String, int>{};
    final byBusinessKey = <(int, int), int>{};
    final existingRows = await (selectOnly(branchItemStock)
          ..addColumns([
            branchItemStock.id,
            branchItemStock.cloudId,
            branchItemStock.organizationId,
            branchItemStock.itemId,
          ]))
        .get();
    for (final row in existingRows) {
      final lid = row.read(branchItemStock.id);
      if (lid == null) continue;
      final cid = row.read(branchItemStock.cloudId);
      if (cid != null) byCloudId[cid] = lid;
      final orgId = row.read(branchItemStock.organizationId);
      final itmId = row.read(branchItemStock.itemId);
      if (orgId != null && itmId != null) byBusinessKey[(orgId, itmId)] = lid;
    }

    await batch((b) async {
      for (final data in dataList) {
        final cloudId_ = (data['cloudId'] ?? data['cloud_id'])?.toString();
        final orgId = data['organizationId'] ?? data['organization_id'];
        final itmId = data['itemId'] ?? data['item_id'];
        final existingId = (cloudId_ != null ? byCloudId[cloudId_] : null) ??
            (orgId != null && itmId != null
                ? byBusinessKey[(orgId as int, itmId as int)]
                : null);
        await upsertFromCloud(data, existingId: existingId);
      }
    });
  }

  // ============================================================================
  // DELETE OPERATIONS
  // ============================================================================

  /// Soft delete a stock record
  Future<bool> softDelete(int id) {
    return (update(branchItemStock)..where((s) => s.id.equals(id)))
        .write(const BranchItemStockCompanion(
          isDeleted: Value(true),
          lastUpdated: Value.absent(),
          isSynced: Value(false),
        ))
        .then((rows) => rows > 0);
  }

  /// Hard delete synced soft-deleted records
  Future<int> cleanupDeleted() {
    return (delete(branchItemStock)
          ..where((s) => s.isDeleted.equals(true))
          ..where((s) => s.isSynced.equals(true)))
        .go();
  }
}
