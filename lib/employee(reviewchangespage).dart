import 'package:chickenjoo_inventory/changerecord.dart';
import 'package:chickenjoo_inventory/data/employee(reviewchanges).dart';
import 'package:chickenjoo_inventory/franchisee(inventory).dart';
import 'package:chickenjoo_inventory/designconstants.dart';
import 'package:flutter/material.dart';

class ReviewChangeDetailPage extends StatelessWidget {
  final ChangeRecord record;
  final VoidCallback? onBack;
  final ValueChanged<ChangeRecord>? onDelete;
  final ValueChanged<ChangeRecord>? onApprove;

  const ReviewChangeDetailPage({
    super.key,
    required this.record,
    this.onBack,
    this.onDelete,
    this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack ?? () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, size: 30),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Review Change Details",
                  style: TextStyle(
                    fontFamily: fontAll,
                    fontSize: 30,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 35),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Employee Info
          const SizedBox(width: 16),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Employee Name:', style: TextStyle(color: Colors.grey)),
                      Text(record.employeeName, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Role:', style: TextStyle(color: Colors.grey)),
                      Text(record.role, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status:', style: TextStyle(color: Colors.grey)),
                      Text(record.status, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Table Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                Expanded(child: Center(child: Text('Sold', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('Spoilage', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(flex: 2, child: Center(child: Text('Current Stock', style: TextStyle(fontWeight: FontWeight.bold)))),
              ],
            ),
          ),

          // Items List
          Expanded(
            child: ListView.builder(
              itemCount: record.items.length,
              itemBuilder: (context, index) {
                final item = record.items[index];
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          child: Text(item.name),
                        ),
                      ),
                      Expanded(child: Center(child: Text(item.sold.toString()))),
                      Expanded(child: Center(child: Text(item.spoilage.toString()))),
                      Expanded(flex: 2, child: Center(child: Text(item.stock.toString()))),
                    ],
                  ),
                );
              },
            ),
          ),

          // Footer
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total Items: ${record.items.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete update?'),
                              content: const Text(
                                  'Are you sure you want to delete this update?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('No'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Yes'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            if (onDelete != null) {
                              onDelete!(record);
                            } else {
                              try {
                                ReviewChangesPage.records.remove(record);
                              } catch (_) {}
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: const Text(
                          'DELETE UPDATE',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A8F1A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Send update to franchisee?'),
                              content: const Text(
                                  'Send this update to the franchisee inventory?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('No'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Yes'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            if (onApprove != null) {
                              onApprove!(record);
                            } else {
                              record.status = 'Updated';
                              try {
                                InventoryPage.pendingChanges.add(record);
                              } catch (_) {}
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: const Text(
                          'SEND TO FRANCHISEE',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
