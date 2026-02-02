import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/screen/employee/item_change_record.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import '../../../../database/app_database.dart';
import '../../../../database/models/item_with_branch_stock.dart';
import 'package:chickenjoo_inventory/tables/sorting_and_filters.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'franchisee_inventory_mobile.dart';
import 'franchisee_inventory_desktop.dart';
import 'replenish_stock_tab.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  // Received updates from employees awaiting franchisee action
  static List<ChangeRecord> pendingChanges = [];

  @override
  State<InventoryPage> createState() => InventoryPageState();
}

class InventoryPageState extends State<InventoryPage> {
  late AppDatabase db;
  
  /// Items with branch-specific stock data
  List<ItemWithBranchStock> items = [];
  
  int? currentOrganizationId;
  int? commissaryId;  // Parent commissary for master items
  int? currentUserId;  // Current logged-in user
  bool isLoading = true;

  int selectedTab = 0; // 0 = Item Stock, 1 = Stock Changes, 2 = Replenish Stock

  ItemSort currentSort = const ItemSort(ItemSortField.name, SortOrder.asc);

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
      print('🔄 Sync completed, refreshing inventory...');
      loadData();
    }
  }

  static const String orgIdKey = 'current_organization_id';

  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      // Get current organization and commissary IDs
      await loadCurrentOrganization();
      await loadCommissaryId();
      await loadCurrentUserId();

      if (currentOrganizationId != null && currentOrganizationId! > 0 && commissaryId != null) {
        // ✅ NEW: Load items with branch-specific stock
        final loadedItems = await db.branchItemStockDao.getItemsWithStockForBranch(
          currentOrganizationId!,
          commissaryId!,
        );

        print('📦 Loaded ${loadedItems.length} items with branch stock');
        for (final item in loadedItems) {
          print('   - ${item.name}: stock=${item.stock}, sold=${item.sold}, spoilage=${item.spoilage}, hasBranchStock=${item.hasBranchStock}');
        }

        if (mounted) {
          setState(() {
            items = loadedItems;
            isLoading = false;
          });
        }
      } else {
        print('⚠️ Missing org context: orgId=$currentOrganizationId, commissaryId=$commissaryId');
        if (mounted) {
          setState(() {
            items = [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error loading inventory data: $e');
      if (mounted) {
        setState(() => isLoading = false);
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
      if (currentUser.organizationId == 0 && currentUser.organizationCloudId != null) {
        final org = await db.organizationsDao.getOrganizationByCloudId(
          currentUser.organizationCloudId!,
        );
        if (org != null) {
          currentOrganizationId = org.id;
          await prefs.setInt(orgIdKey, org.id);
          print('📍 Resolved org ID from cloud ID: ${currentUser.organizationCloudId} → ${org.id}');
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

  /// Load the parent commissary ID for this franchisee
  Future<void> loadCommissaryId() async {
    if (currentOrganizationId == null) return;

    // Get the franchisee's organization to find parent commissary
    final organization = await db.organizationsDao.getOrganizationById(currentOrganizationId!);
    
    if (organization != null) {
      if (organization.type == 'franchisee' && organization.parentCommissaryId != null) {
        // Franchisee: use parent commissary
        commissaryId = organization.parentCommissaryId;
        print('📍 Franchisee mode: commissaryId=${commissaryId}');
      } else if (organization.type == 'commissary') {
        // Commissary viewing own inventory
        commissaryId = organization.id;
        print('📍 Commissary mode: commissaryId=${commissaryId}');
      }
    }

    // Fallback: find any commissary in database
    if (commissaryId == null) {
      final commissaries = await db.organizationsDao.getAllOrganizations(type: 'commissary');
      if (commissaries.isNotEmpty) {
        commissaryId = commissaries.first.id;
        print('📍 Fallback commissary: commissaryId=${commissaryId}');
      }
    }
  }

  Future<void> loadCurrentUserId() async {
    final currentUser = AppGlobals.instance.authService.currentUser;
    if (currentUser != null) {
      // Resolve local ID if it's 0 (meaning we have auth but no local mapping yet)
      if (currentUser.id == 0 && currentUser.cloudId != null) {
        final localUser = await db.usersDao.getUserByCloudId(currentUser.cloudId!);
        if (localUser != null) {
          currentUserId = localUser.id;
          print('👤 Resolved local User ID from cloud ID: ${currentUser.cloudId} → ${localUser.id}');
        } else {
          print('⚠️ Could not resolve local user from cloud ID: ${currentUser.cloudId}');
          // Don't set to 0 - leave as null so we know it's invalid
          currentUserId = null;
        }
      } else if (currentUser.id > 0) {
        currentUserId = currentUser.id;
      } else {
        currentUserId = null;
      }
    } else {
      // If we don't have a user, we might need one for the request.
      // For now, we'll try to get it from the DAO if possible, or fallback.
      // In a real app, we should enforce login.
      final users = await db.usersDao.getAllUsers();
      if (users.isNotEmpty) {
        currentUserId = users.first.id;
      }
    }
    print('👤 Current User ID: $currentUserId');
  }

  void applyItemSort(ItemSort sort) {
    setState(() {
      currentSort = sort;

      switch (sort.field) {
        case ItemSortField.date:
          items.sort((a, b) => a.lastUpdated.compareTo(b.lastUpdated));
          break;
        case ItemSortField.name:
          items.sort((a, b) => a.name.compareTo(b.name));
          break;
        case ItemSortField.stock:
          items.sort((a, b) => a.stock.compareTo(b.stock));
          break;
        case ItemSortField.sale:
          items.sort((a, b) => a.sold.compareTo(b.sold));
          break;
        case ItemSortField.spoilage:
          items.sort((a, b) => a.spoilage.compareTo(b.spoilage));
          break;
      }

      if (sort.order == SortOrder.desc) {
        items = items.reversed.toList();
      }
    });
  }

  /// Quick refresh - syncs only items from cloud
  Future<void> refreshInventory() async {
    setState(() => isLoading = true);
    try {
      await AppGlobals.instance.syncService.syncItemsOnly();
      // Also sync branch item stock
      await AppGlobals.instance.syncService.syncBranchItemStock();
      // loadData will be called via _onSyncComplete
    } catch (e) {
      print('Error refreshing inventory: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AppLayout.isDesktop(context) == false) {
      return InventoryPageMobile(state: this);
    }
    return InventoryPageDesktop(state: this);
  }
}