# Solutions 1

**Project:** Inventory Cross-Platform Offline-First Flutter Application  
**Date:** February 22, 2026  
**Reference:** Application Issues 1.md  
**Total Issues:** 16 | **Recommended Solution Per Issue:** 1 (with reasoning)

---

## Critical Note on Order of Fixes

Do not fix performance before fixing correctness. Attempting to optimize a broken sync flow
will waste time. Follow this order:

1. Fix auth lifecycle first — removes 401 noise so real errors become visible
2. Fix sync correctness — stops retry loops that cascade into performance problems
3. Fix socket and query lifecycle — eliminates pile-up of open connections and queries
4. Fix UI rebuild churn — only becomes properly fixable after the data flow is clean

---

## Step-By-Step Plan

**Step 1 — Lock Baseline and Metrics First**  
Files: `Application Issues 1.md`, `README.md` (or `DOCUMENTATION.md`), `devtools_options.yaml`

**Step 2 — Add Temporary Diagnostics Guards**  
Identify which subsystem causes each spike (sync, realtime, auth, UI rebuilds).  
Files: `main.dart`, `supabase_sync_service_v2.dart`, `realtime_stock_request_service.dart`, `app.dart`

**Step 3 — Fix Auth/Session Lifecycle First**  
Remove 401 noise before performance work begins.  
Files: `supabase_auth_service.dart`, `main.dart`, `app.dart`, `supabase_sync_service_v2.dart`

**Step 4 — Fix Sync Data Correctness Blockers (Issues 3, 4, 9)**  
Stop retries and loops caused by failing syncs.  
Files: `daily_sales_summary_descriptor.dart`, `stock_requests_descriptor.dart`, `daily_sales_summary_dao.dart`, `stock_change_requests_dao.dart`, `supabase_sync_service_v2.dart`, `sync_engine.dart`

**Step 5 — Fix Websocket/Channel Lifecycle Leaks (Issue 10)**  
Files: `realtime_stock_request_service.dart`, `replenish_stock_tab.dart`

**Step 6 — Reduce Idle Polling/Query Pressure (Issues 11 and 12)**  
Files: `main.dart`, `supabase_sync_service_v2.dart`, `sync_helper.dart`, `app.dart`

**Step 7 — Reduce UI Rebuild/Repaint Churn (Issues 1, 7, 13, 14, 15)**  
Files: `main.dart`, `home.dart`, `franchisee_inventory.dart`, `employee_items.dart`, `realtime_status_indicator.dart`

**Step 8 — Add Regression Tests**  
Cover sync mapping, socket lifecycle, and auth refresh behavior.  
Files: `supabase_sync_service_v2_test.dart`, `realtime_stock_request_service_test.dart`, `supabase_auth_service_test.dart`, `stock_change_requests_dao_test.dart`, `daily_sales_summary_dao_test.dart`

**Step 9 — Run Profiling Pass After Each Phase**  
Compare against baseline across CPU, frame, memory, network, and socket count.  
Files: `Application Issues 1.md` (results section)

**Step 10 — Apply Same Hardening to Commissary**  
Apply realtime/sync hardening where code patterns are mirrored.  
Files: `realtime_stock_request_service.dart`, `supabase_sync_service_v2.dart`

---

## Per-Issue Recommended Solutions

---

### Issue 1 — TimerSignificantlyOverdue (UI Blocking 600ms+)

**Recommended: Solutions B + C together**

Move heavy aggregation, count, and status computations to a background isolate boundary,
AND prevent duplicate sync engine initialization at the same time. Solution A (throttling
logs) treats the symptom not the cause and should only be done as a supplementary step.
Solution B is the correct permanent fix since heavy computation should never run on the
main thread. Solution C is likely contributing significantly to the problem because
duplicate initialization means the sync engine is doing double the work on the main thread.

Files: `supabase_sync_service_v2.dart`, `app.dart`, `main.dart`, count DAOs used by sync status

---

### Issue 2 — 401 Unauthorized GET Requests

**Recommended: Solutions A + C together. Implement B with caution.**

Add a central auth gate so sync and realtime only start after a confirmed valid session,
AND immediately stop sync and close channels on auth loss. These two together form a
complete auth lifecycle — one guards the entry, the other guards the exit. Solution B
(refresh before every request) is risky if implemented naively because it adds latency to
every single request. If implemented, refresh proactively when the token is near expiry
rather than reactively on every call.

Files: `supabase_auth_service.dart`, `main.dart`, `app.dart`, `supabase_sync_service_v2.dart`, `realtime_stock_request_service.dart`

