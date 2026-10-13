---
route: "POST /jobs, GET /jobs/nearby, GET /jobs/mine, GET /applications/mine, GET /jobs/:id, PATCH /jobs/:id, POST /jobs/:id/apply, GET /jobs/:id/applicants, POST /jobs/:id/hire/:workerId, POST /jobs/:id/complete, POST /jobs/:id/remove, POST /jobs/:id/photos/upload-url, POST /jobs/:id/photos"
entry_point: "backend/src/routes/job.routes.ts, backend/src/controllers/job.controller.ts"
category: backend
---
Core job lifecycle: post (optional `address_line2` shop/landmark), browse nearby, apply, view applicants, hire atomically (`hire_worker` RPC), complete, remove, photos (`add_job_photo` RPC). `GET /jobs/nearby` and `GET /applications/mine` paginate with `?limit=&offset=` (default 50, max 100); nearby merges the caller's `my_application_status` per job, applications also take `?from=&to=` (YYYY-MM-DD, filters on the job's start_date server-side). `GET /jobs/:id` returns `my_application_status`, `my_review`, and reveals the counterpart's contact only once the application is accepted.
