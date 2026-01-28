// lib/screen/employee/employee_change_item_stock.dart
import 'package:chickenjoo_inventory/screen/employee/item_change_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../database/app_database.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';

import '../../design_constants.dart';

class EmployeeChangeStockPage extends StatefulWidget {
  final UserData userData;
  final VoidCallback onBack;
  final ValueChanged<ChangeRecord>? onRecordSaved;

  const EmployeeChangeStockPage({
    super.key,
    required this.userData,
    required this.onBack,
    this.onRecordSaved,
  });


  @override
  State<EmployeeChangeStockPage> createState() =>
      _EmployeeChangeStockPageState();
}

class _EmployeeChangeStockPageState extends State<EmployeeChangeStockPage> {
  late AppDatabase db;
  List<Item> items = [];
  bool isLoading = true;

  // Track pending changes separately (don't modify actual items yet)
  late List<String> selectedReasons;
  late List<int> pendingSold;
  late List<int> pendingSpoilage;
  late List<TextEditingController> qtyControllers;

  @override
  void initState() {
    super.initState();
    db = database;
    _loadItems();
  }

  @override
  void dispose() {
    for (var c in qtyControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadItems() async {
    // Load commissary items instead of local organization items
    // Find commissary organization (type = 'commissary')
    final allOrgs = await db.organizationsDao.getAllOrganizations();
    final commissary = allOrgs.firstWhere(
      (org) => org.type == 'commissary',
      orElse: () => allOrgs.first, // Fallback to first org if no commissary found
    );
    
    print('📍 Loading commissary items from org: ${commissary.name} (ID: ${commissary.id})');

    final loaded = await db.itemsDao.getItemsByOrganization(commissary.id);

    setState(() {
      items = loaded;
      selectedReasons = List.filled(loaded.length, 'Sale');
      pendingSold = List.filled(loaded.length, 0);
      pendingSpoilage = List.filled(loaded.length, 0);
      qtyControllers = List.generate(
        loaded.length,
        (_) => TextEditingController(),
      );
      isLoading = false;
    });
  }

  int get totalSold => pendingSold.fold(0, (sum, qty) => sum + qty);
  int get totalSpoiled => pendingSpoilage.fold(0, (sum, qty) => sum + qty);

  /// ✅ Save changes directly to item stock and record who made the change
  Future<void> _saveChanges() async {
    // Validate input
    bool hasChanges = false;
    for (var c in qtyControllers) {
      final txt = c.text.trim();
      if (txt.isNotEmpty) {
        hasChanges = true;
        if (!RegExp(r'^\d+$').hasMatch(txt)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter only numbers for quantities.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    if (!hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes to save.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      List<Item> changedItems = [];

      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final soldQty = pendingSold[i];
        final spoilageQty = pendingSpoilage[i];

        if (soldQty > 0 || spoilageQty > 0) {
          // ✅ Directly update item stock - reduce by sold + spoiled
          final newStock = item.stock - soldQty - spoilageQty;
          final updatedSold = item.sold + soldQty;
          final updatedSpoilage = item.spoilage + spoilageQty;
          
          print('📝 Updating item ${item.name}: stock ${item.stock} → $newStock, sold ${item.sold} → $updatedSold, spoilage ${item.spoilage} → $updatedSpoilage');
          
          final updateSuccess = await db.itemsDao.updateItem(
            item.copyWith(
              stock: newStock,
              sold: updatedSold,
              spoilage: updatedSpoilage,
            ),
          );
          
          print(updateSuccess ? '   ✅ Item updated successfully' : '   ❌ Item update failed');

          // ✅ Record the change in stock_change_requests for audit trail (already applied)
          if (soldQty > 0) {
            final requestId = await db.stockChangeRequestsDao.createChangeRequest(
              franchiseeId: widget.userData.organizationId,
              itemId: item.id,
              changeType: 'sold',
              quantity: soldQty,
              requestedBy: widget.userData.id,
              originalStock: item.stock,
              reason: 'Employee stock change - ${widget.userData.fullName ?? widget.userData.username}',
            );
            // Mark as applied since we already updated the stock
            await db.stockChangeRequestsDao.submitChangeRequest(requestId);
          }

          if (spoilageQty > 0) {
            final requestId = await db.stockChangeRequestsDao.createChangeRequest(
              franchiseeId: widget.userData.organizationId,
              itemId: item.id,
              changeType: 'spoiled',
              quantity: spoilageQty,
              requestedBy: widget.userData.id,
              originalStock: item.stock,
              reason: 'Employee stock change - ${widget.userData.fullName ?? widget.userData.username}',
            );
            // Mark as applied since we already updated the stock
            await db.stockChangeRequestsDao.submitChangeRequest(requestId);
          }

          changedItems.add(item.copyWith(sold: soldQty, spoilage: spoilageQty));
        }
      }

      if (changedItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No changes to save.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Create in-memory record for UI callback (if needed)
      final record = ChangeRecord(
        employeeName: widget.userData.fullName ?? widget.userData.username,
        role: widget.userData.roleName,
        items: changedItems,
      );

      // Reset UI and reload items to show updated stock
      await _loadItems();
      
      setState(() {
        selectedReasons = List.filled(items.length, 'Sale');
        pendingSold = List.filled(items.length, 0);
        pendingSpoilage = List.filled(items.length, 0);
        for (var c in qtyControllers) {
          c.clear();
        }
      });

      widget.onRecordSaved?.call(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Stock updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error saving changes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back, size: 30),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Change Item Stock",
                  style: TextStyle(fontFamily: fontAll, fontSize: 25),
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
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Employee Name:',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        widget.userData.fullName ?? widget.userData.username,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Role:', style: TextStyle(color: Colors.grey)),
                      Text(
                        widget.userData.roleName,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Table header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      'Item Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Reason',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Qty',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Current Stock',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'New Stock',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items list
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'No items available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final newStock =
                          item.stock -
                          pendingSold[index] -
                          pendingSpoilage[index];

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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 20,
                                ),
                                child: Text(item.name),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedReasons[index],
                                underline: const SizedBox(),
                                items: ['Sale', 'Spoilage']
                                    .map(
                                      (r) => DropdownMenuItem(
                                        value: r,
                                        child: Center(child: Text(r)),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedReasons[index] = value!;
                                    qtyControllers[index].clear();
                                    pendingSold[index] = 0;
                                    pendingSpoilage[index] = 0;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: TextField(
                                  controller: qtyControllers[index],
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  onChanged: (val) {
                                    final qty = int.tryParse(val) ?? 0;

                                    if (qty > item.stock) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Cannot exceed current stock (${item.stock})',
                                          ),
                                          backgroundColor: Colors.orange,
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                      qtyControllers[index].text = item.stock
                                          .toString();
                                      return;
                                    }

                                    setState(() {
                                      if (selectedReasons[index] == 'Sale') {
                                        pendingSold[index] = qty;
                                        pendingSpoilage[index] = 0;
                                      } else {
                                        pendingSpoilage[index] = qty;
                                        pendingSold[index] = 0;
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(child: Text(item.stock.toString())),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  newStock < 0 ? '0' : '$newStock',
                                  style: TextStyle(
                                    color: newStock < 0
                                        ? Colors.red
                                        : Colors.black,
                                    fontWeight: newStock < 0
                                        ? FontWeight.bold
                                        : FontWeight.normal,
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

          // Footer
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Sold: $totalSold',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Total Spoiled: $totalSpoiled',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE30417),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _saveChanges,
                    child: const Text(
                      'SAVE CHANGES',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
