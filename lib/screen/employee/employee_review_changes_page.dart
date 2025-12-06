import 'package:chickenjoo_inventory/screen/employee/item_change_record.dart';
import 'package:chickenjoo_inventory/screen/franchisee/franchisee_inventory.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/database/database_provider.dart';

class ReviewChangeDetailPage extends StatelessWidget {
  static List<ChangeRecord> records = [];
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

  // ✅ NEW: Apply changes to database
  Future<void> _applyChangesToDatabase() async {
    final db = DatabaseProvider.database;
    
    print('📊 Starting database update for ${record.items.length} items');
    
    for (final item in record.items) {
      print('🔍 Item: ${item.name} (ID: ${item.id}, Sold: ${item.sold}, Spoilage: ${item.spoilage})');
      
      // Validate item ID
      if (item.id <= 0) {
        throw Exception('Invalid item ID (${item.id}) for ${item.name}');
      }
      
      // Add sold and deduct from stock
      if (item.sold > 0) {
        print('  📉 Adding ${item.sold} sold units...');
        await db.itemsDao.addSold(item.id, item.sold);
      }
      
      // Add spoilage and deduct from stock
      if (item.spoilage > 0) {
        print('  📉 Adding ${item.spoilage} spoilage units...');
        await db.itemsDao.addSpoilage(item.id, item.spoilage);
      }
    }
    
    print('✅ Database update completed successfully');
  }

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
                    fontSize: 25,
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
                                records.remove(record);
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
                          print('🔵 Approve button pressed');
                          
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Approve and apply changes?'),
                              content: const Text(
                                  'This will update the inventory with sold/spoilage data and deduct from stock.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    print('🔵 User cancelled approval');
                                    Navigator.pop(ctx, false);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                  onPressed: () {
                                    print('🔵 User confirmed approval');
                                    Navigator.pop(ctx, true);
                                  },
                                  child: const Text('Approve'),
                                ),
                              ],
                            ),
                          );
                          
                          print('🔵 Dialog result: $confirmed');
                          
                          if (confirmed == true) {
                            print('🔵 Starting approval process...');
                            
                            // Show loading indicator
                            if (!context.mounted) {
                              print('❌ Context not mounted before showing snackbar');
                              return;
                            }
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Applying changes...')),
                            );

                            try {
                              print('🔵 Calling _applyChangesToDatabase...');
                              await _applyChangesToDatabase();
                              print('✅ Database changes applied');
                              
                              // Update status
                              record.status = 'Approved';
                              
                              if (onApprove != null) {
                                print('🔵 Calling onApprove callback');
                                onApprove!(record);
                              } else {
                                print('🔵 Using default approval handling');
                                try {
                                  InventoryPage.pendingChanges.add(record);
                                  records.remove(record);
                                } catch (e) {
                                  print('⚠️ Error updating lists: $e');
                                }
                              }
                              
                              if (!context.mounted) {
                                print('❌ Context not mounted after approval');
                                return;
                              }
                              
                              print('🔵 Showing success message');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ Changes applied successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              
                              // Small delay to show the snackbar
                              await Future.delayed(const Duration(milliseconds: 500));
                              
                              if (!context.mounted) {
                                print('❌ Context not mounted before pop');
                                return;
                              }
                              
                              print('🔵 Popping navigation');
                              Navigator.of(context).pop();
                              print('✅ Navigation popped successfully');
                              
                            } catch (e, stackTrace) {
                              print('❌ ERROR during approval: $e');
                              print('❌ Stack trace: $stackTrace');
                              
                              if (!context.mounted) {
                                print('❌ Context not mounted during error handling');
                                return;
                              }
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('❌ Error: $e'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'APPROVE CHANGES',
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