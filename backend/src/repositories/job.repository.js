import { supabase } from '../config/db.js';

export async function createJob(ownerId, job) {
  return supabase.from('jobs').insert({ owner_id: ownerId, ...job }).select().single();
}

export async function nearbyJobs(lat, lng, radiusM) {
  return supabase.rpc('nearby_jobs', { in_lat: lat, in_lng: lng, radius_m: radiusM });
}

export async function jobsByOwner(ownerId) {
  return supabase.from('jobs').select('*').eq('owner_id', ownerId).order('created_at', { ascending: false });
}

export async function applicationsByWorker(workerId) {
  return supabase
    .from('job_applications')
    .select('status, job:jobs(*)')
    .eq('worker_id', workerId)
    .order('created_at', { ascending: false });
}

export async function getJobWithContacts(jobId) {
  return supabase
    .from('jobs')
    .select('*, owner:profiles!jobs_owner_id_fkey(phone, full_name), hired_worker:profiles!jobs_hired_worker_id_fkey(phone, full_name)')
    .eq('id', jobId)
    .maybeSingle();
}

export async function getJobOwnerAndStatus(jobId) {
  return supabase.from('jobs').select('owner_id, status').eq('id', jobId).maybeSingle();
}

export async function applyToJob(jobId, workerId) {
  return supabase.from('job_applications').insert({ job_id: jobId, worker_id: workerId }).select().single();
}

export async function pendingApplicants(jobId) {
  return supabase
    .from('job_applications')
    .select('*, worker:profiles!job_applications_worker_id_fkey(full_name, phone, is_verified, lat, lng)')
    .eq('job_id', jobId)
    .eq('status', 'pending');
}

export async function hireWorker(jobId, workerId) {
  const { error: hireError } = await supabase
    .from('jobs')
    .update({ status: 'hired', hired_worker_id: workerId })
    .eq('id', jobId);
  if (hireError) return { error: hireError };

  await supabase.from('job_applications').update({ status: 'accepted' }).eq('job_id', jobId).eq('worker_id', workerId);
  await supabase.from('job_applications').update({ status: 'rejected' }).eq('job_id', jobId).neq('worker_id', workerId);
  return { error: null };
}

export async function completeJob(jobId) {
  return supabase.from('jobs').update({ status: 'completed' }).eq('id', jobId);
}
