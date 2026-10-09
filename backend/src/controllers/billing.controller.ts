import { createHmac, timingSafeEqual } from 'node:crypto';
import type { Request, Response } from 'express';
import Razorpay from 'razorpay';
import * as planRepo from '../repositories/plan.repository.js';

const PRO_AMOUNT_PAISE = 19900;

function razorpayClient() {
  const keyId = process.env.RAZORPAY_KEY_ID;
  const keySecret = process.env.RAZORPAY_KEY_SECRET;
  if (!keyId || !keySecret) return null;
  return new Razorpay({ key_id: keyId, key_secret: keySecret });
}

export async function getMyBilling(req: Request, res: Response) {
  const { data, error } = await planRepo.effectivePlan(req.userId);
  if (error) return res.status(500).json({ error: error.message });
  // role isn't known here without a profile lookup; report both counters, the client shows
  // whichever one matches its own role.
  const [owner, worker] = await Promise.all([
    planRepo.usageThisMonth(req.userId, 'owner'),
    planRepo.usageThisMonth(req.userId, 'worker'),
  ]);
  res.json({ ...data, usageThisMonth: { owner: owner.data, worker: worker.data } });
}

// One-time ₹199 order per 30-day Pro period (not a Razorpay "Subscription" entity — that needs a
// pre-created Plan in the Razorpay dashboard we don't have; a plain Order the app re-creates each
// time someone upgrades/renews is simpler and needs no dashboard setup beyond API keys).
export async function createCheckout(req: Request, res: Response) {
  const razorpay = razorpayClient();
  if (!razorpay) return res.status(501).json({ error: 'Billing is not configured yet' });

  const order = await razorpay.orders.create({
    amount: PRO_AMOUNT_PAISE,
    currency: 'INR',
    receipt: `pro_${req.userId}_${Date.now()}`,
    notes: { profile_id: req.userId },
  });

  res.json({
    orderId: order.id,
    amount: order.amount,
    currency: order.currency,
    keyId: process.env.RAZORPAY_KEY_ID,
  });
}

// Client-side verification per Razorpay's documented checkout flow: the Flutter SDK's success
// callback hands back these three fields, and HMAC-ing order_id|payment_id with our key secret
// must reproduce their signature. This activates Pro immediately (good UX); the webhook below
// does the exact same activation independently as the source of truth, in case the app is killed
// before this call completes.
export async function verifyPayment(req: Request, res: Response) {
  const keySecret = process.env.RAZORPAY_KEY_SECRET;
  if (!keySecret) return res.status(501).json({ error: 'Billing is not configured yet' });

  const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;
  if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
    return res.status(400).json({ error: 'razorpay_order_id, razorpay_payment_id, razorpay_signature are required' });
  }

  const expected = createHmac('sha256', keySecret).update(`${razorpay_order_id}|${razorpay_payment_id}`).digest('hex');
  if (!timingSafeEqual(Buffer.from(expected), Buffer.from(razorpay_signature))) {
    return res.status(400).json({ error: 'invalid payment signature' });
  }

  const { error } = await planRepo.activateProPlan(req.userId, razorpay_payment_id);
  if (error) return res.status(500).json({ error: error.message });
  res.json({ ok: true });
}

// Razorpay calls this directly (no Jugaadi user session) — verifies the whole request body
// against x-razorpay-signature using the dashboard-configured webhook secret, independent of
// the per-payment signature verifyPayment checks above. Source of truth for activation even if
// the app's own verify call never happens (killed app, network drop after payment).
export async function razorpayWebhook(req: Request, res: Response) {
  const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET;
  if (!webhookSecret) return res.status(501).json({ error: 'Billing is not configured yet' });

  const signature = req.headers['x-razorpay-signature'];
  if (typeof signature !== 'string' || !req.rawBody) return res.status(400).json({ error: 'missing signature or body' });

  const expected = createHmac('sha256', webhookSecret).update(req.rawBody).digest('hex');
  if (!timingSafeEqual(Buffer.from(expected), Buffer.from(signature))) {
    return res.status(400).json({ error: 'invalid webhook signature' });
  }

  const event = req.body.event as string;
  if (event === 'payment.captured' || event === 'order.paid') {
    const payment = req.body.payload?.payment?.entity;
    const profileId = payment?.notes?.profile_id;
    if (profileId) {
      const { error } = await planRepo.activateProPlan(profileId, payment.id);
      if (error) console.warn('[billing] webhook activateProPlan failed:', error.message);
    }
  }

  res.json({ ok: true });
}
