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
    setState(() => isLoading = true);

    try {
      // Get commissary ID from the franchisee's parent organization
      await _loadCommissaryId();
      
      print('🔍 DEBUG: Commissary ID resolved to: $commissaryId');

      if (commissaryId == null) {
        // Check if sync is still in progress - don't show error yet
        final allOrgs = await db.organizationsDao.getAllOrganizations();
        if (allOrgs.isEmpty) {
          // Database is empty, likely first launch - wait for sync
          print('🔍 DEBUG: Database empty, waiting for initial sync...');
          _isWaitingForSync = true;
          if (mounted) {
            setState(() {
              commissaryProducts = [];
              dbCategories = [];
              isLoading = true;  // Keep showing loading indicator
            });
          }
          return;
        }
        
        // Database has orgs but no commissary linked
        if (mounted) {
          setState(() {
            commissaryProducts = [];
            dbCategories = [];
            isLoading = false;
          });
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No commissary linked. Please contact support.'),
            ),
          );
        }
        return;
      }

      // Load master items from commissary
      final items = await db.itemsDao.getCommissaryMasterItems(commissaryId!);
      print('🔍 DEBUG: Found ${items.length} commissary master items');
      
      // ✅ DEBUG: Print stock/sold/spoilage values for loaded items
      for (var item in items) {
        print('   📦 Item: ${item.name} | stock: ${item.stock}, sold: ${item.sold}, spoilage: ${item.spoilage}');
      }
      
      // Check if items are empty but sync might still be running
      if (items.isEmpty) {
        final allItems = await db.itemsDao.getAllItems();
        print('🔍 DEBUG: Total items in database: ${allItems.length}');
        
        if (allItems.isEmpty) {
          // No items at all - might be waiting for sync
          print('🔍 DEBUG: No items in database, waiting for sync...');
          _isWaitingForSync = true;
          if (mounted) {
            setState(() {
              commissaryProducts = [];
              dbCategories = [];
              isLoading = true;  // Keep showing loading indicator
            });
          }
          return;
        }
        
        // Debug: print all items if commissary items are empty but others exist
        for (var item in allItems) {
          print('   - Item: ${item.name}, orgId: ${item.organizationId}, masterItemId: ${item.masterItemId}, isDeleted: ${item.isDeleted}');
        }
      }
      
      final categories = await db.categoriesDao.getAllCategories();

      // Pre-load recipe ingredients for all items
      await _loadRecipeIngredients(items);

      if (mounted) {
        setState(() {
          commissaryProducts = items;
          dbCategories = categories;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: $e')),
        );
      }
    }
  }

  Future<void> _loadCommissaryId() async {
    final currentUser = AppGlobals.instance.authService.currentUser;
    print('🔍 DEBUG: currentUser: ${currentUser?.username}, orgId: ${currentUser?.organizationId}, orgType: ${currentUser?.organizationType}');

    if (currentUser != null) {
      // Get the franchisee's organization
      int orgId = currentUser.organizationId;

      // If org ID is 0, try to resolve from cloud ID
      if (orgId == 0 && currentUser.organizationCloudId != null) {
        print('🔍 DEBUG: orgId is 0, trying to resolve from cloudId: ${currentUser.organizationCloudId}');
        final org = await db.organizationsDao.getOrganizationByCloudId(
          currentUser.organizationCloudId!,
        );
        if (org != null) {
          orgId = org.id;
          print('🔍 DEBUG: Resolved orgId to: $orgId');
        }
      }

      if (orgId > 0) {
        // Get the organization to find its parent commissary
        final organization = await db.organizationsDao.getOrganizationById(orgId);
        print('🔍 DEBUG: Organization: ${organization?.name}, type: ${organization?.type}, parentCommissaryId: ${organization?.parentCommissaryId}');
        if (organization != null) {
          // If this is a franchisee, get the parent commissary
          if (organization.type == 'franchisee' && organization.parentCommissaryId != null) {
            commissaryId = organization.parentCommissaryId;
            print('🔍 DEBUG: Set commissaryId from parent: $commissaryId');
          } else if (organization.type == 'commissary') {
            // If this is a commissary, use its own ID
            commissaryId = organization.id;
            print('🔍 DEBUG: Set commissaryId from self (commissary): $commissaryId');
          }
        }
      }
    }

    // Fallback: Try to get any commissary from the database
    if (commissaryId == null) {
      print('🔍 DEBUG: Commissary ID still null, trying fallback...');
      final commissaries = await db.organizationsDao.getAllOrganizations(type: 'commissary');
      print('🔍 DEBUG: Found ${commissaries.length} commissaries in database');
      if (commissaries.isNotEmpty) {
        commissaryId = commissaries.first.id;
        print('🔍 DEBUG: Using fallback commissary ID: $commissaryId');
      }
    }
  }

  Future<void> _loadRecipeIngredients(List<Item> items) async {
    recipeCache.clear();

    for (final item in items) {
      final recipeIngredients = await db.recipeIngredientsDao.getIngredientsForItem(item.id);
      
      final detailedList = <RecipeIngredientWithDetails>[];
      for (final ri in recipeIngredients) {
        final ingredient = await db.ingredientsDao.getIngredientById(ri.ingredientId);
        if (ingredient != null) {
          detailedList.add(RecipeIngredientWithDetails(
            recipeIngredient: ri,
            ingredient: ingredient,
          ));
        }
      }
      
      recipeCache[item.id] = detailedList;
    }
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
