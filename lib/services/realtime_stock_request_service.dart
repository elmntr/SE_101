// lib/services/realtime_stock_request_service.dart
import 'dart:async';
import 'dart:math';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/app_database.dart';
import '../utils/app_logger.dart';

/// ============================================================================
/// REALTIME STOCK REQUEST SERVICE (SE_101 - Franchisee)
/// ============================================================================
///
/// Provides real-time updates when stock replenishment requests are approved.
/// Features:
/// - WebSocket subscription to stock_replenishment_requests UPDATE events
/// - Exponential backoff retry (3 attempts) before falling back to polling
/// - Adaptive polling intervals based on connection type and battery state
/// - Debounced sync to prevent duplicate operations
/// - Reference counting for multi-screen usage
/// - Lifecycle management (pause/resume for app backgrounding)
/// ============================================================================

/// Connection status for the realtime service
enum RealtimeConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  polling,
}

/// Event emitted when a stock request status changes
class StockRequestEvent {
  final String cloudId;
  final String franchiseeId;
  final String itemId;
  final int quantityRequested;
  final String oldStatus;
  final String newStatus;
  final DateTime timestamp;
  final Map<String, dynamic> rawData;

  StockRequestEvent({
    required this.cloudId,
    required this.franchiseeId,
    required this.itemId,
    required this.quantityRequested,
    required this.oldStatus,
    required this.newStatus,
    required this.timestamp,
    required this.rawData,
  });

  bool get isApproved => newStatus == 'approved';
  bool get isRejected => newStatus == 'rejected';
  bool get isDelivered => newStatus == 'delivered';
}

class RealtimeStockRequestService {
  final SupabaseClient supabase;
  final AppDatabase db;

  // Channel management
  RealtimeChannel? _stockRequestChannel;
  
  // Connection state
  RealtimeConnectionStatus _status = RealtimeConnectionStatus.disconnected;
  bool _isPaused = false;
  
  // Reference counting for multi-screen usage
  int _activeScreenCount = 0;
  
  // Retry configuration
  static const int _maxRetries = 3;
  static const Duration _initialRetryDelay = Duration(seconds: 1);
  
  // Polling fallback
  Timer? _pollingTimer;
  DateTime? _lastPollTime;
  Timer? _realtimeRetryTimer;
  bool _isAttemptingRealtime = false;
  
  // Adaptive polling intervals
  Duration _currentPollingInterval = const Duration(seconds: 5);
  static const Duration _wifiPollingInterval = Duration(seconds: 5);
  static const Duration _cellularPollingInterval = Duration(seconds: 10);
  static const Duration _lowBatteryPollingInterval = Duration(seconds: 30);
  static const Duration _realtimeRetryInterval = Duration(seconds: 60);
  
  // Debouncing
  Timer? _debounceTimer;
  bool _isSyncing = false;
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  
  // Dependencies
  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  // Stream controllers
  final StreamController<RealtimeConnectionStatus> _statusController =
      StreamController<RealtimeConnectionStatus>.broadcast();
  final StreamController<StockRequestEvent> _eventController =
      StreamController<StockRequestEvent>.broadcast();

  // Callbacks
  Function(StockRequestEvent event)? onRequestStatusChanged;
  Function(RealtimeConnectionStatus status)? onConnectionStatusChanged;
  Function(String error)? onError;
  Future<void> Function()? syncCallback;

  // Organization filter
  String? _franchiseeCloudId;

  RealtimeStockRequestService({
    required this.supabase,
    required this.db,
  });

  /// Stream of connection status changes
  Stream<RealtimeConnectionStatus> get statusStream => _statusController.stream;

  /// Stream of stock request events
  Stream<StockRequestEvent> get eventStream => _eventController.stream;

  /// Current connection status
  RealtimeConnectionStatus get status => _status;

  /// Check if actively listening
  bool get isListening => _status == RealtimeConnectionStatus.connected || 
                          _status == RealtimeConnectionStatus.polling;

  /// Number of screens currently using this service
  int get activeScreenCount => _activeScreenCount;

