// lib/screens/inventory_management/inventory_management_page.dart
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/database/daos/ingredients_dao.dart';
import 'package:chickenjoo_inventory/database/daos/items_dao.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'inventory_management_page_controller.dart';
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
  late InventoryManagementPageController controller;

  @override
  void initState() {
    super.initState();
    controller = InventoryManagementPageController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // Expose controller properties for UI
  int get selectedTab => controller.selectedTab;
  bool get hasIngredients => controller.hasIngredients;
  bool get hasProducts => controller.hasProducts;
  TextEditingController get searchController => controller.searchController;
  String get searchQuery => controller.searchQuery;
  IngredientSortOrder get ingredientSortOrder =>
      controller.ingredientSortOrder;
  bool get showLowStockIngredientsOnly =>
      controller.showLowStockIngredientsOnly;
  ItemSortOrder get productSortOrder => controller.productSortOrder;
  bool get showLowStockProductsOnly => controller.showLowStockProductsOnly;
  int? get selectedCategoryId => controller.selectedCategoryId;

  // Delegate methods to controller
  void onSearchChanged(String query) => controller.onSearchChanged(query);
  void setIngredientSortOrder(IngredientSortOrder order) =>
      controller.setIngredientSortOrder(order);
  void toggleLowStockIngredients(bool value) =>
      controller.toggleLowStockIngredients(value);
  void setProductSortOrder(ItemSortOrder order) =>
      controller.setProductSortOrder(order);
  void toggleLowStockProducts(bool value) =>
      controller.toggleLowStockProducts(value);
  void setSelectedCategory(int? categoryId) =>
      controller.setSelectedCategory(categoryId);
  void setSelectedTab(int index) => controller.setSelectedTab(index);
  void setHasIngredients(bool value) => controller.setHasIngredients(value);
  void setHasProducts(bool value) => controller.setHasProducts(value);

  void showAddIngredientDialog() {
    showDialog(
      context: context,
      builder: (context) => IngredientFormDialog(
        commissaryId: widget.commissaryId,
        onSave: (companion) async {
          try {
            await database.ingredientsDao.insertIngredient(
              name: companion.name.value,
              commissaryId: companion.commissaryId.value,
              stock: companion.stock.value,
              unit: companion.unit.value,
              criticalLevel: companion.criticalLevel.value,
              costPerUnit: companion.costPerUnit.value,
              cloudId: companion.cloudId.value,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ingredient added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
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
              minimumStock: itemCompanion.minimumStock.value,
              description: itemCompanion.description.value,
              cloudId: itemCompanion.cloudId.value,
            );

            for (final ingredient in recipeIngredients) {
              await database.recipeIngredientsDao.insertRecipeIngredient(
                itemId: itemId,
                ingredientId: ingredient.ingredientId,
                quantityNeeded: ingredient.quantity,
                unit: ingredient.unit,
              );
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Product added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
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
                const Text('â€¢ ', style: TextStyle(color: Colors.grey)),
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
