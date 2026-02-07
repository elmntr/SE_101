import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import '../../../database/app_database.dart';
import '../../../database/models/item_with_branch_stock.dart';
import 'package:chickenjoo_inventory/tables/sorting_and_filters.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:chickenjoo_inventory/services/search_service.dart';
import 'franchisee_items_mobile.dart';
import 'franchisee_items_desktop.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => ItemsPageState();
}

class ItemsPageState extends State<ItemsPage> {
  late AppDatabase db;

  List<ItemWithBranchStock> dbItems = [];
  List<Category> dbCategories = [];
  int? currentOrganizationId;
  int? commissaryId; // Parent commissary for master items

  int categoryCount = 0;
  int selectedTab = 0; // 0 = Items, 1 = Categories
  bool isLoading = true;

  Map<int, String> categoryMap = {}; // Store category names by ID

  static const String orgIdKey = 'current_organization_id';

  ItemSort currentSort = ItemSort(ItemSortField.name, SortOrder.desc);
  CategorySort currentCategorySort = CategorySort(
    CategorySortField.name,
    SortOrder.desc,
  );

  // Search functionality
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  /// Get filtered and sorted items based on search query
  List<ItemWithBranchStock> get filteredItems {
    var list = dbItems.toList();

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      list = SearchService.filterItems(
        list,
        searchQuery,
        getName: (item) => item.name,
        getDescription: (item) => item.description,
        getCategoryName: (item) => item.categoryName,
      );
    }

    // Apply sorting
    switch (currentSort.field) {
      case ItemSortField.date:
        list.sort((a, b) => a.lastUpdated.compareTo(b.lastUpdated));
        break;
      case ItemSortField.name:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ItemSortField.stock:
        list.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      case ItemSortField.sale:
        list.sort((a, b) => a.sold.compareTo(b.sold));
        break;
      case ItemSortField.spoilage:
        list.sort((a, b) => a.spoilage.compareTo(b.spoilage));
        break;
    }

    if (currentSort.order == SortOrder.desc) {
      list = list.reversed.toList();
    }

