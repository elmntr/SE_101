// // lib/database/seeders/employee_seeder.dart
// import 'package:drift/drift.dart';
// import '../app_database.dart';

// /// Responsible for creating the Employee role and test account
// class EmployeeSeeder {
//   static Future<void> seed(AppDatabase db) async {
//     final employeeRole = await _createEmployeeRole(db);
//     await _createEmployeeUser(db, employeeRole);
//   }

//   /// Creates Employee role with limited permissions
//   static Future<Role> _createEmployeeRole(AppDatabase db) async {
//     final existingRoles = await db.rolesDao.getAllRoles();
//     final existingEmployee = existingRoles.where((r) => r.name == 'employee').firstOrNull;

//     if (existingEmployee != null) {
//       return existingEmployee;
//     }

//     final roleId = await db.rolesDao.insertRole(
//       RolesCompanion.insert(
//         name: 'employee',
//         description: const Value('Test Employee Role'),
//         canViewInventory: const Value(true),
//         canAddInventory: const Value(false),
//         canEditInventory: const Value(false),
//         canDeleteInventory: const Value(false),
//         canViewReports: const Value(false),
//         canExportData: const Value(false),
//         canAccessSettings: const Value(false),
//       ),
//     );

//     return (await db.rolesDao.getAllRoles())
//         .firstWhere((r) => r.id == roleId);
//   }

//   /// Creates Employee user account
//   static Future<void> _createEmployeeUser(AppDatabase db, Role employeeRole) async {
//     final existingUsers = await db.usersDao.getAllUsers();
//     final alreadyExists = existingUsers.any((u) => u.username == 'employee');

//     if (alreadyExists) {
//       print('👤 Employee user already exists');
//       return;
//     }

//     await db.usersDao.insertUser(
//       UsersCompanion.insert(
//         username: 'employee',
//         email: 'employee@example.com',
//         password: 'password123',
//         roleId: employeeRole.id,
//         isActive: const Value(true),
//       ),
//     );
//     print('✅ Test employee account created: employee / password123');
//   }
// }