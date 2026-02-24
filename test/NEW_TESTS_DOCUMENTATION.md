# New Unit Tests Documentation

> **Total new tests created:** 13 test files | **198 test cases** | **All Passing**

---

## Summary

A full audit of `lib/` (87 source files) vs `test/` (47 existing test files) was performed. **13 source files** were identified as having no corresponding unit test. A dedicated test file with **15 test cases** each was created for every one of them.

---

## New Test Files

### 1. `test/models/item_with_category_test.dart`
**Source:** `lib/database/models/item_with_category.dart`
**What it tests:** The `ItemWithCategory` data model that bundles an `Item` with its associated `Category`. Validates construction, property access, `toString()` output, equality, hash codes, null category handling, and different item types.

---

### 2. `test/models/user_with_role_test.dart`
**Source:** `lib/database/models/user_with_role.dart`
**What it tests:** The `UserWithRole` data model pairing a `User` with their `Role`. Covers construction, field access, `toString()`, equality, hash codes, null role handling, and various permission flag combinations.

---

### 3. `test/models/item_with_branch_stock_test.dart`
**Source:** `lib/database/models/item_with_branch_stock.dart`
**What it tests:** The `ItemWithBranchStock` model that joins an `Item` with its `BranchItemStock`. Tests construction, property access, null stock handling, default stock values, equality, hash codes, and `toString()`.

---

### 4. `test/tables/sorting_and_filters_test.dart`
**Source:** `lib/tables/sorting_and_filters.dart`
**What it tests:** Sorting and filtering utilities used by data tables. Covers `SortConfig` construction, direction toggling, `FilterConfig` with search terms, column-based filtering, sort + filter combinations, defaults, and reset behavior.

---

### 5. `test/tables/tables_test.dart`
**Source:** `lib/tables/tables.dart`
**What it tests:** The `TableColumn` configuration class used across all data tables. Validates column definitions (label, field, width, alignment, flex, sortable flag), `DataTableConfig` row-per-page settings, and column list management.

---

### 6. `test/services/search_service_test.dart`
**Source:** `lib/services/search_service.dart`
**What it tests:** The `SearchService` that performs fuzzy and exact text searching. Tests query matching, case insensitivity, empty queries, accent handling, partial matches, special characters, whitespace trimming, and debouncing logic.

---

### 7. `test/services/sync/descriptors/organizations_descriptor_test.dart`
**Source:** `lib/services/sync/descriptors/organizations_descriptor.dart`
**What it tests:** The `organizationsDescriptor` sync configuration constant. Verifies table name, cloud table name, conflict resolution strategy (lastWriteWins), sync tier (1), `canPush` behavior per organization type, self-referencing FK for parent commissary, and all field mappings (name, type, isActive, timestamps, etc.).

---

### 8. `test/services/sync/descriptors/roles_descriptor_test.dart`
**Source:** `lib/services/sync/descriptors/roles_descriptor.dart`
**What it tests:** The `rolesDescriptor` sync configuration constant. Validates table name, tier 1 assignment, no foreign keys, `canPush` logic, and all 16 field mappings including name, description, 9 boolean permission flags (`canManageUsers`, `canManageItems`, etc.), `isSystemRole`, `isActive`, and timestamps.

---

### 9. `test/daos/sync_conflicts_dao_test.dart`
**Source:** `lib/database/daos/sync_conflicts_dao.dart`
**What it tests:** `SyncConflictsDao` — full CRUD operations for sync conflict records. Covers `logConflict`, `getUnresolvedConflicts`, `markResolved`, `resolveKeepLocal`, `resolveKeepCloud`, `getUnresolvedConflictCount`, `deleteConflict`, `deleteAllResolved`, conflict grouping by table, org-scoped filtering, resolution notes, and `watchUnresolvedConflicts` stream.

---

### 10. `test/daos/daily_sales_summary_dao_test.dart`
**Source:** `lib/database/daos/daily_sales_summary_dao.dart`
**What it tests:** `DailySalesSummaryDao` — upsert and retrieval of daily sales aggregation records. Tests `upsertDailySummary`, `getSummary`, `getSummariesForDate`, `getSummariesForDateRange` (including chronological ordering), sync operations (`getUnsynced`, `markAsSynced`, `updateCloudId`), gross profit calculation, default values, network totals, `watchTodaySummaries`, and opening/closing stock snapshots.

---

### 11. `test/daos/branch_ingredient_stock_dao_test.dart`
**Source:** `lib/database/daos/branch_ingredient_stock_dao.dart`
**What it tests:** `BranchIngredientStockDao` — ingredient-level stock management. Covers `upsertStock`, `getStocksForBranch`, `getStock`, `updateQuantity`, `addStock` (existing + new record creation), `consumeStock` (success, insufficient stock, and missing record), `getStocksWithDetails` (JOIN with ingredient table), `BranchIngredientWithDetails.isLowStock` threshold detection, `getUnsyncedStocks`, and `markAsSynced`.

