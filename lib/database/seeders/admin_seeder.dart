// // lib/database/seeders/admin_seeder.dart
// import 'package:drift/drift.dart';
// import '../app_database.dart';

// /// Responsible for creating the Admin role and account safely on all platforms
// class AdminSeeder {
//   /// Entry point to seed Admin role and user
//   static Future<void> seed(AppDatabase db) async {
//     try {
//       await db.transaction(() async {
//         final adminRole = await _createAdminRole(db);
//         await _createAdminUser(db, adminRole);
//       });

//       print('✅ Admin seeding completed');
//     } catch (e, stack) {
//       print('❌ AdminSeeder failed: $e');
//       print(stack);
//     }
//   }

//   /// Creates Admin role with full permissions, if it doesn't exist
//   static Future<Role> _createAdminRole(AppDatabase db) async {
//     final existingRoles = await db.rolesDao.getAllRoles();

//     final admins = existingRoles.where((r) => r.name == 'Admin').toList();
//     if (admins.isNotEmpty) {
//       print('👑 Admin role already exists (ID: ${admins.first.id})');

//       if (!admins.first.isSynced) {
//         print('   📤 Admin role needs syncing');
//       }

//       return admins.first;
//     }

//     print('🔧 Creating Admin role...');

//     final roleId = await db.rolesDao.insertRole(
//       RolesCompanion.insert(
//         name: 'Admin',
//         description: const Value('System Administrator with full access'),
//         canViewInventory: const Value(true),
//         canAddInventory: const Value(true),
//         canEditInventory: const Value(true),
//         canDeleteInventory: const Value(true),
//         canViewReports: const Value(true),
//         canExportData: const Value(true),
//         canAccessSettings: const Value(true),
//         canManageEmployees: const Value(true),
//         canManageRoles: const Value(true),
//         isSystemRole: const Value(true),
//         isSynced: const Value(false),
//       ),
//     );

//     final adminRole = (await db.rolesDao.getAllRoles())
//         .firstWhere((r) => r.id == roleId);

//     print('✅ Admin role created successfully (ID: $roleId)');
//     return adminRole;
//   }

//   /// Creates Admin user account if it doesn't exist
//   static Future<void> _createAdminUser(AppDatabase db, Role adminRole) async {
//     final existingUsers = await db.usersDao.getAllUsers();

//     final adminExists = existingUsers.any((u) => u.username == 'admin');

//     if (adminExists) {
//       final adminUser =
//           existingUsers.firstWhere((u) => u.username == 'admin');

//       print('👑 Admin user already exists (ID: ${adminUser.id})');

//       if (!adminUser.isSynced) {
//         print('   📤 Admin user needs syncing');
//       }

//       return;
//     }

//     print('🔧 Creating Admin user account...');

//     // -----------------------------------------------------------------------
//     // ✔️ ALWAYS hash password correctly here
//     // -----------------------------------------------------------------------
//     final hashedPassword = hashPassword('admin123');

//     // -----------------------------------------------------------------------
//     // ✔️ Insert admin user with hashed password
//     // -----------------------------------------------------------------------
//     await db.usersDao.insertUser(
//       UsersCompanion.insert(
//         username: 'admin',
//         email: 'admin@commissary.com',
//         password: hashedPassword,
//         roleId: adminRole.id,
//         isActive: const Value(true),
//         isSynced: const Value(false),
//       ),
//     );

//     print('✅ Admin account created successfully!');
//     print('📧 Email: admin@commissary.com');
//     print('🔑 Password: admin123');
//     print('📤 Will sync to cloud on next sync cycle');
//     print('⚠️ IMPORTANT: Change this password after first login!');
//   }
// }
