import 'package:chickenjoo_inventory/screen/employee/item_change_record.dart';
import 'package:chickenjoo_inventory/screen/employee/employee_review_changes_page.dart';
import 'package:chickenjoo_inventory/screen/franchisee/franchisee_inventory.dart';
import 'package:chickenjoo_inventory/tables/tables.dart';
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import '../../../database/app_database.dart'; // ✅ your Drift DB
import 'package:chickenjoo_inventory/app_globals.dart';

import 'package:drift/drift.dart' show Value;
import 'employee_change_item_stock.dart';
import 'package:chickenjoo_inventory/tables/sorting_and_filters.dart';

class EmployeeItemsPage extends StatefulWidget {
  final User user;
  final Role role;
  const EmployeeItemsPage({super.key, required this.user, required this.role});
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

  Map<int, String> categoryMap = {}; // Store category names by ID


  int categoryCount = 0;
  int selectedTab = 0; // 0 = Items, 1 = Categories

  ItemSort _currentSort = const ItemSort(ItemSortField.name, SortOrder.asc);
  ReviewSort _reviewSort = const ReviewSort(ReviewSortField.employee, SortOrder.asc);



  @override
  void initState() {
    super.initState();
    db = database;
    _loadItems();
  }

  void _toggleChangeStockMode() {
    setState(() {
      _isInChangeStockMode = !_isInChangeStockMode;
    });
  }

  Future<void> _loadItems() async {
    final items = await db.itemsDao.getAllItems();
    setState(() {
      dbItems = items;
    });
  }

  void _applyItemSort(ItemSort sort) {
  setState(() {
    _currentSort = sort;

    switch (sort.field) {
      case ItemSortField.date:
        dbItems.sort((a, b) => a.lastUpdated.compareTo(b.lastUpdated));
        break;

      case ItemSortField.name:
        dbItems.sort((a, b) => a.name.compareTo(b.name));
        break;

      case ItemSortField.stock:
        dbItems.sort((a, b) => a.stock.compareTo(b.stock));
        break;

      case ItemSortField.sale:
        dbItems.sort((a, b) => a.sold.compareTo(b.sold));
        break;

      case ItemSortField.spoilage:
        dbItems.sort((a, b) => b.spoilage.compareTo(a.spoilage));
        break;
    }

    if (sort.order == SortOrder.desc) {
      dbItems = dbItems.reversed.toList();
    }

  });
}

void _applyReviewSort(ReviewSort sort) {
  setState(() {
    _reviewSort = sort;

    switch (sort.field) {
      case ReviewSortField.employee:
        reviewChanges.sort((a, b) => a.employeeName.compareTo(b.employeeName));
        break;
      case ReviewSortField.role:
        reviewChanges.sort((a, b) => a.role.compareTo(b.role));
        break;

      case ReviewSortField.changes:
        reviewChanges.sort((a, b) => b.totalChanges.compareTo(a.totalChanges));
        break;
    }
    
    if (sort.order == SortOrder.desc) {
      reviewChanges = reviewChanges.reversed.toList();
    }

  });
}

// ✅ SHOW ITEM DETAILS DIALOG
  void _showItemDetails(Item item) {
    final TextEditingController priceController = TextEditingController(text: "100");
    final TextEditingController soldController = TextEditingController(text: item.sold.toString());
    final TextEditingController spoilageController = TextEditingController(text: item.spoilage.toString());
    int? selectedCategoryId = item.categoryId;
    // ✅ Get category name from categoryMap using item.categoryId
    final categoryName = item.categoryId != null 
        ? (categoryMap[item.categoryId] ?? "Uncategorized")
        : "Uncategorized";
    // TODO: Replace hardcoded values with actual item getters once database schema is updated
    final price = 100; // TODO: Use item.price once added to database
    final status = "Healthy"; // TODO: Use item.status once added to database
    final sku = "ABC-123"; // TODO: Use item.sku once added to database
    // ✅ Format lastUpdated as date
    final dateOrdered = "${item.lastUpdated.month}/${item.lastUpdated.day}/${item.lastUpdated.year}";


    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with item name and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontFamily: fontAll,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            "Price: ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextField(
                            controller: priceController, // TODO: Replace with item.price
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),

