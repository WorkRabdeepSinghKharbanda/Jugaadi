---
route: "GET /billing/me, POST /billing/checkout, POST /billing/verify, POST /billing/webhook"
entry_point: "backend/src/routes/billing.routes.ts, backend/src/controllers/billing.controller.ts"
category: backend
---
Razorpay Pro plan (owner Rs399 / worker Rs199 per 30 days, one-time Orders). `checkout` creates the order, `verify` is the client HMAC fast path, `webhook` (raw body + signature) is the source of truth and returns 502 on activation failure so Razorpay retries. Free tier limits live in `plan.repository.ts`.
