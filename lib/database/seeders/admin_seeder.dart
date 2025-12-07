// lib/database/seeders/admin_seeder.dart
import 'package:drift/drift.dart';
import '../app_database.dart';

/// Responsible for creating the Admin role and account safely on all platforms
class AdminSeeder {
  /// Entry point to seed Admin role and user
  static Future<void> seed(AppDatabase db) async {
    try {
      // Wrap all operations in a transaction for safety
      await db.transaction(() async {
        final adminRole = await _createAdminRole(db);
        await _createAdminUser(db, adminRole);
      });
    } catch (e, stack) {
      print('❌ AdminSeeder failed: $e');
      print(stack);
    }
  }

  /// Creates Admin role with full permissions, if it doesn't exist
  static Future<Role> _createAdminRole(AppDatabase db) async {
    final existingRoles = await db.rolesDao.getAllRoles();

    // Safely check for existing Admin role
    final admins = existingRoles.where((r) => r.name == 'Admin').toList();
      if (admins.isNotEmpty) {
        print('👑 Admin role already exists');
        return admins.first;
      }


   

    // Insert new Admin role
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

    // Retrieve newly created role
    final adminRole = (await db.rolesDao.getAllRoles())
        .firstWhere((r) => r.id == roleId);

    print('✅ Admin role created successfully');
    return adminRole;
  }

  /// Creates Admin user account if it doesn't exist
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
    print('⚠️ IMPORTANT: Change this password after first login!');
  }
}
