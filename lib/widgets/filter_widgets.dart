// lib/widgets/filter_widgets.dart
import 'package:flutter/material.dart';

/// Generic sort order enum
enum SortOrder { asc, desc }

/// A universal filter/sort popup menu button that can be used across different screens
class UniversalFilterButton<T> extends StatelessWidget {
  /// The current selected value
  final T? currentValue;

  /// Callback when a value is selected
  final ValueChanged<T> onSelected;

  /// The list of filter options
  final List<FilterOption<T>> options;

  /// Icon to display (defaults to filter_list)
  final IconData icon;

  /// Icon size
  final double iconSize;

  /// Tooltip text
  final String? tooltip;

  /// Icon color
  final Color? iconColor;

  const UniversalFilterButton({
    super.key,
    this.currentValue,
    required this.onSelected,
    required this.options,
    this.icon = Icons.filter_list,
    this.iconSize = 28,
    this.tooltip,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      icon: Icon(icon, size: iconSize, color: iconColor),
      tooltip: tooltip ?? 'Sort & Filter',
      onSelected: onSelected,
      itemBuilder: (context) {
        final items = <PopupMenuEntry<T>>[];

        for (int i = 0; i < options.length; i++) {
          final option = options[i];

          if (option.isDivider) {
            items.add(const PopupMenuDivider());
          } else if (option.isHeader) {
            items.add(
              PopupMenuItem<T>(
                enabled: false,
                height: 32,
                child: Text(
                  option.label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
            );
          } else {
            final isSelected = currentValue == option.value;
            items.add(
              PopupMenuItem<T>(
                value: option.value,
                child: Row(
                  children: [
                    if (option.icon != null) ...[
                      Icon(
                        option.icon,
                        size: 18,
                        color: isSelected ? Theme.of(context).primaryColor : null,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Theme.of(context).primaryColor : null,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check,
                        size: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                  ],
                ),
              ),
            );
          }
        }

        return items;
      },
    );
  }
}

/// Represents a single filter option
class FilterOption<T> {
  final T? value;
  final String label;
  final IconData? icon;
  final bool isDivider;
  final bool isHeader;

  const FilterOption({
    this.value,
    required this.label,
    this.icon,
    this.isDivider = false,
    this.isHeader = false,
  });

  /// Create a divider
  const FilterOption.divider()
      : value = null,
        label = '',
        icon = null,
        isDivider = true,
        isHeader = false;

  /// Create a header/section title
  const FilterOption.header(this.label)
      : value = null,
        icon = null,
        isDivider = false,
        isHeader = true;
}

/// A toggle filter chip for boolean filters (e.g., "Low Stock Only")
class FilterChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  const FilterChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Colors.orange,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.grey[700],
      ),
    );
  }
}

/// A category filter dropdown
class CategoryFilterDropdown extends StatelessWidget {
  final int? selectedCategoryId;
  final List<CategoryOption> categories;
  final ValueChanged<int?> onChanged;
  final String allCategoriesLabel;

