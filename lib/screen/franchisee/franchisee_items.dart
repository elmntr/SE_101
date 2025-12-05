import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import '../../../database/app_database.dart';
import "../../../database/database_provider.dart";
import 'package:chickenjoo_inventory/sorting/sorting_and_filters.dart';
import 'package:drift/drift.dart' show Value;

class ItemsPage extends StatefulWidget {
  const ItemsPage({Key? key}) : super(key: key);

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  late AppDatabase db;

  List<Item> dbItems = [];
  List<Map<String, dynamic>> categories = [];

  int categoryCount = 0;
  int selectedTab = 0; // 0 = Items, 1 = Categories

  ItemSort _currentSort = ItemSort(ItemSortField.name, SortOrder.desc);
  CategorySort _currentCategorySort = CategorySort(CategorySortField.name, SortOrder.desc);

  @override
  void initState() {
    super.initState();
    db = DatabaseProvider.instance;
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await db.itemsDao.getAllItems();
    setState(() {
      dbItems = items;
    });
  }

  // Add Item Dialog
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
                  stock: int.tryParse(stock.text) ?? 0
              );

              Navigator.pop(context);
              _loadItems();
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Add Category Dialog
  void _createCategory() {
    final TextEditingController category = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Add Category",
            style: TextStyle(fontFamily: fontAll, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                decoration: const InputDecoration(labelText: "Category"),
                controller: category),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (category.text.isEmpty) return;
              _saveCategory({
                "category": category.text,
                "itemNumber": categoryCount,
              });
              Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _saveCategory(Map<String, dynamic> newItem) {
    setState(() {
      categories.add(newItem);
    });
  }

  void _applyItemSort(ItemSort sort) {
    setState(() {
      _currentSort = sort;

      int safeCompareInt(int a, int b) => a.compareTo(b);

      switch (sort.field) {
        case ItemSortField.date:
          dbItems.sort((a, b) => a.lastUpdated.compareTo(b.lastUpdated));
          break;
        case ItemSortField.name:
          dbItems.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
          break;
        case ItemSortField.stock:
          dbItems.sort((a, b) => safeCompareInt(a.stock, b.stock));
          break;
        case ItemSortField.sale:
          dbItems.sort((a, b) => safeCompareInt(a.sold, b.sold));
          break;
        case ItemSortField.spoilage:
          dbItems.sort((a, b) => safeCompareInt(a.spoilage, b.spoilage));
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
          categories.sort((a, b) => a["modifiedAt"].compareTo(b["modifiedAt"]));
          break;
        case CategorySortField.name:
          categories.sort((a, b) =>
              a["category"].toString().compareTo(b["category"].toString()));
          break;
        case CategorySortField.items:
          categories.sort((a, b) => a["itemNumber"].compareTo(b["itemNumber"]));
          break;
      }

      if (sort.order == SortOrder.desc) {
        categories = categories.reversed.toList();
      }
    });
  }

  Widget _emptyTables(String message, int tab) {
    selectedTab = tab;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 15),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.red, size: 55),
            onPressed: () {
              if (tab == 1) {
                _createCategory();
              } else {
                _createItem();
              }
            },
          ),
        ],
      ),
    );
  }

  // Fixed Item Table
  Widget _buildItemTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Item Name')),
              DataColumn(label: Text('Stock')),
              DataColumn(label: Text('Sale')),
              DataColumn(label: Text('Spoilage')),
              DataColumn(label: Text('')),
            ],
            rows: dbItems.map((item) {
              return DataRow(cells: [
                DataCell(Text(item.name ?? '')),
                DataCell(Text(item.stock.toString())),
                DataCell(Text(item.sold.toString())),
                DataCell(Text(item.spoilage.toString())),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await db.itemsDao.softDeleteItem(item.id);
                      _loadItems();
                    },
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Fixed Category Table
  Widget _buildCategoryTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Category Name')),
              DataColumn(label: Text('Items in Category')),
              DataColumn(label: Text('')),
            ],
            rows: List.generate(categories.length, (i) {
              final category = categories[i];
              return DataRow(cells: [
                DataCell(Text(category["category"] ?? '')),
                DataCell(Text(category["itemNumber"].toString())),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCategory(i),
                  ),
                ),
              ]);
            }),
          ),
        ),
      ),
    );
  }

  void _deleteCategory(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Delete Category", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to delete this category?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                categories.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              boxShadow: active
                  ? [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4, offset: const Offset(0, 2))]
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
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Items", style: TextStyle(fontSize: 26, fontFamily: fontAll)),
                  IconButton(icon: const Icon(Icons.notifications_outlined, size: 28), onPressed: () {}),
                ],
              ),
              const SizedBox(height: 10),
              // Search + Filter
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
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
                        PopupMenuItem(value: ItemSort(ItemSortField.date, SortOrder.desc), child: Text("Date Modified (Newest)")),
                        PopupMenuItem(value: ItemSort(ItemSortField.date, SortOrder.asc), child: Text("Date Modified (Oldest)")),
                        PopupMenuDivider(),
                        PopupMenuItem(value: ItemSort(ItemSortField.name, SortOrder.desc), child: Text("Name (A–Z)")),
                        PopupMenuItem(value: ItemSort(ItemSortField.name, SortOrder.asc), child: Text("Name (Z–A)")),
                        PopupMenuDivider(),
                        PopupMenuItem(value: ItemSort(ItemSortField.stock, SortOrder.desc), child: Text("Stock (Low → High)")),
                        PopupMenuItem(value: ItemSort(ItemSortField.stock, SortOrder.asc), child: Text("Stock (High → Low)")),
                        PopupMenuDivider(),
                        PopupMenuItem(value: ItemSort(ItemSortField.sale, SortOrder.desc), child: Text("Sale (Low → High)")),
                        PopupMenuItem(value: ItemSort(ItemSortField.sale, SortOrder.asc), child: Text("Sale (High → Low)")),
                        PopupMenuDivider(),
                        PopupMenuItem(value: ItemSort(ItemSortField.spoilage, SortOrder.desc), child: Text("Spoilage (Low → High)")),
                        PopupMenuItem(value: ItemSort(ItemSortField.spoilage, SortOrder.asc), child: Text("Spoilage (High → Low)")),
                      ],
                    )
                  else
                    PopupMenuButton<CategorySort>(
                      icon: const Icon(Icons.filter_list, size: 28),
                      onSelected: _applyCategorySort,
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: CategorySort(CategorySortField.date, SortOrder.desc), child: Text("Date Modified (Newest)")),
                        PopupMenuItem(value: CategorySort(CategorySortField.date, SortOrder.asc), child: Text("Date Modified (Oldest)")),
                        PopupMenuDivider(),
                        PopupMenuItem(value: CategorySort(CategorySortField.name, SortOrder.desc), child: Text("Category (A–Z)")),
                        PopupMenuItem(value: CategorySort(CategorySortField.name, SortOrder.asc), child: Text("Category (Z–A)")),
                        PopupMenuDivider(),
                        PopupMenuItem(value: CategorySort(CategorySortField.items, SortOrder.desc), child: Text("Items (Low → High)")),
                        PopupMenuItem(value: CategorySort(CategorySortField.items, SortOrder.asc), child: Text("Items (High → Low)")),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Tabs
              Container(
                height: 42,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
                child: Row(children: [_buildTab("Items", 0), _buildTab("Categories", 1)]),
              ),
              const SizedBox(height: 12),
              // Table Content
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))),
                  child: selectedTab == 0
                      ? (dbItems.isEmpty ? _emptyTables("You can manage your items here.", 0) : _buildItemTable())
                      : (categories.isEmpty ? _emptyTables("You can add categories here.", 1) : _buildCategoryTable()),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ((selectedTab == 0 && dbItems.isNotEmpty) || (selectedTab == 1 && categories.isNotEmpty))
          ? FloatingActionButton(
              backgroundColor: Colors.red[700],
              onPressed: selectedTab == 0 ? _createItem : _createCategory,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
