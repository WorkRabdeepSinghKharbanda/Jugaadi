import { supabase } from '../config/db.js';

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

export async function deleteJob(jobId: string) {
  return supabase.from('jobs').delete().eq('id', jobId);
}