  const CategoryFilterDropdown({
    super.key,
    this.selectedCategoryId,
    required this.categories,
    required this.onChanged,
    this.allCategoriesLabel = 'All Categories',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: selectedCategoryId,
          hint: Text(allCategoriesLabel),
          isExpanded: false,
          icon: const Icon(Icons.arrow_drop_down),
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Text(allCategoriesLabel),
            ),
            ...categories.map(
              (cat) => DropdownMenuItem<int?>(
                value: cat.id,
                child: Text(cat.name),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Represents a category option
class CategoryOption {
  final int id;
  final String name;

  const CategoryOption({required this.id, required this.name});
}

/// A filter bar that combines multiple filter controls
class UniversalFilterBar extends StatelessWidget {
  final List<Widget> filters;
  final MainAxisAlignment alignment;
  final double spacing;

  const UniversalFilterBar({
    super.key,
    required this.filters,
    this.alignment = MainAxisAlignment.end,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: spacing,
      runSpacing: spacing,
      children: filters,
    );
  }
}

// ============================================================================
// PREDEFINED FILTER OPTIONS FOR COMMON USE CASES
// ============================================================================

/// Predefined sort options for ingredients
class IngredientSortOptions {
  static List<FilterOption<String>> get all => const [
        FilterOption.header('SORT BY NAME'),
        FilterOption(value: 'nameAsc', label: 'Name (A–Z)', icon: Icons.sort_by_alpha),
        FilterOption(value: 'nameDesc', label: 'Name (Z–A)', icon: Icons.sort_by_alpha),
        FilterOption.divider(),
        FilterOption.header('SORT BY STOCK'),
        FilterOption(value: 'stockAsc', label: 'Stock (Low → High)', icon: Icons.inventory_2),
        FilterOption(value: 'stockDesc', label: 'Stock (High → Low)', icon: Icons.inventory_2),
        FilterOption.divider(),
        FilterOption.header('SORT BY COST'),
        FilterOption(value: 'costAsc', label: 'Cost (Low → High)', icon: Icons.attach_money),
        FilterOption(value: 'costDesc', label: 'Cost (High → Low)', icon: Icons.attach_money),
        FilterOption.divider(),
        FilterOption.header('SORT BY DATE'),
        FilterOption(value: 'newestFirst', label: 'Newest First', icon: Icons.schedule),
        FilterOption(value: 'oldestFirst', label: 'Oldest First', icon: Icons.history),
      ];
}

/// Predefined sort options for products/items
class ProductSortOptions {
  static List<FilterOption<String>> get all => const [
        FilterOption.header('SORT BY NAME'),
        FilterOption(value: 'nameAsc', label: 'Name (A–Z)', icon: Icons.sort_by_alpha),
        FilterOption(value: 'nameDesc', label: 'Name (Z–A)', icon: Icons.sort_by_alpha),
        FilterOption.divider(),
        FilterOption.header('SORT BY STOCK'),
        FilterOption(value: 'stockAsc', label: 'Stock (Low → High)', icon: Icons.inventory_2),
        FilterOption(value: 'stockDesc', label: 'Stock (High → Low)', icon: Icons.inventory_2),
        FilterOption.divider(),
        FilterOption.header('SORT BY PRICE'),
        FilterOption(value: 'priceAsc', label: 'Price (Low → High)', icon: Icons.sell),
        FilterOption(value: 'priceDesc', label: 'Price (High → Low)', icon: Icons.sell),
        FilterOption.divider(),
        FilterOption.header('SORT BY COST'),
        FilterOption(value: 'costAsc', label: 'Cost (Low → High)', icon: Icons.attach_money),
        FilterOption(value: 'costDesc', label: 'Cost (High → Low)', icon: Icons.attach_money),
        FilterOption.divider(),
        FilterOption.header('SORT BY DATE'),
        FilterOption(value: 'newestFirst', label: 'Newest First', icon: Icons.schedule),
        FilterOption(value: 'oldestFirst', label: 'Oldest First', icon: Icons.history),
      ];
}

/// Predefined sort options for requests
class RequestSortOptions {
  static List<FilterOption<String>> get all => const [
        FilterOption.header('SORT BY DATE'),
        FilterOption(value: 'newestFirst', label: 'Newest First', icon: Icons.schedule),
        FilterOption(value: 'oldestFirst', label: 'Oldest First', icon: Icons.history),
        FilterOption.divider(),
        FilterOption.header('SORT BY QUANTITY'),
        FilterOption(value: 'quantityAsc', label: 'Quantity (Low → High)', icon: Icons.inventory),
        FilterOption(value: 'quantityDesc', label: 'Quantity (High → Low)', icon: Icons.inventory),
        FilterOption.divider(),
        FilterOption.header('SORT BY STATUS'),
        FilterOption(value: 'statusPending', label: 'Pending First', icon: Icons.pending),
        FilterOption(value: 'statusApproved', label: 'Approved First', icon: Icons.check_circle),
      ];
}

/// Predefined sort options for branches
class BranchSortOptions {
  static List<FilterOption<String>> get all => const [
        FilterOption.header('SORT BY NAME'),
        FilterOption(value: 'nameAsc', label: 'Name (A–Z)', icon: Icons.sort_by_alpha),
        FilterOption(value: 'nameDesc', label: 'Name (Z–A)', icon: Icons.sort_by_alpha),
        FilterOption.divider(),
        FilterOption.header('SORT BY STATUS'),
        FilterOption(value: 'activeFirst', label: 'Active First', icon: Icons.check_circle),
        FilterOption(value: 'inactiveFirst', label: 'Inactive First', icon: Icons.cancel),
        FilterOption.divider(),
        FilterOption.header('SORT BY DATE'),
        FilterOption(value: 'newestFirst', label: 'Newest First', icon: Icons.schedule),
        FilterOption(value: 'oldestFirst', label: 'Oldest First', icon: Icons.history),
      ];
}
