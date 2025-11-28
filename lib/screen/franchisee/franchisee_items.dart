import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import '../../../data/local/app_database.dart';
import "../../../data/database_provider.dart";
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

  @override
  void initState() {
    super.initState();
    db = DatabaseProvider.instance;
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await db.getAllItems();
    setState(() {
      dbItems = items;
    });
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

              await db.insertItem(ItemsCompanion.insert(
                name: name.text,
                stock: Value(int.tryParse(stock.text) ?? 0),
              ));

              Navigator.pop(context);
              _loadItems(); // ✅ refresh UI
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Add Category Popup (untouched)
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

  // Empty Tab Widget
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
                _createItem(); // ✅ now connected to DB
              }
            },
          ),
        ],
      ),
    );
  }

  // ✅ Item Table Widget with "Add Item" button
  Widget _buildItemTable() {
    return SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(
                    label: Text("Item Name",
                        style:
                            TextStyle(fontFamily: fontAll, color: Colors.red))),
                DataColumn(
                    label: Text("Stock",
                        style:
                            TextStyle(fontFamily: fontAll, color: Colors.red))),
                DataColumn(
                    label: Text("Sale",
                        style:
                            TextStyle(fontFamily: fontAll, color: Colors.red))),
                DataColumn(
                    label: Text("Spoilage",
                        style:
                            TextStyle(fontFamily: fontAll, color: Colors.red))),
                DataColumn(label: Text("")),
              ],
              rows: List.generate(dbItems.length, (i) {
                final item = dbItems[i];
                return DataRow(cells: [
                  DataCell(Text(item.name)),
                  DataCell(Text(item.stock.toString())),
                  DataCell(Text(item.sold.toString())),
                  DataCell(Text(item.spoilage.toString())),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await db.deleteItemById(item.id);
                        _loadItems();
                      },
                    ),
                  ),
                ]);
              }),
            ),
          );
  }

  // ✅ Category Table Widget with "Add Category" button
  Widget _buildCategoryTable() {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(
              label: Text("Category Name",
                  style:
                      TextStyle(fontFamily: fontAll, color: Colors.red))),
          DataColumn(
              label: Text("Items in Category",
                  style:
                      TextStyle(fontFamily: fontAll, color: Colors.red))),
          DataColumn(label: Text('')),
        ],
        rows: List.generate(categories.length, (i) {
          final category = categories[i];
          return DataRow(cells: [
            DataCell(Text(category["category"])),
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
    );
  }

  void _deleteCategory(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Delete Category",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to delete this category?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
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
                        _buildTab("Item List", 0),
                        _buildTab("Categories", 1),
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
                          ? (dbItems.isEmpty
                              ? _emptyTables(
                                  "You can manage your items here.",
                                  selectedTab)
                              : _buildItemTable())
                          : (categories.isEmpty
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

      floatingActionButton:  (selectedTab == 0 && dbItems.isNotEmpty) || (selectedTab == 1 && categories.isNotEmpty)
      ? Container(
          margin: const EdgeInsets.only(bottom: 20), // ✅ overlap without pushing content
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
}
