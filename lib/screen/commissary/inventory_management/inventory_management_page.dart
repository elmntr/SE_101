// lib/screens/inventory_management/inventory_management_page.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/database/daos/ingredients_dao.dart';
import 'package:chickenjoo_inventory/database/daos/items_dao.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'inventory_management_page_desktop.dart';
import 'inventory_management_page_mobile.dart';
import 'widgets/ingredient_form_dialog.dart';
import 'widgets/item_form_dialog.dart';

/// Main inventory management page with tabs for Ingredients and Products
/// Commissary can:
/// - Manage raw materials and supplies (Ingredients)
/// - Create and manage finished products with recipes (Products)
class InventoryManagementPage extends StatefulWidget {
  final int organizationId;
  final int commissaryId;
  final String organizationName;

  const InventoryManagementPage({
    super.key,
    required this.organizationId,
    required this.commissaryId,
    this.organizationName = 'Inventory Management',
  });

  @override
  State<InventoryManagementPage> createState() =>
      InventoryManagementPageState();
}

class InventoryManagementPageState extends State<InventoryManagementPage> {
  int selectedTab = 0; // 0 = Ingredients, 1 = Products
  bool hasIngredients = false;
  bool hasProducts = false;

  // Search functionality
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Sort & Filter state for Ingredients tab
  IngredientSortOrder ingredientSortOrder = IngredientSortOrder.nameAsc;
  bool showLowStockIngredientsOnly = false;

  // Sort & Filter state for Products tab
  ItemSortOrder productSortOrder = ItemSortOrder.nameAsc;
  bool showLowStockProductsOnly = false;
  int? selectedCategoryId;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  // Sort/Filter methods for Ingredients
  void setIngredientSortOrder(IngredientSortOrder order) {
    setState(() {
      ingredientSortOrder = order;
    });
  }

  void toggleLowStockIngredients(bool value) {
    setState(() {
      showLowStockIngredientsOnly = value;
    });
  }

  // Sort/Filter methods for Products
  void setProductSortOrder(ItemSortOrder order) {
    setState(() {
      productSortOrder = order;
    });
  }

  void toggleLowStockProducts(bool value) {
    setState(() {
      showLowStockProductsOnly = value;
    });
  }

  void setSelectedCategory(int? categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
    });
  }

  void setSelectedTab(int index) {
    setState(() => selectedTab = index);
  }

  void setHasIngredients(bool value) {
    if (hasIngredients != value) {
      setState(() => hasIngredients = value);
    }
  }

  void setHasProducts(bool value) {
    if (hasProducts != value) {
      setState(() => hasProducts = value);
    }
  }

  void showAddIngredientDialog() {
    // Capture page-level messenger before showing dialog — the dialog's builder
    // context becomes deactivated after Navigator.pop() runs in _handleSave(),
    // which happens before the async onSave completes.
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (context) => IngredientFormDialog(
        commissaryId: widget.commissaryId,
        onSave: (companion) async {
          try {
            await database.ingredientsDao.insertIngredients([companion]);
            if (mounted) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Ingredient added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(e.toString().replaceFirst('Exception: ', '')),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> showAddProductDialog() async {
    final ingredients = await database.ingredientsDao.getAllIngredients();
    final categories = await database.categoriesDao.getAllCategories();

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (context) => ItemFormDialog(
        organizationId: widget.organizationId,
        availableIngredients: ingredients,
        categories: categories,
        onSave: (itemCompanion, recipeIngredients) async {
          try {
            final itemId = await database.itemsDao.insertItem(
              name: itemCompanion.name.value,
              organizationId: itemCompanion.organizationId.value,
              stock: itemCompanion.stock.value,
              categoryId: itemCompanion.categoryId.value,
              price: itemCompanion.price.value,
              costPrice: itemCompanion.costPrice.value,
              unit: itemCompanion.unit.value,
              minimumStock: itemCompanion.minimumStock.value,
              description: itemCompanion.description.value,
              cloudId: itemCompanion.cloudId.value,
            );

            for (final ingredient in recipeIngredients) {
              await database.recipeIngredientsDao.insertRecipeIngredient(
                itemId: itemId,
                ingredientId: ingredient.ingredientId,
                quantityNeeded: ingredient.quantity,
                unit: 'pieces',
              );
            }

            if (mounted) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Product added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(e.toString().replaceFirst('Exception: ', '')),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (AppLayout.isDesktop(context) == false) {
      return InventoryManagementPageMobile(state: this);
    }
    return InventoryManagementPageDesktop(state: this);
  }

  void showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.help_outline, color: Colors.blue),
            SizedBox(width: 12),
            Expanded(child: Text('Inventory Management Help')),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HelpSection(
                title: 'Ingredients Tab',
                icon: Icons.kitchen,
                color: Colors.orange,
                items: [
                  'Manage raw materials and supplies used in your products',
                  'Track stock levels and set critical thresholds for low stock alerts',
                  'Record cost per unit for accurate product costing',
                  'Adjust stock quantities when receiving or using ingredients',
                ],
              ),
              SizedBox(height: 20),
              _HelpSection(
                title: 'Products Tab',
                icon: Icons.fastfood,
                color: Colors.blue,
                items: [
                  'Create and manage finished products for sale',
                  'Build recipes by adding ingredients with quantities',
                  'Auto-calculate product cost based on recipe ingredients',
                  'Track profit margins and stock levels',
                  'Organize products into categories',
                ],
              ),
              SizedBox(height: 20),
              _HelpSection(
                title: 'Tips',
                icon: Icons.lightbulb,
                color: Colors.amber,
                items: [
                  'Add ingredients first before creating products with recipes',
                  'Low stock items are highlighted with orange borders',
                  'Use the search and filter options to quickly find items',
                  'Click on any card to edit its details',
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  const _HelpSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 28, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('� ', style: TextStyle(color: Colors.grey)),
                Expanded(
                  child: Text(item, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
