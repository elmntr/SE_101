# SE-101 + SE101-Commissary Merge — Status & Handoff Summary

**Last Updated:** Generated from merge session  
**Status:** Implementation COMPLETE — 0 compilation errors, 322 warnings/infos  
**Reference:** See `MERGE_PLAN.md` for the original plan (499 lines)

---

## What Was Done

The SE101-Commissary Flutter app was merged into the SE_101 (ChickenJoo Inventory) Flutter app. All commissary UI screens were transplanted, auth flow was updated, database schema was bumped, and Edge Functions were created. The project compiles with **zero errors**.

---

## Prerequisite Decisions Made (8 of 8 Resolved)

| # | Decision | Choice |
|---|----------|--------|
| 1 | HQ Access Code Storage | `hq_access_code_hash TEXT` column on `organizations` table |
| 2 | Initial Access Code | `123456` (PBKDF2 hash stored) |
| 3 | Commissary Screen Namespace | `lib/screen/commissary/` |
| 4 | Branch Admin Auth Account Deletion | Via Supabase Edge Function (service_role key) |
| 5 | HQ Access Gate Trigger | Floating lock icon on login screen (bottom-right) |
| 6 | Route Strategy | Named routes: `/commissary-login`, `/commissary-home` |
| 7 | Commissary Home Nav | Sidebar navigation (desktop) / drawer (mobile) |
| 8 | Password Update for Branch Admins | Via Supabase Edge Function |

---

## Implementation Phases Completed

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | PBKDF2 hash generation for access code "123456" | ✅ |
| 2 | Auth methods added to `supabase_auth_service.dart` | ✅ |
| 3 | `hqAccessCodeHash` column + schema v5 migration + sync descriptor + DAO | ✅ |
| 3b | `canManageInventory`/`canManageBranches` in `RolePermissions` | ✅ |
| 4 | `HqAccessGate` widget created | ✅ |
| 5 | HQ button added to login scaffolds (desktop + mobile) | ✅ |
| 6a-6d | All commissary screens transplanted + filter_widgets + reports_service | ✅ |
| 7 | Routes added to `app.dart` | ✅ |
| 8 | Auth gate branching on `user.isCommissary` | ✅ |
| 12 | Edge Functions created (`delete-auth-user`, `update-user-password`) | ✅ |
| 9 | Testing | ❌ Not yet run |
| 13 | Documentation/Cleanup | ❌ Not done |

---

## Files Modified

### `lib/services/supabase_auth_service.dart`
- Added `createBranchAdminAuthUser(email, password, orgId, orgCloudId, orgName)` — creates Supabase Auth user + local users row
- Added `deleteAuthUser(authUserId)` — calls `delete-auth-user` Edge Function
- Added `updateAuthUserPassword(authUserId, newPassword)` — calls `update-user-password` Edge Function
- `RolePermissions`: added `canManageInventory`, `canManageBranches` boolean fields

### `lib/database/tables/organizations.dart`
- Added: `TextColumn get hqAccessCodeHash => text().nullable()();`

### `lib/database/app_database.dart`
- Schema version: `4 → 5`
- Migration: adds `hq_access_code_hash` TEXT column to `organizations` table
- `hashPassword()` and `verifyPassword()` are top-level functions (lines ~571/578)

### `lib/database/daos/organizations_dao.dart`
- Added: `getCommissary()` aliasing `getMainCommissary()` (returns first commissary org)
- Added: `getFranchisees(int commissaryId)` aliasing `getFranchiseesByCommissary()`
- Added: `hqAccessCodeHash` included in upsert/update methods

### `lib/services/sync/descriptors/organizations_descriptor.dart`
- Added `hqAccessCodeHash` field mapping for push/pull sync

### `lib/screen/login/widgets/login_scaffold_desktop.dart`
- Body wrapped in `Stack`, `HqAccessGate` positioned bottom-right

### `lib/screen/login/widgets/login_scaffold_mobile.dart`
- Body wrapped in `Stack`, `HqAccessGate` positioned bottom-right

### `lib/app.dart`
- Added imports for `CommissaryLoginScreen` and `CommissaryHomeScreen`
- Added routes: `/commissary-login` → `CommissaryLoginScreen`, `/commissary-home` → `CommissaryHomeScreen`

### `lib/screen/auth/auth_gate_screen.dart`
- `_navigateToHome()` now branches: if `user.isCommissary` → `/commissary-home`, else → `/home`

### `test/services/mock_test.dart`
- Fixed import: `supabase_sync_service_test.mocks.dart` → `mock_test.mocks.dart`

---

## Files Created

### Commissary Screens (`lib/screen/commissary/`)

