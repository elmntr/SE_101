import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/designconstants.dart';
import '../data/local/app_database.dart'; // ✅ Drift database import
import '../data/database_provider.dart';
import 'package:drift/drift.dart' show Value;

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late AppDatabase db;
  List<Item> items = [];

  int selectedTab = 0; // 0 = Item Stock, 1 = Stock Changes, 2 = Replenish Stock

  @override
  void initState() {
    super.initState();
    db = DatabaseProvider.instance;
    _loadItems();
  }

  // ✅ Fixed: properly structured and functional
  Future<void> _loadItems() async {
    final refreshed = await db.getAllItems();
    setState(() => items = refreshed);
  }

  // Empty Tab Widget
  Widget _emptyTables(String message, int tab) {
    selectedTab = tab;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 15),
          if (tab == 2)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              ),
              onPressed: () {
                print("Replenish stock button pressed");
              },
              child: const Text("Request Stock",
                  style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  // ✅ Inventory Table Widget
  Widget _buildInventoryTable() {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(
              label: Text("Item Name",
                  style: TextStyle(fontFamily: fontAll, color: Colors.red))),
          DataColumn(
              label: Text("In Stock",
                  style: TextStyle(fontFamily: fontAll, color: Colors.red))),
          DataColumn(
              label: Text("Sale",
                  style: TextStyle(fontFamily: fontAll, color: Colors.red))),
          DataColumn(
              label: Text("Spoilage",
                  style: TextStyle(fontFamily: fontAll, color: Colors.red))),
        ],
        rows: List.generate(items.length, (i) {
          final item = items[i];
          return DataRow(cells: [
            DataCell(Text(item.name)),
            DataCell(Text(item.stock.toString())),
            DataCell(Text(item.sold.toString())), // ✅ corrected field name
            DataCell(Text(item.spoilage.toString())),
          ]);
        }),
      ),
    );
  }

  // Tabs
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
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  // ✅ Build Method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Text("Items",
                    style: TextStyle(fontSize: 30, fontFamily: fontAll)),
                const SizedBox(width: 16),

                // Search Bar
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

                IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 35),
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),

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
                        _buildTab("Item Stock", 0),
                        _buildTab("Stock Changes", 1),
                        _buildTab("Replenish Stock", 2),
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
                          ? (items.isEmpty
                              ? _emptyTables("You can manage your items here.",
                                  selectedTab)
                              : _buildInventoryTable())
                          : selectedTab == 1
                              ? _emptyTables(
                                  "You can view employee stock changes and updates here.",
                                  selectedTab)
                              : _emptyTables(
                                  "You can request stock replenishment for products here.",
                                  selectedTab),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
