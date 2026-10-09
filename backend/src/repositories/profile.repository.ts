import { supabase } from '../config/db.js';

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
// jobs don't dangle — the UI shows "Deleted user" via is_deleted instead.
export async function softDeleteProfile(userId: string) {
  return supabase
    .from('profiles')
    .update({
      full_name: 'Deleted user',
      phone: `deleted-${userId}`,
      contact_phone: null,
      photo_url: null,
      bio: null,
      is_deleted: true,
    })
    .eq('id', userId);
}
