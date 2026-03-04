import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/services/search_service.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/utils/tables.dart';
import 'package:chickenjoo_inventory/widgets/filter_widgets.dart';
import 'requests_page.dart';

class RequestsPageDesktop extends StatelessWidget {
  const RequestsPageDesktop({super.key, required this.state});

  final RequestsPageState state;

  // Modern color palette
  static const _primaryColor = Color(0xFF6366F1); // Indigo
  static const _successColor = Color(0xFF10B981); // Emerald
  static const _warningColor = Color(0xFFF59E0B); // Amber
  static const _dangerColor = Color(0xFFEF4444); // Red
  static const _surfaceColor = Color(0xFFF8FAFC); // Slate 50
  static const _cardColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surfaceColor,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern header with gradient accent
            _buildHeader(),
            const SizedBox(height: 24),
            // Tab section with modern design
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildModernTabs(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: state.selectedTab == 0
                            ? _buildPendingRequestsTab()
                            : _buildHistoryTab(),
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

  Widget _buildHeader() {
    return Row(
      children: [
        // Title with icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primaryColor, _primaryColor.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.inventory_2_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock Replenishment',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                fontFamily: fontAll,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              'Manage branch stock requests',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontFamily: fontAll,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Search bar
        SizedBox(
          width: 300,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: UniversalSearchBar(
              controller: state.searchController,
              onSearch: (value) {
                state.setSearchQuery(value.toLowerCase());
              },
              hintText: 'Search requests...',
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildIconButton(
          icon: Icons.sort_rounded,
          tooltip: 'Sort',
          onTap: () {},
          child: UniversalFilterButton<String>(
            currentValue: state.requestSortOrder,
            icon: Icons.sort_rounded,
            tooltip: 'Sort requests',
            onSelected: state.setRequestSortOrder,
            options: RequestSortOptions.all,
          ),
        ),
        const SizedBox(width: 8),
        _buildIconButton(
          icon: Icons.refresh_rounded,
          tooltip: 'Refresh',
          onTap: state.refresh,
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    VoidCallback? onTap,
    Widget? child,
  }) {
    if (child != null) return child;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(icon, color: const Color(0xFF64748B), size: 22),
        ),
      ),
    );
  }

  Widget _buildModernTabs() {
    return Container(
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildModernTab('Pending Requests', Icons.pending_actions_rounded, 0),
          const SizedBox(width: 8),
          _buildModernTab('Request History', Icons.history_rounded, 1),
        ],
      ),
    );
  }

