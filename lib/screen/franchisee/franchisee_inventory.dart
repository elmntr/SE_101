import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/screen/employee/item_change_record.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import '../../../database/app_database.dart';
import '../../../database/database_provider.dart';
import 'package:chickenjoo_inventory/tables/sorting_and_filters.dart';

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
    db = DatabaseProvider.database;
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 800;
        Widget header(String value) {
          return SizedBox(
            width: isSmall ? 60 : 100,
              child: Text(
                value,
                maxLines: null,                   // ✅ 2–3 lines visible
                softWrap: true,
                overflow: TextOverflow.fade,
                style: const TextStyle(fontFamily: fontAll, color: Colors.red),
              ),
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: isSmall ? 10 : 60,
                    horizontalMargin: isSmall ? 12 : 24,
                    dataRowMinHeight: kMinInteractiveDimension,  // 48px minimum for accessibility
                    dataRowMaxHeight: double.infinity,
                    columns: [
                      DataColumn(
                          label: header("Item Name")),
                      DataColumn(
                          label: header("Stock")),
                      DataColumn(
                          label: Text("Sale",
                              style: TextStyle(fontFamily: fontAll, color: Colors.red))),
                      DataColumn(
                          label: Text("Spoilage",
                              style: TextStyle(fontFamily: fontAll, color: Colors.red))),
                    ],
                    rows: List.generate(items.length, (i) {
                      final item = items[i];
                      Widget cell(String value) {
                        return SizedBox(
                          width: isSmall ? 80 : double.infinity,

                          child: Text(
                              value,
                              maxLines: null,                   // ✅ 2–3 lines visible
                              softWrap: true,
                              overflow: TextOverflow.fade,
                              style: const TextStyle(fontFamily: fontAll),
                            ),
                        );
                      }

                      return DataRow(cells: [
                        DataCell(cell(item.name)),
                        DataCell(cell(item.stock.toString())),
                        DataCell(cell(item.sold.toString())), // ✅ corrected field name
                        DataCell(cell(item.spoilage.toString())),
                      ]);
                    }),
                  ),
                ),
              ),
            );
          },
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
                          ? _emptyTables(
                              "You can manage your items here.", 0)
                          : _buildInventoryTable())
                      : selectedTab == 1
                          ? (InventoryPage.pendingChanges.isEmpty
                              ? _emptyTables(
                                  "You can view employee stock updates here.", 1)
                              : SingleChildScrollView(
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text("Employee")),
                                      DataColumn(label: Text("Role")),
                                      DataColumn(label: Text("Changes")),
                                      DataColumn(label: Text("Status")),
                                    ],
                                    rows: List.generate(
                                        InventoryPage.pendingChanges.length,
                                        (index) {
                                      final record =
                                          InventoryPage.pendingChanges[index];
                                      return DataRow(cells: [
                                        DataCell(Text(record.employeeName)),
                                        DataCell(Text(record.role)),
                                        DataCell(Text(
                                            record.totalChanges.toString())),
                                        DataCell(Text(record.status)),
                                      ]);
                                    }),
                                  ),
                                ))
                          : _emptyTables(
                              "You can request stock replenishment here.", 2),
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
                            ? _emptyTables(
                                "You can manage your items here.", selectedTab)
                            : _buildInventoryTable())
                        : selectedTab == 1
                            ? (InventoryPage.pendingChanges.isEmpty
                                ? _emptyTables(
                                    "You can view employee stock changes here.",
                                    selectedTab)
                                : SingleChildScrollView(
                                    child: DataTable(
                                      columns: const [
                                        DataColumn(label: Text("Employee Name")),
                                        DataColumn(label: Text("Role")),
                                        DataColumn(label: Text("Total Changes")),
                                        DataColumn(label: Text("Status")),
                                      ],
                                      rows: List.generate(
                                          InventoryPage.pendingChanges.length,
                                          (index) {
                                        final record =
                                            InventoryPage.pendingChanges[index];
                                        return DataRow(cells: [
                                          DataCell(Text(
                                              record.employeeName)),
                                          DataCell(Text(record.role)),
                                          DataCell(Text(record.totalChanges
                                              .toString())),
                                          DataCell(Text(record.status)),
                                        ]);
                                      }),
                                    ),
                                  ))
                            : _emptyTables(
                                "You can request stock replenishment here.",
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