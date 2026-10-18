-- Report / block (Play UGC policy) + filtered, sortable nearby_jobs that hides blocked users.
create table if not exists blocks (
  blocker_id uuid not null references profiles(id) on delete cascade,
  blocked_id uuid not null references profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);

create index if not exists blocks_blocked_id_idx on blocks (blocked_id);

create table if not exists reports (
  id bigint generated always as identity primary key,
  reporter_id uuid not null references profiles(id) on delete cascade,
  target_type text not null check (target_type in ('job', 'user')),
  target_id text not null,
  reason text not null check (reason in ('spam', 'scam', 'abusive', 'wrong_info', 'other')),
  details text,
  created_at timestamptz not null default now(),
  unique (reporter_id, target_type, target_id)
);

-- Backend (service role) is the only reader/writer; no policies = no direct client access.
alter table blocks enable row level security;
alter table reports enable row level security;

drop function if exists nearby_jobs(double precision, double precision, double precision, int, int);

create or replace function nearby_jobs(
  in_lat double precision,
  in_lng double precision,
  radius_m double precision default 30000,
  in_limit int default 50,
  in_offset int default 0,
  in_skill text default null,
  in_min_wage numeric default null,
  in_sort text default 'nearest',
  in_viewer uuid default null
)
returns setof jobs
language sql
stable
as $$
  select *
  from jobs
  where status = 'open'
    and earth_distance(ll_to_earth(lat, lng), ll_to_earth(in_lat, in_lng)) < radius_m
    and (in_skill is null or lower(skill_needed) = lower(in_skill))
    and (in_min_wage is null or daily_wage >= in_min_wage)
    and (in_viewer is null or not exists (
      select 1 from blocks b
      where (b.blocker_id = in_viewer and b.blocked_id = jobs.owner_id)
         or (b.blocker_id = jobs.owner_id and b.blocked_id = in_viewer)
    ))
  order by
    case when in_sort = 'pay' then daily_wage end desc nulls last,
    earth_distance(ll_to_earth(lat, lng), ll_to_earth(in_lat, in_lng)) asc,
    id asc
  limit in_limit offset in_offset;
$$;
