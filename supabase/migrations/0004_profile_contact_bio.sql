-- Separate "contact number" (shown to the other party on hire) from the login phone
-- (Supabase Auth identity, never exposed unless contact_phone is unset). Also a free-text
-- bio shown on the profile screen.
alter table profiles add column contact_phone text;
alter table profiles add column bio text;
