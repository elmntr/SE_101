# Application Issues 1

**Project:** Inventory Cross-Platform Offline-First Flutter Application  
**Date:** February 22, 2026  
**Total Issues Found:** 16

---

## 🔴 Critical

**1. TimerSignificantlyOverdue — UI Thread Blocking 600ms+**  
Timers are firing 600–683ms late repeatedly, meaning the main isolate is being blocked and the UI is freezing for noticeable periods during normal use.

**2. 401 Unauthorized GET Requests to Supabase**  
The app is repeatedly making API calls with expired or missing tokens, causing unauthorized request errors continuously during runtime.

**3. daily_sales_summary Sync Failing Every Attempt**  
Error: `Bad state: Too many elements` — this table never successfully syncs on both attempt 1 and attempt 2. Data from this table is never pulled into the local database.

**4. stock_change_requests Sync Failing Every Attempt**  
Error: `type 'Null' is not a subtype of type 'int'` — this table also never successfully syncs. A non-nullable integer column is receiving null from Supabase.

**5. 242 HTTP Requests and Responses Held in Memory and Not Released**  
Supabase HTTP responses are not being freed from memory after use, directly causing abnormally high memory consumption at idle.

**6. 226 Drift Queries Still Active Simultaneously**  
Drift database queries are stacking up and not completing or being released, piling up in memory instead of finishing and disposing properly.

**7. Excessive UI Repainting — paintWithContext at 110% CPU**  
Widgets are being rebuilt and repainted far more than necessary. CPU profiler shows `RenderObject.paintWithContext` consuming over 110% of recorded CPU time, likely triggered by sync status watchers rebuilding the entire widget tree on every COUNT query result.

---

## 🟡 Moderate

**8. High Idle Memory Usage (~400MB)**  
The app is consuming approximately 400MB of memory with no user interaction. This is dangerous for low-end Android devices used at branches and may cause the OS to kill the app in the background.

**9. FK Resolution Failures on stock_replenishment_requests**  
Multiple records are being skipped during sync because their `item_id` references items that do not exist in the local database. This is a sync order issue — items need to be synced before replenishment requests.

**10. Sockets Not Closing Properly**  
One Supabase Realtime socket was found open for 17 seconds and another stuck as Pending. The app is opening new socket connections without properly closing old ones.

**11. 9 Separate COUNT Queries Running Repeatedly Every Few Seconds**  
The app runs 9 individual COUNT queries across all tables every few seconds to check sync status, even when the app is completely idle and no sync is occurring.

**12. Unnecessary Duplicate GET Requests Firing Every 1–2 Seconds**  
Continuous GET requests are being sent to Supabase every 1–2 seconds with no user action triggering them.

**13. SchedulerBinding.handleBeginFrame Taking 6.96s (21.70% CPU)**  
The frame scheduler is spending too long per frame, directly connected to the UI freeze and TimerSignificantlyOverdue issue.

**14. _invoke1 Consuming 34.73% CPU**  
Too many Dart event callbacks are firing continuously, consuming over a third of CPU time.

**15. Map and GrowableList Constantly Allocating**  
Sync status maps and lists are being repeatedly created and thrown away instead of being reused, contributing to memory pressure and CPU overhead.

---

## 🟢 Low / Not Your Code

**16. KeyDownEvent Already Pressed Error (27 times)**  
Flutter Windows platform bug where the OS sends duplicate key press events that Flutter does not expect. This is a known Flutter Windows issue, not caused by application code, and will not appear on Android or iOS devices.
