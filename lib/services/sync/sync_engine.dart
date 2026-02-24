// lib/services/sync/sync_engine.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../utils/app_logger.dart';
import 'sync_conflict.dart';
import 'table_sync_descriptor.dart';

/// Result of a sync operation for a single table
class TableSyncResult {
  final String tableName;
  final int pushedCount;
  final int pulledCount;
  final int conflictCount;
  final int skippedCount;
  final List<String> errors;
  final Duration duration;
  final bool success;

  TableSyncResult({
    required this.tableName,
    this.pushedCount = 0,
    this.pulledCount = 0,
    this.conflictCount = 0,
    this.skippedCount = 0,
    this.errors = const [],
    this.duration = Duration.zero,
    this.success = true,
  });

  @override
  String toString() =>
      '$tableName: ↑$pushedCount ↓$pulledCount ⚠$conflictCount (${duration.inMilliseconds}ms)';
}

/// Result of a full sync operation
class SyncResult {
  final List<TableSyncResult> tableResults;
  final Duration totalDuration;
  final bool success;
  final int totalConflicts;

  SyncResult({
    required this.tableResults,
    required this.totalDuration,
    required this.success,
    required this.totalConflicts,
  });

  int get totalPushed => tableResults.fold(0, (sum, r) => sum + r.pushedCount);
  int get totalPulled => tableResults.fold(0, (sum, r) => sum + r.pulledCount);

  @override
  String toString() =>
      'Sync: ↑$totalPushed ↓$totalPulled ⚠$totalConflicts in ${totalDuration.inSeconds}s';
}

/// Private enum for conflict resolution actions
enum _ConflictAction { useCloud, skipCloud }

/// Generic sync engine that handles push/pull operations using table descriptors
class SyncEngine {
  final AppDatabase db;
  final SupabaseClient supabase;
  final Uuid _uuid = const Uuid();

  // UUID caches for O(1) lookups
  final Map<String, Map<int, String>> _localToCloudCache = {};
  final Map<String, Map<String, int>> _cloudToLocalCache = {};

  // Configuration
  static const int maxRetries = 2;
  static const Duration initialRetryDelay = Duration(seconds: 1);
  static const Duration requestTimeout = Duration(seconds: 30);

  // Callbacks
  void Function(String tableName, String message)? onConflictDetected;
  void Function(String tableName, String error)? onTableError;
  void Function(String tableName, int pushed, int pulled)? onTableSynced;
  void Function(SyncConflictRecord conflict)? onConflictLogged;

  // Organization context
  String? _organizationType;
  int? _organizationId;
  String? _organizationCloudId;

  // Last successful sync timestamp
  DateTime? lastSuccessfulSync;

  /// Reset lastSuccessfulSync to force a full pull
  void resetLastSuccessfulSync() {
    lastSuccessfulSync = null;
  }

  /// Set lastSuccessfulSync to a specific time
  void setLastSuccessfulSync(DateTime? time) {
    lastSuccessfulSync = time;
  }

  SyncEngine({
    required this.db,
    required this.supabase,
    this.onConflictDetected,
    this.onTableError,
    this.onTableSynced,
    this.onConflictLogged,
  });

  /// Initialize caches for all tables
  Future<void> initializeCaches(List<String> tableNames) async {
    for (final table in tableNames) {
      _localToCloudCache[table] = {};
      _cloudToLocalCache[table] = {};
    }

    // Build caches from local database
    await _buildAllCaches();
  }

  /// Set organization context for sync operations
  void setOrganizationContext({
    String? organizationType,
    int? organizationId,
    String? organizationCloudId,
  }) {
    _organizationType = organizationType;
    _organizationId = organizationId;
    _organizationCloudId = organizationCloudId;
  }

  /// Clear organization context (e.g., on logout)
  void clearOrganizationContext() {
    _organizationType = null;
    _organizationId = null;
    _organizationCloudId = null;
    AppLogger.sync('🧹 Sync engine organization context cleared');
  }

