alter table jobs add column photo_urls text[] not null default '{}';

insert into storage.buckets (id, name, public)
values ('job-photos', 'job-photos', true)
on conflict (id) do nothing;

-- Public read (bucket is public, but still need a SELECT policy for anon/authenticated roles
-- to actually list/fetch objects through the API). Writes only ever happen via the backend's
-- service-role key (signed upload URLs it issues), so no INSERT/UPDATE/DELETE policy is needed.
create policy "job photos are publicly readable" on storage.objects
  for select using (bucket_id = 'job-photos');
