// lib/screens/requests/requests_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/design_constants.dart';


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
    searchController.dispose();
    super.dispose();
  }

  void setSearchQuery(String query) => controller.setSearchQuery(query);
  void setSelectedTab(int index) => controller.setSelectedTab(index);
  void setRequestSortOrder(String order) => controller.setRequestSortOrder(order);
  void refresh() => setState(() {});

  List<StockReplenishmentRequest> sortRequests(
    List<StockReplenishmentRequest> requests,
  ) =>
      controller.sortRequests(requests);

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
