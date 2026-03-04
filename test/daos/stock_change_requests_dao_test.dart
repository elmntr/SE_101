// test/daos/stock_change_requests_dao_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import '../database/test_database.dart';
import 'package:chickenjoo_inventory/database/daos/stock_change_requests_dao.dart';

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
}