  // ============================================================================
  // CACHE MANAGEMENT
  // ============================================================================

  /// Build all caches from local database
  Future<void> _buildAllCaches() async {
    if (kDebugMode) {
      AppLogger.sync('🔧 Building UUID caches...');
    }
    final stopwatch = Stopwatch()..start();

    try {
      // Build caches in parallel for all known tables
      await Future.wait([
        _buildTableCache('organizations', () => db.organizationsDao.getAllOrganizations()),
        _buildTableCache('roles', () => db.rolesDao.getAllRoles()),
        _buildTableCache('users', () => db.usersDao.getAllUsers()),
        _buildTableCache('items', () => db.itemsDao.getAllItems()),
        _buildTableCache('ingredients', () => db.ingredientsDao.getAllIngredients()),
        _buildTableCache('recipe_ingredients', () => db.recipeIngredientsDao.getAllRecipeIngredients()),
      ]);

      stopwatch.stop();
      final totalEntries = _localToCloudCache.values.fold(0, (sum, map) => sum + map.length);
      if (kDebugMode) {
        AppLogger.sync('✅ Caches built: $totalEntries entries in ${stopwatch.elapsedMilliseconds}ms');
        // Debug: Show organizations in cache
        final orgCache = _cloudToLocalCache['organizations'] ?? {};
        AppLogger.sync('   📋 Organizations in cache: ${orgCache.length}');
        for (final entry in orgCache.entries) {
          AppLogger.sync('      - ${entry.key} → local ID ${entry.value}');
        }
      }
    } catch (e) {
      AppLogger.sync('⚠️ Error building caches: $e');
    }
  }

