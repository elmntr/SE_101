import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:flutter/material.dart';
import '../../../../database/app_database.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'franchisee_reports_mobile.dart';
import 'franchisee_reports_desktop.dart';

const List<String> _monthNames = [
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

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => ReportsPageState();
}

class ReportsPageState extends State<ReportsPage> {
  late AppDatabase db;

  // UI State
  int? selectedItemId; // null = "All Items"
  String selectedPeriod = 'Weekly';
  DateTime currentDate = DateTime.now();
  DateTime? selectedSpecificDate; // null = show range, non-null = show specific date
  String selectedMetric = 'sold';

  // Data from database
  List<Item> allItems = [];
  int? currentOrganizationId;
  Map<String, List<double>> chartData = {};
  double totalSold = 0;
  double totalSpoilage = 0;
  // Specific date totals (when a date is selected from calendar)
  double selectedDateSold = 0;
  double selectedDateSpoilage = 0;
  bool isLoading = true;
  int _chartRequestId = 0;

  // Getters for display - show specific date totals when selected, otherwise period totals
  double get displayTotalSold => selectedSpecificDate != null ? selectedDateSold : totalSold;
  double get displayTotalSpoilage => selectedSpecificDate != null ? selectedDateSpoilage : totalSpoilage;

  final List<String> periods = ['Weekly', 'Monthly', 'Yearly'];
  static const String orgIdKey = 'current_organization_id';

  @override
  void initState() {
    super.initState();
    db = database;
    loadData();
    
    // ✅ FIX: Listen to sync completion to refresh data
    syncCompleteNotifier.addListener(_onSyncComplete);
  }
  
  @override
  void dispose() {
    syncCompleteNotifier.removeListener(_onSyncComplete);
    super.dispose();
  }
  
