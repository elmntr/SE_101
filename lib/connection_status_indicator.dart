import 'package:flutter/material.dart';
import '../utils/sync_status.dart';

class ConnectionStatusIndicator extends StatefulWidget {
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
  State<ConnectionStatusIndicator> createState() =>
      _ConnectionStatusIndicatorState();
}

class _ConnectionStatusIndicatorState extends State<ConnectionStatusIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    if (widget.syncStatus == SyncStatus.syncing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ConnectionStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.syncStatus == SyncStatus.syncing) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _statusColor() {
    if (!widget.isOnline) {
      return Colors.red;
    }

    switch (widget.syncStatus) {
      case SyncStatus.syncing:
        return Colors.orange;
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusText() {
    if (!widget.isOnline) {
      return 'OFFLINE';
    }

    switch (widget.syncStatus) {
      case SyncStatus.syncing:
        return 'SYNCING';
      case SyncStatus.synced:
        return 'SYNCED';
      case SyncStatus.error:
        return 'SYNC ERROR';
      default:
        return 'UNKNOWN';
    }
  }

  String _tooltipMessage() {
    if (!widget.isOnline) {
      return 'You are offline. Changes will sync when online.';
    }

    switch (widget.syncStatus) {
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

  @override
  Widget build(BuildContext context) {
    final icon = ScaleTransition(
      scale: widget.syncStatus == SyncStatus.syncing
          ? Tween<double>(begin: 0.8, end: 1.0).animate(_controller)
          : const AlwaysStoppedAnimation(1),
      child: Icon(Icons.circle, size: 10, color: _statusColor()),
    );

    final isSyncing = widget.syncStatus == SyncStatus.syncing;

    return Tooltip(
      message: _tooltipMessage(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          Text(_statusText(), style: const TextStyle(fontSize: 12)),
          if (widget.onSyncPressed != null && widget.isOnline) ...[
            const SizedBox(width: 4),
            SizedBox(
              width: 28,
              height: 28,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 16,
                tooltip: isSyncing ? 'Syncing...' : 'Sync now',
                onPressed: isSyncing ? null : widget.onSyncPressed,
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
      ),
    );
  }
}