  /// Build cache for a specific table
  Future<void> _buildTableCache<T>(
    String tableName,
    Future<List<T>> Function() getAll,
  ) async {
    try {
      final items = await getAll();
      _localToCloudCache[tableName] ??= {};
      _cloudToLocalCache[tableName] ??= {};
      _localToCloudCache[tableName]!.clear();
      _cloudToLocalCache[tableName]!.clear();

      for (final item in items) {
        // Use reflection-like approach to get id and cloudId
        final id = _getField<int>(item, 'id');
        final cloudId = _getField<String?>(item, 'cloudId');

        if (id != null && cloudId != null) {
          _localToCloudCache[tableName]![id] = cloudId;
          _cloudToLocalCache[tableName]![cloudId] = id;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.sync('⚠️ Error building cache for $tableName: $e');
      }
    }
  }

  /// Get field value from entity using dynamic access
  R? _getField<R>(dynamic entity, String fieldName) {
    try {
      // Try common field accessors
      switch (fieldName) {
        case 'id':
          return (entity as dynamic).id as R?;
        case 'cloudId':
          return (entity as dynamic).cloudId as R?;
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }

  /// Get cloud UUID for local ID - O(1)
  String? getCloudId(String table, int? localId) {
    if (localId == null) return null;
    return _localToCloudCache[table]?[localId];
  }

  /// Get local ID for cloud UUID - O(1)
  int? getLocalId(String table, String? cloudId) {
    if (cloudId == null) return null;
    return _cloudToLocalCache[table]?[cloudId];
  }

  /// Get record by business key for conflict resolution
  Future<T?> _getByBusinessKey<T>(
    String tableName,
    Map<String, dynamic> localData,
    List<String> businessKeyFields,
  ) async {
    // This is a simplified implementation - in practice, you'd need to
    // call the appropriate DAO method based on the table name
    switch (tableName) {
      case 'daily_sales_summary':
        // For daily_sales_summary, use the DAO method we added
        final organizationId = localData['organizationId'] as int?;
        final itemId = localData['itemId'] as int?;
        final summaryDate = localData['summaryDate'] as DateTime?;
        
        if (organizationId != null && itemId != null && summaryDate != null) {
          // This would need to be injected or accessed differently
          // For now, return null to fall back to cloud_id lookup
          return null;
        }
        break;
      default:
        return null;
    }
    return null;
  }

  /// Update both caches
  void updateCache(String table, int localId, String cloudId) {
    _localToCloudCache[table] ??= {};
    _cloudToLocalCache[table] ??= {};
    _localToCloudCache[table]![localId] = cloudId;
    _cloudToLocalCache[table]![cloudId] = localId;
  }

  /// Rebuild all caches (call after sync completes)
  Future<void> rebuildAllCaches() async {
    await _buildAllCaches();
  }

  // ============================================================================
  // GENERIC PUSH OPERATION
  // ============================================================================

  /// Push local changes to cloud for a table
  Future<TableSyncResult> pushTable<T>({
    required TableSyncDescriptor<T> descriptor,
    required Future<List<T>> Function({int limit, int offset}) getUnsyncedRecords,
    required Future<void> Function(List<int> ids, {Map<int, String>? cloudIds}) markAsSynced,
    required Map<String, dynamic> Function(T record) toMap,
    required int Function(T record) getId,
    required String? Function(T record) getCloudId,
    required bool Function(T record) shouldSkip,
  }) async {
    final stopwatch = Stopwatch()..start();
    int totalPushed = 0;
    int skipped = 0;
    final errors = <String>[];

    // Check if push is allowed for this organization type
    if (!descriptor.canPushFor(_organizationType)) {
      if (kDebugMode) {
        AppLogger.sync('   ℹ️ Skipping ${descriptor.tableName} push (${_organizationType ?? 'unknown'} mode)');
      }
      return TableSyncResult(
        tableName: descriptor.tableName,
        pushedCount: 0,
        skippedCount: 0,
        duration: stopwatch.elapsed,
      );
    }

    // Retry loop for the entire push operation
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        int offset = 0;

        while (true) {
          final unsynced = await getUnsyncedRecords(
            limit: descriptor.pushBatchSize,
            offset: offset,
          );

          if (unsynced.isEmpty) break;

          final batchData = <Map<String, dynamic>>[];
          final syncedIds = <int>[];
          final cloudIdMap = <int, String>{};

          for (final record in unsynced) {
            // Skip deleted/inactive records
            if (shouldSkip(record)) continue;

            final localId = getId(record);
            final existingCloudId = getCloudId(record);
            final cloudId = existingCloudId ?? _uuid.v4();
            final localData = toMap(record);

            // Convert to cloud format using descriptor
            final cloudData = descriptor.toCloudFormat(
              localData,
              getCloudId: this.getCloudId, // Use the cache lookup method
              cloudIdValue: cloudId,
            );

            // Skip if FK resolution failed (empty map returned)
            if (cloudData.isEmpty) {
              skipped++;
              continue;
            }

            cloudIdMap[localId] = cloudId;
            updateCache(descriptor.tableName, localId, cloudId);
            batchData.add(cloudData);
            syncedIds.add(localId);
          }

          if (batchData.isNotEmpty) {
            await supabase
                .from(descriptor.cloudTableName)
                .upsert(batchData, onConflict: 'cloud_id')
                .timeout(requestTimeout);
            totalPushed += batchData.length;
          }

          if (syncedIds.isNotEmpty) {
            await markAsSynced(syncedIds, cloudIds: cloudIdMap);
          }

          offset += descriptor.pushBatchSize;
        }

        // Success - break retry loop
        break;
      } catch (e) {
        final errorMsg = 'Push attempt $attempt failed: $e';
        if (kDebugMode) {
          AppLogger.sync('   ⚠️ ${descriptor.tableName}: $errorMsg');
        }

        if (attempt == maxRetries) {
          errors.add(errorMsg);
          onTableError?.call(descriptor.tableName, errorMsg);
        } else {
          // Exponential backoff with jitter
          final delay = _calculateBackoff(attempt);
          await Future.delayed(delay);
        }
      }
    }

    stopwatch.stop();

    if (totalPushed > 0 && kDebugMode) {
      AppLogger.sync('   ↑ Pushed $totalPushed ${descriptor.tableName}');
    }
    if (skipped > 0 && kDebugMode) {
      AppLogger.sync('   ⚠️ Skipped $skipped ${descriptor.tableName} (missing FKs)');
    }

    return TableSyncResult(
      tableName: descriptor.tableName,
      pushedCount: totalPushed,
      skippedCount: skipped,
      errors: errors,
      duration: stopwatch.elapsed,
      success: errors.isEmpty,
    );
  }

  // ============================================================================
  // GENERIC PULL OPERATION
  // ============================================================================

  /// Pull cloud changes to local for a table
  Future<TableSyncResult> pullTable<T>({
    required TableSyncDescriptor<T> descriptor,
    required Future<void> Function(List<Map<String, dynamic>> records) upsertBatchFromCloud,
    required Future<T?> Function(String cloudId) getByCloudId,
    required DateTime? Function(T record) getLastUpdated,
    required int? Function(T record) getOrganizationId,
    Future<T?> Function(Map<String, dynamic> localData)? getByBusinessKey,
    String? additionalFilter,
  }) async {
    final stopwatch = Stopwatch()..start();
    int totalPulled = 0;
    int conflictCount = 0;
    final errors = <String>[];

    // Retry loop
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // Determine sync start time (ensure UTC format for Supabase)
        final lastSync = descriptor.incrementalSync && lastSuccessfulSync != null
            ? lastSuccessfulSync!.toUtc().toIso8601String()
            : '1970-01-01T00:00:00.000Z';

        if (kDebugMode) {
          AppLogger.sync('   🔍 Pulling ${descriptor.tableName} since: $lastSync');
        }

        // Build query
        var query = supabase
            .from(descriptor.cloudTableName)
            .select()
            .gte('last_updated', lastSync);

        // Add organization filter if specified
        if (descriptor.organizationField != null && _organizationCloudId != null) {
          // RLS should handle this, but we can be explicit
        }

        final cloudRecords = await query
            .order('last_updated', ascending: false)
            .limit(descriptor.pullLimit)
            .timeout(requestTimeout);

        if (kDebugMode) {
          AppLogger.sync('   📥 Received ${cloudRecords.length} ${descriptor.tableName} from cloud');
          if (cloudRecords.isNotEmpty && descriptor.tableName == 'users') {
            // Debug: show first user record to help diagnose FK issues
            final firstRecord = cloudRecords.first;
            AppLogger.sync('   🔎 First user record: cloud_id=${firstRecord['cloud_id']}, org_id=${firstRecord['organization_id']}, role_id=${firstRecord['role_id']}');
          }
        }

        if (cloudRecords.isNotEmpty) {
          final resolvedRecords = <Map<String, dynamic>>[];

          for (final cloudRecord in cloudRecords) {
            // Convert to local format using descriptor
            final localData = descriptor.toLocalFormat(
              cloudRecord,
              getLocalId: getLocalId,
            );

            // Skip if FK resolution failed
            if (localData.isEmpty) {
              if (kDebugMode) {
                AppLogger.sync('   ⚠️ Skipping ${descriptor.tableName} record: FK resolution failed');
              }
              continue;
            }

            // Check for conflicts using business key if available, otherwise cloud_id
            T? existingRecord;
            if (descriptor.businessKeyFields.isNotEmpty && getByBusinessKey != null) {
              // Use business key for conflict detection
              existingRecord = await getByBusinessKey(localData);
            } else {
              // Use cloud_id for conflict detection (original behavior)
              final cloudId = cloudRecord['cloud_id'] as String?;
              if (cloudId != null) {
                existingRecord = await getByCloudId(cloudId);
              }
            }

            if (existingRecord != null) {
              final localUpdated = getLastUpdated(existingRecord);
              final cloudUpdatedStr = cloudRecord['last_updated'] as String?;
              final cloudUpdated = cloudUpdatedStr != null
                  ? DateTime.tryParse(cloudUpdatedStr)
                  : null;

              // Check if local is newer than cloud
              if (localUpdated != null &&
                  cloudUpdated != null &&
                  localUpdated.isAfter(cloudUpdated)) {
                // Conflict detected!
                final resolution = await _handleConflict(
                  descriptor: descriptor,
                  localRecord: existingRecord,
                  cloudRecord: cloudRecord,
                  localUpdated: localUpdated,
                  cloudUpdated: cloudUpdated,
                  getOrganizationId: getOrganizationId,
                );

                if (resolution == _ConflictAction.skipCloud) {
                  conflictCount++;
                  continue; // Don't upsert - keep local
                }
                // resolution == useCloud - continue to upsert
              }
            }

            resolvedRecords.add(localData);
          }

          if (resolvedRecords.isNotEmpty) {
            // Process in batches
            for (int i = 0; i < resolvedRecords.length; i += descriptor.pushBatchSize) {
              final batch = resolvedRecords.skip(i).take(descriptor.pushBatchSize).toList();
              await upsertBatchFromCloud(batch);
            }
            totalPulled = resolvedRecords.length;
          }
        }

        // Success - break retry loop
        break;
      } catch (e) {
        final errorMsg = 'Pull attempt $attempt failed: $e';
        if (kDebugMode) {
          AppLogger.sync('   ⚠️ ${descriptor.tableName}: $errorMsg');
        }

        if (attempt == maxRetries) {
          errors.add(errorMsg);
          onTableError?.call(descriptor.tableName, errorMsg);
        } else {
          final delay = _calculateBackoff(attempt);
          await Future.delayed(delay);
        }
      }
    }

