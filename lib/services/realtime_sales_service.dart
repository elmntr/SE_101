// lib/services/realtime_sales_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/app_database.dart';
import '../utils/app_logger.dart';

/// ============================================================================
/// REALTIME SALES SERVICE
/// ============================================================================
///
/// Provides real-time sales updates for:
/// - Commissary: Live feed of sales from ALL branches
/// - Franchisee: Live feed of their own sales (for dashboard)
///
/// Uses Supabase Realtime to subscribe to stock_change_requests table
/// where change_type = 'sale' or 'sold'
/// ============================================================================
class RealtimeSalesService {
  final SupabaseClient supabase;
  final AppDatabase db;

  RealtimeChannel? _salesChannel;
  bool _isListening = false;

  // Stream controllers for broadcasting sales events
  final StreamController<SaleEvent> _salesEventController =
      StreamController<SaleEvent>.broadcast();

  // Running totals for today (in-memory cache)
  final Map<String, TodaySalesTotals> _branchTotals = {};

  // Callbacks
  Function(SaleEvent event)? onNewSale;
  Function(Map<String, TodaySalesTotals> totals)? onTotalsUpdated;
  Function(String error)? onError;

  RealtimeSalesService({
    required this.supabase,
    required this.db,
  });

  /// Stream of sale events for UI consumption
  Stream<SaleEvent> get salesStream => _salesEventController.stream;

  /// Get current cached totals
  Map<String, TodaySalesTotals> get branchTotals => Map.unmodifiable(_branchTotals);

  /// Check if currently listening
  bool get isListening => _isListening;

  // ═══════════════════════════════════════════════════════════════════════════
  // SUBSCRIPTION MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Start listening to sales events (for commissary - all branches)
  Future<void> startListeningForCommissary() async {
    if (_isListening) {
      AppLogger.sync('⚠️ Already listening to sales events');
      return;
    }

    try {
      _salesChannel = supabase.channel('commissary-sales-feed');

      _salesChannel!
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'stock_change_requests',
            callback: (payload) {
              _handleSaleEvent(payload.newRecord);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'stock_change_requests',
            callback: (payload) {
              // Handle status changes (e.g., pending → approved)
              _handleSaleStatusUpdate(payload.oldRecord, payload.newRecord);
            },
          )
          .subscribe((status, error) {
            if (status == RealtimeSubscribeStatus.subscribed) {
              _isListening = true;
              AppLogger.sync('✅ Subscribed to commissary sales feed');
            } else if (status == RealtimeSubscribeStatus.closed) {
              _isListening = false;
              AppLogger.sync('❌ Sales feed subscription closed');
            }
            if (error != null) {
              AppLogger.error('Realtime error: $error');
              onError?.call(error.toString());
            }
          });

      AppLogger.sync('📡 Starting commissary sales feed subscription...');
    } catch (e) {
      AppLogger.error('Failed to start sales feed: $e');
      onError?.call(e.toString());
    }
  }

  /// Start listening to sales events (for franchisee - own branch only)
  Future<void> startListeningForBranch(String organizationCloudId) async {
    if (_isListening) {
      AppLogger.sync('⚠️ Already listening to sales events');
      return;
    }

    try {
      _salesChannel = supabase.channel('branch-sales-feed');

      _salesChannel!
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'stock_change_requests',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'franchisee_id',
              value: organizationCloudId,
            ),
            callback: (payload) {
              _handleSaleEvent(payload.newRecord);
            },
          )
          .subscribe((status, error) {
            if (status == RealtimeSubscribeStatus.subscribed) {
              _isListening = true;
              AppLogger.sync('✅ Subscribed to branch sales feed');
            } else if (status == RealtimeSubscribeStatus.closed) {
              _isListening = false;
              AppLogger.sync('❌ Sales feed subscription closed');
            }
            if (error != null) {
              AppLogger.error('Realtime error: $error');
              onError?.call(error.toString());
            }
          });

