# SE-101 Issues Review (Migration 012 = Current State)

> Migrations are cumulative upgrades — the highest number is the active state.
> Each issue below reflects what is **currently active** after replaying all migrations in order.

---

## ✅ Issues That Are Actually Resolved

**Issue (from prior review) — `organizations_star_insert` blocking commissary self-insert:**
Migration 003 rewrites this policy and explicitly adds `OR cloud_id = get_current_user_organization_id()`. **Already fixed.**

---

## 🔐 RLS Policy Issues

**1. `users_self_link_auth` allows privilege escalation** *(New in migration 011 — still active)*
- `USING (email = auth.email()) WITH CHECK (email = auth.email())` only locks the email column. It does NOT prevent the user from modifying their own `role_id` or `organization_id`. A franchisee user could call the Supabase REST API directly and promote themselves to a commissary admin role.

**2. `organizations_anon_select` exposes commissary organizations to anonymous users**
- Migration 002 restricts anon access to `type = 'franchisee' AND is_active = true`.
- Migration 003 **replaces this** with simply `USING (is_active = true)` — no type filter. Anonymous users (e.g. the login screen dropdown) can now also read commissary organization records.

**3. `branch_item_stock` SELECT policy has a dangerous `::UUID` cast** *(Migration 008 — still active)*
- `is_in_commissary_network(organization_id::UUID)` — if any `organization_id` value is not a valid UUID (e.g. malformed data), Postgres throws a cast error and breaks the SELECT for the entire commissary.

**4. `stock_change_requests` UPDATE policy blocks commissary** *(Migration 002 — never overridden)*
- No later migration touches this table's UPDATE policy. It remains `NOT is_commissary_user()`, meaning the commissary can never approve/reject change requests via the API. This blocks any future commissary-side approval workflow.

**5. `roles_star_select` has no `TO authenticated` restriction** *(Migration 002 — never overridden)*
- `FOR SELECT USING (true)` with no role restriction. Anonymous users can read the full roles table, including all permission flags.

---

## 🔄 Sync Issues

**6. `_buildAllCaches()` is missing 5 tables** *(sync_engine.dart)*
- Caches for `branch_item_stock`, `branch_ingredient_stock`, `daily_sales_summary`, `stock_replenishment_requests`, and `stock_change_requests` are never built. Any entries added via `updateCache()` during a push are silently wiped on every `rebuildAllCaches()` call because those tables are not included in the rebuild loop.

**7. Pull has no pagination — records are silently dropped** *(sync_engine.dart)*
- A single query with `.order('last_updated', ascending: false).limit(pullLimit)` means if cloud rows exceed `pullLimit`, the oldest records are permanently skipped on every sync cycle. There is no cursor/offset logic to fetch subsequent pages.

**8. Individual sync methods bypass the `_syncCompleter` lock** *(supabase_sync_service_v2.dart)*
- Methods like `syncStockReplenishmentRequests()`, `syncBranchItemStock()`, etc. only check `_isSyncing`. There is a race window where `_syncCompleter` is set but `_isSyncing` has not yet been toggled, allowing concurrent execution with `syncAll()`.

**9. `_pullUserFromCloud` stores auth UID as user `cloudId`** *(supabase_auth_service.dart)*
- The local user record is saved with `cloudId = authUser.id` (the Supabase Auth UUID). On the next `_syncUsers` push, this is sent as `cloud_id` to the `users` table, which does not match the actual row's `cloud_id` in Supabase, risking a duplicate user row being created.

**10. Duplicate `daily_sales_summary` descriptor**
- Both `daily_sales_descriptor.dart` (`dailySalesDescriptor`) and `daily_sales_summary_descriptor.dart` (`dailySalesSummaryDescriptor`) exist for the same table with different field mappings. The barrel file `sync.dart` exports the old one; the sync service uses the new one. Dead code with divergent mappings is a regression risk.

---

## 📊 Data Flow Issues

**11. Password hash is pushed to Supabase cloud** *(supabase_sync_service_v2.dart)*
- `_syncUsers` `toMap` includes `'password': user.password`. The bcrypt/SHA hash is synced to the cloud `users` table. This is unnecessary since Supabase Auth already holds the credential — storing password hashes in a third-party cloud database increases the blast radius of any cloud data breach.

**12. `RealtimeStockRequestService.resume()` never restores commissary subscriptions** *(realtime_stock_request_service.dart)*
- `resume()` checks `_franchiseeCloudId != null`. `attachAsCommissary()` explicitly sets `_franchiseeCloudId = null`, so this condition is always false for commissary screens. After the app is backgrounded and foregrounded, the commissary's realtime channel is never re-opened.

**13. `_reloadParentCommissaryId` silently picks an arbitrary commissary on fallback** *(supabase_sync_service_v2.dart)*
- The final fallback is `getAllOrganizations(type: 'commissary').first`. If more than one commissary record is present in the local DB (cross-network pollution or test data), the wrong parent commissary is assigned, silently corrupting all subsequent sync filters for that session.

**14. `daily_sales_summary` has no commissary INSERT/UPDATE RLS policy** *(Migration 005 — never updated)*
- Only branch-scoped INSERT/UPDATE policies exist. Since `canPush: (orgType) => true` on the descriptor, the sync service will attempt to push commissary-owned summaries and receive a 42501 RLS rejection. The error is swallowed by the retry loop, and the records remain stuck as unsynced forever with no user-visible indication.
