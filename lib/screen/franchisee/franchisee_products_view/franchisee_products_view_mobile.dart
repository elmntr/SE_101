import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/tables/tables.dart';
import 'franchisee_products_view.dart';

class FranchiseeProductsViewMobile extends StatelessWidget {
  final FranchiseeProductsViewState state;

  const FranchiseeProductsViewMobile({super.key, required this.state});

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
                  const Text(
                    'Commissary Products',
                    style: TextStyle(
                      fontSize: 26,
                      fontFamily: fontAll,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 28),
                        tooltip: 'Refresh products from cloud',
                        onPressed: state.refreshProducts,
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, size: 28),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Search bar
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: state.searchController,
                  decoration: const InputDecoration(
                    hintText: "Search products...",
                    icon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    state.setState(() => state.searchQuery = value);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Info banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Viewing products from commissary. Tap a product to see recipe details.',
                        style: TextStyle(color: Colors.blue, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Record Stock/Sales button (only if user has edit permission)
              if (state.canEditStock)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: state.toggleChangeStockMode,
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Record Stock/Sales Change'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Products table
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.filteredProducts.isEmpty
                          ? emptyTables(
                              message: state.searchQuery.isNotEmpty
                                  ? 'No products match your search'
                                  : 'No products available from commissary',
                              buttonType: EmptyButtonType.none,
                            )
                          : buildUniversalTable(
                              headers: [
                                'Product Name',
                                'Category',
                                'Unit',
                                'Recipe Ingredients',
                                '',
                              ],
                              rows: state.filteredProducts.map((item) => [
                                    GestureDetector(
                                      onTap: () => state.showProductDetails(item),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: Text(
                                          item.name,
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => state.showProductDetails(item),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: Text(state.categoryNameForId(item.categoryId)),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => state.showProductDetails(item),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: Text(item.unit),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => state.showProductDetails(item),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: SizedBox(
                                          width: 200,
                                          child: Text(
                                            state.getIngredientsDisplay(item.id),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.visibility, color: Colors.blue),
                                      tooltip: 'View Details',
                                      onPressed: () => state.showProductDetails(item),
                                    ),
                                  ]).toList(),
                              smallHeaderWidth: 120,
                              largeHeaderWidth: 120,
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
