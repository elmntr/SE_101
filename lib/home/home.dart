import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/screen/employee/employee_items/employee_items.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Connectivity and sync imports
import '../../services/connectivity_service.dart';
import '../../connection_status_indicator.dart';
import '../utils/sync_status.dart';
import '../services/supabase_auth_service.dart';

import 'package:chickenjoo_inventory/app_globals.dart';
import '../screen/franchisee/franchisee_reports/franchisee_reports.dart';
import '../screen/franchisee/franchisee_inventory/franchisee_inventory.dart';
import '../screen/franchisee/franchisee_items/franchisee_items.dart';
import '../screen/franchisee/franchisee_employee/franchisee_employee.dart';
import '../screen/employee/employee_account.dart';

// Import the separated UI files
import 'home_mobile.dart';
import 'home_desktop.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.signedInUser});

  final UserData signedInUser;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Widget? currentPage;
  int selectedIndex = 0;
  bool isSideBarOpen = false;
  bool showLabels = false;
  
  // Connectivity and sync state
  SyncStatus syncStatus = SyncStatus.synced;
  late ConnectivityService connectivityService;
  bool isOnline = true;

  List<Map<String, dynamic>> menuItems = [];
  bool isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    loadRoleAndMenu();
    
    // Connectivity service initialization
    connectivityService = ConnectivityService();
    connectivityService.connectionStream.listen((status) {
      setState(() {
        isOnline = status;
        syncStatus = SyncStatus.synced;
      });
    });
  }

  /// Manual sync trigger
  Future<void> triggerManualSync() async {
    if (!isOnline || syncStatus == SyncStatus.syncing) return;

    setState(() => syncStatus = SyncStatus.syncing);

    try {
      await AppGlobals.instance.syncService.syncAll();
      if (mounted) {
        setState(() => syncStatus = SyncStatus.synced);
      }
    } catch (e) {
      if (mounted) {
        setState(() => syncStatus = SyncStatus.error);
      }
    }
  }

  @override
  void dispose() {
    connectivityService.dispose();
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
  Future<void> handleLogout() async {
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
      return HomeScreenMobile(state: this);
    }

    // DESKTOP UI
    return HomeScreenDesktop(state: this);
  }

  /// Build menu using UserData permissions directly
  Future<void> loadRoleAndMenu() async {
    if (!mounted) return;

    // Build menu using permissions from UserData (already loaded from Supabase)
    final menu = buildMenuFromUserData(widget.signedInUser);

    // Update UI
    if (!mounted) return;
    setState(() {
      menuItems = menu;
      selectedIndex = 0;
      currentPage = menu.isNotEmpty
          ? menu.first["page"] as Widget
          : const SizedBox.shrink();
      isLoadingRole = false;
    });
  }

  /// Build menu items from UserData permissions
  List<Map<String, dynamic>> buildMenuFromUserData(UserData userData) {
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
    // Check if user is a restricted employee (can't add/edit/delete inventory)
    final isRestrictedEmployee = !(permissions.canAddInventory ||
        permissions.canEditInventory ||
        permissions.canDeleteInventory);

    if (permissions.canViewInventory || hasFullAccess || isRestrictedEmployee) {
      // For restricted employees (regardless of org type), show read-only items page
      if (isRestrictedEmployee && !hasFullAccess) {
        addItemIf(
          true,
          Icons.shopping_cart,
          "Items",
          EmployeeItemsPage(userData: userData),
        );
      } else if (userData.isFranchisee) {
        // For franchisees with full access, show items page
        addItemIf(
          true,
          Icons.shopping_cart,
          "Items",
          const ItemsPage(),
        );
      } else {
        // For commissary users with full access, show full items page
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