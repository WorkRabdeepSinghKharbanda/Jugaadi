import { Router } from 'express';
import { requireAuth } from '../plugins/auth.js';
import { getMyBilling, createCheckout, verifyPayment, razorpayWebhook } from '../controllers/billing.controller.js';

const router = Router();
router.get('/billing/me', requireAuth, getMyBilling);
router.post('/billing/checkout', requireAuth, createCheckout);
router.post('/billing/verify', requireAuth, verifyPayment);
// Razorpay calls this directly (no user session) — stays unauthenticated; the HMAC signature
// check inside razorpayWebhook (against RAZORPAY_WEBHOOK_SECRET) is the real gate.
router.post('/billing/webhook', razorpayWebhook);

export default router;
