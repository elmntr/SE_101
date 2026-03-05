import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import 'package:chickenjoo_inventory/tables/tables.dart';
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import '../../../../database/app_database.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/screen/employee/employee_change_item_stock.dart';
import 'package:chickenjoo_inventory/tables/sorting_and_filters.dart';
import 'package:chickenjoo_inventory/database/models/item_with_branch_stock.dart';
import 'package:chickenjoo_inventory/services/search_service.dart';
import 'employee_items_mobile.dart';
import 'employee_items_desktop.dart';

class EmployeeItemsPage extends StatefulWidget {
  final UserData userData;
  const EmployeeItemsPage({super.key, required this.userData});

  @override
  State<EmployeeItemsPage> createState() => EmployeeItemsPageState();
}

class EmployeeItemsPageState extends State<EmployeeItemsPage> {
  late AppDatabase db;

  List<ItemWithBranchStock> dbItems = [];
  List<StockChangeRequest> pendingChanges = [];
  List<User> employeeOptions = [];
  int? selectedEmployeeId;
  bool isLoading = true;

  int selectedTab = 0; // 0 = Items, 1 = Review Changes

  Map<int, String> categoryMap = {}; // Store category names by ID

  ItemSort currentSort = const ItemSort(ItemSortField.name, SortOrder.asc);
  ReviewSort reviewSort = const ReviewSort(
    ReviewSortField.employee,
    SortOrder.asc,
  );

  // Search functionality
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  /// Get filtered items based on search query with sorting applied
  List<ItemWithBranchStock> get filteredItems {
    List<ItemWithBranchStock> items = searchQuery.isEmpty
        ? List.from(dbItems)
        : SearchService.filterItems(
            dbItems,
            searchQuery,
            getName: (item) => item.name,
            getDescription: (item) => item.description,
            getCategoryName: (item) => item.categoryName,
          );

    // Apply sorting
    switch (currentSort.field) {
      case ItemSortField.date:
        items.sort((a, b) => a.item.lastUpdated.compareTo(b.item.lastUpdated));
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

    if (currentSort.order == SortOrder.desc) {
      items = items.reversed.toList();
    }

    return items;
  }

  /// Get filtered pending changes based on search query with sorting applied
  List<StockChangeRequest> get filteredPendingChanges {
    List<StockChangeRequest> changes = searchQuery.isEmpty
        ? List.from(pendingChanges)
        : SearchService.filter(
            pendingChanges,
            searchQuery,
            (change) => [change.reason, change.reviewNotes, change.changeType],
          );

    // Apply sorting
    switch (reviewSort.field) {
      case ReviewSortField.employee:
        // All changes are from same employee, so no sort needed
        break;
      case ReviewSortField.role:
        // All changes are from same role, so no sort needed
        break;
      case ReviewSortField.changes:
        changes.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
    }

    if (reviewSort.order == SortOrder.desc) {
      changes = changes.reversed.toList();
    }

    return changes;
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
      //print('🔄 Sync completed, refreshing employee items...');
      loadData();
    }
  }

