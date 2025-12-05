import 'package:chickenjoo_inventory/screen/employee/item_change_record.dart';
import 'package:chickenjoo_inventory/screen/employee/employee_review_changes_page.dart';
import 'package:chickenjoo_inventory/screen/franchisee/franchisee_inventory.dart';
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import '../../../database/app_database.dart';
import "../../../database/database_provider.dart";
import 'package:drift/drift.dart' show Value;
import 'employee_change_item_stock.dart';
import 'package:chickenjoo_inventory/sorting/sorting_and_filters.dart';

class EmployeeItemsPage extends StatefulWidget {
  const EmployeeItemsPage({super.key});

  @override
  State<EmployeeItemsPage> createState() => _EmployeeItemsPageState();
}

class _EmployeeItemsPageState extends State<EmployeeItemsPage> {

  bool _isInChangeStockMode = false;
  bool _isViewingChangeDetail = false;
  ChangeRecord? _selectedChangeRecord;

  late AppDatabase db;

  List<Item> dbItems = [];
  List<Map<String, dynamic>> categories = [];
  List<ChangeRecord> reviewChanges = [];


  int categoryCount = 0;
  int selectedTab = 0; // 0 = Items, 1 = Categories

  ItemSort _currentSort = const ItemSort(ItemSortField.name, SortOrder.asc);
  ReviewSort _reviewSort = const ReviewSort(ReviewSortField.employee, SortOrder.asc);



  @override
  void initState() {
    super.initState();
    db = DatabaseProvider.instance;
    _loadItems();
  }

  void _toggleChangeStockMode() {
    setState(() {
      _isInChangeStockMode = !_isInChangeStockMode;
    });
  }

  // ✅ Load items from database
  Future<void> _loadItems() async {
    final items = await db.itemsDao.getAllItems();;
    setState(() {
      dbItems = items;
    });
  }

  



