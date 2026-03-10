# ChickenJoo Inventory — App Status

**Date:** March 9, 2026  
**Platform:** Flutter (Android / Windows / iOS / macOS / Linux / Web)  
**Architecture:** Offline-first — Drift (SQLite v8) + Supabase cloud sync  

---

## Overall Status

All 6 implementation phases are complete. The app has been stabilized, secured, and regression-tested. The only remaining item is a manual end-to-end validation pass on a real device (Task 6.2).

---

## Phase Summary

| Phase | Title | Status |
|---|---|---|
| 1 | Sync and Data Blockers | ✅ Complete |
| 2 | Security and RLS | ✅ Complete |
| 3 | Auth and Request Loop Stabilization | ✅ Complete |
| 4 | UI Correctness | ✅ Complete |
| 5 | Performance and Memory | ✅ Complete (5.4–5.5 require manual DevTools re-profiling) |
| 6 | Validation and Regression | ✅ Complete (6.2 requires manual device testing) |
| 7 | Commissary Realtime Live Updates Fix | ✅ Complete |
| 8 | Commissary Delete Product Fix | ✅ Complete |
| 9 | Cloud Cleanup Function for Soft-Deleted Records | ✅ Complete |

---

## Phase Details

### Phase 1 — Sync and Data Blockers ✅

| Task | Description | Result |
|---|---|---|
| 1.1 | Fixed `type 'Null' is not a subtype of type 'int'` crash in `stock_change_requests` cloud pull. Added `_coerceInt()` / `_coerceBool()` helpers to the DAO and descriptor. | ✅ |
| 1.2 | Fixed `Bad state: Too many elements` crash. Added v8 DB migration to deduplicate `daily_sales_summary` by business key, keeping the newest row. Created `UNIQUE INDEX idx_daily_sales_bk`. | ✅ |
| 1.3 | Fixed silent cache loss for 5 synced tables. `_buildAllCaches()` in `sync_engine.dart` now covers all 11 tables. | ✅ |
| 1.4 | Added pull pagination. Replaced single-page fetch with a ranged loop so cloud rows beyond the page limit are no longer silently dropped. | ✅ |
| 1.5 | Fixed auth bootstrap user identity mapping. `_pullUserFromCloud()` now stores `users.cloud_id` (the auto-generated UUID) instead of the Auth UID. | ✅ |
| 1.6 | Removed duplicate `daily_sales_descriptor.dart`. Only `daily_sales_summary_descriptor.dart` remains. | ✅ |
| 1.7 | Closed sync lock race. `_runGuardedSync()` helper ensures single-table syncs and `syncAll()` cannot overlap. | ✅ |
| 1.8 | Removed arbitrary parent commissary fallback (`.first` fallback) that could silently assign a franchisee to the wrong network. | ✅ |

---

### Phase 2 — Security and RLS ✅

| Task | Description | Result |
|---|---|---|
| 2.1 | Stopped syncing `password` hashes to the cloud. Field removed from sync payload and descriptor. | ✅ |
| 2.2 | Hardened `users_self_link_auth` RLS policy. Users can self-link `auth_user_id` but cannot change own `role_id` or `organization_id`. | ✅ |
| 2.3 | Fixed commissary update policy for `stock_change_requests`. Commissary can now approve/reject without a `42501` error. | ✅ |
| 2.4 | Restricted anonymous role/org access. Anonymous requests can no longer read commissary orgs or full role permissions. | ✅ |
| 2.5 | Removed unsafe UUID cast in `branch_item_stock` RLS that caused SELECT failures. | ✅ |
| 2.6 | Added commissary write policy for `daily_sales_summary`. Commissary sync no longer gets `42501`. | ✅ |

---

### Phase 3 — Auth and Request Loop Stabilization ✅

| Task | Description | Result |
|---|---|---|
| 3.1 | Eliminated repeated 401 request spam. `SyncAuthException` now short-circuits retries; expired sessions transition cleanly to unauthenticated state. | ✅ |
| 3.2 | Eliminated duplicate GET request loops. Connectivity-change sync now debounces via `_syncDebounceTimer`. `forceFullSyncReplenishmentRequests()` uses the sync lock. | ✅ |
| 3.3 | Stabilized realtime socket lifecycle. `resume()` handles both commissary and franchisee modes. `WidgetsBindingObserver` pauses/resumes the realtime service on app lifecycle changes. | ✅ |

---

### Phase 4 — UI Correctness ✅

| Task | Description | Result |
|---|---|---|
| 4.1 | Replaced dashboard hardcoded zeroes with live DAO data. Cards now reflect real DB counts and refresh after sync. | ✅ |
| 4.2 | Restored commissary realtime after backgrounding. `resume()` correctly restores subscriptions in commissary mode. | ✅ |

---

### Phase 5 — Performance and Memory ✅

