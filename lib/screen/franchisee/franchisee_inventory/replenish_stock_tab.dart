// lib/screen/franchisee/franchisee_inventory/replenish_stock_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/database/models/item_with_branch_stock.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/design_constants.dart';

/// Widget for requesting stock replenishment from commissary
class ReplenishStockTab extends StatefulWidget {
  final int branchId;
  final int commissaryId;
  final int userId;
  final List<ItemWithBranchStock> items;

  const ReplenishStockTab({
    super.key,
    required this.branchId,
    required this.commissaryId,
    required this.userId,
    required this.items,
  });

  @override
  State<ReplenishStockTab> createState() => _ReplenishStockTabState();
}

class _ReplenishStockTabState extends State<ReplenishStockTab> {
  late AppDatabase db;
  late List<TextEditingController> qtyControllers;
  List<StockReplenishmentRequest> existingRequests = [];
  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    db = database;
    qtyControllers = List.generate(
      widget.items.length,
      (_) => TextEditingController(),
    );
    _syncAndLoadRequests();
  }

  Future<void> _syncAndLoadRequests() async {
    // First sync to get latest status updates from cloud
    try {
      print('🔄 Syncing replenishment requests...');
      await AppGlobals.instance.syncService.syncStockReplenishmentRequests();
    } catch (e) {
      print('⚠️ Sync failed: $e');
    }
    // Then load from local DB
    await _loadExistingRequests();
  }

  @override
  void dispose() {
    for (var c in qtyControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadExistingRequests() async {
    try {
      final requests = await db.stockReplenishmentRequestsDao
          .getFranchiseeRequestHistory(widget.branchId, limit: 20);
      if (mounted) {
        setState(() {
          existingRequests = requests;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading requests: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _submitRequests() async {
    // Validate user ID before submitting
    if (widget.userId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: User not logged in properly. Please re-login.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Collect items with quantities > 0
    final requestItems = <MapEntry<ItemWithBranchStock, int>>[];
    for (int i = 0; i < widget.items.length; i++) {
      final qty = int.tryParse(qtyControllers[i].text.trim()) ?? 0;
      if (qty > 0) {
        requestItems.add(MapEntry(widget.items[i], qty));
      }
    }

    if (requestItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter quantity for at least one item'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      for (final entry in requestItems) {
        await db.stockReplenishmentRequestsDao.createRequest(
          franchiseeId: widget.branchId,
          commissaryId: widget.commissaryId,
          itemId: entry.key.id,
          quantityRequested: entry.value,
          requestedBy: widget.userId,
          franchiseeNotes: null,
        );
        print('📝 Created request for ${entry.key.name}: ${entry.value} units');
      }

      // Clear inputs
      for (var c in qtyControllers) {
        c.clear();
      }

      // Auto-sync to push requests to commissary
      try {
        print('🔄 Auto-syncing replenishment requests...');
        await AppGlobals.instance.syncService.syncStockReplenishmentRequests();
        print('✅ Requests synced to cloud');
      } catch (syncError) {
        print('⚠️ Sync failed (will retry later): $syncError');
      }

      // Reload requests
      await _loadExistingRequests();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Submitted ${requestItems.length} request(s)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error submitting requests: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Request form section
        const Text(
          'Request Stock from Commissary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: fontAll,
          ),
        ),
        const SizedBox(height: 12),
        
        // Items table with quantity inputs
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(flex: 3, child: Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Current Stock', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      Expanded(flex: 2, child: Text('Request Qty', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                // Items list
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 3, child: Text(item.name)),
                            Expanded(
                              flex: 2,
                              child: Text(
                                item.stock.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: item.isLowStock ? Colors.red : Colors.black,
                                  fontWeight: item.isLowStock ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: TextField(
                                  controller: qtyControllers[index],
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE30417),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: isSubmitting ? null : _submitRequests,
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'SUBMIT REQUEST',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Existing requests section with refresh button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: fontAll,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh to see latest status',
              onPressed: isLoading ? null : () {
                setState(() => isLoading = true);
                _syncAndLoadRequests();
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Expanded(
          flex: 1,
          child: existingRequests.isEmpty
              ? Center(
                  child: Text(
                    'No requests yet',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              : ListView.builder(
                  itemCount: existingRequests.length,
                  itemBuilder: (context, index) {
                    final req = existingRequests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: FutureBuilder<Item?>(
                          future: db.itemsDao.getItemById(req.itemId),
                          builder: (context, snapshot) {
                            return Text(snapshot.data?.name ?? 'Item #${req.itemId}');
                          },
                        ),
                        subtitle: Text('Qty: ${req.quantityRequested}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(req.status),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            req.status.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
