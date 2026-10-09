# Architecture

Three independently deployable modules in one repo:

- `app/` — Flutter app (owner + worker), deploys to app stores (not yet published)
- `backend/` — Express API, deploys to Render
- `website/` — Next.js marketing site + blog, deploys to Vercel (`jugaadi.vercel.app`)

Plus `supabase/migrations/` — schema applied directly to the Supabase project (not auto-run by either deployable).

## Data flow

```
Flutter app --(HTTPS, Bearer <Supabase JWT>)--> Express backend --(service-role key)--> Supabase Postgres
```

The Flutter app never talks to Supabase tables directly — only to Supabase Auth (phone OTP, to get a session JWT) and to the backend. The backend is the only thing holding the Supabase **service-role key**, so it's the single place that can write to the database, and the single place business rules live (hire logic rejecting other applicants, status transitions, future payment logic). This was a deliberate choice over letting the app call Supabase directly with RLS as the only guard — RLS stays enabled as defense-in-depth, but it's not the primary security boundary.

The website is fully separate — static/server-rendered Next.js, no connection to the backend API. Its only shared dependency is Supabase, for a future `leads` waitlist table (not wired yet).

## Third-party dependencies and real limits

- **Supabase free tier:** project pauses after a week of inactivity — expect a cold-start delay on the first request after a pause.
- **Render free tier:** services spin down after 15 min idle, cold start takes ~30-60s on the next request. Matters for the backend during low-traffic pilot periods.
- **Vercel:** no known MVP-relevant limit at this scale.
- **Razorpay:** not integrated yet — see plan's cut-features list.

## Rule that bit us once

(none yet — this section gets a real entry the first time a real bug costs real time; see `TROUBLESHOOTING.md` for setup snags in the meantime)
