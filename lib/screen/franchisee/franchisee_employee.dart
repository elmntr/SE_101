import 'dart:async';

import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/database/app_database.dart'; // ADDED: Access Drift tables.
import 'package:chickenjoo_inventory/database/database_provider.dart' as provider;
import 'package:chickenjoo_inventory/sorting/sorting_and_filters.dart';

import 'package:drift/drift.dart' show Value;

class EmployeePage extends StatefulWidget {
  const EmployeePage({Key? key}) : super(key: key);

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  late AppDatabase db;
  late StreamSubscription<List<User>> _usersSub;
  late StreamSubscription<List<Role>> _rolesSub;

  List<User> _users = [];
  List<Role> _roles = [];

  EmployeeSort _currentEmployeeSort = EmployeeSort(EmployeeSortField.name, SortOrder.desc);
  RoleSort _currentRoleSort = RoleSort(RoleSortField.name, SortOrder.desc);
  String? _selectedRoleFilter;

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

    List<User> get _filteredUsers {
      var list = _users.toList();

      // Apply role filter first
      if (_selectedRoleFilter != null) {
        list = list.where((user) => user.roleId == _selectedRoleFilter).toList();
      }

      // Then apply sorting
      switch (_currentEmployeeSort.field) {
        case EmployeeSortField.name:
          list.sort((a, b) => (a.username ?? '').compareTo(b.username ?? ''));
          break;
        case EmployeeSortField.email:
          list.sort((a, b) => a.email.compareTo(b.email));
          break;
        case EmployeeSortField.date:
          list.sort((a, b) => b.id.compareTo(a.id));
          break;
      }

      return list;
    }

  int selectedTab = 0; // 0 = Items, 1 = Categories

  bool _isLoading = true; // ADDED: Display spinner while data loads.

  @override
  void initState() {
    super.initState();
    db = provider.DatabaseProvider.database;

    _usersSub = db.usersDao.watchAllUsers().listen((users) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    });

