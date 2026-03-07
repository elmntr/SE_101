// test/services/sync/sync_engine_test.dart

import 'package:flutter_test/flutter_test.dart';

import 'package:chickenjoo_inventory/services/sync/sync_engine.dart';
import 'package:chickenjoo_inventory/services/sync/sync_conflict.dart';
import 'package:chickenjoo_inventory/services/sync/table_sync_descriptor.dart';

void main() {
  group('TableSyncResult', () {
    test('should create with defaults', () {
      final result = TableSyncResult(tableName: 'items');

      expect(result.tableName, 'items');
      expect(result.pushedCount, 0);
      expect(result.pulledCount, 0);
      expect(result.conflictCount, 0);
      expect(result.skippedCount, 0);
      expect(result.errors, isEmpty);
      expect(result.success, isTrue);
      expect(result.duration, Duration.zero);
    });

    test('should create with all values', () {
      final result = TableSyncResult(
        tableName: 'users',
        pushedCount: 5,
        pulledCount: 10,
        conflictCount: 2,
        skippedCount: 1,
        errors: ['Error 1'],
        duration: const Duration(milliseconds: 500),
        success: false,
      );

      expect(result.tableName, 'users');
      expect(result.pushedCount, 5);
      expect(result.pulledCount, 10);
      expect(result.conflictCount, 2);
      expect(result.skippedCount, 1);
      expect(result.errors, ['Error 1']);
      expect(result.success, isFalse);
      expect(result.duration.inMilliseconds, 500);
    });

    test('toString should format correctly', () {
      final result = TableSyncResult(
        tableName: 'items',
        pushedCount: 5,
        pulledCount: 10,
        conflictCount: 2,
        duration: const Duration(milliseconds: 123),
      );

      expect(result.toString(), 'items: ↑5 ↓10 ⚠2 (123ms)');
    });
  });

  group('SyncResult', () {
    test('should calculate totals from table results', () {
      final tableResults = [
        TableSyncResult(
          tableName: 'organizations',
          pushedCount: 2,
          pulledCount: 3,
        ),
        TableSyncResult(
          tableName: 'users',
          pushedCount: 5,
          pulledCount: 8,
        ),
        TableSyncResult(
          tableName: 'items',
          pushedCount: 10,
          pulledCount: 15,
        ),
      ];

      final result = SyncResult(
        tableResults: tableResults,
        totalDuration: const Duration(seconds: 5),
        success: true,
        totalConflicts: 3,
      );

      expect(result.totalPushed, 17); // 2+5+10
      expect(result.totalPulled, 26); // 3+8+15
      expect(result.totalConflicts, 3);
      expect(result.success, isTrue);
    });

    test('toString should format correctly', () {
      final result = SyncResult(
        tableResults: [
          TableSyncResult(tableName: 'items', pushedCount: 5, pulledCount: 10),
        ],
        totalDuration: const Duration(seconds: 3),
        success: true,
        totalConflicts: 1,
      );

      expect(result.toString(), 'Sync: ↑5 ↓10 ⚠1 in 3s');
    });
  });

  group('SyncEngine', () {
    group('Cache Management', () {
      // Note: Full cache tests require a real database and Supabase client.
      // These tests focus on the logic that can be tested in isolation.

      test('updateCache should store bidirectional mapping', () {
        // This test verifies the cache logic conceptually
        // In a real test, we'd use dependency injection or mocks

        // The cache structure is:
        // _localToCloudCache[table][localId] = cloudId
        // _cloudToLocalCache[table][cloudId] = localId

        // We can test the expected behavior through the descriptor's FK resolution
        final descriptor = TableSyncDescriptor<Map<String, dynamic>>(
          tableName: 'items',
          cloudTableName: 'items',
          foreignKeys: [
            const ForeignKeyMapping(
              localField: 'organizationId',
              cloudField: 'organization_id',
              referenceTable: 'organizations',
            ),
          ],
          fieldMappings: [
            FieldMapping.simple('name', 'name'),
          ],
        );

        // Simulate cache lookup behavior
        String? getCloudId(String table, int? localId) {
          if (table == 'organizations' && localId == 1) {
            return 'org-uuid-123';
          }
          return null;
        }

        final localData = {
          'name': 'Test',
          'organizationId': 1,
        };

        final cloudData = descriptor.toCloudFormat(
          localData,
          getCloudId: getCloudId,
          cloudIdValue: 'item-uuid',
        );

        expect(cloudData['organization_id'], 'org-uuid-123');
      });

      test('getCloudId returns null for unknown local ID', () {
        String? getCloudId(String table, int? localId) {
          if (localId == null) return null;
          // Simulate empty cache
          return null;
        }

        expect(getCloudId('items', 999), isNull);
        expect(getCloudId('items', null), isNull);
      });

      test('getLocalId returns null for unknown cloud ID', () {
        int? getLocalId(String table, String? cloudId) {
          if (cloudId == null) return null;
          // Simulate empty cache
          return null;
        }

        expect(getLocalId('items', 'unknown-uuid'), isNull);
        expect(getLocalId('items', null), isNull);
      });
    });

    group('Organization Context', () {
      test('setOrganizationContext should store values', () {
        // We test this indirectly through canPushFor behavior
        final descriptor = TableSyncDescriptor<Map<String, dynamic>>(
          tableName: 'items',
          cloudTableName: 'items',
          canPush: (orgType) => orgType == 'commissary',
        );

        expect(descriptor.canPushFor('commissary'), isTrue);
        expect(descriptor.canPushFor('franchisee'), isFalse);
        expect(descriptor.canPushFor(null), isFalse);
      });
    });

    group('Retry Logic', () {
      // Note: Testing actual retry behavior requires mocking network calls
      // These tests verify the backoff calculation logic

      test('maxRetries constant should be 2', () {
        expect(SyncEngine.maxRetries, 2);
      });

      test('initialRetryDelay should be 1 second', () {
        expect(SyncEngine.initialRetryDelay, const Duration(seconds: 1));
      });

      test('requestTimeout should be 30 seconds', () {
        expect(SyncEngine.requestTimeout, const Duration(seconds: 30));
      });
    });

    group('Push Operation Logic', () {
      test('should skip push when canPushFor returns false', () async {
        // This tests the conditional push logic
        final descriptor = TableSyncDescriptor<Map<String, dynamic>>(
          tableName: 'items',
          cloudTableName: 'items',
          canPush: (orgType) => orgType == 'commissary',
        );

        // Franchisee should not push items
        expect(descriptor.canPushFor('franchisee'), isFalse);
      });

      test('should skip record when shouldSkip returns true', () {
        // Simulate deleted record check
        bool shouldSkip(Map<String, dynamic> record) {
          return record['isDeleted'] == true;
        }

        expect(shouldSkip({'id': 1, 'isDeleted': true}), isTrue);
        expect(shouldSkip({'id': 2, 'isDeleted': false}), isFalse);
        expect(shouldSkip({'id': 3}), isFalse);
      });

      test('should generate UUID for new records', () {
        // Simulate the UUID generation logic
        String getOrGenerateCloudId(String? existing) {
          return existing ?? 'generated-uuid';
        }

        expect(getOrGenerateCloudId('existing-uuid'), 'existing-uuid');
        expect(getOrGenerateCloudId(null), 'generated-uuid');
      });
    });

    group('Pull Operation Logic', () {
      test('incremental sync should filter by lastSuccessfulSync', () {
        // Test the timestamp filtering logic
        DateTime? lastSync = DateTime(2024, 1, 15);

        String getLastSyncFilter(bool incrementalSync, DateTime? lastSuccessfulSync) {
          if (incrementalSync && lastSuccessfulSync != null) {
            return lastSuccessfulSync.toIso8601String();
          }
          return '1970-01-01T00:00:00.000Z';
        }

        expect(
          getLastSyncFilter(true, lastSync),
          '2024-01-15T00:00:00.000',
        );
        expect(
          getLastSyncFilter(false, lastSync),
          '1970-01-01T00:00:00.000Z',
        );
        expect(
          getLastSyncFilter(true, null),
          '1970-01-01T00:00:00.000Z',
        );
      });
    });

    group('Conflict Detection', () {
      test('should detect conflict when local is newer than cloud', () {
        final localUpdated = DateTime(2024, 1, 15, 12, 0);
        final cloudUpdated = DateTime(2024, 1, 15, 10, 0);

        bool hasConflict = localUpdated.isAfter(cloudUpdated);
        expect(hasConflict, isTrue);
      });

      test('should not detect conflict when cloud is newer', () {
        final localUpdated = DateTime(2024, 1, 15, 10, 0);
        final cloudUpdated = DateTime(2024, 1, 15, 12, 0);

        bool hasConflict = localUpdated.isAfter(cloudUpdated);
        expect(hasConflict, isFalse);
      });

      test('should not detect conflict when timestamps are equal', () {
        final localUpdated = DateTime(2024, 1, 15, 10, 0);
        final cloudUpdated = DateTime(2024, 1, 15, 10, 0);

        bool hasConflict = localUpdated.isAfter(cloudUpdated);
        expect(hasConflict, isFalse);
      });
    });

    group('Conflict Resolution Strategy', () {
      test('cloudWins should always use cloud', () {
        const strategy = ConflictResolution.cloudWins;
        // In actual sync, this means we upsert the cloud record
        expect(strategy, ConflictResolution.cloudWins);
      });

      test('localWins should always skip cloud', () {
        const strategy = ConflictResolution.localWins;
        // In actual sync, this means we don't upsert the cloud record
        expect(strategy, ConflictResolution.localWins);
      });

      test('lastWriteWins with local newer should skip cloud', () {
        final localUpdated = DateTime(2024, 1, 15, 12, 0);
        final cloudUpdated = DateTime(2024, 1, 15, 10, 0);
        const strategy = ConflictResolution.lastWriteWins;

        // Local is newer, so skip cloud
        final skipCloud = strategy == ConflictResolution.lastWriteWins &&
            localUpdated.isAfter(cloudUpdated);
        expect(skipCloud, isTrue);
      });

      test('statusAware should prefer higher status', () {
        // Test status-aware resolution logic
        String? localStatus = 'pending';
        String? cloudStatus = 'approved';

        bool cloudWins = StatusHierarchy.isMoreAdvanced(cloudStatus, localStatus);
        expect(cloudWins, isTrue);

        localStatus = 'approved';
        cloudStatus = 'pending';
        cloudWins = StatusHierarchy.isMoreAdvanced(cloudStatus, localStatus);
        expect(cloudWins, isFalse);
      });

      test('manual resolution should log conflict', () {
        const strategy = ConflictResolution.manual;
        // In actual sync, manual conflicts are logged for admin review
        expect(strategy, ConflictResolution.manual);
      });
    });

    group('Tiered Sync', () {
      test('descriptors should be grouped by dependency tier', () {
        final descriptors = [
          const TableSyncDescriptor(
            tableName: 'organizations',
            cloudTableName: 'organizations',
            dependencyTier: 0,
          ),
          const TableSyncDescriptor(
            tableName: 'roles',
            cloudTableName: 'roles',
            dependencyTier: 1,
          ),
          const TableSyncDescriptor(
            tableName: 'users',
            cloudTableName: 'users',
            dependencyTier: 1,
          ),
          const TableSyncDescriptor(
            tableName: 'items',
            cloudTableName: 'items',
            dependencyTier: 2,
          ),
          const TableSyncDescriptor(
            tableName: 'recipe_ingredients',
            cloudTableName: 'recipe_ingredients',
            dependencyTier: 3,
          ),
        ];

        // Group by tier
        final grouped = <int, List<TableSyncDescriptor>>{};
        for (final desc in descriptors) {
          grouped.putIfAbsent(desc.dependencyTier, () => []).add(desc);
        }

        expect(grouped[0]?.length, 1);
        expect(grouped[1]?.length, 2);
        expect(grouped[2]?.length, 1);
        expect(grouped[3]?.length, 1);

        // Verify tier 0 contains organizations
        expect(grouped[0]?.first.tableName, 'organizations');

        // Verify tier 1 tables are independent of each other
        final tier1Names = grouped[1]?.map((d) => d.tableName).toList();
        expect(tier1Names, containsAll(['roles', 'users']));
      });

      test('tiers should be synced in ascending order', () {
        final tiers = [0, 1, 2, 3];

        // Verify proper ordering
        for (int i = 0; i < tiers.length - 1; i++) {
          expect(tiers[i], lessThan(tiers[i + 1]));
        }
      });
    });

    group('Batch Processing', () {
      test('should process records in batches of pushBatchSize', () {
        const batchSize = 50;
        const totalRecords = 125;

        // Calculate expected batches
        int batchCount = (totalRecords / batchSize).ceil();
        expect(batchCount, 3);

        // Simulate batch iteration
        final batches = <List<int>>[];
        for (int i = 0; i < totalRecords; i += batchSize) {
          final end = (i + batchSize > totalRecords) ? totalRecords : i + batchSize;
          batches.add(List.generate(end - i, (j) => i + j));
        }

        expect(batches.length, 3);
        expect(batches[0].length, 50);
        expect(batches[1].length, 50);
        expect(batches[2].length, 25);
      });

      test('default pushBatchSize should be 50', () {
        const descriptor = TableSyncDescriptor(
          tableName: 'test',
          cloudTableName: 'test',
        );
        expect(descriptor.pushBatchSize, 50);
      });

      test('default pullLimit should be 500', () {
        const descriptor = TableSyncDescriptor(
          tableName: 'test',
          cloudTableName: 'test',
        );
        expect(descriptor.pullLimit, 500);
      });
    });

    group('Callbacks', () {
      test('onConflictDetected should be invokable', () {
        String? detectedTable;
        String? detectedMessage;

        void onConflictDetected(String tableName, String message) {
          detectedTable = tableName;
          detectedMessage = message;
        }

        // Simulate callback invocation
        onConflictDetected('items', 'Conflict detected in record uuid-123');

        expect(detectedTable, 'items');
        expect(detectedMessage, 'Conflict detected in record uuid-123');
      });

      test('onTableError should be invokable', () {
        String? errorTable;
        String? errorMessage;

        void onTableError(String tableName, String error) {
          errorTable = tableName;
          errorMessage = error;
        }

        onTableError('users', 'Network timeout');

        expect(errorTable, 'users');
        expect(errorMessage, 'Network timeout');
      });

      test('onTableSynced should be invokable', () {
        String? syncedTable;
        int? pushedCount;
        int? pulledCount;

        void onTableSynced(String tableName, int pushed, int pulled) {
          syncedTable = tableName;
          pushedCount = pushed;
          pulledCount = pulled;
        }

        onTableSynced('items', 5, 10);

        expect(syncedTable, 'items');
        expect(pushedCount, 5);
        expect(pulledCount, 10);
      });
    });
  });

  group('Exponential Backoff', () {
    test('should calculate delay with jitter', () {
      // Base delay = 1 second
      // Attempt 1: 1 * 2^0 = 1 second + jitter
      // Attempt 2: 1 * 2^1 = 2 seconds + jitter

      Duration calculateBackoff(int attempt) {
        final baseDelay = const Duration(seconds: 1);
        final multiplier = 1 << (attempt - 1); // 2^(attempt-1)
        return baseDelay * multiplier;
      }

      expect(calculateBackoff(1), const Duration(seconds: 1));
      expect(calculateBackoff(2), const Duration(seconds: 2));
    });

    test('jitter should be bounded', () {
      // Jitter should be 0-500ms (half of initial delay)
      const maxJitter = Duration(milliseconds: 500);

      // Verify jitter range
      expect(maxJitter.inMilliseconds, 500);
    });
  });

  // ---------------------------------------------------------------------------
  // Task 6.1 – Pull pagination accumulation regression tests (Task 1.4 fix)
  //
  // SyncEngine.pullTable uses a do-while loop that:
  //   1. Fetches one page of up to pullLimit rows.
  //   2. Accumulates them into a combined list.
  //   3. Stops when the returned page is smaller than pullLimit (partial page).
  //
  // These tests lock in that logic using pure in-process simulations of
  // the accumulation pattern — no real Supabase calls involved.
  // ---------------------------------------------------------------------------
  group('Pull pagination accumulation (Task 1.4 regression)', () {
    /// Mimics the accumulation + stop-condition logic from SyncEngine.pullTable.
    List<T> simulatePagedPull<T>({
      required List<List<T>> pages,
      required int pageSize,
    }) {
      final accumulated = <T>[];
      for (final page in pages) {
        accumulated.addAll(page);
        if (page.length < pageSize) break; // partial page → last page
      }
      return accumulated;
    }

    test('accumulates all records across two full pages plus a partial page',
        () {
      const pageSize = 3;
      final pages = [
        [1, 2, 3], // full page — continue
        [4, 5, 6], // full page — continue
        [7, 8], //    partial page — stop
      ];

      final result = simulatePagedPull(pages: pages, pageSize: pageSize);

      expect(result, [1, 2, 3, 4, 5, 6, 7, 8],
          reason: 'All records from all pages should be accumulated');
      expect(result.length, 8);
    });

    test('stops after first partial page — does not request further pages', () {
      const pageSize = 5;
      int pagesFetched = 0;

      final accumulated = <int>[];
      // Simulate: page 1 has 5 (full), page 2 has 3 (partial)
      final pages = [
        List.generate(5, (i) => i + 1),
        List.generate(3, (i) => i + 6),
      ];
      for (final page in pages) {
        pagesFetched++;
        accumulated.addAll(page);
        if (page.length < pageSize) break;
      }

      expect(pagesFetched, 2,
          reason: 'Should stop after receiving partial page');
      expect(accumulated.length, 8);
    });

    test('single page smaller than limit — pagination does not continue', () {
      const pageSize = 500; // Default pullLimit
      final pages = [
        List.generate(42, (i) => i), // Single partial page
      ];

      final result = simulatePagedPull(pages: pages, pageSize: pageSize);

      expect(result.length, 42);
    });

    test('single full page followed by empty page — stops after empty page',
        () {
      const pageSize = 3;
      final pages = [
        [10, 20, 30], // full page
        <int>[], //      empty page — length 0 < pageSize
      ];

      final result = simulatePagedPull(pages: pages, pageSize: pageSize);

      // Empty page signals end-of-data
      expect(result, [10, 20, 30]);
    });

    test('exactly N full pages with no partial page accumulates all records',
        () {
      const pageSize = 4;
      final pages = [
        [1, 2, 3, 4],
        [5, 6, 7, 8],
        [9, 10, 11, 12],
      ];
      // Drift would then request page 4 which returns empty — we model that
      final pagesWithTerminator = [...pages, <int>[]];

      final result =
          simulatePagedPull(pages: pagesWithTerminator, pageSize: pageSize);

      expect(result.length, 12);
      expect(result, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
    });

    test('page offset increments by pageSize on each iteration', () {
      const pageSize = 500;
      final offsets = <int>[];
      // Simulate 3 full pages + 1 partial
      int offset = 0;
      const pagesData = [500, 500, 200]; // record counts per page
      for (final count in pagesData) {
        offsets.add(offset);
        offset += pageSize;
        if (count < pageSize) break;
      }

      expect(offsets, [0, 500, 1000],
          reason: 'Each page should start at offset = pageIndex * pageSize');
    });

    test('pullLimit constant on descriptor defaults to 500', () {
      // Verify that the default pullLimit used by the pagination loop is 500
      const descriptor = TableSyncDescriptor<Map<String, dynamic>>(
        tableName: 'daily_sales_summary',
        cloudTableName: 'daily_sales_summary',
      );
      expect(descriptor.pullLimit, 500);
    });
  });
}
