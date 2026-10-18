---
route: "POST /reports, GET /blocks, POST/DELETE /blocks/:userId, GET /admin/reports"
entry_point: "backend/src/routes/safety.routes.ts, app/lib/core/safety.dart"
category: backend
---
Play UGC safety. Users report a task or person (`reports`: reason spam/scam/abusive/wrong_info/other + optional details) and block people (`blocks`). Blocking hides each side's open tasks from the other in `nearby_jobs` (via `in_viewer`) and filters blocked workers out of `GET /jobs/:id/applicants`. App: overflow menu on job detail (worker view) and on each pending applicant; Profile → "Blocked people" lists and unblocks. Admin reads reports at `GET /admin/reports` (API only, no admin screen yet). Tables are service-role only (RLS on, no policies). Migration 0018.
