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
/// - View access to commissary products
/// - Shows recipe ingredients for each product
/// - Employees can record stock changes (sales/spoilage) with tracking
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
  
  void _onSyncComplete() {
    if (mounted) {
      print('🔄 Sync completed, reloading commissary products...');
      _isWaitingForSync = false;
      loadData();
    }
  }

  /// Quick refresh - syncs only items/products from cloud then reloads
  Future<void> refreshProducts() async {
    setState(() => isLoading = true);
    try {
      await AppGlobals.instance.syncService.syncItemsOnly();
      // loadData will be called automatically via _onSyncComplete
    } catch (e) {
      print('Error refreshing products: $e');
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing: $e')),
        );
      }
    }
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

  /// Toggle stock change mode - opens the employee stock change page
  void toggleChangeStockMode() {
    setState(() {
      isInChangeStockMode = !isInChangeStockMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Stock Change Mode - use existing EmployeeChangeStockPage which tracks who made changes
    if (isInChangeStockMode && currentUserData != null) {
      return EmployeeChangeStockPage(
        userData: currentUserData!,
        onBack: () async {
          toggleChangeStockMode();
          await loadData();  // Refresh data after changes
        },
        onRecordSaved: (_) async {
          await loadData();
        },
      );
    }
    
    if (AppLayout.isDesktop(context) == false) {
      return FranchiseeProductsViewMobile(state: this);
    }
    return FranchiseeProductsViewDesktop(state: this);
  }
}
