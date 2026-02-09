import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/tables/tables.dart';
import 'package:chickenjoo_inventory/services/search_service.dart';
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
                    style: TextStyle(fontSize: 26, fontFamily: fontAll),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 28),
                        tooltip: 'Refresh products from cloud',
                        onPressed: state.refreshProducts,
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

              // Search bar
              UniversalSearchBar(
                controller: state.searchController,
                hintText: "Search products...",
                onSearch: (value) {
                  state.refreshState(() => state.searchQuery = value);
                },
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
                                    state.categoryNameForId(
                                      item.categoryId,
                                    ),
                                  ),
                                ],
                              )
                              .toList(),
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