---

### Issue 3 — daily_sales_summary Sync Fails (Too Many Elements)

**Recommended: Solutions A + C together. Use B only as a temporary bridge.**

Enforce cloud ID uniqueness in the local table AND change the conflict key to a business
key (organizationId, itemId, summaryDate). These two together form the correct long-term
fix. Solution B (tolerate duplicates with first/latest) is acceptable only as a temporary
measure while A and C are being implemented. Do not use B long-term as it will silently
serve wrong data to users.

Files: `daily_sales_summary.dart`, `app_database.dart`, `daily_sales_summary_dao.dart`, `daily_sales_summary_descriptor.dart`, `supabase_sync_service_v2.dart`

---

### Issue 4 — stock_change_requests Sync Fails (Null Not Subtype of int)

**Recommended: All three solutions, in order A → B → C**

Make local/cloud ID nullable-safe in the DAO first, then add null guards in the descriptor
mapping as a defensive layer, then add structured error handling to skip malformed rows
safely. All three are needed and each covers a different layer. One important caveat on
Solution C — make sure skipped rows are logged clearly and visibly. Silently skipping bad
rows causes data gaps that may not be noticed until much later in production.

Files: `stock_change_requests_dao.dart`, `stock_requests_descriptor.dart`, `sync_engine.dart`, `supabase_sync_service_v2.dart`

---

### Issue 5 — 242 HTTP Requests/Responses Retained in Memory

**Recommended: Solutions in order A → C → B**

Stop request storms at root cause first. All other memory solutions here are secondary if
requests are still firing unnecessarily. Adding debounce (C) to a broken flow still gives
you a broken flow, just slower. Reducing payload size (B) is a good practice and easy win
but will not meaningfully reduce the 242 retained responses if the request storm is not
stopped first.

Files: `app.dart`, `main.dart`, `supabase_sync_service_v2.dart`, `sync_helper.dart`, `realtime_sales_service.dart`, `realtime_stock_request_service.dart`, `sync_engine.dart`

---

### Issue 6 — 226 Drift Queries Active Simultaneously

**Recommended: Solutions A + B together**

Collapse 9 count queries into one batched query AND prevent overlapping syncAll() calls.
These two are the real fixes. Solution C (hard cap on concurrent tasks) is useful for
monitoring during the fix process but is a workaround — artificially limiting damage
instead of fixing the cause. Invest in A and B properly.

Files: `supabase_sync_service_v2.dart`, `realtime_stock_request_service.dart`, `main.dart`, unsynced count DAO methods

---

### Issue 7 — Excessive UI Repainting (paintWithContext at 110% CPU)

**Recommended: Solutions A + B together, then C**

Replace broad ValueNotifier with fine-grained notifiers first — this is the correct
architectural fix. A single `ValueNotifier<Map<String,dynamic>>` that updates frequently
will repaint everything that listens to it. Then add debouncing of sync status emissions
(B) as a quick and effective supplementary measure. Solution C (RepaintBoundary and const
widgets) is good practice but lowest impact and will not matter much if A is not fixed
first.

Files: `main.dart`, `home.dart`, `supabase_sync_service_v2.dart`, `realtime_status_indicator.dart`, `replenish_stock_tab.dart`, screens where sync status is shown

---

### Issue 8 — High Idle Memory Usage (~400MB)

**Recommended: Solution C immediately, then A will resolve naturally**

Solution C (remove verbose debug logging in release builds) is a free immediate win and
should be done regardless of everything else. Debug logs holding large string payloads in
memory is a commonly overlooked issue. Solution A is not truly a solution on its own — it
is a dependency on fixing Issues 5, 6, 11, and 12, which will naturally reduce memory once
done. Solution B (reduce in-memory caches) requires investigation to confirm it is actually
contributing before spending time on it.

Files: `realtime_stock_request_service.dart`, `app_logger.dart`, `supabase_sync_service_v2.dart`, `sync_engine.dart`

---

### Issue 9 — FK Resolution Failures on stock_replenishment_requests

**Recommended: Solution A only. Use B and C only if A proves too difficult.**

Enforcing strict sync order so items, users, and organizations are guaranteed to sync
before requests is the only correct permanent fix. Solution B (targeted prefetch for
missing rows) and Solution C (quarantine and retry) are both workarounds that add
complexity and treat the symptom. If sync order is correct, neither B nor C should be
necessary. Invest properly in A.

Files: `supabase_sync_service_v2.dart`, `sync_engine.dart`

---

### Issue 10 — Sockets Not Closing Properly

