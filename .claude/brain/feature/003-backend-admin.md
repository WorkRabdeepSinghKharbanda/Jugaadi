---
route: "PATCH /admin/verify/:userId, GET /admin/users, PATCH /admin/users/:id, POST /admin/users/:id/delete, GET /admin/jobs, PATCH /admin/jobs/:id, DELETE /admin/jobs/:id"
entry_point: "backend/src/routes/admin.routes.ts, backend/src/controllers/admin.controller.ts"
category: backend
---
Admin console API: verify workers, list/edit/deactivate users (shared `deactivateAccount`), list/force-edit jobs, soft-remove jobs (status flip, not hard delete). Every route gated by `requireAdminUser` (JWT + `profiles.is_admin=true`); no shared-secret gate.
