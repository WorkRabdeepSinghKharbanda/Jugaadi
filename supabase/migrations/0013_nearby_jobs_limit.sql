-- GET /jobs/nearby had no cap — a wide radius could return the whole open-jobs table.
-- Pilot-scale fix: a LIMIT, not full pagination (YAGNI at this scale).
-- `create or replace` with a new arg count adds an overload instead of replacing the
-- 3-arg version from 0002 — drop it first so the client's RPC call (always 4 named args)
-- has exactly one function to resolve to.
drop function if exists nearby_jobs(double precision, double precision, double precision);

create or replace function nearby_jobs(in_lat double precision, in_lng double precision, radius_m double precision default 30000, in_limit int default 50)
returns setof jobs
language sql
stable
as $$
  select *
  from jobs
  where status = 'open'
    and earth_distance(ll_to_earth(lat, lng), ll_to_earth(in_lat, in_lng)) < radius_m
  order by earth_distance(ll_to_earth(lat, lng), ll_to_earth(in_lat, in_lng)) asc
  limit in_limit;
$$;
