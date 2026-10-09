import { supabase } from '../config/db.js';

export interface ProfileInput {
  role: 'owner' | 'worker';
  full_name: string;
  phone: string;
  photo_url?: string;
  city?: string;
  lat?: number;
  lng?: number;
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
