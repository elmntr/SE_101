import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'franchisee_reports.dart';

class ReportsPageDesktop extends StatefulWidget {
  final ReportsPageState state;

  const ReportsPageDesktop({super.key, required this.state});

  @override
  State<ReportsPageDesktop> createState() => _ReportsPageDesktopState();
}

class _ReportsPageDesktopState extends State<ReportsPageDesktop> {
  int? _hoveredIndex;
  int? _hoveredItemId; // For stacked bars - which item segment is hovered

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reports',
                  style: TextStyle(fontSize: 30, fontFamily: fontAll),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      iconSize: 28,
                      tooltip: 'Refresh from cloud',
                      onPressed: () => state.loadData(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      iconSize: 35,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Filters ────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return PopupMenuButton<int?>(
                        color: Colors.white,
                        constraints:
                            BoxConstraints(minWidth: constraints.maxWidth),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  state.getSelectedItemName(),
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down,
                                  color: Colors.black),
                            ],
                          ),
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                              value: null, child: Text('All Items')),
                          ...state.allItems.map(
                            (item) => PopupMenuItem(
                                value: item.id, child: Text(item.name)),
                          ),
                        ],
                        onSelected: (value) {
                          state.setState(() => state.selectedItemId = value);
                          state.calculateChartData();
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
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(state.selectedPeriod,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 14)),
                            const Icon(Icons.keyboard_arrow_down,
                                color: Colors.black),
                          ],
                        ),
                      ),
                      itemBuilder: (context) => state.periods
                          .map((p) => PopupMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onSelected: (value) {
                        state.setState(() => state.selectedPeriod = value);
                        state.calculateChartData();
                      },
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
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
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                        if (state.hasSpecificDateSelected)
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.grey, size: 20),
                            onPressed: () => state.clearDateSelection(),
                            tooltip: 'Clear selection',
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
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Main card ──────────────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2)),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Metric tabs
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => state
                                .setState(() => state.selectedMetric = 'sold'),
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
                                  const Text('Total Amount Sold',
                                      style: TextStyle(fontSize: 14)),
                                  const SizedBox(height: 8),
                                  Text(
                                    state.displayTotalSold.toStringAsFixed(0),
                                    style: const TextStyle(
                                        fontSize: 32,
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
                                  const Text('Total Spoilage',
                                      style: TextStyle(fontSize: 14)),
                                  const SizedBox(height: 8),
                                  Text(
                                    state.displayTotalSpoilage
                                        .toStringAsFixed(0),
                                    style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ── Chart ───────────────────────────────────────────────
                    Expanded(
                      child: _buildChart(state, labels, data, maxValue),
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
        // Rotated axis title
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 24),
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              'Stock Amount',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ),

        // Y-axis numbers
        SizedBox(
          width: 42,
          child: Padding(
            padding: const EdgeInsets.only(right: 6, bottom: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(5, (i) {
                final val = maxValue * (4 - i) / 4;
                return Text(
                  _formatAxisValue(val),
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
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
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Tooltip
                  AnimatedOpacity(
                    opacity: _hoveredIndex == index ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 120),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
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
                        duration: const Duration(milliseconds: 120),
                        decoration: BoxDecoration(
                          color: _hoveredIndex == index
                              ? Colors.red.shade700
                              : Colors.red,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(2),
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

          segments.add(
            Flexible(
              flex: (segmentPercent * 1000).round().clamp(1, 1000),
              child: MouseRegion(
                onEnter: (_) => setState(() {
                  _hoveredIndex = bucketIndex;
                  _hoveredItemId = itemId;
                }),
                onExit: (_) => setState(() {
                  _hoveredIndex = null;
                  _hoveredItemId = null;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  decoration: BoxDecoration(
                    color: (_hoveredIndex == bucketIndex &&
                            _hoveredItemId == itemId)
                        ? Color.lerp(color, Colors.black, 0.2)
                        : color,
                    borderRadius: segments.isEmpty
                        ? const BorderRadius.vertical(top: Radius.circular(2))
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
                // Tooltip for stacked bar
                AnimatedOpacity(
                  opacity: (_hoveredIndex == bucketIndex && _hoveredItemId != null)
                      ? 1.0
                      : 0.0,
                  duration: const Duration(milliseconds: 120),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Builder(
                      builder: (context) {
                        if (_hoveredItemId == null) return const SizedBox();
                        final item = state.allItems.firstWhere(
                          (i) => i.id == _hoveredItemId,
                          orElse: () => state.allItems.first,
                        );
                        final itemData = stackedData[_hoveredItemId]?[metric];
                        final value = (itemData != null &&
                                bucketIndex < itemData.length)
                            ? itemData[bucketIndex]
                            : 0.0;
                        return Text(
                          '${item.name}: ${value.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        );
                      },
                    ),
                  ),
                ),
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
                                      top: Radius.circular(2),
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
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Tooltip with item name and value
                  AnimatedOpacity(
                    opacity: _hoveredIndex == index ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 120),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '$itemName: ${value.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
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
                        duration: const Duration(milliseconds: 120),
                        decoration: BoxDecoration(
                          color: _hoveredIndex == index
                              ? Color.lerp(color, Colors.black, 0.2)
                              : color,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(2),
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
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
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
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ),
            )
            .toList(),
      );
    }
  }
}