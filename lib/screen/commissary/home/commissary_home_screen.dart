// lib/screens/home/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import 'package:chickenjoo_inventory/utils/sync_status.dart';
import 'package:chickenjoo_inventory/design_constants.dart';

// Import pages
import '../branches/branches_page.dart';
import '../reports/reports_page.dart';
import '../inventory_management/inventory_management_page.dart';
import '../requests/requests_page.dart';
import '../settings/settings_page.dart';
import '../settings/settings_edit_account.dart';

// Import separated UI files
import 'commissary_home_screen_mobile.dart';
import 'commissary_home_screen_desktop.dart';
import 'commissary_home_screen_controller.dart';
import 'widgets/dashboard_widget.dart';

class CommissaryHomeScreen extends StatefulWidget {
  final UserData signedInUser;

  const CommissaryHomeScreen({super.key, required this.signedInUser});

  @override
  State<CommissaryHomeScreen> createState() => CommissaryHomeScreenState();
}

class CommissaryHomeScreenState extends State<CommissaryHomeScreen> {
  late AppDatabase db;
  CommissaryHomeScreenController? _controller;
  StreamSubscription<UserData?>? _authSubscription;

  /// Live user data that updates when profile is edited
  late UserData currentUserData;

  CommissaryHomeScreenController get controller => _controller!;

  // Expose controller properties for UI access
  Widget? get currentPage => _controller?.currentPage;
  int get selectedIndex => _controller?.selectedIndex ?? 0;
  bool get isSideBarOpen => _controller?.isSideBarOpen ?? false;
  bool get showLabels => _controller?.showLabels ?? false;
  bool get isOnline => _controller?.isOnline ?? false;
  SyncStatus get syncStatus => _controller?.syncStatus ?? SyncStatus.idle;
  List<Map<String, dynamic>> get menuItems => _controller?.menuItems ?? [];

  @override
  void initState() {
    super.initState();
    db = database;
    currentUserData = widget.signedInUser;
    _controller = CommissaryHomeScreenController(
      db: db,
      signedInUser: widget.signedInUser,
      onStateChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
    _controller!.init();
    _loadMenuItems();

    // Listen for auth state changes (e.g. after profile edits) to refresh UI
    _authSubscription = authService.authStateChanges.listen((userData) {
      if (userData != null && mounted) {
        setState(() {
          currentUserData = userData;
        });
        _loadMenuItems();
      }
    });
  }

  void _loadMenuItems() {
    controller.menuItems = [
      {
        'icon': Icons.dashboard,
        'label': 'Dashboard',
        'page': DashboardWidget(
          username: currentUserData.username,
          onSwitchPage: switchPage,
        ),
      },
      {
        'icon': Icons.store,
        'label': 'Branches',
        'page': const BranchesPage(),
      },
      {
        'icon': Icons.inventory_2,
        'label': 'Inventory',
        'page': InventoryManagementPage(
          organizationId: currentUserData.organizationId,
          commissaryId: currentUserData.organizationId,
          organizationName: 'Inventory Management',
        ),
      },
      {
        'icon': Icons.swap_horiz,
        'label': 'Requests',
        'page': const RequestsPage(),
      },
      {
        'icon': Icons.bar_chart,
        'label': 'Reports',
        'page': const ReportsPage(),
      },
      {
        'icon': Icons.account_circle,
        'label': 'Account',
        'page': SettingsEditAccountPage(userData: currentUserData),
      },
      {
        'icon': Icons.settings,
        'label': 'Settings',
        'page': const SettingsPage(),
      },
    ];

    // Preserve current page selection when rebuilding menu
    if (controller.selectedIndex < controller.menuItems.length) {
      controller.currentPage = controller.menuItems[controller.selectedIndex]['page'];
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    controller.dispose();
    super.dispose();
  }

  void toggleSidebar() {
    controller.toggleSidebar();
  }

  void switchPage(int index, {int subTab = 0}) {
    // If navigating to Branches (index 1) with a specific sub-tab,
    // recreate the page with the correct initialTab
    if (subTab > 0 && index == 1) {
      controller.menuItems[1]['page'] = BranchesPage(initialTab: subTab);
    }
    controller.switchPage(index);
  }

  Future<void> handleLogout() async {
    final shouldLogout = await controller.confirmLogout(context);

    if (shouldLogout && mounted) {
      await controller.performLogout(context);

      // Navigate to login screen
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  Future<void> triggerManualSync() async {
    try {
      await controller.triggerManualSync();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync completed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('âŒ Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't build until controller is initialized
    if (_controller == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (AppLayout.isDesktop(context) == false) {
      return CommissaryHomeScreenMobile(state: this);
    }
    return CommissaryHomeScreenDesktop(state: this);
  }
}
