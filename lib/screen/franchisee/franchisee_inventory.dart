import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/screen/employee/item_change_record.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import '../../../database/app_database.dart';
//import '../../../database/database_provider.dart';
import 'package:chickenjoo_inventory/tables/sorting_and_filters.dart';
import 'package:chickenjoo_inventory/tables/tables.dart';
import 'package:chickenjoo_inventory/app_globals.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  // Received updates from employees awaiting franchisee action
  static List<ChangeRecord> pendingChanges = [];

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late AppDatabase db;
  List<Item> items = [];

  int selectedTab = 0; // 0 = Item Stock, 1 = Stock Changes, 2 = Replenish Stock

  ItemSort _currentSort = ItemSort(ItemSortField.name, SortOrder.desc);

  @override
  void initState() {
    super.initState();
    db = database;
    _loadItems();
  }

  // ✅ Fixed: properly structured and functional
  Future<void> _loadItems() async {
  final refreshed = await db.itemsDao.getAllItems();
  print('📊 Loaded ${refreshed.length} items');
  
  // ✅ Check if items have valid IDs
  for (var item in refreshed) {
    print('  - ${item.name}: id=${item.id}, stock=${item.stock}');
  }
  
  setState(() => items = refreshed);
}

  void _applyItemSort(ItemSort sort) {
    setState(() {
      _currentSort = sort;

      switch (sort.field) {
        case ItemSortField.date:
          items.sort((a, b) => a.lastUpdated.compareTo(b.lastUpdated));
          break;
        case ItemSortField.name:
          items.sort((a, b) => a.name.compareTo(b.name));
          break;
        case ItemSortField.stock:
          items.sort((a, b) => a.stock.compareTo(b.stock));
          break;
        case ItemSortField.sale:
          items.sort((a, b) => a.sold.compareTo(b.sold));
          break;
        case ItemSortField.spoilage:
          items.sort((a, b) => a.spoilage.compareTo(b.spoilage));
          break;
      }

      if (sort.order == SortOrder.desc) {
      items = items.reversed.toList();
    }
    });
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

  // ✅ =============== PHONE UI =================
  if (AppLayout.isDesktop(context) == false) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [

              /// HEADER (TITLE + NOTIFICATIONS)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Inventory",
                    style: TextStyle(fontSize: 26, fontFamily: fontAll),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.notifications_outlined, size: 28),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// SEARCH BAR (BELOW TITLE)
                                Row(
                    children: [
                      /// SEARCH BAR
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

                      if (selectedTab == 0)
                        PopupMenuButton<ItemSort>(
                          icon: const Icon(Icons.filter_list, size: 28),
                          onSelected: _applyItemSort,
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: ItemSort(ItemSortField.date, SortOrder.desc),
                              child: Text("Date Modified (Newest)"),
                            ),
                            PopupMenuItem(
                              value: ItemSort(ItemSortField.date, SortOrder.asc),
                              child: Text("Date Modified (Oldest)"),
                            ),

                            PopupMenuDivider(),

                            PopupMenuItem(
                                value: ItemSort(ItemSortField.name, SortOrder.desc), child: Text("Name (A–Z)")),
                            PopupMenuItem(
                                value: ItemSort(ItemSortField.name, SortOrder.asc), child: Text("Name (Z–A)")),

                            PopupMenuDivider(),

                            PopupMenuItem(
                                value: ItemSort(ItemSortField.stock, SortOrder.desc),
                                child: Text("Stock (Low → High)")),
                            PopupMenuItem(
                                value: ItemSort(ItemSortField.stock, SortOrder.asc),
                                child: Text("Stock (High → Low)")),

                            PopupMenuDivider(),

                            PopupMenuItem(
                                value: ItemSort(ItemSortField.sale, SortOrder.desc),
                                child: Text("Sale (Low → High)")),
                            PopupMenuItem(
                                value: ItemSort(ItemSortField.sale, SortOrder.asc),
                                child: Text("Sale (High → Low)")),

                            PopupMenuDivider(),

                            PopupMenuItem(
                                value: ItemSort(ItemSortField.spoilage, SortOrder.desc),
                                child: Text("Spoilage (Low → High)")),
                            PopupMenuItem(
                                value: ItemSort(ItemSortField.spoilage, SortOrder.asc),
                                child: Text("Spoilage (High → Low)")),
                          ],
                        )
                      else
                        PopupMenuButton<CategorySort>(
                          icon: const Icon(Icons.filter_list, size: 28),
                          itemBuilder: (context) => const [
                            
                          ],
                        ),
                    ],
                  ),

              const SizedBox(height: 16),

              /// TABS
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildTab("Stock", 0),
                    _buildTab("Changes", 1),
                    _buildTab("Replenish", 2),
                  ],
                ),
              ),


              /// CONTENT
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),

                  child: selectedTab == 0
                      ? (items.isEmpty
                            ? emptyTables(
                                message: "You can manage your items here.",
                                onAddPressed: null,
                                buttonType: EmptyButtonType.none,
                                buttonText: null)
                            : buildUniversalTable(
                                  headers: ["Item Name", "Stock", "Sale", "Spoilage",],
                                  rows: items.map((item) => [
                                    item.name.toString(),
                                    item.stock.toString(),
                                    item.sold.toString(),
                                    item.spoilage.toString(),
                                  ]).toList(),
                                ))
                        : selectedTab == 1
                            ? (InventoryPage.pendingChanges.isEmpty
                                ? emptyTables(
                                    message: "You can view employee stock changes here.",
                                    onAddPressed: null,
                                    buttonType: EmptyButtonType.none,
                                    buttonText: null)
                                : buildUniversalTable(
                                  headers: ["Employee", "Role", "Changes", "Status"],
                                  rows: List.generate(InventoryPage.pendingChanges.length, (i) {
                                    final record = InventoryPage.pendingChanges[i];
                                    return [
                                      record.employeeName.toString(),
                                      record.role.toString(),
                                      record.totalChanges.toString(),
                                      record.status,
                                    ];
                                  }),
                                ))
                            : emptyTables(
                                message: "You can request stock replenishment here.",
                                onAddPressed: () { print("✅ Request Stock pressed");},
                                buttonType: EmptyButtonType.elevated,
                                buttonText: "Request Stock"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ =============== DESKTOP UI (UNCHANGED) =================
  return Scaffold(
    backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              const Text("Inventory",
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

              if (selectedTab == 0)
                        PopupMenuButton<ItemSort>(
                          icon: const Icon(Icons.filter_list, size: 28),
                          onSelected: _applyItemSort,
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: ItemSort(ItemSortField.date, SortOrder.desc),
                              child: Text("Date Modified (Newest)"),
                            ),
                            PopupMenuItem(
                              value: ItemSort(ItemSortField.date, SortOrder.asc),
                              child: Text("Date Modified (Oldest)"),
                            ),

                            PopupMenuDivider(),

                            PopupMenuItem(
                                value: ItemSort(ItemSortField.name, SortOrder.desc), child: Text("Name (A–Z)")),
                            PopupMenuItem(
                                value: ItemSort(ItemSortField.name, SortOrder.asc), child: Text("Name (Z–A)")),

                            PopupMenuDivider(),

                            PopupMenuItem(
                                value: ItemSort(ItemSortField.stock, SortOrder.desc),
                                child: Text("Stock (Low → High)")),
                            PopupMenuItem(
                                value: ItemSort(ItemSortField.stock, SortOrder.asc),
                                child: Text("Stock (High → Low)")),

                            PopupMenuDivider(),

                            PopupMenuItem(
                                value: ItemSort(ItemSortField.sale, SortOrder.desc),
                                child: Text("Sale (Low → High)")),
                            PopupMenuItem(
                                value: ItemSort(ItemSortField.sale, SortOrder.asc),
                                child: Text("Sale (High → Low)")),

                            PopupMenuDivider(),

                            PopupMenuItem(
                                value: ItemSort(ItemSortField.spoilage, SortOrder.desc),
                                child: Text("Spoilage (Low → High)")),
                            PopupMenuItem(
                                value: ItemSort(ItemSortField.spoilage, SortOrder.asc),
                                child: Text("Spoilage (High → Low)")),
                          ],
                        )
                      else
                        PopupMenuButton<CategorySort>(
                          icon: const Icon(Icons.filter_list, size: 28),
                          itemBuilder: (context) => const [
                            
                          ],
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
                            ? emptyTables(
                                message: "You can manage your items here.",
                                onAddPressed: null,
                                buttonType: EmptyButtonType.none,
                                buttonText: null)
                            : buildUniversalTable(
                                  headers: ["Item Name", "Stock", "Sale", "Spoilage",],
                                  rows: items.map((item) => [
                                    item.name.toString(),
                                    item.stock.toString(),
                                    item.sold.toString(),
                                    item.spoilage.toString(),
                                  ]).toList(),
                                ))
                        : selectedTab == 1
                            ? (InventoryPage.pendingChanges.isEmpty
                                ? emptyTables(
                                    message: "You can view employee stock changes here.",
                                    onAddPressed: null,
                                    buttonType: EmptyButtonType.none,
                                    buttonText: null)
                                : buildUniversalTable(
                                  headers: ["Employee", "Role", "Changes", "Status"],
                                  rows: List.generate(InventoryPage.pendingChanges.length, (i) {
                                    final record = InventoryPage.pendingChanges[i];
                                    return [
                                      record.employeeName.toString(),
                                      record.role.toString(),
                                      record.totalChanges.toString(),
                                      record.status,
                                    ];
                                  }),
                                  ))
                            : emptyTables(
                                message: "You can request stock replenishment here.",
                                onAddPressed: () { print("✅ Request Stock pressed");},
                                buttonType: EmptyButtonType.elevated,
                                buttonText: "Request Stock"),
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