import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/screen/employee/item_change_record.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:drift/drift.dart' show Value;
import '../../../../database/app_database.dart';
import '../../../../database/models/item_with_branch_stock.dart';
import 'package:chickenjoo_inventory/tables/sorting_and_filters.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chickenjoo_inventory/services/search_service.dart';
import 'franchisee_inventory_mobile.dart';
import 'franchisee_inventory_desktop.dart';
import 'replenish_stock_tab.dart';

import 'package:chickenjoo_inventory/services/pos_service.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  // Received updates from employees awaiting franchisee action
  static List<ChangeRecord> pendingChanges = [];

  @override
  State<InventoryPage> createState() => InventoryPageState();
}

class InventoryPageState extends State<InventoryPage> {
  late AppDatabase db;
  late PosService posService;

  /// Items with branch-specific stock data
  List<ItemWithBranchStock> items = [];

  /// Stock change history
  List<StockChangeRequest> changeHistory = [];
  List<User> employeeOptions = [];
  int? selectedEmployeeId;

  int? currentOrganizationId;
  int? commissaryId; // Parent commissary for master items
  int? currentUserId; // Current logged-in user
  bool isLoading = true;

  int selectedTab = 0; // 0 = Item Stock, 1 = Stock Changes, 2 = Replenish Stock, 3 = Sold

  ItemSort currentSort = const ItemSort(ItemSortField.name, SortOrder.asc);

  // Search functionality
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  /// Get filtered and sorted items based on search query
  List<ItemWithBranchStock> get filteredItems {
    var list = items.toList();

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

  @override
  void initState() {
    super.initState();
    db = database;
    posService = PosService(db: db);
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
      //print('🔄 Sync completed, refreshing inventory...');
      loadData();
    }
  }

  void applyEmployeeFilter(int? employeeId) {
    setState(() {
      selectedEmployeeId = employeeId;
    });
    loadData();
  }

  static const String orgIdKey = 'current_organization_id';

  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      // Get current organization and commissary IDs
      await loadCurrentOrganization();
      await loadCommissaryId();
      await loadCurrentUserId();

