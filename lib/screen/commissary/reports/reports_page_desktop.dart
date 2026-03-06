// lib/screens/reports/reports_page_desktop.dart
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/services/reports_service.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/utils/tables.dart';
import 'reports_page.dart';

class ReportsPageDesktop extends StatelessWidget {
  final ReportsPageState state;

  const ReportsPageDesktop({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(state.errorMessage!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: state.loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Text(
                        'Reports',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontAll,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Filters
                      _buildFilters(context),
                      const SizedBox(height: 24),

                      // Overall Stats
                      _buildOverallStats(),
                      const SizedBox(height: 24),

                      // Branch Comparison Chart
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Branch Revenue Comparison',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontAll,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.grid_view, size: 20),
                            onPressed: () =>
                                state.showGridSettingsDialog(false),
                            tooltip: 'Grid settings',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildBranchComparison(),
                      const SizedBox(height: 24),

                      // Branch Table
                      if (state.selectedBranch == null) ...[
                        const Text(
                          'All Branches',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontAll,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildBranchTableControls(),
                        const SizedBox(height: 8),
                        _buildAllBranchesTable(),
                      ] else ...[
                        Text(
                          '${state.selectedBranch!.branchName} - Daily Breakdown',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontAll,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildBranchDetailsTable(),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Row(
      children: [
        // Branch filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<BranchAggregatedStats?>(
              value: state.selectedBranch,
              hint: const Text('All Branches'),
              items: [
                const DropdownMenuItem<BranchAggregatedStats?>(
                  value: null,
                  child: Text('All Branches'),
                ),
                ...state.branchStats.map((branch) => DropdownMenuItem(
                      value: branch,
                      child: Text(branch.branchName),
                    )),
              ],
              onChanged: (value) => state.setSelectedBranch(value),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Period filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.selectedPeriod,
              items: ['Today', 'This Week', 'This Month', 'This Year']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) {
                if (value != null) state.setSelectedPeriod(value);
              },
            ),
          ),
        ),
        const Spacer(),

        // Export button
        OutlinedButton.icon(
          icon: const Icon(Icons.download),
          label: const Text('Export Report'),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export feature coming soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOverallStats() {
    final stats = state.networkStats;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: [
        _buildStatCard(
          title: 'Active Branches',
          value: '${stats.activeBranches}',
          icon: Icons.store,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Total Revenue',
          value: '₱${state.formatCurrency(stats.totalRevenue)}',
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Total Sold',
          value: '${stats.totalSold}',
          icon: Icons.shopping_cart,
          color: Colors.purple,
        ),
        _buildStatCard(
          title: 'Total Profit',
          value: '₱${state.formatCurrency(stats.totalProfit)}',
          icon: Icons.trending_up,
          color: Colors.teal,
        ),
        _buildStatCard(
          title: 'Total Spoilage',
          value: '${stats.totalSpoiled}',
          icon: Icons.delete_forever,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final padding = availableHeight * 0.12;
        final iconSize = availableHeight * 0.15;
        final valueFontSize = (availableHeight * 0.20).clamp(16.0, 28.0);
        final titleFontSize = (availableHeight * 0.10).clamp(10.0, 13.0);

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(padding * 0.4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: iconSize),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: valueFontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontAll,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: padding * 0.2),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: fontAll,
                        fontSize: titleFontSize,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBranchComparison() {
    final displayBranches = state.selectedBranch != null
        ? state.branchStats
            .where((b) => b.organizationId == state.selectedBranch!.organizationId)
            .toList()
        : state.branchStats;

    if (displayBranches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No branches to compare',
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: state.desktopGridColumns,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: 200, // Fixed height for consistent bar charts
        ),
        itemCount: displayBranches.length,
        itemBuilder: (context, index) {
          final branch = displayBranches[index];
          final maxRevenue = state.networkStats.totalRevenue > 0
              ? state.networkStats.totalRevenue
              : 1;
          final percentage =
              (branch.totalRevenue / maxRevenue * 100).clamp(0, 100).toInt();

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '₱${state.formatCurrency(branch.totalRevenue)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.bottomCenter,
                    heightFactor: percentage / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            const Color(0xFFEF4848),
                            const Color(0xFFEF4848).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                branch.branchName,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBranchTableControls() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search branches...',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey),
              ),
              onChanged: (value) =>
                  state.setBranchSearchQuery(value.toLowerCase()),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.branchSortBy,
              icon: const Icon(Icons.sort),
              items: const [
                DropdownMenuItem(
                    value: 'name', child: Text('Sort by Name')),
                DropdownMenuItem(
                    value: 'revenue', child: Text('Sort by Revenue')),
                DropdownMenuItem(
                    value: 'sold', child: Text('Sort by Sold')),
                DropdownMenuItem(
                    value: 'profit', child: Text('Sort by Profit')),
                DropdownMenuItem(
                    value: 'days', child: Text('Sort by Days Active')),
              ],
              onChanged: (value) {
                if (value != null) state.setBranchSortBy(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllBranchesTable() {
    final filteredBranches = state.getFilteredBranches();

    if (filteredBranches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            state.branchStats.isEmpty
                ? 'No branch data available for this period'
                : 'No branches match your search',
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: buildUniversalTable(
        headers: ['Branch', 'Revenue', 'Sold', 'Profit', 'Days Active'],
        rows: filteredBranches.map((branch) {
          return [
            Text(branch.branchName),
            Text('₱${state.formatCurrency(branch.totalRevenue)}'),
            Text('${branch.totalSold}'),
            Text('₱${state.formatCurrency(branch.totalProfit)}'),
            Text('${branch.daysActive}'),
          ];
        }).toList(),
        smallHeaderWidth: 80,
        largeHeaderWidth: 120,
        showHorizontalScrollbar: Platform.isWindows,
        horizontalController:
            Platform.isWindows ? ScrollController() : null,
      ),
    );
  }

  Widget _buildBranchDetailsTable() {
    if (state.selectedBranchDailyData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
              'No sales data found for this branch in the selected period'),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: buildUniversalTable(
        headers: ['Date', 'Revenue', 'Sold', 'Profit'],
        rows: state.selectedBranchDailyData.map((summary) {
          final dateStr =
              '${summary.summaryDate.month}/${summary.summaryDate.day}/${summary.summaryDate.year}';
          return [
            Text(dateStr),
            Text('₱${state.formatCurrency(summary.totalRevenue)}'),
            Text('${summary.totalSold}'),
            Text('₱${state.formatCurrency(summary.totalProfit)}'),
          ];
        }).toList(),
        smallHeaderWidth: 80,
        largeHeaderWidth: 120,
        showHorizontalScrollbar: Platform.isWindows,
        horizontalController:
            Platform.isWindows ? ScrollController() : null,
      ),
    );
  }
}
