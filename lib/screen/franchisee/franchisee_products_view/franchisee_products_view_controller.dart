// lib/screen/franchisee/franchisee_products_view/franchisee_products_view_controller.dart
import 'package:flutter/material.dart';
import '../../../database/app_database.dart';
import 'package:chickenjoo_inventory/tables/tables.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/services/search_service.dart';

/// Helper class to hold recipe ingredient with full ingredient details
class RecipeIngredientWithDetails {
  final RecipeIngredient recipeIngredient;
  final Ingredient ingredient;

  RecipeIngredientWithDetails({
    required this.recipeIngredient,
    required this.ingredient,
  });
}

/// Controller class that handles all the business logic for franchisee products view
class FranchiseeProductsViewController {
  FranchiseeProductsViewController({
    required this.db,
    required this.onStateChanged,
    required this.showSnackBar,
  });

  final AppDatabase db;
  final VoidCallback onStateChanged;
  final void Function(String message) showSnackBar;

  List<Item> commissaryProducts = [];
  List<Category> dbCategories = [];
  int? commissaryId;
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  // Cache for recipe ingredients
  Map<int, List<RecipeIngredientWithDetails>> recipeCache = {};

  void dispose() {
    searchController.dispose();
  }

  Future<void> loadData() async {
    isLoading = true;
    onStateChanged();

    try {
      // Get commissary ID from the franchisee's parent organization
      await _loadCommissaryId();

      //print('🔍 DEBUG: Commissary ID resolved to: $commissaryId');

      if (commissaryId == null) {
        commissaryProducts = [];
        dbCategories = [];
        isLoading = false;
        onStateChanged();
        showSnackBar('No commissary linked. Please contact support.');
        return;
      }

      // Load master items from commissary
      final items = await db.itemsDao.getCommissaryMasterItems(commissaryId!);
      //print('🔍 DEBUG: Found ${items.length} commissary master items');

      // Also check all items in the database for debugging
      final allItems = await db.itemsDao.getAllItems();
      //print('🔍 DEBUG: Total items in database: ${allItems.length}');
      for (var item in allItems) {
        //print(
        //  '   - Item: ${item.name}, orgId: ${item.organizationId}, masterItemId: ${item.masterItemId}, isDeleted: ${item.isDeleted}'
        //);
      }

      final categories = await db.categoriesDao.getAllCategories();

      // Pre-load recipe ingredients for all items
      await _loadRecipeIngredients(items);

      commissaryProducts = items;
      dbCategories = categories;
      isLoading = false;
      onStateChanged();
    } catch (e) {
      //print('Error loading data: $e');
      isLoading = false;
      onStateChanged();
      showSnackBar('Error loading products: $e');
    }
  }

  Future<void> _loadCommissaryId() async {
    final currentUser = AppGlobals.instance.authService.currentUser;
    //print(
    //  '🔍 DEBUG: currentUser: ${currentUser?.username}, orgId: ${currentUser?.organizationId}, orgType: ${currentUser?.organizationType}'
    //);

    if (currentUser != null) {
      // Get the franchisee's organization
      int orgId = currentUser.organizationId;

      // If org ID is 0, try to resolve from cloud ID
      if (orgId == 0 && currentUser.organizationCloudId != null) {
        //print(
        //  '🔍 DEBUG: orgId is 0, trying to resolve from cloudId: ${currentUser.organizationCloudId}'
        //);
        final org = await db.organizationsDao.getOrganizationByCloudId(
          currentUser.organizationCloudId!,
        );
        if (org != null) {
          orgId = org.id;
          //print('🔍 DEBUG: Resolved orgId to: $orgId');
        }
      }

      if (orgId > 0) {
        // Get the organization to find its parent commissary
        final organization = await db.organizationsDao.getOrganizationById(
          orgId,
        );
        //print(
        //  '🔍 DEBUG: Organization: ${organization?.name}, type: ${organization?.type}, parentCommissaryId: ${organization?.parentCommissaryId}'
        //);
        if (organization != null) {
          // If this is a franchisee, get the parent commissary
          if (organization.type == 'franchisee' &&
              organization.parentCommissaryId != null) {
            commissaryId = organization.parentCommissaryId;
            //print('🔍 DEBUG: Set commissaryId from parent: $commissaryId');
          } else if (organization.type == 'commissary') {
            // If this is a commissary, use its own ID
            commissaryId = organization.id;
            //print(
            //  '🔍 DEBUG: Set commissaryId from self (commissary): $commissaryId'
            //);
          }
        }
      }
    }

    // Fallback: Try to get any commissary from the database
    if (commissaryId == null) {
      //print('🔍 DEBUG: Commissary ID still null, trying fallback...');
      final commissaries = await db.organizationsDao.getAllOrganizations(
        type: 'commissary',
      );
      //print('🔍 DEBUG: Found ${commissaries.length} commissaries in database');
      if (commissaries.isNotEmpty) {
        commissaryId = commissaries.first.id;
        //print('🔍 DEBUG: Using fallback commissary ID: $commissaryId');
      }
    }
  }

