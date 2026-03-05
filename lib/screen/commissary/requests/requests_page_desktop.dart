import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/services/search_service.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/tables/tables.dart';
import 'package:chickenjoo_inventory/widgets/filter_widgets.dart';
import 'requests_page.dart';

class RequestsPageDesktop extends StatelessWidget {
  const RequestsPageDesktop({super.key, required this.state});

  final RequestsPageState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header row with title, search bar, filter, and notifications
            Row(
              children: [
                const Text(
                  'Stock Replenishment',
                  style: TextStyle(fontSize: 25, fontFamily: fontAll),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: UniversalSearchBar(
                    controller: state.searchController,
                    onSearch: (value) {
                      state.setSearchQuery(value.toLowerCase());
                    },
                    hintText: 'Search requests...',
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                UniversalFilterButton<String>(
                  currentValue: state.requestSortOrder,
                  icon: Icons.sort,
                  tooltip: 'Sort requests',
                  onSelected: state.setRequestSortOrder,
                  options: RequestSortOptions.all,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 30),
                  tooltip: 'Refresh',
                  onPressed: state.refresh,
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 35),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tab section
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildTab('Pending Requests', 0),
                        _buildTab('Request History', 1),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: state.selectedTab == 0
                          ? _buildPendingRequestsTab()
                          : _buildHistoryTab(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = state.selectedTab == index;

    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => state.setSelectedTab(index),
          child: Container(
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingRequestsTab() {
    return StreamBuilder<List<StockReplenishmentRequest>>(
      stream: state.db.stockReplenishmentRequestsDao.watchRequests(status: 'pending', 
        commissaryId: state.commissaryId!,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allRequests = snapshot.data!;

        // Filter requests based on search
        var requests = allRequests.where((req) {
          if (state.searchQuery.isEmpty) return true;
          return req.id.toString().contains(state.searchQuery) ||
              req.quantityRequested.toString().contains(state.searchQuery);
        }).toList();

        // Apply sorting
        requests = state.sortRequests(requests);

        if (requests.isEmpty) {
          return emptyTables(
            message: allRequests.isEmpty
                ? 'No pending requests. All caught up!'
                : 'No requests match your search.',
            onAddPressed: null,
            buttonType: EmptyButtonType.none,
          );
        }

        return FutureBuilder<List<List<dynamic>>>(
          future: state.buildRequestRows(requests),
          builder: (context, rowSnapshot) {
            if (!rowSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Column(
                children: requests
                    .fold<Map<String, List<StockReplenishmentRequest>>>(
                      <String, List<StockReplenishmentRequest>>{},
                      (map, req) {
                        map.putIfAbsent(
                          req.createdAt.toIso8601String(),
                          () => <StockReplenishmentRequest>[],
                        ).add(req);
                        return map;
                      },
                    )
                    .entries
                    .map(
                      (entry) => ExpansionTile(
                        title: Text(
                          '${DateFormat('MMM d, yyyy  h:mm a').format(entry.value.first.createdAt)} '
                          '(${entry.value.length} requests)',
                        ),
                        children: [
                          buildUniversalTable(
                            headers: [
                              'Request ID',
                              'Branch',
                              'Item',
                              'Amount Requested',
                              'Stock Available',
                              'Date',
                              'Status',
                              '',
                            ],
                            rows: entry.value
                                .map(
                                  (req) =>
                                      requests.indexWhere((r) => r.id == req.id),
                                )
                                .where(
                                  (index) =>
                                      index >= 0 && index < rowSnapshot.data!.length,
                                )
                                .map((index) => rowSnapshot.data![index])
                                .toList(),
                            smallHeaderWidth: 30,
                            largeHeaderWidth: 70,
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return StreamBuilder<List<StockReplenishmentRequest>>(
      stream: state.db.stockReplenishmentRequestsDao.watchRequests(
        commissaryId: state.commissaryId!,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter to show only non-pending (approved/rejected) requests
        final allRequests = snapshot.data!
            .where((r) => r.status != 'pending')
            .toList();

        // Filter requests based on search
        var requests = allRequests.where((req) {
          if (state.searchQuery.isEmpty) return true;
          return req.id.toString().contains(state.searchQuery) ||
              req.status.toLowerCase().contains(state.searchQuery);
        }).toList();

        // Apply sorting
        requests = state.sortRequests(requests);

        if (requests.isEmpty) {
          return emptyTables(
            message: allRequests.isEmpty
                ? 'No request history yet.'
                : 'No requests match your search.',
            onAddPressed: null,
            buttonType: EmptyButtonType.none,
          );
        }

        return FutureBuilder<List<List<dynamic>>>(
          future: state.buildHistoryRows(requests),
          builder: (context, rowSnapshot) {
            if (!rowSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            // Desktop: show all columns with wider widths
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
}
