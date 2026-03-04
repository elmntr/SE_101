// lib/screens/inventory_management/products_tab.dart
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/database/daos/items_dao.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/tables/tables.dart';
import 'widgets/item_form_dialog.dart';

/// Products/Inventory tab for managing finished products
class ProductsTab extends StatefulWidget {
  final int organizationId;
  final ValueChanged<bool>? onItemsChanged;
  final String searchQuery;
  final ItemSortOrder sortOrder;
  final bool showLowStockOnly;
  final int? selectedCategoryId;

  const ProductsTab({
    super.key,
    required this.organizationId,
    this.onItemsChanged,
    this.searchQuery = '',
    this.sortOrder = ItemSortOrder.nameAsc,
    this.showLowStockOnly = false,
    this.selectedCategoryId,
  });

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _showAddProductDialog() async {
    // Fetch ingredients and categories
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
          // Insert item
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

          // Insert recipe ingredients
          for (final ingredient in recipeIngredients) {
            await database.recipeIngredientsDao.insertRecipeIngredient(
              itemId: itemId,
              ingredientId: ingredient.ingredientId,
              quantityNeeded: ingredient.quantity,
              unit: 'pieces',
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
        },
      ),
    );
  }

  Future<void> _showEditProductDialog(Item item) async {
    // Fetch ingredients and categories
    final ingredients = await database.ingredientsDao.getAllIngredients();
    final categories = await database.categoriesDao.getAllCategories();
    final existingRecipe = await database.recipeIngredientsDao
        .getIngredientsForItem(item.id);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => ItemFormDialog(
        item: item,
        organizationId: widget.organizationId,
        availableIngredients: ingredients,
        categories: categories,
        existingRecipe: existingRecipe,
        onSave: (itemCompanion, recipeIngredients) async {
          // Update item
          final updatedItem = Item(
            id: item.id,
            cloudId: itemCompanion.cloudId.value,
            name: itemCompanion.name.value,
            description: itemCompanion.description.value,
            stock: itemCompanion.stock.value,
            minimumStock: itemCompanion.minimumStock.value,
            sold: item.sold,
            spoilage: item.spoilage,
            price: itemCompanion.price.value,
            costPrice: itemCompanion.costPrice.value,
            unit: item.unit,
            organizationId: itemCompanion.organizationId.value,
            categoryId: itemCompanion.categoryId.value,
            masterItemId: item.masterItemId,
            isDeleted: false,
            isSynced: false,
            createdAt: item.createdAt,
            lastUpdated: DateTime.now().toUtc(),
          );
          await database.itemsDao.updateItem(updatedItem);

          // Update recipe - delete old and insert new
          await database.recipeIngredientsDao.deleteAllForItem(item.id);
          for (final ingredient in recipeIngredients) {
            await database.recipeIngredientsDao.insertRecipeIngredient(
              itemId: item.id,
              ingredientId: ingredient.ingredientId,
              quantityNeeded: ingredient.quantity,
              unit: 'pieces',
            );
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(Item item) {
    final passwordController = TextEditingController();
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 12),
              const Expanded(child: Text('Permanently Delete Product')),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to permanently delete "${item.name}"?',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This will permanently delete the item from both the local database and the cloud. This action cannot be undone.',
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Enter your password to confirm:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) =>
                      _performDelete(item, passwordController.text),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _performDelete(item, passwordController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Permanently Delete'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performDelete(Item item, String password) async {
    // Validate password is not empty
    if (password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password is required'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Close the dialog
    if (mounted) Navigator.pop(context);

    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Deleting item...'),
            ],
          ),
          duration: Duration(seconds: 10),
        ),
      );
    }

    try {
      // Get current user
      final currentUser = authService.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Get user from database to verify password
      final user = await database.usersDao.getUserById(currentUser.id);
      if (user == null) {
        throw Exception('User not found');
      }

      // Verify password
      if (!verifyPassword(password, user.password)) {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Incorrect password'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Soft delete locally to avoid FK issues and allow sync
      await database.itemsDao.softDeleteItem(item.id);

      // Best-effort sync to push deactivation to cloud
      try {
        await syncService.syncAll();
      } catch (e) {
        print('?? Failed to sync after delete: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAdjustStockDialog(Item item) {
    final controller = TextEditingController();
    bool isAdding = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.inventory, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(child: Text('Adjust Stock: ${item.name}')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Stock: ${item.stock} units',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ToggleButtons(
                isSelected: [isAdding, !isAdding],
                onPressed: (index) {
                  setDialogState(() {
                    isAdding = index == 0;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 20),
                        SizedBox(width: 8),
                        Text('Add Stock'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.remove, size: 20),
                        SizedBox(width: 8),
                        Text('Remove Stock'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  prefixIcon: Icon(isAdding ? Icons.add : Icons.remove),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final quantity = int.tryParse(controller.text);
                if (quantity != null && quantity > 0) {
                  if (isAdding) {
                    await database.itemsDao.addStock(item.id, quantity);
                  } else {
                    await database.itemsDao.updateStock(item.id, (item.stock - quantity).clamp(0, 999999));
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${isAdding ? "Added" : "Removed"} $quantity units',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecipeDetailsDialog(Item item) async {
    final recipeDetails = await database.recipeIngredientsDao
        .getIngredientsForItem(item.id);

    // Fetch ingredient names
    final ingredientNames = <int, String>{};
    for (final ri in recipeDetails) {
      final ingredient = await database.ingredientsDao.getIngredientById(ri.ingredientId);
      if (ingredient != null) {
        ingredientNames[ri.ingredientId] = ingredient.name;
      }
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.restaurant_menu, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(child: Text('Recipe: ${item.name}')),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: recipeDetails.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No recipe defined for this product.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Recipe table
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(7),
                                topRight: Radius.circular(7),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Ingredient',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Quantity',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Cost',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...recipeDetails.map(
                            (detail) => Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.grey[200]!),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(ingredientNames[detail.ingredientId] ?? 'Unknown'),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${detail.quantityNeeded} ${detail.unit}',
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 2,
                                    child: Text(
                                      '-',
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Cost summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Cost:'),
                              Text(
                                '?${(item.costPrice ?? 0).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Selling Price:'),
                              Text(
                                '?${(item.price ?? 0).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Profit Margin:'),
                              Text(
                                '?${((item.price ?? 0) - (item.costPrice ?? 0)).toStringAsFixed(2)} '
                                '(${(item.price ?? 0) > 0 ? (((item.price ?? 0) - (item.costPrice ?? 0)) / (item.price ?? 1) * 100).toStringAsFixed(1) : 0}%)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: (item.price ?? 0) - (item.costPrice ?? 0) >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Item>>(
      stream: database.itemsDao.watchAllItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        var products = snapshot.data ?? [];

        // Notify parent about items count
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.onItemsChanged?.call(products.isNotEmpty);
          }
        });

        // Apply search filter
        if (widget.searchQuery.isNotEmpty) {
          products = products
              .where(
                (p) => p.name.toLowerCase().contains(
                  widget.searchQuery.toLowerCase(),
                ),
              )
              .toList();
        }

        // Apply category filter
        if (widget.selectedCategoryId != null) {
          products = products
              .where((p) => p.categoryId == widget.selectedCategoryId)
              .toList();
        }

        // Apply low stock filter
        if (widget.showLowStockOnly) {
          products = products.where((p) => p.minimumStock != null && p.stock <= p.minimumStock!).toList();
        }

        // Apply sorting
        products.sort((a, b) {
          switch (widget.sortOrder) {
            case ItemSortOrder.nameAsc:
              return a.name.compareTo(b.name);
            case ItemSortOrder.nameDesc:
              return b.name.compareTo(a.name);
            case ItemSortOrder.stockAsc:
              return a.stock.compareTo(b.stock);
            case ItemSortOrder.stockDesc:
              return b.stock.compareTo(a.stock);
            case ItemSortOrder.newestFirst:
              return b.createdAt.compareTo(a.createdAt);
            case ItemSortOrder.oldestFirst:
              return a.createdAt.compareTo(b.createdAt);
          }
        });

        if (products.isEmpty &&
            widget.searchQuery.isEmpty &&
            !widget.showLowStockOnly &&
            widget.selectedCategoryId == null) {
          return emptyTables(
            message: 'You can manage your products here.',
            onAddPressed: _showAddProductDialog,
            buttonType: EmptyButtonType.icon,
            buttonText: null,
          );
        }

        if (products.isEmpty) {
          return const Center(
            child: Text(
              'No products match your filters',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final numberFormat = NumberFormat('#,##0.##');
        return buildUniversalTable(
          headers: ['Name', 'Stock', 'Price', 'Cost', 'Margin', 'Status', ''],
          rows: products.map((product) {
            final isLowStock = product.minimumStock != null && product.stock <= product.minimumStock!;
            final price = product.price ?? 0;
            final cost = product.costPrice ?? 0;
            final profit = price - cost;
            final profitMargin = price > 0
                ? (profit / price * 100)
                : 0;
            return [
              Text(product.name),
              Text(numberFormat.format(product.stock)),
              Text('?${numberFormat.format(price)}'),
              Text('?${numberFormat.format(cost)}'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: profit >= 0
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${profitMargin.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: profit >= 0 ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLowStock
                      ? Colors.orange.shade100
                      : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isLowStock ? 'Low Stock' : 'In Stock',
                  style: TextStyle(
                    color: isLowStock ? Colors.orange : Colors.green,
                    fontSize: 12,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.restaurant_menu, size: 18),
                    tooltip: 'View Recipe',
                    onPressed: () => _showRecipeDetailsDialog(product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.inventory, size: 18),
                    tooltip: 'Adjust Stock',
                    onPressed: () => _showAdjustStockDialog(product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    tooltip: 'Edit',
                    onPressed: () => _showEditProductDialog(product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                    tooltip: 'Delete',
                    onPressed: () => _showDeleteConfirmation(product),
                  ),
                ],
              ),
            ];
          }).toList(),
          smallHeaderWidth: 40,
          largeHeaderWidth: 90,
        );
      },
    );
  }
}
