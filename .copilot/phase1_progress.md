# Phase 1 Progress - Implementation Plan 2

## Session Summary
Working through `implementation plan2.md` phase by phase. User wants questions asked when unsure, no assumptions.

## Task 1.1: Fix stock_change_requests cloud pull coercion — COMPLETE ✅

### Problem
`type 'Null' is not a subtype of type 'int'` crash during cloud pull in `upsertBatchFromCloud()` due to unsafe `as int` casts.

### Changes Made

1. **lib/services/sync/descriptors/stock_requests_descriptor.dart**
   - Added `_coerceInt()` helper at top of file (handles int, double, numeric String, null → null)
   - Changed `quantity` and `originalStock` FieldMappings from `FieldMapping.simple()` to custom `FieldMapping` with `fromCloud: _coerceInt`

2. **lib/database/daos/stock_change_requests_dao.dart**
   - Added `_coerceInt()` static method (safe int coercion: int/double/String/null)
   - Added `_coerceBool()` static method (safe bool coercion: bool/int/String/null)
   - Rewrote `upsertBatchFromCloud()` to use these helpers instead of raw `as int` casts
   - All FK IDs coerced via `_coerceInt()`, booleans via `_coerceBool()`, strings via `.toString()`
   - Improved skip logging to show which field failed

3. **test/daos/stock_change_requests_dao_test.dart**
   - Added top-level `_absent` sentinel constant for test helper
   - Added `_validCloudRecord()` helper using sentinel pattern to distinguish "not provided" from "explicitly null"
   - Added 12 new tests (16-27) in `upsertBatchFromCloud coercion` group — ALL PASSING
   - Tests cover: int values, double→int, String→int, null skip for required fields, mixed batches, snake_case keys, duplicate cloudId updates, isDeleted coercion, fractional string parsing

### DAO Audit Results (for follow-up, NOT done in Task 1.1)
| DAO | Risk | Issue |
|-----|------|-------|
| branch_ingredient_stock_dao | HIGH | `as String`/`as int` casts on cloud_id, organizationId, ingredientId |
| branch_item_stock_dao | HIGH | `as String` on cloud_id, `as int` on minimumStock |
| recipe_ingredients_dao | HIGH | `DateTime.parse()` without null check on created_at/last_updated |
| daily_sales_summary_dao | MEDIUM | `as String` cast on cloudId |
| stock_replenishment_requests_dao | LOW | Uses `?? 0`/`?? ''` defaults |
| items_dao, ingredients_dao, users_dao, organizations_dao, roles_dao | LOW | Already safe |

### Pre-existing Test Failures (NOT caused by Task 1.1)
Tests 2, 5, 6, 10, 15 fail because `submitChangeRequest()` auto-approves (sets status to 'approved') but tests expect 'pending'. These are pre-existing.

---

## Task 1.2: Clean up daily_sales_summary duplicates — COMPLETE ✅

### Changes Made
- **lib/database/app_database.dart**: Bumped schema version v7 → v8. Added v8 migration that:
  - Deduplicates by business key `(organization_id, item_id, summary_date)` using `ROW_NUMBER() OVER (PARTITION BY ... ORDER BY last_updated DESC, id DESC)`
  - Keeps the newest logical row per business key
  - Creates `UNIQUE INDEX idx_daily_sales_bk` on `(organization_id, item_id, summary_date)` to prevent future duplicates
- `upsertBatchFromCloud()` already targets the business key for ON CONFLICT — no changes needed there

---

## Task 1.3: Add missing cache rebuild coverage — COMPLETE ✅

### Changes Made
- **lib/services/sync/sync_engine.dart**: `_buildAllCaches()` now includes all 11 synced tables (was only 6: organizations, roles, users, items, ingredients, recipe_ingredients)
- **lib/database/daos/branch_ingredient_stock_dao.dart**: Added `getAllBranchIngredientStocks()` (unfiltered, for cache)
- **lib/database/daos/daily_sales_summary_dao.dart**: Added `getAllDailySalesSummaries()` (unfiltered, for cache)
- **lib/database/daos/branch_item_stock_dao.dart**: Added `getAllBranchItemStocks()` (unfiltered, for cache; existing `getAllStock()` filters by `isDeleted`)

---

## Task 1.4: Add pull pagination — COMPLETE ✅

