// test/daos/stock_replenishment_requests_dao_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import '../database/test_database.dart';
import 'package:chickenjoo_inventory/database/daos/stock_replenishment_requests_dao.dart';

void main() {
  late AppDatabase db;
  late StockReplenishmentRequestsDao dao;
  late int commissaryId;
  late int franchiseeId;
  late int itemId;
  late int requesterId;
  late int reviewerId;

  setUp(() async {
    db = createTestDatabase();
    dao = db.stockReplenishmentRequestsDao;

    commissaryId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Commissary', type: 'commissary'),
    );
    franchiseeId = await db.organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Franchisee', type: 'franchisee', parentCommissaryId: Value(commissaryId)),
    );
    final roleId = await db.rolesDao.insertRole(RolesCompanion.insert(name: 'Franchisee Owner'));
    final reviewerRoleId = await db.rolesDao.insertRole(RolesCompanion.insert(name: 'Commissary Staff'));

    requesterId = await db.usersDao.insertUser(UsersCompanion.insert(username: 'req', email: 'r@r.com', password: 'pw', organizationId: franchiseeId, roleId: roleId));
    reviewerId = await db.usersDao.insertUser(UsersCompanion.insert(username: 'rev', email: 'v@v.com', password: 'pw', organizationId: commissaryId, roleId: reviewerRoleId));

    itemId = await db.itemsDao.insertItem(name: 'Test Item', organizationId: commissaryId); // Master item at commissary
  });

  tearDown(() async {
    await db.close();
  });

  test('1. Create request starts in pending status', () async {
    final id = await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 10, requestedBy: requesterId);
    final req = await dao.getRequestById(id);
    expect(req, isNotNull);
    expect(req!.status, 'pending');
  });

  test('2. Approve request moves status to approved', () async {
    final id = await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 10, requestedBy: requesterId);
    await dao.approveRequest(requestId: id, reviewedBy: reviewerId);
    final req = await dao.getRequestById(id);
    expect(req!.status, 'approved');
  });

  test('3. Reject request moves status to rejected', () async {
    final id = await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 10, requestedBy: requesterId);
    await dao.rejectRequest(requestId: id, reviewedBy: reviewerId, reason: 'Out of stock');
    final req = await dao.getRequestById(id);
    expect(req!.status, 'rejected');
    expect(req.commissaryNotes, 'Out of stock');
  });

  test('4. Mark as delivered moves status to delivered', () async {
    final id = await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 10, requestedBy: requesterId);
    await dao.approveRequest(requestId: id, reviewedBy: reviewerId);
    await dao.markAsDelivered(id);
    final req = await dao.getRequestById(id);
    expect(req!.status, 'delivered');
  });

  test('5. Get pending requests for commissary returns correct list', () async {
    final id1 = await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 10, requestedBy: requesterId);
    final id2 = await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 20, requestedBy: requesterId);
    await dao.approveRequest(requestId: id2, reviewedBy: reviewerId);

    final pending = await dao.getPendingRequestsForCommissary(commissaryId);
    expect(pending.length, 1);
    expect(pending.first.id, id1);
  });

  test('6. Get approved requests awaiting delivery returns correct list', () async {
    await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 10, requestedBy: requesterId); // Pending
    final id2 = await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 20, requestedBy: requesterId);
    await dao.approveRequest(requestId: id2, reviewedBy: reviewerId);

    final approved = await dao.getApprovedRequestsAwaitingDelivery(commissaryId);
    expect(approved.length, 1);
    expect(approved.first.id, id2);
  });

  test('7. Get franchisee request history returns all their requests', () async {
    final otherFranchiseeId = await db.organizationsDao.insertOrganization(OrganizationsCompanion.insert(name: 'Other', type: 'franchisee', parentCommissaryId: Value(commissaryId)));
    await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 10, requestedBy: requesterId);
    await dao.createRequest(franchiseeId: otherFranchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 20, requestedBy: requesterId);

    final history = await dao.getFranchiseeRequestHistory(franchiseeId);
    expect(history.length, 1);
  });

  test('8. Soft delete request marks it as deleted', () async {
    final id = await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 10, requestedBy: requesterId);
    await dao.softDeleteRequest(id);
    final req = await dao.getRequestById(id);
    expect(req!.isDeleted, isTrue);
  });

  test('9. Get all requests ignores soft-deleted ones', () async {
    await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 10, requestedBy: requesterId);
    final id2 = await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 20, requestedBy: requesterId);
    await dao.softDeleteRequest(id2);
    final reqs = await dao.getAllRequests();
    expect(reqs.length, 1);
  });

  test('10. Get request count works with status filter', () async {
    await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 10, requestedBy: requesterId); // Pending
    final id2 = await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 20, requestedBy: requesterId);
    await dao.approveRequest(requestId: id2, reviewedBy: reviewerId);

    final count = await dao.getRequestCount(status: 'pending');
    expect(count, 1);
  });

  test('11. Get request count works with franchisee filter', () async {
    final otherFranchiseeId = await db.organizationsDao.insertOrganization(OrganizationsCompanion.insert(name: 'Other', type: 'franchisee', parentCommissaryId: Value(commissaryId)));
    await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 10, requestedBy: requesterId);
    await dao.createRequest(franchiseeId: otherFranchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 20, requestedBy: requesterId);

    final count = await dao.getRequestCount(franchiseeId: franchiseeId);
    expect(count, 1);
  });

  test('12. Get request count works with commissary filter', () async {
    final otherCommissaryId = await db.organizationsDao.insertOrganization(OrganizationsCompanion.insert(name: 'Other Comm', type: 'commissary'));
    await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 10, requestedBy: requesterId);
    await dao.createRequest(franchiseeId: franchiseeId, commissaryId: otherCommissaryId, itemId: itemId, quantityRequested: 20, requestedBy: requesterId);

    final count = await dao.getRequestCount(commissaryId: commissaryId);
    expect(count, 1);
  });

  test('13. Get franchisee request stats returns correct counts', () async {
    final id1 = await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 1, requestedBy: requesterId);
    final id2 = await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 2, requestedBy: requesterId);
    final id3 = await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 3, requestedBy: requesterId);
    await dao.approveRequest(requestId: id1, reviewedBy: reviewerId);
    await dao.rejectRequest(requestId: id2, reviewedBy: reviewerId, reason: '');

    final stats = await dao.getFranchiseeRequestStats(franchiseeId);
    expect(stats['total'], 3);
    expect(stats['pending'], 1);
    expect(stats['approved'], 1);
    expect(stats['rejected'], 1);
    expect(stats['delivered'], 0);
  });

  test('14. Get unsynced count is correct', () async {
    final id1 = await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 1, requestedBy: requesterId);
    await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 2, requestedBy: requesterId);
    await dao.markAsSynced([id1]);

    final count = await dao.getUnsyncedRequestCount();
    expect(count, 1);
  });

  test('15. Sort order works correctly (oldest first)', () async {
    final id1 = await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 1, requestedBy: requesterId);
    await Future.delayed(const Duration(milliseconds: 10)); // Ensure different timestamps
    final id2 = await dao.createRequest(franchiseeId: franchiseeId, commissaryId: commissaryId, itemId: itemId, quantityRequested: 2, requestedBy: requesterId);

    final requests = await dao.getAllRequests(sortOrder: RequestSortOrder.oldestFirst);
    expect(requests.first.id, id1);
    expect(requests.last.id, id2);
  });
}
