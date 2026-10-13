---
route: "POST /profile, GET /profile/me, POST /profile/delete"
entry_point: "backend/src/routes/profile.routes.ts, backend/src/controllers/profile.controller.ts"
category: backend
---
Create/update own profile (role, name, phone, location, contact_phone, email, bio, `lang` en/hi/hinglish, worker skills), fetch own profile + verification status, and soft-delete the account (shared `deactivateAccount`: scrub PII + location + skills, remove their open tasks, ban the auth user — never hard-delete it, FKs cascade and would wipe other users' history). `contact_phone` (null = use login number) is what a hired party sees. Backend-only write path — no direct Supabase client access from the app.
