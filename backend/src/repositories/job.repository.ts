import { randomUUID } from 'node:crypto';
import { supabase } from '../config/db.js';
import { JobStatus, ApplicationStatus } from '../types.js';

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
  workers_needed?: number;
}

export async function createJob(ownerId: string, job: JobInput) {
  return supabase.from('jobs').insert({ owner_id: ownerId, ...job }).select().single();
}

export async function nearbyJobs(lat: number, lng: number, radiusM: number, limit: number) {
  return supabase.rpc('nearby_jobs', { in_lat: lat, in_lng: lng, radius_m: radiusM, in_limit: limit });
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

export async function getJobWithOwner(jobId: string) {
  return supabase
    .from('jobs')
    .select('*, owner:profiles!jobs_owner_id_fkey(phone, contact_phone, email, full_name, is_deleted)')
    .eq('id', jobId)
    .maybeSingle();
}

// Every worker whose application on this job is 'accepted' — a job can have more than one
// once workers_needed > 1. Each becomes contact-visible to the owner as soon as they're hired,
// independent of whether the job still has open slots.
export async function acceptedWorkersForJob(jobId: string) {
  return supabase
    .from('job_applications')
    .select(
      'worker_id, worker:profiles!job_applications_worker_id_fkey(phone, contact_phone, email, full_name, is_deleted, is_verified, bio, city, worker_skills(skill))'
    )
    .eq('job_id', jobId)
    .eq('status', ApplicationStatus.ACCEPTED);
}

export async function myApplicationStatus(jobId: string, workerId: string) {
  return supabase.from('job_applications').select('status').eq('job_id', jobId).eq('worker_id', workerId).maybeSingle();
}

export async function getJobOwnerAndStatus(jobId: string) {
  return supabase.from('jobs').select('owner_id, status').eq('id', jobId).maybeSingle();
}

export async function applyToJob(jobId: string, workerId: string) {
  return supabase.from('job_applications').insert({ job_id: jobId, worker_id: workerId }).select().single();
}

export async function pendingApplicants(jobId: string) {
  // Owner explicitly wants to see applicant phone numbers before hiring (not just after) —
  // contact_phone/email still wait until hire to keep at least the profile's secondary contact
  // channels gated, but the primary phone is visible here now.
  return supabase
    .from('job_applications')
    .select('*, worker:profiles!job_applications_worker_id_fkey(full_name, phone, is_verified, bio, city, worker_skills(skill))')
    .eq('job_id', jobId)
    .eq('status', ApplicationStatus.PENDING);
}

export async function hireWorker(jobId: string, workerId: string) {
  // Atomic: the hired_count<workers_needed and status='open' guard plus the increment happen in
  // one row-locked UPDATE inside the RPC, so two concurrent hire calls can't both succeed past
  // the last open slot (a client-side read-then-write here could race when workers_needed > 1).
  const { data, error } = await supabase.rpc('hire_worker', { p_job_id: jobId, p_worker_id: workerId });
  if (error) {
    const conflict = error.message.includes('job_not_open_or_full');
    return { error: conflict ? { message: 'job is not open or has no slots left' } : error, conflict };
  }
  return { error: null, conflict: false, job: data };
}

export async function completeJob(jobId: string) {
  return supabase.from('jobs').update({ status: JobStatus.DONE }).eq('id', jobId);
}

export type JobUpdateInput = Partial<JobInput>;

export async function updateOpenJob(jobId: string, patch: JobUpdateInput) {
  // Guard on status='open': editing a hired/done job's terms after the fact doesn't make sense.
  return supabase.from('jobs').update(patch).eq('id', jobId).eq('status', JobStatus.OPEN).select().maybeSingle();
}

export async function removeOpenJob(jobId: string) {
  return supabase.from('jobs').update({ status: JobStatus.REMOVED }).eq('id', jobId).eq('status', JobStatus.OPEN).select().maybeSingle();
}

const PHOTOS_BUCKET = 'job-photos';

export async function createPhotoUploadUrl(jobId: string, ext: string) {
  const path = `${jobId}/${randomUUID()}.${ext}`;
  const { data, error } = await supabase.storage.from(PHOTOS_BUCKET).createSignedUploadUrl(path);
  if (error) return { error };
  return {
    error: null,
    path,
    token: data.token,
    publicUrl: supabase.storage.from(PHOTOS_BUCKET).getPublicUrl(path).data.publicUrl,
  };
}

export async function photoCount(jobId: string) {
  const { data, error } = await supabase.from('jobs').select('photo_urls').eq('id', jobId).maybeSingle();
  if (error) return { data: 0, error };
  return { data: (data?.photo_urls as string[] | undefined)?.length ?? 0, error: null };
}

// Atomic append via the add_job_photo() Postgres function (supabase/migrations/0012) — a
// client-side read-then-push-then-write here could lose a photo under concurrent uploads.
export async function addJobPhoto(jobId: string, photoUrl: string): Promise<{ data: unknown; error: { message: string } | null }> {
  const { data, error } = await supabase.rpc('add_job_photo', { p_job_id: jobId, p_url: photoUrl });
  return { data, error };
}
