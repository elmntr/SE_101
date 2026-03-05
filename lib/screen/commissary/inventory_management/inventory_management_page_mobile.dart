import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/database/daos/ingredients_dao.dart';
import 'package:chickenjoo_inventory/database/daos/items_dao.dart';
import 'package:chickenjoo_inventory/services/search_service.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/widgets/filter_widgets.dart';
import 'inventory_management_page.dart';
import 'ingredients_tab.dart';
import 'products_tab.dart';

class InventoryManagementPageMobile extends StatelessWidget {
  final InventoryManagementPageState state;

  const InventoryManagementPageMobile({super.key, required this.state});

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          state.widget.organizationName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontFamily: fontAll,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.help_outline, size: 28),
                        onPressed: () => state.showHelpDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: UniversalSearchBar(
                          controller: state.searchController,
                          onSearch: state.onSearchChanged,
                          hintText: state.selectedTab == 0
                              ? 'Search ingredients...'
                              : 'Search products...',
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                      // Filter/Sort button
                      if (state.selectedTab == 0)
                        UniversalFilterButton<IngredientSortOrder>(
                          currentValue: state.ingredientSortOrder,
                          onSelected: state.setIngredientSortOrder,
                          tooltip: 'Sort',
                          iconSize: 24,
                          options: const [
                            FilterOption.header('SORT BY'),
                            FilterOption(value: IngredientSortOrder.nameAsc, label: 'Name (A�Z)'),
                            FilterOption(value: IngredientSortOrder.nameDesc, label: 'Name (Z�A)'),
                            FilterOption.divider(),
                            FilterOption(value: IngredientSortOrder.stockAsc, label: 'Stock (Low ? High)'),
                            FilterOption(value: IngredientSortOrder.stockDesc, label: 'Stock (High ? Low)'),
                            FilterOption.divider(),
                            FilterOption(value: IngredientSortOrder.newestFirst, label: 'Newest First'),
                            FilterOption(value: IngredientSortOrder.oldestFirst, label: 'Oldest First'),
                          ],
                        )
                      else
                        UniversalFilterButton<ItemSortOrder>(
                          currentValue: state.productSortOrder,
                          onSelected: state.setProductSortOrder,
                          tooltip: 'Sort',
                          iconSize: 24,
                          options: const [
                            FilterOption.header('SORT BY'),
                            FilterOption(value: ItemSortOrder.nameAsc, label: 'Name (A�Z)'),
                            FilterOption(value: ItemSortOrder.nameDesc, label: 'Name (Z�A)'),
                            FilterOption.divider(),
                            FilterOption(value: ItemSortOrder.stockAsc, label: 'Stock (Low ? High)'),
                            FilterOption(value: ItemSortOrder.stockDesc, label: 'Stock (High ? Low)'),
                            FilterOption.divider(),
                            FilterOption(value: ItemSortOrder.newestFirst, label: 'Newest First'),
                            FilterOption(value: ItemSortOrder.oldestFirst, label: 'Oldest First'),
                          ],
                        ),
                      // Low Stock toggle
                      IconButton(
                        icon: Icon(
                          Icons.warning_amber_rounded,
                          size: 24,
                          color: (state.selectedTab == 0 
                              ? state.showLowStockIngredientsOnly 
                              : state.showLowStockProductsOnly)
                              ? Colors.orange
                              : null,
                        ),
                        tooltip: 'Low stock',
                        onPressed: () {
                          if (state.selectedTab == 0) {
                            state.toggleLowStockIngredients(!state.showLowStockIngredientsOnly);
                          } else {
                            state.toggleLowStockProducts(!state.showLowStockProductsOnly);
                          }
                        },
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
                    buildTab('Ingredients', 0),
                    buildTab('Products', 1),
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
                  child: state.selectedTab == 0
                      ? IngredientsTab(
                          commissaryId: state.widget.commissaryId,
                          onItemsChanged: state.setHasIngredients,
                          searchQuery: state.searchQuery,
                          sortOrder: state.ingredientSortOrder,
                          showLowStockOnly: state.showLowStockIngredientsOnly,
                          onAddPressed: state.showAddIngredientDialog,
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
      ),
      floatingActionButton:
          ((state.selectedTab == 0 && state.hasIngredients) ||
              (state.selectedTab == 1 && state.hasProducts))
          ? FloatingActionButton(
              backgroundColor: Colors.red[700],
              onPressed: state.selectedTab == 0
                  ? state.showAddIngredientDialog
                  : state.showAddProductDialog,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
