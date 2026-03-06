// lib/screens/inventory_management/ingredients_tab.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/database/daos/ingredients_dao.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/utils/tables.dart';
import 'widgets/ingredient_form_dialog.dart';

/// Ingredients tab for managing raw materials/ingredients
class IngredientsTab extends StatefulWidget {
  final int commissaryId;
  final ValueChanged<bool>? onItemsChanged;
  final String searchQuery;
  final IngredientSortOrder sortOrder;
  final bool showLowStockOnly;

  const IngredientsTab({
    super.key,
    required this.commissaryId,
    this.onItemsChanged,
    this.searchQuery = '',
    this.sortOrder = IngredientSortOrder.nameAsc,
    this.showLowStockOnly = false,
  });

  @override
  State<IngredientsTab> createState() => _IngredientsTabState();
}

class _IngredientsTabState extends State<IngredientsTab> {
  @override
  void dispose() {
    super.dispose();
  }

  void _showAddIngredientDialog() {
    showDialog(
      context: context,
      builder: (context) => IngredientFormDialog(
        commissaryId: widget.commissaryId,
        onSave: (companion) async {
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
        },
      ),
    );
  }

  void _showEditIngredientDialog(Ingredient ingredient) {
    showDialog(
      context: context,
      builder: (context) => IngredientFormDialog(
        ingredient: ingredient,
        commissaryId: widget.commissaryId,
        onSave: (companion) async {
          final updated = Ingredient(
            id: ingredient.id,
            cloudId: companion.cloudId.value,
            name: companion.name.value,
            unit: companion.unit.value,
            stock: companion.stock.value,
            costPerUnit: companion.costPerUnit.value,
            criticalLevel: companion.criticalLevel.value,
            commissaryId: companion.commissaryId.value,
            isActive: companion.isActive.value,
            createdAt: ingredient.createdAt,
            updatedAt: DateTime.now(),
            lastUpdated: DateTime.now(),
            lastSyncedAt: ingredient.lastSyncedAt,
            needsSync: true,
          );
          await database.ingredientsDao.updateIngredient(updated);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ingredient updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(Ingredient ingredient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ingredient'),
        content: Text(
          'Are you sure you want to delete "${ingredient.name}"?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await database.ingredientsDao.softDeleteIngredient(ingredient.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${ingredient.name} deleted'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAdjustStockDialog(Ingredient ingredient) {
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
              Expanded(child: Text('Adjust Stock: ${ingredient.name}')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Stock: ${ingredient.stock.toStringAsFixed(2)} ${ingredient.unit}',
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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Quantity (${ingredient.unit})',
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
                final quantity = double.tryParse(controller.text);
                if (quantity != null && quantity > 0) {
                  final newStock = isAdding
                      ? ingredient.stock + quantity
                      : ingredient.stock - quantity;
                  await database.ingredientsDao.updateStock(
                    ingredient.id,
                    newStock,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${isAdding ? "Added" : "Removed"} ${quantity.toStringAsFixed(2)} ${ingredient.unit}',
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Ingredient>>(
      stream: database.ingredientsDao.watchAllIngredients(
        commissaryId: widget.commissaryId,
      ),
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

        var ingredients = snapshot.data ?? [];

        // Notify parent about items count
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.onItemsChanged?.call(ingredients.isNotEmpty);
          }
        });

        // Apply search filter
        if (widget.searchQuery.isNotEmpty) {
          ingredients = ingredients
              .where(
                (i) => i.name.toLowerCase().contains(
                  widget.searchQuery.toLowerCase(),
                ),
              )
              .toList();
        }

        // Apply low stock filter
        if (widget.showLowStockOnly) {
          ingredients = ingredients
              .where((i) => i.stock <= (i.criticalLevel ?? 0))
              .toList();
        }

        // Apply sorting
        ingredients.sort((a, b) {
          switch (widget.sortOrder) {
            case IngredientSortOrder.nameAsc:
              return a.name.compareTo(b.name);
            case IngredientSortOrder.nameDesc:
              return b.name.compareTo(a.name);
            case IngredientSortOrder.stockAsc:
              return a.stock.compareTo(b.stock);
            case IngredientSortOrder.stockDesc:
              return b.stock.compareTo(a.stock);
            case IngredientSortOrder.newestFirst:
              return b.createdAt.compareTo(a.createdAt);
            case IngredientSortOrder.oldestFirst:
              return a.createdAt.compareTo(b.createdAt);
          }
        });

        if (ingredients.isEmpty &&
            widget.searchQuery.isEmpty &&
            !widget.showLowStockOnly) {
          return emptyTables(
            message: 'You can manage your ingredients here.',
            onAddPressed: _showAddIngredientDialog,
            buttonType: EmptyButtonType.icon,
            buttonText: null,
          );
        }

        if (ingredients.isEmpty) {
          return const Center(
            child: Text(
              'No ingredients match your filters',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final numberFormat = NumberFormat('#,##0.##');
        return buildUniversalTable(
          headers: [
            'Name',
            'Stock',
            'Unit',
            'Cost/Unit',
            'Critical Level',
            'Status',
            '',
          ],
          rows: ingredients.map((ingredient) {
            final isLowStock = ingredient.stock <= (ingredient.criticalLevel ?? 0);
            return [
              Text(ingredient.name),
              Text(numberFormat.format(ingredient.stock)),
              Text(ingredient.unit),
              Text('₱${numberFormat.format(ingredient.costPerUnit)}'),
              Text(numberFormat.format(ingredient.criticalLevel ?? 0)),
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
                    icon: const Icon(Icons.inventory, size: 18),
                    tooltip: 'Adjust Stock',
                    onPressed: () => _showAdjustStockDialog(ingredient),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    tooltip: 'Edit',
                    onPressed: () => _showEditIngredientDialog(ingredient),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                    tooltip: 'Delete',
                    onPressed: () => _showDeleteConfirmation(ingredient),
                  ),
                ],
              ),
            ];
          }).toList(),
          smallHeaderWidth: 40,
          largeHeaderWidth: 90,
          showHorizontalScrollbar: Platform.isWindows,
          horizontalController:
              Platform.isWindows ? ScrollController() : null,
        );
      },
    );
  }
}
