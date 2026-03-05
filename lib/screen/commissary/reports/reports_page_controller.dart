// lib/screens/reports/reports_page_controller.dart
import 'package:flutter/foundation.dart';

import 'package:chickenjoo_inventory/services/reports_service.dart';
import 'package:chickenjoo_inventory/utils/tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportsPageController {
  final VoidCallback onStateChanged;
  late ReportsService reportsService;

  bool isLoading = true;
  String? errorMessage;

  // Data from Supabase views
  NetworkAggregatedStats networkStats = NetworkAggregatedStats.empty();
  List<BranchAggregatedStats> branchStats = [];
  List<BranchSalesSummary> selectedBranchDailyData = [];

  // Filters
  BranchAggregatedStats? selectedBranch; // null = All branches
  String selectedPeriod = 'This Week';

  // Grid settings
  int desktopGridColumns = 4; // Default: 4 columns on desktop
  int mobileGridColumns = 2; // Default: 2 columns on mobile

  // Search and sort for branches table
  String branchSearchQuery = '';
  String branchSortBy = 'name'; // name, revenue, sold, profit, days

  ReportsPageController({
    required this.onStateChanged,
  }) {
    reportsService = ReportsService(supabase: Supabase.instance.client);
  }

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    onStateChanged();

    try {
      // Fetch network-wide stats from Supabase view
      final nStats = await reportsService.fetchNetworkStats(selectedPeriod);

      // Fetch per-branch stats from Supabase view
      final bStats = await reportsService.fetchBranchStats(selectedPeriod);

      // If a specific branch is selected, fetch its daily breakdown
      List<BranchSalesSummary> branchDailyData = [];
      if (selectedBranch != null) {
        branchDailyData = await reportsService.fetchBranchDailyBreakdown(
          organizationId: selectedBranch!.organizationId,
          period: selectedPeriod,
        );
      }

      networkStats = nStats;
      branchStats = bStats;
      selectedBranchDailyData = branchDailyData;
      isLoading = false;
      onStateChanged();
    } catch (e) {
      print('âŒ Error loading reports: $e');
      errorMessage = 'Failed to load reports: $e';
      isLoading = false;
      onStateChanged();
    }
  }

  void setSelectedPeriod(String period) {
    selectedPeriod = period;
    onStateChanged();
    loadData();
  }

  void setSelectedBranch(BranchAggregatedStats? branch) {
    selectedBranch = branch;
    onStateChanged();
    loadData();
  }

  void setDesktopGridColumns(int columns) {
    desktopGridColumns = columns;
    onStateChanged();
  }

  void setMobileGridColumns(int columns) {
    mobileGridColumns = columns;
    onStateChanged();
  }

  void setBranchSearchQuery(String query) {
    branchSearchQuery = query;
    onStateChanged();
  }

  void setBranchSortBy(String sortBy) {
    branchSortBy = sortBy;
    onStateChanged();
  }
}