### Changes Made
- **lib/services/sync/sync_engine.dart**: Replaced single-page pull with paginated fetch loop
  - Uses `query.range(pageOffset, pageOffset + pageSize - 1)` for Supabase pagination
  - Orders by `last_updated ASC` for consistent pagination (was DESC)
  - Stops when page returns fewer than `pageSize` rows
  - All resolved records accumulated across pages then bulk-upserted

---

## Task 1.5: Fix auth bootstrap user identity mapping — COMPLETE ✅

### Problem
Local user `cloudId` stored `authUser.id` (Supabase Auth UID) instead of the actual `users.cloud_id` from the Supabase users table. This caused the sync engine's UUID cache to map the wrong ID, leading to FK resolution failures and duplicate user rows during sync.

### Changes Made
- **lib/services/supabase_auth_service.dart**:
  - `_pullUserFromCloud()`: Changed `cloudId: authUser.id` → `cloudId: userResponse['cloud_id']`
  - Now stores the actual Supabase `users.cloud_id` instead of the auth UID
  - `_findLocalUser()`: Priority 1 still matches auth UID (backward compat with existing users), Priority 2 matches by email

---

## Task 1.6: Remove duplicate daily sales descriptor — COMPLETE ✅

### Changes Made
- **Deleted** `lib/services/sync/descriptors/daily_sales_descriptor.dart` (obsolete, unused by any Dart code)
- **lib/services/sync/sync.dart**: Updated barrel export from `daily_sales_descriptor.dart` → `daily_sales_summary_descriptor.dart`
- **lib/services/supabase_sync_service_v2.dart**: Removed direct import of `daily_sales_summary_descriptor.dart` (now comes via barrel)

---

## Task 1.7: Close sync lock race on individual sync methods — COMPLETE ✅

### Changes Made
- **lib/services/supabase_sync_service_v2.dart**:
  - Added `_runGuardedSync(String label, Future<void> Function() body)` helper that acquires `_isSyncing` + `_syncCompleter` lock (same as `syncAll()`)
  - All 11 individual sync methods (`syncOrganizations`, `syncItems`, etc.) now use `_runGuardedSync`
  - `syncItemsOnly()` also uses the guarded pattern
  - Properly handles `_pendingContextClear` in the finally block
  - Prevents overlap between individual syncs and `syncAll()`

---

## Task 1.8: Remove arbitrary parent commissary fallback — COMPLETE ✅

### Changes Made
- **lib/services/supabase_sync_service_v2.dart**:
  - `_reloadParentCommissaryId()`: Removed the `.first` commissary fallback that silently assigned franchisees to an arbitrary commissary
  - Now logs a warning if parent commissary cannot be resolved from the org's `parentCommissaryId`

---

## Phase 1 COMPLETE ✅

All 8 tasks done. `flutter analyze` shows zero new errors. Pre-existing failures unchanged:
- 5 stock_change_requests_dao tests (auto-approve issue)
- 2 daily_sales_summary_descriptor tests (field count mismatch + date normalization expectation)

## Key Architecture Notes
- Sync flow: `SyncEngine.pullTable()` → `descriptor.toLocalFormat()` → `dao.upsertBatchFromCloud()`
- Descriptor normalizes field names (snake_case→camelCase) and resolves FKs (cloud UUID→local int ID)
- DAO receives maps with camelCase keys and resolved local IDs
- 4-tier dependency sync: Tier1(orgs,roles) → Tier2(users,items,ingredients) → Tier3(recipes,stock) → Tier4(requests,sales)
- Test DB helper: `test/database/test_database.dart` → `createTestDatabase()` → in-memory Drift DB
- User prefers: in-memory Drift DB tests, NOT mockito. Descriptor normalizes, DAO defends.

## File Locations Reference
- Descriptors: `lib/services/sync/descriptors/`
- DAOs: `lib/database/daos/`
- Tables: `lib/database/tables/` (note: also `lib/tables/` exists)
- Sync engine: `lib/services/sync/sync_engine.dart`
- Sync service: `lib/services/supabase_sync_service_v2.dart`
- Auth service: `lib/services/supabase_auth_service.dart`
- App database: `lib/database/app_database.dart` (v8, 12 tables, 13 DAOs)
- Daily sales descriptor: `daily_sales_summary_descriptor.dart` only (Task 1.6 removed the duplicate)
