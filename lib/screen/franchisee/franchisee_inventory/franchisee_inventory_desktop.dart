import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/tables/sorting_and_filters.dart';
import 'package:chickenjoo_inventory/tables/tables.dart';
import 'package:chickenjoo_inventory/services/search_service.dart';
import 'franchisee_inventory.dart';
import 'replenish_stock_tab.dart';

class InventoryPageDesktop extends StatelessWidget {
  final InventoryPageState state;

  const InventoryPageDesktop({super.key, required this.state});

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
            // Header
            Row(
              children: [
                const Text(
                  "Inventory",
                  style: TextStyle(fontSize: 30, fontFamily: fontAll),
                ),
                const SizedBox(width: 16),

                // Search Bar
                Expanded(
                  child: UniversalSearchBar(
                    controller: state.searchController,
                    hintText: "Search inventory...",
                    onSearch: (value) {
                      state.setState(() => state.searchQuery = value);
                    },
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),

                if (state.selectedTab == 0)
                  PopupMenuButton<ItemSort>(
                    icon: const Icon(Icons.filter_list, size: 28),
                    onSelected: state.applyItemSort,
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
                        value: ItemSort(ItemSortField.name, SortOrder.asc),
                        child: Text("Name (A–Z)"),
                      ),
                      PopupMenuItem(
                        value: ItemSort(ItemSortField.name, SortOrder.desc),
                        child: Text("Name (Z–A)"),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: ItemSort(ItemSortField.stock, SortOrder.asc),
                        child: Text("Stock (Low → High)"),
                      ),
                      PopupMenuItem(
                        value: ItemSort(ItemSortField.stock, SortOrder.desc),
                        child: Text("Stock (High → Low)"),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: ItemSort(ItemSortField.sale, SortOrder.asc),
                        child: Text("Sale (Low → High)"),
                      ),
                      PopupMenuItem(
                        value: ItemSort(ItemSortField.sale, SortOrder.desc),
                        child: Text("Sale (High → Low)"),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: ItemSort(ItemSortField.spoilage, SortOrder.asc),
                        child: Text("Spoilage (Low → High)"),
                      ),
                      PopupMenuItem(
                        value: ItemSort(ItemSortField.spoilage, SortOrder.desc),
                        child: Text("Spoilage (High → Low)"),
                      ),
                    ],
                  ),

                IconButton(
                  icon: const Icon(Icons.refresh, size: 28),
                  tooltip: 'Refresh inventory from cloud',
                  onPressed: state.refreshInventory,
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
                        buildTab("Item Stock", 0),
                        buildTab("Stock Changes", 1),
                        buildTab("Replenish Stock", 2),
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
                          ? (state.filteredItems.isEmpty
                                ? emptyTables(
                                    message: state.searchQuery.isNotEmpty
                                        ? "No items match your search"
                                        : "You can manage your items here.",
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
                                    rows: state.filteredItems
                                        .map(
                                          (item) => [
                                            item.name,
                                            item.stock.toString(),
                                            item.sold.toString(),
                                            item.spoilage.toString(),
                                          ],
                                        )
                                        .toList(),

                                    smallHeaderWidth: 20,
                                    largeHeaderWidth: 120,
                                  ))
                          : state.selectedTab == 1
                          ? (InventoryPage.pendingChanges.isEmpty
                                ? emptyTables(
                                    message:
                                        "You can view employee stock changes here.",
                                    onAddPressed: null,
                                    buttonType: EmptyButtonType.none,
                                    buttonText: null,
                                  )
                                : buildUniversalTable(
                                    headers: [
                                      "Employee",
                                      "Role",
                                      "Changes",
                                      "Status",
                                    ],
                                    rows: List.generate(
                                      InventoryPage.pendingChanges.length,
                                      (i) {
                                        final record =
                                            InventoryPage.pendingChanges[i];
                                        return [
                                          record.employeeName,
                                          record.role,
                                          record.totalChanges.toString(),
                                          record.status,
                                        ];
                                      },
                                    ),

                                    smallHeaderWidth: 20,
                                    largeHeaderWidth: 120,
                                  ))
                          : ReplenishStockTab(
                              branchId: state.currentOrganizationId ?? 0,
                              commissaryId: state.commissaryId ?? 0,
                              userId: state.currentUserId ?? 0,
                              items: state.items,
                            ),
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
