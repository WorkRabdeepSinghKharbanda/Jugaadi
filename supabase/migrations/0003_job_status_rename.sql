-- Rename job lifecycle states: completed -> done, cancelled -> removed (same 4-state shape).
alter table jobs drop constraint jobs_status_check;

update jobs set status = 'done' where status = 'completed';
update jobs set status = 'removed' where status = 'cancelled';

alter table jobs add constraint jobs_status_check check (status in ('open','hired','done','removed'));