| Task | Description | Result |
|---|---|---|
| 5.1 | Removed idle sync status polling. The 30-second `_syncStatusTimer` and 11-query `_updateSyncStatus()` loop were deleted from `main.dart`. | ✅ |
| 5.2 | Reduced `syncStatusNotifier` rebuild scope. Map writes are now guarded to skip no-op updates. `CommissaryHomeScreenController` connectivity callback is guarded. | ✅ |
| 5.3 | Audited and closed subscriptions. `_authListenerSubscription`, `_connectivitySubscription`, and unstored debug `.listen()` calls are all stored and cancelled in `dispose()`. | ✅ |
| 5.4 | Re-profile retained HTTP responses. | ⏳ Requires manual DevTools session after Phase 1–3 fixes |
| 5.5 | Re-profile UI thread blocking / jank. | ⏳ Requires manual DevTools CPU/frame profiling |

---

### Phase 6 — Validation and Regression ✅

#### Task 6.1 — Automated Regression Tests (24 new tests, all passing)

| File | Tests | Coverage |
|---|---|---|
| `test/services/sync/sync_lock_test.dart` | 6 new | `_runGuardedSync` Completer-based lock (Task 1.7) |
| `test/services/sync/auth_bootstrap_identity_test.dart` | 4 new | `cloud_id` vs Auth UID identity mapping (Task 1.5) |
| `test/services/sync/sync_engine_test.dart` | +7 new (41 total) | Pull pagination accumulation (Task 1.4) |
| `test/database/daos/daily_sales_summary_uniqueness_test.dart` | +5 new (12 total) | v8 dedup SQL + upsert idempotency (Task 1.2) |
| `test/daos/stock_change_requests_dao_test.dart` | tests 16–27 (pre-existing) | Null / numeric coercion (Task 1.1) |

**Production bugs caught and fixed during validation:**
- `upsertDailySummary` was using `insertOnConflictUpdate` (conflicts on PK `id` only). Fixed to `DoUpdate(target: [organizationId, itemId, summaryDate])`.
- `_createAllIndexes()` was missing `idx_daily_sales_cloud_id` and `idx_daily_sales_bk`. Fresh installs now get both indexes.

#### Task 6.2 — Manual Validation Checklist

- [ ] Full sync runs without the two crash signatures (`Null is not subtype of int`, `Too many elements`)
- [ ] Commissary can approve stock change requests
- [ ] Franchisee cannot self-promote (role/org unchanged)
- [ ] Dashboard shows live values
- [ ] Commissary realtime recovers after app resume
- [ ] Idle network traffic is quiet
- [ ] 401 spam is gone
- [ ] Memory/query counts are lower than pre-fix baseline

---

---

### Phase 7 — Commissary Realtime Live Updates Fix ✅

**Date:** March 9, 2026

| Task | Description | Result |
|---|---|---|
| 7.1 | Removed wrong `attach()` call from `RequestsPageController.loadContext()`. The controller was calling the franchisee `attach()` method with the commissary's cloud ID, creating a Realtime channel filtered on `franchisee_id = commissaryCloudId`. No franchisee request will ever match that filter, so the commissary received zero INSERT events. Removed the realtime call from the controller entirely — `RequestsPage._loadContext()` already correctly owns the service via `attachAsCommissary()`. | ✅ |
| 7.2 | Eliminated attach race condition in `RequestsPage.initState()`. Both `controller.loadContext()` and `_loadContext()` were fired concurrently unawaited; whichever finished last overwrote the other's subscription on the shared `RealtimeStockRequestService` singleton. Resolved as a side-effect of Task 7.1 — with the controller no longer touching realtime, `_loadContext()` is the sole owner. | ✅ |
| 7.3 | Fixed polling fallback firing on every cycle. `_pollForUpdates()` triggered a full sync whenever any pending request existed, causing constant churn. Added `_lastKnownPendingCount` and `_lastKnownStatusChangedCount` fields; sync is now only triggered when the count **changes**. Both counters are reset in `_stopListening()`. | ✅ |
| 7.4 | Removed unused `_lastPollTime` field from `realtime_stock_request_service.dart`. | ✅ |

**Files changed:**
- `lib/screen/commissary/requests/requests_page_controller.dart` — removed `realtimeStockRequestService.attach()` call
- `lib/services/realtime_stock_request_service.dart` — added count-tracking fields, fixed polling logic, removed unused field

---

### Phase 8 — Commissary Delete Product Fix ✅

**Date:** March 9, 2026

#### Root Causes Fixed

**Bug 1: "Invalid hash format (expected salt$hash)" on delete confirmation**

The commissary login path (`signIn()`) never updated the local password hash after a successful online login. When a user row is pulled from cloud sync, the `password` column gets the placeholder `'!cloud_user_no_local_password'` because the field is intentionally excluded from sync. `verifyPassword()` in `app_database.dart` then failed to parse it, returned `false`, and the delete was blocked.

