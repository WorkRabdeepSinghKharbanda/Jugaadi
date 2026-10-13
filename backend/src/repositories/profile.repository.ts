import { supabase } from '../config/db.js';
import { JobStatus } from '../types.js';

export interface ProfileInput {
  role: 'owner' | 'worker';
  full_name: string;
  phone: string;
  photo_url?: string;
  city?: string;
  lat?: number;
  lng?: number;
  contact_phone?: string | null;
  bio?: string | null;
  email?: string | null;
  lang?: 'en' | 'hi' | 'hinglish';
}

export async function upsertProfile(userId: string, profile: ProfileInput) {
  return supabase.from('profiles').upsert({ id: userId, ...profile });
}

export async function replaceWorkerSkills(workerId: string, skills: string[]) {
  await supabase.from('worker_skills').delete().eq('worker_id', workerId);
  if (!skills.length) return { error: null };
  const rows = skills.map((skill) => ({ worker_id: workerId, skill }));
  return supabase.from('worker_skills').insert(rows);
}

export async function getProfile(userId: string) {
  return supabase.from('profiles').select('*, worker_skills(skill)').eq('id', userId).maybeSingle();
}

export async function verifyProfile(userId: string) {
  return supabase.from('profiles').update({ is_verified: true }).eq('id', userId);
}

// Soft delete: scrub personal fields but keep the row so hired_worker_id/reviewee_id on past
// jobs don't dangle — the UI shows "Deleted user" via is_deleted instead. (city is NOT NULL.)
export async function softDeleteProfile(userId: string) {
  return supabase
    .from('profiles')
    .update({
      full_name: 'Deleted user',
      phone: `deleted-${userId}`,
      contact_phone: null,
      photo_url: null,
      bio: null,
      email: null,
      city: '',
      lat: null,
      lng: null,
      is_deleted: true,
    })
    .eq('id', userId);
}

// Shared by a user deleting their own account and an admin deleting someone else's: scrub PII,
// drop skills, take down their still-open tasks, then BAN the auth identity so they can't sign in.
// Must be a ban, never auth.admin.deleteUser: profiles.id -> auth.users ON DELETE CASCADE, and
// jobs/applications/reviews cascade from profiles, so a hard delete would wipe other users' history.
// The ban is best-effort: if it fails the profile is still fully scrubbed.
export async function deactivateAccount(userId: string): Promise<{ error: { message: string } | null }> {
  const { error } = await softDeleteProfile(userId);
  if (error) return { error };

  const { error: skillsError } = await supabase.from('worker_skills').delete().eq('worker_id', userId);
  if (skillsError) console.warn('[profile] worker_skills cleanup failed:', skillsError.message);

  const { error: jobsError } = await supabase
    .from('jobs')
    .update({ status: JobStatus.REMOVED })
    .eq('owner_id', userId)
    .eq('status', JobStatus.OPEN);
  if (jobsError) console.warn('[profile] closing open jobs failed:', jobsError.message);

  const { error: banError } = await supabase.auth.admin.updateUserById(userId, { ban_duration: '876000h' });
  if (banError) console.warn('[profile] auth ban failed after soft delete:', banError.message);

  return { error: null };
}
