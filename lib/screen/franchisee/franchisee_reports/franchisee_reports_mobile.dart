import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'franchisee_reports.dart';

class ReportsPageMobile extends StatefulWidget {
  final ReportsPageState state;

  const ReportsPageMobile({super.key, required this.state});

  @override
  State<ReportsPageMobile> createState() => _ReportsPageMobileState();
}

class _ReportsPageMobileState extends State<ReportsPageMobile> {
  int? _tappedIndex;
  int? _tappedItemId; // For stacked bars - which item segment is tapped

  String _formatAxisValue(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }

  /// Calculate max value based on chart mode
  double _calculateMaxValue() {
    final state = widget.state;
    final metric = state.selectedMetric;

    if (state.shouldShowGroupedBars) {
      // For grouped bars, find max among individual items
      if (state.itemsDataForDate.isEmpty) return 1.0;
      return state.itemsDataForDate
          .map((item) => (item[metric] as double))
          .reduce((a, b) => a > b ? a : b);
    } else if (state.shouldShowStackedBars) {
      // For stacked bars, max is the sum of all items for each bucket
      final data = state.chartData[metric] ?? [];
      if (data.isEmpty) return 1.0;
      return data.reduce((a, b) => a > b ? a : b);
    } else {
      // Single item mode - use aggregated data
      final data = state.chartData[metric] ?? [];
      if (data.isEmpty) return 1.0;
      return data.reduce((a, b) => a > b ? a : b);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final labels = state.getChartLabels();
    final data = state.chartData[state.selectedMetric] ??
        List<double>.filled(labels.isEmpty ? 1 : labels.length, 0.0);
    final maxValue = _calculateMaxValue();

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reports',
                    style: TextStyle(fontSize: 26, fontFamily: fontAll),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 24),
                        tooltip: 'Refresh from cloud',
                        onPressed: () => state.loadData(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, size: 28),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Filters ────────────────────────────────────────────────
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return PopupMenuButton<int?>(
                              color: Colors.white,
                              constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        state.getSelectedItemName(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down),
                                  ],
                                ),
                              ),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: null,
                                  child: Text('All Items',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal)),
                                ),
                                ...state.allItems.map(
                                  (item) => PopupMenuItem(
                                    value: item.id,
                                    child: Text(item.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal)),
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                state.setState(
                                    () => state.selectedItemId = value);
                                state.calculateChartData();
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
                                  minWidth: constraints.maxWidth),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(state.selectedPeriod,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal)),
                                    const Icon(Icons.keyboard_arrow_down),
                                  ],
                                ),
                              ),
                              itemBuilder: (context) => state.periods
                                  .map(
                                    (p) => PopupMenuItem(
                                      value: p,
                                      child: Text(p,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal)),
                                    ),
                                  )
                                  .toList(),
                              onSelected: (value) {
                                state.setState(
                                    () => state.selectedPeriod = value);
                                state.calculateChartData();
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

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
                          icon: const Icon(Icons.chevron_left,
                              color: Colors.red),
                          onPressed: () => state.navigateDate(false),
                        ),
                        Expanded(
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => state.openPeriodPicker(context),
                              child: Text(
                                state.getDateRangeText(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                        if (state.hasSpecificDateSelected)
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.grey, size: 20),
                            onPressed: () => state.clearDateSelection(),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.chevron_right,
                                color: Colors.red),
                            onPressed: () => state.navigateDate(true),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Metric tabs ────────────────────────────────────────────
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
                        onTap: () => state
                            .setState(() => state.selectedMetric = 'sold'),
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
                              const Text('Total Sold',
                                  style: TextStyle(fontSize: 12)),
                              const SizedBox(height: 6),
                              Text(
                                state.displayTotalSold.toStringAsFixed(0),
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => state.setState(
                            () => state.selectedMetric = 'spoilage'),
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
                              const Text('Spoilage',
                                  style: TextStyle(fontSize: 12)),
                              const SizedBox(height: 6),
                              Text(
                                state.displayTotalSpoilage.toStringAsFixed(0),
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
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

              // ── Chart card ─────────────────────────────────────────────
              GestureDetector(
                // Tap anywhere outside a bar to deselect
                onTap: () => setState(() {
                  _tappedIndex = null;
                  _tappedItemId = null;
                }),
                child: Container(
                  height: 260,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2)),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: _buildChart(state, labels, data, maxValue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the appropriate chart based on the current mode
  Widget _buildChart(ReportsPageState state, List<String> labels,
      List<double> data, double maxValue) {
    // Check for no data
    if (state.shouldShowGroupedBars) {
      if (state.itemsDataForDate.isEmpty) {
        return const Center(child: Text('No data available'));
      }
    } else if (data.isEmpty || labels.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Y-axis numbers
        SizedBox(
          width: 38,
          child: Padding(
            padding: const EdgeInsets.only(right: 4, bottom: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(5, (i) {
                final val = maxValue * (4 - i) / 4;
                return Text(
                  _formatAxisValue(val),
                  style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                );
              }),
            ),
          ),
        ),

        // Bars + x-labels
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: _buildBars(state, labels, data, maxValue),
              ),
              const SizedBox(height: 8),
              _buildXAxisLabels(state, labels),
            ],
          ),
        ),
      ],
    );
  }

  /// Build the bar section based on chart mode
  Widget _buildBars(ReportsPageState state, List<String> labels,
      List<double> data, double maxValue) {
    if (state.shouldShowGroupedBars) {
      // Grouped bars: specific date + All Items
      return _buildGroupedBars(state, maxValue);
    } else if (state.shouldShowStackedBars) {
      // Stacked bars: date range + All Items
      return _buildStackedBars(state, labels, maxValue);
    } else {
      // Simple bars: specific item selected
      return _buildSimpleBars(state, data, maxValue);
    }
  }

  /// Build simple bars (single item mode)
  Widget _buildSimpleBars(
      ReportsPageState state, List<double> data, double maxValue) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(data.length, (index) {
        final value = data[index];
        final heightPercent =
            maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _tappedIndex = _tappedIndex == index ? null : index;
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Tooltip
                  AnimatedOpacity(
                    opacity: _tappedIndex == index ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  // Bar
                  Flexible(
                    child: FractionallySizedBox(
                      heightFactor: heightPercent < 0.01 ? 0.01 : heightPercent,
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: _tappedIndex == index
                              ? Colors.red.shade700
                              : Colors.red,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Build stacked bars (All Items + date range mode)
  Widget _buildStackedBars(
      ReportsPageState state, List<String> labels, double maxValue) {
    final metric = state.selectedMetric;
    final stackedData = state.stackedChartData;
    final aggregatedData = state.chartData[metric] ?? [];

    // Get list of item IDs that have data
    final itemIds = stackedData.keys.toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(labels.length, (bucketIndex) {
        final totalValue =
            bucketIndex < aggregatedData.length ? aggregatedData[bucketIndex] : 0.0;
        final heightPercent =
            maxValue > 0 ? (totalValue / maxValue).clamp(0.0, 1.0) : 0.0;

        // Build stacked segments for this bucket
        final segments = <Widget>[];
        for (final itemId in itemIds) {
          final itemData = stackedData[itemId]?[metric];
          if (itemData == null || bucketIndex >= itemData.length) continue;
          final value = itemData[bucketIndex];
          if (value <= 0) continue;

          final segmentPercent = totalValue > 0 ? value / totalValue : 0.0;
          final color = state.getItemColor(itemId);
          
          // Get item name for display
          String itemName = 'Item';
          if (state.allItems.isNotEmpty) {
            final item = state.allItems.firstWhere(
              (i) => i.id == itemId,
              orElse: () => state.allItems.first,
            );
            itemName = item.name;
          }

          segments.add(
            Flexible(
              flex: (segmentPercent * 1000).round().clamp(1, 1000),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  // Show snackbar with item info on tap
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$itemName: ${value.toStringAsFixed(0)}'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  setState(() {
                    if (_tappedIndex == bucketIndex && _tappedItemId == itemId) {
                      _tappedIndex = null;
                      _tappedItemId = null;
                    } else {
                      _tappedIndex = bucketIndex;
                      _tappedItemId = itemId;
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: (_tappedIndex == bucketIndex &&
                            _tappedItemId == itemId)
                        ? Color.lerp(color, Colors.black, 0.2)
                        : color,
                    borderRadius: segments.isEmpty
                        ? const BorderRadius.vertical(top: Radius.circular(4))
                        : null,
                  ),
                ),
              ),
            ),
          );
        }

        // Reverse segments so first item is at bottom
        final reversedSegments = segments.reversed.toList();

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Stacked bar
                Flexible(
                  child: FractionallySizedBox(
                    heightFactor: heightPercent < 0.01 ? 0.01 : heightPercent,
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: reversedSegments.isEmpty
                          ? [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ]
                          : reversedSegments,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Build grouped bars (All Items + specific date mode)
  Widget _buildGroupedBars(ReportsPageState state, double maxValue) {
    final metric = state.selectedMetric;
    final items = state.itemsDataForDate;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(items.length, (index) {
        final itemData = items[index];
        final value = itemData[metric] as double;
        final itemName = itemData['itemName'] as String;
        final itemId = itemData['itemId'] as int;
        final heightPercent =
            maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;
        final color = state.getItemColor(itemId);

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _tappedIndex = _tappedIndex == index ? null : index;
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Tooltip with item name and value
                  AnimatedOpacity(
                    opacity: _tappedIndex == index ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '$itemName: ${value.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  // Bar with item color
                  Flexible(
                    child: FractionallySizedBox(
                      heightFactor: heightPercent < 0.01 ? 0.01 : heightPercent,
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: _tappedIndex == index
                              ? Color.lerp(color, Colors.black, 0.2)
                              : color,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Build X-axis labels based on chart mode
  Widget _buildXAxisLabels(ReportsPageState state, List<String> labels) {
    if (state.shouldShowGroupedBars) {
      // For grouped bars, show item names
      final items = state.itemsDataForDate;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          return Expanded(
            child: Text(
              item['itemName'] as String,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          );
        }).toList(),
      );
    } else {
      // For stacked and simple bars, show date labels
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: labels
            .map(
              (label) => Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ),
            )
            .toList(),
      );
    }
  }
}