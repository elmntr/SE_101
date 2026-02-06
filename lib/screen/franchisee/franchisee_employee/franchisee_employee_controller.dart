// lib/screen/franchisee/franchisee_employee/franchisee_employee_controller.dart
import 'dart:async';
import 'package:chickenjoo_inventory/tables/tables.dart';
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/tables/sorting_and_filters.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:drift/drift.dart' show Value;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chickenjoo_inventory/services/search_service.dart';

/// Controller class that handles all the business logic for the employee page
class FranchiseeEmployeeController {
  FranchiseeEmployeeController({
    required this.db,
    required this.onStateChanged,
    required this.showSnackBar,
  });

  final AppDatabase db;
  final VoidCallback onStateChanged;
  final void Function(String message) showSnackBar;

  StreamSubscription<List<User>>? usersSub;
  StreamSubscription<List<Role>>? rolesSub;

  List<User> users = [];
  List<Role> roles = [];
  int? currentOrganizationId;

  /// Get roles available for franchisees (excludes commissary-specific roles)
  List<Role> get franchiseeRoles => roles.where((role) => 
    !role.name.toLowerCase().contains('commissary')
  ).toList();

  EmployeeSort currentEmployeeSort = EmployeeSort(
    EmployeeSortField.name,
    SortOrder.desc,
  );
  RoleSort currentRoleSort = RoleSort(RoleSortField.name, SortOrder.desc);
  int? selectedRoleFilter;
  static const int allRolesKey = -1;

  List<String> accessTitles = [
    "View Inventory",
    "Add Inventory",
    "Edit Inventory",
    "Delete Inventory",
    "Manage Employees",
    "Manage Roles",
    "View Reports",
    "Settings",
  ];

  int selectedTab = 0; // 0 = Employees, 1 = Roles
  bool isLoading = true;

  // Search functionality
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  static const String orgIdKey = 'current_organization_id';

  /// Get filtered roles based on search query and sorting
  List<Role> get filteredRoles {
    var list = roles.toList();

    // Filter out commissary-specific roles for franchisee view
    list = list.where((role) => 
      !role.name.toLowerCase().contains('commissary')
    ).toList();

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      list = SearchService.filterCategories(
        list,
        searchQuery,
        getName: (role) => role.name,
        getDescription: (role) => role.description,
      );
    }

    // Apply sorting
    switch (currentRoleSort.field) {
      case RoleSortField.name:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case RoleSortField.employees:
        list.sort((a, b) {
          final countA = users.where((u) => u.roleId == a.id).length;
          final countB = users.where((u) => u.roleId == b.id).length;
          return countA.compareTo(countB);
        });
        break;
      case RoleSortField.date:
        list.sort((a, b) => b.id.compareTo(a.id));
        break;
    }

    if (currentRoleSort.order == SortOrder.desc) {
      list = list.reversed.toList();
    }