      if (currentOrganizationId != null &&
          currentOrganizationId! > 0 &&
          commissaryId != null) {
        // ✅ NEW: Load items with branch-specific stock
        final loadedItems = await db.branchItemStockDao
            .getItemsWithStockForBranch(currentOrganizationId!, commissaryId!);

        //print('📦 Loaded ${loadedItems.length} items with branch stock');
        for (final item in loadedItems) {
          //print(
          //  '   - ${item.name}: stock=${item.stock}, sold=${item.sold}, spoilage=${item.spoilage}, hasBranchStock=${item.hasBranchStock}'
          //);
        }

        final employees = await db.usersDao.getUsersByOrganization(
          currentOrganizationId!,
          isActive: true,
        );

        final changes = await db.stockChangeRequestsDao.getAllChangeRequests(
          franchiseeId: currentOrganizationId!,
          requestedBy: selectedEmployeeId,
        );

        if (mounted) {
          setState(() {
            items = loadedItems;
            changeHistory = changes;
            employeeOptions = employees;
            isLoading = false;
          });
        }
      } else {
        //print(
        //  '⚠️ Missing org context: orgId=$currentOrganizationId, commissaryId=$commissaryId'
        //);
        if (mounted) {
          setState(() {
            items = [];
            changeHistory = [];
            employeeOptions = [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      //print('❌ Error loading inventory data: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// Maps internal changeType values to display-friendly labels.
  String _friendlyChangeType(String changeType) {
    switch (changeType) {
      case 'sold':
        return 'Sold';
      case 'spoiled':
        return 'Spoiled';
      case 'override':
        return 'Override';
      case 'adjustment':
        return 'Adjustment';
      case 'return':
        return 'Return';
      default:
        return changeType;
    }
  }

  Future<List<Map<String, dynamic>>> buildChangeHistoryRows() async {
    final rows = <Map<String, dynamic>>[];

    for (final request in changeHistory) {
      final item = await db.itemsDao.getItemById(request.itemId);
      final user = await db.usersDao.getUserById(request.requestedBy);
      rows.add({
        'employeeName': user?.fullName ?? user?.username ?? 'Unknown',
        'itemName': item?.name ?? 'Unknown',
        'changeType': _friendlyChangeType(request.changeType),
        'quantity': request.quantity.toString(),
        'status': request.status,
        'request': request,
      });
    }

    return rows;
  }

  Widget buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'draft':
        color = Colors.grey;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> approveChangeRequest(
    BuildContext context,
    StockChangeRequest request,
  ) async {
    if (currentUserId == null || currentUserId! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Unable to resolve reviewer.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (request.status != 'pending') {
      return;
    }

    try {
      final success = await db.stockChangeRequestsDao.approveChangeRequest(
        requestId: request.id,
        reviewedBy: currentUserId!,
      );

      if (success) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Change approved.'),
            backgroundColor: Colors.green,
          ),
        );
        await loadData();
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Could not approve change.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving change: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Show a password confirmation dialog for manual stock overrides.
  /// Returns true if the password was verified successfully.
  Future<bool> _showPasswordConfirmDialog(BuildContext context) async {
    if (currentUserId == null) return false;

    final passwordController = TextEditingController();
    bool? confirmed;

    confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Confirm Override',
          style: TextStyle(fontFamily: fontAll, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your password to confirm the manual stock override.',
              style: TextStyle(fontFamily: fontAll),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    final password = passwordController.text.trim();
    if (password.isEmpty) return false;

    return await db.usersDao.verifyUserPassword(currentUserId!, password);
  }

  /// Show dialog to edit stock and spoilage values for an item
  Future<void> showEditStockDialog(
    BuildContext context,
    ItemWithBranchStock item,
  ) async {
    final TextEditingController stockController = TextEditingController(
      text: item.stock.toString(),
    );
    final TextEditingController soldController = TextEditingController(
      text: '0', // How many sold this session
    );
    final TextEditingController spoilageController = TextEditingController(
      text: '0', // How many spoiled this session
    );

    final result = await showDialog<Map<String, int>?>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Edit: ${item.name}',
          style: const TextStyle(fontFamily: fontAll, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stock Quantity (manual override)',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: soldController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Qty Sold (this session)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: spoilageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Qty Spoiled (this session)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final newStock = int.tryParse(stockController.text.trim());
              final newSold = int.tryParse(soldController.text.trim());
              final newSpoilage = int.tryParse(spoilageController.text.trim());
              if (newStock != null && newStock >= 0 &&
                  newSold != null && newSold >= 0 &&
                  newSpoilage != null && newSpoilage >= 0) {
                Navigator.pop(context, {
                  'stock': newStock,
                  'sold': newSold,
                  'spoilage': newSpoilage,
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter valid quantities.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && context.mounted) {
      // Require password confirmation if the stock value is being manually overridden
      if (result['stock'] != item.stock) {
        final confirmed = await _showPasswordConfirmDialog(context);
        if (!confirmed) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Stock override cancelled: incorrect password.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }
      await updateItemStock(context, item, result);
    }
  }

  /// Update the stock and spoilage values for an item
  Future<void> updateItemStock(
    BuildContext context,
    ItemWithBranchStock item,
    Map<String, int> values,
  ) async {
    final newStock = values['stock']!;
    final soldQty = values['sold'] ?? 0;
    final spoilageQty = values['spoilage'] ?? 0;

    if (currentOrganizationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Organization not found.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (currentUserId == null || currentUserId! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Could not identify current user.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Step 1: Ensure branch stock record exists before using PosService
      if (!item.hasBranchStock || item.branchStockId == null) {
        await db.branchItemStockDao.createStock(
          BranchItemStockCompanion(
            organizationId: Value(currentOrganizationId!),
            itemId: Value(item.id),
            stock: Value(newStock),
            sold: const Value(0),
            spoilage: const Value(0),
            isSynced: const Value(false),
          ),
        );
        // Reload items to get the new branchStockId
        await loadData();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Created stock record for ${item.name}. Please re-edit to record sales/spoilage.'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return;
      }

      bool anySuccess = false;

      // Step 2: Apply manual stock override if different from current
      if (newStock != item.stock) {
        final success = await db.branchItemStockDao.updateStock(
          item.branchStockId!,
          BranchItemStockCompanion(
            stock: Value(newStock),
            isSynced: const Value(false), // Mark for sync
          ),
        );
        if (success) {
          anySuccess = true;

          // Create an override audit record so the manual change is traceable
          final requestId = await db.stockChangeRequestsDao.createChangeRequest(
            franchiseeId: currentOrganizationId!,
            itemId: item.id,
            changeType: 'override',
            quantity: newStock - item.stock, // positive = increase, negative = decrease
            requestedBy: currentUserId!,
            originalStock: item.stock,
            reason: 'Manual stock override',
          );
          // Immediately approve so the record shows as audited
          await db.stockChangeRequestsDao.submitChangeRequest(requestId);
        }
      }

      // Step 3: Record sales via PosService (updates stock + daily summary + audit)
      if (soldQty > 0) {
        final result = await posService.recordSale(
          item: item,
          quantity: soldQty,
          organizationId: currentOrganizationId!,
          requestedByUserId: currentUserId!,
          createAuditRecord: true,
        );
        if (result.success) {
          anySuccess = true;
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Warning: Sale recording failed: ${result.errorMessage}'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }

      // Step 4: Record spoilage via PosService (updates stock + daily summary + audit)
      if (spoilageQty > 0) {
        final result = await posService.recordSpoilage(
          item: item,
          quantity: spoilageQty,
          organizationId: currentOrganizationId!,
          requestedByUserId: currentUserId!,
          createAuditRecord: true,
        );
        if (result.success) {
          anySuccess = true;
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Warning: Spoilage recording failed: ${result.errorMessage}'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }

      if (anySuccess) {
        // Step 5: Trigger a sync push so changes go to cloud
        AppGlobals.instance.syncService.syncBranchItemStock().catchError((_) {});

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Updated ${item.name} (Stock=$newStock, Sold=$soldQty, Spoilage=$spoilageQty)'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await loadData();
      } else if (newStock == item.stock && soldQty == 0 && spoilageQty == 0) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No changes made.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating item: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
          //print(
          //  '📍 Resolved org ID from cloud ID: ${currentUser.organizationCloudId} → ${org.id}'
          //);
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
    final organization = await db.organizationsDao.getOrganizationById(
      currentOrganizationId!,
    );

    if (organization != null) {
      if (organization.type == 'franchisee' &&
          organization.parentCommissaryId != null) {
        // Franchisee: use parent commissary
        commissaryId = organization.parentCommissaryId;
        //print('📍 Franchisee mode: commissaryId=${commissaryId}');
      } else if (organization.type == 'commissary') {
        // Commissary viewing own inventory
        commissaryId = organization.id;
        //print('📍 Commissary mode: commissaryId=${commissaryId}');
      }
    }

    // Fallback: find any commissary in database
    if (commissaryId == null) {
      final commissaries = await db.organizationsDao.getAllOrganizations(
        type: 'commissary',
      );
      if (commissaries.isNotEmpty) {
        commissaryId = commissaries.first.id;
        //print('📍 Fallback commissary: commissaryId=${commissaryId}');
      }
    }
  }

  Future<void> loadCurrentUserId() async {
    final currentUser = AppGlobals.instance.authService.currentUser;
    if (currentUser != null) {
      // Resolve local ID if it's 0 (meaning we have auth but no local mapping yet)
      if (currentUser.id == 0 && currentUser.cloudId != null) {
        final localUser = await db.usersDao.getUserByCloudId(
          currentUser.cloudId!,
        );
        if (localUser != null) {
          currentUserId = localUser.id;
          //print(
          //  '👤 Resolved local User ID from cloud ID: ${currentUser.cloudId} → ${localUser.id}'
          //);
        } else {
          //print('⚠️ Could not resolve local user from cloud ID: ${currentUser.cloudId}');
          // Try syncing users first, then retry
          await _trySyncAndResolveUser(currentUser.cloudId!);
        }
      } else if (currentUser.id > 0) {
        currentUserId = currentUser.id;
      } else {
        // User has no ID - try to resolve by email
        await _tryResolveUserByEmail(currentUser.email);
      }
    } else {
      // No authenticated user from auth service
      // This might happen if auth service hasn't loaded yet
      //print('⚠️ No current user from auth service, checking Supabase auth...');
      final supabaseUser = Supabase.instance.client.auth.currentUser;
      if (supabaseUser != null) {
        await _tryResolveUserByEmail(supabaseUser.email ?? '');
      } else {
        currentUserId = null;
      }
    }
    //print('👤 Current User ID: $currentUserId');
  }

  /// Try to sync users and resolve local user ID
  Future<void> _trySyncAndResolveUser(String cloudId) async {
    try {
      //print('🔄 Syncing dependencies and users to resolve local ID...');
      // Sync dependencies first to ensure FK resolution works
      await AppGlobals.instance.syncService.syncOrganizations();
      await AppGlobals.instance.syncService.syncRoles();
      
      // DEBUG: Verify DB State
      final roles = await db.rolesDao.getAllRoles();
      //print('🔍 DEBUG: Local Roles count: ${roles.length}');
      // for (var r in roles) //print('   - Role: ${r.id} | ${r.cloudId} | ${r.name}');
      
      final orgs = await db.organizationsDao.getAllOrganizations();
      //print('🔍 DEBUG: Local Orgs count: ${orgs.length}');
      // for (var o in orgs) //print('   - Org: ${o.id} | ${o.cloudId} | ${o.name}');

      await AppGlobals.instance.syncService.syncUsers();

      final localUser = await db.usersDao.getUserByCloudId(cloudId);
      if (localUser != null) {
        currentUserId = localUser.id;
        //print('👤 Resolved local User ID after sync: $cloudId → ${localUser.id}');
      } else {
        //print('❌ User still not found after sync (Organization/Role might be missing/inactive)');
        currentUserId = null;
      }
    } catch (e) {
      //print('⚠️ Sync failed: $e');
      currentUserId = null;
    }
  }

  /// Try to resolve user by email from local DB
  Future<void> _tryResolveUserByEmail(String email) async {
    if (email.isEmpty) {
      currentUserId = null;
      return;
    }
    
    try {
      final localUser = await db.usersDao.getUserByEmail(email);
      if (localUser != null) {
        currentUserId = localUser.id;
        //print('👤 Resolved User ID by email: $email → ${localUser.id}');
      } else {
        // Try syncing first
        //print('🔄 User not found locally, syncing dependencies and users...');
        await AppGlobals.instance.syncService.syncOrganizations();
        await AppGlobals.instance.syncService.syncRoles();
        await AppGlobals.instance.syncService.syncUsers();
        
        final syncedUser = await db.usersDao.getUserByEmail(email);
        if (syncedUser != null) {
          currentUserId = syncedUser.id;
          //print('👤 Resolved User ID after sync: $email → ${syncedUser.id}');
        } else {
          //print('❌ User not found even after sync: $email');
          currentUserId = null;
        }
      }
    } catch (e) {
      //print('⚠️ Error resolving user: $e');
      currentUserId = null;
    }
  }

  void applyItemSort(ItemSort sort) {
    setState(() {
      currentSort = sort;
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
      //print('Error refreshing inventory: $e');
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
