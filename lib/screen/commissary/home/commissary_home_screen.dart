// lib/screen/commissary/home/commissary_home_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import 'package:chickenjoo_inventory/services/connectivity_service.dart';
import 'package:chickenjoo_inventory/utils/sync_status.dart';
import 'package:chickenjoo_inventory/design_constants.dart';

// Import commissary pages
import 'package:chickenjoo_inventory/screen/commissary/branches/branches_page.dart';
import 'package:chickenjoo_inventory/screen/commissary/reports/reports_page.dart';
import 'package:chickenjoo_inventory/screen/commissary/inventory/inventory_page.dart';
import 'package:chickenjoo_inventory/screen/commissary/inventory_management/inventory_management_page.dart';
import 'package:chickenjoo_inventory/screen/commissary/ingredients/ingredients_page.dart';
import 'package:chickenjoo_inventory/screen/commissary/requests/requests_page.dart';
import 'package:chickenjoo_inventory/screen/commissary/settings/settings_page.dart';

// Import separated UI files
import 'commissary_home_screen_mobile.dart';
import 'commissary_home_screen_desktop.dart';

class CommissaryHomeScreen extends StatefulWidget {
  final UserData signedInUser;

  const CommissaryHomeScreen({super.key, required this.signedInUser});

  @override
  State<CommissaryHomeScreen> createState() => CommissaryHomeScreenState();
}

class CommissaryHomeScreenState extends State<CommissaryHomeScreen> {
  late AppDatabase _db;
  late ConnectivityService _connectivityService;
  
  Widget? currentPage;
  int selectedIndex = 0;
  bool isSideBarOpen = false;
  bool showLabels = false;
  bool isOnline = true;
  SyncStatus syncStatus = SyncStatus.synced;

  List<Map<String, dynamic>> menuItems = [];

  @override
  void initState() {
    super.initState();
    _db = database;
    _initConnectivity();
    _loadMenuItems();
    // Trigger a sync immediately so data is fresh on first load
    // (esp. on fresh Android installs that haven't synced yet)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      syncService.syncAll();
    });
  }

  void _initConnectivity() {
    _connectivityService = ConnectivityService();
    _connectivityService.connectionStream.listen((online) {
      if (mounted) {
        setState(() {
          isOnline = online;
          syncStatus = online ? SyncStatus.synced : SyncStatus.idle;
        });
      }
    });
  }

  void _loadMenuItems() {
    menuItems = [
      {
        'icon': Icons.dashboard,
        'label': 'Dashboard',
        'page': _buildDashboard(),
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
          organizationId: widget.signedInUser.organizationId,
          commissaryId: widget.signedInUser.organizationId,
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
        'page': CommissaryReportsPage(),
      },
      {
        'icon': Icons.settings,
        'label': 'Settings',
        'page': CommissarySettingsPage(),
      },
    ];

    currentPage = menuItems[0]['page'];
  }

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
      currentPage = menuItems[index]['page'];
      isSideBarOpen = false;
      showLabels = false;
    });
  }

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
      try {
        await authService.signOut();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('loggedInUserId');
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      } catch (e) {
        print('❌ Error during logout: $e');
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      }
    }
  }

  Future<void> triggerManualSync() async {
    setState(() {
      syncStatus = SyncStatus.syncing;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        syncStatus = isOnline ? SyncStatus.synced : SyncStatus.idle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    if (isMobile) {
      return CommissaryHomeScreenMobile(state: this);
    } else {
      return CommissaryHomeScreenDesktop(state: this);
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${widget.signedInUser.username}!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: fontAll,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Here\'s an overview of your commissary operations.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontFamily: fontAll,
            ),
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1200 ? 4 : 
                                      constraints.maxWidth > 800 ? 2 : 1;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(title: 'Active Branches', value: '0', icon: Icons.store, color: Colors.blue),
                  _buildStatCard(title: 'Total Items', value: '0', icon: Icons.inventory, color: Colors.green),
                  _buildStatCard(title: 'Pending Requests', value: '0', icon: Icons.pending_actions, color: Colors.orange),
                  _buildStatCard(title: 'Low Stock Alerts', value: '0', icon: Icons.warning, color: Colors.red),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: fontAll),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: constraints.maxWidth > 600 ? 2.5 : 1.5,
                children: [
                  _buildQuickAction(icon: Icons.add_business, label: 'Add Branch', onTap: () => switchPage(1)),
                  _buildQuickAction(icon: Icons.add_box, label: 'Add Item', onTap: () => switchPage(2)),
                  _buildQuickAction(icon: Icons.person_add, label: 'Add Branch Admin', onTap: () => switchPage(1)),
                  _buildQuickAction(icon: Icons.assessment, label: 'View Reports', onTap: () => switchPage(4)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 24),
            ),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: fontAll)),
            Text(title, style: const TextStyle(color: Colors.grey, fontFamily: fontAll)),
          ]),
        ],
      ),
    );
  }

  Widget _buildQuickAction({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFEF4848), size: 24),
            const SizedBox(height: 6),
            Flexible(
              child: Text(label, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 2,
                style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: fontAll, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
