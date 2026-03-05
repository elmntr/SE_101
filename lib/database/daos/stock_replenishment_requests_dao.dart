// lib/database/daos/stock_replenishment_requests_dao.dart
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/stock_replenishment_requests.dart';
import '../tables/items.dart';
import '../tables/organizations.dart';
import '../tables/users.dart';
import '../../utils/app_logger.dart';

part 'stock_replenishment_requests_dao.g.dart';

/// StockReplenishmentRequestsDao - Manage franchisee requests to commissary for items
///
/// Business Flow:
/// 1. Franchisee creates request (status: pending)
/// 2. Commissary reviews and approves/rejects
/// 3. If approved, commissary delivers (status: delivered)
/// 4. Franchisee receives items and stock is updated
@DriftAccessor(
  tables: [StockReplenishmentRequests, Items, Organizations, Users],
)
class StockReplenishmentRequestsDao extends DatabaseAccessor<AppDatabase>
    with _$StockReplenishmentRequestsDaoMixin {
  StockReplenishmentRequestsDao(super.db);

  static const int defaultPageSize = 50;

  // ============================================================================
  // BASIC CRUD OPERATIONS
  // ============================================================================

  /// ✅ Get all replenishment requests with pagination
  Future<List<StockReplenishmentRequest>> getAllRequests({
    int? limit,
    int offset = 0,
    String? status,
    int? franchiseeId,
    int? commissaryId,
    RequestSortOrder sortOrder = RequestSortOrder.newestFirst,
  }) async {
    try {
      final query = select(stockReplenishmentRequests)
        ..where((t) => t.isDeleted.equals(false));

      if (status != null) {
        query.where((t) => t.status.equals(status));
      }

      if (franchiseeId != null) {
        query.where((t) => t.franchiseeId.equals(franchiseeId));
      }

      if (commissaryId != null) {
        query.where((t) => t.commissaryId.equals(commissaryId));
      }

      // Sorting
      query.orderBy([
        (t) {
          switch (sortOrder) {
            case RequestSortOrder.newestFirst:
              return OrderingTerm(
                expression: t.requestedAt,
                mode: OrderingMode.desc,
              );
            case RequestSortOrder.oldestFirst:
              return OrderingTerm(
                expression: t.requestedAt,
                mode: OrderingMode.asc,
              );
          }
        },
      ]);

      if (limit != null) {
        query.limit(limit, offset: offset);
      }

      return await query.get();
    } catch (e) {
      //print('❌ Error fetching replenishment requests: $e');
      return [];
    }
  }

  /// ✅ Count requests
  Future<int> getRequestCount({
    String? status,
    int? franchiseeId,
    int? commissaryId,
  }) async {
    try {
      final query = selectOnly(stockReplenishmentRequests)
        ..addColumns([stockReplenishmentRequests.id.count()])
        ..where(stockReplenishmentRequests.isDeleted.equals(false));

      if (status != null) {
        query.where(stockReplenishmentRequests.status.equals(status));
      }

      if (franchiseeId != null) {
        query.where(
          stockReplenishmentRequests.franchiseeId.equals(franchiseeId),
        );
      }

      if (commissaryId != null) {
        query.where(
          stockReplenishmentRequests.commissaryId.equals(commissaryId),
        );
      }

      final result = await query.getSingle();
      return result.read(stockReplenishmentRequests.id.count()) ?? 0;
    } catch (e) {
      //print('❌ Error counting replenishment requests: $e');
      return 0;
    }
  }

  /// ✅ Watch requests (real-time updates)
  Stream<List<StockReplenishmentRequest>> watchRequests({
    int limit = defaultPageSize,
    int offset = 0,
    String? status,
    int? franchiseeId,
    int? commissaryId,
  }) {
    try {
      final query = select(stockReplenishmentRequests)
        ..where((t) => t.isDeleted.equals(false));

      if (status != null) {
        query.where((t) => t.status.equals(status));
      }

      if (franchiseeId != null) {
        query.where((t) => t.franchiseeId.equals(franchiseeId));
      }

      if (commissaryId != null) {
        query.where((t) => t.commissaryId.equals(commissaryId));
      }

      query
        ..orderBy([
          (t) =>
              OrderingTerm(expression: t.requestedAt, mode: OrderingMode.desc),
        ])
        ..limit(limit, offset: offset);

      return query.watch();
    } catch (e) {
      //print('❌ Error watching replenishment requests: $e');
      return Stream.value([]);
    }
  }

  /// ✅ Create new replenishment request (franchisee creates)
  Future<int> createRequest({
    required int franchiseeId,
    required int commissaryId,
    required int itemId,
    required int quantityRequested,
    required int requestedBy,
    String? franchiseeNotes,
  }) async {
    try {
      return await into(stockReplenishmentRequests).insert(
        StockReplenishmentRequestsCompanion.insert(
          franchiseeId: franchiseeId,
          commissaryId: commissaryId,
          itemId: itemId,
          quantityRequested: quantityRequested,
          status: Value('pending'),
          requestedBy: requestedBy,
          franchiseeNotes: Value(franchiseeNotes),
          isSynced: Value(false),
          cloudId: Value(const Uuid().v4()),
        ),
      );
    } catch (e) {
      //print('❌ Error creating replenishment request: $e');
      rethrow;
    }
  }

  /// ✅ Get request by ID
  Future<StockReplenishmentRequest?> getRequestById(int id) async {
    try {
      return await (select(
        stockReplenishmentRequests,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
    } catch (e) {
      //print('❌ Error fetching request by ID: $e');
      return null;
    }
  }

  // ============================================================================
  // COMMISSARY ACTIONS (Approve/Reject)
  // ============================================================================

  /// ✅ Approve request (commissary)
  Future<bool> approveRequest({
    required int requestId,
    required int reviewedBy,
    String? commissaryNotes,
    DateTime? deliveryDate,
  }) async {
    try {
      final result =
          await (update(
            stockReplenishmentRequests,
          )..where((t) => t.id.equals(requestId))).write(
            StockReplenishmentRequestsCompanion(
              status: Value('approved'),
              reviewedBy: Value(reviewedBy),
              reviewedAt: Value(DateTime.now().toUtc()),
              commissaryNotes: Value(commissaryNotes),
              deliveryDate: Value(deliveryDate),
              lastUpdated: Value(DateTime.now().toUtc()),
              isSynced: Value(false),
            ),
          );

      return result > 0;
    } catch (e) {
      //print('❌ Error approving request: $e');
      return false;
    }
  }

  /// ✅ Reject request (commissary)
  Future<bool> rejectRequest({
    required int requestId,
    required int reviewedBy,
    required String reason,
  }) async {
    try {
      final result =
          await (update(
            stockReplenishmentRequests,
          )..where((t) => t.id.equals(requestId))).write(
            StockReplenishmentRequestsCompanion(
              status: Value('rejected'),
              reviewedBy: Value(reviewedBy),
              reviewedAt: Value(DateTime.now().toUtc()),
              commissaryNotes: Value(reason),
              lastUpdated: Value(DateTime.now().toUtc()),
              isSynced: Value(false),
            ),
          );

      return result > 0;
    } catch (e) {
      //print('❌ Error rejecting request: $e');
      return false;
    }
  }

  /// ✅ Mark as delivered (commissary confirms delivery)
  Future<bool> markAsDelivered(int requestId) async {
    try {
      final result =
          await (update(
            stockReplenishmentRequests,
          )..where((t) => t.id.equals(requestId))).write(
            StockReplenishmentRequestsCompanion(
              status: Value('delivered'),
              lastUpdated: Value(DateTime.now().toUtc()),
              isSynced: Value(false),
            ),
          );

      return result > 0;
    } catch (e) {
      //print('❌ Error marking request as delivered: $e');
      return false;
    }
  }

  // ============================================================================
  // STATUS QUERIES
  // ============================================================================

  /// ✅ Get pending requests for commissary to review
  Future<List<StockReplenishmentRequest>> getPendingRequestsForCommissary(
    int commissaryId,
  ) async {
    try {
      return await (select(stockReplenishmentRequests)
            ..where(
              (t) =>
                  t.commissaryId.equals(commissaryId) &
                  t.status.equals('pending') &
                  t.isDeleted.equals(false),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.requestedAt)]))
          .get();
    } catch (e) {
      //print('❌ Error fetching pending requests: $e');
      return [];
    }
  }

  /// ✅ Get approved requests awaiting delivery
  Future<List<StockReplenishmentRequest>> getApprovedRequestsAwaitingDelivery(
    int commissaryId,
  ) async {
    try {
      return await (select(stockReplenishmentRequests)
            ..where(
              (t) =>
                  t.commissaryId.equals(commissaryId) &
                  t.status.equals('approved') &
                  t.isDeleted.equals(false),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.reviewedAt)]))
          .get();
    } catch (e) {
      //print('❌ Error fetching approved requests: $e');
      return [];
    }
  }

  /// ✅ Get franchisee's request history
  Future<List<StockReplenishmentRequest>> getFranchiseeRequestHistory(
    int franchiseeId, {
    int? limit = 20,
  }) async {
    try {
      final query = select(stockReplenishmentRequests)
        ..where(
          (t) =>
              t.franchiseeId.equals(franchiseeId) & t.isDeleted.equals(false),
        )
        ..orderBy([
          (t) =>
              OrderingTerm(expression: t.requestedAt, mode: OrderingMode.desc),
        ]);

      if (limit != null) {
        query.limit(limit);
      }

      return await query.get();
    } catch (e) {
      //print('❌ Error fetching franchisee request history: $e');
      return [];
    }
  }

  // ============================================================================
  // STATISTICS
  // ============================================================================

  /// ✅ Get request statistics for franchisee
  Future<Map<String, int>> getFranchiseeRequestStats(int franchiseeId) async {
    try {
      final allRequests =
          await (select(stockReplenishmentRequests)..where(
                (t) =>
                    t.franchiseeId.equals(franchiseeId) &
                    t.isDeleted.equals(false),
              ))
              .get();

      return {
        'total': allRequests.length,
        'pending': allRequests.where((r) => r.status == 'pending').length,
        'approved': allRequests.where((r) => r.status == 'approved').length,
        'rejected': allRequests.where((r) => r.status == 'rejected').length,
        'delivered': allRequests.where((r) => r.status == 'delivered').length,
      };
    } catch (e) {
      //print('❌ Error calculating franchisee request stats: $e');
      return {
        'total': 0,
        'pending': 0,
        'approved': 0,
        'rejected': 0,
        'delivered': 0,
      };
    }
  }

  /// ✅ Soft delete request
  Future<bool> softDeleteRequest(int id) async {
    try {
      final result =
          await (update(
            stockReplenishmentRequests,
          )..where((t) => t.id.equals(id))).write(
            StockReplenishmentRequestsCompanion(
              isDeleted: Value(true),
              isSynced: Value(false),
              lastUpdated: Value(DateTime.now().toUtc()),
            ),
          );

      return result > 0;
    } catch (e) {
      //print('❌ Error soft deleting request: $e');
      return false;
    }
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// ✅ Get unsynced requests (paginated)
  Future<List<StockReplenishmentRequest>> getUnsyncedRequests({
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      return await (select(stockReplenishmentRequests)
            ..where((t) => t.isSynced.equals(false))
            ..limit(limit, offset: offset))
          .get();
    } catch (e) {
      //print('❌ Error fetching unsynced requests: $e');
      return [];
    }
  }

  /// ✅ Count unsynced requests
  Future<int> getUnsyncedRequestCount() async {
    try {
      final query = selectOnly(stockReplenishmentRequests)
        ..addColumns([stockReplenishmentRequests.id.count()])
        ..where(stockReplenishmentRequests.isSynced.equals(false));

      final result = await query.getSingle();
      return result.read(stockReplenishmentRequests.id.count()) ?? 0;
    } catch (e) {
      //print('❌ Error counting unsynced requests: $e');
      return 0;
    }
  }

  /// ✅ Mark requests as synced (batch)
  Future<void> markAsSynced(
    List<int> requestIds, {
    Map<int, String>? cloudIds,
  }) async {
    try {
      await db.batch((batch) {
        for (final id in requestIds) {
          batch.update(
            stockReplenishmentRequests,
            StockReplenishmentRequestsCompanion(
              isSynced: Value(true),
              cloudId: Value(cloudIds?[id]),
            ),
            where: (t) => t.id.equals(id),
          );
        }
      });
    } catch (e) {
      //print('❌ Error marking requests as synced: $e');
      rethrow;
    }
  }

  /// ✅ Batch upsert from cloud
  /// Expects data from toLocalFormat (camelCase keys) or raw cloud data (snake_case)
  ///
  /// **IMPORTANT**: When a request is newly approved (status changes from non-approved to approved),
  /// this method automatically adds the requested quantity to the branch's inventory.
  Future<void> upsertBatchFromCloud(
    List<Map<String, dynamic>> cloudRequests,
  ) async {
    try {
      await db.transaction(() async {
        for (final cloudReq in cloudRequests) {
          // Support both camelCase (from toLocalFormat) and snake_case (raw cloud) keys
          final cloudId =
              (cloudReq['cloudId'] ?? cloudReq['cloud_id'])?.toString() ?? '';
          final cloudStatus = (cloudReq['status'] as String?) ?? 'pending';
          final franchiseeId =
              cloudReq['franchiseeId'] ?? cloudReq['franchisee_id'] ?? 0;
          final itemId = cloudReq['itemId'] ?? cloudReq['item_id'] ?? 0;
          final quantityRequested =
              cloudReq['quantityRequested'] ??
              cloudReq['quantity_requested'] ??
              0;

          // First, check if we already have this record locally by cloud_id
          final existing = cloudId.isNotEmpty
              ? await getRequestByCloudId(cloudId)
              : null;
          final localId = existing?.id;
          final previousStatus = existing?.status;

          AppLogger.sync(
            'Processing cloud request: cloudId=$cloudId, cloudStatus=$cloudStatus',
          );
          if (existing != null) {
            AppLogger.sync(
              '   Found local record #${existing.id}, localStatus=${existing.status}',
            );
          } else {
            AppLogger.sync('   No local record found, will insert new');
          }

          // ✅ Idempotent approval guard — must satisfy ALL three conditions:
          //   1. Record already existed locally (not a fresh-sync replay of history)
          //   2. Previous status was not yet 'approved' (genuine state transition)
          //   3. New cloud status is 'approved'
          //
          // This prevents duplicate stock on fresh install or DB clear:
          // - On fresh sync, existing == null for all historical requests → guard blocks.
          // - On realtime approval (pending → approved), existing != null → guard passes.
          // - On re-sync of already-approved request, previousStatus == 'approved' → guard blocks.
          final isNewlyApproved =
              cloudStatus == 'approved' &&
              existing != null &&
              previousStatus != 'approved';

          if (isNewlyApproved) {
            // Defensive ID validation — translation failure during early sync
            // can produce 0 IDs, which would create an invalid BranchItemStock
            // row that later triggers an RLS 42501 on push.
            if (franchiseeId == 0 || itemId == 0 || quantityRequested <= 0) {
              AppLogger.sync(
                '⚠️ Skipping _addStockToBranch: invalid IDs or quantity '
                '(franchiseeId=$franchiseeId, itemId=$itemId, qty=$quantityRequested). '
                'Organization cache may not be fully populated yet.',
              );
            } else {
              AppLogger.sync(
                '🎉 Request is newly approved! Adding $quantityRequested items to branch stock...',
              );
              await _addStockToBranch(franchiseeId, itemId, quantityRequested);
            }
          }

          await upsertFromCloud(
            id: localId,
            franchiseeId: franchiseeId,
            commissaryId:
                cloudReq['commissaryId'] ?? cloudReq['commissary_id'] ?? 0,
            itemId: itemId,
            quantityRequested: quantityRequested,
            status: cloudStatus,
            requestedBy:
                cloudReq['requestedBy'] ?? cloudReq['requested_by'] ?? 0,
            requestedAt: _parseDateTime(
              cloudReq['requestedAt'] ?? cloudReq['requested_at'],
            ),
            reviewedBy: cloudReq['reviewedBy'] ?? cloudReq['reviewed_by'],
            reviewedAt: _parseDateTimeNullable(
              cloudReq['reviewedAt'] ?? cloudReq['reviewed_at'],
            ),
            deliveryDate: _parseDateTimeNullable(
              cloudReq['deliveryDate'] ?? cloudReq['delivery_date'],
            ),
            franchiseeNotes:
                cloudReq['franchiseeNotes'] ?? cloudReq['franchisee_notes'],
            commissaryNotes:
                cloudReq['commissaryNotes'] ?? cloudReq['commissary_notes'],
            createdAt: _parseDateTime(
              cloudReq['createdAt'] ?? cloudReq['created_at'],
            ),
            lastUpdated: _parseDateTime(
              cloudReq['lastUpdated'] ?? cloudReq['last_updated'],
            ),
            isDeleted: cloudReq['isDeleted'] ?? cloudReq['is_deleted'] ?? false,
            cloudId: cloudId,
          );
        }
      });
      AppLogger.sync('Batch upsert of replenishment requests completed');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error batch upserting requests from cloud',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// ✅ Add stock to branch inventory when a replenishment request is approved
  ///
  /// IMPORTANT: Failures here are logged but not rethrown to avoid breaking sync.
  /// However, inventory discrepancies may occur if this fails - check logs for
  /// 'CRITICAL: Stock update failed' messages and manually correct inventory.
  Future<void> _addStockToBranch(
    int franchiseeId,
    int itemId,
    int quantity,
  ) async {
    try {
      // Find or create the branch stock record for this item
      var branchStock = await db.branchItemStockDao.getStockForItem(
        franchiseeId,
        itemId,
      );

      if (branchStock != null) {
        // Update existing stock record
        final success = await db.branchItemStockDao.receiveItems(
          branchStock.id,
          quantity,
        );
        if (success) {
          AppLogger.sync(
            'Added $quantity units to existing branch stock (stockId: ${branchStock.id})',
          );
        } else {
          // CRITICAL: Stock update returned false - may cause inventory discrepancy
          AppLogger.error(
            'CRITICAL: Stock update failed - receiveItems returned false',
            'franchiseeId=$franchiseeId, itemId=$itemId, quantity=$quantity, stockId=${branchStock.id}',
          );
        }
      } else {
        // Create new stock record with the received quantity
        AppLogger.sync('No existing stock record found, creating new one...');
        final stockId = await db.branchItemStockDao.createStock(
          BranchItemStockCompanion(
            organizationId: Value(franchiseeId),
            itemId: Value(itemId),
            stock: Value(quantity),
            sold: const Value(0),
            spoilage: const Value(0),
            lastReceivedAt: Value(DateTime.now().toUtc()),
            lastReceivedQuantity: Value(quantity),
            isSynced: const Value(false),
          ),
        );
        AppLogger.sync(
          'Created new branch stock record (id: $stockId) with $quantity units',
        );
      }
    } catch (e, stackTrace) {
      // CRITICAL: Log this prominently - approved request won't have stock added!
      // This could cause inventory discrepancies where request shows approved but stock wasn't added.
      AppLogger.error(
        'CRITICAL: Failed to add stock to branch inventory! Manual correction required.',
        'franchiseeId=$franchiseeId, itemId=$itemId, quantity=$quantity, error=$e',
        stackTrace,
      );
      // Don't rethrow - we don't want to fail the sync just because stock update failed
      // The request status will still be updated, and manual intervention can fix the stock
    }
  }

  /// Helper to parse DateTime from various formats
  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  /// Helper to parse nullable DateTime
  DateTime? _parseDateTimeNullable(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// ✅ Upsert from cloud (individual)
  Future<void> upsertFromCloud({
    int? id,
    required int franchiseeId,
    required int commissaryId,
    required int itemId,
    required int quantityRequested,
    required String status,
    required int requestedBy,
    required DateTime requestedAt,
    int? reviewedBy,
    DateTime? reviewedAt,
    DateTime? deliveryDate,
    String? franchiseeNotes,
    String? commissaryNotes,
    required DateTime createdAt,
    required DateTime lastUpdated,
    required bool isDeleted,
    required String cloudId,
  }) async {
    try {
      if (id != null) {
        // Update existing record by ID
        await (update(
          stockReplenishmentRequests,
        )..where((t) => t.id.equals(id))).write(
          StockReplenishmentRequestsCompanion(
            franchiseeId: Value(franchiseeId),
            commissaryId: Value(commissaryId),
            itemId: Value(itemId),
            quantityRequested: Value(quantityRequested),
            status: Value(status),
            requestedBy: Value(requestedBy),
            requestedAt: Value(requestedAt),
            reviewedBy: Value(reviewedBy),
            reviewedAt: Value(reviewedAt),
            deliveryDate: Value(deliveryDate),
            franchiseeNotes: Value(franchiseeNotes),
            commissaryNotes: Value(commissaryNotes),
            createdAt: Value(createdAt),
            lastUpdated: Value(lastUpdated),
            isDeleted: Value(isDeleted),
            isSynced: const Value(true),
            cloudId: Value(cloudId),
          ),
        );
        //print('   ✓ Updated request #$id (status: $status)');
      } else {
        // Insert new record
        await into(stockReplenishmentRequests).insert(
          StockReplenishmentRequestsCompanion.insert(
            franchiseeId: franchiseeId,
            commissaryId: commissaryId,
            itemId: itemId,
            quantityRequested: quantityRequested,
            status: Value(status),
            requestedBy: requestedBy,
            requestedAt: Value(requestedAt),
            reviewedBy: Value(reviewedBy),
            reviewedAt: Value(reviewedAt),
            deliveryDate: Value(deliveryDate),
            franchiseeNotes: Value(franchiseeNotes),
            commissaryNotes: Value(commissaryNotes),
            createdAt: Value(createdAt),
            lastUpdated: Value(lastUpdated),
            isDeleted: Value(isDeleted),
            isSynced: const Value(true),
            cloudId: Value(cloudId),
          ),
        );
        //print(
        //  '   ✓ Inserted new request from cloud (cloudId: $cloudId, status: $status)'
        //);
      }
    } catch (e) {
      //print('❌ Error upserting request from cloud: $e');
      rethrow;
    }
  }

  /// ✅ Get request by cloud ID
  Future<StockReplenishmentRequest?> getRequestByCloudId(String cloudId) async {
    try {
      return await (select(
        stockReplenishmentRequests,
      )..where((t) => t.cloudId.equals(cloudId))).getSingleOrNull();
    } catch (e) {
      //print('❌ Error fetching request by cloud ID: $e');
      return null;
    }
  }
}

/// ✅ Sorting options for requests
enum RequestSortOrder { newestFirst, oldestFirst }