  void _onSyncComplete() {
    if (mounted) {
      print('🔄 Sync completed, refreshing reports...');
      loadData();
    }
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      await loadCurrentOrganization();

      List<Item> items;
      if (currentOrganizationId != null) {
        items = await db.itemsDao.getItemsByOrganization(currentOrganizationId!);
      } else {
        items = await db.itemsDao.getAllItems();
      }

      if (mounted) {
        setState(() {
          allItems = items;
          if (selectedItemId != null &&
              items.every((item) => item.id != selectedItemId)) {
            selectedItemId = null;
          }
        });
      }

      await calculateChartData();
    } catch (e) {
      print('❌ Error loading reports data: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> loadCurrentOrganization() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Try to get from current logged-in user session via auth service
    final currentUser = AppGlobals.instance.authService.currentUser;
    if (currentUser != null) {
      // If local ID is 0 but we have cloud ID, look up the local ID
      // This happens on first login when data is synced but UserData has ID 0
      if (currentUser.organizationId == 0 && currentUser.organizationCloudId != null) {
        final org = await db.organizationsDao.getOrganizationByCloudId(
          currentUser.organizationCloudId!,
        );
        if (org != null) {
          currentOrganizationId = org.id;
          await prefs.setInt(orgIdKey, org.id);
          print('📍 Resolved org ID from cloud ID: ${currentUser.organizationCloudId} → ${org.id}');
          return;
        }
      }
      
      await prefs.setInt(orgIdKey, currentUser.organizationId);
      currentOrganizationId = currentUser.organizationId;
    } else {
      // Fallback: Load from local storage (for offline mode)
      currentOrganizationId = prefs.getInt(orgIdKey);
    }
  }

  /// Calculate chart data based on selected item and period
  Future<void> calculateChartData() async {
    final periodConfig = _getPeriodConfigForPeriod(); // Always get period-based config
    final displayConfig = _getPeriodConfig(); // Gets single-day if specific date selected
    final requestId = ++_chartRequestId;

    if (mounted) {
      setState(() {
        chartData = {
          'sold': List<double>.filled(displayConfig.bucketCount, 0.0),
          'spoilage': List<double>.filled(displayConfig.bucketCount, 0.0),
        };
        totalSold = 0;
        totalSpoilage = 0;
        selectedDateSold = 0;
        selectedDateSpoilage = 0;
      });
    }

    if (currentOrganizationId == null) {
      return;
    }

    try {
      // Fetch summaries for the full period range
      final summaries = await db.dailySalesSummaryDao.getSummariesForDateRange(
        organizationId: currentOrganizationId!,
        startDate: periodConfig.startDate,
        endDate: periodConfig.endDate,
      );

      final iterable = selectedItemId == null
          ? summaries
          : summaries.where((summary) => summary.itemId == selectedItemId);

      // Calculate period totals
      double periodSold = 0;
      double periodSpoilage = 0;
      
      // Calculate specific date/month totals (if selected)
      double dateSold = 0;
      double dateSpoilage = 0;
      
      // Calculate chart data for display
      final soldSeries = List<double>.filled(displayConfig.bucketCount, 0.0);
      final spoilageSeries = List<double>.filled(displayConfig.bucketCount, 0.0);

      for (final summary in iterable) {
        // Add to period totals
        periodSold += summary.quantitySold.toDouble();
        periodSpoilage += summary.quantitySpoiled.toDouble();
        
        // Check if this matches the selected specific date
        if (selectedSpecificDate != null) {
          final summaryDate = summary.summaryDate;
          final selectedDate = selectedSpecificDate!;
          
          final normalizedSummary = _normalizeDate(summaryDate);
          final normalizedSelected = _normalizeDate(selectedDate);
          final matches = normalizedSummary.year == normalizedSelected.year &&
                    normalizedSummary.month == normalizedSelected.month &&
                    normalizedSummary.day == normalizedSelected.day;
          
          if (matches) {
            dateSold += summary.quantitySold.toDouble();
            dateSpoilage += summary.quantitySpoiled.toDouble();
          }
        }
        
        // Add to chart display data
        final bucketIndex = displayConfig.resolveBucket(summary.summaryDate);
        if (bucketIndex == null) continue;
        soldSeries[bucketIndex] += summary.quantitySold.toDouble();
        spoilageSeries[bucketIndex] += summary.quantitySpoiled.toDouble();
      }

      if (!mounted || requestId != _chartRequestId) {
        return;
      }

      setState(() {
        chartData = {
          'sold': soldSeries,
          'spoilage': spoilageSeries,
        };
        totalSold = periodSold;
        totalSpoilage = periodSpoilage;
        selectedDateSold = dateSold;
        selectedDateSpoilage = dateSpoilage;
      });
    } catch (e) {
      print('❌ Error calculating chart data: $e');
    }
  }

  String getDateRangeText() {
    // If a specific date is selected, show just that
    if (selectedSpecificDate != null) {
      return formatDate(selectedSpecificDate!);
    }
    
    // Otherwise show the period-based text
    if (selectedPeriod == 'Weekly') {
      final start = currentDate.subtract(const Duration(days: 6));
      return '${formatDate(start)} - ${formatDate(currentDate)}';
    } else if (selectedPeriod == 'Monthly') {
      final start = DateTime(currentDate.year, currentDate.month - 5, 1);
      return '${formatMonthYear(start)} - ${formatMonthYear(currentDate)}';
    } else {
      final start = currentDate.year - 2;
      return '$start - ${currentDate.year}';
    }
  }

  bool get hasSpecificDateSelected => selectedSpecificDate != null;

  void clearDateSelection() {
    setState(() {
      selectedSpecificDate = null;
      currentDate = DateTime.now();
    });
    calculateChartData();
  }

  String formatDate(DateTime date) {
    return '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  String formatMonthYear(DateTime date) {
    return '${_monthNames[date.month - 1]} ${date.year}';
  }

  List<String> getChartLabels() {
    return _getPeriodConfig().labels;
  }

  Future<void> navigateDate(bool forward) async {
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
    await calculateChartData();
  }

  /// Opens a picker suited to the current aggregation period
  Future<void> openPeriodPicker(BuildContext context) async {
    if (selectedPeriod == 'Yearly') {
      final selectedYear = await _showYearPickerDialog(context);
      if (selectedYear == null || !mounted) {
        return;
      }

      setState(() {
        selectedSpecificDate = DateTime(selectedYear, 1, 1);
        currentDate = DateTime(selectedYear, 1, 1);
      });
      await calculateChartData();
      return;
    }

    // Show date picker for Weekly and Monthly periods
    await _openDatePicker(context);
  }

  Future<void> _openDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final firstSelectableDate = DateTime(now.year - 20, 1, 1);
    final lastSelectableDate = DateTime(now.year + 5, 12, 31);
    final normalizedCurrent = _normalizeDate(currentDate);
    final initialDate = normalizedCurrent.isBefore(firstSelectableDate)
        ? firstSelectableDate
        : (normalizedCurrent.isAfter(lastSelectableDate)
            ? lastSelectableDate
            : normalizedCurrent);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstSelectableDate,
      lastDate: lastSelectableDate,
      helpText: 'Select a date',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDatePickerMode: DatePickerMode.day,
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      selectedSpecificDate = picked;
      currentDate = picked;
    });
    await calculateChartData();
  }

  DateTime _alignDateToPeriod(DateTime date) {
    final normalized = _normalizeDate(date);

    if (selectedPeriod == 'Weekly') {
      final daysUntilEnd = (DateTime.sunday - normalized.weekday) % 7;
      return normalized.add(Duration(days: daysUntilEnd));
    }

    if (selectedPeriod == 'Monthly') {
      return DateTime(normalized.year, normalized.month, 1);
    }

    return normalized;
  }

  Future<int?> _showYearPickerDialog(BuildContext context) async {
    final now = DateTime.now();
    // Optimized: Reduced date range to prevent performance issues and crashes
    // Using 20 years back and 5 years forward instead of 1900-2076
    final firstDate = DateTime(now.year - 20, 1, 1);
    final lastDate = DateTime(now.year + 5, 1, 1);
    final initialYear =
        currentDate.year.clamp(firstDate.year, lastDate.year).toInt();

    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Year'),
          content: SizedBox(
            width: 320,
            height: 320,
            child: YearPicker(
              firstDate: firstDate,
              lastDate: lastDate,
              initialDate: DateTime(initialYear, 1, 1),
              selectedDate: DateTime(initialYear, 1, 1),
              onChanged: (value) => Navigator.of(context).pop(value.year),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
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

    if (AppLayout.isDesktop(context) == false) {
      return ReportsPageMobile(state: this);
    }
    return ReportsPageDesktop(state: this);
  }
}

class _ChartPeriodConfig {
  const _ChartPeriodConfig({
    required this.startDate,
    required this.endDate,
    required this.bucketCount,
    required this.labels,
    required this.resolveBucket,
  });

  final DateTime startDate;
  final DateTime endDate;
  final int bucketCount;
  final List<String> labels;
  final int? Function(DateTime date) resolveBucket;
}

DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

_ChartPeriodConfig _buildWeeklyConfig(DateTime current) {
  final end = _normalizeDate(current);
  final start = end.subtract(const Duration(days: 6));
  final labels = List<String>.generate(7, (index) {
    final date = start.add(Duration(days: index));
    return '${_monthNames[date.month - 1]} ${date.day}';
  });

  return _ChartPeriodConfig(
    startDate: start,
    endDate: end,
    bucketCount: 7,
    labels: labels,
    resolveBucket: (date) {
      final normalized = _normalizeDate(date);
      final diff = normalized.difference(start).inDays;
      if (diff < 0 || diff >= 7) {
        return null;
      }
      return diff;
    },
  );
}

_ChartPeriodConfig _buildMonthlyConfig(DateTime current) {
  final end = DateTime(current.year, current.month + 1, 0);
  final start = DateTime(current.year, current.month - 5, 1);
  final labels = List<String>.generate(6, (index) {
    final date = DateTime(start.year, start.month + index, 1);
    return _monthNames[date.month - 1];
  });

  return _ChartPeriodConfig(
    startDate: start,
    endDate: end,
    bucketCount: 6,
    labels: labels,
    resolveBucket: (date) {
      final normalized = DateTime(date.year, date.month, 1);
      final diff =
          (normalized.year - start.year) * 12 + (normalized.month - start.month);
      if (diff < 0 || diff >= 6) {
        return null;
      }
      return diff;
    },
  );
}

_ChartPeriodConfig _buildYearlyConfig(DateTime current) {
  final startYear = current.year - 2;
  final start = DateTime(startYear, 1, 1);
  final end = DateTime(current.year, 12, 31);
  final labels =
      List<String>.generate(3, (index) => (startYear + index).toString());

  return _ChartPeriodConfig(
    startDate: start,
    endDate: end,
    bucketCount: 3,
    labels: labels,
    resolveBucket: (date) {
      final yearIndex = date.year - startYear;
      if (yearIndex < 0 || yearIndex >= 3) {
        return null;
      }
      return yearIndex;
    },
  );
}

_ChartPeriodConfig _buildSingleDayConfig(DateTime date) {
  final normalized = _normalizeDate(date);
  final label = '${_monthNames[normalized.month - 1]} ${normalized.day}';

  return _ChartPeriodConfig(
    startDate: normalized,
    endDate: normalized,
    bucketCount: 1,
    labels: [label],
    resolveBucket: (d) {
      final normalizedD = _normalizeDate(d);
      if (normalizedD.year == normalized.year &&
          normalizedD.month == normalized.month &&
          normalizedD.day == normalized.day) {
        return 0;
      }
      return null;
    },
  );
}

extension on ReportsPageState {
  _ChartPeriodConfig _getPeriodConfig() {
    // If a specific date is selected, show only that data
    if (selectedSpecificDate != null) {
      return _buildSingleDayConfig(selectedSpecificDate!);
    }

    final normalizedCurrent = _normalizeDate(currentDate);

    switch (selectedPeriod) {
      case 'Monthly':
        return _buildMonthlyConfig(normalizedCurrent);
      case 'Yearly':
        return _buildYearlyConfig(normalizedCurrent);
      default:
        return _buildWeeklyConfig(normalizedCurrent);
    }
  }

  // Always returns period-based config (ignores selectedSpecificDate)
  _ChartPeriodConfig _getPeriodConfigForPeriod() {
    final normalizedCurrent = _normalizeDate(currentDate);

    switch (selectedPeriod) {
      case 'Monthly':
        return _buildMonthlyConfig(normalizedCurrent);
      case 'Yearly':
        return _buildYearlyConfig(normalizedCurrent);
      default:
        return _buildWeeklyConfig(normalizedCurrent);
    }
  }
}