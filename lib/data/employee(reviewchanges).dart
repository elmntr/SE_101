import 'package:chickenjoo_inventory/changerecord.dart';
import 'package:chickenjoo_inventory/employee(reviewchangespage).dart';
import 'package:chickenjoo_inventory/franchisee(inventory).dart';
import 'package:chickenjoo_inventory/designconstants.dart';
import 'package:flutter/material.dart';

class ReviewChangesPage extends StatefulWidget {
  final VoidCallback onBack;
  static List<ChangeRecord> records = [];

  const ReviewChangesPage({super.key, required this.onBack});

  @override
  State<ReviewChangesPage> createState() => _ReviewChangesPageState();
}

class _ReviewChangesPageState extends State<ReviewChangesPage> {
  @override
  Widget build(BuildContext context) {
    if (ReviewChangesPage.records.isEmpty) {
      return Scaffold(
        backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back, size: 30),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Review Changes",
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
            Expanded(
              child: Center(
                child: Text(
                  "No changes in review.",
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      );
    }

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
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back, size: 30),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Review Changes",
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

          // Table Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      'Employee Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Role',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Total Changes',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Action',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Changes List
          Expanded(
            child: ListView.builder(
              itemCount: ReviewChangesPage.records.length,
              itemBuilder: (context, index) {
                final record = ReviewChangesPage.records[index];
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
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          child: Text(record.employeeName),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(child: Text(record.role)),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(record.totalChanges.toString()),
                        ),
                      ),
                      Expanded(
                        child: Center(child: Text(record.status)),
                      ),
                      Expanded(
                        child: Center(
                          child: ElevatedButton(
                            child: const Text("View"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReviewChangeDetailPage(
                                    record: record,
                                    onBack: () => Navigator.pop(context),
                                    onDelete: (rec) {
                                      setState(() {
                                        ReviewChangesPage.records.remove(rec);
                                      });
                                      Navigator.pop(context);
                                    },
                                    onApprove: (rec) {
                                      setState(() {
                                        final idx = ReviewChangesPage.records.indexOf(rec);
                                        if (idx != -1) ReviewChangesPage.records[idx].status = 'Updated';
                                        try {
                                          InventoryPage.pendingChanges.add(rec);
                                        } catch (_) {}
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              );
                            },
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total Records: ${ReviewChangesPage.records.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
