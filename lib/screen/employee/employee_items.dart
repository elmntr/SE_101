import 'package:chickenjoo_inventory/tables/tables.dart';
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import '../../../database/app_database.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import 'employee_change_item_stock.dart';
import 'package:chickenjoo_inventory/tables/sorting_and_filters.dart';

class EmployeeItemsPage extends StatefulWidget {
  final UserData userData;
  const EmployeeItemsPage({super.key, required this.userData});

  @override
  State<EmployeeItemsPage> createState() => _EmployeeItemsPageState();
}

class _EmployeeItemsPageState extends State<EmployeeItemsPage> {
  bool _isInChangeStockMode = false;
  bool _isViewingChangeDetail = false;
  StockChangeRequest? _selectedChangeRequest;

  late AppDatabase db;

  List<Item> dbItems = [];
  List<StockChangeRequest> pendingChanges = [];
  bool _isLoading = true;

  Map<int, String> categoryMap = {}; // Store category names by ID


  int categoryCount = 0;
  int selectedTab = 0; // 0 = Items, 1 = Categories

  ItemSort _currentSort = const ItemSort(ItemSortField.name, SortOrder.asc);
  ReviewSort _reviewSort = const ReviewSort(
    ReviewSortField.employee,
    SortOrder.asc,
  );

  @override
  void initState() {
    super.initState();
    db = database;
    _loadData();
  }