    _rolesSub = db.rolesDao.watchAllRoles().listen((roles) {
      setState(() {
        _roles = roles;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _usersSub.cancel();
    _rolesSub.cancel();
    super.dispose();
  }

  //Add Employee Popup
  void _createEmployee() {
    if (_roles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a role before adding employees.')),
      );
      return;
    }

    final TextEditingController employeeName = TextEditingController();
    final TextEditingController employeeEmail = TextEditingController();
    final TextEditingController employeePN = TextEditingController();
    final TextEditingController employeePassword = TextEditingController();
    String? selectedRole = _roles.first.name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Add Employee", style: TextStyle(fontFamily: fontAll, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: "Name"), controller: employeeName),
            TextField(decoration: const InputDecoration(labelText: "Email"), controller: employeeEmail),
            TextField(decoration: const InputDecoration(labelText: "Phone"), controller: employeePN),
            TextField(
              decoration: const InputDecoration(labelText: "Password"),
              controller: employeePassword,
              obscureText: true,
            ),
            DropdownButtonFormField<String>(
              initialValue: selectedRole,
              decoration: const InputDecoration(labelText: 'Role'),
              items: _roles
                  .map((role) => DropdownMenuItem<String>(
                        value: role.name,
                        child: Text(role.name),
                      ))
                  .toList(),
              onChanged: (value) {
                selectedRole = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
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
              final role = await db.rolesDao.getRoleByName(selectedRole!);
              if (role == null) throw Exception('Role not found');

              if (name.isEmpty || email.isEmpty || password.isEmpty || selectedRole == null) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Name, email, password, and role are required.')),
                );
                return;
              }

              try {
                await db.usersDao.insertUser(
                  UsersCompanion.insert(
                    email: email,
                    username: name,
                    phone: Value(phone.isEmpty ? null : phone),
                    password: password,
                    roleId: role.id,
                  ),
                );
                if (!navigator.mounted || !messenger.mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Employee added successfully.')),
                );
              } on Exception catch (e) {
                if (!messenger.mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text('Failed to add employee: ${e.toString()}')),
                );
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _applyEmployeeSort(EmployeeSort sort) {
  setState(() {
    _currentEmployeeSort = sort;

    switch (sort.field) {
      case EmployeeSortField.name:
        _users.sort((a, b) => (a.username ?? '').compareTo(b.username ?? ''));
        break;
      case EmployeeSortField.email:
        _users.sort((a, b) => a.email.compareTo(b.email));
        break;
      case EmployeeSortField.date:
        _users.sort((a, b) => b.id.compareTo(a.id)); // assuming higher ID = newer
        break;
    }
    
      if (sort.order == SortOrder.desc) {
      _users = _users.reversed.toList();
      }
  });
}

void _applyRoleSort(RoleSort sort) {
  setState(() {
    _currentRoleSort = sort;

    switch (sort.field) {
      case RoleSortField.name:
        _roles.sort((a, b) => a.name.compareTo(b.name));
        break;
      case RoleSortField.employees:
        _roles.sort((a, b) {
          final countA = _users.where((u) => u.roleId == a.name).length;
          final countB = _users.where((u) => u.roleId == b.name).length;
          return countA.compareTo(countB);
        });
        break;
      case RoleSortField.date:
        _roles.sort((a, b) => b.id.compareTo(a.id));
        break;
    }
    
      if (sort.order == SortOrder.desc) {
      _roles = _roles.reversed.toList();
      }
  });
}

  //Add Role Popup
  void _createRoleDialog() {
    final TextEditingController roleName = TextEditingController();
    List<bool> access = List.generate(accessTitles.length, (_) => false);

    showDialog(
      context: context,
      barrierDismissible: true, // allow tapping outside to cancel
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 50, vertical: 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(25),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return SizedBox(
              width: 600,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Add Role",
                      style: TextStyle(
                        fontFamily: fontAll,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      )),
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
                  const SizedBox(height: 25),
                  const Text("Access",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: fontAll,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 50,
                    runSpacing: 10,
                    children: List.generate(access.length, (i) {
                      return SizedBox(
                        width: 160,
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
                            Flexible(child: Text(accessTitles[i])),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel button
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 14,
              ),
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
                await db.rolesDao.insertRole(_buildRoleCompanion(name, access));
                if (!navigator.mounted || !messenger.mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text('Role "$name" created.')),
                );
              } on Exception catch (e) {
                if (!messenger.mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text('Failed to create role: ${e.toString()}')),
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

  RolesCompanion _buildRoleCompanion(String name, List<bool> access) {
    return RolesCompanion.insert(
      name: name,
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

  List<bool> _flagsFromRole(Role role) {
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

  //Empty Tab Widget
  Widget _emptyTables(String message, int tab) {

    selectedTab = tab;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 15),
          if (tab == 0)
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.red, size: 55),
              onPressed: _createEmployee,
            )
          else
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.red, size: 55),
              onPressed: _createRoleDialog,
            ),
        ],
      ),
    );
  }

  // Employee Table Widget
  // Employee Table Widget – NOW 100% IDENTICAL to ItemsPage style
Widget _buildEmployeeTable() {
  if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (_filteredUsers.isEmpty) {
    return _emptyTables(
      _selectedRoleFilter == null
          ? "No employees found"
          : "No employees with role '$_selectedRoleFilter'",
      0,
    );
  }

  return LayoutBuilder(
    builder: (context, constraints) {
      final isSmall = constraints.maxWidth < 800;

      Widget header(String value) {
        return SizedBox(
          width: isSmall ? 60 : 100,
          child: Text(
            value,
            maxLines: null,
            softWrap: true,
            overflow: TextOverflow.fade,
            style: const TextStyle(fontFamily: fontAll, color: Colors.red),
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columnSpacing: isSmall ? 10 : 60,
              horizontalMargin: isSmall ? 12 : 24,
              dataRowMinHeight: kMinInteractiveDimension,
              dataRowMaxHeight: double.infinity,
              columns: [
                DataColumn(label: header("Name")),
                DataColumn(label: header("Email")),
                DataColumn(label: header("Phone")),
                DataColumn(label: header("Role")),
                DataColumn(label: const Text("")), // Delete
              ],
              rows: _filteredUsers.map((user) {

                

                Widget cell(String? value) {
                  return SizedBox(
                    width: isSmall ? 80 : double.infinity,
                    child: Text(
                      value ?? '-',
                      maxLines: null,
                      softWrap: true,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(fontFamily: fontAll),
                    ),
                  );
                }
                
                return DataRow(
                  cells: [
                    DataCell(cell(user.username)),
                    DataCell(cell(user.email)),
                    DataCell(cell(user.phone)),
                    DataCell(
                      SizedBox(
                        width: isSmall ? 100 : 180,
                        child: _roles.isEmpty
    ? const Text('No roles', style: TextStyle(color: Colors.grey))
    : DropdownButton<int>(
        isDense: true,
        isExpanded: true,
        // use roleId as value
        value: user.roleId,
        items: _roles
            .map((role) => DropdownMenuItem<int>(
                  value: role.id, // role.id is int
                  child: Text(
                    role.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        onChanged: (int? newRoleId) async {
          if (newRoleId == null) return;
          await _assignRole(user, newRoleId);
        },
      ),

                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteEmployee(user),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      );
    },
  );
}

  // Delete Employee
  void _deleteEmployee(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Delete Employee", style: TextStyle(fontFamily: fontAll, fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to remove this employee?"),
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
                  SnackBar(content: Text('Employee ${user.email} removed.')),
                );
              } on Exception catch (e) {
                if (!messenger.mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text('Failed to delete employee: ${e.toString()}')),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Role Table Widget
  // Role Table Widget
Widget _buildRoleTable() {
  if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (_roles.isEmpty) {
    return _emptyTables("No roles found", 1);
  }

  return LayoutBuilder(
    builder: (context, constraints) {
      final isSmall = constraints.maxWidth < 800;

      // Dynamic width for the Access column – scales with screen size
      final double accessColumnWidth = (constraints.maxWidth - 
          (isSmall ? 40 : 100) * 3 -   // 3 other columns (Role, Employees, delete)
          40 * 3 -                     // columnSpacing between columns
          100)                         // safety margin + delete button
          .clamp(200.0, 600.0);        // min 200, max 600 so it never gets too cramped or too wide

      Widget header(String value) {
        return SizedBox(
          width: isSmall ? 60 : 100,
          child: Text(
            value,
            maxLines: null,
            softWrap: true,
            overflow: TextOverflow.fade,
            style: const TextStyle(fontFamily: fontAll, color: Colors.red),
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columnSpacing: isSmall ? 10 : 60,
              horizontalMargin: isSmall ? 12 : 24,
              dataRowMinHeight: kMinInteractiveDimension,  // 48px minimum for accessibility
              dataRowMaxHeight: double.infinity,
              columns: [
                DataColumn(label: header("Role Name")),
                DataColumn(label: header("Access")),
                DataColumn(label: header("Employee")),
                DataColumn(label: const Text("")),
              ],
              rows: _roles.map((role) {
                

                final accessWidgets = <Widget>[];
                final accessFlags = _flagsFromRole(role);
                for (int j = 0; j < accessTitles.length; j++) {
                  if (accessFlags[j]) {
                    accessWidgets.add(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(right: 6, bottom: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(accessTitles[j], style: const TextStyle(fontSize: 12)),
                      ),
                    );
                  }
                }

                final userCount = _users.where((user) => user.roleId == role.name).length;

                Widget cell(String value) {
                    return SizedBox(
                      width: isSmall ? 80 : double.infinity,

                       child: Text(
                          value,
                          maxLines: null,                   // ✅ 2–3 lines visible
                          softWrap: true,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(fontFamily: fontAll),
                        ),
                    );
                  }

                return DataRow(
                  cells: [
                    DataCell(cell(role.name)),
                    // RESPONSIVE ACCESS COLUMN
                    DataCell(
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: accessColumnWidth),
                        child: Wrap(children: accessWidgets),
                      ),
                    ),
                    DataCell(cell(userCount.toString())),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteRole(role, userCount),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      );
    },
  );
}


  
  // Delete Role
  void _deleteRole(Role role, int assignedUsers) {
    if (assignedUsers > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot delete "${role.name}" while $assignedUsers user(s) are assigned to it.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Delete Role", style: TextStyle(fontFamily: fontAll, fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to remove this role?"),
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
              final success = await db.rolesDao.deleteRoleById(role.id);
              if (!navigator.mounted || !messenger.mounted) return;
              navigator.pop();
              if (success == 0) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Role "${role.name}" deleted.')),
                );
              } else {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Failed to delete role.')),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _assignRole(User user, int roleId) async {
  final messenger = ScaffoldMessenger.of(context);

  try {
    await db.usersDao.assignRoleToUser(user.id, roleId);
    if (!mounted || !messenger.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text('Updated ${user.email} role.')),
    );
  } on Exception catch (e) {
    if (!messenger.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text('Failed to update role: ${e.toString()}')),
    );
  }
}


// Tab Builder
  Widget _buildTab(String label, int index) {
    bool active = selectedTab == index;
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          height: 45,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.grey[300],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
      )
    );
  }

  @override
Widget build(BuildContext context) {

  // PHONE UI – identical to ItemsPage
  if (AppLayout.isDesktop(context) == false) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [

              // HEADER (stacked – title + notification)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Employees",
                        style: TextStyle(fontSize: 26, fontFamily: fontAll),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, size: 28),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // SEARCH + FILTER ROW
                  Row(
                    children: [
                      // Search Bar
                      Expanded(
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: "Search...",
                              icon: Icon(Icons.search),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Row(
              children: [
                // Role Filter Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedRoleFilter,
                      hint: const Text("All Roles", style: TextStyle(fontSize: 14)),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text("All Roles"),
                        ),
                        ..._roles.map((role) => DropdownMenuItem<String?>(
                              value: role.name,
                              child: Text(role.name),
                            )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRoleFilter = value;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Sort Menu
                PopupMenuButton<EmployeeSort>(
                  icon: const Icon(Icons.sort, size: 32, color: Colors.black87),
                  onSelected: (sort) {
                    setState(() {
                      _currentEmployeeSort = sort;
                    });
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: EmployeeSort(EmployeeSortField.date, SortOrder.desc), child: Text("Date Added (Newest)")),
                    PopupMenuItem(value: EmployeeSort(EmployeeSortField.date, SortOrder.asc), child: Text("Date Added (Oldest)")),
                    PopupMenuDivider(),
                    PopupMenuItem(value: EmployeeSort(EmployeeSortField.name, SortOrder.desc), child: Text("Name (A–Z)")),
                    PopupMenuItem(value: EmployeeSort(EmployeeSortField.name, SortOrder.asc), child: Text("Name (Z–A)")),
                    PopupMenuDivider(),
                    PopupMenuItem(value: EmployeeSort(EmployeeSortField.email, SortOrder.desc), child: Text("Email (A–Z)")),
                    PopupMenuItem(value: EmployeeSort(EmployeeSortField.email, SortOrder.asc), child: Text("Email (Z–A)")),
                  ],
                ),
              ],
            ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // TABS (Employees / Roles)
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildTab("Employees", 0),
                    _buildTab("Roles", 1),
                  ],
                ),
              ),

              // CONTENT
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : selectedTab == 0
                          ? _buildEmployeeTable()
                          : _buildRoleTable(),
                ),
              ),
            ],
          ),
        ),
      ),

      // FAB – only show when data is loaded
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.red[700],
              onPressed: selectedTab == 0 ? _createEmployee : _createRoleDialog,
              child: const Icon(Icons.add, color: Colors.white),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //  Header
            Row(
              children: [
                const Text("Employee", style: TextStyle(fontSize: 30, fontFamily: fontAll)),
                const SizedBox(width: 16),

                // Search Bar
                // Search Bar + Filter Button
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Search...",
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
              // Filter + Sort Button
            Row(
              children: [
                // Role Filter Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedRoleFilter,
                      hint: const Text("All Roles", style: TextStyle(fontSize: 14)),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text("All Roles"),
                        ),
                        ..._roles.map((role) => DropdownMenuItem<String?>(
                              value: role.name,
                              child: Text(role.name),
                            )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRoleFilter = value;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Sort Menu
                // Sort Menu
                PopupMenuButton<EmployeeSort>(
                  icon: const Icon(Icons.sort, size: 32, color: Colors.black87),
                  onSelected: (sort) {
                    setState(() {
                      _currentEmployeeSort = sort;
                    });
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: EmployeeSort(EmployeeSortField.date, SortOrder.desc), child: Text("Date Added (Newest)")),
                    PopupMenuItem(value: EmployeeSort(EmployeeSortField.date, SortOrder.asc), child: Text("Date Added (Oldest)")),
                    PopupMenuDivider(),
                    PopupMenuItem(value: EmployeeSort(EmployeeSortField.name, SortOrder.desc), child: Text("Name (A–Z)")),
                    PopupMenuItem(value: EmployeeSort(EmployeeSortField.name, SortOrder.asc), child: Text("Name (Z–A)")),
                    PopupMenuDivider(),
                    PopupMenuItem(value: EmployeeSort(EmployeeSortField.email, SortOrder.desc), child: Text("Email (A–Z)")),
                    PopupMenuItem(value: EmployeeSort(EmployeeSortField.email, SortOrder.asc), child: Text("Email (Z–A)")),
                  ],
                ),
              ],
            ),

                IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 35),
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 13),

            // Tabs + Content
            Expanded(
              child: Column(
                children: [
                  // Raised Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildTab("Employee", 0),
                        _buildTab("Roles", 1),
                      ],
                    ),
                  ),

                  // White content box
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: selectedTab == 0 
                          ? ( _isLoading ? const Center(child: CircularProgressIndicator()) : _buildEmployeeTable())
                          : ( _isLoading ? const Center(child: CircularProgressIndicator()) : _buildRoleTable() ),
              
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton:  (selectedTab == 0 && !_isLoading) || (selectedTab == 1 && !_isLoading) 
      ? Container(
          margin: const EdgeInsets.only(bottom: 20), // ✅ overlap without pushing content
          child: FloatingActionButton(
            backgroundColor: Colors.red[700],
            onPressed: selectedTab == 0 ? _createEmployee : _createRoleDialog,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        )
      : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

    );
  }

  
}