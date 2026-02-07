# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

ChickenJoo Inventory is a Flutter inventory management app with offline-first architecture using Drift (SQLite) for local storage and Supabase for cloud sync/auth. It supports multiple platforms (Android, Windows, iOS, macOS, Linux, Web) with responsive mobile/desktop layouts.

## Build & Development Commands

```powershell
# Install dependencies
flutter pub get

# Generate Drift database code (required after modifying tables/DAOs)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for continuous code generation during development
dart run build_runner watch

# Run on specific platforms
flutter run -d windows
flutter run -d chrome
flutter run -d emulator-5554  # Android emulator
```

## Testing

```powershell
# Run all tests
flutter test

# Run single test file
flutter test test/daos/items_dao_test.dart

# Run tests with coverage
flutter test --coverage
```

## Linting

```powershell
flutter analyze
dart format lib/ test/
```

## Architecture

### Offline-First Data Flow
```
UI Screens → DAOs → Local Drift DB (SQLite) ↔ SupabaseSyncServiceV2 ↔ Supabase Cloud
```

### Key Architectural Patterns

1. **Dual ID System**: Every table has both `id` (local INTEGER) and `cloud_id` (UUID TEXT). Use local IDs for joins/foreign keys, cloud IDs for sync operations.

2. **DAO Pattern**: All database operations go through DAOs in `lib/database/daos/`. Each table has a corresponding DAO with CRUD operations.

3. **Sync Descriptors**: Table sync logic is defined in `lib/services/sync/descriptors/`. Each descriptor handles push/pull operations for one table.

4. **AppGlobals Singleton**: Access services via `database`, `syncService`, `authService` getters from `lib/app_globals.dart`.

5. **Responsive Layouts**: Screens have `_desktop.dart` and `_mobile.dart` variants selected at runtime based on screen width.

### Generated Files (Do Not Edit)
- `lib/database/app_database.g.dart`
- `lib/database/daos/*_dao.g.dart`
- `test/**/*.mocks.dart`

Regenerate with `dart run build_runner build --delete-conflicting-outputs`

## Environment Setup

Copy `.env.example` to `.env` and fill in Supabase credentials:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

## Key Files

- `lib/main.dart` - App entry point, initializes DB, Supabase, and services
- `lib/app_globals.dart` - Singleton for accessing database and services
- `lib/database/app_database.dart` - Drift database definition with all 11 tables
- `lib/services/supabase_sync_service_v2.dart` - Bi-directional sync engine
- `lib/services/supabase_auth_service.dart` - Authentication with UserData model

## Database Schema

11 tables: `organizations`, `roles`, `users`, `categories`, `items`, `ingredients`, `recipe_ingredients`, `branch_ingredient_stock`, `stock_replenishment_requests`, `stock_change_requests`, `daily_sales_summary`

When adding/modifying tables:
1. Define table in `lib/database/tables/`
2. Create DAO in `lib/database/daos/`
3. Register in `lib/database/app_database.dart` (`@DriftDatabase` annotation)
4. Run `dart run build_runner build --delete-conflicting-outputs`
5. Create sync descriptor in `lib/services/sync/descriptors/` if cloud sync needed

## Sync Considerations

- Sync uses `last_synced_at` and `last_modified_at` timestamps for conflict detection
- Star topology: Commissary syncs all data, franchisees sync only their organization's data
- Always update `last_modified_at` when modifying records locally
