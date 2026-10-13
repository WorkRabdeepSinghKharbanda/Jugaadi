-- Offset paging needs a total order: many jobs share a shop's lat/lng so earth_distance ties,
-- and Postgres gives no stable order between ties — pages could duplicate/skip rows. Tiebreak on id.
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
  order by earth_distance(ll_to_earth(lat, lng), ll_to_earth(in_lat, in_lng)) asc, id asc
  limit in_limit offset in_offset;
$$;
