// lib/screens/inventory_management/widgets/item_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/design_constants.dart';

/// Dialog for adding or editing an inventory item with recipe
class ItemFormDialog extends StatefulWidget {
  final Item? item;
  final int organizationId;
  final List<Ingredient> availableIngredients;
  final List<Category> categories;
  final List<RecipeIngredient>? existingRecipe;
  final Function(ItemsCompanion item, List<RecipeIngredientData> recipe) onSave;

  const ItemFormDialog({
    super.key,
    this.item,
    required this.organizationId,
    required this.availableIngredients,
    required this.categories,
    this.existingRecipe,
    required this.onSave,
  });

  @override
  State<ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _criticalLevelController = TextEditingController();

  static const _uuid = Uuid();

  int? _selectedCategoryId;
  List<RecipeIngredientData> _recipeIngredients = [];
  double _calculatedCost = 0.0;

  bool get isEditing => widget.item != null;

  // Number formatter for thousands separator
  final NumberFormat _numberFormat = NumberFormat('#,##0.##');

  String _formatWithCommas(String value) {
    if (value.isEmpty) return value;
    // Remove commas and get only digits (and decimal point)
    final cleanValue = value.replaceAll(',', '');
    // Extract digits only (before decimal) to check length
    final parts = cleanValue.split('.');
    final integerPart = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
    // Limit to 8 digits
    if (integerPart.length > 8) {
      final truncatedInt = integerPart.substring(0, 8);
      final truncatedValue = parts.length > 1 ? '$truncatedInt.${parts[1]}' : truncatedInt;
      final number = double.tryParse(truncatedValue);
      if (number == null) return value;
      return _numberFormat.format(number);
    }
    final number = double.tryParse(cleanValue);
    if (number == null) return value;
    return _numberFormat.format(number);
  }

  String _removeCommas(String value) {
    return value.replaceAll(',', '');
  }

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _descriptionController.text = widget.item!.description ?? '';
      _priceController.text = _formatWithCommas((widget.item!.price ?? 0).toString());
      _stockController.text = _formatWithCommas(widget.item!.stock.toString());
      _criticalLevelController.text = _formatWithCommas((widget.item!.minimumStock ?? 0).toString());
      _selectedCategoryId = widget.item!.categoryId;

      // Load existing recipe
      if (widget.existingRecipe != null) {
        _recipeIngredients = widget.existingRecipe!.map((ri) {
          final ingredient = widget.availableIngredients
              .where((i) => i.id == ri.ingredientId)
              .firstOrNull;
          return RecipeIngredientData(
            ingredientId: ri.ingredientId,
            quantity: ri.quantityNeeded,
            ingredientName: ingredient?.name ?? 'Unknown',
            unit: ingredient?.unit ?? '',
            costPerUnit: 0,
          );
        }).toList();
        _calculateCost();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _criticalLevelController.dispose();
    super.dispose();
  }

  void _calculateCost() {
    double cost = 0.0;
    for (final ingredient in _recipeIngredients) {
      cost += ingredient.quantity * ingredient.costPerUnit;
    }
    setState(() {
      _calculatedCost = cost;
    });
  }

  void _addIngredient() {
    showDialog(
      context: context,
      builder: (context) => _AddIngredientToRecipeDialog(
        availableIngredients: widget.availableIngredients
            .where((i) => !_recipeIngredients.any((r) => r.ingredientId == i.id))
            .toList(),
        onAdd: (ingredientId, quantity) {
          final ingredient = widget.availableIngredients
              .firstWhere((i) => i.id == ingredientId);
          setState(() {
            _recipeIngredients.add(RecipeIngredientData(
              ingredientId: ingredientId,
              quantity: quantity,
              ingredientName: ingredient.name,
              unit: ingredient.unit,
              costPerUnit: 0,
            ));
            _calculateCost();
          });
        },
      ),
    );
  }

