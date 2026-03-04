# SE-101 + SE101-Commissary Merge — Implementation Plan

**Author:** GitHub Copilot  
**Date:** March 4, 2026  
**Status:** Planning — Do not code until all prerequisite decisions are resolved.

---

## Part 0 — Architecture Comparison

### What Both Apps Share (No Duplication Needed)
| Component | SE-101 | SE101-Commissary | Notes |
|---|---|---|---|
| `SupabaseSyncServiceV2` | ✅ | ✅ | SE-101 version is authoritative — already handles both org types |
| `SupabaseAuthService` | ✅ | ✅ | SE-101 is a **superset** — already has `signIn()`, `signInToBranch()`, `fetchAvailableBranches()`, `isCommissary`, `isFranchisee` |
| `RealtimeStockRequestService` | ✅ | ✅ | SE-101 version used |
| `ConnectivityService` | ✅ | ✅ | SE-101 version used |
| `AppGlobals` | ✅ | ✅ | SE-101 version used |
| `AppDatabase` | ✅ | ✅ | SE-101 is a superset (14 tables vs 11; has `SyncConflicts`, `BranchIngredientStock`) |
| Sync descriptors (all tables) | ✅ | ✅ | SE-101 also has `categories_descriptor.dart` that commissary lacks |
| `search_service.dart` | ✅ | ✅ | SE-101 version used |
| `AuthGateScreen` | ✅ | ✅ | Needs modification — see Phase 3 |
| `design_constants.dart` | ✅ | ✅ | SE-101 version used; commissary has minor differences (merge constants) |

### What Exists Only in SE101-Commissary (Must Be Transplanted)
| Screen / File | Purpose |
|---|---|
| `screens/login/login_screen.dart` | Commissary login (no branch selection, uses `signIn()`) |
| `screens/home/home_screen.dart` + desktop/mobile | Commissary dashboard shell with sidebar |
| `screens/branches/` (3 files) | Manage franchisee orgs + create branch admin accounts |
| `screens/inventory_management/` (6 files) | Full CRUD for commissary items and ingredients |
| `screens/requests/` (3 files) | View + approve/reject replenishment requests from branches |
| `screens/reports/reports_page.dart` | Commissary-scoped reports page |
| `screens/ingredients/ingredients_page.dart` | Ingredient management outer shell |
| `screens/inventory/inventory_page.dart` | Stock overview page |
| `screens/settings/settings_page.dart` | Commissary settings |
| `services/reports_service.dart` | Data layer for commissary reports |
| `services/supabase_auth_service.dart` → `createBranchAdminAuthUser()` | Creates Supabase Auth accounts for branch admins |

### What Exists Only in SE-101 (Franchisee-Specific — No Change Needed)
| Screen | Purpose |
|---|---|
| `screen/franchisee/franchisee_reports/` | Franchisee branch reports |
| `screen/franchisee/franchisee_inventory/` | Branch stock replenishment requests |
| `screen/franchisee/franchisee_items/` | Branch items list |
| `screen/franchisee/franchisee_employee/` | Branch employee management |
| `screen/franchisee/franchisee_products_view/` | Read-only commissary product catalog |
| `screen/employee/` | Restricted employee views |

### Key Architectural Insight
SE-101's auth service already has `signIn()` (used by commissary) as a separate method from `signInToBranch()` (used by franchisees). `UserData.isCommissary` is already defined. `fetchAvailableBranches()` already filters `.eq('type', 'franchisee')`. SE-101 is structurally ready — only the commissary UI screens, the HQ gate, and `createBranchAdminAuthUser()` are missing.

---

## Part 0.5 — Prerequisite Decisions ✅ All Resolved

### Decision 1: HQ Access Code Storage Location
**✅ RESOLVED — Option A chosen.**

Add `hq_access_code_hash TEXT` to the `organizations` table in Supabase. The app reads it by querying `organizations WHERE type = 'commissary' LIMIT 1` before showing the access code prompt. Reuses the existing organizations sync pipeline; no new Supabase table needed.

### Decision 2: Supabase Migration for Decision 1
**✅ RESOLVED — Run the following migration before coding Phase 3.**

