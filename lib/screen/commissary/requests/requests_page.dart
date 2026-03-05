// lib/screens/requests/requests_page.dart
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/design_constants.dart';

// Import separated UI files
import 'requests_page_mobile.dart';
import 'requests_page_desktop.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => RequestsPageState();
}

class RequestsPageState extends State<RequestsPage> {
  late AppDatabase db;
  int? currentUserId;
  int? commissaryId;
  String? _commissaryCloudId;
  
  // Missing state variables - added to fix compile errors
  final TextEditingController _searchController = TextEditingController();
  int selectedTab = 0;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  // Sort functionality
  String requestSortOrder = 'newestFirst';

  @override
  void initState() {
    super.initState();
    db = database;
    _loadContext();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void setSearchQuery(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  void setSelectedTab(int index) {
    setState(() {
      selectedTab = index;
    });
  }

  void refresh() {
    setState(() {});
  }

  void setRequestSortOrder(String order) {
    setState(() {
      requestSortOrder = order;
    });
  }

  // Public method for scaffolds to use
  List<StockReplenishmentRequest> sortRequests(
    List<StockReplenishmentRequest> requests,
  ) {
    final sorted = List<StockReplenishmentRequest>.from(requests);
    switch (requestSortOrder) {
      case 'newestFirst':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldestFirst':
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'quantityDesc':
        sorted.sort(
          (a, b) => b.quantityRequested.compareTo(a.quantityRequested),
        );
        break;
      case 'quantityAsc':
        sorted.sort(
          (a, b) => a.quantityRequested.compareTo(b.quantityRequested),
        );
        break;
      case 'approvedFirst':
        sorted.sort((a, b) {
          if (a.status == 'approved' && b.status != 'approved') return -1;
          if (a.status != 'approved' && b.status == 'approved') return 1;
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
      case 'rejectedFirst':
        sorted.sort((a, b) {
          if (a.status == 'rejected' && b.status != 'rejected') return -1;
          if (a.status != 'rejected' && b.status == 'rejected') return 1;
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
      default:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return sorted;
  }

  Future<void> _loadContext() async {
    debugPrint('RequestsPage: loading context...');
    final user = AppGlobals.instance.authService.currentUser;
    debugPrint('RequestsPage: currentUser=${user?.id} orgId=${user?.organizationId}');
    if (user != null) {
      if (mounted) {
        setState(() {
          currentUserId = user.id;
          commissaryId = user.organizationId;
        });
      }

      try {
        final org = await db.organizationsDao.getOrganizationById(user.organizationId);
        debugPrint('RequestsPage: org cloudId=${org?.cloudId}');
        if (org?.cloudId != null) {
          _commissaryCloudId = org!.cloudId;
          debugPrint('RequestsPage: attaching realtime cloudId=$_commissaryCloudId');
          await realtimeStockRequestService.attach(_commissaryCloudId!);
          realtimeStockRequestService.statusStream.listen((status) {
            debugPrint('RequestsPage: realtime status=$status');
          });
          realtimeStockRequestService.eventStream.listen((event) {
            debugPrint('RequestsPage: realtime event cloudId=${event.cloudId} status=${event.newStatus}');
          });
        }
      } catch (e) {
        debugPrint('RequestsPage: WARN Failed to initialize realtime: $e');
      }
    } else {
      debugPrint('RequestsPage: no currentUser yet');
    }
  }



  Future<void> _approveRequest(StockReplenishmentRequest request) async {
    if (currentUserId == null) return;

    // Show confirmation dialog with quantity adjustment?
    // For now, simple confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Request'),
        content: Text(
          'Approve request for ${request.quantityRequested} units?\n\nThis will deduct from commissary stock and add to branch stock immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve & Transfer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // 1. Check commissary stock
      final item = await db.itemsDao.getItemById(request.itemId);
      if (item == null) {
        throw Exception(
          'Item not found in commissary (itemId: ${request.itemId})',
        );
      }

      print(
        '?? Item found: ${item.name} (id=${item.id}, cloudId=${item.cloudId})',
      );
      print(
        '   Current stock: ${item.stock}, Requested: ${request.quantityRequested}',
      );

      if (item.stock < request.quantityRequested) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Insufficient stock! Have: ${item.stock}, Requested: ${request.quantityRequested}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // 2. Reduce commissary stock
      final newStock = item.stock - request.quantityRequested;
      final rowsUpdated = await db.itemsDao.updateStock(
        request.itemId,
        newStock,
      );
      print('?? updateStock returned: $rowsUpdated rows updated');
      print(
        '?? Reduced commissary stock for item ${item.name}: ${item.stock} ? $newStock',
      );

      // Verify the update worked
      final updatedItem = await db.itemsDao.getItemById(request.itemId);
      print(
        '?? Verification - Item after update: stock=${updatedItem?.stock}, needsSync=${updatedItem?.isSynced}',
      );

      // 3. Add to branch stock
      // Find existing stock record for branch
      final branchStock = await db.branchItemStockDao.getStockForItem(
        request.franchiseeId,
        request.itemId,
      );

      if (branchStock != null) {
        // Update existing
        await db.branchItemStockDao.receiveItems(
          branchStock.id,
          request.quantityRequested,
        );
      } else {
        // Create new
        await db.branchItemStockDao.createStock(
          BranchItemStockCompanion(
            organizationId: Value(request.franchiseeId),
            itemId: Value(request.itemId),
            stock: Value(request.quantityRequested),
            sold: const Value(0),
            spoilage: const Value(0),
            lastReceivedAt: Value(DateTime.now()),
            lastReceivedQuantity: Value(request.quantityRequested),
          ),
        );
      }

      // 4. Mark request as approved
      await db.stockReplenishmentRequestsDao.approveRequest(
        requestId: request.id,
        reviewedBy: currentUserId!,
        commissaryNotes: 'Auto-approved by commissary app',
      );

      // 5. Auto-sync to push changes to cloud
      try {
        print('?? Auto-syncing after approval...');
        await syncService.syncAll();
        print('? Approval synced to cloud');
      } catch (syncError) {
        print('?? Sync failed (will retry later): $syncError');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('? Request approved and stock transferred'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error approving request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectRequest(StockReplenishmentRequest request) async {
    if (currentUserId == null) return;

    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await db.stockReplenishmentRequestsDao.rejectRequest(
        requestId: request.id,
        reviewedBy: currentUserId!,
        reason: reasonController.text.trim(),
      );

      // Auto-sync to push rejection to cloud
      try {
        print('?? Auto-syncing after rejection...');
        await syncService.syncAll();
        print('? Rejection synced to cloud');
      } catch (syncError) {
        print('?? Sync failed (will retry later): $syncError');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request rejected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error rejecting request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (commissaryId == null) {
      return const Scaffold(
        backgroundColor: Color.fromRGBO(238, 238, 238, 1),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Determine if we're on mobile or desktop based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    if (isMobile) {
      return RequestsPageMobile(state: this);
    } else {
      return RequestsPageDesktop(state: this);
    }
  }

  // Public method for scaffolds to build request rows
  Future<List<List<dynamic>>> buildRequestRows(
    List<StockReplenishmentRequest> requests,
  ) async {
    List<List<dynamic>> rows = [];

    for (final req in requests) {
      final org = await db.organizationsDao.getOrganizationById(
        req.franchiseeId,
      );
      final item = await db.itemsDao.getItemById(req.itemId);

      rows.add([
        Text('#${req.id}', style: const TextStyle(fontFamily: fontAll)),
        Text(
          org?.name ?? 'Unknown Branch',
          style: const TextStyle(fontFamily: fontAll),
        ),
        Text(
          item?.name ?? 'Unknown Item',
          style: const TextStyle(fontFamily: fontAll),
        ),
        Text(
          '${req.quantityRequested}',
          style: const TextStyle(
            fontFamily: fontAll,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${item?.stock ?? 0}',
          style: TextStyle(
            fontFamily: fontAll,
            color: (item?.stock ?? 0) < req.quantityRequested
                ? Colors.red
                : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          DateFormat('MMM d, yyyy  h:mm a').format(req.createdAt),
          style: const TextStyle(fontFamily: fontAll, fontSize: 12),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Pending',
            style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
              tooltip: 'Approve',
              onPressed: () => _approveRequest(req),
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
              tooltip: 'Reject',
              onPressed: () => _rejectRequest(req),
            ),
          ],
        ),
      ]);
    }

    return rows;
  }

  // Public method for scaffolds to build history rows
  Future<List<List<dynamic>>> buildHistoryRows(
    List<StockReplenishmentRequest> requests,
  ) async {
    List<List<dynamic>> rows = [];

    for (final req in requests) {
      final org = await db.organizationsDao.getOrganizationById(
        req.franchiseeId,
      );
      final item = await db.itemsDao.getItemById(req.itemId);

      final isApproved = req.status == 'approved';

      rows.add([
        Text('#${req.id}', style: const TextStyle(fontFamily: fontAll)),
        Text(
          org?.name ?? 'Unknown Branch',
          style: const TextStyle(fontFamily: fontAll),
        ),
        Text(
          item?.name ?? 'Unknown Item',
          style: const TextStyle(fontFamily: fontAll),
        ),
        Text(
          '${req.quantityRequested}',
          style: const TextStyle(fontFamily: fontAll),
        ),
        Text(
          DateFormat('MMM d, yyyy  h:mm a').format(req.createdAt),
          style: const TextStyle(fontFamily: fontAll, fontSize: 12),
        ),
        Text(
          req.reviewedAt != null
              ? DateFormat('MMM d, yyyy  h:mm a').format(req.reviewedAt!)
              : '-',
          style: const TextStyle(fontFamily: fontAll, fontSize: 12),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isApproved ? Colors.green.shade100 : Colors.red.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isApproved ? 'Approved' : 'Rejected',
            style: TextStyle(
              color: isApproved ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox.shrink(), // Empty cell for actions column
      ]);
    }

    return rows;
  }
}