**Bug 2: Deleted items/stock never reached Supabase cloud**

`shouldSkip: (item) => item.isDeleted` in both `_syncItems()` and `_syncBranchItemStock()` silently swallowed all soft-deletions — deleted records appeared in `getUnsyncedItems()` but were skipped before being pushed, so `is_deleted: true` was never sent to the cloud. Branches and franchisees never received the deletion signal.

**Bug 3: Branch stock rows orphaned on item delete**

When a commissary deleted an item, only the `items` row was soft-deleted. The `branch_item_stock` rows for that item on every franchisee were never touched, leaving orphaned stock records that wasted space and would never clean up.

**Bug 4: `recipe_ingredients.is_deleted` missing on Supabase cloud**

The Dart sync descriptor included `is_deleted` as a field mapping, so pushing a soft-deleted recipe ingredient would fail with a column-not-found error.

**Bug 5: `branch_item_stock.softDelete()` not stamping `lastUpdated`**

The existing soft-delete used `lastUpdated: Value.absent()`, which meant the timestamp was never updated and incremental sync would never detect the change.

#### Tasks

| Task | Description | Result |
|---|---|---|
| 8.1 | Fixed `signIn()` (commissary login) to write the local PBKDF2 password hash after every successful online login, same as the franchisee `_onlineSignInToBranch()` path already did. | ✅ |
| 8.2 | Added `verifyCurrentUserPassword(password)` public method to `SupabaseAuthService`. Tries Supabase Auth re-authentication first (online, no local hash dependency); falls back to local PBKDF2 hash offline. Also opportunistically refreshes the local hash on success. | ✅ |
| 8.3 | Updated `_performDelete()` in `ProductsTab` to use `authService.verifyCurrentUserPassword()` instead of the direct local-hash check. | ✅ |
| 8.4 | Fixed `shouldSkip` in `_syncItems()` and `_syncBranchItemStock()`: changed from `shouldSkip: (r) => r.isDeleted` to `shouldSkip: (_) => false` so soft-deleted records are pushed to cloud with `is_deleted: true`. | ✅ |
| 8.5 | Added `softDeleteByItemId(int itemId)` to `BranchItemStockDao`. Bulk soft-deletes all stock rows for a given item, setting `is_deleted = true`, `is_synced = false`, `last_updated = now()`. | ✅ |
| 8.6 | Fixed `BranchItemStockDao.softDelete()` to stamp `lastUpdated` (was using `Value.absent()`). | ✅ |
| 8.7 | Updated `_performDelete()` to cascade the soft-delete in order: item → branch_item_stock (all branches) → recipe_ingredients. All three are then pushed in the subsequent `syncAll()` call. | ✅ |
| 8.8 | Added `db.branchItemStockDao.cleanupDeleted()` to `_cleanupDeletedRecords()` so hard-cleanup runs for branch stock rows after cloud confirms deletion. | ✅ |
| 8.9 | Created Supabase migration `019_add_is_deleted_to_recipe_ingredients.sql` to add the missing `is_deleted BOOLEAN DEFAULT FALSE` column and a partial index to the cloud `recipe_ingredients` table. | ✅ |

#### Delete Flow (after fixes)

```
[Commissary] clicks delete → password verified via Supabase re-auth
     │
     ▼  Three cascaded soft-deletes (all at once before sync):
     │  1. items.is_deleted = true
     │  2. branch_item_stock.is_deleted = true  (all branches)
     │  3. recipe_ingredients.is_deleted = true (all recipe rows)
     │
     ▼  syncAll() pushes all three tables to Supabase cloud
[Supabase Cloud DB]
     │
     ├─ Realtime event ──────────────────────────┐
     │                                            │
     ▼                                            ▼
[Branch ONLINE]                        [Branch OFFLINE]
Receives event immediately             Misses event
→ pulls is_deleted=true                → On reconnect pulls via incremental sync
→ updates local DB                     → catches up, updates local DB
→ UI removes item                      → UI removes item
```

**Files changed:**
- `lib/services/supabase_auth_service.dart` — `signIn()` hash update, new `verifyCurrentUserPassword()`
- `lib/screen/commissary/inventory_management/products_tab.dart` — cascade delete, Supabase re-auth
- `lib/database/daos/branch_item_stock_dao.dart` — `softDeleteByItemId()`, fixed `softDelete()`
- `lib/services/supabase_sync_service_v2.dart` — `shouldSkip` fixes, `cleanupDeleted` added
- `supabase/migrations/019_add_is_deleted_to_recipe_ingredients.sql` — **apply to Supabase**

---

### Phase 9 — Cloud Cleanup Function for Soft-Deleted Records ✅

