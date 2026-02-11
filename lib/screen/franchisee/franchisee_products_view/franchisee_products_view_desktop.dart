import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/tables/tables.dart';
import 'package:chickenjoo_inventory/services/search_service.dart';
import 'franchisee_products_view.dart';

class FranchiseeProductsViewDesktop extends StatelessWidget {
  final FranchiseeProductsViewState state;

  const FranchiseeProductsViewDesktop({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header row
            Row(
              children: [
                const Text(
                  "Commissary Products",
                  style: TextStyle(fontSize: 30, fontFamily: fontAll),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: UniversalSearchBar(
                    controller: state.searchController,
                    hintText: "Search products...",
                    onSearch: (value) {
                      state.refreshState(() => state.searchQuery = value);
                    },
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 28),
                  tooltip: 'Refresh products from cloud',
                  onPressed: state.refreshProducts,
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 35),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Products table
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                        ],
                        rows: state.filteredProducts
                            .map(
                              (item) => [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  state.categoryNameForId(item.categoryId),
                                ),
                              ],
                            )
                            .toList(),
                        smallHeaderWidth: 20,
                        largeHeaderWidth: 120,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