    stopwatch.stop();

    if (totalPulled > 0 && kDebugMode) {
      AppLogger.sync('   ↓ Pulled $totalPulled ${descriptor.tableName}');
    }

    onTableSynced?.call(descriptor.tableName, 0, totalPulled);

    return TableSyncResult(
      tableName: descriptor.tableName,
      pulledCount: totalPulled,
      conflictCount: conflictCount,
      errors: errors,
      duration: stopwatch.elapsed,
      success: errors.isEmpty,
    );
  }

  // ============================================================================
  // CONFLICT HANDLING
  // ============================================================================

  Future<_ConflictAction> _handleConflict<T>({
    required TableSyncDescriptor<T> descriptor,
    required T localRecord,
    required Map<String, dynamic> cloudRecord,
    required DateTime localUpdated,
    required DateTime cloudUpdated,
    required int? Function(T record) getOrganizationId,
  }) async {
    switch (descriptor.conflictResolution) {
      case ConflictResolution.cloudWins:
        return _ConflictAction.useCloud;

      case ConflictResolution.localWins:
        return _ConflictAction.skipCloud;

      case ConflictResolution.lastWriteWins:
        // Local is newer, so skip cloud
        return _ConflictAction.skipCloud;

      case ConflictResolution.statusAware:
        // Compare status fields
        if (descriptor.statusField != null) {
          final localStatus = _getField<String>(localRecord, descriptor.statusField!);
          final cloudStatus = cloudRecord[descriptor.statusField];

          if (StatusHierarchy.isMoreAdvanced(cloudStatus?.toString(), localStatus)) {
            return _ConflictAction.useCloud;
          }
        }
        // Fallback to local wins (since local is newer)
        return _ConflictAction.skipCloud;

      case ConflictResolution.manual:
        // Log conflict for manual review
        await _logConflict(
          tableName: descriptor.tableName,
          cloudId: cloudRecord['cloud_id'] as String? ?? '',
          localRecord: localRecord,
          cloudRecord: cloudRecord,
          organizationId: getOrganizationId(localRecord),
        );
        // Show notification
        onConflictDetected?.call(
          descriptor.tableName,
          'Sync conflict detected in ${descriptor.tableName}. Manual review required.',
        );
        // Skip cloud update - local takes precedence until manually resolved
        return _ConflictAction.skipCloud;
    }
  }

  /// Log a conflict to the sync_conflicts table
  Future<void> _logConflict<T>({
    required String tableName,
    required String cloudId,
    required T localRecord,
    required Map<String, dynamic> cloudRecord,
    int? organizationId,
  }) async {
    try {
      final conflict = SyncConflictRecord(
        tableName: tableName,
        cloudId: cloudId,
        localData: _recordToMap(localRecord),
        cloudData: cloudRecord,
        conflictType: ConflictType.bothModified,
        organizationId: organizationId,
      );

      // Notify callback
      onConflictLogged?.call(conflict);

      // The actual DB insertion should be handled by the sync service
      // which has access to the sync_conflicts DAO
    } catch (e) {
      if (kDebugMode) {
        AppLogger.sync('   ⚠️ Failed to log conflict: $e');
      }
    }
  }

  Map<String, dynamic> _recordToMap(dynamic record) {
    // Try to convert record to map
    try {
      if (record is Map<String, dynamic>) return record;

      // For Drift entities, we need to manually extract fields
      // This is a simplified version - actual implementation would need
      // to handle each entity type
      return {
        'id': _getField<int>(record, 'id'),
        'cloudId': _getField<String>(record, 'cloudId'),
        'lastUpdated': _getField<DateTime>(record, 'lastUpdated')?.toIso8601String(),
      };
    } catch (_) {
      return {};
    }
  }

  // ============================================================================
  // TIER-BASED PARALLEL SYNC
  // ============================================================================

  /// Sync multiple tables in parallel within the same dependency tier
  Future<List<TableSyncResult>> syncTier(
    List<Future<TableSyncResult> Function()> tableSyncFunctions,
  ) async {
    return await Future.wait(tableSyncFunctions.map((fn) => fn()));
  }

  /// Sync all tiers sequentially, with parallel sync within each tier
  Future<SyncResult> syncAllTiers(
    Map<int, List<Future<TableSyncResult> Function()>> tierMap,
  ) async {
    final stopwatch = Stopwatch()..start();
    final allResults = <TableSyncResult>[];
    var success = true;
    var totalConflicts = 0;

    // Get sorted tier numbers
    final sortedTiers = tierMap.keys.toList()..sort();

    for (final tier in sortedTiers) {
      final tierFunctions = tierMap[tier] ?? [];
      if (tierFunctions.isEmpty) continue;

      if (kDebugMode) {
        AppLogger.sync('📊 Syncing Tier $tier (${tierFunctions.length} tables)...');
      }

      final tierResults = await syncTier(tierFunctions);
      allResults.addAll(tierResults);

      // Check for failures
      for (final result in tierResults) {
        if (!result.success) success = false;
        totalConflicts += result.conflictCount;
      }
    }

    stopwatch.stop();

    // Update last successful sync if all succeeded (use UTC for Supabase compatibility)
    if (success) {
      lastSuccessfulSync = DateTime.now().toUtc();
    }

    return SyncResult(
      tableResults: allResults,
      totalDuration: stopwatch.elapsed,
      success: success,
      totalConflicts: totalConflicts,
    );
  }

  // ============================================================================
  // UTILITIES
  // ============================================================================

  /// Calculate exponential backoff with jitter
  Duration _calculateBackoff(int attempt) {
    final baseDelay = initialRetryDelay.inMilliseconds * pow(2, attempt - 1);
    final jitter = Random().nextInt(1000); // 0-1000ms jitter
    return Duration(milliseconds: baseDelay.toInt() + jitter);
  }

  /// Clear all caches
  void clearCaches() {
    for (final cache in _localToCloudCache.values) {
      cache.clear();
    }
    for (final cache in _cloudToLocalCache.values) {
      cache.clear();
    }
  }

  /// Get cache statistics
  Map<String, int> getCacheStats() {
    return _localToCloudCache.map((table, cache) => MapEntry(table, cache.length));
  }
}
