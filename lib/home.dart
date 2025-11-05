import 'package:chickenjoo_inventory/designconstants.dart';
import 'package:flutter/material.dart';
import 'franchisee(reports).dart';
import 'franchisee(inventory).dart';
import 'franchisee(items).dart';
import 'franchisee(employee).dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // (APURADO) Naka set na as default page yung ReportsPage pagdating sa Franchisee
  Widget currentPage = const ReportsPage(); 
  int selectedIndex = 0;
  bool isSideBarOpen = false;
  String accountType = "franchisee"; 

  late List<Map<String, dynamic>> menuItems;

  @override
  void initState() {
    super.initState();

    if (accountType == "franchisee") {
      menuItems = [
        {"icon": Icons.bar_chart, "label": "Reports", "page": const ReportsPage()},
        {"icon": Icons.shopping_cart, "label": "Items", "page": const ItemsPage()},
        {"icon": Icons.inventory_2, "label": "Inventory", "page": const InventoryPage()},
        {"icon": Icons.person_2, "label": "Employee", "page": const EmployeePage()},
      ];
    } else if (accountType == "admin") {
      menuItems = [
        {"icon": Icons.dashboard, "label": "Dashboard", "page": const ReportsPage()},
        {"icon": Icons.store, "label": "Manage Branches", "page": const ItemsPage()},
        {"icon": Icons.people, "label": "Users", "page": const EmployeePage()},
        {"icon": Icons.settings, "label": "Settings", "page": const InventoryPage()},
      ];
    }

    currentPage = menuItems[0]["page"]; // first page default
  }

  void switchPage(int index) {
    setState(() {
      selectedIndex = index;
      currentPage = menuItems[index]["page"];
      isSideBarOpen = false;
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
          onPressed: () {
            setState(() => isSideBarOpen = !isSideBarOpen);
          },
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/chicken_joo_logo.png", height: 30),
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

      body: 
      Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSideBarOpen ? 200 : 70,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                ...List.generate(menuItems.length, (index) {
                  return Column(
                    children: [
                      sideBarButtons(menuItems[index]["icon"], menuItems[index]["label"], index),
                      const SizedBox(height: 5),
                    ],
                  );
                }),
              ],
            ),
          ),

          Container(width: 1, color: Colors.grey.shade300),

          Expanded(
            child: Container(
              child: currentPage,
            ),
          ),
        ],
      ),
    );
  }

  // Button for Sidebar
  Widget sideBarButtons(IconData icon, String label, int index) {
    bool active = selectedIndex == index;

    return InkWell(
      onTap: () => switchPage(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: active
            ? BoxDecoration(color: Colors.white.withOpacity(0.25))
            : null,
        child: Row(
          children: [
            Icon(icon, size: 25,
                color: active ? Colors.red : Colors.grey.shade900),
            if (isSideBarOpen) ...[
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                    fontFamily: fontAll,
                    fontSize: 16,
                    color: active ? Colors.red : Colors.black,
                    fontWeight: active ? FontWeight.normal : FontWeight.normal),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
