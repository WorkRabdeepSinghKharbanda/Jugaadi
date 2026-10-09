import { supabase } from '../config/db.js';

export async function upsertProfile(userId, { role, full_name, phone, photo_url, city, lat, lng }) {
  return supabase.from('profiles').upsert({ id: userId, role, full_name, phone, photo_url, city, lat, lng });
}

export async function replaceWorkerSkills(workerId, skills) {
  await supabase.from('worker_skills').delete().eq('worker_id', workerId);
  if (!skills.length) return { error: null };
  const rows = skills.map((skill) => ({ worker_id: workerId, skill }));
  return supabase.from('worker_skills').insert(rows);
}

export async function getProfile(userId) {
  return supabase.from('profiles').select('*, worker_skills(skill)').eq('id', userId).maybeSingle();
}

export async function verifyProfile(userId) {
  return supabase.from('profiles').update({ is_verified: true }).eq('id', userId);
}
