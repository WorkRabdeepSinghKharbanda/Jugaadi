---
route: "POST /jobs/:id/review, PATCH /jobs/:id/review, GET /profiles/:id/reviews"
entry_point: "backend/src/routes/review.routes.ts, backend/src/controllers/review.controller.ts"
category: backend
---
One review per reviewer per job (`unique(job_id, reviewer_id)`), only on `done` jobs, only by the owner or a hired worker. POST creates (409 if one exists); PATCH edits the caller's own review (404 if none, never creates). The reviewer's current review comes back as `my_review` on `GET /jobs/:id`.
