import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service that monitors network connectivity changes.
/// 
/// Uses [distinct] to prevent duplicate emissions and avoid
/// unnecessary UI rebuilds when connectivity status hasn't changed.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  
  /// Tracks last emitted value to implement distinct behavior
  bool? _lastEmittedValue;
  
  /// Subscription to connectivity changes
  StreamSubscription<ConnectivityResult>? _subscription;

  /// Stream of distinct connectivity status changes.
  /// Only emits when the online/offline status actually changes.
  Stream<bool> get connectionStream => _controller.stream;
  
  /// Current connectivity status (cached)
  bool get isOnline => _lastEmittedValue ?? false;

  ConnectivityService() {
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
    _init();
  }

  Future<void> _init() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
  }

  void _updateStatus(ConnectivityResult result) {
    if (_controller.isClosed) return;
    final isOnline = result != ConnectivityResult.none;
    
    // Only emit if the value has actually changed (distinct behavior)
    if (_lastEmittedValue != isOnline) {
      _lastEmittedValue = isOnline;
      _controller.add(isOnline);
    }
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
