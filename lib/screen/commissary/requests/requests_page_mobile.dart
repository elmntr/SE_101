import 'dart:io';
import 'package:flutter/material.dart';

import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/services/search_service.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/tables/tables.dart';
import 'package:chickenjoo_inventory/widgets/filter_widgets.dart';
import 'requests_page.dart';

class RequestsPageMobile extends StatelessWidget {
  const RequestsPageMobile({super.key, required this.state});

  final RequestsPageState state;

  // Modern color palette
  static const _primaryColor = Color(0xFF6366F1); // Indigo
  static const _successColor = Color(0xFF10B981); // Emerald
  static const _warningColor = Color(0xFFF59E0B); // Amber
  static const _dangerColor = Color(0xFFEF4444); // Red
  static const _surfaceColor = Color(0xFFF8FAFC); // Slate 50

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surfaceColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern header
              _buildHeader(),
              const SizedBox(height: 16),
              // Search bar
              _buildSearchBar(),
              const SizedBox(height: 16),
              // Tab section
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primaryColor, _primaryColor.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.inventory_2_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stock Requests',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontAll,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                'Manage branch requests',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontFamily: fontAll,
                ),
              ),
            ],
          ),
        ),
        _buildIconButton(
          icon: Icons.refresh_rounded,
          onTap: state.refresh,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
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
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        UniversalFilterButton<String>(
          currentValue: state.requestSortOrder,
          icon: Icons.sort_rounded,
          tooltip: 'Sort requests',
          onSelected: state.setRequestSortOrder,
          options: RequestSortOptions.all,
        ),
      ],
    );
  }

  Widget _buildIconButton({required IconData icon, VoidCallback? onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
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
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildModernTab('Pending', Icons.pending_actions_rounded, 0),
          const SizedBox(width: 6),
          _buildModernTab('History', Icons.history_rounded, 1),
        ],
      ),
    );
  }

  Widget _buildModernTab(String label, IconData icon, int index) {
    final isActive = state.selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => state.setSelectedTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
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
                size: 18,
                color: isActive ? _primaryColor : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
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
            title: allRequests.isEmpty ? 'All Caught Up!' : 'No Results',
            subtitle: allRequests.isEmpty
                ? 'No pending requests'
                : 'Try different search',
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _primaryColor.withOpacity(0.1),
                  _primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.store_rounded,
              color: _primaryColor,
              size: 22,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                branchName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontAll,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildMiniChip('$totalItems items', _primaryColor),
                  const SizedBox(width: 6),
                  _buildMiniChip('$totalQty units', _warningColor),
                ],
              ),
            ],
          ),
          children: [
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 12),
            ...requests.map((req) => _buildRequestItem(req)),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
          fontFamily: fontAll,
        ),
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
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item name and request ID
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(
                      Icons.fastfood_rounded,
                      color: Color(0xFF64748B),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
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
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            fontFamily: fontAll,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Stats row
              Row(
                children: [
                  _buildStatItem(
                    'Requested',
                    '${req.quantityRequested}',
                    const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    'Available',
                    '$stockAvailable',
                    isLowStock ? _dangerColor : _successColor,
                  ),
                  const Spacer(),
                  // Actions
                  _buildActionButton(
                    icon: Icons.check_rounded,
                    color: _successColor,
                    onTap: () => state.approveRequest(req),
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.close_rounded,
                    color: _dangerColor,
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

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF94A3B8),
            fontFamily: fontAll,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: fontAll,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
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
            title: allRequests.isEmpty ? 'No History' : 'No Results',
            subtitle: allRequests.isEmpty
                ? 'Processed requests appear here'
                : 'Try different search',
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
                  'Qty Requested',
                  'Date',
                  'Reviewed',
                  'Status',
                  '',
                ],
                rows: rowSnapshot.data!,
                smallHeaderWidth: 80,
                largeHeaderWidth: 100,
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 40,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: fontAll,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _dangerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: _dangerColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Error',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: fontAll,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: const TextStyle(
              fontSize: 13,
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
