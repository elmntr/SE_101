# WebSocket & Sync Fix Summary

## Overview

Three related problems were identified and fixed across the SE_101 (franchisee + commissary) and SE101-COmmissary (legacy) projects:

1. Commissary could receive stock requests in real-time but approve/reject never pushed to cloud without a manual sync.
2. Supabase WebSocket closing with code 1006 on the commissary realtime channel.
3. `no such column: is_deleted` crashing sync on existing databases (both projects).

---

## Problem 1 — `no such column: is_deleted` (SE101-COmmissary)

**File:** `lib/database/app_database.dart`

**Root cause:** `categories`, `stock_replenishment_requests`, and `branch_item_stock` had `isDeleted` added to their Drift table definitions after initial creation, but no `ALTER TABLE` migration was ever written. Every sync call referencing `is_deleted` crashed with a SQLite exception.

**Fix:** Schema version bumped 3 → 4. The new v4 migration block runs:

```sql
ALTER TABLE categories ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0;
ALTER TABLE stock_replenishment_requests ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0;
ALTER TABLE branch_item_stock ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0;
```

Each wrapped in `try/catch` for idempotency (safe to run on a fresh install).

---

## Problem 2 — WebSocket 1006 / realtime not updating (SE101-COmmissary)

**File:** `lib/services/realtime_stock_request_service.dart`

Three bugs fixed:

### 2a — No server-side filter (RLS blocks full-table access)

The subscription had no `filter:` clause, so Supabase evaluated RLS for every row in the table. With `auth_user_id = NULL` on legacy accounts, RLS returned false for all rows and the server closed the WebSocket with code 1006.

**Fix:** Added `PostgresChangeFilter(type: eq, column: 'commissary_id', value: _commissaryCloudId!)` so Supabase only pushes rows matching this commissary — sidesteps the full-table RLS check.

### 2b — Race condition: disconnect before first `subscribed` swallowed by lock

When the channel closed with 1006 *before* the subscription was ever confirmed, `_handleDisconnection()` scheduled a reconnect but `_isAttemptingRealtime` was still `true`, silently swallowing it. The only recovery was the 10-second `completer.timeout`.

**Fix:** Added a local `wasEverSubscribed` flag:
- Closed **after** first `subscribed` → `_handleDisconnection()` as before.
- Closed **before** first `subscribed` → immediately `completer.completeError(...)` so `_connectWithRetry`'s retry loop picks it up without penalty.

### 2c — No catch-up sync on reconnect

After reconnecting, any requests that arrived during the disconnect window were never fetched.

**Fix:** `_triggerDebouncedSync()` is called immediately when the subscription transitions to `subscribed`.

---

## Problem 3 — Commissary realtime service wired to franchisee mode (SE_101)

**Files:** `lib/services/realtime_stock_request_service.dart`, `lib/screen/commissary/requests/requests_page.dart`

**Root cause:** The SE_101 `RealtimeStockRequestService` was franchisee-only — it filtered on `franchisee_id` and only handled `UPDATE` events (status changes). The commissary page was calling `attach()` (franchisee mode) so it filtered on the wrong column and missed `INSERT` events (new pending requests). The event listener also only `debugPrint`-ed and never triggered a refresh.

**Fixes:**

### `realtime_stock_request_service.dart`

- Added `_isCommissaryMode` / `_commissaryCloudId` fields.
- Added `attachAsCommissary(String commissaryCloudId)` — sets commissary mode, stops any existing franchisee subscription, starts fresh.
- `_createChannel()` now passes the correct server-side filter for the active mode (`commissary_id` vs `franchisee_id`) and routes `INSERT`+`UPDATE` events to `_handleCommissaryEvent()` in commissary mode.
- Added `_handleCommissaryEvent()` — synthesises a `StockRequestEvent` (with `oldStatus = ''` for inserts) and triggers debounced sync.
- `_pollForUpdates()` polls for `pending` requests in commissary mode, `approved/rejected/delivered` in franchisee mode.
- `_stopListening()` resets commissary mode flags on detach.

