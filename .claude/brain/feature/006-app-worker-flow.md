---
route: "WorkerTabs → WorkerHomeScreen / MyJobsScreen → JobDetailScreen"
entry_point: "app/lib/screens/worker/"
category: app
---
Worker browses nearby open jobs (infinite scroll via `core/paginated_list.dart`, status pill on jobs already applied to), applies, and tracks applications in "My applications" (infinite scroll; filter icon picks a date range, applied server-side, chip clears it). Sees owner contact once hired; reviews the owner once, then edits.
Free-plan ads (AdMob native card every 8 jobs; Pro/trial ad-free) are built but DISABLED: `core/ads.dart` is a stub, real code in `.claude/docs/ads/ads.dart.disabled`. Enable steps in RUNNING.md.
Nearby list: each card shows daily pay and distance; filter icon opens a sheet (sort nearest/highest pay, search distance 5–50 km, skill, minimum pay; active state shown by a filled icon, server-side). Lists show pulsing skeleton cards while loading (`core/skeleton.dart`). Overflow menu on job detail: report task / block owner (see 012).