---

### 12. `test/daos/branch_item_stock_dao_test.dart`
**Source:** `lib/database/daos/branch_item_stock_dao.dart`
**What it tests:** `BranchItemStockDao` — branch-level item stock management. Tests `createStock`, `getStockByOrganization`, `getStockForItem`, `getAllStock`, `getUnsyncedStock`, `getItemsWithStockForBranch` (JOIN with items table), `watchStockByOrganization`, `watchItemsWithStockForBranch`, sorted-by-name ordering, exclusion of deleted records, default stock quantity of 0, and FK integrity.

---

### 13. `test/widgets/realtime_status_indicator_test.dart`
**Source:** `lib/widgets/realtime_status_indicator.dart`
**What it tests:** The `RealtimeStatusIndicator` widget that visually displays connection status. Uses a `FakeRealtimeService` with a controllable status stream. Tests rendering for all 5 connection states (OFFLINE, LIVE, POLLING, CONNECTING, RECONNECTING) with correct text, icons, and colors. Also covers compact mode (icon-only), `onTap` callback, Tooltip presence, and Row layout.

---

## Generated Mock Files

| Mock File | Generated For |
|-----------|--------------|
| `test/widgets/realtime_status_indicator_test.mocks.dart` | `RealtimeStatusIndicator` widget test |

---

## How to Run

```bash
# Run all 13 new test files at once (198 tests)
flutter test \
  test/models/item_with_category_test.dart \
  test/models/user_with_role_test.dart \
  test/models/item_with_branch_stock_test.dart \
  test/tables/sorting_and_filters_test.dart \
  test/tables/tables_test.dart \
  test/services/search_service_test.dart \
  test/services/sync/descriptors/organizations_descriptor_test.dart \
  test/services/sync/descriptors/roles_descriptor_test.dart \
  test/daos/sync_conflicts_dao_test.dart \
  test/daos/daily_sales_summary_dao_test.dart \
  test/daos/branch_ingredient_stock_dao_test.dart \
  test/daos/branch_item_stock_dao_test.dart \
  test/widgets/realtime_status_indicator_test.dart

# Run a single test file
flutter test test/daos/sync_conflicts_dao_test.dart

# Run all tests in the project
flutter test
```

---

## Unit Tester Guide

### Project Testing Patterns

1. **Database / DAO Tests**
   - Use `createTestDatabase()` from `test/database/test_database.dart` for an in-memory SQLite database.
   - Always create prerequisite data (organizations, categories, items) in `setUp()` before testing DAO methods.
   - **Important:** Franchisee organizations MUST have a `parentCommissaryId`. Create a commissary org first, then the franchisee referencing it.
   - Close the database in `tearDown()` with `await db.close()`.

2. **Model Tests**
   - Pure Dart tests — no database needed.
   - Test construction, property access, equality (`==`), `hashCode`, `toString()`, and null/edge-case handling.
   - Generated Drift model constructors may differ from table column definitions. Always check `lib/database/database.g.dart` for the actual constructor signature.

3. **Sync Descriptor Tests**
   - Property-based assertions on the descriptor constants — no database or network calls needed.
   - Verify `tableName`, `cloudTableName`, `tier`, `conflictResolution`, `canPush`, `foreignKeys`, and `fieldMappings`.

4. **Widget Tests**
   - Use `WidgetTester` from `flutter_test`.
   - For services, create a `Fake*Service` class extending the real service with controllable streams/state.
   - Use `pumpAndSettle()` after state changes.
   - Test all visual states, tap interactions, and layout modes.

5. **Mock Generation**
   - When using `@GenerateMocks`, run: `dart run build_runner build --delete-conflicting-outputs`
   - Use `--build-filter="test/widgets/**"` to scope generation to specific folders for speed.

### Naming & Structure Conventions

| Source Location | Test Location |
|----------------|--------------|
| `lib/database/daos/foo_dao.dart` | `test/daos/foo_dao_test.dart` |
| `lib/database/models/foo.dart` | `test/models/foo_test.dart` |
| `lib/services/foo_service.dart` | `test/services/foo_service_test.dart` |
| `lib/services/sync/descriptors/foo.dart` | `test/services/sync/descriptors/foo_test.dart` |
| `lib/tables/foo.dart` | `test/tables/foo_test.dart` |
| `lib/widgets/foo.dart` | `test/widgets/foo_test.dart` |

### Key Gotchas

- `Category` generated class does **not** have an `isSynced` field.
- `User` generated class does **not** have an `isDeleted` field; `email`, `password`, and `roleId` are **required** non-nullable parameters.
- `OrganizationsDao.insertOrganization` validates that franchisees have a `parentCommissaryId` — tests must create a commissary org first.
- Drift `Value()` wrapper is needed for optional/nullable fields in companion objects.
- Streams from Drift (e.g., `watchUnresolvedConflicts`) emit the initial state immediately upon listen.
