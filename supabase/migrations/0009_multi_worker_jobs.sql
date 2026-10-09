alter table jobs add column workers_needed int not null default 1 check (workers_needed >= 1);
alter table jobs add column hired_count int not null default 0 check (hired_count >= 0 and hired_count <= workers_needed);

-- Atomic hire: guards hired_count < workers_needed and status = 'open' in one row-locked
-- UPDATE (closes the race two concurrent hire requests would otherwise have), flips the job
-- to 'hired' once every slot is filled, and only then auto-rejects remaining pending applicants.
create or replace function hire_worker(p_job_id bigint, p_worker_id uuid)
returns jobs
language plpgsql
as $$
declare
  v_job jobs;
begin
  update jobs
  set hired_count = hired_count + 1,
      status = case when hired_count + 1 >= workers_needed then 'hired' else status end
  where id = p_job_id and status = 'open' and hired_count < workers_needed
  returning * into v_job;

  if v_job.id is null then
    raise exception 'job_not_open_or_full';
  end if;

  update job_applications set status = 'accepted' where job_id = p_job_id and worker_id = p_worker_id;

  if v_job.status = 'hired' then
    update job_applications set status = 'rejected' where job_id = p_job_id and worker_id <> p_worker_id and status = 'pending';
  end if;

  return v_job;
end;
$$;