  // ═══════════════════════════════════════════════════════════════════════════
  // REFERENCE COUNTING (Multi-screen support)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Attach a screen to this service (increments reference count)
  /// Starts listening if this is the first screen
  Future<void> attach(String franchiseeCloudId) async {
    _activeScreenCount++;
    _franchiseeCloudId = franchiseeCloudId;
    
    AppLogger.sync('📎 Screen attached (count: $_activeScreenCount)');
    
    if (_activeScreenCount == 1) {
      await _startListening();
    }
  }

  /// Detach a screen from this service (decrements reference count)
  /// Stops listening if this was the last screen
  Future<void> detach() async {
    _activeScreenCount = (_activeScreenCount - 1).clamp(0, 999);
    
    AppLogger.sync('📎 Screen detached (count: $_activeScreenCount)');
    
    if (_activeScreenCount == 0) {
      await _stopListening();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Pause subscriptions (call when app goes to background)
  Future<void> pause() async {
    if (_isPaused) return;
    _isPaused = true;
    
    AppLogger.sync('⏸️ Realtime stock request service paused');
    
    // Unsubscribe but keep state
    if (_stockRequestChannel != null) {
      await supabase.removeChannel(_stockRequestChannel!);
      _stockRequestChannel = null;
    }
    
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _cancelRealtimeRetry();
    
    _updateStatus(RealtimeConnectionStatus.disconnected);
  }

  /// Resume subscriptions (call when app returns to foreground)
  Future<void> resume() async {
    if (!_isPaused) return;
    _isPaused = false;
    
    AppLogger.sync('▶️ Realtime stock request service resumed');
    
    if (_activeScreenCount > 0 && _franchiseeCloudId != null) {
      await _startListening();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUBSCRIPTION MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _startListening() async {
    if (_franchiseeCloudId == null) {
      AppLogger.error('Cannot start listening: franchiseeCloudId not set');
      return;
    }

    _updateStatus(RealtimeConnectionStatus.connecting);
    
    // Start connectivity monitoring for adaptive polling
    _startConnectivityMonitoring();
    
    await _connectWithRetry();
  }

  Future<void> _connectWithRetry() async {
    if (_isPaused || _activeScreenCount == 0) return;
    if (_isAttemptingRealtime) return;

    _isAttemptingRealtime = true;
    try {
      _updateStatus(RealtimeConnectionStatus.connecting);

      int attempt = 0;
      while (attempt < _maxRetries && !_isPaused && _activeScreenCount > 0) {
        attempt++;
        try {
          await _createChannel();
          _cancelRealtimeRetry();
          _pollingTimer?.cancel();
          _pollingTimer = null;
          return;
        } catch (e) {
          AppLogger.sync('WARN Realtime connect attempt $attempt failed: $e');
          if (attempt >= _maxRetries) {
            _startPollingFallback();
            _scheduleRealtimeRetry();
            return;
          }
          await Future.delayed(_calculateBackoff(attempt));
        }
      }
    } finally {
      _isAttemptingRealtime = false;
    }
  }

  Future<void> _createChannel() async {
    AppLogger.sync('🔧 Creating channel for franchisee: $_franchiseeCloudId');
    
    // Issue 10 fix: Use stable channel name to prevent socket leak (was using DateTime which created new channels on reconnect)
    final channelName = 'stock-requests-$_franchiseeCloudId';
    if (_stockRequestChannel != null) {
      await supabase.removeChannel(_stockRequestChannel!);
      _stockRequestChannel = null;
    }
    _stockRequestChannel = supabase.channel(channelName);

    final completer = Completer<void>();
    
    // Listen to ALL postgres changes (*, not just update) without filter
    _stockRequestChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,  // Listen to INSERT, UPDATE, DELETE
          schema: 'public',
          table: 'stock_replenishment_requests',
          callback: (payload) {
            AppLogger.sync('🔔 POSTGRES CHANGE RECEIVED! Event type: ${payload.eventType}');
            AppLogger.sync('   Old: ${payload.oldRecord}');
            AppLogger.sync('   New: ${payload.newRecord}');
            
            // Only process updates
            if (payload.eventType == PostgresChangeEvent.update) {
              // Manual filter check
              final franchiseeId = payload.newRecord['franchisee_id']?.toString();
              AppLogger.sync('   Checking: franchisee_id=$franchiseeId vs expected=$_franchiseeCloudId');
              
              if (franchiseeId == _franchiseeCloudId) {
                _handleStatusUpdate(payload.oldRecord, payload.newRecord);
              } else {
                AppLogger.sync('   ⏭️ Skipping - not for this franchisee');
              }
            }
          },
        )
        .subscribe((status, error) {
          AppLogger.sync('📡 Subscription status: $status, error: $error');
          if (status == RealtimeSubscribeStatus.subscribed) {
            AppLogger.sync('✅ Successfully subscribed to stock_replenishment_requests changes (channel: $channelName)');
            _updateStatus(RealtimeConnectionStatus.connected);
            if (!completer.isCompleted) {
              completer.complete();
            }
          } else if (status == RealtimeSubscribeStatus.closed) {
            AppLogger.sync('❌ Channel closed');
            _handleDisconnection();
          } else if (status == RealtimeSubscribeStatus.channelError) {
            AppLogger.sync('❌ Channel error: $error');
            if (!completer.isCompleted) {
              completer.completeError(error ?? Exception('Channel error'));
            }
          }
          if (error != null) {
            AppLogger.error('Realtime subscription error: $error');
            onError?.call(error.toString());
          }
        });

    // Wait for subscription to complete or timeout
    await completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('WebSocket subscription timed out');
      },
    );
  }

  void _handleDisconnection() {
    if (_isPaused || _activeScreenCount == 0) return;
    
    AppLogger.sync('❌ WebSocket disconnected, attempting reconnection...');
    _updateStatus(RealtimeConnectionStatus.reconnecting);
    
    // Attempt to reconnect
    Future.delayed(const Duration(seconds: 2), () {
      if (!_isPaused && _activeScreenCount > 0) {
        _connectWithRetry();
      }
    });
  }

  Future<void> _stopListening() async {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _realtimeRetryTimer?.cancel();
    _realtimeRetryTimer = null;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    
    if (_stockRequestChannel != null) {
      await supabase.removeChannel(_stockRequestChannel!);
      _stockRequestChannel = null;
    }
    
    _updateStatus(RealtimeConnectionStatus.disconnected);
    AppLogger.sync('🔌 Disconnected from stock request feed');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POLLING FALLBACK
  // ═══════════════════════════════════════════════════════════════════════════

  void _startPollingFallback() {
    _updateStatus(RealtimeConnectionStatus.polling);
    _updatePollingInterval();
    
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_currentPollingInterval, (_) {
      _pollForUpdates();
    });
    
    // Do an immediate poll
    _pollForUpdates();
    
    AppLogger.sync('📊 Started polling fallback (interval: ${_currentPollingInterval.inSeconds}s)');
    _scheduleRealtimeRetry();
  }

  Future<void> _pollForUpdates() async {
    if (_isPaused || _isSyncing) return;
    
    try {
      AppLogger.sync('📊 Polling for franchisee_id: $_franchiseeCloudId');
      
      // Query for ANY approved/rejected/delivered requests
      // The sync service will handle checking if local DB needs updating
      final response = await supabase
          .from('stock_replenishment_requests')
          .select()
          .eq('franchisee_id', _franchiseeCloudId!)
          .inFilter('status', ['approved', 'rejected', 'delivered'])
          .eq('is_deleted', false);
      
      AppLogger.sync('📊 Found ${(response as List).length} approved/rejected/delivered requests');
      
      if (response.isNotEmpty) {
        // Just trigger a sync - let the sync service figure out what's new
        AppLogger.sync('📬 Triggering sync to check for updates...');
        _triggerDebouncedSync();
      }
    } catch (e) {
      AppLogger.error('Polling error: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ADAPTIVE POLLING
  // ═══════════════════════════════════════════════════════════════════════════

  void _startConnectivityMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      _updatePollingInterval();
    });
  }

  Future<void> _updatePollingInterval() async {
    try {
      // Check battery state
      final batteryState = await _battery.batteryState;
      final batteryLevel = await _battery.batteryLevel;
      final isLowBattery = batteryLevel < 20 || batteryState == BatteryState.discharging && batteryLevel < 30;
      
      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      final isWifi = connectivityResult == ConnectivityResult.wifi;
      
      // Determine polling interval
      if (isLowBattery) {
        _currentPollingInterval = _lowBatteryPollingInterval;
      } else if (isWifi) {
        _currentPollingInterval = _wifiPollingInterval;
      } else {
        _currentPollingInterval = _cellularPollingInterval;
      }
      
      // Restart timer with new interval if polling
      if (_status == RealtimeConnectionStatus.polling && _pollingTimer != null) {
        _pollingTimer?.cancel();
        _pollingTimer = Timer.periodic(_currentPollingInterval, (_) {
          _pollForUpdates();
        });
        AppLogger.sync('📊 Polling interval updated to ${_currentPollingInterval.inSeconds}s');
      }
    } catch (e) {
      // Default to cellular interval if battery check fails
      _currentPollingInterval = _cellularPollingInterval;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EVENT HANDLING
  // ═══════════════════════════════════════════════════════════════════════════

  void _handleStatusUpdate(Map<String, dynamic> oldRecord, Map<String, dynamic> newRecord) {
    try {
      final oldStatus = oldRecord['status']?.toString() ?? '';
      final newStatus = newRecord['status']?.toString() ?? '';
      
      // Only care about status transitions
      if (oldStatus == newStatus) return;
      
      final event = StockRequestEvent(
        cloudId: newRecord['cloud_id']?.toString() ?? '',
        franchiseeId: newRecord['franchisee_id']?.toString() ?? '',
        itemId: newRecord['item_id']?.toString() ?? '',
        quantityRequested: _parseIntSafe(newRecord['quantity_requested']),
        oldStatus: oldStatus,
        newStatus: newStatus,
        timestamp: DateTime.tryParse(newRecord['last_updated']?.toString() ?? '') ?? DateTime.now(),
        rawData: newRecord,
      );
      
      // Broadcast event
      _eventController.add(event);
      onRequestStatusChanged?.call(event);
      
      if (kDebugMode) {
        AppLogger.sync('📬 Stock request ${event.cloudId}: $oldStatus → $newStatus');
      }
      
      // Trigger debounced sync on approval/rejection/delivery
      if (event.isApproved || event.isRejected || event.isDelivered) {
        _triggerDebouncedSync();
      }
    } catch (e) {
      AppLogger.error('Error handling status update: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DEBOUNCED SYNC
  // ═══════════════════════════════════════════════════════════════════════════

  void _triggerDebouncedSync() {
    if (_isSyncing) {
      AppLogger.sync('⏳ Sync already in progress, skipping...');
      return;
    }
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () async {
      await _performSync();
    });
  }

  Future<void> _performSync() async {
    if (_isSyncing) return;
    
    _isSyncing = true;
    try {
      AppLogger.sync('🔄 Syncing stock replenishment requests...');
      
      if (syncCallback != null) {
        await syncCallback!();
      }
      
      AppLogger.sync('✅ Sync completed');
    } catch (e) {
      AppLogger.error('Sync error: $e');
      onError?.call(e.toString());
    } finally {
      _isSyncing = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILITIES
  // ═══════════════════════════════════════════════════════════════════════════

  void _updateStatus(RealtimeConnectionStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(newStatus);
      onConnectionStatusChanged?.call(newStatus);
    }
  }

  void _scheduleRealtimeRetry() {
    if (_realtimeRetryTimer != null) return;
    _realtimeRetryTimer = Timer.periodic(_realtimeRetryInterval, (_) {
      if (_isPaused || _activeScreenCount == 0) return;
      if (_status == RealtimeConnectionStatus.polling ||
          _status == RealtimeConnectionStatus.reconnecting) {
        _connectWithRetry();
      }
    });
  }

  void _cancelRealtimeRetry() {
    _realtimeRetryTimer?.cancel();
    _realtimeRetryTimer = null;
  }

  /// Calculate exponential backoff with jitter
  Duration _calculateBackoff(int attempt) {
    final baseDelay = _initialRetryDelay.inMilliseconds * pow(2, attempt - 1);
    final jitter = Random().nextInt(1000); // 0-1000ms jitter
    return Duration(milliseconds: baseDelay.toInt() + jitter);
  }

  int _parseIntSafe(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CLEANUP
  // ═══════════════════════════════════════════════════════════════════════════

  void dispose() {
    _pollingTimer?.cancel();
    _debounceTimer?.cancel();
    _realtimeRetryTimer?.cancel();
    _connectivitySubscription?.cancel();
    _stopListening();
    _statusController.close();
    _eventController.close();
    AppLogger.sync('🛑 RealtimeStockRequestService disposed');
  }
}
