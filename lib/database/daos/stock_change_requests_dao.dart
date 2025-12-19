// lib/database/daos/stock_change_requests_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/stock_change_requests.dart';
import '../tables/items.dart';
import '../tables/organizations.dart';
import '../tables/users.dart';

part 'stock_change_requests_dao.g.dart';

/// StockChangeRequestsDao - Manage employee stock change requests requiring franchisee approval
/// 
/// Business Flow:
/// 1. Employee creates change (status: draft)
/// 2. Employee reviews and submits (status: pending)
/// 3. Franchisee reviews and approves/rejects
/// 4. If approved: Item stock is updated
/// 5. If rejected: Reverted to draft for employee to review
@DriftAccessor(tables: [StockChangeRequests, Items, Organizations, Users])
class StockChangeRequestsDao extends DatabaseAccessor<AppDatabase> 
    with _$StockChangeRequestsDaoMixin {
  StockChangeRequestsDao(AppDatabase db) : super(db);

  static const int defaultPageSize = 50;

  // ============================================================================
  // BASIC CRUD OPERATIONS
  // ============================================================================

  /// ✅ Get all stock change requests with pagination
  Future<List<StockChangeRequest>> getAllChangeRequests({
    int? limit,
    int offset = 0,
    String? status,
    String? changeType,
    int? franchiseeId,
    int? itemId,
    int? requestedBy,
    ChangeSortOrder sortOrder = ChangeSortOrder.newestFirst,
  }) async {
    try {
      final query = select(stockChangeRequests)
        ..where((t) => t.isDeleted.equals(false));
      
      if (status != null) {
        query.where((t) => t.status.equals(status));
      }
      
      if (changeType != null) {
        query.where((t) => t.changeType.equals(changeType));
      }
      
      if (franchiseeId != null) {
        query.where((t) => t.franchiseeId.equals(franchiseeId));
      }
      
      if (itemId != null) {
        query.where((t) => t.itemId.equals(itemId));
      }
      
      if (requestedBy != null) {
        query.where((t) => t.requestedBy.equals(requestedBy));
      }
      
      // Sorting
      query.orderBy([
        (t) {
          switch (sortOrder) {
            case ChangeSortOrder.newestFirst:
              return OrderingTerm(expression: t.requestedAt, mode: OrderingMode.desc);
            case ChangeSortOrder.oldestFirst:
              return OrderingTerm(expression: t.requestedAt, mode: OrderingMode.asc);
          }
        }
      ]);
      
      if (limit != null) {
        query.limit(limit, offset: offset);
      }
      
      return await query.get();
    } catch (e) {
      print('❌ Error fetching stock change requests: $e');
      return [];
    }
  }

  /// ✅ Count change requests
  Future<int> getChangeRequestCount({
    String? status,
    String? changeType,
    int? franchiseeId,
    int? requestedBy,
  }) async {
    try {
      final query = selectOnly(stockChangeRequests)
        ..addColumns([stockChangeRequests.id.count()])
        ..where(stockChangeRequests.isDeleted.equals(false));
      
      if (status != null) {
        query.where(stockChangeRequests.status.equals(status));
      }
      
      if (changeType != null) {
        query.where(stockChangeRequests.changeType.equals(changeType));
      }
      
      if (franchiseeId != null) {
        query.where(stockChangeRequests.franchiseeId.equals(franchiseeId));
      }
      
      if (requestedBy != null) {
        query.where(stockChangeRequests.requestedBy.equals(requestedBy));
      }
      
      final result = await query.getSingle();
      return result.read(stockChangeRequests.id.count()) ?? 0;
    } catch (e) {
      print('❌ Error counting stock change requests: $e');
      return 0;
    }
  }

  /// ✅ Watch change requests (real-time updates)
  Stream<List<StockChangeRequest>> watchChangeRequests({
    int limit = defaultPageSize,
    int offset = 0,
    String? status,
    int? franchiseeId,
    int? requestedBy,
  }) {
    try {
      final query = select(stockChangeRequests)
        ..where((t) => t.isDeleted.equals(false));
      
      if (status != null) {
        query.where((t) => t.status.equals(status));
      }
      
      if (franchiseeId != null) {
        query.where((t) => t.franchiseeId.equals(franchiseeId));
      }
      
      if (requestedBy != null) {
        query.where((t) => t.requestedBy.equals(requestedBy));
      }
      
      query
        ..orderBy([(t) => OrderingTerm(expression: t.requestedAt, mode: OrderingMode.desc)])
        ..limit(limit, offset: offset);
      
      return query.watch();
    } catch (e) {
      print('❌ Error watching stock change requests: $e');
      return Stream.value([]);
    }
  }

  // ============================================================================
  // EMPLOYEE ACTIONS (Create, Submit)
  // ============================================================================

  /// ✅ Create new stock change request (employee creates in draft)
  Future<int> createChangeRequest({
    required int franchiseeId,
    required int itemId,
    required String changeType, // 'sold', 'spoiled', 'adjustment', 'return'
    required int quantity,
    required int requestedBy,
    required int originalStock,
    String? reason,
  }) async {
    try {
      // Validate changeType
      const validTypes = ['sold', 'spoiled', 'adjustment', 'return'];
      if (!validTypes.contains(changeType)) {
        throw ArgumentError('Invalid change type. Must be one of: ${validTypes.join(", ")}');
      }
      
      return await into(stockChangeRequests).insert(
        StockChangeRequestsCompanion.insert(
          franchiseeId: franchiseeId,
          itemId: itemId,
          changeType: changeType,
          quantity: quantity,
          status: Value('draft'),
          requestedBy: requestedBy,
          originalStock: originalStock,
          reason: Value(reason),
          isSynced: Value(false),
        ),
      );
    } catch (e) {
      print('Error creating change request: $e');
      rethrow;
    }
  }

  /// Update draft change request (employee editing)
  Future<bool> updateDraftChangeRequest({
    required int requestId,
    int? quantity,
    String? reason,
  }) async {
    try {
      // Only allow editing drafts
      final request = await getChangeRequestById(requestId);
      if (request == null || request.status != 'draft') {
        print('Can only edit draft requests');
        return false;
      }

      final companion = StockChangeRequestsCompanion(
        quantity: quantity != null ? Value(quantity) : const Value.absent(),
        reason: reason != null ? Value(reason) : const Value.absent(),
        lastUpdated: Value(DateTime.now()),
        isSynced: const Value(false),
      );

      final result = await (update(stockChangeRequests)
        ..where((t) => t.id.equals(requestId)))
        .write(companion);

      return result > 0;
    } catch (e) {
      print('Error updating draft change request: $e');
      return false;
    }
  }

  /// Submit change request (employee submits for review)
  Future<bool> submitChangeRequest(int requestId) async {
    try {
      // Only allow submitting drafts
      final request = await getChangeRequestById(requestId);
      if (request == null || request.status != 'draft') {
        print('⚠️ Can only submit draft requests');
        return false;
      }
      
      final result = await (update(stockChangeRequests)
        ..where((t) => t.id.equals(requestId)))
        .write(StockChangeRequestsCompanion(
          status: Value('pending'),
          submittedAt: Value(DateTime.now()),
          lastUpdated: Value(DateTime.now()),
          isSynced: Value(false),
        ));
      
      return result > 0;
    } catch (e) {
      print('❌ Error submitting change request: $e');
      return false;
    }
  }

  /// ✅ Get employee's draft requests
  Future<List<StockChangeRequest>> getEmployeeDrafts(int employeeId) async {
    try {
      return await (select(stockChangeRequests)
        ..where((t) => 
          t.requestedBy.equals(employeeId) &
          t.status.equals('draft') &
          t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm(expression: t.requestedAt, mode: OrderingMode.desc)]))
        .get();
    } catch (e) {
      print('❌ Error fetching employee drafts: $e');
      return [];
    }
  }

  /// ✅ Get employee's pending requests
  Future<List<StockChangeRequest>> getEmployeePendingRequests(int employeeId) async {
    try {
      return await (select(stockChangeRequests)
        ..where((t) => 
          t.requestedBy.equals(employeeId) &
          t.status.equals('pending') &
          t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm(expression: t.submittedAt ?? t.requestedAt, mode: OrderingMode.desc)]))
        .get();
    } catch (e) {
      print('❌ Error fetching employee pending requests: $e');
      return [];
    }
  }

  // ============================================================================
  // FRANCHISEE ACTIONS (Approve, Reject)
  // ============================================================================

  /// ✅ Get pending requests for franchisee to review
  Future<List<StockChangeRequest>> getPendingRequestsForFranchisee(int franchiseeId) async {
    try {
      return await (select(stockChangeRequests)
        ..where((t) => 
          t.franchiseeId.equals(franchiseeId) &
          t.status.equals('pending') &
          t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm(expression: t.submittedAt ?? t.requestedAt)]))
        .get();
    } catch (e) {
      print('❌ Error fetching pending requests for franchisee: $e');
      return [];
    }
  }

  /// ✅ Approve change request and apply changes to item stock
  Future<bool> approveChangeRequest({
    required int requestId,
    required int reviewedBy,
    String? reviewNotes,
  }) async {
    try {
      final request = await getChangeRequestById(requestId);
      if (request == null || request.status != 'pending') {
        print('⚠️ Can only approve pending requests');
        return false;
      }
      
      // Apply changes in a transaction
      return await db.transaction(() async {
        // 1. Update request status
        await (update(stockChangeRequests)
          ..where((t) => t.id.equals(requestId)))
          .write(StockChangeRequestsCompanion(
            status: Value('approved'),
            reviewedBy: Value(reviewedBy),
            reviewedAt: Value(DateTime.now()),
            reviewNotes: Value(reviewNotes),
            lastUpdated: Value(DateTime.now()),
            isSynced: Value(false),
          ));
        
        // 2. Apply stock changes based on change type
        switch (request.changeType) {
          case 'sold':
            await db.itemsDao.addSold(request.itemId, request.quantity);
            break;
          case 'spoiled':
            await db.itemsDao.addSpoilage(request.itemId, request.quantity);
            break;
          case 'adjustment':
            // For adjustments, directly update stock
            final item = await db.itemsDao.getItemById(request.itemId);
            if (item != null) {
              final newStock = item.stock + request.quantity; // Can be negative for deductions
              await db.itemsDao.updateStock(request.itemId, newStock);
            }
            break;
          case 'return':
            // Return: decrease sold, increase stock
            await customUpdate(
              'UPDATE items SET '
              'sold = sold - ?, '
              'stock = stock + ?, '
              'last_updated = ?, '
              'is_synced = 0 '
              'WHERE id = ?',
              updates: {db.items},
              variables: [
                Variable.withInt(request.quantity),
                Variable.withInt(request.quantity),
                Variable.withDateTime(DateTime.now()),
                Variable.withInt(request.itemId),
              ],
            );
            break;
        }
        
        return true;
      });
    } catch (e) {
      print('❌ Error approving change request: $e');
      return false;
    }
  }

  /// ✅ Reject change request (revert to draft)
  Future<bool> rejectChangeRequest({
    required int requestId,
    required int reviewedBy,
    required String reason,
  }) async {
    try {
      final request = await getChangeRequestById(requestId);
      if (request == null || request.status != 'pending') {
        print('⚠️ Can only reject pending requests');
        return false;
      }
      
      // Revert to draft so employee can review and resubmit
      final result = await (update(stockChangeRequests)
        ..where((t) => t.id.equals(requestId)))
        .write(StockChangeRequestsCompanion(
          status: Value('rejected'),
          reviewedBy: Value(reviewedBy),
          reviewedAt: Value(DateTime.now()),
          reviewNotes: Value(reason),
          lastUpdated: Value(DateTime.now()),
          isSynced: Value(false),
        ));
      
      return result > 0;
    } catch (e) {
      print('❌ Error rejecting change request: $e');
      return false;
    }
  }

  // ============================================================================
  // QUERIES
  // ============================================================================

  /// ✅ Get change request by ID
  Future<StockChangeRequest?> getChangeRequestById(int id) async {
    try {
      return await (select(stockChangeRequests)
        ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching change request by ID: $e');
      return null;
    }
  }

  /// ✅ Get change request history for item
  Future<List<StockChangeRequest>> getItemChangeHistory(
    int itemId, {
    int? limit = 20,
  }) async {
    try {
      final query = select(stockChangeRequests)
        ..where((t) => 
          t.itemId.equals(itemId) &
          t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm(expression: t.requestedAt, mode: OrderingMode.desc)]);
      
      if (limit != null) {
        query.limit(limit);
      }
      
      return await query.get();
    } catch (e) {
      print('❌ Error fetching item change history: $e');
      return [];
    }
  }

  /// ✅ Get employee's change request history
  Future<List<StockChangeRequest>> getEmployeeChangeHistory(
    int employeeId, {
    int? limit = 20,
  }) async {
    try {
      final query = select(stockChangeRequests)
        ..where((t) => 
          t.requestedBy.equals(employeeId) &
          t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm(expression: t.requestedAt, mode: OrderingMode.desc)]);
      
      if (limit != null) {
        query.limit(limit);
      }
      
      return await query.get();
    } catch (e) {
      print('❌ Error fetching employee change history: $e');
      return [];
    }
  }

  // ============================================================================
  // STATISTICS
  // ============================================================================

  /// ✅ Get change request statistics for franchisee
  Future<Map<String, int>> getFranchiseeChangeStats(int franchiseeId) async {
    try {
      final allRequests = await (select(stockChangeRequests)
        ..where((t) => 
          t.franchiseeId.equals(franchiseeId) &
          t.isDeleted.equals(false)))
        .get();
      
      return {
        'total': allRequests.length,
        'draft': allRequests.where((r) => r.status == 'draft').length,
        'pending': allRequests.where((r) => r.status == 'pending').length,
        'approved': allRequests.where((r) => r.status == 'approved').length,
        'rejected': allRequests.where((r) => r.status == 'rejected').length,
      };
    } catch (e) {
      print('❌ Error calculating franchisee change stats: $e');
      return {'total': 0, 'draft': 0, 'pending': 0, 'approved': 0, 'rejected': 0};
    }
  }

  /// ✅ Soft delete change request
  Future<bool> softDeleteChangeRequest(int id) async {
    try {
      final result = await (update(stockChangeRequests)
        ..where((t) => t.id.equals(id)))
        .write(StockChangeRequestsCompanion(
          isDeleted: Value(true),
          isSynced: Value(false),
          lastUpdated: Value(DateTime.now()),
        ));
      
      return result > 0;
    } catch (e) {
      print('❌ Error soft deleting change request: $e');
      return false;
    }
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// ✅ Get unsynced change requests (paginated)
  Future<List<StockChangeRequest>> getUnsyncedChangeRequests({
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      return await (select(stockChangeRequests)
        ..where((t) => t.isSynced.equals(false))
        ..limit(limit, offset: offset))
        .get();
    } catch (e) {
      print('❌ Error fetching unsynced change requests: $e');
      return [];
    }
  }

  /// ✅ Count unsynced change requests
  Future<int> getUnsyncedChangeRequestCount() async {
    try {
      final query = selectOnly(stockChangeRequests)
        ..addColumns([stockChangeRequests.id.count()])
        ..where(stockChangeRequests.isSynced.equals(false));
      
      final result = await query.getSingle();
      return result.read(stockChangeRequests.id.count()) ?? 0;
    } catch (e) {
      print('❌ Error counting unsynced change requests: $e');
      return 0;
    }
  }

  /// ✅ Mark change requests as synced (batch)
  Future<void> markAsSynced(List<int> requestIds, {Map<int, String>? cloudIds}) async {
    try {
      await db.batch((batch) {
        for (final id in requestIds) {
          batch.update(
            stockChangeRequests,
            StockChangeRequestsCompanion(
              isSynced: Value(true),
              cloudId: Value(cloudIds?[id]),
            ),
            where: (t) => t.id.equals(id),
          );
        }
      });
    } catch (e) {
      print('❌ Error marking change requests as synced: $e');
      rethrow;
    }
  }

  /// ✅ Batch upsert from cloud
  Future<void> upsertBatchFromCloud(List<Map<String, dynamic>> cloudRequests) async {
    try {
      await db.transaction(() async {
        for (final cloudReq in cloudRequests) {
          await upsertFromCloud(
            id: cloudReq['local_id'],
            franchiseeId: cloudReq['franchisee_id'],
            itemId: cloudReq['item_id'],
            changeType: cloudReq['change_type'],
            quantity: cloudReq['quantity'],
            status: cloudReq['status'],
            requestedBy: cloudReq['requested_by'],
            requestedAt: DateTime.parse(cloudReq['requested_at']),
            submittedAt: cloudReq['submitted_at'] != null
                ? DateTime.parse(cloudReq['submitted_at'])
                : null,
            reviewedBy: cloudReq['reviewed_by'],
            reviewedAt: cloudReq['reviewed_at'] != null
                ? DateTime.parse(cloudReq['reviewed_at'])
                : null,
            reason: cloudReq['reason'],
            reviewNotes: cloudReq['review_notes'],
            originalStock: cloudReq['original_stock'],
            createdAt: DateTime.parse(cloudReq['created_at']),
            lastUpdated: DateTime.parse(cloudReq['last_updated']),
            isDeleted: cloudReq['is_deleted'] ?? false,
            cloudId: cloudReq['cloud_id'],
          );
        }
      });
    } catch (e) {
      print('❌ Error batch upserting change requests from cloud: $e');
      rethrow;
    }
  }

  /// ✅ Upsert from cloud (individual)
  Future<void> upsertFromCloud({
    required int id,
    required int franchiseeId,
    required int itemId,
    required String changeType,
    required int quantity,
    required String status,
    required int requestedBy,
    required DateTime requestedAt,
    DateTime? submittedAt,
    int? reviewedBy,
    DateTime? reviewedAt,
    String? reason,
    String? reviewNotes,
    required int originalStock,
    required DateTime createdAt,
    required DateTime lastUpdated,
    required bool isDeleted,
    required String cloudId,
  }) async {
    try {
      await into(stockChangeRequests).insertOnConflictUpdate(
        StockChangeRequestsCompanion.insert(
          id: Value(id),
          franchiseeId: franchiseeId,
          itemId: itemId,
          changeType: changeType,
          quantity: quantity,
          status: Value(status),
          requestedBy: requestedBy,
          requestedAt: Value(requestedAt),
          submittedAt: Value(submittedAt),
          reviewedBy: Value(reviewedBy),
          reviewedAt: Value(reviewedAt),
          reason: Value(reason),
          reviewNotes: Value(reviewNotes),
          originalStock: originalStock,
          createdAt: Value(createdAt),
          lastUpdated: Value(lastUpdated),
          isDeleted: Value(isDeleted),
          isSynced: Value(true),
          cloudId: Value(cloudId),
        ),
      );
    } catch (e) {
      print('❌ Error upserting change request from cloud: $e');
      rethrow;
    }
  }

  /// ✅ Get change request by cloud ID
  Future<StockChangeRequest?> getChangeRequestByCloudId(String cloudId) async {
    try {
      return await (select(stockChangeRequests)
        ..where((t) => t.cloudId.equals(cloudId)))
        .getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching change request by cloud ID: $e');
      return null;
    }
  }
}

/// ✅ Sorting options for change requests
enum ChangeSortOrder {
  newestFirst,
  oldestFirst,
}