// lib/screens/reports/reports_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chickenjoo_inventory/services/reports_service.dart';
import 'package:chickenjoo_inventory/design_constants.dart';

/// Reports Page - Cross-branch reporting for commissary
/// Uses Supabase views (branch_sales_summary, network_daily_sales) for accurate data
class CommissaryReportsPage extends StatefulWidget {
  const CommissaryReportsPage({super.key});

  @override
  State<CommissaryReportsPage> createState() => _CommissaryReportsPageState();
}

class _CommissaryReportsPageState extends State<CommissaryReportsPage> {
  late ReportsService _reportsService;
  bool _isLoading = true;
  String? _errorMessage;

  // Data from Supabase views
  NetworkAggregatedStats _networkStats = NetworkAggregatedStats.empty();
  List<BranchAggregatedStats> _branchStats = [];
  List<BranchSalesSummary> _selectedBranchDailyData = [];
  
  // Filters
  BranchAggregatedStats? _selectedBranch; // null = All branches
  String _selectedPeriod = 'This Week';

  @override
  void initState() {
    super.initState();
    _reportsService = ReportsService(supabase: Supabase.instance.client);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch network-wide stats from Supabase view
      final networkStats = await _reportsService.fetchNetworkStats(_selectedPeriod);
      
      // Fetch per-branch stats from Supabase view
      final branchStats = await _reportsService.fetchBranchStats(_selectedPeriod);

      // If a specific branch is selected, fetch its daily breakdown
      List<BranchSalesSummary> branchDailyData = [];
      if (_selectedBranch != null) {
        branchDailyData = await _reportsService.fetchBranchDailyBreakdown(
          organizationId: _selectedBranch!.organizationId,
          period: _selectedPeriod,
        );
      }

      setState(() {
        _networkStats = networkStats;
        _branchStats = branchStats;
        _selectedBranchDailyData = branchDailyData;
        _isLoading = false;
      });
    } catch (e) {
      print('? Error loading reports: $e');
      setState(() {
        _errorMessage = 'Failed to load reports: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AppLayout.isDesktop(context) == false) {
      // MOBILE VIEW
      return Scaffold(
        backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                            style: TextStyle(fontSize: 26, fontFamily: fontAll),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, size: 28),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Mobile Filters
                      _buildMobileFilters(),
                      const SizedBox(height: 16),

                      // Mobile Stats
                      _buildMobileStats(),
                      const SizedBox(height: 24),

                      // Branch Performance
                      const Text(
                        'Branch Performance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontAll,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildMobileBranchComparison(),
                      const SizedBox(height: 24),

                      // Error message if any
                      if (_errorMessage != null) ...[                
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Branch List
                      if (_selectedBranch == null) ...[
                        const Text(
                          'All Branches',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontAll,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildMobileBranchList(),
                      ] else if (_selectedBranch != null) ...[
                        Text(
                          _selectedBranch!.branchName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontAll,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildMobileBranchDetails(),
                      ],
                    ],
                  ),
                ),
        ),
      );
    }

    // DESKTOP VIEW
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filters
                  _buildFilters(),
                  const SizedBox(height: 24),

                  // Overall stats
                  _buildOverallStats(),
                  const SizedBox(height: 32),

                  // Branch comparison
                  const Text(
                    'Branch Performance',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontAll,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBranchComparison(),
                  const SizedBox(height: 32),

                  // Error message if any
                  if (_errorMessage != null) ...[                
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Detailed tables
                  if (_selectedBranch == null) ...[
                    const Text(
                      'All Branches Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontAll,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAllBranchesTable(),
                  ] else ...[
                    Text(
                      '${_selectedBranch!.branchName} Details',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontAll,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBranchDetailsTable(),
                  ],
                ],
              ),
            ),
    );
  }

  // DESKTOP WIDGETS

