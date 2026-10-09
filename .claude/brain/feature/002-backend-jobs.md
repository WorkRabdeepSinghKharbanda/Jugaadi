---
route: "POST /jobs, GET /jobs/nearby, GET /jobs/mine, GET /jobs/:id, POST /jobs/:id/apply, GET /jobs/:id/applicants, POST /jobs/:id/hire/:workerId, POST /jobs/:id/complete, GET /applications/mine"
entry_point: "backend/src/index.js"
category: backend
---
Core job lifecycle: post, browse nearby (via `nearby_jobs` Postgres RPC), apply, view applicants, hire (auto-rejects other applicants), mark complete. `GET /jobs/:id` reveals the other party's phone number only once status is `hired`/`completed` and only to the owner or the hired worker.
