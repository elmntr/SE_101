# SE_101 ChickenJoo Inventory - Repo Notes

## Project
- Flutter offline-first inventory management app
- Drift (SQLite) local DB + Supabase cloud sync
- Database version: v8 (bumped from v7 during Phase 1)

## Build
- `flutter pub get` → deps
- `dart run build_runner build --delete-conflicting-outputs` → codegen
- `flutter test` → tests
- `flutter analyze` → lint

## Key Conventions
- Dual ID: `id` (local int autoincrement) + `cloud_id` (UUID text, nullable)
- DAO pattern in `lib/database/daos/`, tables in `lib/database/tables/`
- Sync descriptors in `lib/services/sync/descriptors/`
- Sync barrel: `lib/services/sync/sync.dart` (exports all descriptors)
- Test DB: `test/database/test_database.dart` → `createTestDatabase()` (in-memory)
- User prefers real in-memory Drift DB for tests, NOT mockito unless already used
- Generated files: `*.g.dart`, `*.mocks.dart` — do not edit
- Individual sync methods use `_runGuardedSync()` — same lock as `syncAll()`
- Pull pagination via `.range()` in `SyncEngine.pullTable()` — no silent record drops
- Auth bootstrap stores actual `users.cloud_id` (not auth UID) as local `cloudId`

## Implementation Progress
- **Phase 1**: COMPLETE (Tasks 1.1–1.8) — Sync and Data Blockers
- **Phase 2**: NOT STARTED — Security and RLS
- **Phase 3–6**: NOT STARTED

## Pre-existing Issues
- `submitChangeRequest()` auto-approves instead of setting 'pending' → some tests (2,5,6,10,15) fail pre-existing
- Unused import warning in stock_change_requests_dao.dart (pre-existing)
- 2 daily_sales_summary_descriptor tests fail (field count mismatch + date normalization expectation vs active descriptor)
