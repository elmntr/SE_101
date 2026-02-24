// lib/screen/settings/sync_conflicts_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import '../../app_globals.dart';
import '../../design_constants.dart';

/// Screen for viewing and resolving sync conflicts
/// Accessible from Settings for both commissary and franchisee admins
/// Franchisee admins only see conflicts for their own organization
class SyncConflictsScreen extends StatefulWidget {
  const SyncConflictsScreen({super.key});

  @override
  State<SyncConflictsScreen> createState() => _SyncConflictsScreenState();
}

class _SyncConflictsScreenState extends State<SyncConflictsScreen> {
  List<SyncConflict> _conflicts = [];
  bool _isLoading = true;
  String? _error;
  bool _showResolved = false;

  @override
  void initState() {
    super.initState();
    _loadConflicts();
  }

  Future<void> _loadConflicts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final db = AppGlobals.instance.database;
      final currentUser = AppGlobals.instance.authService.currentUser;
      final orgId = currentUser?.organizationId;

      List<SyncConflict> conflicts;
      if (_showResolved) {
        conflicts = await db.syncConflictsDao.getAllConflicts(
          organizationId: orgId,
          limit: 100,
        );
      } else {
        conflicts = await db.syncConflictsDao.getUnresolvedConflicts(
          organizationId: orgId,
        );
      }

      setState(() {
        _conflicts = conflicts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load conflicts: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _resolveConflict(SyncConflict conflict, String resolution) async {
    try {
      final db = AppGlobals.instance.database;
      await db.syncConflictsDao.markResolved(
        id: conflict.id,
        resolution: resolution,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conflict resolved: $resolution'),
          backgroundColor: Colors.green,
        ),
      );

      _loadConflicts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resolve: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearResolvedConflicts() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Resolved Conflicts'),
        content: const Text(
          'This will permanently delete all resolved conflicts older than 30 days. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final db = AppGlobals.instance.database;
        final deleted = await db.syncConflictsDao.cleanupOldConflicts(days: 30);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cleared $deleted old conflicts'),
            backgroundColor: Colors.green,
          ),
        );

        _loadConflicts();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Conflicts'),
        backgroundColor: colorAll,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConflicts,
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'toggle_resolved') {
                setState(() => _showResolved = !_showResolved);
                _loadConflicts();
              } else if (value == 'clear_old') {
                _clearResolvedConflicts();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_resolved',
                child: Row(
                  children: [
                    Icon(
                      _showResolved ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(_showResolved ? 'Hide Resolved' : 'Show Resolved'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_old',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 20),
                    SizedBox(width: 8),
                    Text('Clear Old (30+ days)'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadConflicts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_conflicts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _showResolved ? 'No conflicts found' : 'No unresolved conflicts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'All sync operations are working smoothly',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConflicts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _conflicts.length,
        itemBuilder: (context, index) => _buildConflictCard(_conflicts[index]),
      ),
    );
  }

  Widget _buildConflictCard(SyncConflict conflict) {
    final isResolved = conflict.resolvedAt != null;
    final localData = _tryParseJson(conflict.localData);
    final cloudData = _tryParseJson(conflict.cloudData);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isResolved ? 1 : 3,
      color: isResolved ? Colors.grey.shade100 : null,
      child: ExpansionTile(
        leading: Icon(
          isResolved ? Icons.check_circle : Icons.warning_amber,
          color: isResolved ? Colors.green : Colors.orange,
        ),
        title: Text(
          '${conflict.sourceTable} conflict',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isResolved ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          'Type: ${conflict.conflictType} • ${_formatDate(conflict.createdAt)}',
          style: TextStyle(
            fontSize: 12,
            color: isResolved ? Colors.grey : Colors.grey.shade600,
          ),
        ),
        trailing: isResolved
            ? Chip(
                label: Text(conflict.resolution ?? 'resolved'),
                backgroundColor: Colors.green.shade100,
                labelStyle: const TextStyle(fontSize: 10),
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cloud ID
                _buildInfoRow('Cloud ID', conflict.cloudId),
                const Divider(),

                // Data comparison
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Local data
                    Expanded(
                      child: _buildDataSection(
                        'Local Data',
                        localData,
                        Colors.blue.shade50,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Cloud data
                    Expanded(
                      child: _buildDataSection(
                        'Cloud Data',
                        cloudData,
                        Colors.orange.shade50,
                      ),
                    ),
                  ],
                ),

                // Resolution actions
                if (!isResolved) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _resolveConflict(conflict, 'localWins'),
                        icon: const Icon(Icons.phone_android, size: 18),
                        label: const Text('Keep Local'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _resolveConflict(conflict, 'cloudWins'),
                        icon: const Icon(Icons.cloud, size: 18),
                        label: const Text('Keep Cloud'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],

                // Resolution info
                if (isResolved && conflict.resolvedAt != null) ...[
                  const Divider(),
                  _buildInfoRow(
                    'Resolved',
                    '${conflict.resolution} on ${_formatDate(conflict.resolvedAt!)}',
                  ),
                  if (conflict.notes != null && conflict.notes!.isNotEmpty)
                    _buildInfoRow('Notes', conflict.notes!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(
    String title,
    Map<String, dynamic> data,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...data.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${e.key}: ',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${e.value}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          if (data.isEmpty)
            const Text(
              'No data',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Map<String, dynamic> _tryParseJson(String jsonStr) {
    try {
      final decoded = json.decode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'raw': decoded.toString()};
    } catch (_) {
      return {'raw': jsonStr};
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
