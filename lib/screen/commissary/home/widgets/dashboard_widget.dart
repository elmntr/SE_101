// lib/screens/home/widgets/dashboard_widget.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/design_constants.dart';

/// Dashboard widget shown as the home/landing page of the commissary app.
/// Displays live overview stats (loaded from local DB) and quick action buttons.
class DashboardWidget extends StatefulWidget {
  final String username;
  final int organizationId;
  final void Function(int) onSwitchPage;

  const DashboardWidget({
    super.key,
    required this.username,
    required this.organizationId,
    required this.onSwitchPage,
  });

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  bool _isLoading = true;
  int _activeBranches = 0;
  int _totalItems = 0;
  int _pendingRequests = 0;
  int _lowStockAlerts = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
    syncCompleteNotifier.addListener(_onSyncComplete);
  }

  @override
  void dispose() {
    syncCompleteNotifier.removeListener(_onSyncComplete);
    super.dispose();
  }

  void _onSyncComplete() {
    if (mounted) _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final db = database;
      final results = await Future.wait([
        db.organizationsDao.getOrganizationCount(
          type: 'franchisee',
          isActive: true,
          parentCommissaryId: widget.organizationId,
        ),
        db.itemsDao.getItemCount(),
        db.stockReplenishmentRequestsDao.getRequestCount(
          status: 'pending',
          commissaryId: widget.organizationId,
        ),
        db.branchItemStockDao.getLowStockCountForCommissary(
          widget.organizationId,
        ),
      ]);
      if (mounted) {
        setState(() {
          _activeBranches = results[0];
          _totalItems = results[1];
          _pendingRequests = results[2];
          _lowStockAlerts = results[3];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Text(
            'Welcome back, ${widget.username}!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: fontAll,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Here\'s an overview of your commissary operations.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontFamily: fontAll,
            ),
          ),
          const SizedBox(height: 32),

          // Stats cards
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1200
                  ? 4
                  : constraints.maxWidth > 800
                      ? 2
                      : 1;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    title: 'Active Branches',
                    value: _activeBranches,
                    icon: Icons.store,
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    title: 'Total Items',
                    value: _totalItems,
                    icon: Icons.inventory,
                    color: Colors.green,
                  ),
                  _buildStatCard(
                    title: 'Pending Requests',
                    value: _pendingRequests,
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),
                  _buildStatCard(
                    title: 'Low Stock Alerts',
                    value: _lowStockAlerts,
                    icon: Icons.warning,
                    color: Colors.red,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          // Quick actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: fontAll,
            ),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: constraints.maxWidth > 600 ? 2.5 : 1.5,
                children: [
                  _buildQuickAction(
                    icon: Icons.add_business,
                    label: 'Add Branch',
                    onTap: () => widget.onSwitchPage(1),
                  ),
                  _buildQuickAction(
                    icon: Icons.add_box,
                    label: 'Add Item',
                    onTap: () => widget.onSwitchPage(2),
                  ),
                  _buildQuickAction(
                    icon: Icons.person_add,
                    label: 'Add Branch Admin',
                    onTap: () => widget.onSwitchPage(1),
                  ),
                  _buildQuickAction(
                    icon: Icons.assessment,
                    label: 'View Reports',
                    onTap: () => widget.onSwitchPage(4),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      '$value',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontAll,
                      ),
                    ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontFamily: fontAll,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFEF4848), size: 24),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: fontAll,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
