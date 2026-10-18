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
export async function blockedEitherWay(userId: string): Promise<{ ids: Set<string>; error: { message: string } | null }> {
  const [mine, theirs] = await Promise.all([
    supabase.from('blocks').select('blocked_id').eq('blocker_id', userId).limit(10000),
    supabase.from('blocks').select('blocker_id').eq('blocked_id', userId).limit(10000),
  ]);
  const error = mine.error ?? theirs.error;
  const ids = new Set<string>([...(mine.data ?? []).map((b) => b.blocked_id), ...(theirs.data ?? []).map((b) => b.blocker_id)]);
  return { ids, error };
}

// True if either of the two has blocked the other. Throws-as-error so callers can fail closed.
export async function isBlockedBetween(a: string, b: string): Promise<{ blocked: boolean; error: { message: string } | null }> {
  const { data, error } = await supabase
    .from('blocks')
    .select('blocker_id')
    .or(`and(blocker_id.eq.${a},blocked_id.eq.${b}),and(blocker_id.eq.${b},blocked_id.eq.${a})`)
    .limit(1);
  return { blocked: (data?.length ?? 0) > 0, error };
}

export async function createReport(r: { reporter_id: string; target_type: string; target_id: string; reason: string; details?: string }) {
  return supabase.from('reports').insert(r);
}

export async function listReports() {
  return supabase.from('reports').select('*, reporter:profiles!reports_reporter_id_fkey(full_name)').order('created_at', { ascending: false }).limit(200);
}
