import type { Request, Response } from 'express';
import * as planRepo from '../repositories/plan.repository.js';

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

// Seam for Milestone 9b: becomes a real Razorpay order-creation call once RAZORPAY_KEY_ID /
// RAZORPAY_KEY_SECRET are set on Render. The Flutter side already expects this exact shape
// (501 today), so wiring real keys in needs no client change.
export async function createCheckout(_req: Request, res: Response) {
  if (!process.env.RAZORPAY_KEY_ID) {
    return res.status(501).json({ error: 'Billing is not configured yet' });
  }
  res.status(501).json({ error: 'Razorpay checkout not implemented yet' });
}

export async function razorpayWebhook(_req: Request, res: Response) {
  if (!process.env.RAZORPAY_KEY_SECRET) {
    return res.status(501).json({ error: 'Billing is not configured yet' });
  }
  res.status(501).json({ error: 'Razorpay webhook not implemented yet' });
}