  void _toggleChangeStockMode() {
    setState(() {
      _isInChangeStockMode = !_isInChangeStockMode;
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load items for the user's organization
      final items = await db.itemsDao.getItemsByOrganization(
        widget.userData.organizationId,
      );

      // Load pending/draft changes for this employee
      final changes = await db.stockChangeRequestsDao.getAllChangeRequests(
        requestedBy: widget.userData.id,
      );

      if (mounted) {
        setState(() {
          dbItems = items;
          pendingChanges = changes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

  void _applyReviewSort(ReviewSort sort) {
    setState(() {
      _reviewSort = sort;

      switch (sort.field) {
        case ReviewSortField.employee:
          // All changes are from same employee, so no sort needed
          break;
        case ReviewSortField.role:
          // All changes are from same role, so no sort needed
          break;
        case ReviewSortField.changes:
          pendingChanges.sort((a, b) => b.quantity.compareTo(a.quantity));
          break;
      }

      if (sort.order == SortOrder.desc) {
        pendingChanges = pendingChanges.reversed.toList();
      }
    });
  }

  Future<void> _deleteChangeRequest(StockChangeRequest request) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Delete Change Request'),
        content: const Text(
          'Are you sure you want to delete this change request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await db.stockChangeRequestsDao.softDeleteChangeRequest(request.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Change request deleted')),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting request: $e')));
        }
      }
    }
  }

  void _viewChangeDetail(StockChangeRequest request) {
    setState(() {
      _isViewingChangeDetail = true;
      _selectedChangeRequest = request;
    });
  }

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
                      ),
                    ]
                  : [],
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Change Stock Mode
    if (_isInChangeStockMode) {
      return EmployeeChangeStockPage(
        userData: widget.userData,
        onBack: () async {
          _toggleChangeStockMode();
          await _loadData();
        },
        onRecordSaved: (_) async {
          await _loadData();
          setState(() {
            selectedTab = 1; // Switch to Review Changes tab
          });
        },
      );
    }

    // View Change Detail
    if (_isViewingChangeDetail && _selectedChangeRequest != null) {
      return Scaffold(
        backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
        appBar: AppBar(
          backgroundColor: Colors.red.shade400,
          title: const Text('Change Request Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _isViewingChangeDetail = false;
                _selectedChangeRequest = null;
              });
            },
          ),
        ),
        body: FutureBuilder<Item?>(
          future: db.itemsDao.getItemById(_selectedChangeRequest!.itemId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final item = snapshot.data;
            final request = _selectedChangeRequest!;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Item: ${item?.name ?? 'Unknown'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Change Type: ${request.changeType}'),
                      Text('Quantity: ${request.quantity}'),
                      Text('Status: ${request.status}'),
                      Text('Original Stock: ${request.originalStock}'),
                      if (request.reason != null)
                        Text('Reason: ${request.reason}'),
                      const SizedBox(height: 20),
                      if (request.status == 'draft')
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => _deleteChangeRequest(request),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
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
            );
          },
        ),
      );
    }

    // Mobile UI
    if (AppLayout.isDesktop(context) == false) {
      return Scaffold(
        backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Items',
                          style: TextStyle(fontSize: 26, fontFamily: fontAll),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            size: 28,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
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
                                value: ItemSort(
                                  ItemSortField.date,
                                  SortOrder.desc,
                                ),
                                child: Text("Date Modified (Newest)"),
                              ),
                              PopupMenuItem(
                                value: ItemSort(
                                  ItemSortField.date,
                                  SortOrder.asc,
                                ),
                                child: Text("Date Modified (Oldest)"),
                              ),
                              PopupMenuDivider(),
                              PopupMenuItem(
                                value: ItemSort(
                                  ItemSortField.name,
                                  SortOrder.desc,
                                ),
                                child: Text("Name (A–Z)"),
                              ),
                              PopupMenuItem(
                                value: ItemSort(
                                  ItemSortField.name,
                                  SortOrder.asc,
                                ),
                                child: Text("Name (Z–A)"),
                              ),
                              PopupMenuDivider(),
                              PopupMenuItem(
                                value: ItemSort(
                                  ItemSortField.stock,
                                  SortOrder.desc,
                                ),
                                child: Text("Stock (Low → High)"),
                              ),
                              PopupMenuItem(
                                value: ItemSort(
                                  ItemSortField.stock,
                                  SortOrder.asc,
                                ),
                                child: Text("Stock (High → Low)"),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildTab("Items", 0),
                      _buildTab("Review Changes", 1),
                    ],
                  ),
                ),
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
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : selectedTab == 0
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
                                )),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton:
            (selectedTab == 0 && dbItems.isNotEmpty && !_isLoading)
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }

    // Desktop UI (similar structure)
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  "Items",
                  style: TextStyle(fontSize: 30, fontFamily: fontAll),
                ),
                const SizedBox(width: 16),
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
                        value: ItemSort(ItemSortField.name, SortOrder.desc),
                        child: Text("Name (A–Z)"),
                      ),
                      PopupMenuItem(
                        value: ItemSort(ItemSortField.stock, SortOrder.desc),
                        child: Text("Stock (Low → High)"),
                      ),
                    ],
                  ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 35),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                        _buildTab("Review Changes", 1),
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
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : selectedTab == 0
                          ? (dbItems.isEmpty
                                ? emptyTables(
                                    message: "No items available",
                                    onAddPressed: null,
                                    buttonType: EmptyButtonType.none,
                                    buttonText: null,
                                  )
                                : buildUniversalTable(
                                    headers: [
                                      "Item Name",
                                      "Stock",
                                      "Sale",
                                      "Spoilage",
                                    ],
                                    rows: dbItems
                                        .map(
                                          (item) => [
                                            item.name,
                                            item.stock.toString(),
                                            item.sold.toString(),
                                            item.spoilage.toString(),
                                          ],
                                        )
                                        .toList(),
                                  ))
                          : (pendingChanges.isEmpty
                                ? emptyTables(
                                    message: "No pending changes",
                                    onAddPressed: null,
                                    buttonType: EmptyButtonType.none,
                                    buttonText: null,
                                  )
                                : FutureBuilder<List<Map<String, dynamic>>>(
                                    future: _buildChangeRequestRows(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      return buildUniversalTable(
                                        headers: [
                                          "Item",
                                          "Type",
                                          "Quantity",
                                          "Status",
                                          "Actions",
                                        ],
                                        rows: snapshot.data!
                                            .map(
                                              (row) => [
                                                row['itemName'],
                                                row['changeType'],
                                                row['quantity'],
                                                _buildStatusChip(row['status']),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.visibility,
                                                      ),
                                                      onPressed: () =>
                                                          _viewChangeDetail(
                                                            row['request'],
                                                          ),
                                                    ),
                                                    if (row['status'] ==
                                                        'draft')
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                        ),
                                                        onPressed: () =>
                                                            _deleteChangeRequest(
                                                              row['request'],
                                                            ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            )
                                            .toList(),
                                      );
                                    },
                                  )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          (selectedTab == 0 && dbItems.isNotEmpty && !_isLoading)
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<List<Map<String, dynamic>>> _buildChangeRequestRows() async {
    final rows = <Map<String, dynamic>>[];

    for (final request in pendingChanges) {
      final item = await db.itemsDao.getItemById(request.itemId);
      rows.add({
        'itemName': item?.name ?? 'Unknown',
        'changeType': request.changeType,
        'quantity': request.quantity.toString(),
        'status': request.status,
        'request': request,
      });
    }

    return rows;
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'draft':
        color = Colors.grey;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