  Widget _buildFilters() {
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
              value: _selectedBranch,
              hint: const Text('All Branches'),
              items: [
                const DropdownMenuItem<BranchAggregatedStats?>(
                  value: null,
                  child: Text('All Branches'),
                ),
                ..._branchStats.map((branch) => DropdownMenuItem(
                      value: branch,
                      child: Text(branch.branchName),
                    )),
              ],
              onChanged: (value) {
                setState(() => _selectedBranch = value);
                _loadData(); // Reload data for selected branch
              },
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
              value: _selectedPeriod,
              items: ['Today', 'This Week', 'This Month', 'This Year']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedPeriod = value!);
                _loadData(); // Reload data for new period
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
          value: '${_networkStats.activeBranches}',
          icon: Icons.store,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Total Revenue',
          value: '?${_formatCurrency(_networkStats.totalRevenue)}',
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Total Sold',
          value: '${_networkStats.totalSold}',
          icon: Icons.shopping_cart,
          color: Colors.purple,
        ),
        _buildStatCard(
          title: 'Total Profit',
          value: '?${_formatCurrency(_networkStats.totalProfit)}',
          icon: Icons.trending_up,
          color: Colors.teal,
        ),
        _buildStatCard(
          title: 'Total Spoilage',
          value: '${_networkStats.totalSpoiled}',
          icon: Icons.delete_forever,
          color: Colors.orange,
        ),
      ],
    );
  }

  /// Format currency with thousands separator
  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(2);
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
        
        // Calculate appropriate sizes based on available space
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
    if (_branchStats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No branches to compare',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _branchStats.map((branch) {
          final maxRevenue = _networkStats.totalRevenue > 0 ? _networkStats.totalRevenue : 1;
          final percentage = (branch.totalRevenue / maxRevenue * 100).clamp(0, 100).toInt();

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '?${_formatCurrency(branch.totalRevenue)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
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
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAllBranchesTable() {
    if (_branchStats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No branch data available for this period'),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DataTable(
        columns: const [
          DataColumn(
              label: Text('Branch', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Revenue', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Sold', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Profit', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Days Active', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: _branchStats.map((branch) {
          return DataRow(cells: [
            DataCell(Text(branch.branchName)),
            DataCell(Text('?${_formatCurrency(branch.totalRevenue)}')),
            DataCell(Text('${branch.totalSold}')),
            DataCell(Text('?${_formatCurrency(branch.totalProfit)}')),
            DataCell(Text('${branch.daysActive}')),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildBranchDetailsTable() {
    if (_selectedBranchDailyData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No sales data found for this branch in the selected period'),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Revenue', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Sold', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Profit', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: _selectedBranchDailyData.map((summary) {
          final dateStr = '${summary.summaryDate.month}/${summary.summaryDate.day}/${summary.summaryDate.year}';

          return DataRow(cells: [
            DataCell(Text(dateStr)),
            DataCell(Text('?${_formatCurrency(summary.totalRevenue)}')),
            DataCell(Text('${summary.totalSold}')),
            DataCell(Text('?${_formatCurrency(summary.totalProfit)}')),
          ]);
        }).toList(),
      ),
    );
  }

  // MOBILE WIDGETS

  Widget _buildMobileFilters() {
    return Column(
      children: [
        // Branch filter
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
              value: _selectedBranch,
              isExpanded: true,
              hint: const Text('All Branches'),
              items: [
                const DropdownMenuItem<BranchAggregatedStats?>(
                  value: null,
                  child: Text('All Branches'),
                ),
                ..._branchStats.map((branch) => DropdownMenuItem(
                      value: branch,
                      child: Text(branch.branchName),
                    )),
              ],
              onChanged: (value) {
                setState(() => _selectedBranch = value);
                _loadData();
              },
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Period filter
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPeriod,
              isExpanded: true,
              items: ['Today', 'This Week', 'This Month', 'This Year']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedPeriod = value!);
                _loadData();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMobileStatCard(
                title: 'Branches',
                value: '${_networkStats.activeBranches}',
                icon: Icons.store,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMobileStatCard(
                title: 'Revenue',
                value: '?${_formatCurrency(_networkStats.totalRevenue)}',
                icon: Icons.attach_money,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMobileStatCard(
                title: 'Sold',
                value: '${_networkStats.totalSold}',
                icon: Icons.shopping_cart,
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMobileStatCard(
                title: 'Profit',
                value: '?${_formatCurrency(_networkStats.totalProfit)}',
                icon: Icons.trending_up,
                color: Colors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildMobileStatCard(
          title: 'Total Spoilage',
          value: '${_networkStats.totalSpoiled}',
          icon: Icons.delete_forever,
          color: Colors.orange,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontAll,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontFamily: fontAll,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBranchComparison() {
    if (_branchStats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No branches to compare',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _branchStats.map((branch) {
          final maxRevenue = _networkStats.totalRevenue > 0 ? _networkStats.totalRevenue : 1;
          final percentage = (branch.totalRevenue / maxRevenue * 100).clamp(0, 100).toInt();

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '?${_formatCurrency(branch.totalRevenue)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Container(
                      width: double.infinity,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileBranchList() {
    if (_branchStats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No branch data available for this period'),
        ),
      );
    }

    return Column(
      children: _branchStats.map((branch) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      branch.branchName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontAll,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${branch.daysActive} days',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMobileStat('Revenue', '?${_formatCurrency(branch.totalRevenue)}'),
                  _buildMobileStat('Sold', '${branch.totalSold}'),
                  _buildMobileStat('Profit', '?${_formatCurrency(branch.totalProfit)}'),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileStat(String label, String value, {bool hasWarning = false}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasWarning)
              const Icon(Icons.warning, color: Colors.orange, size: 14),
            if (hasWarning) const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBranchDetails() {
    if (_selectedBranchDailyData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No sales data found for this branch'),
        ),
      );
    }

    return Column(
      children: _selectedBranchDailyData.map((summary) {
        final dateStr = '${summary.summaryDate.month}/${summary.summaryDate.day}/${summary.summaryDate.year}';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontAll,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: summary.totalProfit >= 0
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      summary.totalProfit >= 0 ? 'Profit' : 'Loss',
                      style: TextStyle(
                        color: summary.totalProfit >= 0 ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMobileStat('Revenue', '?${_formatCurrency(summary.totalRevenue)}'),
                  _buildMobileStat('Sold', '${summary.totalSold}'),
                  _buildMobileStat('Profit', '?${_formatCurrency(summary.totalProfit)}'),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}