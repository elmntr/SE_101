import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/screen/employee/employee_items.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Connectivity and sync imports
import '../services/connectivity_service.dart';
import '../connection_status_indicator.dart';
import 'utils/sync_status.dart';
import 'services/supabase_auth_service.dart';

import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'screen/franchisee/franchisee_reports.dart';
import 'screen/franchisee/franchisee_inventory.dart';
import 'screen/franchisee/franchisee_items.dart';
import 'screen/franchisee/franchisee_employee.dart' hide Text;
import 'screen/employee/employee_account.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.signedInUser});

  final UserData signedInUser;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget? currentPage;
  int selectedIndex = 0;
  bool isSideBarOpen = false;
  bool showLabels = false;
  late AppDatabase _db;
  
  // ✅ ADD THESE STATE VARIABLES (NO DUPLICATES)
  SyncStatus _syncStatus = SyncStatus.synced;
  DateTime? _lastSyncTime;
  late ConnectivityService _connectivityService;
  bool _isOnline = true;

  List<Map<String, dynamic>> menuItems = [];
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    _db = database;
    _loadRoleAndMenu();
    
    // ✅ ADD CONNECTIVITY SERVICE INITIALIZATION
    _connectivityService = ConnectivityService();
    _connectivityService.connectionStream.listen((status) {
      setState(() {
        _isOnline = status;
        _syncStatus = SyncStatus.synced;
      });
    });
  }

  // ✅ ADD DISPOSE METHOD
  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
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
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontFamily: fontAll),
        ),
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
      // Sign out from Supabase Auth
      await AppGlobals.instance.authService.signOut();
      
      // Clear local session
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('loggedInUserId');

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
            // ✅ ADD CONNECTION STATUS INDICATOR
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ConnectionStatusIndicator(
                isOnline: _isOnline,
                syncStatus: _syncStatus,
              ),
            ),
            
            // ✅ PROFILE MENU WITH LOGOUT
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.account_circle,
                  color: Colors.white,
                  size: 28,
                ),
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
                        Text(
                          widget.signedInUser.username,
                          style: const TextStyle(fontFamily: fontAll),
                        ),
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
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.red,
                            fontFamily: fontAll,
                          ),
                        ),
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
                decoration: BoxDecoration(color: Colors.red.shade400),
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
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
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
                  style: TextStyle(color: Colors.red, fontFamily: fontAll),
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
          // ✅ ADD CONNECTION STATUS INDICATOR
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ConnectionStatusIndicator(
              isOnline: _isOnline,
              syncStatus: _syncStatus,
            ),
          ),
          
          // ✅ PROFILE MENU WITH LOGOUT
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PopupMenuButton<String>(
              icon: const Icon(
                Icons.account_circle,
                color: Colors.white,
                size: 28,
              ),
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
                      Text(
                        widget.signedInUser.username,
                        style: const TextStyle(fontFamily: fontAll),
                      ),
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
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: fontAll,
                        ),
                      ),
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
        decoration: active
            ? BoxDecoration(color: Colors.white.withOpacity(0.25))
            : null,
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

  // ✅ FIXED: Build menu using UserData permissions directly
  Future<void> _loadRoleAndMenu() async {
    if (!mounted) return;

    // Build menu using permissions from UserData (already loaded from Supabase)
    final menu = _buildMenuFromUserData(widget.signedInUser);

    // Update UI
    if (!mounted) return;
    setState(() {
      menuItems = menu;
      selectedIndex = 0;
      currentPage = menu.isNotEmpty
          ? menu.first["page"] as Widget
          : const SizedBox.shrink();
      _isLoadingRole = false;
    });
  }

  /// Build menu items from UserData permissions
  List<Map<String, dynamic>> _buildMenuFromUserData(UserData userData) {
    final permissions = userData.permissions;
    final List<Map<String, dynamic>> items = [];

    // Check if user has full access (all permissions)
    final hasFullAccess = permissions.canViewReports &&
        permissions.canViewInventory &&
        permissions.canAddInventory &&
        permissions.canEditInventory &&
        permissions.canDeleteInventory &&
        permissions.canManageEmployees &&
        permissions.canManageRoles &&
        permissions.canAccessSettings &&
        permissions.canExportData;

    void addItemIf(bool condition, IconData icon, String label, Widget page) {
      if (condition) {
        items.add({"icon": icon, "label": label, "page": page});
      }
    }

    // Reports
    addItemIf(
      permissions.canViewReports || hasFullAccess,
      Icons.bar_chart,
      "Reports",
      const ReportsPage(),
    );

    // Items / Inventory
    if (permissions.canViewInventory || hasFullAccess) {
      final isRestrictedEmployee = !(permissions.canAddInventory ||
          permissions.canEditInventory ||
          permissions.canDeleteInventory);
      
      // For restricted employees, show read-only items page
      if (isRestrictedEmployee && !hasFullAccess) {
        addItemIf(
          true,
          Icons.shopping_cart,
          "Items",
          EmployeeItemsPage(userData: userData),
        );
      } else {
        addItemIf(
          true,
          Icons.shopping_cart,
          "Items",
          const ItemsPage(),
        );
      }
    }

    // Inventory management page
    addItemIf(
      permissions.canAddInventory ||
          permissions.canEditInventory ||
          permissions.canDeleteInventory ||
          hasFullAccess,
      Icons.inventory_2,
      "Inventory",
      const InventoryPage(),
    );

    // Employee management page
    addItemIf(
      permissions.canManageEmployees || permissions.canManageRoles || hasFullAccess,
      Icons.person_2,
      "Employee",
      const EmployeePage(),
    );

    // Account page for all users
    addItemIf(
      true,
      Icons.account_circle,
      "Account",
      EmployeeAccountPage(userData: userData),
    );

    return items;
  }
}