// lib/screens/reports/reports_page.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/services/reports_service.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'reports_page_controller.dart';
import 'reports_page_desktop.dart';
import 'reports_page_mobile.dart';

/// Reports Page - Cross-branch reporting for commissary
/// Uses Supabase views (branch_sales_summary, network_daily_sales) for accurate data
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => ReportsPageState();
}

class ReportsPageState extends State<ReportsPage> {
  late ReportsPageController controller;

  // Expose controller properties for UI access
  bool get isLoading => controller.isLoading;
  String? get errorMessage => controller.errorMessage;
  NetworkAggregatedStats get networkStats => controller.networkStats;
  List<BranchAggregatedStats> get branchStats => controller.branchStats;
  List<BranchSalesSummary> get selectedBranchDailyData =>
      controller.selectedBranchDailyData;
  BranchAggregatedStats? get selectedBranch => controller.selectedBranch;
  String get selectedPeriod => controller.selectedPeriod;
  int get desktopGridColumns => controller.desktopGridColumns;
  int get mobileGridColumns => controller.mobileGridColumns;
  String get branchSearchQuery => controller.branchSearchQuery;
  String get branchSortBy => controller.branchSortBy;

  @override
  void initState() {
    super.initState();
    controller = ReportsPageController(
      onStateChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
    controller.loadData();
  }

  // Delegate methods to controller
  void setSelectedPeriod(String period) => controller.setSelectedPeriod(period);
  void setSelectedBranch(BranchAggregatedStats? branch) =>
      controller.setSelectedBranch(branch);
  void setDesktopGridColumns(int columns) =>
      controller.setDesktopGridColumns(columns);
  void setMobileGridColumns(int columns) =>
      controller.setMobileGridColumns(columns);
  void setBranchSearchQuery(String query) =>
      controller.setBranchSearchQuery(query);
  void setBranchSortBy(String sortBy) => controller.setBranchSortBy(sortBy);
  Future<void> loadData() => controller.loadData();

  /// Format currency with thousands separator
  String formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(2);
  }

  /// Get filtered and sorted branches for table display
  List<BranchAggregatedStats> getFilteredBranches() {
    List<BranchAggregatedStats> filtered = branchStats.where((branch) {
      // Filter by selected branch if one is chosen
      if (selectedBranch != null &&
          branch.organizationId != selectedBranch!.organizationId) {
        return false;
      }
      return branch.branchName.toLowerCase().contains(branchSearchQuery);
    }).toList();

    filtered.sort((a, b) {
      switch (branchSortBy) {
        case 'revenue':
          return b.totalRevenue.compareTo(a.totalRevenue);
        case 'sold':
          return b.totalSold.compareTo(a.totalSold);
        case 'profit':
          return b.totalProfit.compareTo(a.totalProfit);
        case 'days':
          return b.daysActive.compareTo(a.daysActive);
        case 'name':
        default:
          return a.branchName.compareTo(b.branchName);
      }
    });

    return filtered;
  }

  /// Show grid settings dialog to customize columns
  void showGridSettingsDialog(bool isMobile) {
    final currentColumns = isMobile ? mobileGridColumns : desktopGridColumns;
    final minColumns = isMobile ? 1 : 2;
    final maxColumns = isMobile ? 3 : 6;
    int selectedColumns = currentColumns;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.grid_view, color: Color(0xFFEF4848)),
              const SizedBox(width: 12),
              Text(
                isMobile ? 'Mobile Grid Settings' : 'Desktop Grid Settings',
                style: const TextStyle(fontFamily: fontAll),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Number of columns: $selectedColumns',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontAll,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('$minColumns',
                      style: const TextStyle(fontFamily: fontAll)),
                  Expanded(
                    child: Slider(
                      value: selectedColumns.toDouble(),
                      min: minColumns.toDouble(),
                      max: maxColumns.toDouble(),
                      divisions: maxColumns - minColumns,
                      activeColor: const Color(0xFFEF4848),
                      label: '$selectedColumns',
                      onChanged: (value) {
                        setDialogState(() {
                          selectedColumns = value.toInt();
                        });
                      },
                    ),
                  ),
                  Text('$maxColumns',
                      style: const TextStyle(fontFamily: fontAll)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isMobile
                            ? 'Adjust columns for better viewing on mobile devices'
                            : 'Adjust columns to fit your screen size',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontFamily: fontAll,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(fontFamily: fontAll)),
            ),
            ElevatedButton(
              onPressed: () {
                if (isMobile) {
                  setMobileGridColumns(selectedColumns);
                } else {
                  setDesktopGridColumns(selectedColumns);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4848),
                foregroundColor: Colors.white,
              ),
              child:
                  const Text('Apply', style: TextStyle(fontFamily: fontAll)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (AppLayout.isDesktop(context) == false) {
      return ReportsPageMobile(state: this);
    }
    return ReportsPageDesktop(state: this);
  }
}