  Future<void> _loadRecipeIngredients(List<Item> items) async {
    recipeCache.clear();

    for (final item in items) {
      final recipeIngredients = await db.recipeIngredientsDao
          .getIngredientsForItem(item.id);

      final detailedList = <RecipeIngredientWithDetails>[];
      for (final ri in recipeIngredients) {
        final ingredient = await db.ingredientsDao.getIngredientById(
          ri.ingredientId,
        );
        if (ingredient != null) {
          detailedList.add(
            RecipeIngredientWithDetails(
              recipeIngredient: ri,
              ingredient: ingredient,
            ),
          );
        }
      }

      recipeCache[item.id] = detailedList;
    }
  }

  String categoryNameForId(int? id) {
    if (id == null) return 'Uncategorized';
    try {
      return dbCategories.firstWhere((c) => c.id == id).name;
    } catch (_) {
      return 'Uncategorized';
    }
  }

  String getIngredientsDisplay(int itemId) {
    final ingredients = recipeCache[itemId];
    if (ingredients == null || ingredients.isEmpty) {
      return 'No recipe';
    }
    return ingredients
        .map(
          (ri) =>
              '${ri.recipeIngredient.quantityNeeded} ${ri.recipeIngredient.unit} ${ri.ingredient.name}',
        )
        .join(', ');
  }

  List<Item> get filteredProducts {
    if (searchQuery.isEmpty) return commissaryProducts;
    // Use the universal SearchService to filter products
    return SearchService.filterItems(
      commissaryProducts,
      searchQuery,
      getName: (item) => item.name,
      getDescription: (item) => item.description,
      getCategoryName: (item) => categoryNameForId(item.categoryId),
    );
  }

  void showProductDetails(BuildContext context, Item item) {
    final ingredients = recipeCache[item.id] ?? [];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.fastfood, color: Colors.red, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontFamily: fontAll,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Product Info
                  _buildInfoRow('Category', categoryNameForId(item.categoryId)),
                  _buildInfoRow('Unit', item.unit),
                  if (item.costPrice != null)
                    _buildInfoRow(
                      'Cost Price',
                      '₱${item.costPrice!.toStringAsFixed(2)}',
                    ),
                  if (item.description != null && item.description!.isNotEmpty)
                    _buildInfoRow('Description', item.description!),

                  const SizedBox(height: 20),

                  // Recipe Ingredients Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Recipe Ingredients',
                              style: TextStyle(
                                fontFamily: fontAll,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (ingredients.isEmpty)
                          const Text(
                            'No recipe defined for this product.',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          )
                        else
                          ...ingredients.map(
                            (ri) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 6,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      ri.ingredient.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${ri.recipeIngredient.quantityNeeded} ${ri.recipeIngredient.unit}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Close button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Close',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
