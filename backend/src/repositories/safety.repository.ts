import { supabase } from '../config/db.js';

export async function addBlock(blockerId: string, blockedId: string) {
  return supabase.from('blocks').upsert({ blocker_id: blockerId, blocked_id: blockedId }, { onConflict: 'blocker_id,blocked_id', ignoreDuplicates: true });
}

export async function removeBlock(blockerId: string, blockedId: string) {
  return supabase.from('blocks').delete().eq('blocker_id', blockerId).eq('blocked_id', blockedId);
}

export async function blockedProfiles(blockerId: string) {
  return supabase.from('blocks').select('blocked_id, created_at, blocked:profiles!blocks_blocked_id_fkey(full_name)').eq('blocker_id', blockerId).order('created_at', { ascending: false });
}

// Ids hidden from `userId` in either direction (they blocked, or were blocked by).
export async function blockedEitherWay(userId: string): Promise<Set<string>> {
  const { data } = await supabase.from('blocks').select('blocker_id, blocked_id').or(`blocker_id.eq.${userId},blocked_id.eq.${userId}`);
  return new Set((data ?? []).map((b) => (b.blocker_id === userId ? b.blocked_id : b.blocker_id)));
}

export async function createReport(r: { reporter_id: string; target_type: string; target_id: string; reason: string; details?: string }) {
  return supabase.from('reports').insert(r);
}

export async function listReports() {
  return supabase.from('reports').select('*, reporter:profiles!reports_reporter_id_fkey(full_name)').order('created_at', { ascending: false }).limit(200);
}
