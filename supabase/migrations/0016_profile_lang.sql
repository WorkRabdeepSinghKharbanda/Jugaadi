-- Worker/owner's chosen app language, set from the profile screen. Source of truth across
-- devices; the app also caches it locally (shared_preferences) for instant boot before
-- /profile/me resolves.
alter table profiles add column lang text not null default 'en' check (lang in ('en', 'hi', 'hinglish'));