      AppLogger.sync('📡 Starting branch sales feed subscription...');
    } catch (e) {
      AppLogger.error('Failed to start sales feed: $e');
      onError?.call(e.toString());
    }
  }

  /// Stop listening to sales events
  Future<void> stopListening() async {
    if (_salesChannel != null) {
      await supabase.removeChannel(_salesChannel!);
      _salesChannel = null;
      _isListening = false;
      AppLogger.sync('🔌 Disconnected from sales feed');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EVENT HANDLERS
  // ═══════════════════════════════════════════════════════════════════════════

  void _handleSaleEvent(Map<String, dynamic> record) {
    try {
      final changeType = record['change_type']?.toString().toLowerCase() ?? '';

      // Only process sales (not spoilage or other change types)
      if (changeType != 'sale' && changeType != 'sold') {
        return;
      }

      final event = SaleEvent(
        id: record['cloud_id']?.toString() ?? '',
        organizationId: record['franchisee_id']?.toString() ?? '',
        itemId: record['item_id']?.toString() ?? '',
        quantity: _parseIntSafe(record['quantity']),
        status: record['status']?.toString() ?? 'pending',
        timestamp: DateTime.tryParse(record['created_at']?.toString() ?? '') ??
            DateTime.now(),
        rawData: record,
      );

      // Update running totals
      _updateTotals(event);

      // Broadcast to listeners
      _salesEventController.add(event);
      onNewSale?.call(event);

      if (kDebugMode) {
        AppLogger.sync(
            '💰 Sale: ${event.quantity} items from branch ${event.organizationId}');
      }
    } catch (e) {
      AppLogger.error('Error handling sale event: $e');
    }
  }

  void _handleSaleStatusUpdate(
    Map<String, dynamic> oldRecord,
    Map<String, dynamic> newRecord,
  ) {
    try {
      final oldStatus = oldRecord['status']?.toString() ?? '';
      final newStatus = newRecord['status']?.toString() ?? '';
      final changeType = newRecord['change_type']?.toString().toLowerCase() ?? '';

      // Only care about sales becoming approved
      if (changeType != 'sale' && changeType != 'sold') {
        return;
      }

      if (oldStatus != 'approved' && newStatus == 'approved') {
        // Sale was approved - update local daily summary
        _recordApprovedSale(newRecord);
      }
    } catch (e) {
      AppLogger.error('Error handling status update: $e');
    }
  }

  void _updateTotals(SaleEvent event) {
    final branchId = event.organizationId;

    if (!_branchTotals.containsKey(branchId)) {
      _branchTotals[branchId] = TodaySalesTotals(
        organizationId: branchId,
        date: DateTime.now(),
      );
    }

    _branchTotals[branchId]!.totalQuantity += event.quantity;
    _branchTotals[branchId]!.transactionCount += 1;
    _branchTotals[branchId]!.lastSaleAt = event.timestamp;

    onTotalsUpdated?.call(_branchTotals);
  }

  Future<void> _recordApprovedSale(Map<String, dynamic> record) async {
    try {
      // Get item details for price/cost
      final itemId = record['item_id']?.toString();
      if (itemId == null) return;

      // This would update the local daily_sales_summary
      // For now, just log it - full implementation depends on your item lookup
      if (kDebugMode) {
        AppLogger.sync('✅ Sale approved: ${record['cloud_id']}');
      }
    } catch (e) {
      AppLogger.error('Error recording approved sale: $e');
    }
  }

  int _parseIntSafe(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // QUERIES - Fetch initial/historical data
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fetch today's sales from Supabase (for initial load)
  Future<List<SaleEvent>> fetchTodaysSales({String? organizationId}) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      PostgrestFilterBuilder query = supabase
          .from('stock_change_requests')
          .select()
          .gte('created_at', startOfDay.toIso8601String())
          .inFilter('change_type', ['sale', 'sold']);

      if (organizationId != null) {
        query = query.eq('franchisee_id', organizationId);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List).map((record) {
        return SaleEvent(
          id: record['cloud_id']?.toString() ?? '',
          organizationId: record['franchisee_id']?.toString() ?? '',
          itemId: record['item_id']?.toString() ?? '',
          quantity: _parseIntSafe(record['quantity']),
          status: record['status']?.toString() ?? 'pending',
          timestamp:
              DateTime.tryParse(record['created_at']?.toString() ?? '') ??
                  DateTime.now(),
          rawData: record,
        );
      }).toList();
    } catch (e) {
      AppLogger.error('Error fetching today\'s sales: $e');
      onError?.call(e.toString());
      return [];
    }
  }

  /// Fetch network totals for today (commissary view)
  Future<Map<String, dynamic>> fetchNetworkTotalsToday() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final response = await supabase
          .from('stock_change_requests')
          .select('quantity, change_type, franchisee_id')
          .gte('created_at', startOfDay.toIso8601String())
          .inFilter('change_type', ['sale', 'sold'])
          .eq('status', 'approved');

      int totalSold = 0;
      Set<String> activeBranches = {};

      for (final record in response) {
        totalSold += _parseIntSafe(record['quantity']);
        activeBranches.add(record['franchisee_id']?.toString() ?? '');
      }

      return {
        'totalSold': totalSold,
        'transactionCount': (response as List).length,
        'activeBranches': activeBranches.length,
      };
    } catch (e) {
      AppLogger.error('Error fetching network totals: $e');
      return {
        'totalSold': 0,
        'transactionCount': 0,
        'activeBranches': 0,
      };
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CLEANUP
  // ═══════════════════════════════════════════════════════════════════════════

  void dispose() {
    stopListening();
    _salesEventController.close();
    _branchTotals.clear();
  }

  /// Reset daily totals (call at midnight or on date change)
  void resetDailyTotals() {
    _branchTotals.clear();
    AppLogger.sync('🔄 Daily sales totals reset');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════════════

/// Represents a single sale event from realtime subscription
class SaleEvent {
  final String id;
  final String organizationId;
  final String itemId;
  final int quantity;
  final String status;
  final DateTime timestamp;
  final Map<String, dynamic> rawData;

  // Additional fields populated after joining with items
  String? itemName;
  double? unitPrice;
  double? revenue;

  SaleEvent({
    required this.id,
    required this.organizationId,
    required this.itemId,
    required this.quantity,
    required this.status,
    required this.timestamp,
    required this.rawData,
    this.itemName,
    this.unitPrice,
    this.revenue,
  });

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending' || status == 'draft';
}

/// Running totals for a branch for the current day
class TodaySalesTotals {
  final String organizationId;
  final DateTime date;
  int totalQuantity;
  int transactionCount;
  double totalRevenue;
  DateTime? lastSaleAt;

  // Optional: populated after joining with organization
  String? branchName;

  TodaySalesTotals({
    required this.organizationId,
    required this.date,
    this.totalQuantity = 0,
    this.transactionCount = 0,
    this.totalRevenue = 0.0,
    this.lastSaleAt,
    this.branchName,
  });
}
