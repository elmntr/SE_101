// lib/screens/reports/reports_page_mobile.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/services/reports_service.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'reports_page.dart';

class ReportsPageMobile extends StatelessWidget {
  final ReportsPageState state;

  const ReportsPageMobile({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(state.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: state.loadData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => state.loadData(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Reports',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: fontAll,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.grid_view, size: 20),
                                onPressed: () =>
                                    state.showGridSettingsDialog(true),
                                tooltip: 'Grid settings',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Filters
                          _buildMobileFilters(context),
                          const SizedBox(height: 16),

                          // Stats
                          _buildMobileStats(),
                          const SizedBox(height: 16),

                          // Branch Comparison
                          const Text(
                            'Branch Revenue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontAll,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildMobileBranchComparison(),
                          const SizedBox(height: 16),

                          // Branch List
                          Text(
                            state.selectedBranch == null
                                ? 'All Branches'
                                : state.selectedBranch!.branchName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontAll,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildMobileBranchTableControls(),
                          const SizedBox(height: 8),
                          _buildMobileBranchList(),

                          // Daily breakdown when a branch is selected
                          if (state.selectedBranch != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              '${state.selectedBranch!.branchName} - Daily Breakdown',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontAll,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildMobileBranchDetails(),
                          ],
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildMobileFilters(BuildContext context) {
    return Column(
      children: [
        // Branch filter (full width)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<BranchAggregatedStats?>(
              isExpanded: true,
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
        const SizedBox(height: 8),

        // Period filter + Export button row
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
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
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export feature coming soon')),
                );
              },
              tooltip: 'Export',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileStats() {
    final stats = state.networkStats;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: state.mobileGridColumns,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.4,
      children: [
        _buildMobileStatCard(
          title: 'Branches',
          value: '${stats.activeBranches}',
          icon: Icons.store,
          color: Colors.blue,
        ),
        _buildMobileStatCard(
          title: 'Revenue',
          value: '₱${state.formatCurrency(stats.totalRevenue)}',
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        _buildMobileStatCard(
          title: 'Sold',
          value: '${stats.totalSold}',
          icon: Icons.shopping_cart,
          color: Colors.purple,
        ),
        _buildMobileStatCard(
          title: 'Profit',
          value: '₱${state.formatCurrency(stats.totalProfit)}',
          icon: Icons.trending_up,
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildMobileStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontAll,
                ),
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontFamily: fontAll,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBranchComparison() {
    final displayBranches = state.selectedBranch != null
        ? state.branchStats
            .where((b) => b.organizationId == state.selectedBranch!.organizationId)
            .toList()
        : state.branchStats;

    if (displayBranches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
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
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: displayBranches.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final branch = displayBranches[index];
          final maxRevenue = state.networkStats.totalRevenue > 0
              ? state.networkStats.totalRevenue
              : 1;
          final percentage =
              (branch.totalRevenue / maxRevenue * 100).clamp(0, 100).toInt();

          return SizedBox(
            width: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '₱${state.formatCurrency(branch.totalRevenue)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 9),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Container(
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
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
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  branch.branchName,
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileBranchTableControls() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
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
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (value) =>
                state.setBranchSearchQuery(value.toLowerCase()),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: state.branchSortBy,
              icon: const Icon(Icons.sort, size: 18),
              items: const [
                DropdownMenuItem(value: 'name', child: Text('Sort by Name')),
                DropdownMenuItem(
                    value: 'revenue', child: Text('Sort by Revenue')),
                DropdownMenuItem(value: 'sold', child: Text('Sort by Sold')),
                DropdownMenuItem(
                    value: 'profit', child: Text('Sort by Profit')),
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

  Widget _buildMobileBranchList() {
    final filteredBranches = state.getFilteredBranches();

    if (filteredBranches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            state.branchStats.isEmpty
                ? 'No branch data available'
                : 'No branches match your search',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: filteredBranches.map((branch) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              branch.branchName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: fontAll,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                _buildMobileStat(
                    'Revenue', '₱${state.formatCurrency(branch.totalRevenue)}'),
                _buildMobileStat('Sold', '${branch.totalSold}'),
                _buildMobileStat(
                    'Profit', '₱${state.formatCurrency(branch.totalProfit)}'),
                _buildMobileStat('Days Active', '${branch.daysActive}'),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => state.setSelectedBranch(branch),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMobileBranchDetails() {
    if (state.selectedBranchDailyData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No daily data for this branch',
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Column(
      children: state.selectedBranchDailyData.map((summary) {
        final dateStr =
            '${summary.summaryDate.month}/${summary.summaryDate.day}/${summary.summaryDate.year}';
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateStr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: fontAll,
                  )),
              const SizedBox(height: 4),
              _buildMobileStat(
                  'Revenue', '₱${state.formatCurrency(summary.totalRevenue)}'),
              _buildMobileStat('Sold', '${summary.totalSold}'),
              _buildMobileStat(
                  'Profit', '₱${state.formatCurrency(summary.totalProfit)}'),
            ],
          ),
        );
      }).toList(),
    );
  }
}
