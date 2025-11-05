import 'package:chickenjoo_inventory/designconstants.dart';
import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String selectedItem = 'All Items';
  String selectedPeriod = 'Weekly';
  DateTime currentDate = DateTime.now();
  String selectedMetric = 'sold';

  final List<String> items = ['All Items', 'Item 1', 'Item 2', 'Item 3'];
  final List<String> periods = ['Weekly', 'Monthly', 'Yearly'];

  final Map<String, Map<String, List<double>>> chartData = {
    'sold': {
      'Weekly': [400, 350, 320, 380, 410, 300, 340],
      'Monthly': [1200, 1500, 1300, 1400, 1600, 1350],
      'Yearly': [15000, 18000, 16500],
    },
    'spoilage': {
      'Weekly': [150, 120, 100, 140, 130, 110, 125],
      'Monthly': [500, 600, 450, 550, 620, 480],
      'Yearly': [6000, 7500, 6800],
    },
  };

  String getDateRangeText() {
    if (selectedPeriod == 'Weekly') {
      final start = currentDate.subtract(const Duration(days: 6));
      return '${_formatDate(start)} - ${_formatDate(currentDate)}';
    } else if (selectedPeriod == 'Monthly') {
      final start = DateTime(currentDate.year, currentDate.month - 5, 1);
      return '${_formatMonthYear(start)} - ${_formatMonthYear(currentDate)}';
    } else {
      final start = currentDate.year - 2;
      return '$start - ${currentDate.year}';
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatMonthYear(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }

  List<String> getChartLabels() {
    if (selectedPeriod == 'Weekly') {
      return ['Sep 28', 'Sep 29', 'Sep 30', 'Oct 1', 'Oct 2', 'Oct 3', 'Oct 4'];
    } else if (selectedPeriod == 'Monthly') {
      return ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'];
    } else {
      return ['2023', '2024', '2025'];
    }
  }

  void navigateDate(bool forward) {
    setState(() {
      if (selectedPeriod == 'Weekly') {
        currentDate = forward
            ? currentDate.add(const Duration(days: 7))
            : currentDate.subtract(const Duration(days: 7));
      } else if (selectedPeriod == 'Monthly') {
        currentDate = forward
            ? DateTime(currentDate.year, currentDate.month + 6, 1)
            : DateTime(currentDate.year, currentDate.month - 6, 1);
      } else {
        currentDate = forward
            ? DateTime(currentDate.year + 3, 1, 1)
            : DateTime(currentDate.year - 3, 1, 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = chartData[selectedMetric]![selectedPeriod]!;
    final maxValue = data.reduce((a, b) => a > b ? a : b);
  
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reports',
                  style: TextStyle(fontSize: 30, fontFamily: fontAll),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  iconSize: 35,
                  onPressed: () {},
                )
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    child: DropdownButton<String>(
                      value: selectedItem,
                      isExpanded: true,
                      dropdownColor: Colors.red,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.keyboard_arrow_up, color: Colors.black),
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                      onChanged: (value) => setState(() => selectedItem = value!),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  child: DropdownButton<String>(
                    value: selectedPeriod,
                    dropdownColor: Colors.white,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_up, color: Colors.black),
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    items: periods.map((period) => DropdownMenuItem(value: period, child: Text(period))).toList(),
                    onChanged: (value) => setState(() => selectedPeriod = value!),
                  ),
                ),
                const SizedBox(width: 12),

                // Date navigation
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.red),
                        onPressed: () => navigateDate(false),
                      ),
                      Text(getDateRangeText(), style: const TextStyle(fontSize: 13)),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.red),
                        onPressed: () => navigateDate(true),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedMetric = 'sold'),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: selectedMetric == 'sold' ? Colors.red : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.only(bottom: 8),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Amount Sold', style: TextStyle(fontSize: 14)),
                                  SizedBox(height: 8),
                                  Text('1200', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedMetric = 'spoilage'),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: selectedMetric == 'spoilage' ? Colors.red : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.only(bottom: 8),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Spoilage', style: TextStyle(fontSize: 14)),
                                  SizedBox(height: 8),
                                  Text('600', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Chart
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 12, bottom: 20),
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Text('Stock Amount', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: List.generate(data.length, (index) {
                                      final value = data[index];
                                      final heightPercent = value / maxValue;

                                      return Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: FractionallySizedBox(
                                            heightFactor: heightPercent,
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: getChartLabels().map(
                                    (label) => Expanded(
                                      child: Text(label,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                    ),
                                  ).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
