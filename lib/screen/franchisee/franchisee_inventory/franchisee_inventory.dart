import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/screen/employee/item_change_record.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import '../../../../database/app_database.dart';
import 'package:chickenjoo_inventory/tables/sorting_and_filters.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'franchisee_inventory_mobile.dart';
import 'franchisee_inventory_desktop.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  // Received updates from employees awaiting franchisee action
  static List<ChangeRecord> pendingChanges = [];

  @override
  State<InventoryPage> createState() => InventoryPageState();
}

class InventoryPageState extends State<InventoryPage> {
  late AppDatabase db;
  List<Item> items = [];
  int? currentOrganizationId;
  bool isLoading = true;

  int selectedTab = 0; // 0 = Item Stock, 1 = Stock Changes, 2 = Replenish Stock

  ItemSort currentSort = const ItemSort(ItemSortField.name, SortOrder.asc);

  @override
  void initState() {
    super.initState();
    db = database;
    loadData();
  }

  static const String orgIdKey = 'current_organization_id';

  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      // Get current organization from auth service or local storage
      await loadCurrentOrganization();

      if (currentOrganizationId != null) {
        // Load items for this organization
        final loadedItems = await db.itemsDao.getItemsByOrganization(
          currentOrganizationId!,
        );

        if (mounted) {
          setState(() {
            items = loadedItems;
            isLoading = false;
          });
        }
      } else {
        // Fallback to all items if no organization found
        final loadedItems = await db.itemsDao.getAllItems();
        if (mounted) {
          setState(() {
            items = loadedItems;
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

  @override
  Widget build(BuildContext context) {
    if (AppLayout.isDesktop(context) == false) {
      return InventoryPageMobile(state: this);
    }
    return InventoryPageDesktop(state: this);
  }
}