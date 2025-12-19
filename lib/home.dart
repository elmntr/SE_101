import 'package:chickenjoo_inventory/database/daos/users_dao.dart';
import 'package:chickenjoo_inventory/database/daos/roles_dao.dart';
import 'package:chickenjoo_inventory/database/models/user_with_role.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/screen/employee/employee_change_item_stock.dart';
import 'package:chickenjoo_inventory/screen/employee/employee_items.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'screen/franchisee/franchisee_reports.dart';
import 'screen/franchisee/franchisee_inventory.dart';
import 'screen/franchisee/franchisee_items.dart';
import 'screen/franchisee/franchisee_employee.dart';
import 'screen/employee/employee_account.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.signedInUser});

  final User signedInUser;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget? currentPage;
  int selectedIndex = 0;
  bool isSideBarOpen = false;
  bool showLabels = false;
  late AppDatabase _db;

  List<Map<String, dynamic>> menuItems = [];
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    _db = database;
    _loadRoleAndMenu();
  }

  void toggleSidebar() {
    setState(() {
      isSideBarOpen = !isSideBarOpen;
      showLabels = false;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && isSideBarOpen) {
        setState(() => showLabels = true);
      }
    });
  }

  void switchPage(int index) {
    setState(() {
      selectedIndex = index;
      currentPage = menuItems[index]["page"] as Widget;
      isSideBarOpen = false;
      showLabels = false;
    });
  }

  /// Handles user logout with confirmation dialog
  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Logout', style: TextStyle(fontFamily: fontAll)),
        content: const Text('Are you sure you want to logout?',
            style: TextStyle(fontFamily: fontAll)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('loggedInUserId'); // or prefs.clear() if you want to clear everything

  Navigator.pushNamedAndRemoveUntil(
    context,
    '/login',
    (route) => false,
  );
}
  }

  @override
  Widget build(BuildContext context) {
    // MOBILE UI
    if (AppLayout.isDesktop(context) == false) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red.shade400,
          elevation: 3,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            // ✅ PROFILE MENU WITH LOGOUT
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle, color: Colors.white, size: 28),
                onSelected: (value) {
                  if (value == 'logout') {
                    _handleLogout();
                  } else if (value == 'profile') {
                    // Navigate to profile page
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person, size: 20),
                        const SizedBox(width: 12),
                        Text(widget.signedInUser.username,
                            style: const TextStyle(fontFamily: fontAll)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Logout',
                            style: TextStyle(
                                color: Colors.red, fontFamily: fontAll)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: currentPage ?? const SizedBox.shrink(),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(imageAll, height: 60),
                    const SizedBox(height: 10),
                    const Text(
                      "Inventory System",
                      style: TextStyle(
                        fontFamily: fontAll,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              // Menu items
              ...List.generate(menuItems.length, (index) {
                final bool isActive = selectedIndex == index;

                return ListTile(
                  leading: Icon(
                    menuItems[index]["icon"],
                    color: isActive ? Colors.red : Colors.black,
                  ),
                  title: Text(
                    menuItems[index]["label"],
                    style: TextStyle(
                      color: isActive ? Colors.red : Colors.black,
                      fontFamily: fontAll,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  tileColor: isActive ? Colors.red.withOpacity(0.08) : null,
                  selected: isActive,
                  onTap: () {
                    Navigator.pop(context);
                    switchPage(index);
                  },
                );
              }),
              // ✅ LOGOUT BUTTON IN DRAWER
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: fontAll,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  _handleLogout();
                },
              ),
            ],
          ),
        ),
      );
    }

    // DESKTOP UI
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.red.shade400,
        elevation: 3,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 35),
          onPressed: toggleSidebar,
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(imageAll, height: 30),
            const SizedBox(width: 10),
            const Text(
              "Inventory System",
              style: TextStyle(
                fontFamily: fontAll,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          // ✅ PROFILE MENU WITH LOGOUT
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.account_circle, color: Colors.white, size: 28),
              onSelected: (value) {
                if (value == 'logout') {
                  _handleLogout();
                } else if (value == 'profile') {
                  // Navigate to profile page
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 20),
                      const SizedBox(width: 12),
                      Text(widget.signedInUser.username,
                          style: const TextStyle(fontFamily: fontAll)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  enabled: false,
                  child: Text(
                    widget.signedInUser.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: fontAll,
                    ),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Logout',
                          style:
                              TextStyle(color: Colors.red, fontFamily: fontAll)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSideBarOpen ? 200 : 70,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                if (_isLoadingRole)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )
                else
                  ...List.generate(menuItems.length, (index) {
                    return Column(
                      children: [
                        sideBarButtons(
                          menuItems[index]["icon"],
                          menuItems[index]["label"],
                          index,
                        ),
                        const SizedBox(height: 5),
                      ],
                    );
                  }),
              ],
            ),
          ),
          Container(width: 1, color: Colors.grey.shade300),
          Expanded(
            child: _isLoadingRole
                ? const Center(child: CircularProgressIndicator())
                : currentPage ?? const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget sideBarButtons(IconData icon, String label, int index) {
    final bool active = selectedIndex == index;

    return InkWell(
      onTap: () => switchPage(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration:
            active ? BoxDecoration(color: Colors.white.withOpacity(0.25)) : null,
        child: Row(
          children: [
            Icon(
              icon,
              size: 25,
              color: active ? Colors.red : Colors.grey.shade900,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: showLabels
                  ? Row(
                      children: [
                        const SizedBox(width: 12),
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: fontAll,
                            fontSize: 16,
                            color: active ? Colors.red : Colors.black,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadRoleAndMenu() async {
  if (!mounted) return;

  // 1️⃣ Get the user's roleId and DAOs
  final usersDao = _db.usersDao;
  final rolesDao = _db.rolesDao;
  final userId = widget.signedInUser.id;

  // 2️⃣ Build menu for the user
  final menu = await buildMenuForUser(usersDao, rolesDao, userId);

  // 3️⃣ Update UI
  if (!mounted) return;
  setState(() {
    menuItems = menu;
    currentPage = menu.isNotEmpty ? menu.first["page"] as Widget : const SizedBox.shrink();
    _isLoadingRole = false;
  });
}


Future<List<Map<String, dynamic>>> buildMenuForUser(
  UsersDao usersDao,
  RolesDao rolesDao,
  int userId,
) async {
  // 1️⃣ Get user + role from DB
  final usersWithRoles = await usersDao.getUsersWithRoles();
  
  final userWithRole = usersWithRoles.firstWhereOrNull((u) => u.user.id == userId);

  // 2️⃣ Define default/fallback role and user
  final defaultRole = Role(
    id: 0,
    name: 'Guest',
    description: 'Default guest role',
    canViewInventory: false,
    canAddInventory: false,
    canEditInventory: false,
    canDeleteInventory: false,
    canViewReports: false,
    canExportData: false,
    canAccessSettings: false,
    canManageEmployees: false,
    canManageRoles: false,
    isSystemRole: false,
    isActive: true,
    createdAt: DateTime.now(),
    lastUpdated: DateTime.now(),
    isSynced: false
  );

 final defaultUser = User(
  id: 0,
  username: 'guest',
  fullName: 'Guest User',         // NEW field
  email: 'guest@example.com',
  password: '',
  roleId: 0,
  organizationId: 0,              // NEW field
  isActive: true,
  createdAt: DateTime.now(),
  lastUpdated: DateTime.now(),
  isSynced: false
);


  final user = userWithRole?.user ?? defaultUser;
  final role = userWithRole?.role ?? defaultRole;

  final List<Map<String, dynamic>> items = [];

  // 3️⃣ Determine if role has "full access" (like admin)
  final hasFullAccess = [
    role.canViewReports,
    role.canViewInventory,
    role.canAddInventory,
    role.canEditInventory,
    role.canDeleteInventory,
    role.canManageEmployees,
    role.canManageRoles,
    role.canAccessSettings,
    role.canExportData,
  ].every((flag) => flag == true);

  // 4️⃣ Add menu items dynamically based on access flags
  void addItemIf(bool condition, IconData icon, String label, Widget page) {
    if (condition) {
      items.add({"icon": icon, "label": label, "page": page});
    }
  }

  // Reports
  addItemIf(role.canViewReports || hasFullAccess, Icons.bar_chart, "Reports", const ReportsPage());

  // Items / Inventory
  if (role.canViewInventory || hasFullAccess) {
    // Employees with restricted inventory see EmployeeItemsPage
    final isRestrictedEmployee = !(role.canAddInventory || role.canEditInventory || role.canDeleteInventory);
    addItemIf(isRestrictedEmployee && !hasFullAccess, Icons.shopping_cart, "Items", EmployeeItemsPage(user: user, role: role));
    addItemIf(!isRestrictedEmployee || hasFullAccess, Icons.shopping_cart, "Items", const ItemsPage());
  }

  // Inventory management page
  addItemIf(role.canAddInventory || role.canEditInventory || role.canDeleteInventory || hasFullAccess,
      Icons.inventory_2, "Inventory", const InventoryPage());

  // Employee management page
  addItemIf(role.canManageEmployees || role.canManageRoles || hasFullAccess,
      Icons.person_2, "Employee", const EmployeePage());

  // Account page for all employees or full-access users
  addItemIf((role.canViewInventory) || hasFullAccess,
      Icons.account_circle, "Account", EmployeeAccountPage(user: user, role: role));

  return items;
}




}