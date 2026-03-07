// test/daos/stock_change_requests_dao_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import '../database/test_database.dart';
import 'package:chickenjoo_inventory/database/daos/stock_change_requests_dao.dart';

/// Sentinel to distinguish "not provided" from "explicitly null" in test helpers.
const _absent = Object();

void main() {
  late AppDatabase db;
  late StockChangeRequestsDao dao;
  late int franchiseeId;
  late int itemId;
  late int employeeId;
  late int managerId;

  setUp(() async {
    db = createTestDatabase();
    dao = db.stockChangeRequestsDao;

    final commissaryId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Test Commissary',
        type: 'commissary',
      ),
    );
    franchiseeId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Franchisee',
        type: 'franchisee',
        parentCommissaryId: Value(commissaryId),
      ),
    );
    final roleId = await db.rolesDao.insertRole(
      RolesCompanion.insert(name: 'Employee'),
    );
    final managerRoleId = await db.rolesDao.insertRole(
      RolesCompanion.insert(name: 'Manager'),
    );

    employeeId = await db.usersDao.insertUser(
      UsersCompanion.insert(
        username: 'emp',
        email: 'e@e.com',
        password: 'pw',
        organizationId: franchiseeId,
        roleId: roleId,
      ),
    );
    managerId = await db.usersDao.insertUser(
      UsersCompanion.insert(
        username: 'man',
        email: 'm@m.com',
        password: 'pw',
        organizationId: franchiseeId,
        roleId: managerRoleId,
      ),
    );

    itemId = await db.itemsDao.insertItem(
      name: 'Test Item',
      organizationId: franchiseeId,
      stock: 100,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('1. Create change request starts in draft status', () async {
    final id = await dao.createChangeRequest(
      franchiseeId: franchiseeId,
      itemId: itemId,
      changeType: 'sold',
      quantity: 5,
      requestedBy: employeeId,
      originalStock: 100,
    );
    final req = await dao.getChangeRequestById(id);
    expect(req, isNotNull);
    expect(req!.status, 'draft');
  });

  test('2. Submit change request moves status to pending', () async {
    final id = await dao.createChangeRequest(
      franchiseeId: franchiseeId,
      itemId: itemId,
      changeType: 'sold',
      quantity: 5,
      requestedBy: employeeId,
      originalStock: 100,
    );
    await dao.submitChangeRequest(id);
    final req = await dao.getChangeRequestById(id);
    expect(req!.status, 'pending');
  });

  test(
    '3. Approve sold request: status becomes approved, stock unchanged (PosService owns stock)',
    () async {
      final id = await dao.createChangeRequest(
        franchiseeId: franchiseeId,
        itemId: itemId,
        changeType: 'sold',
        quantity: 10,
        requestedBy: employeeId,
        originalStock: 100,
      );
      // Manually set to pending (simulating employee submit without PosService auto-approve)
      await (db.update(db.stockChangeRequests)..where((t) => t.id.equals(id)))
          .write(const StockChangeRequestsCompanion(status: Value('pending')));
      await dao.approveChangeRequest(requestId: id, reviewedBy: managerId);

      final req = await dao.getChangeRequestById(id);
      final item = await db.itemsDao.getItemById(itemId);

      expect(req!.status, 'approved');
      // Stock must NOT be touched here — PosService already applied it on submission.
      expect(item!.stock, 100);
    },
  );

  test('4. Approve spoiled request: status becomes approved, stock unchanged', () async {
    final id = await dao.createChangeRequest(
      franchiseeId: franchiseeId,
      itemId: itemId,
      changeType: 'spoiled',
      quantity: 5,
      requestedBy: employeeId,
      originalStock: 100,
    );
    // Manually set to pending
    await (db.update(db.stockChangeRequests)..where((t) => t.id.equals(id)))
        .write(const StockChangeRequestsCompanion(status: Value('pending')));
    await dao.approveChangeRequest(requestId: id, reviewedBy: managerId);

    final item = await db.itemsDao.getItemById(itemId);
    // Stock must NOT be touched here — PosService already applied it on submission.
    expect(item!.stock, 100);
  });

  test('5. Reject change request moves status to rejected', () async {
    final id = await dao.createChangeRequest(
      franchiseeId: franchiseeId,
      itemId: itemId,
      changeType: 'sold',
      quantity: 5,
      requestedBy: employeeId,
      originalStock: 100,
    );
    await dao.submitChangeRequest(id);
    await dao.rejectChangeRequest(
      requestId: id,
      reviewedBy: managerId,
      reason: 'Incorrect quantity',
    );

    final req = await dao.getChangeRequestById(id);
    final item = await db.itemsDao.getItemById(itemId);

    expect(req!.status, 'rejected');
    expect(item!.stock, 100); // Stock should not change
  });

  test('6. Get pending requests for franchisee returns correct list', () async {
    final id1 = await dao.createChangeRequest(
      franchiseeId: franchiseeId,
      itemId: itemId,
      changeType: 'sold',
      quantity: 1,
      requestedBy: employeeId,
      originalStock: 100,
    );
    await dao.submitChangeRequest(id1);
    await dao.createChangeRequest(
      franchiseeId: franchiseeId,
      itemId: itemId,
      changeType: 'sold',
      quantity: 2,
      requestedBy: employeeId,
      originalStock: 100,
    ); // Draft

    final pending = await dao.getPendingRequestsForFranchisee(franchiseeId);
    expect(pending.length, 1);
    expect(pending.first.id, id1);
  });

  test('7. Get employee drafts returns correct list', () async {
    final id1 = await dao.createChangeRequest(
      franchiseeId: franchiseeId,
      itemId: itemId,
      changeType: 'sold',
      quantity: 1,
      requestedBy: employeeId,
      originalStock: 100,
    );
    final id2 = await dao.createChangeRequest(
      franchiseeId: franchiseeId,
      itemId: itemId,
      changeType: 'sold',
      quantity: 2,
      requestedBy: employeeId,
      originalStock: 100,
    );
    await dao.submitChangeRequest(id2);

    final drafts = await dao.getEmployeeDrafts(employeeId);
    expect(drafts.length, 1);
    expect(drafts.first.id, id1);
  });

  test('8. Update draft change request modifies quantity and reason', () async {
    final id = await dao.createChangeRequest(
      franchiseeId: franchiseeId,
      itemId: itemId,
      changeType: 'sold',
      quantity: 5,
      requestedBy: employeeId,
      originalStock: 100,
      reason: 'Initial',
    );
    await dao.updateDraftChangeRequest(
      requestId: id,
      quantity: 10,
      reason: 'Updated',
    );
    final req = await dao.getChangeRequestById(id);
    expect(req!.quantity, 10);
    expect(req.reason, 'Updated');
  });

  test('9. Cannot update non-draft request', () async {
    final id = await dao.createChangeRequest(
      franchiseeId: franchiseeId,
      itemId: itemId,
      changeType: 'sold',
      quantity: 5,
      requestedBy: employeeId,
      originalStock: 100,
    );
    await dao.submitChangeRequest(id);
    final success = await dao.updateDraftChangeRequest(
      requestId: id,
      quantity: 10,
    );
    expect(success, isFalse);
  });

  test('10. Approve request for adjustment updates stock correctly', () async {
    final id = await dao.createChangeRequest(
      franchiseeId: franchiseeId,
      itemId: itemId,
      changeType: 'adjustment',
      quantity: -10,
      requestedBy: employeeId,
      originalStock: 100,
    );
    await dao.submitChangeRequest(id);
    await dao.approveChangeRequest(requestId: id, reviewedBy: managerId);
    final item = await db.itemsDao.getItemById(itemId);
    expect(item!.stock, 90);
  });

  test(
    '11. Approve return request restores BranchItemStock correctly',
    () async {
      // Set up: simulate what PosService would have written (stock=80, sold=20)
      await db.branchItemStockDao.createStock(
        BranchItemStockCompanion(
          organizationId: Value(franchiseeId),
          itemId: Value(itemId),
          stock: const Value(80),
          sold: const Value(20),
          spoilage: const Value(0),
          isSynced: const Value(false),
        ),
      );
      final id = await dao.createChangeRequest(
        franchiseeId: franchiseeId,
        itemId: itemId,
        changeType: 'return',
        quantity: 5,
        requestedBy: employeeId,
        originalStock: 80,
      );
      // Manually set to pending
      await (db.update(db.stockChangeRequests)..where((t) => t.id.equals(id)))
          .write(const StockChangeRequestsCompanion(status: Value('pending')));
      await dao.approveChangeRequest(requestId: id, reviewedBy: managerId);

      final branchStock = await db.branchItemStockDao
          .getStockForItem(franchiseeId, itemId);
      expect(branchStock!.stock, 85); // 80 + 5
      expect(branchStock.sold, 15);   // 20 - 5
    },
  );

  test('12. Soft delete request marks it as deleted', () async {
    final id = await dao.createChangeRequest(
      franchiseeId: franchiseeId,
      itemId: itemId,
      changeType: 'sold',
      quantity: 5,
      requestedBy: employeeId,
      originalStock: 100,
    );
    await dao.softDeleteChangeRequest(id);
    final req = await dao.getChangeRequestById(id);
    expect(req!.isDeleted, isTrue);
  });

  test('13. Get all requests ignores soft-deleted ones', () async {
    await dao.createChangeRequest(
      franchiseeId: franchiseeId,
      itemId: itemId,
      changeType: 'sold',
      quantity: 1,
      requestedBy: employeeId,
      originalStock: 100,
    );
    final id2 = await dao.createChangeRequest(
      franchiseeId: franchiseeId,
      itemId: itemId,
      changeType: 'sold',
      quantity: 2,
      requestedBy: employeeId,
      originalStock: 100,
    );
    await dao.softDeleteChangeRequest(id2);
    final reqs = await dao.getAllChangeRequests();
    expect(reqs.length, 1);
  });

  test('14. Get item change history returns correct list', () async {
    await dao.createChangeRequest(
      franchiseeId: franchiseeId,
      itemId: itemId,
      changeType: 'sold',
      quantity: 1,
      requestedBy: employeeId,
      originalStock: 100,
    );
    await dao.createChangeRequest(
      franchiseeId: franchiseeId,
      itemId: itemId,
      changeType: 'spoiled',
      quantity: 2,
      requestedBy: employeeId,
      originalStock: 99,
    );
    final history = await dao.getItemChangeHistory(itemId);
    expect(history.length, 2);
  });

  test('15. Get franchisee change stats returns correct counts', () async {
    final id1 = await dao.createChangeRequest(
      franchiseeId: franchiseeId,
      itemId: itemId,
      changeType: 'sold',
      quantity: 1,
      requestedBy: employeeId,
      originalStock: 100,
    );
    final id2 = await dao.createChangeRequest(
      franchiseeId: franchiseeId,
      itemId: itemId,
      changeType: 'sold',
      quantity: 2,
      requestedBy: employeeId,
      originalStock: 99,
    );
    await dao.submitChangeRequest(id1);
    await dao.submitChangeRequest(id2);
    await dao.approveChangeRequest(requestId: id1, reviewedBy: managerId);
    await dao.createChangeRequest(
      franchiseeId: franchiseeId,
      itemId: itemId,
      changeType: 'sold',
      quantity: 3,
      requestedBy: employeeId,
      originalStock: 98,
    ); // Draft

    final stats = await dao.getFranchiseeChangeStats(franchiseeId);
    expect(stats['total'], 3);
    expect(stats['draft'], 1);
    expect(stats['pending'], 1);
    expect(stats['approved'], 1);
    expect(stats['rejected'], 0);
  });

  // ==========================================================================
  // upsertBatchFromCloud – cloud coercion / null safety
  // ==========================================================================

  /// Helper: build a valid cloud record map with required fields.
  /// Pass explicit null to test null-handling (sentinel distinguishes from omission).
  Map<String, dynamic> _validCloudRecord({
    Object? franchiseeId = _absent,
    Object? itemId = _absent,
    Object? quantity = _absent,
    Object? requestedBy = _absent,
    Object? originalStock = _absent,
    Object? cloudId = _absent,
    String? changeType,
    String? status,
    Object? isDeleted = _absent,
  }) {
    return {
      'franchiseeId': identical(franchiseeId, _absent) ? 1 : franchiseeId,
      'itemId': identical(itemId, _absent) ? 1 : itemId,
      'quantity': identical(quantity, _absent) ? 5 : quantity,
      'requestedBy': identical(requestedBy, _absent) ? 1 : requestedBy,
      'originalStock': identical(originalStock, _absent) ? 100 : originalStock,
      'cloudId': identical(cloudId, _absent) ? 'cloud-uuid-1' : cloudId,
      'changeType': changeType ?? 'sold',
      'status': status ?? 'approved',
      'isDeleted': identical(isDeleted, _absent) ? false : isDeleted,
      'requestedAt': DateTime.now().toUtc().toIso8601String(),
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'lastUpdated': DateTime.now().toUtc().toIso8601String(),
    };
  }

  group('upsertBatchFromCloud coercion', () {
    test('16. Accepts int values for numeric fields', () async {
      await dao.upsertBatchFromCloud([
        _validCloudRecord(
          franchiseeId: franchiseeId,
          itemId: itemId,
          quantity: 7,
          requestedBy: employeeId,
          originalStock: 90,
          cloudId: 'int-test-1',
        ),
      ]);

      final req = await dao.getChangeRequestByCloudId('int-test-1');
      expect(req, isNotNull);
      expect(req!.quantity, 7);
      expect(req.originalStock, 90);
    });

    test('17. Coerces double values to int (e.g. 3.0 → 3)', () async {
      await dao.upsertBatchFromCloud([
        _validCloudRecord(
          franchiseeId: franchiseeId.toDouble(),
          itemId: itemId.toDouble(),
          quantity: 3.0,
          requestedBy: employeeId.toDouble(),
          originalStock: 50.0,
          cloudId: 'double-test-1',
        ),
      ]);

      final req = await dao.getChangeRequestByCloudId('double-test-1');
      expect(req, isNotNull);
      expect(req!.quantity, 3);
      expect(req.originalStock, 50);
      expect(req.franchiseeId, franchiseeId);
      expect(req.itemId, itemId);
      expect(req.requestedBy, employeeId);
    });

    test('18. Coerces numeric String values to int (e.g. "3" → 3)', () async {
      await dao.upsertBatchFromCloud([
        _validCloudRecord(
          franchiseeId: franchiseeId.toString(),
          itemId: itemId.toString(),
          quantity: '8',
          requestedBy: employeeId.toString(),
          originalStock: '42',
          cloudId: 'string-test-1',
        ),
      ]);

      final req = await dao.getChangeRequestByCloudId('string-test-1');
      expect(req, isNotNull);
      expect(req!.quantity, 8);
      expect(req.originalStock, 42);
    });

    test('19. Skips row when required numeric field is null', () async {
      await dao.upsertBatchFromCloud([
        _validCloudRecord(
          franchiseeId: franchiseeId,
          itemId: itemId,
          quantity: null,
          requestedBy: employeeId,
          originalStock: 100,
          cloudId: 'null-quantity-1',
        ),
      ]);

      final req = await dao.getChangeRequestByCloudId('null-quantity-1');
      expect(req, isNull, reason: 'Row with null required quantity should be skipped');
    });

    test('20. Skips row when originalStock is null', () async {
      await dao.upsertBatchFromCloud([
        _validCloudRecord(
          franchiseeId: franchiseeId,
          itemId: itemId,
          quantity: 5,
          requestedBy: employeeId,
          originalStock: null,
          cloudId: 'null-stock-1',
        ),
      ]);

      final req = await dao.getChangeRequestByCloudId('null-stock-1');
      expect(req, isNull, reason: 'Row with null required originalStock should be skipped');
    });

    test('21. Skips row when cloudId is null', () async {
      await dao.upsertBatchFromCloud([
        _validCloudRecord(
          franchiseeId: franchiseeId,
          itemId: itemId,
          quantity: 5,
          requestedBy: employeeId,
          originalStock: 100,
          cloudId: null,
        ),
      ]);

      // Nothing inserted — no way to look it up, just verify no crash
      final all = await dao.getAllChangeRequests();
      expect(all.where((r) => r.cloudId == null).isEmpty, isTrue);
    });

    test('22. Skips row when franchiseeId is null', () async {
      await dao.upsertBatchFromCloud([
        _validCloudRecord(
          franchiseeId: null,
          itemId: itemId,
          quantity: 5,
          requestedBy: employeeId,
          originalStock: 100,
          cloudId: 'null-fid-1',
        ),
      ]);

      final req = await dao.getChangeRequestByCloudId('null-fid-1');
      expect(req, isNull);
    });

    test('23. Mixed batch: valid rows inserted, invalid rows skipped', () async {
      await dao.upsertBatchFromCloud([
        // Valid
        _validCloudRecord(
          franchiseeId: franchiseeId,
          itemId: itemId,
          quantity: 1,
          requestedBy: employeeId,
          originalStock: 100,
          cloudId: 'batch-ok-1',
        ),
        // Invalid: null quantity
        _validCloudRecord(
          franchiseeId: franchiseeId,
          itemId: itemId,
          quantity: null,
          requestedBy: employeeId,
          originalStock: 100,
          cloudId: 'batch-bad-1',
        ),
        // Valid with doubles
        _validCloudRecord(
          franchiseeId: franchiseeId.toDouble(),
          itemId: itemId.toDouble(),
          quantity: 2.0,
          requestedBy: employeeId.toDouble(),
          originalStock: 80.0,
          cloudId: 'batch-ok-2',
        ),
      ]);

      expect(await dao.getChangeRequestByCloudId('batch-ok-1'), isNotNull);
      expect(await dao.getChangeRequestByCloudId('batch-bad-1'), isNull);
      expect(await dao.getChangeRequestByCloudId('batch-ok-2'), isNotNull);
    });

    test('24. Handles snake_case keys from raw cloud payload', () async {
      await dao.upsertBatchFromCloud([
        {
          'franchisee_id': franchiseeId,
          'item_id': itemId,
          'quantity': 6,
          'requested_by': employeeId,
          'original_stock': 77,
          'cloud_id': 'snake-test-1',
          'change_type': 'spoiled',
          'status': 'pending',
          'is_deleted': false,
          'requested_at': DateTime.now().toUtc().toIso8601String(),
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'last_updated': DateTime.now().toUtc().toIso8601String(),
        },
      ]);

      final req = await dao.getChangeRequestByCloudId('snake-test-1');
      expect(req, isNotNull);
      expect(req!.quantity, 6);
      expect(req.originalStock, 77);
      expect(req.changeType, 'spoiled');
    });

    test('25. Updates existing record on duplicate cloudId', () async {
      await dao.upsertBatchFromCloud([
        _validCloudRecord(
          franchiseeId: franchiseeId,
          itemId: itemId,
          quantity: 10,
          requestedBy: employeeId,
          originalStock: 100,
          cloudId: 'dup-test-1',
          status: 'draft',
        ),
      ]);

      final first = await dao.getChangeRequestByCloudId('dup-test-1');
      expect(first!.quantity, 10);
      expect(first.status, 'draft');

      await dao.upsertBatchFromCloud([
        _validCloudRecord(
          franchiseeId: franchiseeId,
          itemId: itemId,
          quantity: 20,
          requestedBy: employeeId,
          originalStock: 100,
          cloudId: 'dup-test-1',
          status: 'approved',
        ),
      ]);

      final updated = await dao.getChangeRequestByCloudId('dup-test-1');
      expect(updated!.quantity, 20);
      expect(updated.status, 'approved');
    });

    test('26. Coerces isDeleted from int (1) and string ("true")', () async {
      await dao.upsertBatchFromCloud([
        _validCloudRecord(
          franchiseeId: franchiseeId,
          itemId: itemId,
          quantity: 1,
          requestedBy: employeeId,
          originalStock: 100,
          cloudId: 'bool-int-1',
          isDeleted: 1,
        ),
      ]);
      final r1 = await dao.getChangeRequestByCloudId('bool-int-1');
      expect(r1!.isDeleted, isTrue);

      await dao.upsertBatchFromCloud([
        _validCloudRecord(
          franchiseeId: franchiseeId,
          itemId: itemId,
          quantity: 1,
          requestedBy: employeeId,
          originalStock: 100,
          cloudId: 'bool-str-1',
          isDeleted: 'true',
        ),
      ]);
      final r2 = await dao.getChangeRequestByCloudId('bool-str-1');
      expect(r2!.isDeleted, isTrue);
    });

    test('27. Coerces double string "3.5" to int 3 for quantity', () async {
      await dao.upsertBatchFromCloud([
        _validCloudRecord(
          franchiseeId: franchiseeId,
          itemId: itemId,
          quantity: '3.5',
          requestedBy: employeeId,
          originalStock: '100.9',
          cloudId: 'double-str-1',
        ),
      ]);

      final req = await dao.getChangeRequestByCloudId('double-str-1');
      expect(req, isNotNull);
      expect(req!.quantity, 3);
      expect(req.originalStock, 100);
    });
  });
}
