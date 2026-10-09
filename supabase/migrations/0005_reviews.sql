create table reviews (
  id bigint generated always as identity primary key,
  job_id bigint not null references jobs(id) on delete cascade,
  reviewer_id uuid not null references profiles(id) on delete cascade,
  reviewee_id uuid not null references profiles(id) on delete cascade,
  rating int not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz not null default now(),
  unique (job_id, reviewer_id)
);

alter table reviews enable row level security;

-- Backend (service role) bypasses RLS; these are defense-in-depth, same spirit as the other tables.
create policy "reviews readable by authenticated" on reviews
  for select to authenticated using (true);
create policy "reviews writable by reviewer" on reviews
  for insert to authenticated with check (auth.uid() = reviewer_id);