Step 1 — Add the column:
```sql
ALTER TABLE organizations ADD COLUMN hq_access_code_hash TEXT;
```
Step 2 — Generate the hash using `AppDatabase.hashPassword(yourChosenCode)` (run locally or in a test), then set it:
```sql
UPDATE organizations
SET hq_access_code_hash = '<PBKDF2_hash_of_code>'
WHERE type = 'commissary';
```
The plaintext code is never stored anywhere. The Supabase migration must be run and verified before Phase 4 (HqAccessGate) can be tested.

### Decision 3: Commissary admin route after login
**✅ RESOLVED — Separate `/commissary-home` route.**

The transplanted `CommissaryHomeScreen` gets its own `/commissary-home` named route. The franchisee `/home` route and `HomeScreen` are untouched. This keeps both flows fully isolated and avoids any risk of franchisee regressions.

### Decision 4: Auth gate routing for commissary users
**✅ RESOLVED — Confirmed as part of Decision 3.**

`AuthGateScreen` will branch on `currentUser.isCommissary`: commissary users are routed to `/commissary-home`, franchisee users to `/home`. A small targeted change to `auth_gate_screen.dart` handles this (Phase 8).

---

## Part 1 — File Inventory

### 1.1 Files to Copy Verbatim (then update imports)
All source: `SE101-COmmissary/lib/` → target: `SE_101/lib/`