### `requests_page.dart`

- Removed duplicate `_searchController` field.
- Added `_syncAndRefresh()` — syncs replenishment requests from cloud then calls `setState`.
- Switched `attach()` → `attachAsCommissary()`.
- Event listener now calls `_syncAndRefresh()` on every event.
- Catch-up `_syncAndRefresh()` called immediately after attaching.

---

## Problem 4 — Approve/Reject not pushing to cloud in real-time (SE_101)

**Files:** `lib/services/supabase_sync_service_v2.dart`, `lib/screen/commissary/requests/requests_page.dart`

### Root causes

1. `syncAll()` has a smart-sync cooldown — if a sync ran recently it returns silently.
2. `pushReplenishmentOutcomeNow()` (first attempt) assumed an in-flight sync already included the approval. It doesn't — the local DB write happens *after* the sync's push phase so it always waited for the lock to clear then returned without pushing anything.
3. `pushReplenishmentOutcomeNow()` (second attempt) fell through correctly but still had to wait for the periodic sync timer to release `_isSyncing`, causing the `awaiting in-flight sync` delay visible in logs. The UI never called `setState` until after all of that completed.

### Final fix — two-layer approach

**Layer 1 — Direct REST push** (`directUpdateRequestStatus`, new method):

```dart
Future<void> directUpdateRequestStatus({
  required String requestCloudId,
  required String status,
  required String reviewerCloudId,
  String? notes,
  required DateTime reviewedAt,
}) async {
  await supabase.from('stock_replenishment_requests').update({
    'status': status,
    'reviewed_by': reviewerCloudId,
    'reviewed_at': reviewedAt.toUtc().toIso8601String(),
    'commissary_notes': notes,
    'last_updated': DateTime.now().toUtc().toIso8601String(),
  }).eq('cloud_id', requestCloudId);
}
```

- Single Supabase REST call, ~100ms, zero lock contention.
- Mirrors exactly how the franchisee side *receives* status changes via WebSocket.
- Pushes `status`, `reviewed_by`, `reviewed_at`, `commissary_notes`, `last_updated`.

**Layer 2 — Background stock sync** (`pushReplenishmentOutcomeNow`, called fire-and-forget):

```dart
syncService.pushReplenishmentOutcomeNow().catchError(
  (e) => debugPrint('background stock sync failed: $e'),
);
```

- Handles items (commissary stock deduction) and branch_item_stock (franchisee credit).
- Non-blocking — UI and direct push have already completed.

**UI refresh:** `setState(() {})` called immediately after `directUpdateRequestStatus` returns. Local DB already has the correct state from `approveRequest`/`rejectRequest`, so the request moves to the history tab instantly.

---

## Files Changed

| File | Project | Change |
|------|---------|--------|
| `lib/database/app_database.dart` | SE101-COmmissary | Schema v3→v4, ALTER TABLE for 3 tables |
| `lib/services/realtime_stock_request_service.dart` | SE101-COmmissary | Server-side filter, `wasEverSubscribed` race fix, catch-up sync |
| `lib/services/realtime_stock_request_service.dart` | SE_101 | `attachAsCommissary()`, `_handleCommissaryEvent()`, commissary polling, server-side filter |
| `lib/screen/commissary/requests/requests_page.dart` | SE_101 | Use `attachAsCommissary`, event-driven refresh, duplicate field cleanup |
| `lib/services/supabase_sync_service_v2.dart` | SE_101 | `directUpdateRequestStatus()`, `pushReplenishmentOutcomeNow()` (fixed race) |

---

## Supabase SQL Still Required

> ⚠️ The RLS root cause (`auth_user_id = NULL` causing `get_current_user_organization_id()` to return null) requires `011_fix_auth_bootstrap.sql` to be applied in the Supabase SQL Editor. The app-side fixes above make the service resilient, but permanent WebSocket stability on accounts created before migration 002 depends on that RLS fix being in place.