    return list;
  }

  List<User> get filteredUsers {
    var list = users.toList();

    // Apply search filter first
    if (searchQuery.isNotEmpty) {
      list = SearchService.filterEmployees(
        list,
        searchQuery,
        getName: (user) => user.username,
        getEmail: (user) => user.email,
        getRole: (user) {
          final role = roles.where((r) => r.id == user.roleId).firstOrNull;
          return role?.name;
        },
      );
    }

    // Apply role filter
    if (selectedRoleFilter != null) {
      list = list.where((user) => user.roleId == selectedRoleFilter).toList();
    }

    // Then apply sorting
    switch (currentEmployeeSort.field) {
      case EmployeeSortField.name:
        list.sort((a, b) => (a.username).compareTo(b.username));
        break;
      case EmployeeSortField.email:
        list.sort((a, b) => a.email.compareTo(b.email));
        break;
      case EmployeeSortField.date:
        list.sort((a, b) => b.id.compareTo(a.id));
        break;
    }

    if (currentEmployeeSort.order == SortOrder.desc) {
      list = list.reversed.toList();
    }

    return list;
  }

  /// Initialize data with proper organization filtering
  Future<void> initializeData() async {
    await loadCurrentOrganization();
    setupSubscriptions();
  }

  /// Setup database subscriptions after organization is loaded
  void setupSubscriptions() {
    // Use organization-filtered stream if we have org ID, otherwise fallback
    if (currentOrganizationId != null) {
      usersSub = db.usersDao
          .watchUsersByOrganization(currentOrganizationId!)
          .listen((userList) {
            users = userList;
            isLoading = false;
            onStateChanged();
          });
    } else {
      // Fallback to all users (should not happen in normal operation)
      usersSub = db.usersDao.watchAllUsers().listen((userList) {
        users = userList;
        isLoading = false;
        onStateChanged();
      });
    }

    rolesSub = db.rolesDao.watchAllRoles().listen((roleList) {
      roles = roleList;
      isLoading = false;
      onStateChanged();
    });
  }

  Future<void> loadCurrentOrganization() async {
    final prefs = await SharedPreferences.getInstance();

    // Try to get from current logged-in user session via auth service
    final currentUser = AppGlobals.instance.authService.currentUser;
    if (currentUser != null) {
      // Save to local storage for offline access
      await prefs.setInt(orgIdKey, currentUser.organizationId);
      currentOrganizationId = currentUser.organizationId;
      onStateChanged();
    } else {
      // Fallback: Load from local storage (for offline mode)
      final storedOrgId = prefs.getInt(orgIdKey);
      if (storedOrgId != null) {
        currentOrganizationId = storedOrgId;
        onStateChanged();
      } else {
        print('Warning: No logged-in user found and no stored organization');
      }
    }
  }

  void dispose() {
    usersSub?.cancel();
    rolesSub?.cancel();
  }

  void applyEmployeeSort(EmployeeSort sort) {
    currentEmployeeSort = sort;
    onStateChanged();
  }

  void applyRoleSort(RoleSort sort) {
    currentRoleSort = sort;
    onStateChanged();
  }

  RolesCompanion buildRoleCompanion(
    String name,
    String description,
    List<bool> access,
  ) {
    return RolesCompanion.insert(
      name: name,
      description: Value(description.isEmpty ? null : description),
      canViewInventory: Value(access[0]),
      canAddInventory: Value(access[1]),
      canEditInventory: Value(access[2]),
      canDeleteInventory: Value(access[3]),
      canManageEmployees: Value(access[4]),
      canManageRoles: Value(access[5]),
      canViewReports: Value(access[6]),
      canAccessSettings: Value(access[7]),
    );
  }

  List<bool> flagsFromRole(Role role) {
    return [
      role.canViewInventory,
      role.canAddInventory,
      role.canEditInventory,
      role.canDeleteInventory,
      role.canManageEmployees,
      role.canManageRoles,
      role.canViewReports,
      role.canAccessSettings,
    ];
  }

  Future<void> assignRole(User user, int roleId) async {
    try {
      await db.usersDao.assignRoleToUser(user.id, roleId);
      showSnackBar('Updated ${user.username} role.');
    } on Exception catch (e) {
      showSnackBar('Failed to update role: ${e.toString()}');
    }
  }

  // Dialog methods
  void createEmployee(BuildContext context) {
    if (franchiseeRoles.isEmpty) {
      showSnackBar('Please create a role before adding employees.');
      return;
    }

    if (currentOrganizationId == null) {
      showSnackBar('Organization not found. Please try again.');
      return;
    }

    final TextEditingController employeeName = TextEditingController();
    final TextEditingController employeeEmail = TextEditingController();
    final TextEditingController employeePN = TextEditingController();
    final TextEditingController employeePassword = TextEditingController();
    int? selectedRoleId = franchiseeRoles.first.id;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          title: const Text(
            "Add Employee",
            style: TextStyle(fontFamily: fontAll, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Full Name"),
                  controller: employeeName,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(labelText: "Email"),
                  controller: employeeEmail,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Phone (Optional)",
                  ),
                  controller: employeePN,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(labelText: "Password"),
                  controller: employeePassword,
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedRoleId,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: franchiseeRoles
                      .map(
                        (role) => DropdownMenuItem<int>(
                          value: role.id,
                          child: Text(role.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedRoleId = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final dialogContext = context;
                final messenger = ScaffoldMessenger.of(dialogContext);
                final navigator = Navigator.of(dialogContext);

                final name = employeeName.text.trim();
                final email = employeeEmail.text.trim();
                final phone = employeePN.text.trim();
                final password = employeePassword.text;

                if (name.isEmpty ||
                    email.isEmpty ||
                    password.isEmpty ||
                    selectedRoleId == null) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Name, email, password, and role are required.',
                      ),
                    ),
                  );
                  return;
                }

                try {
                  // Use auth service to create employee (creates both Supabase Auth + local user)
                  final authService = AppGlobals.instance.authService;
                  final result = await authService.createEmployee(
                    email: email,
                    username: name,
                    password: password,
                    organizationId: currentOrganizationId!,
                    roleId: selectedRoleId!,
                    fullName: name,
                    phone: phone.isEmpty ? null : phone,
                  );

                  if (!navigator.mounted || !messenger.mounted) return;

                  if (result.success) {
                    navigator.pop();
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Employee added successfully.'),
                      ),
                    );
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          result.message ?? 'Failed to add employee',
                        ),
                      ),
                    );
                  }
                } on Exception catch (e) {
                  if (!messenger.mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Failed to add employee: ${e.toString()}'),
                    ),
                  );
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void createRoleDialog(BuildContext context) {
    final TextEditingController roleName = TextEditingController();
    final TextEditingController roleDescription = TextEditingController();
    List<bool> access = List.generate(accessTitles.length, (_) => false);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width > 600 ? 50 : 20,
          vertical: MediaQuery.of(context).size.height > 700 ? 60 : 40,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(25),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width > 600
                    ? 600
                    : double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add Role",
                      style: TextStyle(
                        fontFamily: fontAll,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      controller: roleName,
                      decoration: InputDecoration(
                        labelText: "Role Name",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: roleDescription,
                      decoration: InputDecoration(
                        labelText: "Description (Optional)",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "Access",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: fontAll,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: MediaQuery.of(context).size.width > 600
                          ? 50
                          : 10,
                      runSpacing: 10,
                      children: List.generate(access.length, (i) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width > 600
                              ? 160
                              : 140,
                          child: Row(
                            children: [
                              Checkbox(
                                activeColor: Colors.red,
                                value: access[i],
                                onChanged: (value) {
                                  setStateDialog(() {
                                    access[i] = value ?? false;
                                  });
                                },
                              ),
                              Flexible(
                                child: Text(
                                  accessTitles[i],
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final dialogContext = context;
              final messenger = ScaffoldMessenger.of(dialogContext);
              final navigator = Navigator.of(dialogContext);
              final name = roleName.text.trim();

              if (name.isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Role name is required.')),
                );
                return;
              }

              try {
                await db.rolesDao.insertRole(
                  buildRoleCompanion(name, roleDescription.text.trim(), access),
                );
                if (!navigator.mounted || !messenger.mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text('Role "$name" created.')),
                );
              } on Exception catch (e) {
                if (!messenger.mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to create role: ${e.toString()}'),
                  ),
                );
              }
            },
            child: const Text(
              "SUBMIT",
              style: TextStyle(
                color: Colors.white,
                fontFamily: fontAll,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void deleteEmployee(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Delete Employee",
          style: TextStyle(fontFamily: fontAll, fontWeight: FontWeight.bold),
        ),
        content: Text("Are you sure you want to remove ${user.username}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final dialogContext = context;
              final messenger = ScaffoldMessenger.of(dialogContext);
              final navigator = Navigator.of(dialogContext);
              try {
                await db.usersDao.deleteUserById(user.id);
                if (!navigator.mounted || !messenger.mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text('${user.username} removed.')),
                );
              } on Exception catch (e) {
                if (!messenger.mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete employee: ${e.toString()}'),
                  ),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void deleteRole(BuildContext context, Role role, int assignedUsers) {
    if (assignedUsers > 0) {
      showSnackBar(
        'Cannot delete "${role.name}" while $assignedUsers user(s) are assigned to it.',
      );
      return;
    }

    if (role.isSystemRole) {
      showSnackBar('System roles cannot be deleted.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Delete Role",
          style: TextStyle(fontFamily: fontAll, fontWeight: FontWeight.bold),
        ),
        content: Text("Are you sure you want to delete '${role.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final dialogContext = context;
              final messenger = ScaffoldMessenger.of(dialogContext);
              final navigator = Navigator.of(dialogContext);

              try {
                await db.rolesDao.deleteRoleById(role.id);
                if (!navigator.mounted || !messenger.mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text('Role "${role.name}" deleted.')),
                );
              } on Exception catch (e) {
                if (!messenger.mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Cannot delete "${role.name}": ${e.toString()}',
                    ),
                  ),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
