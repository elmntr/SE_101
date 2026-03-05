// lib/screens/requests/requests_page.dart
import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/services/realtime_stock_request_service.dart';


// Import separated UI files
import 'requests_page_mobile.dart';
import 'requests_page_desktop.dart';
import 'requests_page_controller.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => RequestsPageState();
}

class RequestsPageState extends State<RequestsPage> {
  late AppDatabase db;
  late RequestsPageController controller;
  final TextEditingController searchController = TextEditingController();

  // Expose controller properties for UI access
  int? get currentUserId => controller.currentUserId;
  int? get commissaryId => controller.commissaryId;
  int get selectedTab => controller.selectedTab;
  String get searchQuery => controller.searchQuery;
  String get requestSortOrder => controller.requestSortOrder;

  // Realtime stream subscriptions (must be cancelled in dispose)
  StreamSubscription<RealtimeConnectionStatus>? _statusSubscription;
  StreamSubscription<StockRequestEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    db = database;
    controller = RequestsPageController(
      db: db,
      onStateChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
    controller.loadContext();
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _eventSubscription?.cancel();
    realtimeStockRequestService.detach();
    searchController.dispose();
    super.dispose();
  }

  void setSearchQuery(String query) => controller.setSearchQuery(query);
  void setSelectedTab(int index) => controller.setSelectedTab(index);
  void setRequestSortOrder(String order) => controller.setRequestSortOrder(order);
  void refresh() => setState(() {});

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
          _statusSubscription = realtimeStockRequestService.statusStream.listen((status) {
            debugPrint('RequestsPage: realtime status=$status');
          });
          _eventSubscription = realtimeStockRequestService.eventStream.listen((event) {
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



  /// Get branch names for a list of requests
  Future<Map<int, String>> getBranchNames(
    List<StockReplenishmentRequest> requests,
  ) async {
    final branchIds = requests.map((r) => r.franchiseeId).toSet();
    final branchNames = <int, String>{};
    
    for (final branchId in branchIds) {
      final org = await db.organizationsDao.getOrganizationById(branchId);
      branchNames[branchId] = org?.name ?? 'Unknown Branch';
    }
    
    return branchNames;
  }

  /// Public method to approve a request
  void approveRequest(StockReplenishmentRequest request) {
    _approveRequest(request);
  }

  /// Public method to reject a request
  void rejectRequest(StockReplenishmentRequest request) {
    _rejectRequest(request);
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

  Future<Map<int, String>> getBranchNames(
    List<StockReplenishmentRequest> requests,
  ) =>
      controller.getBranchNames(requests);

  void approveRequest(StockReplenishmentRequest request) async {
    final confirmed = await controller.confirmApproval(request, context);
    if (confirmed) {
      await controller.approveRequest(request, context);
    }
  }

  void rejectRequest(StockReplenishmentRequest request) async {
    final reason = await controller.getRejectReason(context);
    if (reason != null) {
      await controller.rejectRequest(request, reason, context);
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

    if (AppLayout.isDesktop(context) == false) {
      return RequestsPageMobile(state: this);
    }
    return RequestsPageDesktop(state: this);
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
              onPressed: () => approveRequest(req),
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
              tooltip: 'Reject',
              onPressed: () => rejectRequest(req),
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
