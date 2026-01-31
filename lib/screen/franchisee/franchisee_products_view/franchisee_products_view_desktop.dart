import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/tables/tables.dart';
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
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: fontAll,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: state.searchController,
                      decoration: const InputDecoration(
                        hintText: "Search products...",
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        state.setState(() => state.searchQuery = value);
                      },
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

            // Info banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Viewing products from commissary. Click a product to see recipe details.',
                      style: TextStyle(color: Colors.blue, fontSize: 13),
                    ),
                  ),
                  // Record Stock/Sales button (only if user has edit permission)
                  if (state.canEditStock)
                    ElevatedButton.icon(
                      onPressed: state.toggleChangeStockMode,
                      icon: const Icon(Icons.edit_note, size: 20),
                      label: const Text('Record Stock/Sales Change'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
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
                              'Stock',
                              'Sold',
                              'Spoilage',
                              'Unit',
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
                                  Text(
                                    '${item.stock}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: item.stock <= (item.minimumStock ?? 10) ? Colors.red : Colors.black,
                                    ),
                                  ),
                                  Text('${item.sold}'),
                                  Text(
                                    '${item.spoilage}',
                                    style: TextStyle(
                                      color: item.spoilage > 0 ? Colors.orange : Colors.black,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => state.showProductDetails(item),
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: Text(item.unit),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.visibility, color: Colors.blue),
                                    tooltip: 'View Details',
                                    onPressed: () => state.showProductDetails(item),
                                  ),
                                ]).toList(),
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
