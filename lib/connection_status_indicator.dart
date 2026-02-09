// lib/widgets/connection_status_indicator.dart
import 'package:flutter/material.dart';
import '../utils/sync_status.dart';

/// Widget that displays the current connection and sync status
class ConnectionStatusIndicator extends StatelessWidget {
  final bool isOnline;
  final SyncStatus syncStatus;
  final VoidCallback? onSyncPressed;

  const ConnectionStatusIndicator({
    super.key,
    required this.isOnline,
    required this.syncStatus,
    this.onSyncPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isSyncing = syncStatus == SyncStatus.syncing;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: _getTooltipMessage(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getBackgroundColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getBackgroundColor()),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusIcon(),
                const SizedBox(width: 4),
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: _getBackgroundColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (onSyncPressed != null && isOnline) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 16,
              tooltip: isSyncing ? 'Syncing...' : 'Sync now',
              onPressed: isSyncing ? null : onSyncPressed,
              icon: isSyncing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
            ),
          ),
        ],
      ],
    );
  }

  String _getTooltipMessage() {
    if (!isOnline) {
      return 'You are offline. Changes will sync when online.';
    }

    switch (syncStatus) {
      case SyncStatus.syncing:
        return 'Syncing data with the server...';
      case SyncStatus.synced:
        return 'All data is up to date.';
      case SyncStatus.error:
        return 'Sync failed. Will retry automatically.';
      default:
        return '';
    }
  }

  Widget _buildStatusIcon() {
    if (!isOnline) {
      return const Icon(Icons.cloud_off, size: 16, color: Colors.grey);
    }

    switch (syncStatus) {
      case SyncStatus.syncing:
        return SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: _getBackgroundColor(),
          ),
        );
      case SyncStatus.synced:
        return const Icon(Icons.cloud_done, size: 16, color: Colors.green);
      case SyncStatus.error:
        return const Icon(Icons.cloud_off, size: 16, color: Colors.red);
      default:
        return const Icon(Icons.cloud_off, size: 16, color: Colors.grey);
    }
  }

  String _getStatusText() {
    if (!isOnline) return 'Offline';

    switch (syncStatus) {
      case SyncStatus.syncing:
        return 'Syncing';
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.error:
        return 'Error';
      default:
        return 'Idle';
    }
  }

  Color _getBackgroundColor() {
    if (!isOnline) return Colors.grey;

    switch (syncStatus) {
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
