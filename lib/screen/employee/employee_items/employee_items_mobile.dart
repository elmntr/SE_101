import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/tables/sorting_and_filters.dart';
import 'package:chickenjoo_inventory/tables/tables.dart';
import 'package:chickenjoo_inventory/services/search_service.dart';
import 'employee_items.dart';

class EmployeeItemsPageMobile extends StatelessWidget {
  final EmployeeItemsPageState state;

  const EmployeeItemsPageMobile({super.key, required this.state});

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
                        child: UniversalSearchBar(
                          controller: state.searchController,
                          hintText: state.selectedTab == 0
                              ? "Search items..."
                              : "Search changes...",
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
                    buildTab("Items", 0),
                    buildTab("Review Changes", 1),
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
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.selectedTab == 0
                      ? _buildItemsTab()
                      : _buildReviewChangesTab(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          (state.selectedTab == 0 &&
              state.dbItems.isNotEmpty &&
              !state.isLoading)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton.extended(
                onPressed: state.showChangeStockDialog,
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

  Widget _buildItemsTab() {
    if (state.filteredItems.isEmpty) {
      return emptyTables(
        message: state.searchQuery.isNotEmpty
            ? "No items match your search"
            : "No items available",
        onAddPressed: null,
        buttonType: EmptyButtonType.none,
        buttonText: null,
      );
    }
    return buildUniversalTable(
      headers: ["Item Name", "Stock", "Sale", "Spoilage"],
      rows: state.filteredItems
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
            ],
          )
          .toList(),
      smallHeaderWidth: 20,
      largeHeaderWidth: 120,
    );
  }

  Widget _buildReviewChangesTab() {
    return Column(
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
              onChanged: (value) => state.applyEmployeeFilter(value),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All employees'),
                ),
                ...state.employeeOptions.map(
                  (user) => DropdownMenuItem<int?>(
                    value: user.id,
                    child: Text(user.fullName ?? user.username),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (state.filteredPendingChanges.isEmpty)
          emptyTables(
            message: state.searchQuery.isNotEmpty
              ? "No changes match your search"
              : "No review changes",
            onAddPressed: null,
            buttonType: EmptyButtonType.none,
            buttonText: null,
          )
        else
          FutureBuilder<List<Map<String, dynamic>>>(
            future: state.buildChangeRequestRows(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return buildUniversalTable(
                headers: ["Employee", "Item", "Type", "Qty", "Status", ""],
                rows: snapshot.data!
                    .map(
                      (row) => [
                        row['employeeName'],
                        row['itemName'],
                        row['changeType'],
                        row['quantity'],
                        state.buildStatusChip(row['status']),
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () =>
                              state.viewChangeDetail(row['request']),
                        ),
                      ],
                    )
                    .toList(),
                smallHeaderWidth: 20,
                largeHeaderWidth: 120,
              );
            },
          ),
      ],
    );
  }
}
