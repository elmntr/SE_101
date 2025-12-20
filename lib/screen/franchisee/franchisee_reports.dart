import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:flutter/material.dart';
import '../../../database/app_database.dart';
import 'package:chickenjoo_inventory/app_globals.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late AppDatabase db;

  // UI State
  int? selectedItemId; // null = "All Items"
  String selectedPeriod = 'Weekly';
  DateTime currentDate = DateTime.now();
  String selectedMetric = 'sold';

  // Data from database
  List<Item> allItems = [];
  int? currentOrganizationId; // ✅ FIXED: Track current user's organization
  Map<String, List<double>> chartData = {};
  double totalSold = 0;
  double totalSpoilage = 0;
  bool isLoading = true;

  final List<String> periods = ['Weekly', 'Monthly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    db = database;
    _loadData();
  }

  /// ✅ FIXED: Load items for current user's organization
  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      // Get current user (TODO: Replace with actual session management)
      final currentUser = await db.usersDao.getUserById(1);

      if (currentUser != null) {
        currentOrganizationId = currentUser.organizationId;

        // Load items for this organization
        final items = await db.itemsDao.getItemsByOrganization(
          currentOrganizationId!,
        );

        if (mounted) {
          setState(() {
            allItems = items;
            _calculateChartData();
            _calculateTotals();
            isLoading = false;
          });
        }
      } else {
        // Fallback to all items if no user found
        final items = await db.itemsDao.getAllItems();
        if (mounted) {
          setState(() {
            allItems = items;
            _calculateChartData();
            _calculateTotals();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error loading reports data: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// Calculate chart data based on selected item and period
  void _calculateChartData() {
    if (selectedItemId == null) {
      // All items combined
      _calculateAllItemsData();
    } else {
      // Single item
      _calculateSingleItemData(selectedItemId!);
    }
  }

  /// Calculate totals for the metric cards
  void _calculateTotals() {
    if (selectedItemId == null) {
      // Sum all items
      totalSold = allItems.fold(0, (sum, item) => sum + item.sold);
      totalSpoilage = allItems.fold(0, (sum, item) => sum + item.spoilage);
    } else {
      // Single item
      final item = allItems.firstWhere((i) => i.id == selectedItemId);
      totalSold = item.sold.toDouble();
      totalSpoilage = item.spoilage.toDouble();
    }
  }

  /// Calculate chart data for all items
  void _calculateAllItemsData() {
    // For now, we'll use mock data since we don't have historical tracking
    // In a real app, you'd query historical data from a transactions table

    if (selectedPeriod == 'Weekly') {
      // Generate realistic data based on current totals
      final avgPerDay = totalSold / 7;
      chartData = {
        'sold': List.generate(7, (i) => avgPerDay * (0.8 + (i % 3) * 0.2)),
        'spoilage': List.generate(
          7,
          (i) => totalSpoilage / 7 * (0.7 + (i % 3) * 0.3),
        ),
      };
    } else if (selectedPeriod == 'Monthly') {
      final avgPerMonth = totalSold / 6;
      chartData = {
        'sold': List.generate(6, (i) => avgPerMonth * (0.8 + (i % 3) * 0.2)),
        'spoilage': List.generate(
          6,
          (i) => totalSpoilage / 6 * (0.7 + (i % 3) * 0.3),
        ),
      };
    } else {
      final avgPerYear = totalSold / 3;
      chartData = {
        'sold': List.generate(3, (i) => avgPerYear * (0.85 + i * 0.1)),
        'spoilage': List.generate(
          3,
          (i) => totalSpoilage / 3 * (0.8 + i * 0.15),
        ),
      };
    }
  }

  /// Calculate chart data for a single item
  void _calculateSingleItemData(int itemId) {
    final item = allItems.firstWhere((i) => i.id == itemId);

    if (selectedPeriod == 'Weekly') {
      final avgPerDay = item.sold / 7;
      chartData = {
        'sold': List.generate(7, (i) => avgPerDay * (0.8 + (i % 3) * 0.2)),
        'spoilage': List.generate(
          7,
          (i) => item.spoilage / 7 * (0.7 + (i % 3) * 0.3),
        ),
      };
    } else if (selectedPeriod == 'Monthly') {
      final avgPerMonth = item.sold / 6;
      chartData = {
        'sold': List.generate(6, (i) => avgPerMonth * (0.8 + (i % 3) * 0.2)),
        'spoilage': List.generate(
          6,
          (i) => item.spoilage / 6 * (0.7 + (i % 3) * 0.3),
        ),
      };
    } else {
      final avgPerYear = item.sold / 3;
      chartData = {
        'sold': List.generate(3, (i) => avgPerYear * (0.85 + i * 0.1)),
        'spoilage': List.generate(
          3,
          (i) => item.spoilage / 3 * (0.8 + i * 0.15),
        ),
      };
    }
  }

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
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatMonthYear(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  List<String> getChartLabels() {
    if (selectedPeriod == 'Weekly') {
      final labels = <String>[];
      for (int i = 6; i >= 0; i--) {
        final date = currentDate.subtract(Duration(days: i));
        labels.add('${_formatMonthYear(date).split(' ')[0]} ${date.day}');
      }
      return labels;
    } else if (selectedPeriod == 'Monthly') {
      final labels = <String>[];
      for (int i = 5; i >= 0; i--) {
        final date = DateTime(currentDate.year, currentDate.month - i, 1);
        labels.add(_formatMonthYear(date).split(' ')[0]);
      }
      return labels;
    } else {
      return List.generate(3, (i) => (currentDate.year - 2 + i).toString());
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
      _calculateChartData();
    });
  }

  String getSelectedItemName() {
    if (selectedItemId == null) return 'All Items';
    final item = allItems.firstWhere(
      (item) => item.id == selectedItemId,
      orElse: () => allItems.first,
    );
    return item.name;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Get current data for the selected metric
    final data = chartData[selectedMetric] ?? List.filled(7, 0.0);
    final maxValue = data.isEmpty ? 1.0 : data.reduce((a, b) => a > b ? a : b);

    if (AppLayout.isDesktop(context) == false) {
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
                                        getSelectedItemName(),
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
                                  ...allItems.map(
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
                                  setState(() {
                                    selectedItemId = value;
                                    _calculateChartData();
                                    _calculateTotals();
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
                                        selectedPeriod,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      const Icon(Icons.keyboard_arrow_down),
                                    ],
                                  ),
                                ),
                                itemBuilder: (context) => periods
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
                                  setState(() {
                                    selectedPeriod = value;
                                    _calculateChartData();
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
                            onPressed: () => navigateDate(false),
                          ),
                          Text(
                            getDateRangeText(),
                            style: const TextStyle(fontSize: 12),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_right,
                              color: Colors.red,
                            ),
                            onPressed: () => navigateDate(true),
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
                          onTap: () => setState(() => selectedMetric = 'sold'),
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: selectedMetric == 'sold'
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
                                  totalSold.toStringAsFixed(0),
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
                              setState(() => selectedMetric = 'spoilage'),
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: selectedMetric == 'spoilage'
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
                                  totalSpoilage.toStringAsFixed(0),
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
                        children: getChartLabels()
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

    // DESKTOP UI
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
                                getSelectedItemName(),
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
                          ...allItems.map(
                            (item) => PopupMenuItem(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          setState(() {
                            selectedItemId = value;
                            _calculateChartData();
                            _calculateTotals();
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
                              selectedPeriod,
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
                      itemBuilder: (context) => periods
                          .map(
                            (period) => PopupMenuItem(
                              value: period,
                              child: Text(period),
                            ),
                          )
                          .toList(),
                      onSelected: (value) {
                        setState(() {
                          selectedPeriod = value;
                          _calculateChartData();
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
                        onPressed: () => navigateDate(false),
                      ),
                      Text(
                        getDateRangeText(),
                        style: const TextStyle(fontSize: 13),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Colors.red,
                        ),
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
                                setState(() => selectedMetric = 'sold'),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: selectedMetric == 'sold'
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
                                    totalSold.toStringAsFixed(0),
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
                                setState(() => selectedMetric = 'spoilage'),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: selectedMetric == 'spoilage'
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
                                    totalSpoilage.toStringAsFixed(0),
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
                                  children: getChartLabels()
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
