import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'franchisee_reports.dart';

class ReportsPageDesktop extends StatelessWidget {
  final ReportsPageState state;

  const ReportsPageDesktop({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Get current data for the selected metric
    final data = state.chartData[state.selectedMetric] ?? List.filled(7, 0.0);
    final maxValue = data.isEmpty ? 1.0 : data.reduce((a, b) => a > b ? a : b);

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
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return PopupMenuButton<int?>(
                        color: Colors.white,
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                state.getSelectedItemName(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: null,
                            child: Text('All Items'),
                          ),
                          ...state.allItems.map(
                            (item) => PopupMenuItem(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          state.setState(() {
                            state.selectedItemId = value;
                            state.calculateChartData();
                            state.calculateTotals();
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return PopupMenuButton<String>(
                      color: Colors.white,
                      constraints: const BoxConstraints(minWidth: 120),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              state.selectedPeriod,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      itemBuilder: (context) => state.periods
                          .map(
                            (period) => PopupMenuItem(
                              value: period,
                              child: Text(period),
                            ),
                          )
                          .toList(),
                      onSelected: (value) {
                        state.setState(() {
                          state.selectedPeriod = value;
                          state.calculateChartData();
                        });
                      },
                    );
                  },
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
                        onPressed: () => state.navigateDate(false),
                      ),
                      Text(
                        state.getDateRangeText(),
                        style: const TextStyle(fontSize: 13),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Colors.red,
                        ),
                        onPressed: () => state.navigateDate(true),
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
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                state.setState(() => state.selectedMetric = 'sold'),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: state.selectedMetric == 'sold'
                                        ? Colors.red
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Amount Sold',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    state.totalSold.toStringAsFixed(0),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                state.setState(() => state.selectedMetric = 'spoilage'),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: state.selectedMetric == 'spoilage'
                                        ? Colors.red
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Spoilage',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    state.totalSpoilage.toStringAsFixed(0),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                            padding: const EdgeInsets.only(
                              right: 12,
                              bottom: 20,
                            ),
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Text(
                                'Stock Amount',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: List.generate(data.length, (
                                      index,
                                    ) {
                                      final value = data[index];
                                      final heightPercent = maxValue > 0
                                          ? (value / maxValue).clamp(0.0, 1.0)
                                          : 0.01;

                                      return Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: FractionallySizedBox(
                                            heightFactor: heightPercent.clamp(
                                              0.0,
                                              1.0,
                                            ),
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                      top: Radius.circular(2),
                                                    ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: state.getChartLabels()
                                      .map(
                                        (label) => Expanded(
                                          child: Text(
                                            label,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
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
            ),
          ],
        ),
      ),
    );
  }
}