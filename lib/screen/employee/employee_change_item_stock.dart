import 'package:chickenjoo_inventory/screen/employee/item_change_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/local/app_database.dart';
import '../../../data/database_provider.dart';
import '../../design_constants.dart';

class EmployeeChangeStockPage extends StatefulWidget {
  final VoidCallback onBack;
  final ValueChanged<ChangeRecord>? onRecordSaved;

  const EmployeeChangeStockPage({
    super.key,
    required this.onBack,
    this.onRecordSaved,
  });

  @override
  State<EmployeeChangeStockPage> createState() => _EmployeeChangeStockPageState();
}

class _EmployeeChangeStockPageState extends State<EmployeeChangeStockPage> {
  late AppDatabase db;
  List<Item> items = [];
  bool isLoading = true;

  late List<String> selectedReasons;
  late List<TextEditingController> qtyControllers;

  

  @override
  void initState() {
    super.initState();
    db = DatabaseProvider.instance;
    _loadItems();
  }

  @override
  void dispose() {
    // dispose controllers if initialized
    try {
      for (var c in qtyControllers) {
        c.dispose();
      }
    } catch (_) {}
    super.dispose();
  }

  Future<void> _loadItems() async {
    final loaded = await db.getAllItems();
    setState(() {
      items = loaded;
      selectedReasons = loaded
          .map((item) => item.sold > 0 ? 'Sale' : 'Spoilage')
          .toList();
      isLoading = false;
      qtyControllers = loaded
          .map((item) => TextEditingController(
              text: item.sold > 0
                  ? item.sold.toString()
                  : (item.spoilage > 0 ? item.spoilage.toString() : '')))
          .toList();
    });
  }

  int get totalSold => items.fold(0, (sum, item) => sum + item.sold);
  int get totalSpoiled => items.fold(0, (sum, item) => sum + item.spoilage);

  void _saveChanges() {
    // Validate controllers: ensure only digits or empty
    for (var c in qtyControllers) {
      final txt = c.text.trim();
        if (txt.isNotEmpty && !RegExp(r'^\d+$').hasMatch(txt)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter only numbers for quantities.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Update items from controllers before creating record
    for (int i = 0; i < items.length; i++) {
      final txt = qtyControllers[i].text.trim();
      final qty = txt.isEmpty ? 0 : int.tryParse(txt) ?? 0;
      if (selectedReasons[i] == 'Sale') {
        items[i] = items[i].copyWith(sold: qty);
      } else {
        items[i] = items[i].copyWith(spoilage: qty);
      }
    }

    final record = ChangeRecord(
      employeeName: "Employee 1",
      role: "Cashier",
      items: List.from(items.map((i) => i.copyWith())),
    );

    // Reset sold/spoilage
    setState(() {
      items = items.map((i) => i.copyWith(sold: 0, spoilage: 0)).toList();
      selectedReasons = items.map((i) => "Sale").toList();
      // clear controllers
      for (var c in qtyControllers) {
        c.text = '';
      }
    });

    // Send record back (if a handler was provided)
    widget.onRecordSaved?.call(record);

    // Go back to main page
    widget.onBack();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Changes sent for review!"), backgroundColor: Colors.green),
    );
  }



  @override
  Widget build(BuildContext context) {
    
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(

      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back,
                      size: 30),
                ),

                const SizedBox(width: 10),

                const Text(
                  "Change Item Stock",
                  style: TextStyle(
                    fontFamily: fontAll,
                    fontSize: 30,
                  ),
                ),

                const Spacer(),

                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      size: 35,),
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
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Employee Name:', style: TextStyle(color: Colors.grey)),
                      Text('Employee 1', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Role:', style: TextStyle(color: Colors.grey)),
                      Text('Cashier', style: TextStyle(fontSize: 16)),
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
                Expanded(flex: 3, child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold)),
                )),
                Expanded(flex: 2, child: Center(child: Text('Reason', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(flex: 2, child: Center(child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(flex: 2, child: Center(child: Text('Current', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('Sold', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('Spoiled', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(flex: 2, child: Center(child: Text('New Stock', style: TextStyle(fontWeight: FontWeight.bold)))),
              ],
            ),
          ),

          // Items List
          Expanded(

            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final newStock = item.stock - item.sold - item.spoilage;

                return Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          bottom: BorderSide(color: Colors.grey))),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            child: Text(item.name),
                          )),

                      // Reason
                      Expanded(
                        flex: 2,
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedReasons[index],
                          underline: const SizedBox(),
                          items: ['Sale', 'Spoilage']
                              .map((r) => DropdownMenuItem(
                                    value: r,
                                    child: Center(child: Text(r)),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedReasons[index] = value!;
                              if (value == 'Sale') {
                                items[index] = item.copyWith(spoilage: 0);
                              } else {
                                items[index] = item.copyWith(sold: 0);
                              }
                              // clear qty input when reason changes
                              try {
                                qtyControllers[index].text = '';
                              } catch (_) {}
                            });
                          },
                        ),
                      ),

                      // Qty Input
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: qtyControllers[index],
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            hintText: '0',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: (val) {
                            final qty = int.tryParse(val) ?? 0;
                            setState(() {
                              if (selectedReasons[index] == 'Sale') {
                                items[index] = item.copyWith(sold: qty);
                              } else {
                                items[index] = item.copyWith(spoilage: qty);
                              }
                            });
                          },
                        ),
                      ),

                      Expanded(flex: 2, child: Center(child: Text(item.stock.toString()))),
                      Expanded(child: Center(child: Text(item.sold.toString()))),
                      Expanded(child: Center(child: Text(item.spoilage.toString()))),
                      Expanded(flex: 2, child: Center(child: Text(newStock < 0 ? '0' : '$newStock'))),
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
                      Text('Total Sold: $totalSold',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Total Spoiled: $totalSpoiled',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
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
                          borderRadius: BorderRadius.circular(30)),
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
