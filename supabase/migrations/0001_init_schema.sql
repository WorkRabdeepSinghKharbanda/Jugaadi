-- Jugaadi MVP schema: 4 tables, single-city pilot, manual verification.

create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('owner','worker')),
  full_name text not null,
  phone text not null,
  photo_url text,
  city text not null default 'PILOT_CITY',
  lat double precision,
  lng double precision,
  is_verified boolean not null default false,
  created_at timestamptz not null default now()
);

create table worker_skills (
  id bigint generated always as identity primary key,
  worker_id uuid not null references profiles(id) on delete cascade,
  skill text not null
);

create table jobs (
  id bigint generated always as identity primary key,
  owner_id uuid not null references profiles(id) on delete cascade,
  title text not null,
  description text,
  skill_needed text not null,
  lat double precision not null,
  lng double precision not null,
  address_text text,
  start_date date not null,
  end_date date not null,
  daily_wage numeric,
  status text not null default 'open' check (status in ('open','hired','completed','cancelled')),
  hired_worker_id uuid references profiles(id),
  created_at timestamptz not null default now()
);

create table job_applications (
  id bigint generated always as identity primary key,
  job_id bigint not null references jobs(id) on delete cascade,
  worker_id uuid not null references profiles(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted','rejected')),
  created_at timestamptz not null default now(),
  unique (job_id, worker_id)
);

create extension if not exists cube;
create extension if not exists earthdistance;

create or replace function nearby_jobs(in_lat double precision, in_lng double precision, radius_m double precision default 5000)
returns setof jobs
language sql
stable
as $$
  select *
  from jobs
  where status = 'open'
    and earth_distance(ll_to_earth(lat, lng), ll_to_earth(in_lat, in_lng)) < radius_m
  order by earth_distance(ll_to_earth(lat, lng), ll_to_earth(in_lat, in_lng)) asc;
$$;

alter table profiles enable row level security;
alter table worker_skills enable row level security;
alter table jobs enable row level security;
alter table job_applications enable row level security;

create policy "profiles readable by authenticated" on profiles
  for select to authenticated using (true);
create policy "profiles writable by self" on profiles
  for insert to authenticated with check (auth.uid() = id);
create policy "profiles updatable by self" on profiles
  for update to authenticated using (auth.uid() = id);

create policy "worker_skills readable by authenticated" on worker_skills
  for select to authenticated using (true);
create policy "worker_skills writable by owner" on worker_skills
  for all to authenticated using (auth.uid() = worker_id) with check (auth.uid() = worker_id);

create policy "jobs readable by authenticated" on jobs
  for select to authenticated using (true);
create policy "jobs writable by owner" on jobs
  for all to authenticated using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

create policy "applications readable by involved parties" on job_applications
  for select to authenticated using (
    auth.uid() = worker_id
    or auth.uid() = (select owner_id from jobs where jobs.id = job_applications.job_id)
  );
create policy "applications insertable by worker" on job_applications
  for insert to authenticated with check (auth.uid() = worker_id);
create policy "applications updatable by job owner" on job_applications
  for update to authenticated using (
    auth.uid() = (select owner_id from jobs where jobs.id = job_applications.job_id)
  );
