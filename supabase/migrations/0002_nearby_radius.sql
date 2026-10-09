-- City-label locations (picked via geocoder search or a single GPS fix) can easily be
-- several km apart for the same city; 5km was too tight to ever match in practice.
create or replace function nearby_jobs(in_lat double precision, in_lng double precision, radius_m double precision default 30000)
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
