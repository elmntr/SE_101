// lib/screens/inventory_management/widgets/ingredient_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/design_constants.dart';

/// Dialog for adding or editing an ingredient
class IngredientFormDialog extends StatefulWidget {
  final Ingredient? ingredient;
  final int commissaryId;
  final Function(IngredientsCompanion) onSave;

  const IngredientFormDialog({
    super.key,
    this.ingredient,
    required this.commissaryId,
    required this.onSave,
  });

  @override
  State<IngredientFormDialog> createState() => _IngredientFormDialogState();
}

class _IngredientFormDialogState extends State<IngredientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _stockController = TextEditingController();
  final _costController = TextEditingController();
  final _criticalLevelController = TextEditingController();

  static const _uuid = Uuid();

  bool get isEditing => widget.ingredient != null;

  // Common units
  final List<String> _commonUnits = [
    'grams',
    'kilograms',
    'milliliters',
    'liters',
    'pieces',
    'packs',
    'boxes',
    'bottles',
    'cans',
    'bags',
  ];

  // Number formatter for thousands separator
  static final _numberFormat = NumberFormat('#,##0.##');

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
    if (widget.ingredient != null) {
      _nameController.text = widget.ingredient!.name;
      _unitController.text = widget.ingredient!.unit;
      _stockController.text = _formatWithCommas(widget.ingredient!.stock.toString());
      _costController.text = _formatWithCommas(widget.ingredient!.costPerUnit.toString());
      _criticalLevelController.text = _formatWithCommas(widget.ingredient!.criticalLevel.toString());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _stockController.dispose();
    _costController.dispose();
    _criticalLevelController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final companion = IngredientsCompanion(
      id: isEditing ? Value(widget.ingredient!.id) : const Value.absent(),
      cloudId: isEditing 
          ? Value(widget.ingredient!.cloudId) 
          : Value(_uuid.v4()),
      name: Value(_nameController.text.trim()),
      unit: Value(_unitController.text.trim()),
      stock: Value(double.tryParse(_removeCommas(_stockController.text)) ?? 0),
      costPerUnit: Value(double.tryParse(_removeCommas(_costController.text)) ?? 0),
      criticalLevel: Value(double.tryParse(_removeCommas(_criticalLevelController.text)) ?? 10),
      commissaryId: Value(widget.commissaryId),
      isActive: const Value(true),
      needsSync: const Value(true),
    );

    widget.onSave(companion);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
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
                        isEditing ? Icons.edit : Icons.add_circle,
                        color: Colors.orange,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditing ? 'Edit Ingredient' : 'Add Ingredient',
                        style: const TextStyle(
                          fontFamily: fontAll,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Ingredient Name *',
                      hintText: 'e.g., Chicken Breast, Cooking Oil',
                      prefixIcon: Icon(Icons.inventory_2),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter ingredient name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Unit of measurement
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _unitController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Unit of Measurement *',
                            hintText: 'Select a unit',
                            prefixIcon: Icon(Icons.straighten),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please select a unit';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: PopupMenuButton<String>(
                          tooltip: 'Common units',
                          icon: const Icon(Icons.arrow_drop_down_circle),
                          onSelected: (unit) {
                            setState(() {
                              _unitController.text = unit;
                            });
                          },
                          itemBuilder: (context) => _commonUnits
                              .map((unit) => PopupMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Cost and Stock row
                  Row(
                    children: [
                      // Cost per unit
                      Expanded(
                        child: TextFormField(
                          controller: _costController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[\d,.]'),
                            ),
                          ],
                          onChanged: (value) {
                            final cursorPosition = _costController.selection.baseOffset;
                            final oldLength = value.length;
                            final formatted = _formatWithCommas(value);
                            if (formatted != value) {
                              _costController.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(
                                  offset: cursorPosition + (formatted.length - oldLength),
                                ),
                              );
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Cost per Unit *',
                            hintText: '0',
                            prefixText: '₱ ',
                            prefixIcon: Icon(Icons.attach_money),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter cost';
                            }
                            final cost = double.tryParse(value.replaceAll(',', ''));
                            if (cost == null || cost < 0) {
                              return 'Invalid cost';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Current stock
                      Expanded(
                        child: TextFormField(
                          controller: _stockController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[\d,.]'),
                            ),
                          ],
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
                          decoration: const InputDecoration(
                            labelText: 'Current Stock',
                            hintText: '0',
                            prefixIcon: Icon(Icons.inventory),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Critical level
                  TextFormField(
                    controller: _criticalLevelController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[\d,.]'),
                      ),
                    ],
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
                    decoration: const InputDecoration(
                      labelText: 'Critical Level (Low Stock Alert)',
                      hintText: '10',
                      helperText: 'Alert when stock falls below this level',
                      prefixIcon: Icon(Icons.warning_amber),
                      border: OutlineInputBorder(),
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
                        label: Text(isEditing ? 'Save Changes' : 'Add Ingredient'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
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
