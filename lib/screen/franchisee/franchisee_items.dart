import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import '../../../database/app_database.dart';
import 'package:chickenjoo_inventory/tables/sorting_and_filters.dart';
import 'package:chickenjoo_inventory/tables/tables.dart';
import 'package:drift/drift.dart' show Value;
import 'package:chickenjoo_inventory/app_globals.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({Key? key}) : super(key: key);

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  late AppDatabase db;

  List<Item> dbItems = [];
  List<Map<String, dynamic>> categories = [];
  Map<int, String> categoryMap = {}; // Store category names by ID

  int categoryCount = 0;
  int selectedTab = 0; // 0 = Items, 1 = Categories

  ItemSort _currentSort = ItemSort(ItemSortField.name, SortOrder.desc);
  CategorySort _currentCategorySort = CategorySort(CategorySortField.name, SortOrder.desc);

  @override
  void initState() {
    super.initState();
    db = database;
    _loadItems();
    _loadCategories();
  }

  Future<void> _loadItems() async {
    final items = await db.itemsDao.getAllItems();
    setState(() {
      dbItems = items;
    });
  }

  Future<void> _loadCategories() async {
    final cats = await db.categoriesDao.getAllCategories();
    setState(() {
      categoryMap = {for (var cat in cats) cat.id: cat.name};
    });
  }

  // ✅ SHOW ITEM DETAILS DIALOG
  void _showItemDetails(Item item) {
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
                          Text(
                            "₱ $price", // TODO: Replace with item.price
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                categoryName, // Up
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
                              child: Text(
                                item.sold.toString(), // ✅ Using actual item.sold
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
                              child: Text(
                                item.spoilage.toString(), // ✅ Using actual item.spoilage
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
    final TextEditingController price = TextEditingController();
    int? selectedCategoryId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add Item",
                      style: TextStyle(
                        fontFamily: fontAll,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      decoration: const InputDecoration(labelText: "Item Name"),
                      controller: name,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(labelText: "Initial Stock"),
                      keyboardType: TextInputType.number,
                      controller: stock,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(labelText: "Price (Optional)"),
                      keyboardType: TextInputType.number,
                      controller: price,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: "Category (Optional)"),
                      value: selectedCategoryId,
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('No Category'),
                        ),
                        ...dbCategories.map((cat) => DropdownMenuItem<int>(
                          value: cat.id,
                          child: Text(cat.name),
                        )),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategoryId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () async {
                            final dialogContext = context;
                            final messenger = ScaffoldMessenger.of(dialogContext);
                            final navigator = Navigator.of(dialogContext);

                            if (name.text.isEmpty) {
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Item name is required')),
                              );
                              return;
                            }

                            try {
                              // Get user's organization ID
                              final currentUser = await db.usersDao.getUserById(1); // TODO: Get from session
                              final organizationId = currentUser?.organizationId ?? 1;

                              await db.itemsDao.insertItem(
                                name: name.text,
                                organizationId: organizationId,
                                stock: int.tryParse(stock.text) ?? 0,
                                categoryId: selectedCategoryId,
                                price: price.text.isNotEmpty ? double.tryParse(price.text) : null,
                              );

                              if (!navigator.mounted || !messenger.mounted) return;
                              navigator.pop();
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Item added successfully')),
                              );
                              _loadData();
                            } catch (e) {
                              if (!messenger.mounted) return;
                              messenger.showSnackBar(
                                SnackBar(content: Text('Error adding item: $e')),
                              );
                            }
                          },
                          child: const Text("Save", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Create Category Dialog
  void _createCategory() {
    final TextEditingController categoryName = TextEditingController();
    final TextEditingController description = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Add Category",
                    style: TextStyle(
                      fontFamily: fontAll,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: const InputDecoration(labelText: "Category Name"),
                    controller: categoryName,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(labelText: "Description (Optional)"),
                    controller: description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () async {
                          final dialogContext = context;
                          final messenger = ScaffoldMessenger.of(dialogContext);
                          final navigator = Navigator.of(dialogContext);

                          if (categoryName.text.isEmpty) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Category name is required')),
                            );
                            return;
                          }

                          try {
                            await db.categoriesDao.insertCategory(
                              name: categoryName.text,
                              description: description.text.isEmpty ? null : description.text,
                            );

                            if (!navigator.mounted || !messenger.mounted) return;
                            navigator.pop();
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Category added successfully')),
                            );
                            _loadData();
                          } catch (e) {
                            if (!messenger.mounted) return;
                            messenger.showSnackBar(
                              SnackBar(content: Text('Error adding category: $e')),
                            );
                          }
                        },
                        child: const Text("Save", style: TextStyle(color: Colors.white)),
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
          dbItems.sort((a, b) => a.spoilage.compareTo(b.spoilage));
          break;
      }

      if (sort.order == SortOrder.desc) {
        dbItems = dbItems.reversed.toList();
      }
    });
  }

  void _applyCategorySort(CategorySort sort) {
    setState(() {
      _currentCategorySort = sort;

      switch (sort.field) {
        case CategorySortField.date:
          dbCategories.sort((a, b) => a.lastUpdated.compareTo(b.lastUpdated));
          break;
        case CategorySortField.name:
          dbCategories.sort((a, b) => a.name.compareTo(b.name));
          break;
        case CategorySortField.items:
          // Will be handled by category with counts
          break;
      }

      if (sort.order == SortOrder.desc) {
        categories = categories.reversed.toList();
      }
    });
  }

  Future<void> _deleteItem(Item item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Delete Item"),
        content: Text("Are you sure you want to delete '${item.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await db.itemsDao.deleteItem(item.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${item.name} deleted')),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting item: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteCategory(Category category) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Delete Category"),
        content: Text("Are you sure you want to delete '${category.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await db.categoriesDao.deleteCategory(category.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${category.name} deleted')),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
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
                      )
                    ]
                  : [],
            ),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (AppLayout.isDesktop(context) == false) {
      /// ✅ PHONE UI
      return Scaffold(
        backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                /// HEADER (STACKED)
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
                            onSelected: _applyCategorySort,
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: CategorySort(CategorySortField.date, SortOrder.desc),
                                child: Text("Date Modified (Newest)"),
                              ),
                              PopupMenuItem(
                                value: CategorySort(CategorySortField.date, SortOrder.asc),
                                child: Text("Date Modified (Oldest)"),
                              ),
                              PopupMenuDivider(),
                              PopupMenuItem(
                                  value: CategorySort(CategorySortField.name, SortOrder.desc), child: Text("Category (A–Z)")),
                              PopupMenuItem(
                                  value: CategorySort(CategorySortField.name, SortOrder.asc), child: Text("Category (Z–A)")),
                              PopupMenuDivider(),
                              PopupMenuItem(
                                  value: CategorySort(CategorySortField.items, SortOrder.desc),
                                  child: Text("Items (Low → High)")),
                              PopupMenuItem(
                                  value: CategorySort(CategorySortField.items, SortOrder.asc),
                                  child: Text("Items (High → Low)")),
                            ],
                          ),
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
                      _buildTab("Items", 0),
                      _buildTab("Categories", 1),
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
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                  item.stock.toString(),
                                  item.sold.toString(),
                                  item.spoilage.toString(),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      await db.itemsDao.deleteItem(item.id);
                                      _loadItems();
                                    },
                                  ),
                                ]).toList(),
                              ))
                        : (categories.isEmpty
                            ? emptyTables(
                                message: "You can add categories here.",
                                onAddPressed: _createCategory,
                                buttonType: EmptyButtonType.icon,
                                buttonText: null)
                            : buildUniversalTable(
                                headers: ["Category Name", "Items in Category", ""],
                                rows: List.generate(categories.length, (i) {
                                  final category = categories[i];
                                  return [
                                    category["category"].toString(),
                                    category["itemNumber"].toString(),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteCategory(i),
                                    ),
                                  ];
                                }),
                              )),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton:
            (selectedTab == 0 && dbItems.isNotEmpty) ||
                    (selectedTab == 1 && categories.isNotEmpty)
                ? FloatingActionButton(
                    backgroundColor: Colors.red[700],
                    onPressed:
                        selectedTab == 0 ? _createItem : _createCategory,
                    child: const Icon(Icons.add, color: Colors.white),
                  )
                : null,
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerFloat,
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text("Items", style: TextStyle(fontSize: 30, fontFamily: fontAll)),
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
                    onSelected: _applyCategorySort,
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: CategorySort(CategorySortField.date, SortOrder.desc),
                        child: Text("Date Modified (Newest)"),
                      ),
                      PopupMenuItem(
                        value: CategorySort(CategorySortField.date, SortOrder.asc),
                        child: Text("Date Modified (Oldest)"),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                          value: CategorySort(CategorySortField.name, SortOrder.desc), child: Text("Category (A–Z)")),
                      PopupMenuItem(
                          value: CategorySort(CategorySortField.name, SortOrder.asc), child: Text("Category (Z–A)")),
                      PopupMenuDivider(),
                      PopupMenuItem(
                          value: CategorySort(CategorySortField.items, SortOrder.desc),
                          child: Text("Items (Low → High)")),
                      PopupMenuItem(
                          value: CategorySort(CategorySortField.items, SortOrder.asc),
                          child: Text("Items (High → Low)")),
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
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                    item.stock.toString(),
                                    item.sold.toString(),
                                    item.spoilage.toString(),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        await db.itemsDao.deleteItem(item.id);
                                        _loadItems();
                                      },
                                    ),
                                  ]).toList(),
                                ))
                          : (categories.isEmpty
                              ? emptyTables(
                                  message: "You can add categories here to organize your items.",
                                  onAddPressed: _createCategory,
                                  buttonType: EmptyButtonType.icon,
                                  buttonText: null)
                              : buildUniversalTable(
                                  headers: ["Category Name", "Items in Category", ""],
                                  rows: List.generate(categories.length, (i) {
                                    final category = categories[i];
                                    return [
                                      category["category"].toString(),
                                      category["itemNumber"].toString(),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteCategory(i),
                                      ),
                                    ];
                                  }),
                                )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: (selectedTab == 0 && dbItems.isNotEmpty) || (selectedTab == 1 && categories.isNotEmpty)
          ? Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton(
                backgroundColor: Colors.red[700],
                onPressed: selectedTab == 0 ? _createItem : _createCategory,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<List<Map<String, dynamic>>> _buildCategoryRows() async {
    final rows = <Map<String, dynamic>>[];
    
    for (final category in dbCategories) {
      final itemCount = await db.categoriesDao.getItemCountInCategory(category.id);
      rows.add({
        'name': category.name,
        'itemCount': itemCount,
        'category': category,
      });
    }
    
    return rows;
  }
}