                  // Row 1: Category and Status
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Category:",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonFormField<int>(
                                value: selectedCategoryId,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text("Uncategorized")
                                  ),
                                  ...categoryMap.entries.map((entry) => DropdownMenuItem<int>(
                                    value: entry.key,
                                    child: Text(entry.value),
                                  )),
                                ],
                                onChanged: (value) {
                                  selectedCategoryId = value;
                                },
                              )
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Status:",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status, // TODO: Replace with item.status
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Row 2: SKU and Amount Sold
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "SKU:",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                sku, // TODO: Replace with item.sku
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Amount Sold:",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: soldController, // ✅ Using actual item.sold
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Row 3: Date Ordered and Amount Spoiled
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Date Ordered:",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                dateOrdered, // Up
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Amount Spoiled:",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: spoilageController, // ✅ Using actual item.spoilage
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "CANCEL",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Add edit functionality
                        },
                        child: const Text("SAVE ITEM DETAILS"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ ADD ITEM POPUP (connected to DB)
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
      user: widget.user,            // ✅ ADDED
      role: widget.role, 

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
                        else (
                          PopupMenuButton<ReviewSort>(
                            icon: const Icon(Icons.filter_list, size: 28),
                            onSelected: _applyReviewSort,
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
                        ? emptyTables(
                            message: "You can manage your items here.",
                            onAddPressed: _createItem,
                            buttonType: EmptyButtonType.icon,
                            buttonText: null)
                        : buildUniversalTable(
                            headers: ["Item Name", "Stock", "Sale", "Spoilage", ""],
                            rows: dbItems.map((item) => [
                              GestureDetector(
                                onTap: () => _showItemDetails(item),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Text(
                                    item.name.toString(),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showItemDetails(item),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Text(
                                    item.stock.toString(),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showItemDetails(item),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Text(
                                    item.sold.toString(),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showItemDetails(item),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Text(
                                    item.spoilage.toString(),
                                  ),
                                ),
                              ),
                              
                              
                              
                              
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await db.itemsDao.deleteItem(item.id);
                                  _loadItems();
                                },
                              ),
                            ]).toList(),
                          ))
                      : (reviewChanges.isEmpty
                            ? emptyTables(
                                message: "You can view employee stock changes here.",
                                onAddPressed: null,
                                buttonType: EmptyButtonType.none,
                                buttonText: null)
                            : buildUniversalTable(
                                headers: ["Employee", "Role", "Changes", "Status", ""],
                                rows: List.generate(reviewChanges.length, (i) {
                                  final record = reviewChanges[i];
                                  return [
                                    record.employeeName.toString(),
                                    record.role.toString(),
                                    record.totalChanges.toString(),
                                    record.status,
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
                                  ];
                                }),
                              ))
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
                        else (
                          PopupMenuButton<ReviewSort>(
                            icon: const Icon(Icons.filter_list, size: 28),
                            onSelected: _applyReviewSort,
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
                          ? emptyTables(
                              message: "You can manage your items here.",
                              onAddPressed: _createItem,
                              buttonType: EmptyButtonType.icon,
                              buttonText: null)
                          : buildUniversalTable(
                              headers: ["Item Name", "Stock", "Sale", "Spoilage", ""],
                              rows: dbItems.map((item) => [
                                GestureDetector(
                                  onTap: () => _showItemDetails(item),
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Text(
                                      item.name.toString(),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _showItemDetails(item),
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Text(
                                      item.stock.toString(),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _showItemDetails(item),
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Text(
                                      item.sold.toString(),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _showItemDetails(item),
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Text(
                                      item.spoilage.toString(),
                                    ),
                                  ),
                                ),
                                
                                
                                
                                
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await db.itemsDao.deleteItem(item.id);
                                    _loadItems();
                                  },
                                ),
                              ]).toList(),
                            ))
                        : (reviewChanges.isEmpty
                            ? emptyTables(
                                    message: "You can view employee stock changes here.",
                                    onAddPressed: null,
                                    buttonType: EmptyButtonType.none,
                                    buttonText: null)
                                : buildUniversalTable(
                                  headers: ["Employee", "Role", "Changes", "Status", ""],
                                  rows: List.generate(reviewChanges.length, (i) {
                                    final record = reviewChanges[i];
                                    return [
                                      record.employeeName.toString(),
                                      record.role.toString(),
                                      record.totalChanges.toString(),
                                      record.status,
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
                                    ];
                                  }),
                              ))
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