**Recommended: All three solutions, with B as the most urgent**

Use a stable single channel name per session instead of timestamp-per-attempt channels —
this is the most urgent fix and the direct cause of the socket leak. Then differentiate
intentional close from real disconnect (A) to prevent reconnect loops after logout. Then
fix listener leaks in screen dispose (C) since stream subscriptions not cancelled in
dispose() is one of the most common Flutter memory leak patterns. All three are
interconnected and needed together.

Files: `realtime_stock_request_service.dart`, `replenish_stock_tab.dart`

---

### Issue 11 — 9 COUNT Queries Every Few Seconds

**Recommended: Solution A for long term, Solution C as immediate improvement**

Switch to event-driven updates that only trigger on sync complete — this is the correct
long-term design and eliminates polling entirely. As an immediate improvement while A is
being implemented, Solution C (one summary query instead of nine) is simple and practical.
Solution B (cached counters invalidated by writes) is over-engineering for this scale and
adds complexity that is not justified given the user count.

Files: `main.dart`, `supabase_sync_service_v2.dart`, `sync_helper.dart`

---

### Issue 12 — Duplicate GET Requests Every 1–2 Seconds

**Recommended: Solution B first, then C. Avoid A unless B fails.**

Remove the double initialization path in the login/home routing flow first — this is
almost certainly the root cause and fixing it may eliminate the duplicates entirely.
Solution C (backoff and jitter on retry loops) is good hygiene and worth doing after B.
Solution A (centralized request deduplication with an in-flight map) is complex to
implement correctly, requires careful handling of error cases and race conditions, and may
become entirely unnecessary once B is fixed.

Files: `app.dart`, `main.dart`, `supabase_sync_service_v2.dart`, `realtime_stock_request_service.dart`

---

### Issue 13 — SchedulerBinding.handleBeginFrame Taking 6.96s

**Recommended: Solutions A + B together**

Move expensive state merges out of frame-critical paths AND throttle sync callbacks from
realtime ticks. These two directly address the frame time problem. Fixing Issues 11 and 12
will also naturally reduce frame pressure as a side effect. Solution C (split large build
methods into memoized subwidgets) is good practice but will not meaningfully move the
needle until A and B are done — frame time here is dominated by sync callbacks, not build
complexity.

Files: `main.dart`, `home.dart`, `realtime_stock_request_service.dart`, `supabase_sync_service_v2.dart`, `replenish_stock_tab.dart`, `franchisee_inventory.dart`

---

### Issue 14 — _invoke1 Callback Overhead (34.73% CPU)

**Recommended: Solutions A + C together, then B**

Consolidate stream subscriptions and avoid duplicate listeners per screen mount — this
directly addresses the problem since multiple listeners on the same stream multiplies
callback overhead. Also remove verbose logging in hot paths (C) immediately since string
interpolation and logging in callbacks that fire hundreds of times per second adds up
significantly. Solution B (debounce at service level) pairs well with A and is worth adding
after A and C are done.

Files: `replenish_stock_tab.dart`, `realtime_status_indicator.dart`, `realtime_stock_request_service.dart`, `app_logger.dart`, `supabase_sync_service_v2.dart`

---

### Issue 15 — Map/GrowableList Constant Allocations

**Recommended: Solutions in order A → C → B**

Stop creating new sync-status maps each tick and use a typed model with mutable fields —
this has the most impact since it directly reduces garbage collector pressure on every sync
tick. Then avoid reconverting unchanged payloads in realtime handlers (C) as a smart
optimization since if data has not changed it should not be reprocessed. Solution B (reuse
buffers in sync engine) is reasonable but lower priority than A and C.

Files: `main.dart`, `sync_helper.dart`, `realtime_stock_request_service.dart`, `realtime_sales_service.dart`, `sync_engine.dart`, `supabase_sync_service_v2.dart`

---

### Issue 16 — KeyDownEvent Already Pressed (Flutter Windows Platform Bug)

**Recommended: Solution A first, then C. Avoid B unless A fails.**

Upgrade Flutter SDK to the latest stable version first — always the right first step for
platform bugs since this may already be fixed in a newer version. Solution C (filter the
noisy log in devtools config) is a harmless and practical quality-of-life improvement for
keeping logs clean during development and can be done at any time. Solution B (local input
guard to ignore duplicate key-downs) adds app-level code to fix a framework bug and should
only be used as a last resort if upgrading the SDK does not resolve it.

Files: `pubspec.yaml`, `windows/runner/*`, `devtools_options.yaml`, `README.md`, screen files where raw keyboard handlers exist
