import 'package:flutter/material.dart';
import '../../../../database/app_database.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> monthNames = [
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

class ChartPeriodConfig {
  const ChartPeriodConfig({
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

DateTime normalizeDate(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);

ChartPeriodConfig buildWeeklyConfig(DateTime current) {
  final end = normalizeDate(current);
  final start = end.subtract(const Duration(days: 6));
  final labels = List<String>.generate(7, (index) {
    final date = start.add(Duration(days: index));
    return '${monthNames[date.month - 1]} ${date.day}';
  });

  return ChartPeriodConfig(
    startDate: start,
    endDate: end,
    bucketCount: 7,
    labels: labels,
    resolveBucket: (date) {
      final normalized = normalizeDate(date);
      final diff = normalized.difference(start).inDays;
      if (diff < 0 || diff >= 7) {
        return null;
      }
      return diff;
    },
  );
}

ChartPeriodConfig buildMonthlyConfig(DateTime current) {
  final end = DateTime(current.year, current.month + 1, 0);
  final start = DateTime(current.year, current.month - 5, 1);
  final labels = List<String>.generate(6, (index) {
    final date = DateTime(start.year, start.month + index, 1);
    return monthNames[date.month - 1];
  });

  return ChartPeriodConfig(
    startDate: start,
    endDate: end,
    bucketCount: 6,
    labels: labels,
    resolveBucket: (date) {
      final normalized = DateTime(date.year, date.month, 1);
      final diff =
          (normalized.year - start.year) * 12 +
          (normalized.month - start.month);
      if (diff < 0 || diff >= 6) {
        return null;
      }
      return diff;
    },
  );
}

ChartPeriodConfig buildYearlyConfig(DateTime current) {
  final startYear = current.year - 2;
  final start = DateTime(startYear, 1, 1);
  final end = DateTime(current.year, 12, 31);
  final labels = List<String>.generate(
    3,
    (index) => (startYear + index).toString(),
  );

  return ChartPeriodConfig(
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

ChartPeriodConfig buildSingleDayConfig(DateTime date) {
  final normalized = normalizeDate(date);
  final label = '${monthNames[normalized.month - 1]} ${normalized.day}';

  return ChartPeriodConfig(
    startDate: normalized,
    endDate: normalized,
    bucketCount: 1,
    labels: [label],
    resolveBucket: (d) {
      final normalizedD = normalizeDate(d);
      if (normalizedD.year == normalized.year &&
          normalizedD.month == normalized.month &&
          normalizedD.day == normalized.day) {
        return 0;
      }
      return null;
    },
  );
}

/// Builds a custom monthly range config
ChartPeriodConfig buildCustomMonthlyConfig(DateTime start, DateTime end) {
  final normalizedStart = DateTime(start.year, start.month, 1);
  final normalizedEnd = DateTime(
    end.year,
    end.month + 1,
    0,
  ); // Last day of end month

  // Calculate number of months
  final monthCount =
      (end.year - start.year) * 12 + (end.month - start.month) + 1;

  final labels = List<String>.generate(monthCount, (index) {
    final date = DateTime(
      normalizedStart.year,
      normalizedStart.month + index,
      1,
    );
    return monthNames[date.month - 1];
  });

  return ChartPeriodConfig(
    startDate: normalizedStart,
    endDate: normalizedEnd,
    bucketCount: monthCount,
    labels: labels,
    resolveBucket: (date) {
      final normalized = DateTime(date.year, date.month, 1);
      final diff =
          (normalized.year - normalizedStart.year) * 12 +
          (normalized.month - normalizedStart.month);
      if (diff < 0 || diff >= monthCount) {
        return null;
      }
      return diff;
    },
  );
}

/// Builds a custom yearly range config
ChartPeriodConfig buildCustomYearlyConfig(DateTime start, DateTime end) {
  final startYear = start.year;
  final endYear = end.year;
  final yearCount = endYear - startYear + 1;

  final normalizedStart = DateTime(startYear, 1, 1);
  final normalizedEnd = DateTime(endYear, 12, 31);

  final labels = List<String>.generate(
    yearCount,
    (index) => (startYear + index).toString(),
  );

  return ChartPeriodConfig(
    startDate: normalizedStart,
    endDate: normalizedEnd,
    bucketCount: yearCount,
    labels: labels,
    resolveBucket: (date) {
      final yearIndex = date.year - startYear;
      if (yearIndex < 0 || yearIndex >= yearCount) {
        return null;
      }
      return yearIndex;
    },
  );
}

/// Controller class that handles all the business logic for the reports page
class FranchiseeReportsController {
  FranchiseeReportsController({required this.db, required this.onStateChanged});

  final AppDatabase db;
  final VoidCallback onStateChanged;

  // UI State
  int? selectedItemId; // null = "All Items"
  String selectedPeriod = 'Weekly';
  DateTime currentDate = DateTime.now();
  DateTime?
  selectedSpecificDate; // null = show range, non-null = show specific date
  String selectedMetric = 'sold';

  // Custom date range for Monthly and Yearly
  DateTime? customRangeStart;
  DateTime? customRangeEnd;
  bool useCustomRange = false;

  // Data from database
  List<Item> allItems = [];
  int? currentOrganizationId;
  Map<String, List<double>> chartData = {};
  double totalSold = 0;
  double totalSpoilage = 0;
  // All-time totals (persistent across period changes)
  double allTimeTotalSold = 0;
  double allTimeTotalSpoilage = 0;
  // Specific date totals (when a date is selected from calendar)
  double selectedDateSold = 0;
  double selectedDateSpoilage = 0;
  bool isLoading = true;
  int _chartRequestId = 0;

  final List<String> periods = ['Weekly', 'Monthly', 'Yearly'];
  static const String orgIdKey = 'current_organization_id';

  // Getters for display - show specific date/range totals when selected, otherwise all-time totals
  double get displayTotalSold {
    if (selectedSpecificDate != null) return selectedDateSold;
    if (useCustomRange) return totalSold;
    return allTimeTotalSold;
  }

  double get displayTotalSpoilage {
    if (selectedSpecificDate != null) return selectedDateSpoilage;
    if (useCustomRange) return totalSpoilage;
    return allTimeTotalSpoilage;
  }

  bool get hasSpecificDateSelected =>
      selectedSpecificDate != null || useCustomRange;

  Future<void> loadData() async {
    isLoading = true;
    onStateChanged();

    try {
      await loadCurrentOrganization();

      List<Item> items;
      if (currentOrganizationId != null) {
        items = await db.itemsDao.getItemsByOrganization(
          currentOrganizationId!,
        );
      } else {
        items = await db.itemsDao.getAllItems();
      }

      allItems = items;
      if (selectedItemId != null &&
          items.every((item) => item.id != selectedItemId)) {
        selectedItemId = null;
      }

      await calculateChartData();
    } catch (e) {
      //print('❌ Error loading reports data: $e');
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  Future<void> loadCurrentOrganization() async {
    final prefs = await SharedPreferences.getInstance();

    // Try to get from current logged-in user session via auth service
    final currentUser = AppGlobals.instance.authService.currentUser;
    if (currentUser != null) {
      // If local ID is 0 but we have cloud ID, look up the local ID
      // This happens on first login when data is synced but UserData has ID 0
      if (currentUser.organizationId == 0 &&
          currentUser.organizationCloudId != null) {
        final org = await db.organizationsDao.getOrganizationByCloudId(
          currentUser.organizationCloudId!,
        );
        if (org != null) {
          currentOrganizationId = org.id;
          await prefs.setInt(orgIdKey, org.id);
          //print(
          //  '📍 Resolved org ID from cloud ID: ${currentUser.organizationCloudId} → ${org.id}'
          //);
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
    final periodConfig =
        getPeriodConfigForPeriod(); // Always get period-based config
    final displayConfig =
        getPeriodConfig(); // Gets single-day if specific date selected
    final requestId = ++_chartRequestId;

    chartData = {
      'sold': List<double>.filled(displayConfig.bucketCount, 0.0),
      'spoilage': List<double>.filled(displayConfig.bucketCount, 0.0),
    };
    totalSold = 0;
    totalSpoilage = 0;
    selectedDateSold = 0;
    selectedDateSpoilage = 0;
    onStateChanged();

    if (currentOrganizationId == null) {
      return;
    }

    try {
      // Fetch all-time summaries for persistent totals
      final allTimeSummaries = await db.dailySalesSummaryDao
          .getSummariesForDateRange(
            organizationId: currentOrganizationId!,
            startDate: DateTime(2000, 1, 1), // Far past date
            endDate: DateTime(2100, 12, 31), // Far future date
          );

      // Calculate all-time totals
      final allTimeIterable = selectedItemId == null
          ? allTimeSummaries
          : allTimeSummaries.where(
              (summary) => summary.itemId == selectedItemId,
            );

      double allTimeSold = 0;
      double allTimeSpoilage = 0;
      for (final summary in allTimeIterable) {
        allTimeSold += summary.quantitySold.toDouble();
        allTimeSpoilage += summary.quantitySpoiled.toDouble();
      }

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
      final spoilageSeries = List<double>.filled(
        displayConfig.bucketCount,
        0.0,
      );

      double calculatedRevenue = 0;

      for (final summary in iterable) {
        // Add to period totals
        periodSold += summary.quantitySold.toDouble();
        periodSpoilage += summary.quantitySpoiled.toDouble();
        calculatedRevenue += summary.revenue;

        // Check if this matches the selected specific date
        if (selectedSpecificDate != null) {
          final summaryDate = summary.summaryDate;
          final selectedDate = selectedSpecificDate!;

          final normalizedSummary = normalizeDate(summaryDate);
          final normalizedSelected = normalizeDate(selectedDate);
          final matches =
              normalizedSummary.year == normalizedSelected.year &&
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

      // \x1B[33m is ANSI yellow, \x1B[0m resets color
      //print('\x1B[33m💰 Total Sales (Revenue) for selected period: ₱${calculatedRevenue.toStringAsFixed(2)}\x1B[0m');
      //print('📊 Total Sold: $periodSold, Total Spoilage: $periodSpoilage');

      if (requestId != _chartRequestId) {
        return;
      }

      chartData = {'sold': soldSeries, 'spoilage': spoilageSeries};
      totalSold = periodSold;
      totalSpoilage = periodSpoilage;
      allTimeTotalSold = allTimeSold;
      allTimeTotalSpoilage = allTimeSpoilage;
      selectedDateSold = dateSold;
      selectedDateSpoilage = dateSpoilage;
      onStateChanged();
    } catch (e) {
      //print('❌ Error calculating chart data: $e');
    }
  }

  String getDateRangeText() {
    // If a specific date is selected, show just that
    if (selectedSpecificDate != null) {
      return formatDate(selectedSpecificDate!);
    }

    // If custom range is active for Monthly or Yearly
    if (useCustomRange && customRangeStart != null && customRangeEnd != null) {
      if (selectedPeriod == 'Monthly') {
        return '${formatMonthYear(customRangeStart!)} - ${formatMonthYear(customRangeEnd!)}';
      } else if (selectedPeriod == 'Yearly') {
        return '${customRangeStart!.year} - ${customRangeEnd!.year}';
      }
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

  void clearDateSelection() {
    selectedSpecificDate = null;
    customRangeStart = null;
    customRangeEnd = null;
    useCustomRange = false;
    currentDate = DateTime.now();
    onStateChanged();
    calculateChartData();
  }

  String formatDate(DateTime date) {
    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  String formatMonthYear(DateTime date) {
    return '${monthNames[date.month - 1]} ${date.year}';
  }

  List<String> getChartLabels() {
    return getPeriodConfig().labels;
  }

  Future<void> navigateDate(bool forward) async {
    // Clear custom range when navigating
    useCustomRange = false;
    customRangeStart = null;
    customRangeEnd = null;

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
    onStateChanged();
    await calculateChartData();
  }

  /// Opens a picker suited to the current aggregation period
  Future<void> openPeriodPicker(BuildContext context) async {
    if (selectedPeriod == 'Yearly') {
      await showYearRangePicker(context);
      return;
    }

    if (selectedPeriod == 'Monthly') {
      await showMonthRangePicker(context);
      return;
    }

    // Show date picker for Weekly period
    await openDatePicker(context);
  }

  Future<void> openDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final firstSelectableDate = DateTime(now.year - 20, 1, 1);
    final lastSelectableDate = DateTime(now.year + 5, 12, 31);
    final normalizedCurrent = normalizeDate(currentDate);
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

    if (picked == null) {
      return;
    }

    selectedSpecificDate = picked;
    currentDate = picked;
    onStateChanged();
    await calculateChartData();
  }

  DateTime alignDateToPeriod(DateTime date) {
    final normalized = normalizeDate(date);

    if (selectedPeriod == 'Weekly') {
      final daysUntilEnd = (DateTime.sunday - normalized.weekday) % 7;
      return normalized.add(Duration(days: daysUntilEnd));
    }

    if (selectedPeriod == 'Monthly') {
      return DateTime(normalized.year, normalized.month, 1);
    }

    return normalized;
  }

  Future<int?> showYearPickerDialog(
    BuildContext context, {
    String title = 'Select Year',
    int? initialYear,
  }) async {
    final now = DateTime.now();
    // Optimized: Reduced date range to prevent performance issues and crashes
    // Using 20 years back and 5 years forward instead of 1900-2076
    final firstDate = DateTime(now.year - 20, 1, 1);
    final lastDate = DateTime(now.year + 5, 1, 1);
    final yearToUse = initialYear ?? currentDate.year;
    final clampedYear = yearToUse.clamp(firstDate.year, lastDate.year).toInt();

    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 320,
            height: 320,
            child: YearPicker(
              firstDate: firstDate,
              lastDate: lastDate,
              initialDate: DateTime(clampedYear, 1, 1),
              selectedDate: DateTime(clampedYear, 1, 1),
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

  /// Shows a year range picker dialog for Yearly period
  Future<void> showYearRangePicker(BuildContext context) async {
    final now = DateTime.now();
    final firstAllowedYear = now.year - 20;
    final lastAllowedYear = now.year + 5;

    int startYear = customRangeStart?.year ?? (currentDate.year - 2);
    int endYear = customRangeEnd?.year ?? currentDate.year;

    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Year Range'),
              content: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Start Year
                    ListTile(
                      title: const Text('From Year'),
                      trailing: DropdownButton<int>(
                        value: startYear.clamp(
                          firstAllowedYear,
                          lastAllowedYear,
                        ),
                        items: List.generate(
                          lastAllowedYear - firstAllowedYear + 1,
                          (index) {
                            final year = firstAllowedYear + index;
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            );
                          },
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              startYear = value;
                              if (endYear < startYear) {
                                endYear = startYear;
                              }
                            });
                          }
                        },
                      ),
                    ),
                    // End Year
                    ListTile(
                      title: const Text('To Year'),
                      trailing: DropdownButton<int>(
                        value: endYear.clamp(startYear, lastAllowedYear),
                        items: List.generate(lastAllowedYear - startYear + 1, (
                          index,
                        ) {
                          final year = startYear + index;
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              endYear = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).pop({'start': startYear, 'end': endYear}),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    customRangeStart = DateTime(result['start']!, 1, 1);
    customRangeEnd = DateTime(result['end']!, 12, 31);
    useCustomRange = true;
    selectedSpecificDate = null;
    currentDate = customRangeEnd!;
    onStateChanged();
    await calculateChartData();
  }

  /// Shows a month range picker dialog for Monthly period
  Future<void> showMonthRangePicker(BuildContext context) async {
    DateTime startMonth =
        customRangeStart ??
        DateTime(currentDate.year, currentDate.month - 5, 1);
    DateTime endMonth =
        customRangeEnd ?? DateTime(currentDate.year, currentDate.month, 1);

    final result = await showDialog<Map<String, DateTime>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Month Range'),
              content: SizedBox(
                width: 340,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Start Month
                    ListTile(
                      title: const Text('From'),
                      subtitle: Text(formatMonthYear(startMonth)),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: () async {
                          final picked = await showMonthYearPicker(
                            context,
                            initialDate: startMonth,
                            title: 'Select Start Month',
                          );
                          if (picked != null) {
                            setDialogState(() {
                              startMonth = picked;
                              if (endMonth.isBefore(startMonth)) {
                                endMonth = startMonth;
                              }
                            });
                          }
                        },
                      ),
                    ),
                    // End Month
                    ListTile(
                      title: const Text('To'),
                      subtitle: Text(formatMonthYear(endMonth)),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: () async {
                          final picked = await showMonthYearPicker(
                            context,
                            initialDate: endMonth,
                            firstDate: startMonth,
                            title: 'Select End Month',
                          );
                          if (picked != null) {
                            setDialogState(() {
                              endMonth = picked;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).pop({'start': startMonth, 'end': endMonth}),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    customRangeStart = result['start']!;
    customRangeEnd = DateTime(
      result['end']!.year,
      result['end']!.month + 1,
      0,
    ); // Last day of month
    useCustomRange = true;
    selectedSpecificDate = null;
    currentDate = customRangeEnd!;
    onStateChanged();
    await calculateChartData();
  }

  /// Helper to show a month/year picker
  Future<DateTime?> showMonthYearPicker(
    BuildContext context, {
    required DateTime initialDate,
    DateTime? firstDate,
    String title = 'Select Month',
  }) async {
    final now = DateTime.now();
    final first = firstDate ?? DateTime(now.year - 20, 1, 1);
    final last = DateTime(now.year + 5, 12, 31);

    int selectedYear = initialDate.year.clamp(first.year, last.year);
    int selectedMonth = initialDate.month;

    return showDialog<DateTime>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Adjust month if year constraint makes current month invalid
            if (selectedYear == first.year && selectedMonth < first.month) {
              selectedMonth = first.month;
            }
            if (selectedYear == last.year && selectedMonth > last.month) {
              selectedMonth = last.month;
            }

            final minMonth = selectedYear == first.year ? first.month : 1;
            final maxMonth = selectedYear == last.year ? last.month : 12;

            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: 280,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Year selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: selectedYear > first.year
                              ? () => setDialogState(() => selectedYear--)
                              : null,
                        ),
                        Text(
                          selectedYear.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: selectedYear < last.year
                              ? () => setDialogState(() => selectedYear++)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Month grid
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 4,
                      childAspectRatio: 1.5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: List.generate(12, (index) {
                        final month = index + 1;
                        final isEnabled =
                            month >= minMonth && month <= maxMonth;
                        final isSelected = month == selectedMonth;

                        return InkWell(
                          onTap: isEnabled
                              ? () =>
                                    setDialogState(() => selectedMonth = month)
                              : null,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isEnabled
                                    ? (isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey[300]!)
                                    : Colors.grey[200]!,
                              ),
                            ),
                            child: Text(
                              monthNames[index],
                              style: TextStyle(
                                color: isEnabled
                                    ? (isSelected ? Colors.white : Colors.black)
                                    : Colors.grey[400],
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).pop(DateTime(selectedYear, selectedMonth, 1)),
                  child: const Text('Select'),
                ),
              ],
            );
          },
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

  ChartPeriodConfig getPeriodConfig() {
    // If a specific date is selected, show only that data
    if (selectedSpecificDate != null) {
      return buildSingleDayConfig(selectedSpecificDate!);
    }

    // If custom range is active
    if (useCustomRange && customRangeStart != null && customRangeEnd != null) {
      if (selectedPeriod == 'Monthly') {
        return buildCustomMonthlyConfig(customRangeStart!, customRangeEnd!);
      } else if (selectedPeriod == 'Yearly') {
        return buildCustomYearlyConfig(customRangeStart!, customRangeEnd!);
      }
    }

    final normalizedCurrent = normalizeDate(currentDate);

    switch (selectedPeriod) {
      case 'Monthly':
        return buildMonthlyConfig(normalizedCurrent);
      case 'Yearly':
        return buildYearlyConfig(normalizedCurrent);
      default:
        return buildWeeklyConfig(normalizedCurrent);
    }
  }

  // Always returns period-based config (ignores selectedSpecificDate but respects custom range)
  ChartPeriodConfig getPeriodConfigForPeriod() {
    // If custom range is active
    if (useCustomRange && customRangeStart != null && customRangeEnd != null) {
      if (selectedPeriod == 'Monthly') {
        return buildCustomMonthlyConfig(customRangeStart!, customRangeEnd!);
      } else if (selectedPeriod == 'Yearly') {
        return buildCustomYearlyConfig(customRangeStart!, customRangeEnd!);
      }
    }

    final normalizedCurrent = normalizeDate(currentDate);

    switch (selectedPeriod) {
      case 'Monthly':
        return buildMonthlyConfig(normalizedCurrent);
      case 'Yearly':
        return buildYearlyConfig(normalizedCurrent);
      default:
        return buildWeeklyConfig(normalizedCurrent);
    }
  }
}
