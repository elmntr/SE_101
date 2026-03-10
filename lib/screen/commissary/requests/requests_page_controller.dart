// lib/screens/requests/requests_page_controller.dart
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';

class RequestsPageController {
  final AppDatabase db;
  final VoidCallback onStateChanged;

  int? currentUserId;
  int? commissaryId;
  String? commissaryCloudId;

  int selectedTab = 0;
  String searchQuery = '';
  String requestSortOrder = 'newestFirst';

  RequestsPageController({
    required this.db,
    required this.onStateChanged,
  });

  Future<void> loadContext() async {
    debugPrint('RequestsPageController: loading context...');
    final user = AppGlobals.instance.authService.currentUser;
    debugPrint(
      'RequestsPageController: currentUser=${user?.id} orgId=${user?.organizationId}',
    );
    if (user != null) {
      currentUserId = user.id;
      commissaryId = user.organizationId;
      onStateChanged();

      try {
        final org =
            await db.organizationsDao.getOrganizationById(user.organizationId);
        debugPrint('RequestsPageController: org cloudId=${org?.cloudId}');
        if (org?.cloudId != null) {
          commissaryCloudId = org!.cloudId;
          debugPrint(
            'RequestsPageController: commissaryCloudId=$commissaryCloudId (realtime managed by RequestsPage)',
          );
        }
      } catch (e) {
        debugPrint(
          'RequestsPageController: WARN Failed to load org: $e',
        );
      }
    } else {
      debugPrint('RequestsPageController: no currentUser yet');
    }
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    onStateChanged();
  }

  void setSelectedTab(int index) {
    selectedTab = index;
    onStateChanged();
  }

  void setRequestSortOrder(String order) {
    requestSortOrder = order;
    onStateChanged();
  }

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

  Future<bool> confirmApproval(
    StockReplenishmentRequest request,
    BuildContext context,
  ) async {
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

    return confirmed ?? false;
  }

  Future<void> approveRequest(
    StockReplenishmentRequest request,
    BuildContext context,
  ) async {
    if (currentUserId == null) return;

    try {
      // 1. Check commissary stock
      final item = await db.itemsDao.getItemById(request.itemId);
      if (item == null) {
        throw Exception(
          'Item not found in commissary (itemId: ${request.itemId})',
        );
      }

      print(
        'ðŸ“¦ Item found: ${item.name} (id=${item.id}, cloudId=${item.cloudId})',
      );
      print(
        '   Current stock: ${item.stock}, Requested: ${request.quantityRequested}',
      );

      if (item.stock < request.quantityRequested) {
        if (context.mounted) {
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
      print('ðŸ“¦ updateStock returned: $rowsUpdated rows updated');
      print(
        'ðŸ“¦ Reduced commissary stock for item ${item.name}: ${item.stock} â†’ $newStock',
      );

      // Verify the update worked
      final updatedItem = await db.itemsDao.getItemById(request.itemId);
      print(
        'ðŸ"¦ Verification - Item after update: stock=${updatedItem?.stock}, isSynced=${updatedItem?.isSynced}',
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
        print('ðŸ”„ Auto-syncing after approval...');
        await syncService.syncAll();
        print('âœ… Approval synced to cloud');
      } catch (syncError) {
        print('âš ï¸ Sync failed (will retry later): $syncError');
      }

      if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('âœ… Request approved and stock transferred'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error approving request: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<String?> getRejectReason(BuildContext context) async {
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

    if (confirmed == true) {
      return reasonController.text.trim();
    }
    return null;
  }

  Future<void> rejectRequest(
    StockReplenishmentRequest request,
    String reason,
    BuildContext context,
  ) async {
    if (currentUserId == null) return;

    try {
      await db.stockReplenishmentRequestsDao.rejectRequest(
        requestId: request.id,
        reviewedBy: currentUserId!,
        reason: reason,
      );

      // Auto-sync to push rejection to cloud
      try {
        print('ðŸ”„ Auto-syncing after rejection...');
        await syncService.syncAll();
        print('âœ… Rejection synced to cloud');
      } catch (syncError) {
        print('âš ï¸ Sync failed (will retry later): $syncError');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request rejected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error rejecting request: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