    return list;
  }

  /// Get filtered and sorted categories based on search query
  List<Category> get filteredCategories {
    var list = dbCategories.toList();

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      list = SearchService.filterCategories(
        list,
        searchQuery,
        getName: (cat) => cat.name,
        getDescription: (cat) => cat.description,
      );
    }

    // Apply sorting
    switch (currentCategorySort.field) {
      case CategorySortField.date:
        list.sort((a, b) => a.lastUpdated.compareTo(b.lastUpdated));
        break;
      case CategorySortField.name:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case CategorySortField.items:
        // Will be handled by category with counts
        break;
    }

    if (currentCategorySort.order == SortOrder.desc) {
      list = list.reversed.toList();
    }

    return list;
  }

  @override
  void initState() {
    super.initState();
    db = database;
    loadData();

    // ✅ FIX: Listen to sync completion to refresh data
    syncCompleteNotifier.addListener(_onSyncComplete);
  }

  @override
  void dispose() {
    syncCompleteNotifier.removeListener(_onSyncComplete);
    super.dispose();
  }

  void _onSyncComplete() {
    if (mounted) {
      print('🔄 Sync completed, refreshing items...');
      loadData();
    }
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      // Get current organization and commissary IDs
      await loadCurrentOrganization();
      await loadCommissaryId();

      // Only load items if we have a valid organization context
      if (currentOrganizationId == null || commissaryId == null) {
        if (mounted) {
          setState(() {
            dbItems = [];
            dbCategories = [];
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No organization context. Please log in again.'),
            ),
          );
        }
        return;
      }

      // Load items with branch-specific stock (same as inventory)
      final items = await db.branchItemStockDao
          .getItemsWithStockForBranch(currentOrganizationId!, commissaryId!);

      final categories = await db.categoriesDao.getAllCategories();

      print('📦 Loaded ${items.length} items with branch stock for Items page');

      if (mounted) {
        setState(() {
          dbItems = items;
          dbCategories = categories;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// Load the parent commissary ID for this franchisee
  Future<void> loadCommissaryId() async {
    if (currentOrganizationId == null) return;

    // Get the franchisee's organization to find parent commissary
    final organization = await db.organizationsDao.getOrganizationById(
      currentOrganizationId!,
    );

    if (organization != null) {
      if (organization.type == 'franchisee' &&
          organization.parentCommissaryId != null) {
        // Franchisee: use parent commissary
        commissaryId = organization.parentCommissaryId;
        print('📍 Franchisee mode: commissaryId=$commissaryId');
      } else if (organization.type == 'commissary') {
        // Commissary viewing own inventory
        commissaryId = organization.id;
        print('📍 Commissary mode: commissaryId=$commissaryId');
      }
    }

    // Fallback: find any commissary in database
    if (commissaryId == null) {
      final commissaries = await db.organizationsDao.getAllOrganizations(
        type: 'commissary',
      );
      if (commissaries.isNotEmpty) {
        commissaryId = commissaries.first.id;
        print('📍 Fallback commissary: commissaryId=$commissaryId');
      }
    }
  }

  Future<void> loadCurrentOrganization() async {
    final prefs = await SharedPreferences.getInstance();

    // Try to get from current logged-in user session via auth service
    final currentUser = AppGlobals.instance.authService.currentUser;
    if (currentUser != null) {
      // If local ID is 0 but we have cloud ID, look up the local ID
      // This happens on first login when data is synced but UserData has ID 0
      if (currentUser.organizationId == 0 &&
          currentUser.organizationCloudId != null) {
        final org = await db.organizationsDao.getOrganizationByCloudId(
          currentUser.organizationCloudId!,
        );
        if (org != null) {
          currentOrganizationId = org.id;
          await prefs.setInt(orgIdKey, org.id);
          print(
            '📍 Resolved org ID from cloud ID: ${currentUser.organizationCloudId} → ${org.id}',
          );
          return;
        }
      }

      await prefs.setInt(orgIdKey, currentUser.organizationId);
      currentOrganizationId = currentUser.organizationId;
    } else {
      // Fallback: Load from local storage (for offline mode)
      currentOrganizationId = prefs.getInt(orgIdKey);
    }
  }

  // Create Item Dialog
  void createItem() {
    final TextEditingController name = TextEditingController();
    final TextEditingController stock = TextEditingController();
    final TextEditingController price = TextEditingController();
    int? selectedCategoryId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add Item",
                      style: TextStyle(
                        fontFamily: fontAll,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      decoration: const InputDecoration(labelText: "Item Name"),
                      controller: name,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Initial Stock",
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: stock,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Price (Optional)",
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}$'),
                        ),
                      ],
                      controller: price,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: "Category (Optional)",
                      ),
                      initialValue: selectedCategoryId,
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('No Category'),
                        ),
                        ...dbCategories.map(
                          (cat) => DropdownMenuItem<int>(
                            value: cat.id,
                            child: Text(cat.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategoryId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            final dialogContext = context;
                            final messenger = ScaffoldMessenger.of(
                              dialogContext,
                            );
                            final navigator = Navigator.of(dialogContext);

                            if (name.text.isEmpty) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Item name is required'),
                                ),
                              );
                              return;
                            }

                            try {
                              // Get user's organization ID from auth service
                              final currentUser =
                                  AppGlobals.instance.authService.currentUser;
                              if (currentUser == null) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Not logged in. Please log in again.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              final organizationId = currentUser.organizationId;

                              await db.itemsDao.insertItem(
                                name: name.text,
                                organizationId: organizationId,
                                stock: int.tryParse(stock.text) ?? 0,
                                categoryId: selectedCategoryId,
                                price: price.text.isNotEmpty
                                    ? double.tryParse(price.text)
                                    : null,
                              );

                              if (!navigator.mounted || !messenger.mounted)
                                return;
                              navigator.pop();
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Item added successfully'),
                                ),
                              );
                              loadData();
                            } catch (e) {
                              if (!messenger.mounted) return;
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Error adding item: $e'),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            "Save",
                            style: TextStyle(color: Colors.white),
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
      ),
    );
  }

  // Create Category Dialog
  void createCategory() {
    final TextEditingController categoryName = TextEditingController();
    final TextEditingController description = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Add Category",
                    style: TextStyle(
                      fontFamily: fontAll,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Category Name",
                    ),
                    controller: categoryName,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Description (Optional)",
                    ),
                    controller: description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          final dialogContext = context;
                          final messenger = ScaffoldMessenger.of(dialogContext);
                          final navigator = Navigator.of(dialogContext);

                          if (categoryName.text.isEmpty) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Category name is required'),
                              ),
                            );
                            return;
                          }

                          try {
                            await db.categoriesDao.insertCategory(
                              name: categoryName.text,
                              description: description.text.isEmpty
                                  ? null
                                  : description.text,
                            );

                            if (!navigator.mounted || !messenger.mounted)
                              return;
                            navigator.pop();
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Category added successfully'),
                              ),
                            );
                            loadData();
                          } catch (e) {
                            if (!messenger.mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Error adding category: $e'),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
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

  void applyItemSort(ItemSort sort) {
    setState(() {
      currentSort = sort;
    });
  }

  void applyCategorySort(CategorySort sort) {
    setState(() {
      currentCategorySort = sort;
    });
  }

  Future<void> deleteItem(Item item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Delete Item"),
        content: Text("Are you sure you want to delete '${item.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await db.itemsDao.deleteItem(item.id);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${item.name} deleted')));
          loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting item: $e')));
        }
      }
    }
  }

  Future<void> deleteCategory(Category category) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Delete Category"),
        content: Text("Are you sure you want to delete '${category.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await db.categoriesDao.deleteCategory(category.id);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${category.name} deleted')));
          loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      }
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

  void showItemDetails(Item item) {
    final TextEditingController priceController = TextEditingController(
      text: item.price?.toString() ?? "",
    );
    final TextEditingController soldController = TextEditingController(
      text: item.sold.toString(),
    );
    final TextEditingController spoilageController = TextEditingController(
      text: item.spoilage.toString(),
    );
    String? selectedUnit = item.unit.isEmpty ? null : item.unit;
    final TextEditingController minStockController = TextEditingController(
      text: item.minimumStock?.toString() ?? "",
    );

    int? selectedCategoryId = item.categoryId;

    final dateOrdered =
        "${item.lastUpdated.month}/${item.lastUpdated.day}/${item.lastUpdated.year}";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
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
                    // Header with item name and price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontFamily: fontAll,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: priceController,
                            readOnly: true,
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: "Price",
                              prefixText: "₱",
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Row 1: Category and Unit
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Category:",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonFormField<int>(
                                  value: selectedCategoryId,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                      value: null,
                                      child: Text("Uncategorized"),
                                    ),
                                    ...dbCategories.map(
                                      (cat) => DropdownMenuItem<int>(
                                        value: cat.id,
                                        child: Text(cat.name),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setDialogState(() {
                                      selectedCategoryId = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Unit:",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  setDialogState(() {
                                    selectedUnit = value;
                                  });
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'piece',
                                    child: Text('piece'),
                                  ),
                                  PopupMenuItem(
                                    value: 'grams',
                                    child: Text('grams'),
                                  ),
                                  PopupMenuItem(value: 'kg', child: Text('kg')),
                                  PopupMenuItem(value: 'ml', child: Text('ml')),
                                  PopupMenuItem(value: 'l', child: Text('l')),
                                ],
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        selectedUnit ?? 'Select unit',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Row 2: Min Stock and Amount Sold
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Minimum Stock:",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: minStockController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Amount Sold:",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: soldController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Row 3: Date Ordered and Amount Spoiled
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Date Ordered:",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  dateOrdered,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Amount Spoiled:",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: spoilageController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "CANCEL",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () async {
                            final dialogContext = context;
                            final messenger = ScaffoldMessenger.of(
                              dialogContext,
                            );
                            final navigator = Navigator.of(dialogContext);

                            try {
                              final double? parsedPrice =
                                  priceController.text.isNotEmpty
                                  ? double.tryParse(priceController.text)
                                  : null;
                              final int parsedSold =
                                  int.tryParse(soldController.text) ??
                                  item.sold;
                              final int parsedSpoilage =
                                  int.tryParse(spoilageController.text) ??
                                  item.spoilage;
                              final int? parsedMinStock =
                                  minStockController.text.isNotEmpty
                                  ? int.tryParse(minStockController.text)
                                  : item.minimumStock;
                              final String? unitText = selectedUnit;

                              // Calculate the change in sold/spoilage for daily summary
                              final soldChange = parsedSold - item.sold;
                              final spoilageChange =
                                  parsedSpoilage - item.spoilage;

                              final updated = item.copyWith(
                                price: Value(parsedPrice),
                                sold: parsedSold,
                                spoilage: parsedSpoilage,
                                unit: (unitText != null && unitText.isNotEmpty)
                                    ? unitText
                                    : item.unit,
                                minimumStock: Value(parsedMinStock),
                                categoryId: Value(selectedCategoryId),
                              );

                              final success = await db.itemsDao.updateItem(
                                updated,
                              );

                              if (success) {
                                // Record changes in daily sales summary for reports
                                if (soldChange > 0 &&
                                    currentOrganizationId != null) {
                                  await db.dailySalesSummaryDao.recordSale(
                                    organizationId: currentOrganizationId!,
                                    itemId: item.id,
                                    quantity: soldChange,
                                    unitPrice: parsedPrice ?? item.price ?? 0,
                                    unitCost: item.costPrice ?? 0,
                                    currentStock: item.stock - soldChange,
                                  );
                                }
                                if (spoilageChange > 0 &&
                                    currentOrganizationId != null) {
                                  await db.dailySalesSummaryDao.recordSpoilage(
                                    organizationId: currentOrganizationId!,
                                    itemId: item.id,
                                    quantity: spoilageChange,
                                    currentStock: item.stock - spoilageChange,
                                  );
                                }

                                if (!navigator.mounted || !messenger.mounted)
                                  return;
                                navigator.pop();
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Item updated successfully'),
                                  ),
                                );
                                loadData();
                              } else {
                                if (!messenger.mounted) return;
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to update item'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (!(ScaffoldMessenger.maybeOf(
                                    context,
                                  )?.mounted ??
                                  false))
                                return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error updating item: $e'),
                                ),
                              );
                            }
                          },
                          child: const Text("SAVE ITEM DETAILS"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> buildCategoryRows() async {
    final rows = <Map<String, dynamic>>[];

    for (final category in dbCategories) {
      final itemCount = await db.categoriesDao.getItemCountInCategory(
        category.id,
      );
      rows.add({
        'name': category.name,
        'itemCount': itemCount,
        'category': category,
      });
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    if (AppLayout.isDesktop(context) == false) {
      return ItemsPageMobile(state: this);
    }
    return ItemsPageDesktop(state: this);
  }
}
