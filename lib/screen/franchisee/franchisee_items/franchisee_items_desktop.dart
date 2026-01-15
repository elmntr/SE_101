import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/tables/sorting_and_filters.dart';
import 'package:chickenjoo_inventory/tables/tables.dart';
import 'franchisee_items.dart';

class ItemsPageDesktop extends StatelessWidget {
  final ItemsPageState state;

  const ItemsPageDesktop({super.key, required this.state});

  Widget buildTab(String label, int index) {
    bool active = state.selectedTab == index;
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => state.setState(() => state.selectedTab = index),
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
                        color: Colors.black.withValues(alpha: 0.12),
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
                if (state.selectedTab == 0)
                  PopupMenuButton<ItemSort>(
                    icon: const Icon(Icons.filter_list, size: 28),
                    onSelected: state.applyItemSort,
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
                  )
                else
                  PopupMenuButton<CategorySort>(
                    icon: const Icon(Icons.filter_list, size: 28),
                    onSelected: state.applyCategorySort,
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: CategorySort(
                          CategorySortField.name,
                          SortOrder.desc,
                        ),
                        child: Text("Category (A–Z)"),
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
                        buildTab("Item List", 0),
                        buildTab("Categories", 1),
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
                      child: state.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : state.selectedTab == 0
                          ? (state.dbItems.isEmpty
                                ? emptyTables(
                                    message: "You can manage your items here.",
                                    onAddPressed: state.createItem,
                                    buttonType: EmptyButtonType.icon,
                                    buttonText: null,
                                  )
                                : buildUniversalTable(
                                    headers: [
                                      "Item Name",
                                      "Price",
                                      "Category",
                                      "Unit",
                                      "Stock",
                                      "Sale",
                                      "Spoilage",
                                      "",
                                    ],
                                    rows: state.dbItems
                                        .map(
                                          (item) => [
                                            GestureDetector(
                                              onTap: () => state.showItemDetails(item),
                                              child: MouseRegion(
                                                cursor: SystemMouseCursors.click,
                                                child: Text(item.name),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => state.showItemDetails(item),
                                              child: MouseRegion(
                                                cursor: SystemMouseCursors.click,
                                                child: Text(item.price != null ? '₱${item.price!.toStringAsFixed(2)}' : ''),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => state.showItemDetails(item),
                                              child: MouseRegion(
                                                cursor: SystemMouseCursors.click,
                                                child: Text(state.categoryNameForId(item.categoryId)),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => state.showItemDetails(item),
                                              child: MouseRegion(
                                                cursor: SystemMouseCursors.click,
                                                child: Text(item.unit),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => state.showItemDetails(item),
                                              child: MouseRegion(
                                                cursor: SystemMouseCursors.click,
                                                child: Text(item.stock.toString()),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => state.showItemDetails(item),
                                              child: MouseRegion(
                                                cursor: SystemMouseCursors.click,
                                                child: Text(item.sold.toString()),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => state.showItemDetails(item),
                                              child: MouseRegion(
                                                cursor: SystemMouseCursors.click,
                                                child: Text(item.spoilage.toString()),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () =>
                                                  state.deleteItem(item),
                                            ),
                                          ],
                                        )
                                        .toList(),
                                        
                                smallHeaderWidth: 20,
                                largeHeaderWidth: 80,
                                  ))
                          : (state.dbCategories.isEmpty
                                ? emptyTables(
                                    message:
                                        "You can add categories here to organize your items.",
                                    onAddPressed: state.createCategory,
                                    buttonType: EmptyButtonType.icon,
                                    buttonText: null,
                                  )
                                : FutureBuilder<List<Map<String, dynamic>>>(
                                    future: state.buildCategoryRows(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      return buildUniversalTable(
                                        headers: [
                                          "Category Name",
                                          "Items in Category",
                                          "",
                                        ],
                                        rows: snapshot.data!
                                            .map(
                                              (row) => [
                                                row['name'],
                                                row['itemCount'].toString(),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () =>
                                                      state.deleteCategory(
                                                        row['category'],
                                                      ),
                                                ),
                                              ],
                                            )
                                            .toList(),
                                            
                                smallHeaderWidth: 20,
                                largeHeaderWidth: 120,
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
          (!state.isLoading &&
              ((state.selectedTab == 0 && state.dbItems.isNotEmpty) ||
                  (state.selectedTab == 1 && state.dbCategories.isNotEmpty)))
          ? Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton(
                backgroundColor: Colors.red[700],
                onPressed: state.selectedTab == 0 ? state.createItem : state.createCategory,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}