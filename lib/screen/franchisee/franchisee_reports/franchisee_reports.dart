import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:flutter/material.dart';
import '../../../../database/app_database.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'franchisee_reports_mobile.dart';
import 'franchisee_reports_desktop.dart';

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
  String selectedMetric = 'sold';

  // Data from database
  List<Item> allItems = [];
  int? currentOrganizationId;
  Map<String, List<double>> chartData = {};
  double totalSold = 0;
  double totalSpoilage = 0;
  bool isLoading = true;

  final List<String> periods = ['Weekly', 'Monthly', 'Yearly'];
  static const String orgIdKey = 'current_organization_id';

  @override
  void initState() {
    super.initState();
    db = database;
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      // Get current organization from auth service or local storage
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
          calculateChartData();
          calculateTotals();
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading reports data: $e');
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
  void calculateChartData() {
    if (selectedItemId == null) {
      // All items combined
      calculateAllItemsData();
    } else {
      // Single item
      calculateSingleItemData(selectedItemId!);
    }
  }

  /// Calculate totals for the metric cards
  void calculateTotals() {
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
  void calculateAllItemsData() {
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
  void calculateSingleItemData(int itemId) {
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
      return '${formatDate(start)} - ${formatDate(currentDate)}';
    } else if (selectedPeriod == 'Monthly') {
      final start = DateTime(currentDate.year, currentDate.month - 5, 1);
      return '${formatMonthYear(start)} - ${formatMonthYear(currentDate)}';
    } else {
      final start = currentDate.year - 2;
      return '$start - ${currentDate.year}';
    }
  }

  String formatDate(DateTime date) {
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

  String formatMonthYear(DateTime date) {
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
        labels.add('${formatMonthYear(date).split(' ')[0]} ${date.day}');
      }
      return labels;
    } else if (selectedPeriod == 'Monthly') {
      final labels = <String>[];
      for (int i = 5; i >= 0; i--) {
        final date = DateTime(currentDate.year, currentDate.month - i, 1);
        labels.add(formatMonthYear(date).split(' ')[0]);
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
      calculateChartData();
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

    if (AppLayout.isDesktop(context) == false) {
      return ReportsPageMobile(state: this);
    }
    return ReportsPageDesktop(state: this);
  }
}