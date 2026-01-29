import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import 'package:chickenjoo_inventory/tables/tables.dart';
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import '../../../../database/app_database.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/screen/employee/employee_change_item_stock.dart';
import 'package:chickenjoo_inventory/tables/sorting_and_filters.dart';
import 'employee_items_mobile.dart';
import 'employee_items_desktop.dart';

class EmployeeItemsPage extends StatefulWidget {
  final UserData userData;
  const EmployeeItemsPage({super.key, required this.userData});

  @override
  State<EmployeeItemsPage> createState() => EmployeeItemsPageState();
}

class EmployeeItemsPageState extends State<EmployeeItemsPage> {
  bool isInChangeStockMode = false;
  bool isViewingChangeDetail = false;
  StockChangeRequest? selectedChangeRequest;

  late AppDatabase db;

  List<Item> dbItems = [];
  List<StockChangeRequest> pendingChanges = [];
  bool isLoading = true;

  int selectedTab = 0; // 0 = Items, 1 = Review Changes

  Map<int, String> categoryMap = {}; // Store category names by ID

  ItemSort currentSort = const ItemSort(ItemSortField.name, SortOrder.asc);
  ReviewSort reviewSort = const ReviewSort(
    ReviewSortField.employee,
    SortOrder.asc,
  );

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
      print('🔄 Sync completed, refreshing employee items...');
      loadData();
    }
  }

  void toggleChangeStockMode() {
    setState(() {
      isInChangeStockMode = !isInChangeStockMode;
    });
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
          print('📍 Employee items: Resolved org ID from cloud ID: ${widget.userData.organizationCloudId} → ${org.id}');
        }
      }

      // Load items for the user's organization
      final items = await db.itemsDao.getItemsByOrganization(orgId);

      // Load pending/draft changes for this employee
      final changes = await db.stockChangeRequestsDao.getAllChangeRequests(
        requestedBy: widget.userData.id,
      );

      if (mounted) {
        setState(() {
          dbItems = items;
          pendingChanges = changes;
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

  void applyItemSort(ItemSort sort) {
    setState(() {
      currentSort = sort;

      switch (sort.field) {
        case ItemSortField.date:
          dbItems.sort((a, b) => a.lastUpdated.compareTo(b.lastUpdated));
          break;
        case ItemSortField.name:
          dbItems.sort((a, b) => a.name.compareTo(b.name));
          break;
        case ItemSortField.stock:
          dbItems.sort((a, b) => a.stock.compareTo(b.stock));
          break;
        case ItemSortField.sale:
          dbItems.sort((a, b) => a.sold.compareTo(b.sold));
          break;
        case ItemSortField.spoilage:
          dbItems.sort((a, b) => b.spoilage.compareTo(a.spoilage));
          break;
      }

      if (sort.order == SortOrder.desc) {
        dbItems = dbItems.reversed.toList();
      }
    });
  }

  void applyReviewSort(ReviewSort sort) {
    setState(() {
      reviewSort = sort;

      switch (sort.field) {
        case ReviewSortField.employee:
          // All changes are from same employee, so no sort needed
          break;
        case ReviewSortField.role:
          // All changes are from same role, so no sort needed
          break;
        case ReviewSortField.changes:
          pendingChanges.sort((a, b) => b.quantity.compareTo(a.quantity));
          break;
      }

      if (sort.order == SortOrder.desc) {
        pendingChanges = pendingChanges.reversed.toList();
      }
    });
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

  void showItemDetails(Item item) async {
    // Fetch category
    Category? category;
    if (item.categoryId != null) {
      category = await db.categoriesDao.getCategoryById(item.categoryId!);
    }
    
    final categoryName = category?.name ?? "Uncategorized";
    final dateOrdered = "${item.lastUpdated.month}/${item.lastUpdated.day}/${item.lastUpdated.year}";

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
                          item.name,
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
                  buildInfoRow("Current Stock:", item.stock.toString()),
                  const SizedBox(height: 12),
                  buildInfoRow("Amount Sold:", item.sold.toString()),
                  const SizedBox(height: 12),
                  buildInfoRow("Amount Spoiled:", item.spoilage.toString()),
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void viewChangeDetail(StockChangeRequest request) {
    setState(() {
      isViewingChangeDetail = true;
      selectedChangeRequest = request;
    });
  }

  Future<List<Map<String, dynamic>>> buildChangeRequestRows() async {
    final rows = <Map<String, dynamic>>[];

    for (final request in pendingChanges) {
      final item = await db.itemsDao.getItemById(request.itemId);
      rows.add({
        'itemName': item?.name ?? 'Unknown',
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
    // Change Stock Mode
    if (isInChangeStockMode) {
      return EmployeeChangeStockPage(
        userData: widget.userData,
        onBack: () async {
          toggleChangeStockMode();
          await loadData();
        },
        onRecordSaved: (_) async {
          await loadData();
          setState(() {
            selectedTab = 1; // Switch to Review Changes tab
          });
        },
      );
    }

    // View Change Detail
    if (isViewingChangeDetail && selectedChangeRequest != null) {
      return Scaffold(
        backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
        appBar: AppBar(
          backgroundColor: Colors.red.shade400,
          title: const Text('Change Request Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                isViewingChangeDetail = false;
                selectedChangeRequest = null;
              });
            },
          ),
        ),
        body: FutureBuilder<Item?>(
          future: db.itemsDao.getItemById(selectedChangeRequest!.itemId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final item = snapshot.data;
            final request = selectedChangeRequest!;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Item: ${item?.name ?? 'Unknown'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Change Type: ${request.changeType}'),
                      Text('Quantity: ${request.quantity}'),
                      Text('Status: ${request.status}'),
                      Text('Original Stock: ${request.originalStock}'),
                      if (request.reason != null)
                        Text('Reason: ${request.reason}'),
                      const SizedBox(height: 20),
                      if (request.status == 'draft')
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => deleteChangeRequest(request),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    if (AppLayout.isDesktop(context) == false) {
      return EmployeeItemsPageMobile(state: this);
    }
    return EmployeeItemsPageDesktop(state: this);
  }
}