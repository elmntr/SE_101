import 'dart:async';
import 'package:chickenjoo_inventory/tables/tables.dart';
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/tables/sorting_and_filters.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:drift/drift.dart' show Value;
import 'package:shared_preferences/shared_preferences.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  late AppDatabase db;
  late StreamSubscription<List<User>> _usersSub;
  late StreamSubscription<List<Role>> _rolesSub;

  List<User> _users = [];
  List<Role> _roles = [];
  int? _currentOrganizationId; // Store current user's organization

  EmployeeSort _currentEmployeeSort = EmployeeSort(
    EmployeeSortField.name,
    SortOrder.desc,
  );
  // ignore: unused_field - Reserved for future sort UI implementation
  RoleSort _currentRoleSort = RoleSort(RoleSortField.name, SortOrder.desc);
  int? _selectedRoleFilter;
  static const int _allRolesKey = -1;

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
        list.sort((a, b) => (a.username).compareTo(b.username));
        break;
      case EmployeeSortField.email:
        list.sort((a, b) => a.email.compareTo(b.email));
        break;
      case EmployeeSortField.date:
        list.sort((a, b) => b.id.compareTo(a.id));
        break;
    }

    if (_currentEmployeeSort.order == SortOrder.desc) {
      list = list.reversed.toList();
    }

    return list;
  }

  int selectedTab = 0; // 0 = Employees, 1 = Roles
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    db = database;
    _initializeData();
  }

  /// Initialize data with proper organization filtering
  Future<void> _initializeData() async {
    await _loadCurrentOrganization();
    _setupSubscriptions();
  }

  /// Setup database subscriptions after organization is loaded
  void _setupSubscriptions() {
    // Use organization-filtered stream if we have org ID, otherwise fallback
    if (_currentOrganizationId != null) {
      _usersSub = db.usersDao.watchUsersByOrganization(_currentOrganizationId!).listen((users) {
        if (mounted) {
          setState(() {
            _users = users;
            _isLoading = false;
          });
        }
      });
    } else {
      // Fallback to all users (should not happen in normal operation)
      _usersSub = db.usersDao.watchAllUsers().listen((users) {
        if (mounted) {
          setState(() {
            _users = users;
            _isLoading = false;
          });
        }
      });
    }

    _rolesSub = db.rolesDao.watchAllRoles().listen((roles) {
      if (mounted) {
        setState(() {
          _roles = roles;
          _isLoading = false;
        });
      }
    });
  }

  static const String _orgIdKey = 'current_organization_id';

  Future<void> _loadCurrentOrganization() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Try to get from current logged-in user session via auth service
    final currentUser = AppGlobals.instance.authService.currentUser;
    if (currentUser != null) {
      // Save to local storage for offline access
      await prefs.setInt(_orgIdKey, currentUser.organizationId);
      setState(() {
        _currentOrganizationId = currentUser.organizationId;
      });
    } else {
      // Fallback: Load from local storage (for offline mode)
      final storedOrgId = prefs.getInt(_orgIdKey);
      if (storedOrgId != null) {
        setState(() {
          _currentOrganizationId = storedOrgId;
        });
      } else {
        print('Warning: No logged-in user found and no stored organization');
      }
    }
  }

  @override
  void dispose() {
    _usersSub.cancel();
    _rolesSub.cancel();
    super.dispose();
  }

  void _createEmployee() {
    if (_roles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create a role before adding employees.'),
        ),
      );
      return;
    }

    if (_currentOrganizationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Organization not found. Please try again.'),
        ),
      );
      return;
    }

    final TextEditingController employeeName = TextEditingController();
    final TextEditingController employeeEmail = TextEditingController();
    final TextEditingController employeePN = TextEditingController();
    final TextEditingController employeePassword = TextEditingController();
    int? selectedRoleId = _roles.first.id;

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
                  initialValue: selectedRoleId,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: _roles
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
                    organizationId: _currentOrganizationId!,
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
                        content: Text(result.message ?? 'Failed to add employee'),
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

  void _applyEmployeeSort(EmployeeSort sort) {
    setState(() {
      _currentEmployeeSort = sort;
    });
  }

  // ignore: unused_element - Reserved for future sort UI implementation
  void _applyRoleSort(RoleSort sort) {
    setState(() {
      _currentRoleSort = sort;

      switch (sort.field) {
        case RoleSortField.name:
          _roles.sort((a, b) => a.name.compareTo(b.name));
          break;
        case RoleSortField.employees:
          _roles.sort((a, b) {
            final countA = _users.where((u) => u.roleId == a.id).length;
            final countB = _users.where((u) => u.roleId == b.id).length;
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

  void _createRoleDialog() {
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
                  _buildRoleCompanion(
                    name,
                    roleDescription.text.trim(),
                    access,
                  ),
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

  RolesCompanion _buildRoleCompanion(
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

  void _deleteEmployee(User user) {
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

  void _deleteRole(Role role, int assignedUsers) {
    if (assignedUsers > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot delete "${role.name}" while $assignedUsers user(s) are assigned to it.',
          ),
        ),
      );
      return;
    }

    if (role.isSystemRole) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('System roles cannot be deleted.')),
      );
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

  Future<void> _assignRole(User user, int roleId) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      await db.usersDao.assignRoleToUser(user.id, roleId);
      if (!mounted || !messenger.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Updated ${user.username} role.')),
      );
    } on Exception catch (e) {
      if (!messenger.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to update role: ${e.toString()}')),
      );
    }
  }

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
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (AppLayout.isDesktop(context) == false) {
      return Scaffold(
        backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
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
                          icon: const Icon(
                            Icons.notifications_outlined,
                            size: 28,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: PopupMenuButton<int>(
                                tooltip: "Filter by role",
                                onSelected: (value) {
                                  setState(() {
                                    _selectedRoleFilter = value == _allRolesKey
                                        ? null
                                        : value;
                                  });
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem<int>(
                                    value: _allRolesKey,
                                    child: Text("All Roles"),
                                  ),
                                  const PopupMenuDivider(),
                                  ..._roles.map(
                                    (role) => PopupMenuItem<int>(
                                      value: role.id,
                                      child: Text(role.name),
                                    ),
                                  ),
                                ],
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedRoleFilter == null
                                          ? "All Roles"
                                          : _roles
                                                .firstWhere(
                                                  (r) =>
                                                      r.id ==
                                                      _selectedRoleFilter,
                                                )
                                                .name,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.filter_list, size: 20),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            PopupMenuButton<EmployeeSort>(
                              icon: const Icon(
                                Icons.sort,
                                size: 32,
                                color: Colors.black87,
                              ),
                              onSelected: _applyEmployeeSort,
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: EmployeeSort(
                                    EmployeeSortField.date,
                                    SortOrder.desc,
                                  ),
                                  child: Text("Date Added (Newest)"),
                                ),
                                PopupMenuItem(
                                  value: EmployeeSort(
                                    EmployeeSortField.date,
                                    SortOrder.asc,
                                  ),
                                  child: Text("Date Added (Oldest)"),
                                ),
                                PopupMenuDivider(),
                                PopupMenuItem(
                                  value: EmployeeSort(
                                    EmployeeSortField.name,
                                    SortOrder.desc,
                                  ),
                                  child: Text("Name (A–Z)"),
                                ),
                                PopupMenuItem(
                                  value: EmployeeSort(
                                    EmployeeSortField.name,
                                    SortOrder.asc,
                                  ),
                                  child: Text("Name (Z–A)"),
                                ),
                                PopupMenuDivider(),
                                PopupMenuItem(
                                  value: EmployeeSort(
                                    EmployeeSortField.email,
                                    SortOrder.desc,
                                  ),
                                  child: Text("Email (A–Z)"),
                                ),
                                PopupMenuItem(
                                  value: EmployeeSort(
                                    EmployeeSortField.email,
                                    SortOrder.asc,
                                  ),
                                  child: Text("Email (Z–A)"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                        ? (_filteredUsers.isEmpty
                              ? _selectedRoleFilter == null
                                    ? emptyTables(
                                        message: "No employees found",
                                        onAddPressed: _createEmployee,
                                        buttonType: EmptyButtonType.icon,
                                        buttonText: null,
                                      )
                                    : emptyTables(
                                        message:
                                            "No employees with selected role",
                                        onAddPressed: _createEmployee,
                                        buttonType: EmptyButtonType.icon,
                                        buttonText: null,
                                      )
                              : buildUniversalTable(
                                  headers: [
                                    "Name",
                                    "Email",
                                    "Phone",
                                    "Role",
                                    "",
                                  ],
                                  rows: _filteredUsers.map((user) {
                                    return [
                                      user.username,
                                      user.email,
                                      user.phone ?? '-',
                                      SizedBox(
                                        child: _roles.isEmpty
                                            ? const Text(
                                                'No roles',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              )
                                            : DropdownButton<int>(
                                                isDense: true,
                                                isExpanded: true,
                                                value: user.roleId,
                                                items: _roles
                                                    .map(
                                                      (role) =>
                                                          DropdownMenuItem<int>(
                                                            value: role.id,
                                                            child: Text(
                                                              role.name,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                    )
                                                    .toList(),
                                                onChanged:
                                                    (int? newRoleId) async {
                                                      if (newRoleId == null)
                                                        return;
                                                      await _assignRole(
                                                        user,
                                                        newRoleId,
                                                      );
                                                    },
                                              ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _deleteEmployee(user),
                                      ),
                                    ];
                                  }).toList(),
                                  
                                smallHeaderWidth: 20,
                                largeHeaderWidth: 120,
                                ))
                        : (_roles.isEmpty
                              ? emptyTables(
                                  message: "No roles found",
                                  onAddPressed: _createRoleDialog,
                                  buttonType: EmptyButtonType.icon,
                                  buttonText: null,
                                )
                              : buildUniversalTable(
                                  headers: [
                                    "Role Name",
                                    "Access",
                                    "Employees",
                                    "",
                                  ],
                                  rows: _roles.map((role) {
                                    final accessWidgets = <Widget>[];
                                    final accessFlags = _flagsFromRole(role);
                                    for (
                                      int j = 0;
                                      j < accessTitles.length;
                                      j++
                                    ) {
                                      if (accessFlags[j]) {
                                        accessWidgets.add(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 3,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              accessTitles[j],
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    }

                                    final userCount = _users
                                        .where((user) => user.roleId == role.id)
                                        .length;

                                    return [
                                      role.name,
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 200,
                                        ),
                                        child: Wrap(children: accessWidgets),
                                      ),
                                      userCount.toString(),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _deleteRole(role, userCount),
                                      ),
                                    ];
                                  }).toList(),
                                  
                                smallHeaderWidth: 20,
                                largeHeaderWidth: 120,
                                )),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton:
            (!_isLoading &&
                ((selectedTab == 0 && _filteredUsers.isNotEmpty) ||
                    (selectedTab == 1 && _roles.isNotEmpty)))
            ? Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: FloatingActionButton(
                  backgroundColor: Colors.red[700],
                  onPressed: selectedTab == 0
                      ? _createEmployee
                      : _createRoleDialog,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }

    // Desktop UI (similar structure with minor adjustments)
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  "Employee",
                  style: TextStyle(fontSize: 30, fontFamily: fontAll),
                ),
                const SizedBox(width: 16),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: PopupMenuButton<int>(
                        tooltip: "Filter by role",
                        onSelected: (value) {
                          setState(() {
                            _selectedRoleFilter = value == _allRolesKey
                                ? null
                                : value;
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem<int>(
                            value: _allRolesKey,
                            child: Text("All Roles"),
                          ),
                          const PopupMenuDivider(),
                          ..._roles.map(
                            (role) => PopupMenuItem<int>(
                              value: role.id,
                              child: Text(role.name),
                            ),
                          ),
                        ],
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedRoleFilter == null
                                  ? "All Roles"
                                  : _roles
                                        .firstWhere(
                                          (r) => r.id == _selectedRoleFilter,
                                        )
                                        .name,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.filter_list, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    PopupMenuButton<EmployeeSort>(
                      icon: const Icon(
                        Icons.sort,
                        size: 32,
                        color: Colors.black87,
                      ),
                      onSelected: _applyEmployeeSort,
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: EmployeeSort(
                            EmployeeSortField.name,
                            SortOrder.desc,
                          ),
                          child: Text("Name (A–Z)"),
                        ),
                        PopupMenuItem(
                          value: EmployeeSort(
                            EmployeeSortField.email,
                            SortOrder.desc,
                          ),
                          child: Text("Email (A–Z)"),
                        ),
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
            Expanded(
              child: Column(
                children: [
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
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : selectedTab == 0
                          ? (_filteredUsers.isEmpty
                                ? emptyTables(
                                    message: "No employees found",
                                    onAddPressed: _createEmployee,
                                    buttonType: EmptyButtonType.icon,
                                    buttonText: null,
                                  )
                                : buildUniversalTable(
                                    headers: [
                                      "Name",
                                      "Email",
                                      "Phone",
                                      "Role",
                                      "",
                                    ],
                                    rows: _filteredUsers.map((user) {
                                      return [
                                        user.username,
                                        user.email,
                                        user.phone ?? '-',
                                        SizedBox(
                                          child: _roles.isEmpty
                                              ? const Text('No roles')
                                              : DropdownButton<int>(
                                                  isDense: true,
                                                  isExpanded: true,
                                                  value: user.roleId,
                                                  items: _roles
                                                      .map(
                                                        (role) =>
                                                            DropdownMenuItem<
                                                              int
                                                            >(
                                                              value: role.id,
                                                              child: Text(
                                                                role.name,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                      )
                                                      .toList(),
                                                  onChanged:
                                                      (int? newRoleId) async {
                                                        if (newRoleId == null)
                                                          return;
                                                        await _assignRole(
                                                          user,
                                                          newRoleId,
                                                        );
                                                      },
                                                ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              _deleteEmployee(user),
                                        ),
                                      ];
                                    }).toList(),
                                    
                                smallHeaderWidth: 20,
                                largeHeaderWidth: 120,
                                  ))
                          : (_roles.isEmpty
                                ? emptyTables(
                                    message: "No roles found",
                                    onAddPressed: _createRoleDialog,
                                    buttonType: EmptyButtonType.icon,
                                    buttonText: null,
                                  )
                                : buildUniversalTable(
                                    headers: [
                                      "Role Name",
                                      "Access",
                                      "Employees",
                                      "",
                                    ],
                                    rows: _roles.map((role) {
                                      final accessWidgets = <Widget>[];
                                      final accessFlags = _flagsFromRole(role);
                                      for (
                                        int j = 0;
                                        j < accessTitles.length;
                                        j++
                                      ) {
                                        if (accessFlags[j]) {
                                          accessWidgets.add(
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 3,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                accessTitles[j],
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      }

                                      final userCount = _users
                                          .where(
                                            (user) => user.roleId == role.id,
                                          )
                                          .length;

                                      return [
                                        role.name,
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 200,
                                          ),
                                          child: Wrap(children: accessWidgets),
                                        ),
                                        userCount.toString(),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              _deleteRole(role, userCount),
                                        ),
                                      ];
                                    }).toList(),
                                    
                                smallHeaderWidth: 20,
                                largeHeaderWidth: 120,
                                  )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          (!_isLoading &&
              ((selectedTab == 0 && _filteredUsers.isNotEmpty) ||
                  (selectedTab == 1 && _roles.isNotEmpty)))
          ? Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton(
                backgroundColor: Colors.red[700],
                onPressed: selectedTab == 0
                    ? _createEmployee
                    : _createRoleDialog,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
