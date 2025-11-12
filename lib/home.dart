import 'package:chickenjoo_inventory/designconstants.dart';
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/data/database_provider.dart'; // ADDED: Access shared database instance.
import 'package:chickenjoo_inventory/data/local/app_database.dart'; // ADDED: Access authenticated user and role rows.
import 'franchisee(reports).dart';
import 'franchisee(inventory).dart';
import 'franchisee(items).dart';
import 'franchisee(employee).dart';
import 'employee(account).dart';

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
  bool showLabels = false; // ✅ NEW
  late AppDatabase _db; // ADDED: Database reference for permission lookup.

  List<Map<String, dynamic>> menuItems = [];
  bool _isLoadingRole = true; // ADDED: Avoids rendering before permissions load.

  @override
  void initState() {
    super.initState();
    _db = DatabaseProvider.instance;
    _loadRoleAndMenu();
  }

  // ✅ Sidebar toggle with delayed label appearance
  void toggleSidebar() {
    setState(() {
      isSideBarOpen = !isSideBarOpen;
      showLabels = false; // hide immediately
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

  @override
  Widget build(BuildContext context) {
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
            const Icon(Icons.inventory_2, color: Colors.white, size: 30),
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.account_circle, color: Colors.white, size: 28),
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

  // ADDED: Loads the role then configures the sidebar menu.
  Future<void> _loadRoleAndMenu() async {
    final role = await _db.getRoleByName(widget.signedInUser.role);
    if (!mounted) return;

    final menu = _buildMenu(role);

    setState(() {
      menuItems = menu;
      currentPage = menu.first["page"] as Widget;
      _isLoadingRole = false;
    });
  }

  // ADDED: Builds navigation entries based on stored permissions.
  List<Map<String, dynamic>> _buildMenu(Role? role) {
    final List<Map<String, dynamic>> items = [];
    final bool isAdmin = role?.name == 'admin';

    if (isAdmin || (role?.canViewReports ?? false)) {
      items.add({"icon": Icons.bar_chart, "label": "Reports", "page": const ReportsPage()});
    }
    if (isAdmin || (role?.canViewInventory ?? false)) {
      items.add({"icon": Icons.shopping_cart, "label": "Items", "page": const ItemsPage()});
    }
    if (isAdmin ||
        (role?.canAddInventory ?? false) ||
        (role?.canEditInventory ?? false) ||
        (role?.canDeleteInventory ?? false)) {
      items.add({"icon": Icons.inventory_2, "label": "Inventory", "page": const InventoryPage()});
    }
    if (isAdmin || (role?.canManageEmployees ?? false) || (role?.canManageRoles ?? false)) {
      items.add({"icon": Icons.person_2, "label": "Employee", "page": const EmployeePage()});
    }

    // Account page is always available for viewing personal details.
    items.add({"icon": Icons.person, "label": "Account", "page": const EmployeeAccountPage()});

    return items.isEmpty
        ? [
            {
              "icon": Icons.person,
              "label": "Account",
              "page": const EmployeeAccountPage(),
            }
          ]
        : items;
  }
}
