---
route: "WorkerTabs → WorkerHomeScreen / MyJobsScreen → JobDetailScreen"
entry_point: "app/lib/screens/worker/"
category: app
---
Worker browses nearby open jobs (infinite scroll via `core/paginated_list.dart`, status pill on jobs already applied to), applies, and tracks applications in "My applications" (infinite scroll; filter icon picks a date range, applied server-side, chip clears it). Sees owner contact once hired; reviews the owner once, then edits.
