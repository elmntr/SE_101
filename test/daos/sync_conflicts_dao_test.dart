// test/daos/sync_conflicts_dao_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import '../database/test_database.dart';
import 'package:chickenjoo_inventory/database/daos/sync_conflicts_dao.dart';

void main() {
  late AppDatabase db;
  late SyncConflictsDao dao;

  setUp(() {
    db = createTestDatabase();
    dao = db.syncConflictsDao;
  });

  tearDown(() async {
    await db.close();
  });

  test('1. logConflict inserts a new conflict record', () async {
    final id = await dao.logConflict(
      sourceTable: 'items',
      cloudId: 'cloud-123',
      localData: '{"name":"Local Item"}',
      cloudData: '{"name":"Cloud Item"}',
      conflictType: 'bothModified',
    );
    expect(id, greaterThan(0));
  });

  test('2. getUnresolvedConflicts returns unresolved entries', () async {
    await dao.logConflict(
      sourceTable: 'items',
      cloudId: 'cloud-1',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'bothModified',
    );
    await dao.logConflict(
      sourceTable: 'users',
      cloudId: 'cloud-2',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'localDeletedCloudModified',
    );
    final conflicts = await dao.getUnresolvedConflicts();
    expect(conflicts.length, equals(2));
  });

  test('3. markResolved marks a conflict as resolved', () async {
    final id = await dao.logConflict(
      sourceTable: 'items',
      cloudId: 'cloud-1',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'bothModified',
    );
    final result = await dao.markResolved(id: id, resolution: 'localWins');
    expect(result, isTrue);
    final conflicts = await dao.getUnresolvedConflicts();
    expect(conflicts, isEmpty);
  });

  test('4. resolveKeepLocal sets resolution to localWins', () async {
    final id = await dao.logConflict(
      sourceTable: 'items',
      cloudId: 'cloud-1',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'bothModified',
    );
    await dao.resolveKeepLocal(id: id);
    final all = await dao.getAllConflicts();
    expect(all.first.resolution, equals('localWins'));
  });

  test('5. resolveKeepCloud sets resolution to cloudWins', () async {
    final id = await dao.logConflict(
      sourceTable: 'items',
      cloudId: 'cloud-1',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'bothModified',
    );
    await dao.resolveKeepCloud(id: id);
    final all = await dao.getAllConflicts();
    expect(all.first.resolution, equals('cloudWins'));
  });

  test('6. getUnresolvedConflictCount returns correct count', () async {
    await dao.logConflict(
      sourceTable: 'items',
      cloudId: 'a',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'bothModified',
    );
    await dao.logConflict(
      sourceTable: 'items',
      cloudId: 'b',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'bothModified',
    );
    final count = await dao.getUnresolvedConflictCount();
    expect(count, equals(2));
  });

  test('7. deleteConflict removes a specific conflict', () async {
    final id = await dao.logConflict(
      sourceTable: 'items',
      cloudId: 'cloud-1',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'bothModified',
    );
    final deleted = await dao.deleteConflict(id);
    expect(deleted, isTrue);
    final count = await dao.getUnresolvedConflictCount();
    expect(count, equals(0));
  });

  test('8. deleteAllResolved removes only resolved conflicts', () async {
    final id1 = await dao.logConflict(
      sourceTable: 'items',
      cloudId: 'a',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'bothModified',
    );
    await dao.logConflict(
      sourceTable: 'items',
      cloudId: 'b',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'bothModified',
    );
    await dao.markResolved(id: id1, resolution: 'localWins');
    final deletedCount = await dao.deleteAllResolved();
    expect(deletedCount, equals(1));
    final remaining = await dao.getAllConflicts();
    expect(remaining.length, equals(1));
  });

  test('9. getAllConflicts returns both resolved and unresolved', () async {
    final id = await dao.logConflict(
      sourceTable: 'items',
      cloudId: 'a',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'bothModified',
    );
    await dao.logConflict(
      sourceTable: 'users',
      cloudId: 'b',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'bothModified',
    );
    await dao.markResolved(id: id, resolution: 'localWins');
    final all = await dao.getAllConflicts();
    expect(all.length, equals(2));
  });

  test('10. getAllConflicts with includeResolved=false excludes resolved', () async {
    final id = await dao.logConflict(
      sourceTable: 'items',
      cloudId: 'a',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'bothModified',
    );
    await dao.logConflict(
      sourceTable: 'users',
      cloudId: 'b',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'bothModified',
    );
    await dao.markResolved(id: id, resolution: 'localWins');
    final unresolved = await dao.getAllConflicts(includeResolved: false);
    expect(unresolved.length, equals(1));
  });

  test('11. getConflictsGroupedByTable groups correctly', () async {
    await dao.logConflict(
      sourceTable: 'items',
      cloudId: 'a',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'bothModified',
    );
    await dao.logConflict(
      sourceTable: 'items',
      cloudId: 'b',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'bothModified',
    );
    await dao.logConflict(
      sourceTable: 'users',
      cloudId: 'c',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'bothModified',
    );
    final grouped = await dao.getConflictsGroupedByTable();
    expect(grouped.keys.length, equals(2));
    expect(grouped['items']!.length, equals(2));
    expect(grouped['users']!.length, equals(1));
  });

  test('12. logConflict with organizationId stores it correctly', () async {
    await dao.logConflict(
      sourceTable: 'items',
      cloudId: 'cloud-1',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'bothModified',
      organizationId: 42,
    );
    final conflicts = await dao.getUnresolvedConflicts(organizationId: 42);
    expect(conflicts.length, equals(1));
    expect(conflicts.first.organizationId, equals(42));
  });

  test('13. getUnresolvedConflicts filters by organizationId', () async {
    await dao.logConflict(
      sourceTable: 'items',
      cloudId: 'a',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'bothModified',
      organizationId: 1,
    );
    await dao.logConflict(
      sourceTable: 'items',
      cloudId: 'b',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'bothModified',
      organizationId: 2,
    );
    final org1 = await dao.getUnresolvedConflicts(organizationId: 1);
    expect(org1.length, equals(1));
  });

  test('14. markResolved with notes stores notes', () async {
    final id = await dao.logConflict(
      sourceTable: 'items',
      cloudId: 'cloud-1',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'bothModified',
    );
    await dao.markResolved(id: id, resolution: 'manual', notes: 'Reviewed by admin');
    final all = await dao.getAllConflicts();
    expect(all.first.notes, equals('Reviewed by admin'));
  });

  test('15. watchUnresolvedConflicts emits updates', () async {
    final stream = dao.watchUnresolvedConflicts();
    final future = stream.first;
    await dao.logConflict(
      sourceTable: 'items',
      cloudId: 'watch-test',
      localData: '{}',
      cloudData: '{}',
      conflictType: 'bothModified',
    );
    final result = await future;
    expect(result, isNotEmpty);
  });
}
