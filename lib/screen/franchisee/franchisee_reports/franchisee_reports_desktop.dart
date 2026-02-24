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

  String _formatAxisValue(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final labels = state.getChartLabels();
    final data = state.chartData[state.selectedMetric] ??
        List<double>.filled(labels.isEmpty ? 1 : labels.length, 0.0);
    final maxValue =
        data.isEmpty ? 1.0 : data.reduce((a, b) => a > b ? a : b);

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
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  iconSize: 35,
                  onPressed: () {},
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
                      child: data.isEmpty || labels.isEmpty
                          ? const Center(child: Text('No data available'))
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Rotated axis title
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 4, bottom: 24),
                                  child: RotatedBox(
                                    quarterTurns: 3,
                                    child: Text(
                                      'Stock Amount',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                  ),
                                ),

                                // ── Y-axis numbers ──────────────────────────
                                // Width is fixed; bottom padding accounts for
                                // SizedBox(8) + x-label row (~16 px) = 24 px.
                                SizedBox(
                                  width: 42,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 6, bottom: 24),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: List.generate(5, (i) {
                                        // i=0 → max, i=4 → 0
                                        final val = maxValue * (4 - i) / 4;
                                        return Text(
                                          _formatAxisValue(val),
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[600]),
                                        );
                                      }),
                                    ),
                                  ),
                                ),

                                // ── Bars + x-labels ─────────────────────────
                                Expanded(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          // stretch so each Expanded child fills
                                          // the full column height, enabling
                                          // the inner Column layout for tooltips.
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: List.generate(data.length,
                                              (index) {
                                            final value = data[index];
                                            final heightPercent = maxValue > 0
                                                ? (value / maxValue)
                                                    .clamp(0.0, 1.0)
                                                : 0.0;

                                            return Expanded(
                                              child: MouseRegion(
                                                onEnter: (_) => setState(() =>
                                                    _hoveredIndex = index),
                                                onExit: (_) => setState(
                                                    () => _hoveredIndex = null),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 4),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      // Tooltip — kept in the
                                                      // layout at all times
                                                      // (opacity 0 when not
                                                      // hovered) so bar heights
                                                      // stay consistent.
                                                      AnimatedOpacity(
                                                        opacity: _hoveredIndex ==
                                                                index
                                                            ? 1.0
                                                            : 0.0,
                                                        duration: const Duration(
                                                            milliseconds: 120),
                                                        child: Container(
                                                          margin: const EdgeInsets
                                                              .only(bottom: 4),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 7,
                                                                  vertical: 3),
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                Colors.black87,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          child: Text(
                                                            value
                                                                .toStringAsFixed(
                                                                    0),
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ),
                                                      ),
                                                      // Bar
                                                      Flexible(
                                                        child:
                                                            FractionallySizedBox(
                                                          heightFactor:
                                                              heightPercent <
                                                                      0.01
                                                                  ? 0.01
                                                                  : heightPercent,
                                                          alignment: Alignment
                                                              .bottomCenter,
                                                          child:
                                                              AnimatedContainer(
                                                            duration: const Duration(
                                                                milliseconds:
                                                                    120),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: _hoveredIndex ==
                                                                      index
                                                                  ? Colors.red
                                                                      .shade700
                                                                  : Colors.red,
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .vertical(
                                                                top: Radius
                                                                    .circular(
                                                                        2),
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
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      // X-axis labels
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: labels
                                            .map(
                                              (label) => Expanded(
                                                child: Text(
                                                  label,
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey[600]),
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