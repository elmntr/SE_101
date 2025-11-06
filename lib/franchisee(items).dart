import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/designconstants.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({Key? key}) : super(key: key);

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> categories = [];

  int categoryCount = 0;
  int selectedTab = 0; // 0 = Items, 1 = Categories

  // ✅ Add Item Function
  void _addNewCategory(Map<String, dynamic> newItem) {
    setState(() {
      categories.add(newItem);
    });
  }

  // ✅ Add Item Dialog
  void _showAddCategory() {
    final TextEditingController category = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Add Category", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: "Category"), controller: category),
            ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (category.text.isEmpty) return;
              _addNewCategory({
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

  // ✅ Empty Screen Widget
  Widget _noPresentItems(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _noPresentCategories(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 15),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.red, size: 55),
            onPressed: _showAddCategory,
          )
        ],
      ),
    );
  }
  

  // ✅ Table Widget
  Widget _buildCategoryTable() {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Category Name", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Items in Category", style: TextStyle(fontWeight: FontWeight.bold))),
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
                onPressed: () => _confirmDelete(i),
              ),
            ),
          ]);
        }),
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Delete Category", style: TextStyle(fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ Header
            Row(
              children: [
                const Text("Items", style: TextStyle(fontSize: 30, fontFamily: fontAll)),
                const SizedBox(width: 16),

                // ✅ Search Bar
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

            // ✅ Tabs + Content
            Expanded(
              child: Column(
                children: [
                  // ✅ Raised Tabs
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

                  // ✅ White content box
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
                          ? _noPresentItems("You can manage your items here.")
                          : (categories.isEmpty ?_noPresentCategories("You can add categories here to organize your items.") : _buildCategoryTable()) ,
              
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

  // ✅ Tab Builder
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
      )
    );
  }
}
