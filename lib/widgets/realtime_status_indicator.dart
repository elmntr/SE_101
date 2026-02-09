// lib/widgets/realtime_status_indicator.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/realtime_stock_request_service.dart';

/// Widget that displays the realtime WebSocket connection status.
/// Shows: 🟢 Live, 🟡 Reconnecting, 🔵 Polling, 🔴 Disconnected
/// Includes animated pulse when actively connected.
class RealtimeStatusIndicator extends StatefulWidget {
  final RealtimeStockRequestService service;
  final bool compact;
  final VoidCallback? onTap;

  const RealtimeStatusIndicator({
    super.key,
    required this.service,
    this.compact = false,
    this.onTap,
  });

  @override
  State<RealtimeStatusIndicator> createState() => _RealtimeStatusIndicatorState();
}

class _RealtimeStatusIndicatorState extends State<RealtimeStatusIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late StreamSubscription<RealtimeConnectionStatus> _statusSubscription;
  RealtimeConnectionStatus _status = RealtimeConnectionStatus.disconnected;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _status = widget.service.status;
    _updateAnimation();

    _statusSubscription = widget.service.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _status = status;
        });
        _updateAnimation();
      }
    });
  }

  void _updateAnimation() {
    if (_status == RealtimeConnectionStatus.connected) {
      _pulseController.repeat(reverse: true);
    } else if (_status == RealtimeConnectionStatus.connecting ||
               _status == RealtimeConnectionStatus.reconnecting) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _statusSubscription.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Color _statusColor() {
    switch (_status) {
      case RealtimeConnectionStatus.connected:
        return Colors.green;
      case RealtimeConnectionStatus.connecting:
      case RealtimeConnectionStatus.reconnecting:
        return Colors.orange;
      case RealtimeConnectionStatus.polling:
        return Colors.blue;
      case RealtimeConnectionStatus.disconnected:
        return Colors.red;
    }
  }

  IconData _statusIcon() {
    switch (_status) {
      case RealtimeConnectionStatus.connected:
        return Icons.wifi;
      case RealtimeConnectionStatus.connecting:
      case RealtimeConnectionStatus.reconnecting:
        return Icons.sync;
      case RealtimeConnectionStatus.polling:
        return Icons.update;
      case RealtimeConnectionStatus.disconnected:
        return Icons.wifi_off;
    }
  }

  String _statusText() {
    switch (_status) {
      case RealtimeConnectionStatus.connected:
        return 'LIVE';
      case RealtimeConnectionStatus.connecting:
        return 'CONNECTING';
      case RealtimeConnectionStatus.reconnecting:
        return 'RECONNECTING';
      case RealtimeConnectionStatus.polling:
        return 'POLLING';
      case RealtimeConnectionStatus.disconnected:
        return 'OFFLINE';
    }
  }

  String _tooltipMessage() {
    switch (_status) {
      case RealtimeConnectionStatus.connected:
        return 'Real-time updates active. You will receive instant notifications.';
      case RealtimeConnectionStatus.connecting:
        return 'Establishing real-time connection...';
      case RealtimeConnectionStatus.reconnecting:
        return 'Connection lost. Attempting to reconnect...';
      case RealtimeConnectionStatus.polling:
        return 'Real-time unavailable. Checking for updates periodically.';
      case RealtimeConnectionStatus.disconnected:
        return 'Not connected. Updates will sync when you refresh.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    final isAnimating = _status == RealtimeConnectionStatus.connected ||
                        _status == RealtimeConnectionStatus.connecting ||
                        _status == RealtimeConnectionStatus.reconnecting;

    final icon = AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: isAnimating 
              ? 0.8 + (_pulseController.value * 0.2) 
              : 1.0,
          child: child,
        );
      },
      child: Icon(
        _statusIcon(),
        size: widget.compact ? 14 : 16,
        color: color,
      ),
    );

    if (widget.compact) {
      return Tooltip(
        message: _tooltipMessage(),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: icon,
          ),
        ),
      );
    }

    return Tooltip(
      message: _tooltipMessage(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 6),
              Text(
                _statusText(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