  // ✅ ADD ITEM POPUP (using db.insertItem)
  void _createItem() {
    final TextEditingController name = TextEditingController();
    final TextEditingController stock = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Add Item",
            style: TextStyle(fontFamily: fontAll, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                decoration: const InputDecoration(labelText: "Item Name"),
                controller: name),
            TextField(
                decoration: const InputDecoration(labelText: "Initial Stock"),
                keyboardType: TextInputType.number,
                controller: stock),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (name.text.isEmpty || stock.text.isEmpty) return;

              // ✅ Using db.insertItem from app_database.dart
              await db.itemsDao.insertItem(
                  name: name.text,
                  stock: int.tryParse(stock.text) ?? 0,
              );


              Navigator.pop(context);
              _loadItems(); // ✅ refresh UI
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
          if (tab == 0)
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.red, size: 55),
            onPressed: () {
              _createItem(); 
            },
          ),
        ],
      ),
    );
  }

  // ✅ Item Table Widget
  Widget _buildItemTable() {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isSmall = constraints.maxWidth < 800;

      Widget header(String value) {
        return SizedBox(
          width: isSmall ? 60 : 100,
          child: Text(
            value,
            maxLines: null,
            softWrap: true,
            overflow: TextOverflow.fade,
            style: const TextStyle(fontFamily: fontAll, color: Colors.red),
          ),
        );
      }

      Widget cell(String value) {
        return SizedBox(
          width: isSmall ? 80 : double.infinity,
          child: Text(
            value,
            maxLines: null,
            softWrap: true,
            overflow: TextOverflow.fade,
            style: const TextStyle(fontFamily: fontAll),
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
              dataRowMinHeight: kMinInteractiveDimension,
              dataRowMaxHeight: double.infinity,
              columns: [
                DataColumn(label: header("Item Name")),
                DataColumn(label: header("Stock")),
                DataColumn(label: header("Sale")),
                DataColumn(label: header("Spoilage")),
                DataColumn(label: header("")),
              ],
              rows: dbItems.map((item) {
                return DataRow(
                  cells: [
                    DataCell(cell(item.name)),
                    DataCell(cell(item.stock.toString())),
                    DataCell(cell(item.sold.toString())),
                    DataCell(cell(item.spoilage.toString())),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await db.itemsDao.deleteItem(item.id); // DAO call
                          _loadItems(); // refresh
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      );
    },
  );
}



  

  // ✅ Category Table Widget (Review Changes)
  Widget _buildCategoryTable() {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isSmall = constraints.maxWidth < 800;
      Widget header(String value) {
        return SizedBox(
          width: isSmall ? 40 : 80,

            child: Text(
              value,
              maxLines: null,
              softWrap: true,
              overflow: TextOverflow.fade,
              style: const TextStyle(fontFamily: fontAll, color: Colors.red),
            ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth,
          ),
          child: DataTable(
            headingRowHeight: 48,
            columnSpacing: isSmall ? 10 : 60,
            horizontalMargin: isSmall ? 12 : 24,
            dataRowMinHeight: kMinInteractiveDimension,
            dataRowMaxHeight: double.infinity,

            columns: [
              
              DataColumn(label: header("Employee Name")),
              DataColumn(label: header("Role")),
              DataColumn(label: header("Total Changes")),
              DataColumn(label: header("Status")),
              DataColumn(label: header("")),
            ],

            rows: List.generate(reviewChanges.length, (index) {
              final record = reviewChanges[index];

              Widget cell(String value) {
                return SizedBox(
                  width: isSmall ? 60 : double.infinity,

                    child: Text(
                      value,
                      maxLines: null,
                      softWrap: true,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(fontFamily: fontAll),
                    ),
                );
              }

              return DataRow(cells: [
                DataCell(cell(record.employeeName)),
                DataCell(cell(record.role)),
                DataCell(cell(record.totalChanges.toString())),
                DataCell(cell(record.status)),
                DataCell(
                  SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: ElevatedButton(
                        child: const Text("View"),
                        onPressed: () {
                          setState(() {
                            _isViewingChangeDetail = true;
                            _selectedChangeRecord = record;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ]);
            }),
          ),
        ),
      );
    },
  );
}


  // Tab Builder
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

  // MAIN BUILD
  @override
  @override
Widget build(BuildContext context) {

  // ✅ CHANGE STOCK MODE
  if (_isInChangeStockMode) {
    return EmployeeChangeStockPage(
      onBack: () async {
        _toggleChangeStockMode();
        await _loadItems();
      },
      onRecordSaved: (record) {
        setState(() {
          reviewChanges.add(record);
          selectedTab = 1;
        });
      },
    );
  }

  // ✅ VIEW CHANGE DETAIL
  if (_isViewingChangeDetail && _selectedChangeRecord != null) {
    return ReviewChangeDetailPage(
      record: _selectedChangeRecord!,
      onBack: () {
        setState(() {
          _isViewingChangeDetail = false;
          _selectedChangeRecord = null;
        });
      },
      onDelete: (rec) {
        setState(() {
          reviewChanges.remove(rec);
          _isViewingChangeDetail = false;
          _selectedChangeRecord = null;
          selectedTab = 1;
        });
      },
      onApprove: (rec) {
        setState(() {
          final idx = reviewChanges.indexOf(rec);
          if (idx != -1) reviewChanges[idx].status = 'Updated';
          try {
            InventoryPage.pendingChanges.add(rec);
          } catch (_) {}
          _isViewingChangeDetail = false;
          _selectedChangeRecord = null;
          selectedTab = 1;
        });
      },
    );
  }

  // ✅ PHONE UI
    if (AppLayout.isDesktop(context) == false) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [

              /// ✅ HEADER
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Items",
                        style: TextStyle(fontSize: 26, fontFamily: fontAll),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, size: 28),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      /// ✅ SEARCH BAR
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

                      /// ✅ ITEM SORT FILTER (MOBILE)
                      if (selectedTab == 0)
                        PopupMenuButton<ItemSort>(
                          icon: const Icon(Icons.filter_list, size: 28),
                          onSelected: null,
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
                        else (
                          PopupMenuButton<ReviewSort>(
                            icon: const Icon(Icons.filter_list, size: 28),
                            onSelected: null,
                            itemBuilder: (context) => const [

                              PopupMenuItem(value: ReviewSort(ReviewSortField.employee, SortOrder.desc), child: Text("Employee (A–Z)")),
                              PopupMenuItem(value: ReviewSort(ReviewSortField.employee, SortOrder.asc), child: Text("Employee (Z–A)")),

                              PopupMenuDivider(),

                              
                              PopupMenuItem(value: ReviewSort(ReviewSortField.role, SortOrder.desc), child: Text("Role (A–Z)")),
                              PopupMenuItem(value: ReviewSort(ReviewSortField.role, SortOrder.asc), child: Text("Role (Z–A)")),

                              PopupMenuDivider(),

                              PopupMenuItem(
                                value: ReviewSort(ReviewSortField.changes, SortOrder.desc),
                                child: Text("Change (Low → High)"),
                              ),
                              PopupMenuItem(
                                value: ReviewSort(ReviewSortField.changes, SortOrder.asc),
                                child: Text("Change (High → Low)"),
                              ),
                            ],
                          )
                          ),
                      
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// ✅ TABS
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildTab("Items", 0),
                    _buildTab("Categories", 1),
                  ],
                ),
              ),

              /// ✅ CONTENT
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: selectedTab == 0
                      ? (dbItems.isEmpty
                          ? _emptyTables("You can manage your items here.", 0)
                          : _buildItemTable())
                      : (reviewChanges.isEmpty
                          ? _emptyTables("You can add categories here.", 1)
                          : _buildCategoryTable()),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: (selectedTab == 0 && dbItems.isNotEmpty)
        ? Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: FloatingActionButton.extended(
              onPressed: _toggleChangeStockMode,
              backgroundColor: const Color(0xFFE30417),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              label: const Text(
                'Change Stock',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              icon: const Icon(
                Icons.inventory_2_outlined,
                color: Colors.white,
              ),
            ),
          )
        : null,

    floatingActionButtonLocation:
        FloatingActionButtonLocation.centerFloat,
    );
  }

  // =========================
  // ✅ DESKTOP UI
  // =========================
  return Scaffold(
    backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          /// ✅ HEADER
          Row(
            children: [
              const Text("Items",
                  style: TextStyle(fontSize: 30, fontFamily: fontAll)),
              const SizedBox(width: 16),

              /// ✅ SEARCH BAR
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

              /// ✅ ITEM SORT FILTER (DESKTOP)
              if (selectedTab == 0)
                        PopupMenuButton<ItemSort>(
                          icon: const Icon(Icons.filter_list, size: 28),
                          onSelected: null,
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
                        else (
                          PopupMenuButton<ReviewSort>(
                            icon: const Icon(Icons.filter_list, size: 28),
                            onSelected: null,
                            itemBuilder: (context) => const [

                              PopupMenuItem(value: ReviewSort(ReviewSortField.employee, SortOrder.desc), child: Text("Employee (A–Z)")),
                              PopupMenuItem(value: ReviewSort(ReviewSortField.employee, SortOrder.asc), child: Text("Employee (Z–A)")),

                              PopupMenuDivider(),

                              
                              PopupMenuItem(value: ReviewSort(ReviewSortField.role, SortOrder.desc), child: Text("Role (A–Z)")),
                              PopupMenuItem(value: ReviewSort(ReviewSortField.role, SortOrder.asc), child: Text("Role (Z–A)")),

                              PopupMenuDivider(),

                              PopupMenuItem(
                                value: ReviewSort(ReviewSortField.changes, SortOrder.desc),
                                child: Text("Change (Low → High)"),
                              ),
                              PopupMenuItem(
                                value: ReviewSort(ReviewSortField.changes, SortOrder.asc),
                                child: Text("Change (High → Low)"),
                              ),
                            ],
                          )
                    ),

              IconButton(
                icon:
                    const Icon(Icons.notifications_outlined, size: 35),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// ✅ TABS
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
                      _buildTab("Item List", 0),
                      _buildTab("Categories", 1),
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
                        ? (dbItems.isEmpty
                            ? _emptyTables(
                                "You can manage your items here.",
                                selectedTab)
                            : _buildItemTable())
                        : (reviewChanges.isEmpty
                            ? _emptyTables(
                                "You can add categories here to organize your items.",
                                selectedTab)
                            : _buildCategoryTable()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
floatingActionButton: (selectedTab == 0 && dbItems.isNotEmpty)
        ? Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: FloatingActionButton.extended(
              onPressed: _toggleChangeStockMode,
              backgroundColor: const Color(0xFFE30417),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              label: const Text(
                'Change Stock',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              icon: const Icon(
                Icons.inventory_2_outlined,
                color: Colors.white,
              ),
            ),
          )
        : null,

    floatingActionButtonLocation:
        FloatingActionButtonLocation.centerFloat,
  );
}
}