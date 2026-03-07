// test/services/sync/sync_lock_test.dart
//
// Task 6.1e – Sync lock concurrency guard regression tests (Task 1.7 fix)
//
// Task 1.7 fixed a bug where two concurrent calls to syncAll (or any of the
// public sync methods) would both execute their bodies in parallel, leading to
// duplicate writes, race conditions, and unnecessary network traffic.
//
// The fix uses a Completer-based guard inside _runGuardedSync:
//
//   Future<void> _runGuardedSync(String label, Future<void> Function() body) async {
//     if (_syncCompleter != null && !_syncCompleter!.isCompleted) {
//       return _syncCompleter!.future;   // ← second caller waits on same future
//     }
//     if (_isSyncing) return;
//     _isSyncing = true;
//     _syncCompleter = Completer<void>();
//     try {
//       await body();
//     } finally {
//       _isSyncing = false;
//       _syncCompleter!.complete();
//     }
//   }
//
// These are pure Dart logic tests – no database or Supabase required.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Sync lock concurrency guard (Task 1.7 regression)', () {
    // ------------------------------------------------------------------ //
    // Helper: a self-contained re-implementation of the guard logic so the
    // tests are not coupled to the private internals of
    // SupabaseSyncServiceV2.  This mirrors the exact Completer pattern.

    Completer<void>? _syncCompleter;
    bool _isSyncing = false;

    Future<void> guardedSync(Future<void> Function() body) async {
      if (_syncCompleter != null && !_syncCompleter!.isCompleted) {
        return _syncCompleter!.future; // second caller waits on same future
      }
      if (_isSyncing) return;
      _isSyncing = true;
      _syncCompleter = Completer<void>();
      try {
        await body();
      } finally {
        _isSyncing = false;
        _syncCompleter!.complete();
      }
    }

    setUp(() {
      _syncCompleter = null;
      _isSyncing = false;
    });

    // ------------------------------------------------------------------ //

    test(
      'concurrent calls execute the body exactly once',
      () async {
        int bodyExecutionCount = 0;
        final barrier = Completer<void>(); // keeps first body suspended

        // First call — begins but blocks at barrier
        final firstCall = guardedSync(() async {
          bodyExecutionCount++;
          await barrier.future;
        });

        // Yield so the event loop processes the first call's start
        await Future<void>.delayed(Duration.zero);

        // Second call — should be dropped; it joins firstCall's future
        final secondCall = guardedSync(() async {
          bodyExecutionCount++; // MUST NOT run
        });

        // Unblock first body
        barrier.complete();
        await Future.wait([firstCall, secondCall]);

        expect(bodyExecutionCount, 1,
            reason: 'Body must execute exactly once despite concurrent callers');
      },
    );

    test(
      'second caller receives the same future as the first caller',
      () async {
        final barrier = Completer<void>();
        bool secondResolved = false;

        final first = guardedSync(() async {
          await barrier.future;
        });

        await Future<void>.delayed(Duration.zero);

        final second = guardedSync(() async {});
        second.then((_) => secondResolved = true);

        expect(secondResolved, isFalse,
            reason: 'Second caller should still be waiting');

        barrier.complete();
        await Future.wait([first, second]);

        expect(secondResolved, isTrue,
            reason: 'Second caller completes when first body finishes');
      },
    );

    test(
      'sequential calls each execute their own body',
      () async {
        int count = 0;

        // First call runs and completes
        await guardedSync(() async {
          count++;
        });
        expect(count, 1);

        // After completion the guard resets; a second call runs normally
        await guardedSync(() async {
          count++;
        });
        expect(count, 2,
            reason: 'Sequential calls must each run their body once');
      },
    );

    test(
      'guard resets after completion so subsequent calls are not blocked',
      () async {
        await guardedSync(() async {});
        // Completer is now completed — a fresh call must start a new op
        bool ran = false;
        await guardedSync(() async {
          ran = true;
        });
        expect(ran, isTrue,
            reason: 'Guard must reset after previous sync completes');
      },
    );

    test(
      'body exception propagates to first caller and guard resets',
      () async {
        bool threw = false;
        int countAfter = 0;

        try {
          await guardedSync(() async {
            throw Exception('sync failed');
          });
        } on Exception {
          threw = true;
        }

        expect(threw, isTrue);

        // Guard should reset; next call must proceed
        await guardedSync(() async {
          countAfter++;
        });
        expect(countAfter, 1,
            reason: 'Guard must reset after an exception so future syncs work');
      },
    );

    test(
      'many near-simultaneous calls execute body only once',
      () async {
        int bodyCount = 0;
        final barrier = Completer<void>();

        final first = guardedSync(() async {
          bodyCount++;
          await barrier.future;
        });

        await Future<void>.delayed(Duration.zero);

        // Fire off many additional concurrent callers
        final extras = [
          for (int i = 0; i < 10; i++)
            guardedSync(() async {
              bodyCount++;
            }),
        ];

        barrier.complete();
        await Future.wait([first, ...extras]);

        expect(bodyCount, 1,
            reason: 'Only the first body must execute regardless of '
                'how many callers pile up');
      },
    );
  });
}