  Widget _buildModernTab(String label, IconData icon, int index) {
    final isActive = state.selectedTab == index;

    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => state.setSelectedTab(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? _primaryColor : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? const Color(0xFF1E293B)
                        : const Color(0xFF64748B),
                    fontFamily: fontAll,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingRequestsTab() {
    return StreamBuilder<List<StockReplenishmentRequest>>(
      stream: state.db.stockReplenishmentRequestsDao.watchRequests(
        status: 'pending',
        commissaryId: state.commissaryId!,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: _primaryColor),
          );
        }

        final allRequests = snapshot.data!;

        var requests = allRequests.where((req) {
          if (state.searchQuery.isEmpty) return true;
          return req.id.toString().contains(state.searchQuery) ||
              req.quantityRequested.toString().contains(state.searchQuery);
        }).toList();

        requests = state.sortRequests(requests);

        if (requests.isEmpty) {
          return _buildEmptyState(
            icon: Icons.check_circle_outline_rounded,
            title: allRequests.isEmpty
                ? 'All Caught Up!'
                : 'No Matching Requests',
            subtitle: allRequests.isEmpty
                ? 'No pending requests at the moment'
                : 'Try adjusting your search criteria',
          );
        }

        return FutureBuilder<Map<int, String>>(
          future: state.getBranchNames(requests),
          builder: (context, branchSnapshot) {
            if (!branchSnapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: _primaryColor),
              );
            }

            final branchNames = branchSnapshot.data!;

            // Group by branch
            final groupedByBranch = <int, List<StockReplenishmentRequest>>{};
            for (final req in requests) {
              groupedByBranch.putIfAbsent(req.franchiseeId, () => []).add(req);
            }

            return ListView.builder(
              itemCount: groupedByBranch.length,
              itemBuilder: (context, index) {
                final branchId = groupedByBranch.keys.elementAt(index);
                final branchRequests = groupedByBranch[branchId]!;
                final branchName = branchNames[branchId] ?? 'Unknown Branch';

                return _buildBranchCard(
                  context,
                  branchName: branchName,
                  requests: branchRequests,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBranchCard(
    BuildContext context, {
    required String branchName,
    required List<StockReplenishmentRequest> requests,
  }) {
    final totalItems = requests.length;
    final totalQty = requests.fold(0, (sum, r) => sum + r.quantityRequested);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _primaryColor.withOpacity(0.1),
                  _primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.store_rounded,
              color: _primaryColor,
              size: 24,
            ),
          ),
          title: Text(
            branchName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: fontAll,
              color: Color(0xFF1E293B),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatChip(
                icon: Icons.inventory_2_outlined,
                label: '$totalItems items',
                color: _primaryColor,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                icon: Icons.scale_outlined,
                label: '$totalQty units',
                color: _warningColor,
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          children: [
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 16),
            ...requests.map((req) => _buildRequestItem(req)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: fontAll,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestItem(StockReplenishmentRequest req) {
    return FutureBuilder<Item?>(
      future: state.db.itemsDao.getItemById(req.itemId),
      builder: (context, snapshot) {
        final item = snapshot.data;
        final itemName = item?.name ?? 'Loading...';
        final stockAvailable = item?.stock ?? 0;
        final isLowStock = stockAvailable < req.quantityRequested;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              // Item info
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(
                        Icons.fastfood_rounded,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            itemName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: fontAll,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            'Request #${req.id}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                              fontFamily: fontAll,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Quantity requested
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Requested',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontFamily: fontAll,
                      ),
                    ),
                    Text(
                      '${req.quantityRequested} units',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: fontAll,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              // Stock available
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontFamily: fontAll,
                      ),
                    ),
                    Row(
                      children: [
                        if (isLowStock)
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: _dangerColor,
                            size: 16,
                          ),
                        if (isLowStock) const SizedBox(width: 4),
                        Text(
                          '$stockAvailable units',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: fontAll,
                            color: isLowStock
                                ? _dangerColor
                                : _successColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Date
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Requested On',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontFamily: fontAll,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, h:mm a').format(req.createdAt),
                      style: const TextStyle(
                        fontFamily: fontAll,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(
                    icon: Icons.check_rounded,
                    color: _successColor,
                    tooltip: 'Approve',
                    onTap: () => state.approveRequest(req),
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.close_rounded,
                    color: _dangerColor,
                    tooltip: 'Reject',
                    onTap: () => state.rejectRequest(req),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return StreamBuilder<List<StockReplenishmentRequest>>(
      stream: state.db.stockReplenishmentRequestsDao.watchRequests(
        commissaryId: state.commissaryId!,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: _primaryColor),
          );
        }

        final allRequests =
            snapshot.data!.where((r) => r.status != 'pending').toList();

        var requests = allRequests.where((req) {
          if (state.searchQuery.isEmpty) return true;
          return req.id.toString().contains(state.searchQuery) ||
              req.status.toLowerCase().contains(state.searchQuery);
        }).toList();

        requests = state.sortRequests(requests);

        if (requests.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history_rounded,
            title: allRequests.isEmpty ? 'No History Yet' : 'No Matching Results',
            subtitle: allRequests.isEmpty
                ? 'Processed requests will appear here'
                : 'Try adjusting your search criteria',
          );
        }

        return FutureBuilder<List<List<dynamic>>>(
          future: state.buildHistoryRows(requests),
          builder: (context, rowSnapshot) {
            if (!rowSnapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: _primaryColor),
              );
            }

            return buildUniversalTable(
              headers: [
                'Request ID',
                'Branch',
                'Item',
                'Amount Requested',
                'Date',
                'Reviewed',
                'Status',
                '',
              ],
              rows: rowSnapshot.data!,
              smallHeaderWidth: 20,
              largeHeaderWidth: 80,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 48,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: fontAll,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: fontAll,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _dangerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: _dangerColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Error loading requests',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: fontAll,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: fontAll,
              color: _dangerColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