| File | Purpose |
|------|---------|
| `login/hq_access_gate.dart` | Lock icon widget + access code verification dialog (PBKDF2) |
| `login/commissary_login_screen.dart` | Commissary-specific login (no branch selection) |
| `home/commissary_home_screen.dart` | Dashboard shell (routes to `_desktop` or `_mobile`) |
| `home/commissary_home_screen_desktop.dart` | Desktop layout: sidebar with 6 nav items |
| `home/commissary_home_screen_mobile.dart` | Mobile layout: drawer navigation |
| `branches/branches_page.dart` | Manage franchisee orgs + create branch admin accounts |
| `branches/branches_page_desktop.dart` | Desktop variant |
| `branches/branches_page_mobile.dart` | Mobile variant |
| `inventory_management/inventory_management_page.dart` | TabBar: Ingredients / Products tabs |
| `inventory_management/inventory_management_page_desktop.dart` | Desktop variant |
| `inventory_management/inventory_management_page_mobile.dart` | Mobile variant |
| `inventory_management/ingredients_tab.dart` | Ingredient list with add/edit/delete/adjust stock |
| `inventory_management/products_tab.dart` | Product list with add/edit/delete/adjust stock + recipe mgmt |
| `inventory_management/widgets/ingredient_form_dialog.dart` | Add/edit ingredient dialog |
| `inventory_management/widgets/item_form_dialog.dart` | Add/edit item dialog with recipe management |
| `requests/requests_page.dart` | View + approve/reject stock replenishment requests |
| `requests/requests_page_desktop.dart` | Desktop variant |
| `requests/requests_page_mobile.dart` | Mobile variant |
| `reports/reports_page.dart` | Cross-branch commissary reporting |
| `ingredients/ingredients_page.dart` | Ingredient management outer shell |
| `inventory/inventory_page.dart` | Stock overview page |
| `settings/settings_page.dart` | Sync controls + connection status display |

### Shared Widgets & Services

| File | Purpose |
|------|---------|
| `lib/widgets/filter_widgets.dart` | `UniversalFilterButton` + `FilterOption` reusable widgets |
| `lib/services/reports_service.dart` | Data layer for commissary reports (queries Supabase views) |

### Supabase Edge Functions

| File | Purpose |
|------|---------|
| `supabase/functions/delete-auth-user/index.ts` | Deletes Supabase Auth user (requires service_role key) |
| `supabase/functions/update-user-password/index.ts` | Updates Supabase Auth user password (service_role key) |

---

## Critical API Facts (for Future Agents)

These mappings were discovered during error fixing and are essential for anyone modifying the transplanted code:

### Database Field Mapping (Commissary Source → SE_101 Actual)

| Commissary Used | SE_101 Actual | Table |
|-----------------|---------------|-------|
| `criticalLevel` | `minimumStock` (nullable int) | ingredients, items |
| `costPerUnit` | *(does not exist)* | ingredients |
| `cost` | `costPrice` (nullable double) | items |
| `needsSync` | `isSynced` (bool, inverted logic) | ingredients, items |
| `updatedAt` | `lastUpdated` | ingredients, items |
| `lastSyncedAt` | `lastUpdated` | ingredients, items |
| `passwordHash` | `password` | users |
| `authUserId` | `cloudId` | users |
| `isActive` | `isDeleted` (inverted logic) | ingredients, items |

### DAO Method Mapping

| Commissary Used | SE_101 Actual |
|-----------------|---------------|
| `createIngredient(companion)` | `insertIngredients([companion])` |
| `createItem(companion)` | `insertItem(name:, organizationId:, ...)` |
| `createRecipeIngredient(...)` | `insertRecipeIngredient(itemId:, ingredientId:, quantityNeeded:, unit:)` |
| `adjustStock(id, delta)` | `addStock(id, amount)` / `deductStock(id, amount)` / `updateStock(id, newStock)` |
| `watchIngredientsByCommissary(id)` | `watchAllIngredients(commissaryId: id)` |
| `watchItemsByOrganization(id)` | `watchAllItems()` |
| `getRecipeIngredients(itemId)` | `getIngredientsForItem(itemId)` |
| `deleteRecipeForItem(itemId)` | `deleteAllForItem(itemId)` |
| `getRecipeWithDetails(itemId)` | `getIngredientsForItem(itemId)` |
| `watchPendingRequests(...)` | `watchRequests(status: 'pending', ...)` |
| `watchAllRequests(...)` | `watchRequests(...)` |

### Sync Service

| Commissary Used | SE_101 Actual |
|-----------------|---------------|
| `performFullSync()` | `syncAll()` |
| `isOnline` (getter) | *(does not exist — derive from `getSyncStatus()`)* |
| `lastSuccessfulSync` (getter) | *(does not exist — derive from `getSyncStatus()`)* |

### Enums

