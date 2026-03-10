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
  Timer? _realtimeRetryTimer;
  // Cancellable timer for the post-disconnection reconnect delay.
  // Replaces an untracked Future.delayed so it can never stack with
  // the periodic realtimeRetryTimer.
  Timer? _disconnectionRetryTimer;
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

  // Polling: track last known counts to avoid spurious syncs
  int _lastKnownPendingCount = 0;
  int _lastKnownStatusChangedCount = 0;
  
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

  // Commissary mode — set via attachAsCommissary()
  bool _isCommissaryMode = false;
  String? _commissaryCloudId;

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

  /// Attach a commissary screen to this service.
  /// Filters on commissary_id and fires on INSERT (new pending requests).
  Future<void> attachAsCommissary(String commissaryCloudId) async {
    AppLogger.websocket('📎 attachAsCommissary() cloudId=$commissaryCloudId  screens=$_activeScreenCount');

    if (_activeScreenCount > 0 && _isCommissaryMode && _commissaryCloudId == commissaryCloudId) {
      _activeScreenCount++;
      AppLogger.websocket('📎 Duplicate commissary attach ignored (count: $_activeScreenCount)');
      return;
    }

    if (_activeScreenCount > 0) {
      await _stopListening();
      _activeScreenCount = 0;
    }

    _isCommissaryMode = true;
    _commissaryCloudId = commissaryCloudId;
    _franchiseeCloudId = null;
    _activeScreenCount++;

    AppLogger.websocket('📎 Commissary screen attached (count: $_activeScreenCount)');
    await _startListening();
  }

  /// Attach a screen to this service (increments reference count)
  /// Starts listening if this is first screen
  Future<void> attach(String franchiseeCloudId) async {
    AppLogger.websocket('📎 attach() called - current count: $_activeScreenCount, new cloudId: $franchiseeCloudId');
    
    // Guard against duplicate attachments with same cloudId
    if (_activeScreenCount > 0 && _franchiseeCloudId == franchiseeCloudId) {
      AppLogger.websocket('⚠️ Duplicate attach() called with same cloudId, ignoring');
      _activeScreenCount++;
      AppLogger.websocket('📎 Screen attached (count: $_activeScreenCount) - duplicate ignored');
      return;
    }
    
    // If different cloudId, we need to restart connection
    if (_activeScreenCount > 0 && _franchiseeCloudId != franchiseeCloudId) {
      AppLogger.websocket('⚠️ attach() called with different cloudId, restarting connection');
      await _stopListening();
      _activeScreenCount = 0;
    }
    
    _activeScreenCount++;
    _franchiseeCloudId = franchiseeCloudId;
    
    AppLogger.websocket('📎 Screen attached (count: $_activeScreenCount)');
    
    if (_activeScreenCount == 1) {
      AppLogger.websocket('🚀 First screen attached, starting listening...');
      await _startListening();
    } else {
      AppLogger.websocket('ℹ️ Additional screen attached, already listening');
    }
  }

  /// Detach a screen from this service (decrements reference count)
  /// Stops listening if this was the last screen
  Future<void> detach() async {
    AppLogger.websocket('📎 detach() called - current count: $_activeScreenCount');
    
    _activeScreenCount = (_activeScreenCount - 1).clamp(0, 999);
    
    AppLogger.websocket('📎 Screen detached (count: $_activeScreenCount)');
    
    if (_activeScreenCount == 0) {
      AppLogger.websocket('🛑 Last screen detached, stopping listening...');
      await _stopListening();
    } else {
      AppLogger.websocket('ℹ️ Other screens still attached, keeping connection alive');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Pause subscriptions (call when app goes to background)
  Future<void> pause() async {
    if (_isPaused) return;
    _isPaused = true;
    
    AppLogger.websocket('⏸️ PAUSE  — removing channel (if open)');
    
    // Unsubscribe but keep state
    if (_stockRequestChannel != null) {
      AppLogger.websocket('🔌 CLOSE  reason=app_paused  screens=$_activeScreenCount');
      await supabase.removeChannel(_stockRequestChannel!);
      _stockRequestChannel = null;
    }
    
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _disconnectionRetryTimer?.cancel();
    _disconnectionRetryTimer = null;
    _cancelRealtimeRetry();
    
    _updateStatus(RealtimeConnectionStatus.disconnected);
  }

  /// Resume subscriptions (call when app returns to foreground)
  Future<void> resume() async {
    if (!_isPaused) return;
    _isPaused = false;
    
    AppLogger.websocket('▶️ RESUME — restarting listener (screens: $_activeScreenCount, commissary=$_isCommissaryMode)');
    
    final hasIdentity = _isCommissaryMode
        ? _commissaryCloudId != null
        : _franchiseeCloudId != null;

    if (_activeScreenCount > 0 && hasIdentity) {
      await _startListening();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUBSCRIPTION MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _startListening() async {
    if (_isCommissaryMode) {
      if (_commissaryCloudId == null) {
        AppLogger.error('Cannot start listening: commissaryCloudId not set');
        return;
      }
    } else {
      if (_franchiseeCloudId == null) {
        AppLogger.error('Cannot start listening: franchiseeCloudId not set');
        return;
      }
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
    // ── DIAGNOSTIC: log every channel open with a traceable stamp ──
    final stamp = DateTime.now().toIso8601String();
    final cloudId = _isCommissaryMode ? _commissaryCloudId : _franchiseeCloudId;
    final mode = _isCommissaryMode ? 'commissary' : 'franchisee';
    AppLogger.websocket('🔌 OPEN   channel [$stamp] $mode=$cloudId  screens=$_activeScreenCount');

    final channelName = _isCommissaryMode
        ? 'stock-requests-commissary-$_commissaryCloudId'
        : 'stock-requests-$_franchiseeCloudId';
    if (_stockRequestChannel != null) {
      AppLogger.websocket('🔌 CLOSE  reason=replacing_before_new_open  screens=$_activeScreenCount');
      await supabase.removeChannel(_stockRequestChannel!);
      _stockRequestChannel = null;
    }
    _stockRequestChannel = supabase.channel(channelName);
    AppLogger.websocket('🔌 NAMED  channel → $channelName');

    final completer = Completer<void>();

    _stockRequestChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stock_replenishment_requests',
          // Server-side filter reduces bandwidth and avoids full-table RLS checks
          filter: _isCommissaryMode
              ? PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: 'commissary_id',
                  value: _commissaryCloudId!,
                )
              : PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: 'franchisee_id',
                  value: _franchiseeCloudId!,
                ),
          callback: (payload) {
            AppLogger.sync('🔔 POSTGRES CHANGE RECEIVED! Event type: ${payload.eventType}');
            AppLogger.sync('   Old: ${payload.oldRecord}');
            AppLogger.sync('   New: ${payload.newRecord}');

            if (_isCommissaryMode) {
              // Commissary: care about new pending requests (INSERT) and any
              // subsequent status changes on those requests (UPDATE).
              if (payload.eventType == PostgresChangeEvent.insert ||
                  payload.eventType == PostgresChangeEvent.update) {
                _handleCommissaryEvent(payload.newRecord);
              }
            } else {
              // Franchisee: only care about status changes on their requests.
              if (payload.eventType == PostgresChangeEvent.update) {
                _handleStatusUpdate(payload.oldRecord, payload.newRecord);
              }
            }
          },
        )
        .subscribe((status, error) {
          AppLogger.websocket('📡 SUBSCRIBE STATUS  [$channelName] → $status  error=$error');
          if (status == RealtimeSubscribeStatus.subscribed) {
            AppLogger.websocket('✅ SUBSCRIBED  [$channelName]  screens=$_activeScreenCount');
            _updateStatus(RealtimeConnectionStatus.connected);
            if (!completer.isCompleted) {
              completer.complete();
            }
          } else if (status == RealtimeSubscribeStatus.timedOut) {
            AppLogger.websocket('⏱️ TIMED OUT [$channelName] — will retry');
            if (!completer.isCompleted) {
              completer.completeError(TimeoutException('Supabase reported timeout'));
            }
          } else if (status == RealtimeSubscribeStatus.closed) {
            AppLogger.websocket('🔌 CLOSE  reason=server_closed  channel=$channelName  screens=$_activeScreenCount  paused=$_isPaused');
            _handleDisconnection();
          } else if (status == RealtimeSubscribeStatus.channelError) {
            AppLogger.websocket('❌ CH_ERROR  [$channelName]  error=$error');
            if (!completer.isCompleted) {
              completer.completeError(error ?? Exception('Channel error'));
            }
          }
          if (error != null) {
            AppLogger.websocket('❌ SUB_ERROR [$channelName]  $error');
            onError?.call(error.toString());
          }
        });

    // Wait for subscription to complete or timeout
    await completer.future.timeout(
      const Duration(seconds: 30), // was 10
      onTimeout: () {
        throw TimeoutException('WebSocket subscription timed out');
      },
    );
  }

  void _handleDisconnection() {
    if (_isPaused || _activeScreenCount == 0) return;
    
    AppLogger.websocket('🔁 DISCONNECTED — reconnecting in 5s');
    _updateStatus(RealtimeConnectionStatus.reconnecting);
    
    // Use a cancellable Timer instead of Future.delayed so this reconnect
    // attempt can never stack with the periodic _realtimeRetryTimer.
    _disconnectionRetryTimer?.cancel();
    _disconnectionRetryTimer = Timer(const Duration(seconds: 5), () {
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
    _disconnectionRetryTimer?.cancel();
    _disconnectionRetryTimer = null;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _isCommissaryMode = false;
    _commissaryCloudId = null;
    _lastKnownPendingCount = 0;
    _lastKnownStatusChangedCount = 0;

    if (_stockRequestChannel != null) {
      AppLogger.websocket('🔌 CLOSE  reason=all_screens_detached  screens=$_activeScreenCount');
      await supabase.removeChannel(_stockRequestChannel!);
      _stockRequestChannel = null;
    }

    _updateStatus(RealtimeConnectionStatus.disconnected);
    AppLogger.websocket('🔌 STOPPED listening — all timers/channels cleared');
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
    
    AppLogger.websocket('📊 POLLING FALLBACK started (interval: ${_currentPollingInterval.inSeconds}s) — WebSocket unavailable');
    _scheduleRealtimeRetry();
  }

  Future<void> _pollForUpdates() async {
    if (_isPaused || _isSyncing) return;

    try {
      if (_isCommissaryMode) {
        AppLogger.sync('📊 Polling for commissary_id: $_commissaryCloudId');
        final response = await supabase
            .from('stock_replenishment_requests')
            .select()
            .eq('commissary_id', _commissaryCloudId!)
            .eq('status', 'pending')
            .eq('is_deleted', false);
        final count = (response as List).length;
        AppLogger.sync('📊 Found $count pending requests (last known: $_lastKnownPendingCount)');
        if (count != _lastKnownPendingCount) {
          _lastKnownPendingCount = count;
          AppLogger.sync('📬 Pending count changed — triggering sync');
          _triggerDebouncedSync();
        }
      } else {
        AppLogger.sync('📊 Polling for franchisee_id: $_franchiseeCloudId');
        final response = await supabase
            .from('stock_replenishment_requests')
            .select()
            .eq('franchisee_id', _franchiseeCloudId!)
            .inFilter('status', ['approved', 'rejected', 'delivered'])
            .eq('is_deleted', false);
        final count = (response as List).length;
        AppLogger.sync('📊 Found $count approved/rejected/delivered requests (last known: $_lastKnownStatusChangedCount)');
        if (count != _lastKnownStatusChangedCount) {
          _lastKnownStatusChangedCount = count;
          AppLogger.sync('📬 Status-changed count changed — triggering sync');
          _triggerDebouncedSync();
        }
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

  /// Commissary mode: fires on INSERT (new pending request) or UPDATE.
  void _handleCommissaryEvent(Map<String, dynamic> newRecord) {
    try {
      final status = newRecord['status']?.toString() ?? '';

      // Synthesise a StockRequestEvent with oldStatus='' for INSERT events.
      final event = StockRequestEvent(
        cloudId: newRecord['cloud_id']?.toString() ?? '',
        franchiseeId: newRecord['franchisee_id']?.toString() ?? '',
        itemId: newRecord['item_id']?.toString() ?? '',
        quantityRequested: _parseIntSafe(newRecord['quantity_requested']),
        oldStatus: '',
        newStatus: status,
        timestamp: DateTime.tryParse(newRecord['last_updated']?.toString() ?? '') ?? DateTime.now(),
        rawData: newRecord,
      );

      _eventController.add(event);

      if (kDebugMode) {
        AppLogger.sync('📬 Commissary event: request ${event.cloudId} status=$status');
      }

      // Always sync — could be a new pending request or a change in a request
      // the commissary admin is actively reviewing.
      _triggerDebouncedSync();
    } catch (e) {
      AppLogger.error('Error handling commissary event: $e');
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
    _disconnectionRetryTimer?.cancel();
    _connectivitySubscription?.cancel();
    _stopListening();
    _statusController.close();
    _eventController.close();
    AppLogger.websocket('🛑 DISPOSE — RealtimeStockRequestService (remaining screens=$_activeScreenCount)');
  }
}
