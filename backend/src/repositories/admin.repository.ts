import { supabase } from '../config/db.js';
import { JobStatus } from '../types.js';

export async function listUsers() {
  return supabase.from('profiles').select('*').order('created_at', { ascending: false });
}

export async function updateUser(userId: string, patch: Record<string, unknown>) {
  return supabase.from('profiles').update(patch).eq('id', userId).select().maybeSingle();
}

export async function listAllJobs() {
  return supabase.from('jobs').select('*').order('created_at', { ascending: false });
}

export async function updateAnyJob(jobId: string, patch: Record<string, unknown>) {
  return supabase.from('jobs').update(patch).eq('id', jobId).select().maybeSingle();
}

// Soft delete, like the owner-facing removeOpenJob — jobs are referenced by reviews and
// job_applications, so a hard DELETE would orphan them. Unlike removeOpenJob this isn't gated
// on status='open': an admin needs to be able to pull a job regardless of its current state.
export async function removeJob(jobId: string) {
  return supabase.from('jobs').update({ status: JobStatus.REMOVED }).eq('id', jobId);
}
