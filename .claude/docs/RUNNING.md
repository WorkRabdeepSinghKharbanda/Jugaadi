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

### Run against production (simulator/emulator)

To point a simulator/emulator build at the live Render backend + Supabase project instead of local, use `.env.production` (same file the release APK is built from):

```
cd app
flutter run --dart-define-from-file=.env.production
```

`flutter devices` lists available simulators/emulators; add `-d <device-id>` to target one. Release build for distribution is the same flag with `flutter build apk --release` instead of `flutter run`.

### Release signing and Play Store bundle

Release builds sign with the upload key in `app/android/jugaadi-upload.jks`, configured by `app/android/key.properties` (both gitignored — back them up outside the repo; losing the upload key means asking Google Play to reset it). Without `key.properties` Gradle falls back to the debug key, which is fine for `flutter run --release` but not for distribution.

```
cd app
flutter build apk --release --dart-define-from-file=.env.production        # sideload / Drive
flutter build appbundle --release --dart-define-from-file=.env.production  # Play Store upload
```

Outputs: `build/app/outputs/flutter-apk/app-release.apk` and `build/app/outputs/bundle/release/app-release.aab`. Bump the `+N` build number in `pubspec.yaml` for every upload (Play rejects a repeated versionCode). The app's `AndroidManifest.xml` removes geolocator's `GeolocatorLocationService` (`tools:node="remove"`): Jugaadi never runs location in a foreground service, and leaving it in makes Play Console ask for a FOREGROUND_SERVICE_LOCATION declaration. Re-add it only if background location is ever built. Changing the signing key means an older debug-signed APK cannot be updated in place — users reinstall once.

## Deploy order for migrations that change an RPC

Apply the SQL migration (psql) BEFORE pushing the backend that calls it. Migration 0018 recreates `nearby_jobs` with new params; a backend deployed first returns 500 on `/jobs/nearby` until the migration lands. Roll back by re-running 0017 (restores the old function; the new backend then breaks, so revert it too).

## Enabling Free-plan ads (currently OFF)

Built, then disabled on request. Free-plan workers would see a native AdMob card after every 8 jobs in the nearby list; Pro and the 7-day trial see none. To turn on:

1. `cd app && flutter pub add google_mobile_ads`.
2. `cp ../.claude/docs/ads/ads.dart.disabled lib/core/ads.dart` (replaces the stub).
3. Uncomment `admobNativeUnitId` in `lib/config.dart`; add `ADMOB_NATIVE_UNIT_ID=ca-app-pub-…/…` to `app/.env.production`.
4. Uncomment the `meta-data` in `AndroidManifest.xml` and the `manifestPlaceholders` line in `build.gradle.kts`; add `admobAppId=ca-app-pub-…~…` to `android/key.properties`.
5. Uncomment the `no_ads` benefit in `plans_screen.dart` (string key already exists).
6. Website: add "Shows ads" to the Free plan and "No ads" to the Pro plan in `website/src/lib/home-copy.ts` (en/hi/hinglish); add an "Ads (Free plan)" row and Google AdMob to the provider list in the privacy page; mention ads in the terms "Plans and payments"; add to `LISTING.md`.
7. Play Console: App content, Ads, "Contains ads" = Yes; Data safety, Device or other IDs (advertising ID) = collected, shared, for advertising; Advertising ID declaration = Yes.
8. In AdMob console block sensitive categories (jobs, loans, gambling, dating). Bump the build number and rebuild.

## Store screenshots tool

`app/tool/store_screenshots/` regenerates the Play Store screenshots: `mock_server.py` serves demo data, `main.dart` drives the real app through its screens, `capture.sh` shoots phone/7"/10" sizes on the Android emulator. Outputs land in `.claude/docs/play-store/screenshots/`.

## website/

```
cd website
npm install
npm run dev   # http://localhost:3000
```

Deployed via Vercel project `jugaadi` → `jugaadi.vercel.app`. Connect the GitHub repo under Vercel project Settings → Git to get auto-deploy on push to `main` (one-time interactive step, can't be done from the CLI).
