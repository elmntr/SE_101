// lib/screen/franchisee/franchisee_products_view.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import '../../database/app_database.dart';
import 'package:chickenjoo_inventory/tables/tables.dart';
import 'package:chickenjoo_inventory/app_globals.dart';

/// Franchisee Products View Page
/// - View-only access to commissary products (no create/edit/delete)
/// - Shows recipe ingredients for each product
class FranchiseeProductsView extends StatefulWidget {
  const FranchiseeProductsView({super.key});

  @override
  State<FranchiseeProductsView> createState() => _FranchiseeProductsViewState();
}

class _FranchiseeProductsViewState extends State<FranchiseeProductsView> {
  late AppDatabase db;

  List<Item> commissaryProducts = [];
  List<Category> dbCategories = [];
  int? _commissaryId;
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Cache for recipe ingredients
  Map<int, List<RecipeIngredientWithDetails>> _recipeCache = {};

  @override
  void initState() {
    super.initState();
    db = database;
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Get commissary ID from the franchisee's parent organization
      await _loadCommissaryId();
      
      print('🔍 DEBUG: Commissary ID resolved to: $_commissaryId');

      if (_commissaryId == null) {
        if (mounted) {
          setState(() {
            commissaryProducts = [];
            dbCategories = [];
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No commissary linked. Please contact support.'),
            ),
          );
        }
        return;
      }

      // Load master items from commissary
      final items = await db.itemsDao.getCommissaryMasterItems(_commissaryId!);
      print('🔍 DEBUG: Found ${items.length} commissary master items');
      
      // Also check all items in the database for debugging
      final allItems = await db.itemsDao.getAllItems();
      print('🔍 DEBUG: Total items in database: ${allItems.length}');
      for (var item in allItems) {
        print('   - Item: ${item.name}, orgId: ${item.organizationId}, masterItemId: ${item.masterItemId}, isDeleted: ${item.isDeleted}');
      }
      
      final categories = await db.categoriesDao.getAllCategories();

      // Pre-load recipe ingredients for all items
      await _loadRecipeIngredients(items);

      if (mounted) {
        setState(() {
          commissaryProducts = items;
          dbCategories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
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
            _commissaryId = organization.parentCommissaryId;
            print('🔍 DEBUG: Set commissaryId from parent: $_commissaryId');
          } else if (organization.type == 'commissary') {
            // If this is a commissary, use its own ID
            _commissaryId = organization.id;
            print('🔍 DEBUG: Set commissaryId from self (commissary): $_commissaryId');
          }
        }
      }
    }

    // Fallback: Try to get any commissary from the database
    if (_commissaryId == null) {
      print('🔍 DEBUG: Commissary ID still null, trying fallback...');
      final commissaries = await db.organizationsDao.getAllOrganizations(type: 'commissary');
      print('🔍 DEBUG: Found ${commissaries.length} commissaries in database');
      if (commissaries.isNotEmpty) {
        _commissaryId = commissaries.first.id;
        print('🔍 DEBUG: Using fallback commissary ID: $_commissaryId');
      }
    }
  }

  Future<void> _loadRecipeIngredients(List<Item> items) async {
    _recipeCache.clear();

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
      
      _recipeCache[item.id] = detailedList;
    }
  }

  String _categoryNameForId(int? id) {
    if (id == null) return 'Uncategorized';
    try {
      return dbCategories.firstWhere((c) => c.id == id).name;
    } catch (_) {
      return 'Uncategorized';
    }
  }

  String _getIngredientsDisplay(int itemId) {
    final ingredients = _recipeCache[itemId];
    if (ingredients == null || ingredients.isEmpty) {
      return 'No recipe';
    }
    return ingredients
        .map((ri) => '${ri.recipeIngredient.quantityNeeded} ${ri.recipeIngredient.unit} ${ri.ingredient.name}')
        .join(', ');
  }

  void _showProductDetails(Item item) {
    final ingredients = _recipeCache[item.id] ?? [];

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
                  _buildInfoRow('Category', _categoryNameForId(item.categoryId)),
                  _buildInfoRow('Unit', item.unit),
                  if (item.costPrice != null)
                    _buildInfoRow('Cost Price', '₱${item.costPrice!.toStringAsFixed(2)}'),
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
                            Icon(Icons.restaurant_menu, color: Colors.red, size: 20),
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
                          ...ingredients.map((ri) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.circle, size: 6, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        ri.ingredient.name,
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Text(
                                      '${ri.recipeIngredient.quantityNeeded} ${ri.recipeIngredient.unit}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              )),
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

  List<Item> get _filteredProducts {
    if (_searchQuery.isEmpty) return commissaryProducts;
    return commissaryProducts
        .where((item) => item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 16 : 12),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Commissary Products',
                    style: TextStyle(
                      fontSize: isDesktop ? 30 : 26,
                      fontFamily: fontAll,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 28),
                        tooltip: 'Refresh',
                        onPressed: _loadData,
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, size: 28),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Search bar
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: "Search products...",
                    icon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Info banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Viewing products from commissary. Tap a product to see recipe details.',
                        style: TextStyle(color: Colors.blue, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Products table
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isDesktop ? 20 : 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _searchQuery.isNotEmpty
                                        ? Icons.search_off
                                        : Icons.inventory_2_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'No products match your search'
                                        : 'No products available from commissary',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : buildUniversalTable(
                              headers: [
                                'Product Name',
                                'Category',
                                'Unit',
                                'Recipe Ingredients',
                                '',
                              ],
                              rows: _filteredProducts.map((item) => [
                                    GestureDetector(
                                      onTap: () => _showProductDetails(item),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: Text(
                                          item.name,
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _showProductDetails(item),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: Text(_categoryNameForId(item.categoryId)),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _showProductDetails(item),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: Text(item.unit),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _showProductDetails(item),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: SizedBox(
                                          width: 200,
                                          child: Text(
                                            _getIngredientsDisplay(item.id),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.visibility, color: Colors.blue),
                                      tooltip: 'View Details',
                                      onPressed: () => _showProductDetails(item),
                                    ),
                                  ]).toList(),
                              smallHeaderWidth: 20,
                              largeHeaderWidth: isDesktop ? 120 : 80,
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper class to hold recipe ingredient with full ingredient details
class RecipeIngredientWithDetails {
  final RecipeIngredient recipeIngredient;
  final Ingredient ingredient;

  RecipeIngredientWithDetails({
    required this.recipeIngredient,
    required this.ingredient,
  });
}
