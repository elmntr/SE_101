// lib/screen/franchisee/franchisee_products_view/franchisee_products_view.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import '../../../database/app_database.dart';
import 'franchisee_products_view_mobile.dart';
import 'franchisee_products_view_desktop.dart';
import 'franchisee_products_view_controller.dart';

// Re-export for backward compatibility
export 'franchisee_products_view_controller.dart'
    show RecipeIngredientWithDetails;

/// Franchisee Products View Page
/// - View access to commissary products (read-only for franchisee owners/managers)
/// - Shows recipe ingredients for each product
class FranchiseeProductsView extends StatefulWidget {
  final UserData? userData;

  const FranchiseeProductsView({super.key, this.userData});

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

  // Get current user data from widget or auth service
  UserData? get currentUserData =>
      widget.userData ?? AppGlobals.instance.authService.currentUser;

  /// Method to allow external widgets to trigger a state refresh
  void refreshState(VoidCallback fn) {
    setState(fn);
  }

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

  /// Quick refresh - syncs only items/products from cloud then reloads
  Future<void> refreshProducts() async {
    controller.isLoading = true;
    setState(() {});
    try {
      await AppGlobals.instance.syncService.syncItemsOnly();
      // loadData will be called automatically via _onSyncComplete
    } catch (e) {
      //print('Error refreshing products: $e');
      if (mounted) {
        controller.isLoading = false;
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error refreshing: $e')));
      }
    }
  }

  /// Loads data via the controller
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
