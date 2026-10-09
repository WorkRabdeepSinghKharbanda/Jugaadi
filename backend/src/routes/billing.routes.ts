import { Router } from 'express';
import { requireAuth } from '../plugins/auth.js';
import { getMyBilling, createCheckout, razorpayWebhook } from '../controllers/billing.controller.js';

const router = Router();
router.get('/billing/me', requireAuth, getMyBilling);
router.post('/billing/checkout', requireAuth, createCheckout);
// Razorpay calls this directly (no user session) — stays unauthenticated, webhook signature
// verification (Milestone 9b) is the real gate once keys exist.
router.post('/billing/webhook', razorpayWebhook);

export default router;
