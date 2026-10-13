-- Infinite-scroll pagination for GET /jobs/nearby — add an offset so the client can page
-- past the first LIMIT instead of always getting page 1. Same new-arg-count-means-new-overload
-- gotcha as 0013: drop the 4-arg version first so the client's RPC call (always 5 named args)
-- resolves to exactly one function.
drop function if exists nearby_jobs(double precision, double precision, double precision, int);

create or replace function nearby_jobs(
  in_lat double precision,
  in_lng double precision,
  radius_m double precision default 30000,
  in_limit int default 50,
  in_offset int default 0
)
returns setof jobs
language sql
stable
as $$
  select *
  from jobs
  where status = 'open'
    and earth_distance(ll_to_earth(lat, lng), ll_to_earth(in_lat, in_lng)) < radius_m
  order by earth_distance(ll_to_earth(lat, lng), ll_to_earth(in_lat, in_lng)) asc
  limit in_limit offset in_offset;
$$;
