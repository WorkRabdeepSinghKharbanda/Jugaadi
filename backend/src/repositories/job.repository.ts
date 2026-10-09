import { supabase } from '../config/db.js';

export interface JobInput {
  title: string;
  description?: string;
  skill_needed: string;
  lat: number;
  lng: number;
  address_text?: string;
  start_date: string;
  end_date: string;
  daily_wage?: number;
}

export async function createJob(ownerId: string, job: JobInput) {
  return supabase.from('jobs').insert({ owner_id: ownerId, ...job }).select().single();
}

export async function nearbyJobs(lat: number, lng: number, radiusM: number) {
  return supabase.rpc('nearby_jobs', { in_lat: lat, in_lng: lng, radius_m: radiusM });
}

export async function jobsByOwner(ownerId: string) {
  return supabase.from('jobs').select('*').eq('owner_id', ownerId).order('created_at', { ascending: false });
}

export async function applicationsByWorker(workerId: string) {
  return supabase
    .from('job_applications')
    .select('status, job:jobs(*)')
    .eq('worker_id', workerId)
    .order('created_at', { ascending: false });
}

export async function getJobWithContacts(jobId: string) {
  return supabase
    .from('jobs')
    .select(
      '*, owner:profiles!jobs_owner_id_fkey(phone, contact_phone, full_name, is_deleted), hired_worker:profiles!jobs_hired_worker_id_fkey(phone, contact_phone, full_name, is_deleted)'
    )
    .eq('id', jobId)
    .maybeSingle();
}

export async function getJobOwnerAndStatus(jobId: string) {
  return supabase.from('jobs').select('owner_id, status').eq('id', jobId).maybeSingle();
}

export async function applyToJob(jobId: string, workerId: string) {
  return supabase.from('job_applications').insert({ job_id: jobId, worker_id: workerId }).select().single();
}

export async function pendingApplicants(jobId: string) {
  // Phone/location stay hidden until hire (matches getJobDetail's reveal-on-hire rule) —
  // don't leak an applicant's contact info to the owner before they're chosen.
  return supabase
    .from('job_applications')
    .select('*, worker:profiles!job_applications_worker_id_fkey(full_name, is_verified)')
    .eq('job_id', jobId)
    .eq('status', 'pending');
}

export async function hireWorker(jobId: string, workerId: string) {
  // Guard on status='open' so two concurrent hire requests can't both succeed (second write
  // would silently overwrite hired_worker_id from the first).
  const { data: hired, error: hireError } = await supabase
    .from('jobs')
    .update({ status: 'hired', hired_worker_id: workerId })
    .eq('id', jobId)
    .eq('status', 'open')
    .select()
    .maybeSingle();
  if (hireError) return { error: hireError, conflict: false };
  if (!hired) return { error: { message: 'job is not open' }, conflict: true };

  await supabase.from('job_applications').update({ status: 'accepted' }).eq('job_id', jobId).eq('worker_id', workerId);
  await supabase.from('job_applications').update({ status: 'rejected' }).eq('job_id', jobId).neq('worker_id', workerId);
  return { error: null, conflict: false };
}

export async function completeJob(jobId: string) {
  return supabase.from('jobs').update({ status: 'done' }).eq('id', jobId);
}

export type JobUpdateInput = Partial<JobInput>;

export async function updateOpenJob(jobId: string, patch: JobUpdateInput) {
  // Guard on status='open': editing a hired/done job's terms after the fact doesn't make sense.
  return supabase.from('jobs').update(patch).eq('id', jobId).eq('status', 'open').select().maybeSingle();
}

export async function removeOpenJob(jobId: string) {
  return supabase.from('jobs').update({ status: 'removed' }).eq('id', jobId).eq('status', 'open').select().maybeSingle();
}
