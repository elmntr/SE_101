import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/database/daos/ingredients_dao.dart';
import 'package:chickenjoo_inventory/database/daos/items_dao.dart';
import 'package:chickenjoo_inventory/services/search_service.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/widgets/filter_widgets.dart';
import 'inventory_management_page.dart';
import 'ingredients_tab.dart';
import 'products_tab.dart';

class InventoryManagementPageDesktop extends StatelessWidget {
  final InventoryManagementPageState state;

  const InventoryManagementPageDesktop({super.key, required this.state});

  Widget buildTab(String label, int index) {
    bool active = state.selectedTab == index;
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => state.setSelectedTab(index),
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
                Text(
                  state.widget.organizationName,
                  style: const TextStyle(fontSize: 30, fontFamily: fontAll),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: UniversalSearchBar(
                    controller: state.searchController,
                    onSearch: state.onSearchChanged,
                    hintText: state.selectedTab == 0
                        ? 'Search ingredients...'
                        : 'Search products...',
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                // Filter/Sort button - changes based on selected tab
                if (state.selectedTab == 0)
                  UniversalFilterButton<IngredientSortOrder>(
                    currentValue: state.ingredientSortOrder,
                    onSelected: state.setIngredientSortOrder,
                    tooltip: 'Sort ingredients',
                    options: const [
                      FilterOption.header('SORT BY NAME'),
                      FilterOption(value: IngredientSortOrder.nameAsc, label: 'Name (Aâ€“Z)', icon: Icons.sort_by_alpha),
                      FilterOption(value: IngredientSortOrder.nameDesc, label: 'Name (Zâ€“A)', icon: Icons.sort_by_alpha),
                      FilterOption.divider(),
                      FilterOption.header('SORT BY STOCK'),
                      FilterOption(value: IngredientSortOrder.stockAsc, label: 'Stock (Low â†’ High)', icon: Icons.inventory_2),
                      FilterOption(value: IngredientSortOrder.stockDesc, label: 'Stock (High â†’ Low)', icon: Icons.inventory_2),
                      FilterOption.divider(),

                      FilterOption.header('SORT BY DATE'),
                      FilterOption(value: IngredientSortOrder.newestFirst, label: 'Newest First', icon: Icons.schedule),
                      FilterOption(value: IngredientSortOrder.oldestFirst, label: 'Oldest First', icon: Icons.history),
                    ],
                  )
                else
                  UniversalFilterButton<ItemSortOrder>(
                    currentValue: state.productSortOrder,
                    onSelected: state.setProductSortOrder,
                    tooltip: 'Sort products',
                    options: const [
                      FilterOption.header('SORT BY NAME'),
                      FilterOption(value: ItemSortOrder.nameAsc, label: 'Name (Aâ€“Z)', icon: Icons.sort_by_alpha),
                      FilterOption(value: ItemSortOrder.nameDesc, label: 'Name (Zâ€“A)', icon: Icons.sort_by_alpha),
                      FilterOption.divider(),
                      FilterOption.header('SORT BY STOCK'),
                      FilterOption(value: ItemSortOrder.stockAsc, label: 'Stock (Low â†’ High)', icon: Icons.inventory_2),
                      FilterOption(value: ItemSortOrder.stockDesc, label: 'Stock (High â†’ Low)', icon: Icons.inventory_2),
                      FilterOption.divider(),

                      FilterOption.header('SORT BY DATE'),
                      FilterOption(value: ItemSortOrder.newestFirst, label: 'Newest First', icon: Icons.schedule),
                      FilterOption(value: ItemSortOrder.oldestFirst, label: 'Oldest First', icon: Icons.history),
                    ],
                  ),
                // Low Stock toggle
                IconButton(
                  icon: Icon(
                    Icons.warning_amber_rounded,
                    size: 28,
                    color: (state.selectedTab == 0 ? state.showLowStockIngredientsOnly : state.showLowStockProductsOnly)
                        ? Colors.orange
                        : null,
                  ),
                  tooltip: 'Show low stock only',
                  onPressed: () {
                    if (state.selectedTab == 0) {
                      state.toggleLowStockIngredients(!state.showLowStockIngredientsOnly);
                    } else {
                      state.toggleLowStockProducts(!state.showLowStockProductsOnly);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline, size: 35),
                  onPressed: () => state.showHelpDialog(context),
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
                        buildTab('Ingredients', 0),
                        buildTab('Products', 1),
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
                      child: state.selectedTab == 0
                          ? IngredientsTab(
                              commissaryId: state.widget.commissaryId,
                              onItemsChanged: state.setHasIngredients,
                              searchQuery: state.searchQuery,
                              sortOrder: state.ingredientSortOrder,
                              showLowStockOnly: state.showLowStockIngredientsOnly,
                            )
                          : ProductsTab(
                              organizationId: state.widget.organizationId,
                              onItemsChanged: state.setHasProducts,
                              searchQuery: state.searchQuery,
                              sortOrder: state.productSortOrder,
                              showLowStockOnly: state.showLowStockProductsOnly,
                              selectedCategoryId: state.selectedCategoryId,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          ((state.selectedTab == 0 && state.hasIngredients) ||
              (state.selectedTab == 1 && state.hasProducts))
          ? Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton(
                backgroundColor: Colors.red[700],
                onPressed: state.selectedTab == 0
                    ? state.showAddIngredientDialog
                    : state.showAddProductDialog,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
