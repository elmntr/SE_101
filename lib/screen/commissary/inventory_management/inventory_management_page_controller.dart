// lib/screens/inventory_management/inventory_management_page_controller.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/database/daos/ingredients_dao.dart';
import 'package:chickenjoo_inventory/database/daos/items_dao.dart';

/// Controller for InventoryManagementPage
/// Holds all UI state and business logic for inventory tab management
class InventoryManagementPageController {
  final VoidCallback onStateChanged;

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

  InventoryManagementPageController({required this.onStateChanged});

  void dispose() {
    searchController.dispose();
  }

  void onSearchChanged(String query) {
    searchQuery = query;
    onStateChanged();
  }

  // Sort/Filter methods for Ingredients
  void setIngredientSortOrder(IngredientSortOrder order) {
    ingredientSortOrder = order;
    onStateChanged();
  }

  void toggleLowStockIngredients(bool value) {
    showLowStockIngredientsOnly = value;
    onStateChanged();
  }

  // Sort/Filter methods for Products
  void setProductSortOrder(ItemSortOrder order) {
    productSortOrder = order;
    onStateChanged();
  }

  void toggleLowStockProducts(bool value) {
    showLowStockProductsOnly = value;
    onStateChanged();
  }

  void setSelectedCategory(int? categoryId) {
    selectedCategoryId = categoryId;
    onStateChanged();
  }

  void setSelectedTab(int index) {
    selectedTab = index;
    onStateChanged();
  }

  void setHasIngredients(bool value) {
    if (hasIngredients != value) {
      hasIngredients = value;
      onStateChanged();
    }
  }

  void setHasProducts(bool value) {
    if (hasProducts != value) {
      hasProducts = value;
      onStateChanged();
    }
  }
}
