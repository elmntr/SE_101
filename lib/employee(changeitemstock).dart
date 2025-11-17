import 'package:flutter/material.dart';
import '../data/local/app_database.dart';
import '../data/database_provider.dart';
import 'designconstants.dart';

class EmployeeChangeStockPage extends StatefulWidget {
  final VoidCallback onBack;
  const EmployeeChangeStockPage({super.key, required this.onBack});

  @override
  State<EmployeeChangeStockPage> createState() => _EmployeeChangeStockPageState();
}

class _EmployeeChangeStockPageState extends State<EmployeeChangeStockPage> {
  late AppDatabase db;
  List<Item> items = [];
  bool isLoading = true;

  late List<String> selectedReasons;

  @override
  void initState() {
    super.initState();
    db = DatabaseProvider.instance;
    _loadItems();
  }

  Future<void> _loadItems() async {
    final loaded = await db.getAllItems();
    setState(() {
      items = loaded;
      selectedReasons = loaded
          .map((item) => item.sold > 0 ? 'Sale' : 'Spoilage')
          .toList();
      isLoading = false;
    });
  }

  int get totalSold => items.fold(0, (sum, item) => sum + item.sold);
  int get totalSpoiled => items.fold(0, (sum, item) => sum + item.spoilage);

  Future<void> _saveChanges() async {
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final newStock = item.stock - item.sold - item.spoilage;

      await db.updateItemData(
        item.copyWith(stock: newStock < 0 ? 0 : newStock),
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Changes saved na!'),
          backgroundColor: Colors.green,
        ),
      );
    }
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
                            });
                          },
                        ),
                      ),

                      // Qty Input
                      Expanded(
                        flex: 2,
                        child: TextField(
                          keyboardType: TextInputType.number,
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
