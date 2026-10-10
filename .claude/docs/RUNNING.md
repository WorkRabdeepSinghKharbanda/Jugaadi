# Running Jugaadi locally

## Supabase

1. Create a project at supabase.com.
2. Run `supabase/migrations/0001_init_schema.sql` against it (SQL editor, or `supabase db push` once the CLI is linked).
3. Grab the project URL, anon key, and service-role key from Project Settings → API.

## backend/

```
cd backend
cp .env.example .env   # fill in SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
npm install
npm run dev             # listens on PORT (default 3000)
```

| Key | Required | Purpose |
|---|---|---|
| `SUPABASE_URL` | yes | Supabase project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | yes | Server-only key; backend is the only thing holding it |
| `PORT` | no (default 3000) | HTTP port |

**How to get each credential:**
- `SUPABASE_URL` / `SUPABASE_SERVICE_ROLE_KEY`: Supabase dashboard → Project Settings → API. Service-role key bypasses RLS — never ship it to the Flutter app, never commit it.

All `/admin/*` routes (including `PATCH /admin/verify/:userId`) are gated by `requireAdminUser`: caller must send a valid Supabase session JWT (`Authorization: Bearer ...`) for a profile with `is_admin=true` (flipped manually via SQL for the pilot).

## app/

```
cd app
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=API_BASE_URL=http://localhost:3000
```

Without these three `--dart-define` values the app shows a "not configured" screen instead of crashing.

- `SUPABASE_ANON_KEY`: Supabase dashboard → Project Settings → API (the public anon key, safe to ship in the app).

## website/

```
cd website
npm install
npm run dev   # http://localhost:3000
```

Deployed via Vercel project `jugaadi` → `jugaadi.vercel.app`. Connect the GitHub repo under Vercel project Settings → Git to get auto-deploy on push to `main` (one-time interactive step, can't be done from the CLI).
