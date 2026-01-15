import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'franchisee_reports.dart';

class ReportsPageMobile extends StatelessWidget {
  final ReportsPageState state;

  const ReportsPageMobile({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Get current data for the selected metric
    final data = state.chartData[state.selectedMetric] ?? List.filled(7, 0.0);
    final maxValue = data.isEmpty ? 1.0 : data.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reports',
                    style: TextStyle(fontSize: 26, fontFamily: fontAll),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 28),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // FILTERS (STACKED FOR PHONE)
              Column(
                children: [
                  // ITEM SELECTOR + PERIOD
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
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      state.getSelectedItemName(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down),
                                  ],
                                ),
                              ),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: null,
                                  child: Text(
                                    'All Items',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                ...state.allItems.map(
                                  (item) => PopupMenuItem(
                                    value: item.id,
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
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

                      const SizedBox(width: 8),

                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return PopupMenuButton<String>(
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
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      state.selectedPeriod,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down),
                                  ],
                                ),
                              ),
                              itemBuilder: (context) => state.periods
                                  .map(
                                    (period) => PopupMenuItem(
                                      value: period,
                                      child: Text(
                                        period,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
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
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // DATE NAVIGATION
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.red,
                          ),
                          onPressed: () => state.navigateDate(false),
                        ),
                        Text(
                          state.getDateRangeText(),
                          style: const TextStyle(fontSize: 12),
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

              const SizedBox(height: 16),

              // METRIC TABS
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => state.setState(() => state.selectedMetric = 'sold'),
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 6),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Sold',
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                state.totalSold.toStringAsFixed(0),
                                style: const TextStyle(
                                  fontSize: 22,
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
                          padding: const EdgeInsets.only(bottom: 6),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Spoilage',
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                state.totalSpoilage.toStringAsFixed(0),
                                style: const TextStyle(
                                  fontSize: 22,
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
              ),

              const SizedBox(height: 20),

              // PHONE CHART CARD
              Container(
                height: 260,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(data.length, (index) {
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
                                heightFactor: heightPercent.clamp(0.0, 1.0),
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(4),
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: state.getChartLabels()
                          .map(
                            (label) => Expanded(
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
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
      ),
    );
  }
}