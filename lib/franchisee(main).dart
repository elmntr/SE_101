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

  final List<Widget> pages = const [
    ReportsPage(),
    ItemsPage(),
    InventoryPage(),
    EmployeePage(),
  ];

  void switchPage(int index) {
    setState(() {
      selectedIndex = index;
      currentPage = pages[index];
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

                sideBarButtons(Icons.bar_chart, "Reports", 0),
                const SizedBox(height: 5),
                sideBarButtons(Icons.shopping_cart, "Items", 1),
                const SizedBox(height: 5),
                sideBarButtons(Icons.inventory_2, "Inventory", 2),
                const SizedBox(height: 5),
                sideBarButtons(Icons.person_2, "Employee", 3),
              ],
            ),
          ),

          Container(width: 1, color: Colors.grey.shade300),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: currentPage,
            ),
          ),
        ],
      ),
    );
  }

  // Button for Drawer Menu Items
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
