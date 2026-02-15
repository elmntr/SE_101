import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/tables/sorting_and_filters.dart';
import 'package:chickenjoo_inventory/tables/tables.dart';
import 'package:chickenjoo_inventory/services/search_service.dart';
import 'franchisee_inventory.dart';
import 'replenish_stock_tab.dart';

class InventoryPageMobile extends StatelessWidget {
  final InventoryPageState state;

  const InventoryPageMobile({super.key, required this.state});

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
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 28),
                        tooltip: 'Refresh inventory from cloud',
                        onPressed: state.refreshInventory,
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
                ],
              ),

              const SizedBox(height: 10),

              /// SEARCH BAR + FILTER
              Row(
                children: [
                  /// SEARCH BAR
                  Expanded(
                    child: UniversalSearchBar(
                      controller: state.searchController,
                      hintText: "Search inventory...",
                      onSearch: (value) {
                        state.setState(() => state.searchQuery = value);
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

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
                          value: ItemSort(
                            ItemSortField.spoilage,
                            SortOrder.asc,
                          ),
                          child: Text("Spoilage (Low → High)"),
                        ),
                        PopupMenuItem(
                          value: ItemSort(
                            ItemSortField.spoilage,
                            SortOrder.desc,
                          ),
                          child: Text("Spoilage (High → Low)"),
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
                    buildTab("Stock", 0),
                    buildTab("Changes", 1),
                    buildTab("Replenish", 2),
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

                                smallHeaderWidth: 60,
                                largeHeaderWidth: 120,
                              ))
                      : state.selectedTab == 1
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Employee:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                DropdownButton<int?>(
                                  value: state.selectedEmployeeId,
                                  hint: const Text('All employees'),
                                  onChanged: (value) =>
                                      state.applyEmployeeFilter(value),
                                  items: [
                                    const DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('All employees'),
                                    ),
                                    ...state.employeeOptions.map(
                                      (user) => DropdownMenuItem<int?>(
                                        value: user.id,
                                        child: Text(
                                          user.fullName ?? user.username,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (state.changeHistory.isEmpty)
                              emptyTables(
                                message: state.searchQuery.isNotEmpty
                                    ? "No changes match your search"
                                    : "No change history",
                                onAddPressed: null,
                                buttonType: EmptyButtonType.none,
                                buttonText: null,
                              )
                            else
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: state.buildChangeHistoryRows(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return buildUniversalTable(
                                    headers: [
                                      "Employee",
                                      "Item",
                                      "Type",
                                      "Quantity",
                                      "Status",
                                      "Actions",
                                    ],
                                    rows: snapshot.data!
                                        .map(
                                          (row) => [
                                            row['employeeName'],
                                            row['itemName'],
                                            row['changeType'],
                                            row['quantity'],
                                            state.buildStatusChip(row['status']),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (row['status'] == 'pending')
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green,
                                                    ),
                                                    tooltip: 'Approve change',
                                                    onPressed: () =>
                                                        state.approveChangeRequest(
                                                      context,
                                                      row['request'],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        )
                                        .toList(),
                                    smallHeaderWidth: 60,
                                    largeHeaderWidth: 120,
                                  );
                                },
                              ),
                          ],
                        )
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
      ),
    );
  }
}