**Date:** March 9, 2026

#### Overview

Added a PostgreSQL `SECURITY DEFINER` function to Supabase that hard-deletes cloud rows that were soft-deleted more than 30 days ago. This prevents indefinite row accumulation in the cloud DB — soft-deleted records that every client has already pulled are permanently removed.

#### Root Cause / Motivation

The Phase 8 cascade-delete flow correctly soft-deletes `items`, `branch_item_stock`, and `recipe_ingredients` on both the local DB and in Supabase. However, those `is_deleted = TRUE` rows were never hard-deleted from the cloud, causing table bloat over time.

#### Tasks

| Task | Description | Result |
|---|---|---|
| 9.1 | Created `cleanup_soft_deleted_records(older_than_days INTEGER DEFAULT 30)` PostgreSQL function. Deletes in dependency order: `recipe_ingredients` → `branch_item_stock` (with extra `is_synced = TRUE` guard) → `items`. Returns a summary row with counts of deleted rows per table. | ✅ |
| 9.2 | Locked down permissions: `REVOKE EXECUTE … FROM PUBLIC`, `GRANT EXECUTE … TO service_role`. Anonymous and authenticated roles cannot invoke the function. | ✅ |
| 9.3 | Added three partial indexes (`WHERE is_deleted = TRUE`) on `items`, `branch_item_stock`, and `recipe_ingredients` so the cleanup DELETE queries use index scans instead of full table scans. | ✅ |
| 9.4 | Added commented-out `pg_cron` schedule block (every Sunday 03:00 UTC) ready to activate once the extension is enabled in the Supabase Dashboard. | ✅ |

#### Design Decisions

| Decision | Reason |
|---|---|
| Uses `last_updated` as the deletion timestamp proxy | No `deleted_at` column exists on any table. Every soft-delete path stamps `last_updated = NOW()`, making it a reliable proxy. |
| `is_synced = TRUE` guard on `branch_item_stock` only | `is_synced` only exists in the cloud schema for `branch_item_stock` (migration 008). For `items` and `recipe_ingredients` the 30-day window is the safety gate. |
| 30-day default window | Covers clients that are offline for up to a month while still providing timely cleanup. Do not reduce below 30 days without adding `is_synced` guards to the other two tables. |

#### Cleanup Flow

```
pg_cron triggers every Sunday 03:00 UTC (or manual call via service_role)
     │
     ▼  cleanup_soft_deleted_records(30)
     │  cutoff = NOW() - 30 days
     │
     ├─ DELETE recipe_ingredients   WHERE is_deleted=TRUE AND last_updated < cutoff
     ├─ DELETE branch_item_stock    WHERE is_deleted=TRUE AND is_synced=TRUE AND last_updated < cutoff
     └─ DELETE items                WHERE is_deleted=TRUE AND last_updated < cutoff
     │
     ▼  Returns: (deleted_recipe_ingredients, deleted_branch_item_stock, deleted_items)
```

#### Manual Dry-Run (before scheduling)

```sql
-- Count rows that would be purged without deleting anything
SELECT COUNT(*) FROM recipe_ingredients WHERE is_deleted = TRUE AND last_updated < NOW() - INTERVAL '30 days';
SELECT COUNT(*) FROM branch_item_stock  WHERE is_deleted = TRUE AND is_synced = TRUE AND last_updated < NOW() - INTERVAL '30 days';
SELECT COUNT(*) FROM items              WHERE is_deleted = TRUE AND last_updated < NOW() - INTERVAL '30 days';

-- Execute cleanup
SELECT * FROM cleanup_soft_deleted_records();
```

**Files changed:**
- `supabase/migrations/020_cleanup_soft_deleted_records.sql` — **apply to Supabase**

---

## Known Pre-existing Issues (Out of Scope)

| Issue | Location | Notes |
|---|---|---|
| `submitChangeRequest()` auto-approves instead of setting `pending` | `stock_change_requests_dao.dart` | Causes tests 2, 5, 6, 10, 15 to fail. Status workflow bug, not addressed in any phase. |
| Unused import warning | `stock_change_requests_dao.dart` | Pre-existing lint warning. |
| 2 `daily_sales_summary_descriptor` tests fail | `test/services/` | Field count mismatch + date normalization in descriptor — distinct from DAO tests which all pass. |

---

## Database Schema

**Current version:** v8  
**Tables (11):** `organizations`, `roles`, `users`, `categories`, `items`, `ingredients`, `recipe_ingredients`, `branch_ingredient_stock`, `stock_replenishment_requests`, `stock_change_requests`, `daily_sales_summary`

**v8 migration:** Deduplicates `daily_sales_summary` by business key `(organization_id, item_id, summary_date)` keeping the newest row, then creates `UNIQUE INDEX idx_daily_sales_bk`.