| Source Path | Target Path in SE-101 |
|---|---|
| `screens/login/login_screen.dart` | `screen/commissary/login/commissary_login_screen.dart` |
| `screens/auth/auth_gate_screen.dart` | *(do NOT copy — SE-101's already exists)* |
| `screens/home/home_screen.dart` | `screen/commissary/home/commissary_home_screen.dart` |
| `screens/home/home_screen_desktop.dart` | `screen/commissary/home/commissary_home_screen_desktop.dart` |
| `screens/home/home_screen_mobile.dart` | `screen/commissary/home/commissary_home_screen_mobile.dart` |
| `screens/branches/branches_page.dart` | `screen/commissary/branches/branches_page.dart` |
| `screens/branches/branches_page_desktop.dart` | `screen/commissary/branches/branches_page_desktop.dart` |
| `screens/branches/branches_page_mobile.dart` | `screen/commissary/branches/branches_page_mobile.dart` |
| `screens/inventory_management/inventory_management_page.dart` | `screen/commissary/inventory_management/inventory_management_page.dart` |
| `screens/inventory_management/inventory_management_page_desktop.dart` | `screen/commissary/inventory_management/inventory_management_page_desktop.dart` |
| `screens/inventory_management/inventory_management_page_mobile.dart` | `screen/commissary/inventory_management/inventory_management_page_mobile.dart` |
| `screens/inventory_management/ingredients_tab.dart` | `screen/commissary/inventory_management/ingredients_tab.dart` |
| `screens/inventory_management/products_tab.dart` | `screen/commissary/inventory_management/products_tab.dart` |
| `screens/inventory_management/widgets/` (all files) | `screen/commissary/inventory_management/widgets/` |
| `screens/requests/requests_page.dart` | `screen/commissary/requests/requests_page.dart` |
| `screens/requests/requests_page_desktop.dart` | `screen/commissary/requests/requests_page_desktop.dart` |
| `screens/requests/requests_page_mobile.dart` | `screen/commissary/requests/requests_page_mobile.dart` |
| `screens/reports/reports_page.dart` | `screen/commissary/reports/reports_page.dart` |
| `screens/ingredients/ingredients_page.dart` | `screen/commissary/ingredients/ingredients_page.dart` |
| `screens/inventory/inventory_page.dart` | `screen/commissary/inventory/inventory_page.dart` |
| `screens/settings/settings_page.dart` | `screen/commissary/settings/settings_page.dart` |
| `services/reports_service.dart` | `services/reports_service.dart` |

### 1.2 New Files to Create (Not Copied from Either App)
| File | Purpose |
|---|---|
| `screen/commissary/login/hq_access_gate.dart` | Widget: HQ button on branch selection screen + access code dialog |

### 1.3 Files to Modify in SE-101
| File | What Changes |
|---|---|
| `lib/app.dart` | Add `/commissary-login` and `/commissary-home` routes |
| `lib/screen/auth/auth_gate_screen.dart` | Route commissary users to `/commissary-home` instead of `/home` |
| `lib/screen/login/login_screen.dart` | Add discrete HQ button |
| `lib/screen/login/widgets/login_scaffold_desktop.dart` | Render HQ button in corner |
| `lib/screen/login/widgets/login_scaffold_mobile.dart` | Render HQ button in corner |
| `lib/services/supabase_auth_service.dart` | Add `createBranchAdminAuthUser()` from commissary |
| Each transplanted commissary screen | Update all imports to `chickenjoo_inventory` package |

---

## Part 2 — Phase-by-Phase Steps

---

### Phase 1: Prerequisite Decisions + Supabase Prep
**Do this before any code changes.**

**Step 1.1 — Resolve all four decisions in Part 0.5.**  
Document the chosen option for each before proceeding.

**Step 1.2 — Run the chosen Supabase migration.**  
If Option A is chosen for the access code:
1. Open Supabase SQL Editor.
2. Run the `ALTER TABLE` migration to add `hq_access_code_hash` to `organizations`.
3. Generate the hash of the desired access code using the in-app `hashPassword()` function (run it locally or in a test), then run the `UPDATE` statement to set it on the commissary row.
4. Verify the hash is set correctly: `SELECT hq_access_code_hash FROM organizations WHERE type='commissary'` — must return a non-null value.

**Step 1.3 — Verify SE-101 `fetchAvailableBranches` filter.**  
Confirm the query already uses `.eq('type', 'franchisee')`. (From the code review: it does. No change needed. The commissary organization will never appear in the branch list.)

---

### Phase 2: Add `createBranchAdminAuthUser()` to SE-101 Auth Service
**File:** `SE_101/lib/services/supabase_auth_service.dart`

**Step 2.1** — Open `SE101-COmmissary/lib/services/supabase_auth_service.dart` and locate `createBranchAdminAuthUser()` (lines ~727–797) and `deleteAuthUser()` and `updateUserPassword()` which are commissary-admin-only helpers.

**Step 2.2** — Copy these three methods into SE-101's `supabase_auth_service.dart`, in the section labelled `ADMIN FUNCTIONS FOR MANAGING BRANCH USERS`.

**Step 2.3** — The methods use only `_supabase`, `_currentUser`, `_authStateController`, and `_logAuth()` — all of which already exist in SE-101's auth service. No new fields are needed.

**Step 2.4** — Verify no import changes are needed (all dependencies are already imported in SE-101's auth service).

---

### Phase 3: Add HQ Access Code Storage to `organizations` table in Local DB
**This step is only needed if Option A is chosen in Phase 1.**

**Step 3.1** — Open `SE_101/lib/database/tables/organizations.dart`.

**Step 3.2** — Add a nullable `TextColumn` called `hqAccessCodeHash` with JSON key `hq_access_code_hash`:
```dart
TextColumn get hqAccessCodeHash => text().nullable().withDefault(const Constant(''))();
```

**Step 3.3** — Increment `schemaVersion` in `SE_101/lib/database/app_database.dart` (currently at N, set to N+1).

**Step 3.4** — Add an `onUpgrade` migration branch that runs `ALTER TABLE organizations ADD COLUMN hq_access_code_hash TEXT` (or uses Drift's `m.addColumn`).

**Step 3.5** — Add `hqAccessCodeHash` to `OrganizationsDao` — this column must be included in the `fromCloudRecord()` (sync pull) mapping for the organization. Verify `organizations_descriptor.dart` includes this field so it is pulled from Supabase on sync.

**Step 3.6** — Run `dart run build_runner build --delete-conflicting-outputs` after all table edits.

---

### Phase 4: Create the HQ Access Gate Widget
**New file:** `SE_101/lib/screen/commissary/login/hq_access_gate.dart`

This file is a self-contained widget, not copied from commissary. Write it from scratch (it is small — only ~60 lines):

**Step 4.1** — Create a `HqAccessGate` `StatefulWidget`.

**Step 4.2** — The widget exposes a small icon button (e.g., `Icons.admin_panel_settings` or `Icons.lock`, sized ~20pt, placed as a floating overlay on the login scaffold). It must be visually subtle — no tooltip, no label.

**Step 4.3** — When tapped, show a modal dialog with a single `TextFormField` (obscured, labelled generically — do NOT use "Admin" or "Commissary" in the label). Add "Cancel" and "Confirm" buttons.

**Step 4.4** — On "Confirm", call a method `_verifyAndNavigate(String enteredCode)`:  
1. Fetch `hq_access_code_hash` from local DB: `database.organizationsDao.getCommissaryOrg()` (add this helper to `OrganizationsDao` if it does not exist — query by `type = 'commissary' LIMIT 1`).
2. If the local DB has no commissary record yet (first launch before sync), attempt an online fetch: `supabase.from('organizations').select('hq_access_code_hash').eq('type','commissary').limit(1)`.
3. Compare `AppDatabase.verifyPassword(enteredCode, storedHash)` (the same function used for offline login).
4. If match: close dialog + `Navigator.pushNamed(context, '/commissary-login')`.
5. If no match: show a generic error message ("Incorrect code.") with no hint about what the code protects. Do NOT reveal the dialog is for admin access.

**Step 4.5** — The dialog must be dismissed silently (no log output, no toast) on wrong code — only a subtle inline error text inside the dialog itself.

---

### Phase 5: Add HQ Button to Login Scaffolds
**Files:**  
- `SE_101/lib/screen/login/widgets/login_scaffold_desktop.dart`  
- `SE_101/lib/screen/login/widgets/login_scaffold_mobile.dart`

**Step 5.1** — In `login_scaffold_desktop.dart`, wrap the existing `Scaffold` body in a `Stack`, and as the last child of the `Stack` add:
```dart
Positioned(
  bottom: 12,
  right: 12,
  child: HqAccessGate(),
)
```

**Step 5.2** — In `login_scaffold_mobile.dart`, do the same — `Stack` wrapping the existing content with `HqAccessGate` positioned at `bottom: 12, right: 12`.

**Step 5.3** — Import `hq_access_gate.dart` in both scaffold files.

**Step 5.4** — Verify the button does not overlap the branch dropdown or login form on any screen size. Test at 360×640 (minimum Android), 1280×720 (minimum desktop).

---

### Phase 6: Transplant Commissary Screens
Copy all files listed in Part 1.1 from SE101-Commissary to SE-101 using the target paths shown.

**Step 6.1 — Create the target folder structure:**
```
SE_101/lib/screen/commissary/
  login/
  home/
  branches/
  inventory_management/
    widgets/
  requests/
  reports/
  ingredients/
  inventory/
  settings/
```

**Step 6.2 — Copy all files** listed in the file inventory table (Part 1.1).

**Step 6.3 — Import fix pass (Critical).**  
Every copied file uses relative imports (e.g., `../../services/reports_service.dart`, `../../app_globals.dart`, `../../utils/design_constants.dart`) and possibly `package:commissary_app/...` references. These must be updated to `package:chickenjoo_inventory/...` absolute imports.

Do a find-and-replace sweep for:
- `../../services/` → `package:chickenjoo_inventory/services/`
- `../../database/` → `package:chickenjoo_inventory/database/`
- `../../app_globals.dart` → `package:chickenjoo_inventory/app_globals.dart`
- `../../utils/design_constants.dart` → `package:chickenjoo_inventory/utils/design_constants.dart`
  - ⚠️ SE-101 has `design_constants.dart` at `lib/design_constants.dart` (root level) AND at `lib/utils/design_constants.dart`. Verify which path to use — `lib/utils/design_constants.dart` is the correct one for the transplanted files.
- `package:commissary_app/` → `package:chickenjoo_inventory/`
- Any `screens/` path references → `screen/commissary/`

For the commissary home screen variants (`commissary_home_screen_desktop.dart`, `commissary_home_screen_mobile.dart`): they import the `HomeScreenState` class from `home_screen.dart`. After renaming, update that class name to `CommissaryHomeScreenState` and update all references accordingly.

**Step 6.4 — Rename class names for clarity** to avoid collisions with existing SE-101 classes:

| Old Class Name | New Class Name |
|---|---|
| `HomeScreen` (commissary) | `CommissaryHomeScreen` |
| `HomeScreenState` (commissary) | `CommissaryHomeScreenState` |
| `HomeScreenDesktop` (commissary) | `CommissaryHomeScreenDesktop` |
| `HomeScreenMobile` (commissary) | `CommissaryHomeScreenMobile` |
| `LoginScreen` (commissary) | `CommissaryLoginScreen` |
| `SettingsPage` (commissary) | `CommissarySettingsPage` |
| `ReportsPage` (commissary) | `CommissaryReportsPage` |

All franchisee classes keep their current names unchanged.

---

### Phase 7: Add New Routes in `app.dart`
**File:** `SE_101/lib/app.dart`

**Step 7.1** — Add imports for the new commissary screens at the top of `app.dart`:
```dart
import 'screen/commissary/login/commissary_login_screen.dart';
import 'screen/commissary/home/commissary_home_screen.dart';
```

**Step 7.2** — Add two entries to the `routes` map:
```dart
'/commissary-login': (context) => const CommissaryLoginScreen(),
```

**Step 7.3** — Add a case in `onGenerateRoute` for `/commissary-home`:
```dart
if (settings.name == '/commissary-home') {
  final userData = settings.arguments as UserData?;
  if (userData == null) {
    return MaterialPageRoute(builder: (context) => const CommissaryLoginScreen());
  }
  // Reinitialize sync for commissary org context
  reinitializeSyncWithUserContext(userData);
  return MaterialPageRoute(
    builder: (context) => CommissaryHomeScreen(signedInUser: userData),
  );
}
```

**Step 7.4** — The commissary login screen navigates to `/commissary-home` on successful login (not `/home`). This requires updating `CommissaryLoginScreen._handleLogin()` to call:
```dart
Navigator.pushReplacementNamed(context, '/commissary-home', arguments: result.localUser);
```

---

### Phase 8: Modify `AuthGateScreen` for Commissary Routing
**File:** `SE_101/lib/screen/auth/auth_gate_screen.dart`

**Step 8.1** — In `_navigateBasedOnState()`, the current logic routes all authenticated users to `/home`. Change it to branch on `userData.isCommissary`:

```dart
void _navigateBasedOnState(AuthLifecycleState state) {
  if (_hasNavigated || !mounted) return;
  _hasNavigated = true;

  if (state == AuthLifecycleState.authenticated && _authService.currentUser != null) {
    final user = _authService.currentUser!;
    if (user.isCommissary) {
      _navigateToCommissaryHome(user);
    } else {
      _navigateToHome(user);
    }
  } else {
    _navigateToLogin();
  }
}

void _navigateToCommissaryHome(UserData user) {
  Navigator.pushReplacementNamed(context, '/commissary-home', arguments: user);
}
```

**Step 8.2** — Verify that on logout from the commissary home screen, `Navigator.pushNamedAndRemoveUntil(context, '/login', ...)` is used (routing back to the franchisee login screen, which has the HQ button). This is intentional — the commissary admin must use the HQ button again if they need to re-login.

---

### Phase 9: Wire TransplantedCommissary Screens to SE-101 Services
Several commissary screens directly access `AppGlobals`, `database`, `syncService`, and `authService` via the top-level convenience getters. Since SE-101 already has these with identical signatures, no wiring changes are needed beyond the import fixes in Phase 6.

**Step 9.1 — Verify `RealtimeStockRequestService` is wired to `CommissaryHomeScreen`.**  
The commissary `RequestsPage` uses `AppGlobals.instance.realtimeStockRequestService`. This is already initialized in SE-101's `main.dart`. Confirm `realtimeStockRequestService.attach(commissaryCloudId)` is called with the correct ID when the commissary user logs in. The `attach()` call currently happens in `RequestsPage._loadContext()` using `AppGlobals.instance.authService.currentUser`. This is fine — no change needed.

**Step 9.2 — Verify `reports_service.dart` database references.**  
`ReportsService` uses `AppGlobals.instance.database` (or direct DAO calls). Confirm all table/DAO references resolve against SE-101's `AppDatabase` — they should, since SE-101 has all the tables the commissary had.

**Step 9.3 — Verify commissary screens do not reference BranchItemStockDao.
BranchItemStock is a SE-101 franchisee-exclusive table that tracks finished product stock per branch (e.g., 100 chickens at Branch A). Commissary screens should never reference it — ingredients and supply are managed at the commissary level only, not per branch. Scan all transplanted commissary screens for any BranchItemStockDao references. If any are found, this is a red flag that the screen is incorrectly reaching into branch-level data. Remove or replace the reference with the appropriate commissary-level DAO instead.

---

### Phase 10: Code Generation
**Run after Phase 6 (table changes) and after all `.g.dart` dependencies are in place.**

```powershell
cd "C:\RJ\Coding\FlutterProjects\SE_101"
dart run build_runner build --delete-conflicting-outputs
```

Expected outputs:
- Regenerated `lib/database/app_database.g.dart`
- Regenerated `lib/database/daos/*.g.dart`

If you see `Too many positional arguments` or `Undefined name` errors, they indicate an import collision or class name conflict introduced in Phase 6. Fix before proceeding.

---

### Phase 11: Compile Check + Error Triage
```powershell
flutter analyze
```

**Expected error categories and resolutions:**

| Error Pattern | Likely Cause | Resolution |
|---|---|---|
| `Target of URI doesn't exist` | Old relative import still in a transplanted file | Re-run import fix pass (Phase 6.3) |
| `The getter 'homeScreenState' isn't defined` | Commissary desktop/mobile file still references old class name | Apply class rename from Phase 6.4 |
| `Undefined class 'SettingsPage'` | Name collision between commissary and franchisee | Confirm class rename applied (`CommissarySettingsPage`) |
| `'ReportsPage' is already defined` | Same | Apply class rename (`CommissaryReportsPage`) |
| `Method not found: 'getCommissaryOrg'` | DAO helper not added | Add it to `OrganizationsDao` |
| `schemaVersion` mismatch errors | Drift migration missing | Verify Phase 3 steps |
| `Too many elements` / null safety | DAO method signature differs from commissary version | Copy missing DAO methods or fix null handling |

---

### Phase 12: Integration Testing Checklist
Perform these manual tests before considering the merge complete.

#### Franchisee Flow (must be 100% unchanged)
- [ ] App launches, shows branch selection screen with franchisee branches only
- [ ] Commissary organization does NOT appear in the branch list
- [ ] Franchisee can log in normally and reach `HomeScreen`
- [ ] All franchisee menu items (Reports, Products, Inventory, Employee, Account) still function
- [ ] Franchisee logout returns to login screen
- [ ] Session restore (re-open app while logged in as franchisee) routes to `/home`

#### HQ Button Flow
- [ ] A small, unlabelled button is visible in the corner of the login screen (desktop + mobile)
- [ ] Tapping the button shows an access code dialog
- [ ] Entering a wrong code shows a generic error within the dialog; no navigation occurs
- [ ] Entering the correct code navigates to `/commissary-login` (CommissaryLoginScreen)

#### Commissary Login Flow
- [ ] CommissaryLoginScreen shows the commissary login form (no branch dropdown)
- [ ] Entering a valid commissary admin email + password logs in and routes to `/commissary-home`
- [ ] Entering invalid credentials shows an error message
- [ ] Back navigation from `CommissaryLoginScreen` returns to the franchisee login screen
- [ ] Session restore (re-open app while logged in as commissary admin) routes to `/commissary-home`

#### Commissary Dashboard
- [ ] `CommissaryHomeScreen` renders with the sidebar: Dashboard, Branches, Inventory, Requests, Reports, Settings
- [ ] Each sidebar item navigates to the correct screen
- [ ] `BranchesPage` loads and displays franchisee organizations
- [ ] Creating a new branch admin account calls `createBranchAdminAuthUser()` and does not sign out the commissary admin (race condition awareness from audit)
- [ ] `RequestsPage` loads pending replenishment requests
- [ ] Approving a request updates the status and triggers sync
- [ ] `CommissaryReportsPage` loads without error
- [ ] `CommissarySettingsPage` loads without error
- [ ] `InventoryManagementPage` loads and CRUD operations work
- [ ] Logout from commissary home returns to the main login screen

#### Sync Validation
- [ ] After commissary login, sync sets organization context as `type='commissary'`
- [ ] Full sync pulls all tables (organizations, roles, users, categories, items, ingredients, recipe_ingredients, branch_item_stock, stock_replenishment_requests, stock_change_requests, daily_sales_summary)
- [ ] Franchisee sync is unaffected (test on a second device/session)

---

## Part 3 — Files NOT Needed from SE101-Commissary

The following files from SE101-Commissary are **not transplanted** because SE-101 already has equivalent or superior versions:

| File | Reason |
|---|---|
| `lib/app.dart` | SE-101's `app.dart` is extended, not replaced |
| `lib/main.dart` | SE-101's `main.dart` is the entry point, not replaced |
| `lib/app_globals.dart` | SE-101's version is used |
| `lib/database/` (all) | SE-101's database is a superset |
| `lib/services/supabase_sync_service_v2.dart` | SE-101's version used |
| `lib/services/supabase_auth_service.dart` | SE-101's version extended (Phase 2 only) |
| `lib/services/connectivity_service.dart` | SE-101's version used |
| `lib/services/realtime_stock_request_service.dart` | SE-101's version used |
| `lib/services/search_service.dart` | SE-101 already has this |
| `lib/screens/auth/auth_gate_screen.dart` | SE-101's version is modified, not replaced |
| All `*.g.dart` files | Regenerated by build_runner |
| `lib/utils/sync_status.dart` | SE-101 already has `utils/sync_status.dart` |
| `lib/config/` | SE-101 already has Supabase config |

---

## Part 4 — Risk Register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Import collisions (`SettingsPage`, `ReportsPage` defined twice) | High | Build error | Apply all class renames in Phase 6.4 before running `flutter analyze` |
| `design_constants.dart` path mismatch (commissary uses `utils/`, SE-101 root has one too) | Medium | Build error | Use `package:chickenjoo_inventory/utils/design_constants.dart` consistently in all transplanted files |
| HQ button overlaps UI elements on small screens | Medium | UX issue | Use `SafeArea` + test at 360×640 |
| Session not restored correctly for commissary on restart | Medium | Auth failure | Verify `AuthGateScreen` changes in Phase 8 route to `/commissary-home` for commissary users |
| `BranchItemStockDao` method signature mismatch | Low | Runtime error | Manual comparison of DAO methods (Phase 9.3) |
| Access code hash not set in Supabase | Low | Gate never works | Verify during Phase 1.2 with a SELECT query |
| build_runner conflict from schema version bump | Low | Generation error | Pass `--delete-conflicting-outputs` flag |

---

## Summary — Implementation Order

```
Phase 1:  Supabase prep + decisions
Phase 2:  Add createBranchAdminAuthUser to SE-101 auth service
Phase 3:  Add hq_access_code_hash to organizations table (Drift schema)
Phase 4:  Create HqAccessGate widget
Phase 5:  Add HQ button to login scaffolds
Phase 6:  Transplant all commissary screens + import fix pass + class renames
Phase 7:  Add new routes to app.dart
Phase 8:  Modify auth_gate_screen.dart for commissary routing
Phase 9:  Wire verification (DAOs, realtime service, reports service)
Phase 10: Run build_runner
Phase 11: flutter analyze + error triage
Phase 12: Integration testing
```

**Estimated complexity:** Phases 1–9 are all mechanical copy/rename operations with no new logic. Phase 4 (HqAccessGate) is the only net-new logic (~60 lines). The largest risk is import path fixing in Phase 6 — this should be done with find-and-replace, not manually line-by-line.
