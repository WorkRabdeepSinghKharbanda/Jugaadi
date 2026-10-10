---
route: "PATCH /admin/verify/:userId"
entry_point: "backend/src/routes/admin.routes.ts, backend/src/controllers/admin.controller.ts"
category: backend
---
Manual worker verification: flips `profiles.is_verified`. Gated by `requireAdminUser` (JWT + `profiles.is_admin=true`), same as every other `/admin/*` route — no more separate shared-secret gate.
