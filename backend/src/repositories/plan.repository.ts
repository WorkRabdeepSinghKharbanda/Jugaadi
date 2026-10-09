import { supabase } from '../config/db.js';

const TRIAL_DAYS = 7;

export async function startTrialSubscription(profileId: string) {
  const trialEndsAt = new Date(Date.now() + TRIAL_DAYS * 24 * 60 * 60 * 1000).toISOString();
  // Upsert on profile_id (unique) — re-running profile setup shouldn't reset an existing trial/plan.
  return supabase
    .from('subscriptions')
    .upsert({ profile_id: profileId, plan_id: 'pro', status: 'trialing', trial_ends_at: trialEndsAt }, { onConflict: 'profile_id', ignoreDuplicates: true });
}

export interface PlanLimits {
  plan: 'free' | 'pro';
  status: string;
  unlimited: boolean;
  limit: number | null;
  trial_ends_at: string | null;
  current_period_end: string | null;
}

export async function effectivePlan(profileId: string): Promise<{ data: PlanLimits | null; error: { message: string } | null }> {
  const { data: sub, error } = await supabase.from('subscriptions').select('*').eq('profile_id', profileId).maybeSingle();
  if (error) return { data: null, error };

  // No subscription row (shouldn't normally happen post-signup) or an expired/cancelled one both
  // fall back to Free rather than erroring — never block the app over a billing-state gap.
  const trialActive = sub?.status === 'trialing' && sub.trial_ends_at && new Date(sub.trial_ends_at) > new Date();
  const isPro = trialActive || sub?.status === 'active';

  return {
    error: null,
    data: {
      plan: isPro ? 'pro' : 'free',
      status: sub?.status ?? 'expired',
      unlimited: isPro,
      limit: isPro ? null : 3,
      trial_ends_at: sub?.trial_ends_at ?? null,
      current_period_end: sub?.current_period_end ?? null,
    },
  };
}

const PRO_PERIOD_DAYS = 30;

/// Activates (or renews) Pro for `profileId` after a verified payment. Idempotent to call twice
/// for the same payment (webhook + client-side verify both call this) — just overwrites with the
/// same period end either way.
export async function activateProPlan(profileId: string, razorpayPaymentId: string) {
  const currentPeriodEnd = new Date(Date.now() + PRO_PERIOD_DAYS * 24 * 60 * 60 * 1000).toISOString();
  return supabase.from('subscriptions').upsert(
    {
      profile_id: profileId,
      plan_id: 'pro',
      status: 'active',
      current_period_end: currentPeriodEnd,
      razorpay_subscription_id: razorpayPaymentId,
    },
    { onConflict: 'profile_id' }
  );
}

export async function usageThisMonth(profileId: string, role: 'owner' | 'worker') {
  const monthStart = new Date();
  monthStart.setDate(1);
  monthStart.setHours(0, 0, 0, 0);

  if (role === 'owner') {
    const { count, error } = await supabase
      .from('jobs')
      .select('id', { count: 'exact', head: true })
      .eq('owner_id', profileId)
      .gte('created_at', monthStart.toISOString());
    return { data: count ?? 0, error };
  }
  const { count, error } = await supabase
    .from('job_applications')
    .select('id', { count: 'exact', head: true })
    .eq('worker_id', profileId)
    .gte('created_at', monthStart.toISOString());
  return { data: count ?? 0, error };
}
