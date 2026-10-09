import { supabase } from '../config/db.js';

export async function createReview(jobId: string, reviewerId: string, revieweeId: string, rating: number, comment?: string) {
  return supabase
    .from('reviews')
    .insert({ job_id: jobId, reviewer_id: reviewerId, reviewee_id: revieweeId, rating, comment })
    .select()
    .single();
}

export async function reviewsForProfile(profileId: string) {
  return supabase
    .from('reviews')
    .select('*, reviewer:profiles!reviews_reviewer_id_fkey(full_name)')
    .eq('reviewee_id', profileId)
    .order('created_at', { ascending: false });
}

export async function hasReviewed(jobId: string, reviewerId: string) {
  return supabase.from('reviews').select('id').eq('job_id', jobId).eq('reviewer_id', reviewerId).maybeSingle();
}
