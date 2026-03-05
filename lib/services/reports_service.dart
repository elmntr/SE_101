// lib/services/reports_service.dart
//
// Reports Service for fetching aggregated sales data from Supabase views
// Uses branch_sales_summary and network_daily_sales views as the source of truth

import 'package:supabase_flutter/supabase_flutter.dart';

/// Data model for network-wide daily sales totals
class NetworkDailySales {
  final DateTime summaryDate;
  final int totalSold;
  final int totalSpoiled;
  final double totalRevenue;
  final double totalCost;
  final double totalProfit;
  final int totalTransactions;
  final int activeBranches;

  NetworkDailySales({
    required this.summaryDate,
    required this.totalSold,
    required this.totalSpoiled,
    required this.totalRevenue,
    required this.totalCost,
    required this.totalProfit,
    required this.totalTransactions,
    required this.activeBranches,
  });

  factory NetworkDailySales.fromJson(Map<String, dynamic> json) {
    return NetworkDailySales(
      summaryDate: DateTime.parse(json['summary_date'] as String),
      totalSold: (json['total_sold'] as num?)?.toInt() ?? 0,
      totalSpoiled: (json['total_spoiled'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0.0,
      totalProfit: (json['total_profit'] as num?)?.toDouble() ?? 0.0,
      totalTransactions: (json['total_transactions'] as num?)?.toInt() ?? 0,
      activeBranches: (json['active_branches'] as num?)?.toInt() ?? 0,
    );
  }

  /// Empty/zero instance for when there's no data
  factory NetworkDailySales.empty(DateTime date) {
    return NetworkDailySales(
      summaryDate: date,
      totalSold: 0,
      totalSpoiled: 0,
      totalRevenue: 0.0,
      totalCost: 0.0,
      totalProfit: 0.0,
      totalTransactions: 0,
      activeBranches: 0,
    );
  }
}

/// Data model for per-branch sales summary
class BranchSalesSummary {
  final String organizationId;
  final String branchName;
  final DateTime summaryDate;
  final int totalSold;
  final double totalRevenue;
  final double totalProfit;

  BranchSalesSummary({
    required this.organizationId,
    required this.branchName,
    required this.summaryDate,
    required this.totalSold,
    required this.totalRevenue,
    required this.totalProfit,
  });

  factory BranchSalesSummary.fromJson(Map<String, dynamic> json) {
    return BranchSalesSummary(
      organizationId: json['organization_id'] as String? ?? '',
      branchName: json['branch_name'] as String? ?? 'Unknown Branch',
      summaryDate: DateTime.parse(json['summary_date'] as String),
      totalSold: (json['total_sold'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      totalProfit: (json['total_profit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Aggregated branch stats for a date range
class BranchAggregatedStats {
  final String organizationId;
  final String branchName;
  final int totalSold;
  final double totalRevenue;
  final double totalProfit;
  final int daysActive;

  BranchAggregatedStats({
    required this.organizationId,
    required this.branchName,
    required this.totalSold,
    required this.totalRevenue,
    required this.totalProfit,
    required this.daysActive,
  });

  /// Create from a list of daily summaries for the same branch
  factory BranchAggregatedStats.fromDailySummaries(List<BranchSalesSummary> summaries) {
    if (summaries.isEmpty) {
      return BranchAggregatedStats(
        organizationId: '',
        branchName: 'Unknown',
        totalSold: 0,
        totalRevenue: 0.0,
        totalProfit: 0.0,
        daysActive: 0,
      );
    }

    return BranchAggregatedStats(
      organizationId: summaries.first.organizationId,
      branchName: summaries.first.branchName,
      totalSold: summaries.fold(0, (sum, s) => sum + s.totalSold),
      totalRevenue: summaries.fold(0.0, (sum, s) => sum + s.totalRevenue),
      totalProfit: summaries.fold(0.0, (sum, s) => sum + s.totalProfit),
      daysActive: summaries.length,
    );
  }
}

/// Aggregated network stats for a date range
class NetworkAggregatedStats {
  final int totalSold;
  final int totalSpoiled;
  final double totalRevenue;
  final double totalCost;
  final double totalProfit;
  final int totalTransactions;
  final int activeBranches;
  final int daysWithSales;

  NetworkAggregatedStats({
    required this.totalSold,
    required this.totalSpoiled,
    required this.totalRevenue,
    required this.totalCost,
    required this.totalProfit,
    required this.totalTransactions,
    required this.activeBranches,
    required this.daysWithSales,
  });

  /// Create from a list of daily network sales
  factory NetworkAggregatedStats.fromDailySales(List<NetworkDailySales> dailySales) {
    if (dailySales.isEmpty) {
      return NetworkAggregatedStats(
        totalSold: 0,
        totalSpoiled: 0,
        totalRevenue: 0.0,
        totalCost: 0.0,
        totalProfit: 0.0,
        totalTransactions: 0,
        activeBranches: 0,
        daysWithSales: 0,
      );
    }

    // Get unique active branches across all days
    final maxActiveBranches = dailySales.fold(0, (max, d) => d.activeBranches > max ? d.activeBranches : max);

    return NetworkAggregatedStats(
      totalSold: dailySales.fold(0, (sum, d) => sum + d.totalSold),
      totalSpoiled: dailySales.fold(0, (sum, d) => sum + d.totalSpoiled),
      totalRevenue: dailySales.fold(0.0, (sum, d) => sum + d.totalRevenue),
      totalCost: dailySales.fold(0.0, (sum, d) => sum + d.totalCost),
      totalProfit: dailySales.fold(0.0, (sum, d) => sum + d.totalProfit),
      totalTransactions: dailySales.fold(0, (sum, d) => sum + d.totalTransactions),
      activeBranches: maxActiveBranches,
      daysWithSales: dailySales.length,
    );
  }

  /// Empty stats
  factory NetworkAggregatedStats.empty() {
    return NetworkAggregatedStats(
      totalSold: 0,
      totalSpoiled: 0,
      totalRevenue: 0.0,
      totalCost: 0.0,
      totalProfit: 0.0,
      totalTransactions: 0,
      activeBranches: 0,
      daysWithSales: 0,
    );
  }
}

/// Service for fetching report data from Supabase views
class ReportsService {
  final SupabaseClient supabase;

  ReportsService({required this.supabase});

  /// Calculate date range based on period selection
  ({DateTime start, DateTime end}) getDateRange(String period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (period) {
      case 'Today':
        return (start: today, end: today);
      case 'This Week':
        // Start of week (Monday)
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        return (start: weekStart, end: today);
      case 'This Month':
        final monthStart = DateTime(now.year, now.month, 1);
        return (start: monthStart, end: today);
      case 'This Year':
        final yearStart = DateTime(now.year, 1, 1);
        return (start: yearStart, end: today);
      default:
        return (start: today, end: today);
    }
  }

  /// Fetch network-wide daily sales for a date range
  Future<List<NetworkDailySales>> fetchNetworkDailySales({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startStr = _formatDate(startDate);
      final endStr = _formatDate(endDate);

      final response = await supabase
          .from('network_daily_sales')
          .select()
          .gte('summary_date', startStr)
          .lte('summary_date', endStr)
          .order('summary_date', ascending: false);

      return (response as List)
          .map((json) => NetworkDailySales.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching network daily sales: $e');
      return [];
    }
  }

  /// Fetch aggregated network stats for a period
  Future<NetworkAggregatedStats> fetchNetworkStats(String period) async {
    final range = getDateRange(period);
    final dailySales = await fetchNetworkDailySales(
      startDate: range.start,
      endDate: range.end,
    );
    return NetworkAggregatedStats.fromDailySales(dailySales);
  }

  /// Fetch branch sales summary for a date range
  Future<List<BranchSalesSummary>> fetchBranchSalesSummary({
    required DateTime startDate,
    required DateTime endDate,
    String? organizationId,
  }) async {
    try {
      final startStr = _formatDate(startDate);
      final endStr = _formatDate(endDate);

      var query = supabase
          .from('branch_sales_summary')
          .select()
          .gte('summary_date', startStr)
          .lte('summary_date', endStr);

      if (organizationId != null) {
        query = query.eq('organization_id', organizationId);
      }

      final response = await query.order('summary_date', ascending: false);

      return (response as List)
          .map((json) => BranchSalesSummary.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching branch sales summary: $e');
      return [];
    }
  }

  /// Fetch aggregated stats per branch for a period
  Future<List<BranchAggregatedStats>> fetchBranchStats(String period) async {
    final range = getDateRange(period);
    final summaries = await fetchBranchSalesSummary(
      startDate: range.start,
      endDate: range.end,
    );

    // Group by organization_id
    final grouped = <String, List<BranchSalesSummary>>{};
    for (final summary in summaries) {
      grouped.putIfAbsent(summary.organizationId, () => []).add(summary);
    }

    // Aggregate each group
    return grouped.values
        .map((list) => BranchAggregatedStats.fromDailySummaries(list))
        .toList()
      ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
  }

  /// Fetch stats for a specific branch
  Future<BranchAggregatedStats?> fetchSingleBranchStats({
    required String organizationId,
    required String period,
  }) async {
    final range = getDateRange(period);
    final summaries = await fetchBranchSalesSummary(
      startDate: range.start,
      endDate: range.end,
      organizationId: organizationId,
    );

    if (summaries.isEmpty) return null;
    return BranchAggregatedStats.fromDailySummaries(summaries);
  }

  /// Fetch daily breakdown for a specific branch
  Future<List<BranchSalesSummary>> fetchBranchDailyBreakdown({
    required String organizationId,
    required String period,
  }) async {
    final range = getDateRange(period);
    return fetchBranchSalesSummary(
      startDate: range.start,
      endDate: range.end,
      organizationId: organizationId,
    );
  }

  /// Format date for Supabase query
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
