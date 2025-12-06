// lib/database/seeders/admin_seeder.dart
import 'package:drift/drift.dart';
import '../app_database.dart';

/// Responsible for creating the Admin role and account
class AdminSeeder {
  static Future<void> seed(AppDatabase db) async {
    final adminRole = await _createAdminRole(db);
    await _createAdminUser(db, adminRole);
  }

  /// Creates Admin role with full permissions
  static Future<Role> _createAdminRole(AppDatabase db) async {
    final existingRoles = await db.rolesDao.getAllRoles();
    final existingAdmin = existingRoles.where((r) => r.name == 'Admin').firstOrNull;

    if (existingAdmin != null) {
      print('👑 Admin role already exists');
      return existingAdmin;
    }

    print('🔧 Creating Admin role...');
    final roleId = await db.rolesDao.insertRole(
      RolesCompanion.insert(
        name: 'Admin',
        description: const Value('System Administrator with full access'),
        canViewInventory: const Value(true),
        canAddInventory: const Value(true),
        canEditInventory: const Value(true),
        canDeleteInventory: const Value(true),
        canViewReports: const Value(true),
        canExportData: const Value(true),
        canAccessSettings: const Value(true),
        canManageEmployees: const Value(true),
        canManageRoles: const Value(true),
        isSystemRole: const Value(true),
      ),
    );

    final adminRole = (await db.rolesDao.getAllRoles())
        .firstWhere((r) => r.id == roleId);
    print('✅ Admin role created successfully');
    return adminRole;
  }

  /// Creates Admin user account
  static Future<void> _createAdminUser(AppDatabase db, Role adminRole) async {
    final existingUsers = await db.usersDao.getAllUsers();
    final adminExists = existingUsers.any((u) => u.username == 'admin');

    if (adminExists) {
      print('👑 Admin user already exists');
      return;
    }

    print('🔧 Creating Admin user account...');
    await db.usersDao.insertUser(
      UsersCompanion.insert(
        username: 'admin',
        email: 'admin@commissary.com',
        password: 'admin123',
        roleId: adminRole.id,
        isActive: const Value(true),
      ),
    );

    print('✅ Admin account created successfully!');
    print('📧 Email: admin@commissary.com');
    print('🔑 Password: admin123');
    print('⚠️  IMPORTANT: Change this password after first login!');
  }
}