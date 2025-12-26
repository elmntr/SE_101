// test/daos/organizations_dao_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import '../database/test_database.dart';
import 'package:chickenjoo_inventory/database/daos/organizations_dao.dart';

void main() {
  late AppDatabase db;
  late OrganizationsDao organizationsDao;

  setUp(() {
    db = createTestDatabase();
    organizationsDao = db.organizationsDao;
  });

  tearDown(() async {
    await db.close();
  });

  test('1. Insert commissary successfully', () async {
    final id = await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Main Commissary',
        type: 'commissary',
      ),
    );
    final org = await organizationsDao.getOrganizationById(id);
    expect(org, isNotNull);
    expect(org!.name, 'Main Commissary');
    expect(org.type, 'commissary');
  });

  test('2. Insert franchisee successfully', () async {
    final commissaryId = await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Main Commissary',
        type: 'commissary',
      ),
    );
    final franchiseeId = await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Branch A',
        type: 'franchisee',
        parentCommissaryId: Value(commissaryId),
      ),
    );
    final org = await organizationsDao.getOrganizationById(franchiseeId);
    expect(org, isNotNull);
    expect(org!.parentCommissaryId, commissaryId);
  });

  test('3. Insert franchisee fails without parent commissary', () async {
    expect(
      () => organizationsDao.insertOrganization(
        OrganizationsCompanion.insert(name: 'Branch A', type: 'franchisee'),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('4. Get all organizations returns correct count', () async {
    final c1Id = await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Com1', type: 'commissary'),
    );
    await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Fra1',
        type: 'franchisee',
        parentCommissaryId: Value(c1Id),
      ),
    );
    final orgs = await organizationsDao.getAllOrganizations();
    expect(orgs.length, 2);
  });

  test('5. Update organization changes its properties', () async {
    final id = await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Old Name', type: 'commissary'),
    );
    final org = (await organizationsDao.getOrganizationById(id))!;
    await organizationsDao.updateOrganization(org.copyWith(name: 'New Name'));
    final updated = await organizationsDao.getOrganizationById(id);
    expect(updated!.name, 'New Name');
  });

  test('6. Deactivate organization marks it as inactive', () async {
    final id = await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'To Deactivate', type: 'commissary'),
    );
    await organizationsDao.deactivateOrganization(id);
    final org = await organizationsDao.getOrganizationById(id);
    expect(org!.isActive, isFalse);
  });

  test('7. Get all organizations ignores inactive ones by default', () async {
    await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Active', type: 'commissary'),
    );
    final id = await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Inactive', type: 'commissary'),
    );
    await organizationsDao.deactivateOrganization(id);
    final orgs = await organizationsDao.getAllOrganizations(isActive: true);
    expect(orgs.length, 1);
    expect(orgs.first.name, 'Active');
  });

  test('8. Reactivate organization marks it as active', () async {
    final id = await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'To Reactivate', type: 'commissary'),
    );
    await organizationsDao.deactivateOrganization(id);
    await organizationsDao.reactivateOrganization(id);
    final org = await organizationsDao.getOrganizationById(id);
    expect(org!.isActive, isTrue);
  });

  test('9. Get all commissaries returns only commissaries', () async {
    final c1Id = await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Com1', type: 'commissary'),
    );
    await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Fra1',
        type: 'franchisee',
        parentCommissaryId: Value(c1Id),
      ),
    );
    final commissaries = await organizationsDao.getAllCommissaries();
    expect(commissaries.length, 1);
    expect(commissaries.first.name, 'Com1');
  });

  test('10. Get all franchisees returns only franchisees', () async {
    final cId = await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Com1', type: 'commissary'),
    );
    await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Fra1',
        type: 'franchisee',
        parentCommissaryId: Value(cId),
      ),
    );
    final franchisees = await organizationsDao.getAllFranchisees();
    expect(franchisees.length, 1);
    expect(franchisees.first.name, 'Fra1');
  });

  test('11. Get franchisees by commissary filters correctly', () async {
    final c1Id = await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Com1', type: 'commissary'),
    );
    final c2Id = await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Com2', type: 'commissary'),
    );
    await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Fra1',
        type: 'franchisee',
        parentCommissaryId: Value(c1Id),
      ),
    );
    await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Fra2',
        type: 'franchisee',
        parentCommissaryId: Value(c2Id),
      ),
    );

    final c1Franchisees = await organizationsDao.getFranchiseesByCommissary(
      c1Id,
    );
    expect(c1Franchisees.length, 1);
    expect(c1Franchisees.first.name, 'Fra1');
  });

  test('12. Deactivate fails if organization has active users', () async {
    final cId = await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Com', type: 'commissary'),
    );
    final orgId = await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Org With User',
        type: 'franchisee',
        parentCommissaryId: Value(cId),
      ),
    );
    final roleId = await db.rolesDao.insertRole(
      RolesCompanion.insert(name: 'Test Role'),
    );
    await db.usersDao.insertUser(
      UsersCompanion.insert(
        username: 'test',
        email: 'a@b.c',
        password: 'pw',
        organizationId: orgId,
        roleId: roleId,
      ),
    );

    expect(
      () => organizationsDao.deactivateOrganization(orgId),
      throwsException,
    );
  });

  test('13. Deactivate fails if organization has active items', () async {
    final cId = await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Com', type: 'commissary'),
    );
    final orgId = await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Org With Item',
        type: 'franchisee',
        parentCommissaryId: Value(cId),
      ),
    );
    await db.itemsDao.insertItem(name: 'Test Item', organizationId: orgId);

    expect(
      () => organizationsDao.deactivateOrganization(orgId),
      throwsException,
    );
  });

  test('14. Get organization count works with filters', () async {
    final cId = await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Com1', type: 'commissary'),
    );
    await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Fra1',
        type: 'franchisee',
        parentCommissaryId: Value(cId),
      ),
    );
    await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Fra2',
        type: 'franchisee',
        parentCommissaryId: Value(cId),
      ),
    );

    final count = await organizationsDao.getOrganizationCount(
      type: 'franchisee',
    );
    expect(count, 2);
  });

  test('15. Get main commissary returns the first created one', () async {
    await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'Second Commissary',
        type: 'commissary',
      ),
    );
    await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(
        name: 'First Commissary',
        type: 'commissary',
      ),
    );

    final main = await organizationsDao.getMainCommissary();
    expect(main, isNotNull);
    // Note: Order of insertion matters. The test db is not seeded, so the first one we insert should be the main one.
    // Let's re-insert to be sure of the order.
    await db.customStatement('DELETE FROM organizations');
    final firstId = await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'First', type: 'commissary'),
    );
    await organizationsDao.insertOrganization(
      OrganizationsCompanion.insert(name: 'Second', type: 'commissary'),
    );

    final mainAfterReset = await organizationsDao.getMainCommissary();
    expect(mainAfterReset!.id, firstId);
  });

  test(
    '16. Get organization by name finds the correct active organization',
    () async {
      await organizationsDao.insertOrganization(
        OrganizationsCompanion.insert(name: 'FindMe', type: 'commissary'),
      );
      final id = await organizationsDao.insertOrganization(
        OrganizationsCompanion.insert(
          name: 'FindMeButInactive',
          type: 'commissary',
        ),
      );
      await organizationsDao.deactivateOrganization(id);

      final org = await organizationsDao.getOrganizationByName('FindMe');
      expect(org, isNotNull);
      expect(org!.isActive, isTrue);
    },
  );
}
