-- Atomic photo append: addJobPhoto previously did SELECT photo_urls, push in JS, UPDATE — two
-- concurrent uploads on the same job could race and silently lose one. One UPDATE statement
-- closes the race (jobs.id is bigint, not uuid, per 0001_init_schema.sql). Returns the updated
-- row so the repository doesn't need a second round trip to hand the new photo_urls back.
create or replace function add_job_photo(p_job_id bigint, p_url text)
returns jobs
language sql
as $$
  update jobs set photo_urls = array_append(photo_urls, p_url) where id = p_job_id
  returning *;
$$;
