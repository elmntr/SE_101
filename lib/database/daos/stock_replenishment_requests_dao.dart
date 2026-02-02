// lib/database/daos/stock_replenishment_requests_dao.dart
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/stock_replenishment_requests.dart';
import '../tables/items.dart';
import '../tables/organizations.dart';
import '../tables/users.dart';

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
      print('❌ Error fetching replenishment requests: $e');
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
      print('❌ Error counting replenishment requests: $e');
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
      print('❌ Error watching replenishment requests: $e');
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
      print('❌ Error creating replenishment request: $e');
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
      print('❌ Error fetching request by ID: $e');
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
              reviewedAt: Value(DateTime.now()),
              commissaryNotes: Value(commissaryNotes),
              deliveryDate: Value(deliveryDate),
              lastUpdated: Value(DateTime.now()),
              isSynced: Value(false),
            ),
          );

      return result > 0;
    } catch (e) {
      print('❌ Error approving request: $e');
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
              reviewedAt: Value(DateTime.now()),
              commissaryNotes: Value(reason),
              lastUpdated: Value(DateTime.now()),
              isSynced: Value(false),
            ),
          );

      return result > 0;
    } catch (e) {
      print('❌ Error rejecting request: $e');
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
              lastUpdated: Value(DateTime.now()),
              isSynced: Value(false),
            ),
          );

      return result > 0;
    } catch (e) {
      print('❌ Error marking request as delivered: $e');
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
      print('❌ Error fetching pending requests: $e');
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
            ..orderBy([
              (t) => OrderingTerm(expression: t.reviewedAt),
            ]))
          .get();
    } catch (e) {
      print('❌ Error fetching approved requests: $e');
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
      print('❌ Error fetching franchisee request history: $e');
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
      print('❌ Error calculating franchisee request stats: $e');
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
              lastUpdated: Value(DateTime.now()),
            ),
          );

      return result > 0;
    } catch (e) {
      print('❌ Error soft deleting request: $e');
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
      print('❌ Error fetching unsynced requests: $e');
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
      print('❌ Error counting unsynced requests: $e');
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
      print('❌ Error marking requests as synced: $e');
      rethrow;
    }
  }

  /// ✅ Batch upsert from cloud
  Future<void> upsertBatchFromCloud(
    List<Map<String, dynamic>> cloudRequests,
  ) async {
    try {
      await db.transaction(() async {
        for (final cloudReq in cloudRequests) {
          final cloudId = cloudReq['cloud_id'] as String;
          final cloudStatus = cloudReq['status'] as String;
          
          // First, check if we already have this record locally by cloud_id
          final existing = await getRequestByCloudId(cloudId);
          final localId = existing?.id;
          
          print('   🔍 Processing cloud request: cloudId=$cloudId, cloudStatus=$cloudStatus');
          if (existing != null) {
            print('      Found local record #${existing.id}, localStatus=${existing.status}');
          } else {
            print('      No local record found, will insert new');
          }
          
          await upsertFromCloud(
            id: localId,
            franchiseeId: cloudReq['franchisee_id'],
            commissaryId: cloudReq['commissary_id'],
            itemId: cloudReq['item_id'],
            quantityRequested: cloudReq['quantity_requested'],
            status: cloudStatus,
            requestedBy: cloudReq['requested_by'],
            requestedAt: DateTime.parse(cloudReq['requested_at']),
            reviewedBy: cloudReq['reviewed_by'],
            reviewedAt: cloudReq['reviewed_at'] != null
                ? DateTime.parse(cloudReq['reviewed_at'])
                : null,
            deliveryDate: cloudReq['delivery_date'] != null
                ? DateTime.parse(cloudReq['delivery_date'])
                : null,
            franchiseeNotes: cloudReq['franchisee_notes'],
            commissaryNotes: cloudReq['commissary_notes'],
            createdAt: DateTime.parse(cloudReq['created_at']),
            lastUpdated: DateTime.parse(cloudReq['last_updated']),
            isDeleted: cloudReq['is_deleted'] ?? false,
            cloudId: cloudId,
          );
        }
      });
      print('   ✅ Batch upsert completed');
    } catch (e) {
      print('❌ Error batch upserting requests from cloud: $e');
      rethrow;
    }
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
        await (update(stockReplenishmentRequests)..where((t) => t.id.equals(id)))
            .write(StockReplenishmentRequestsCompanion(
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
        ));
        print('   ✓ Updated request #$id (status: $status)');
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
        print('   ✓ Inserted new request from cloud (cloudId: $cloudId, status: $status)');
      }
    } catch (e) {
      print('❌ Error upserting request from cloud: $e');
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
      print('❌ Error fetching request by cloud ID: $e');
      return null;
    }
  }
}

/// ✅ Sorting options for requests
enum RequestSortOrder { newestFirst, oldestFirst }
