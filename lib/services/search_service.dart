// lib/services/search_service.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';

/// A universal search service that provides search functionality across different
/// screens and data types in the application.
///
/// This service supports:
/// - Items (inventory items with branch stock)
/// - Products (commissary products)
/// - Employees
/// - Categories
/// - Stock changes
/// - Any custom searchable data
///
/// Usage:
/// ```dart
/// // Filter a list of items
/// final results = SearchService.filterItems(items, 'chicken');
///
/// // Use the search widget
/// UniversalSearchBar(
///   controller: searchController,
///   onSearch: (query) => setState(() => searchQuery = query),
///   hintText: 'Search items...',
/// )
/// ```

class SearchService {
  /// Private constructor to prevent instantiation
  SearchService._();

  // ============================================================================
  // GENERIC SEARCH METHODS
  // ============================================================================

  /// Generic filter method that works with any list and custom search logic
  ///
  /// [items] - The list to filter
  /// [query] - The search query
  /// [searchFields] - Function that extracts searchable fields from each item
  ///
  /// Example:
  /// ```dart
  /// final results = SearchService.filter(
  ///   users,
  ///   'john',
  ///   (user) => [user.name, user.email],
  /// );
  /// ```
  static List<T> filter<T>(
    List<T> items,
    String query,
    List<String?> Function(T item) searchFields,
  ) {
    if (query.isEmpty) return items;

    final lowerQuery = query.toLowerCase().trim();
    if (lowerQuery.isEmpty) return items;

    return items.where((item) {
      final fields = searchFields(item);
      return fields.any((field) {
        if (field == null || field.isEmpty) return false;
        return field.toLowerCase().contains(lowerQuery);
      });
    }).toList();
  }

  /// Multi-word search that matches all words in the query
  ///
  /// Example: "chicken breast" matches items containing both "chicken" AND "breast"
  static List<T> filterAllWords<T>(
    List<T> items,
    String query,
    List<String?> Function(T item) searchFields,
  ) {
    if (query.isEmpty) return items;

    final words = query.toLowerCase().trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return items;

    return items.where((item) {
      final fields = searchFields(item);
      final combinedText = fields
          .where((f) => f != null && f.isNotEmpty)
          .map((f) => f!.toLowerCase())
          .join(' ');

      return words.every((word) => combinedText.contains(word));
    }).toList();
  }

  /// Search with scoring - returns results sorted by relevance
  ///
  /// [primaryFields] - Fields with higher priority (e.g., name)
  /// [secondaryFields] - Fields with lower priority (e.g., description)
  static List<T> filterWithRelevance<T>(
    List<T> items,
    String query, {
    required List<String?> Function(T item) primaryFields,
    List<String?> Function(T item)? secondaryFields,
  }) {
    if (query.isEmpty) return items;

    final lowerQuery = query.toLowerCase().trim();
    if (lowerQuery.isEmpty) return items;

    final scored = <_ScoredItem<T>>[];

    for (final item in items) {
      int score = 0;

      // Check primary fields (higher weight)
      final primary = primaryFields(item);
      for (final field in primary) {
        if (field == null || field.isEmpty) continue;
        final lower = field.toLowerCase();

        if (lower == lowerQuery) {
          score += 100; // Exact match
        } else if (lower.startsWith(lowerQuery)) {
          score += 50; // Starts with query
        } else if (lower.contains(lowerQuery)) {
          score += 25; // Contains query
        }
      }

      // Check secondary fields (lower weight)
      if (secondaryFields != null) {
        final secondary = secondaryFields(item);
        for (final field in secondary) {
          if (field == null || field.isEmpty) continue;
          final lower = field.toLowerCase();

          if (lower.contains(lowerQuery)) {
            score += 10; // Contains in secondary field
          }
        }
      }

      if (score > 0) {
        scored.add(_ScoredItem(item, score));
      }
    }

    // Sort by score (highest first)
    scored.sort((a, b) => b.score.compareTo(a.score));

    return scored.map((s) => s.item).toList();
  }

