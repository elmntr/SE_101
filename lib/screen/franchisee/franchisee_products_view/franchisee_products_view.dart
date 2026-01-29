// lib/screen/franchisee/franchisee_products_view/franchisee_products_view.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import '../../../database/app_database.dart';
import 'franchisee_products_view_mobile.dart';
import 'franchisee_products_view_desktop.dart';
import 'franchisee_products_view_controller.dart';

// Re-export for backward compatibility
export 'franchisee_products_view_controller.dart'
    show RecipeIngredientWithDetails;

/// Franchisee Products View Page
/// - View-only access to commissary products (no create/edit/delete)
/// - Shows recipe ingredients for each product
class FranchiseeProductsView extends StatefulWidget {
  const FranchiseeProductsView({super.key});

  @override
  State<FranchiseeProductsView> createState() => FranchiseeProductsViewState();
}

class FranchiseeProductsViewState extends State<FranchiseeProductsView> {
  late AppDatabase db;
  late FranchiseeProductsViewController controller;

  // Expose controller properties for UI access
  List<Item> get commissaryProducts => controller.commissaryProducts;
  List<Category> get dbCategories => controller.dbCategories;
  int? get commissaryId => controller.commissaryId;
  bool get isLoading => controller.isLoading;

  String get searchQuery => controller.searchQuery;
  set searchQuery(String value) => controller.searchQuery = value;

  TextEditingController get searchController => controller.searchController;

  Map<int, List<RecipeIngredientWithDetails>> get recipeCache =>
      controller.recipeCache;

  List<Item> get filteredProducts => controller.filteredProducts;

  @override
  void initState() {
    super.initState();
    db = database;
    controller = FranchiseeProductsViewController(
      db: db,
      onStateChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
      showSnackBar: (message) {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
    );
    controller.loadData();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    await controller.loadData();
  }

  String categoryNameForId(int? id) {
    return controller.categoryNameForId(id);
  }

  String getIngredientsDisplay(int itemId) {
    return controller.getIngredientsDisplay(itemId);
  }

  void showProductDetails(Item item) {
    controller.showProductDetails(context, item);
  }

  @override
  Widget build(BuildContext context) {
    if (AppLayout.isDesktop(context) == false) {
      return FranchiseeProductsViewMobile(state: this);
    }
    return FranchiseeProductsViewDesktop(state: this);
  }
}