  /// Show Change Stock dialog
  void showChangeStockDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXxl)),
        elevation: elevationDialog,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radiusXxl),
          child: Container(
            constraints: dialogConstraintsLarge,
            decoration: AppDecorations.dialog,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dialog Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: actionButtonRed,
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor.withValues(alpha: shadowOpacity),
                        blurRadius: shadowBlurLow,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.white,
                        size: iconSizeLg,
                      ),
                      const SizedBox(width: spacingXl),
                      Expanded(
                        child: Text(
                          'Change Item Stock',
                          style: AppTextStyles.dialogTitle,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                          loadData();
                        },
                      ),
                    ],
                  ),
                ),
                // Dialog Content
                Flexible(
                  child: EmployeeChangeStockPage(
                    userData: widget.userData,
                    onBack: () {
                      Navigator.pop(context);
                      loadData();
                    },
                    onRecordSaved: (_) async {
                      await loadData();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show Review Changes dialog
  void showReviewChangesDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXxl)),
        elevation: elevationDialog,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radiusXxl),
          child: Container(
            constraints: dialogConstraintsMedium,
            decoration: AppDecorations.dialog,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dialog Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: actionButtonRed,
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor.withValues(alpha: shadowOpacity),
                        blurRadius: shadowBlurLow,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.history, color: Colors.white, size: iconSizeLg),
                      const SizedBox(width: spacingXl),
                      Expanded(
                        child: Text(
                          'Review Changes',
                          style: AppTextStyles.dialogTitle,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Dialog Content
                Expanded(child: _buildReviewChangesContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build the Review Changes content for the dialog
  Widget _buildReviewChangesContent() {
    if (pendingChanges.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No pending changes',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: buildChangeRequestRows(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final row = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  row['itemName'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Employee: ${row['employeeName']} • ${row['changeType']} - Qty: ${row['quantity']}',
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildStatusChip(row['status']),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.visibility),
                      tooltip: 'View Details',
                      onPressed: () {
                        Navigator.pop(context);
                        showChangeDetailDialog(row['request']);
                      },
                    ),
                    if (row['status'] == 'draft')
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete',
                        onPressed: () async {
                          await deleteChangeRequest(row['request']);
                          Navigator.pop(context);
                          showReviewChangesDialog(); // Reopen with updated data
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Show Change Detail dialog
  void showChangeDetailDialog(StockChangeRequest request) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: FutureBuilder<Item?>(
            future: db.itemsDao.getItemById(request.itemId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final item = snapshot.data;

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Change Request Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Item: ${item?.name ?? 'Unknown'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildInfoRow('Change Type:', request.changeType),
                    const SizedBox(height: 8),
                    buildInfoRow('Quantity:', request.quantity.toString()),
                    const SizedBox(height: 8),
                    buildInfoRow('Status:', request.status),
                    const SizedBox(height: 8),
                    buildInfoRow(
                      'Original Stock:',
                      request.originalStock.toString(),
                    ),
                    if (request.reason != null) ...[
                      const SizedBox(height: 8),
                      buildInfoRow('Reason:', request.reason!),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (request.status == 'draft')
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                              await deleteChangeRequest(request);
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      // Resolve org ID - if local ID is 0, look up from cloud ID
      int orgId = widget.userData.organizationId;
      if (orgId == 0 && widget.userData.organizationCloudId != null) {
        final org = await db.organizationsDao.getOrganizationByCloudId(
          widget.userData.organizationCloudId!,
        );
        if (org != null) {
          orgId = org.id;
          //print(
          //  '📍 Employee items: Resolved org ID from cloud ID: ${widget.userData.organizationCloudId} → ${org.id}',
          //);
        }
      }

      // Load items with branch-specific stock data
      List<ItemWithBranchStock> items = [];

      if (widget.userData.isFranchisee) {
        // For franchisee employees, load items with branch stock from parent commissary
        final organization = await db.organizationsDao.getOrganizationById(
          orgId,
        );
        if (organization != null && organization.parentCommissaryId != null) {
          items = await db.branchItemStockDao.getItemsWithStockForBranch(
            orgId,
            organization.parentCommissaryId!,
          );
          //print(
          //  '📍 Employee items (franchisee): Loaded ${items.length} items with branch stock from commissary ${organization.parentCommissaryId}',
          //);
        } else {
          // Fallback: try to get any commissary
          final commissaries = await db.organizationsDao.getAllOrganizations(
            type: 'commissary',
          );
          if (commissaries.isNotEmpty) {
            items = await db.branchItemStockDao.getItemsWithStockForBranch(
              orgId,
              commissaries.first.id,
            );
            //print(
            //  '📍 Employee items (franchisee fallback): Loaded ${items.length} items with branch stock from commissary ${commissaries.first.id}',
            //);
          }
        }
      } else {
        // For commissary employees, load commissary items as ItemWithBranchStock
        final commissaryItems = await db.itemsDao.getItemsByOrganization(orgId);
        items = commissaryItems
            .map(
              (item) => ItemWithBranchStock(
                item: item,
                branchStock: null,
                category: null,
              ),
            )
            .toList();
        //print(
        //  '📍 Employee items (commissary): Loaded ${items.length} items from org $orgId',
        //);
      }

      // Load employees for filter
      final employees = await db.usersDao.getUsersByOrganization(
        orgId,
        isActive: true,
      );

      // Load change history for this organization
      final changes = await db.stockChangeRequestsDao.getAllChangeRequests(
        franchiseeId: orgId,
        requestedBy: selectedEmployeeId,
        status: 'approved',
      );

      if (mounted) {
        setState(() {
          dbItems = items;
          pendingChanges = changes;
          employeeOptions = employees;
          isLoading = false;
        });
      }
    } catch (e) {
      //print('Error loading data: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void applyItemSort(ItemSort sort) {
    setState(() {
      currentSort = sort;
    });
  }

  void applyReviewSort(ReviewSort sort) {
    setState(() {
      reviewSort = sort;
    });
  }

  void applyEmployeeFilter(int? employeeId) {
    setState(() {
      selectedEmployeeId = employeeId;
    });
    loadData();
  }

  Future<void> deleteChangeRequest(StockChangeRequest request) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Delete Change Request'),
        content: const Text(
          'Are you sure you want to delete this change request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await db.stockChangeRequestsDao.softDeleteChangeRequest(request.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Change request deleted')),
          );
          loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting request: $e')));
        }
      }
    }
  }

  void showItemDetails(ItemWithBranchStock itemWithStock) async {
    final item = itemWithStock.item;
    // Fetch category
    Category? category;
    if (item.categoryId != null) {
      category = await db.categoriesDao.getCategoryById(item.categoryId!);
    }

    final categoryName = category?.name ?? "Uncategorized";
    final dateOrdered =
        "${item.lastUpdated.month}/${item.lastUpdated.day}/${item.lastUpdated.year}";

    if (!mounted) return;

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
                  // Header with item name and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          itemWithStock.name,
                          style: const TextStyle(
                            fontFamily: fontAll,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      if (item.price != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "₱${item.price!.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Info Grid
                  buildInfoRow("Category:", categoryName),
                  const SizedBox(height: 12),
                  buildInfoRow("Unit:", item.unit),
                  const SizedBox(height: 12),
                  buildInfoRow(
                    "Current Stock:",
                    itemWithStock.stock.toString(),
                  ),
                  const SizedBox(height: 12),
                  buildInfoRow("Amount Sold:", itemWithStock.sold.toString()),
                  const SizedBox(height: 12),
                  buildInfoRow(
                    "Amount Spoiled:",
                    itemWithStock.spoilage.toString(),
                  ),
                  const SizedBox(height: 12),
                  buildInfoRow("Date Updated:", dateOrdered),
                  if (item.minimumStock != null) ...[
                    const SizedBox(height: 12),
                    buildInfoRow(
                      "Minimum Stock:",
                      item.minimumStock.toString(),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("CLOSE"),
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

  // Helper widget for read-only info rows
  Widget buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  void viewChangeDetail(StockChangeRequest request) {
    showChangeDetailDialog(request);
  }

  Future<List<Map<String, dynamic>>> buildChangeRequestRows() async {
    final rows = <Map<String, dynamic>>[];

    for (final request in pendingChanges) {
      final item = await db.itemsDao.getItemById(request.itemId);
      final user = await db.usersDao.getUserById(request.requestedBy);
      final employeeName = user?.fullName ?? user?.username ?? 'Unknown';
      rows.add({
        'itemName': item?.name ?? 'Unknown',
        'employeeName': employeeName,
        'changeType': request.changeType,
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

  @override
  Widget build(BuildContext context) {
    if (AppLayout.isDesktop(context) == false) {
      return EmployeeItemsPageMobile(state: this);
    }
    return EmployeeItemsPageDesktop(state: this);
  }
}