  // ============================================================================
  // SPECIALIZED SEARCH METHODS FOR COMMON DATA TYPES
  // ============================================================================

  /// Filter items by name, description, or category
  ///
  /// Works with any item that has these common properties via a getter function
  static List<T> filterItems<T>(
    List<T> items,
    String query, {
    required String Function(T) getName,
    String? Function(T)? getDescription,
    String? Function(T)? getCategoryName,
  }) {
    return filter(
      items,
      query,
      (item) => [
        getName(item),
        if (getDescription != null) getDescription(item),
        if (getCategoryName != null) getCategoryName(item),
      ],
    );
  }

  /// Filter employees by name, email, or role
  static List<T> filterEmployees<T>(
    List<T> employees,
    String query, {
    required String Function(T) getName,
    String? Function(T)? getEmail,
    String? Function(T)? getRole,
  }) {
    return filter(
      employees,
      query,
      (employee) => [
        getName(employee),
        if (getEmail != null) getEmail(employee),
        if (getRole != null) getRole(employee),
      ],
    );
  }

  /// Filter categories by name or description
  static List<T> filterCategories<T>(
    List<T> categories,
    String query, {
    required String Function(T) getName,
    String? Function(T)? getDescription,
  }) {
    return filter(
      categories,
      query,
      (category) => [
        getName(category),
        if (getDescription != null) getDescription(category),
      ],
    );
  }

  /// Filter stock changes by item name, employee name, or notes
  static List<T> filterStockChanges<T>(
    List<T> changes,
    String query, {
    required String Function(T) getItemName,
    String? Function(T)? getEmployeeName,
    String? Function(T)? getNotes,
  }) {
    return filter(
      changes,
      query,
      (change) => [
        getItemName(change),
        if (getEmployeeName != null) getEmployeeName(change),
        if (getNotes != null) getNotes(change),
      ],
    );
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Highlights matching text in a string
  ///
  /// Returns a list of TextSpans with highlighted portions
  static List<TextSpan> highlightMatches(
    String text,
    String query, {
    TextStyle? normalStyle,
    TextStyle? highlightStyle,
  }) {
    if (query.isEmpty) {
      return [TextSpan(text: text, style: normalStyle)];
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        // No more matches, add remaining text
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start), style: normalStyle));
        }
        break;
      }

      // Add text before match
      if (index > start) {
        spans.add(
          TextSpan(text: text.substring(start, index), style: normalStyle),
        );
      }

      // Add highlighted match
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style:
              highlightStyle ??
              const TextStyle(
                backgroundColor: searchHighlight,
                fontWeight: FontWeight.bold,
              ),
        ),
      );

      start = index + query.length;
    }

    return spans.isEmpty ? [TextSpan(text: text, style: normalStyle)] : spans;
  }

  /// Checks if a string matches the search query
  static bool matches(String? text, String query) {
    if (text == null || text.isEmpty) return false;
    if (query.isEmpty) return true;
    return text.toLowerCase().contains(query.toLowerCase());
  }

  /// Debounce helper for search input
  /// Returns a function that will call [action] after [delay] if not called again
  static void Function(String) debounce(
    void Function(String) action,
    Duration delay,
  ) {
    int lastCallTime = 0;

    return (String query) {
      final callTime = DateTime.now().millisecondsSinceEpoch;
      lastCallTime = callTime;

      Future.delayed(delay, () {
        if (lastCallTime == callTime) {
          action(query);
        }
      });
    };
  }
}

/// Internal class for scoring search results
class _ScoredItem<T> {
  final T item;
  final int score;

  _ScoredItem(this.item, this.score);
}

// ============================================================================
// UNIVERSAL SEARCH BAR WIDGET
// ============================================================================

/// A reusable search bar widget that can be used across different screens
class UniversalSearchBar extends StatelessWidget {
  /// Text editing controller for the search field
  final TextEditingController controller;

  /// Callback when search query changes
  final ValueChanged<String>? onSearch;