| Enum | Valid Values |
|------|-------------|
| `SyncStatus` | `idle`, `syncing`, `synced`, `error` — NO `offline` |
| `IngredientSortOrder` | `nameAsc`, `nameDesc`, `stockAsc`, `stockDesc`, `newestFirst`, `oldestFirst` — NO `costAsc`/`costDesc` |
| `ItemSortOrder` | `nameAsc`, `nameDesc`, `stockAsc`, `stockDesc`, `newestFirst`, `oldestFirst` — NO `priceAsc`/`priceDesc`/`costAsc`/`costDesc` |

### Other Important Facts

- `buildUniversalTable()` params: `headers`, `rows`, `smallHeaderWidth`, `largeHeaderWidth` — NO `showHorizontalScrollbar` or `horizontalController`
- `AppLayout.isDesktop()` defined in `design_constants.dart` (threshold 1000px)
- `fontAll` constant = `'Montserrat'` in `design_constants.dart`
- `StockRequestEvent` has `newStatus`/`oldStatus` — NO `status` getter
- `RecipeIngredient` has `quantityNeeded` — NOT `quantity`
- `IngredientsCompanion.insert()` required: `name`, `commissaryId`
- `ItemsCompanion.insert()` required: `name`, `organizationId`

---

## PBKDF2 Access Code Hash

The default HQ access code is **`123456`** with hash:
```
781963085214c44cc9b773f111d1f14a$5cc98eb5b6aecd7289ea368d8ad79556c4081446aab4e0ad1f968494da5b7ffa
```
Format: `salt$hash` — verified using `hashPassword()` / `verifyPassword()` from `app_database.dart`.

---

## What Still Needs To Be Done

### 1. Run Tests (Phase 9)
```powershell
flutter test
```
Existing tests have NOT been run since the merge. They may need updates if any shared code paths changed.

### 2. Runtime Testing
- Navigate to `/commissary-login` and verify login works
- Verify HqAccessGate shows on login screen (bottom-right lock icon)
- Verify access code "123456" is accepted and navigates to `/commissary-login`
- After commissary login, verify `/commissary-home` loads with all 6 sidebar items
- Test each commissary page: Branches, Inventory Management, Requests, Reports, Ingredients, Settings
- Test branch creation flow (creates auth user via Edge Function)
- Test inventory CRUD (add/edit/delete ingredients and items)
- Test recipe management (add ingredients to item recipe)
- Test request approval/rejection
- Test sync from Settings page

### 3. Deploy Supabase Changes
- **Cloud migration**: Add `hq_access_code_hash TEXT` column to `organizations` table in Supabase
- **Insert hash**: Update commissary organization row with the PBKDF2 hash above
- **Deploy Edge Functions**:
  ```powershell
  supabase functions deploy delete-auth-user
  supabase functions deploy update-user-password
  ```

### 4. Fix Warnings (322 remaining)
Most are:
- `avoid_print` — replace `print()` with `AppLogger` calls
- `deprecated_member_use` — `.withOpacity()` should become `Color.fromRGBO()` or similar
- `use_build_context_synchronously` — add `if (!mounted) return;` guards after awaits
- `unused_import` — remove unused imports
- `prefer_const_constructors` / `prefer_const_literals_to_create_immutables`

### 5. UX Review of Transplanted Screens
Some features were simplified during adaptation:
- **Ingredient cost display removed** (SE_101's `ingredients` table has no `costPerUnit` field)
- **Recipe cost calculations return 0** (no cost data available)
- **Sort options reduced** (no cost-based sorting since cost fields don't exist on all tables)
- A future agent should review each commissary screen for completeness and UX quality

### 6. Documentation Cleanup (Phase 13)
- Update `DOCUMENTATION.md` to cover commissary features
- Update `AGENTS.md` if needed
- Consider removing or archiving `MERGE_PLAN.md` and this file once merge is validated

---

## Navigation Flow

```
App Start
  → AuthGateScreen
    → bootstrap()
    → if authenticated:
        → if user.isCommissary → /commissary-home (CommissaryHomeScreen)
        → else → /home (HomePage, franchisee/employee)
    → if unauthenticated → /login (LoginScreen)
        → HqAccessGate (floating lock icon, bottom-right)
          → access code dialog → verify PBKDF2 → /commissary-login
        → Normal login → signInToBranch() → /home
```

## Commissary Home Sidebar Items

1. **Dashboard** — placeholder overview
2. **Branches** — manage franchisee organizations + admin accounts
3. **Inventory Management** — items + ingredients CRUD with recipe management
4. **Requests** — approve/reject stock replenishment requests
5. **Reports** — cross-branch reporting
6. **Settings** — sync controls, connection status

---

## Project State

- **Compilation**: ✅ 0 errors
- **Warnings/Infos**: 322 (non-blocking)
- **Schema Version**: 5
- **Generated files**: Up to date (391 outputs from build_runner)
- **Package**: `chickenjoo_inventory`
- **Key dependency added**: `intl: ^0.20.2`