  void _editIngredient(int index) {
    final ingredient = _recipeIngredients[index];
    final quantityController = TextEditingController(
      text: ingredient.quantity.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${ingredient.ingredientName}'),
        content: TextField(
          controller: quantityController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Quantity (${ingredient.unit})',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newQuantity = double.tryParse(quantityController.text);
              if (newQuantity != null && newQuantity > 0) {
                setState(() {
                  _recipeIngredients[index] = RecipeIngredientData(
                    ingredientId: ingredient.ingredientId,
                    quantity: newQuantity,
                    ingredientName: ingredient.ingredientName,
                    unit: ingredient.unit,
                    costPerUnit: ingredient.costPerUnit,
                  );
                  _calculateCost();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _removeIngredient(int index) {
    setState(() {
      _recipeIngredients.removeAt(index);
      _calculateCost();
    });
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final companion = ItemsCompanion(
      id: isEditing ? Value(widget.item!.id) : const Value.absent(),
      cloudId: isEditing ? Value(widget.item!.cloudId) : Value(_uuid.v4()),
      name: Value(_nameController.text.trim()),
      description: Value(_descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim()),
      price: Value(double.tryParse(_removeCommas(_priceController.text)) ?? 0),
      costPrice: Value(_calculatedCost),
      stock: Value(int.tryParse(_removeCommas(_stockController.text)) ?? 0),
      minimumStock: Value(int.tryParse(_removeCommas(_criticalLevelController.text)) ?? 10),
      categoryId: Value(_selectedCategoryId),
      organizationId: Value(widget.organizationId),
      isDeleted: const Value(false),
      isSynced: const Value(false),
    );

    widget.onSave(companion, _recipeIngredients);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final priceValue = double.tryParse(_removeCommas(_priceController.text)) ?? 0;
    final profitMargin = priceValue - _calculatedCost;
    final profitPercentage = priceValue > 0
        ? (profitMargin / priceValue) * 100
        : 0;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        isEditing ? Icons.edit : Icons.add_box,
                        color: Colors.blue,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditing ? 'Edit Product' : 'Add Product',
                        style: const TextStyle(
                          fontFamily: fontAll,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Basic Info Section
                  const Text(
                    'Product Information',
                    style: TextStyle(
                      fontFamily: fontAll,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name *',
                      hintText: 'e.g., Fried Chicken Meal',
                      prefixIcon: Icon(Icons.fastfood),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter product name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Product description...',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category dropdown
                  DropdownButtonFormField<int?>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category (Optional)',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('No Category'),
                      ),
                      ...widget.categories.map(
                        (cat) => DropdownMenuItem<int?>(
                          value: cat.id,
                          child: Text(cat.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Price and Stock row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[\d,.]'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Selling Price *',
                            hintText: '0',
                            prefixText: '? ',
                            prefixIcon: Icon(Icons.sell),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            final cursorPosition = _priceController.selection.baseOffset;
                            final oldLength = value.length;
                            final formatted = _formatWithCommas(value);
                            if (formatted != value) {
                              _priceController.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(
                                  offset: cursorPosition + (formatted.length - oldLength),
                                ),
                              );
                            }
                            setState(() {});
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter price';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[\d,]'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Current Stock',
                            hintText: '0',
                            prefixIcon: Icon(Icons.inventory),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            final cursorPosition = _stockController.selection.baseOffset;
                            final oldLength = value.length;
                            final formatted = _formatWithCommas(value);
                            if (formatted != value) {
                              _stockController.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(
                                  offset: cursorPosition + (formatted.length - oldLength),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _criticalLevelController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[\d,]'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Critical Level',
                            hintText: '10',
                            prefixIcon: Icon(Icons.warning),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            final cursorPosition = _criticalLevelController.selection.baseOffset;
                            final oldLength = value.length;
                            final formatted = _formatWithCommas(value);
                            if (formatted != value) {
                              _criticalLevelController.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(
                                  offset: cursorPosition + (formatted.length - oldLength),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recipe Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recipe Composition',
                        style: TextStyle(
                          fontFamily: fontAll,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: widget.availableIngredients.isEmpty
                            ? null
                            : _addIngredient,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Ingredient'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Recipe ingredients list
                  if (_recipeIngredients.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Center(
                        child: Text(
                          'No ingredients added yet.\nAdd ingredients to define the recipe.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
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
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Quantity',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Cost',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                SizedBox(width: 80),
                              ],
                            ),
                          ),
                          // Ingredients list
                          ...List.generate(_recipeIngredients.length, (index) {
                            final ingredient = _recipeIngredients[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey[200]!),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(ingredient.ingredientName),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${ingredient.quantity} ${ingredient.unit}',
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '?${ingredient.totalCost.toStringAsFixed(2)}',
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 18,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () => _editIngredient(index),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => _removeIngredient(index),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
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
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Cost:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '?${_calculatedCost.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blue,
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
                              '?${(double.tryParse(_priceController.text) ?? 0).toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Profit Margin:'),
                            Text(
                              '?${profitMargin.toStringAsFixed(2)} (${profitPercentage.toStringAsFixed(1)}%)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: profitMargin >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _handleSave,
                        icon: Icon(isEditing ? Icons.save : Icons.add),
                        label: Text(isEditing ? 'Save Changes' : 'Add Product'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Data class for recipe ingredients
class RecipeIngredientData {
  final int ingredientId;
  final double quantity;
  final String ingredientName;
  final String unit;
  final double costPerUnit;

  RecipeIngredientData({
    required this.ingredientId,
    required this.quantity,
    required this.ingredientName,
    required this.unit,
    required this.costPerUnit,
  });

  double get totalCost => quantity * costPerUnit;
}

/// Dialog for adding an ingredient to recipe
class _AddIngredientToRecipeDialog extends StatefulWidget {
  final List<Ingredient> availableIngredients;
  final Function(int ingredientId, double quantity) onAdd;

  const _AddIngredientToRecipeDialog({
    required this.availableIngredients,
    required this.onAdd,
  });

  @override
  State<_AddIngredientToRecipeDialog> createState() =>
      _AddIngredientToRecipeDialogState();
}

class _AddIngredientToRecipeDialogState
    extends State<_AddIngredientToRecipeDialog> {
  int? _selectedIngredientId;
  final _quantityController = TextEditingController();

  // Number formatter for thousands separator
  final NumberFormat _numberFormat = NumberFormat('#,##0.##');

  String _formatWithCommas(String value) {
    if (value.isEmpty) return value;
    final cleanValue = value.replaceAll(',', '');
    final parts = cleanValue.split('.');
    final integerPart = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
    if (integerPart.length > 8) {
      final truncatedInt = integerPart.substring(0, 8);
      final truncatedValue = parts.length > 1 ? '$truncatedInt.${parts[1]}' : truncatedInt;
      final number = double.tryParse(truncatedValue);
      if (number == null) return value;
      return _numberFormat.format(number);
    }
    final number = double.tryParse(cleanValue);
    if (number == null) return value;
    return _numberFormat.format(number);
  }

  String _removeCommas(String value) {
    return value.replaceAll(',', '');
  }

  Ingredient? get _selectedIngredient => widget.availableIngredients
      .where((i) => i.id == _selectedIngredientId)
      .firstOrNull;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Ingredient to Recipe'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: _selectedIngredientId,
              decoration: const InputDecoration(
                labelText: 'Select Ingredient',
                border: OutlineInputBorder(),
              ),
              items: widget.availableIngredients.map((ingredient) {
                return DropdownMenuItem<int>(
                  value: ingredient.id,
                  child: Text(
                    '${ingredient.name} (${ingredient.unit})',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedIngredientId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
              ],
              onChanged: (value) {
                final cursorPosition = _quantityController.selection.baseOffset;
                final oldLength = value.length;
                final formatted = _formatWithCommas(value);
                if (formatted != value) {
                  _quantityController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: cursorPosition + (formatted.length - oldLength),
                    ),
                  );
                }
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'Quantity',
                suffixText: _selectedIngredient?.unit ?? '',
                border: const OutlineInputBorder(),
              ),
            ),
            if (_selectedIngredient != null &&
                _quantityController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Cost contribution:'),
                    Text(
                      '${(double.tryParse(_removeCommas(_quantityController.text)) ?? 0).toStringAsFixed(2)} ${_selectedIngredient!.unit}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedIngredientId != null &&
                  _quantityController.text.isNotEmpty
              ? () {
                  final quantity = double.tryParse(_removeCommas(_quantityController.text));
                  if (quantity != null && quantity > 0) {
                    widget.onAdd(_selectedIngredientId!, quantity);
                    Navigator.pop(context);
                  }
                }
              : null,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
