---
route: "PATCH /admin/verify/:userId"
entry_point: "backend/src/auth.js, backend/src/index.js"
category: backend
---
Manual worker verification: flips `profiles.is_verified`. Gated by a shared `ADMIN_SECRET` header, not a real admin auth system — single-admin MVP only, see plan's cut-features list.