  /// Callback when search is submitted (e.g., pressing Enter)
  final ValueChanged<String>? onSubmitted;

  /// Placeholder text
  final String hintText;

  /// Whether to show the clear button
  final bool showClearButton;

  /// Whether to auto-focus the search field
  final bool autofocus;

  /// Custom decoration for the search bar container
  final BoxDecoration? decoration;

  /// Height of the search bar
  final double height;

  /// Padding inside the search bar
  final EdgeInsets contentPadding;

  /// Prefix icon
  final IconData prefixIcon;

  /// Custom prefix widget (overrides prefixIcon)
  final Widget? prefix;

  /// Custom suffix widget
  final Widget? suffix;

  /// Text style for the search input
  final TextStyle? textStyle;

  /// Text style for the hint text
  final TextStyle? hintStyle;

  /// Debounce duration for search callback (set to Duration.zero to disable)
  final Duration debounceDuration;

  const UniversalSearchBar({
    super.key,
    required this.controller,
    this.onSearch,
    this.onSubmitted,
    this.hintText = 'Search...',
    this.showClearButton = true,
    this.autofocus = false,
    this.decoration,
    this.height = 42,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 12),
    this.prefixIcon = Icons.search,
    this.prefix,
    this.suffix,
    this.textStyle,
    this.hintStyle,
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: contentPadding,
      decoration:
          decoration ??
          AppDecorations.searchBar,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        style: textStyle,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintStyle ?? const TextStyle(color: textMuted),
          icon: prefix ?? Icon(prefixIcon, color: textMuted),
          border: InputBorder.none,
          suffixIcon: _buildSuffixIcon(),
        ),
        onChanged: _handleSearch,
        onSubmitted: onSubmitted,
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (suffix != null) return suffix;

    if (showClearButton) {
      return ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          if (value.text.isEmpty) return const SizedBox.shrink();
          return IconButton(
            icon: const Icon(Icons.clear, color: textMuted, size: iconSizeMd),
            onPressed: () {
              controller.clear();
              onSearch?.call('');
            },
          );
        },
      );
    }

    return null;
  }

  void _handleSearch(String query) {
    if (onSearch == null) return;

    if (debounceDuration == Duration.zero) {
      onSearch!(query);
    } else {
      // Simple inline debounce
      Future.delayed(debounceDuration, () {
        if (controller.text == query) {
          onSearch!(query);
        }
      });
    }
  }
}

// ============================================================================
// SEARCH CONTROLLER MIXIN
// ============================================================================

/// A mixin that provides common search functionality for StatefulWidgets
///
/// Usage:
/// ```dart
/// class MyScreenState extends State<MyScreen> with SearchControllerMixin {
///   @override
///   void dispose() {
///     disposeSearchController();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     final filteredItems = SearchService.filter(
///       allItems,
///       searchQuery,
///       (item) => [item.name],
///     );
///     // ...
///   }
/// }
/// ```
mixin SearchControllerMixin<T extends StatefulWidget> on State<T> {
  /// The search query text
  String searchQuery = '';

  /// Controller for the search text field
  late final TextEditingController searchController;

  /// Initialize the search controller (call in initState)
  void initSearchController() {
    searchController = TextEditingController();
    searchController.addListener(_onSearchChanged);
  }

  /// Dispose the search controller (call in dispose)
  void disposeSearchController() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {
        searchQuery = searchController.text;
      });
    }
  }

  /// Update the search query programmatically
  void updateSearchQuery(String query) {
    searchController.text = query;
  }

  /// Clear the search
  void clearSearch() {
    searchController.clear();
  }

  /// Build a search bar with default settings
  Widget buildSearchBar({
    String hintText = 'Search...',
    ValueChanged<String>? onSearch,
  }) {
    return UniversalSearchBar(
      controller: searchController,
      hintText: hintText,
      onSearch:
          onSearch ??
          (query) {
            setState(() {
              searchQuery = query;
            });
          },
    );
  }
}
