import express from 'express';
import './types.js';
import profileRoutes from './routes/profile.routes.js';
import jobRoutes from './routes/job.routes.js';
import adminRoutes from './routes/admin.routes.js';
import reviewRoutes from './routes/review.routes.js';
import billingRoutes from './routes/billing.routes.js';

const app = express();
// Stash the raw request body so the webhook route can HMAC-verify Razorpay's signature against
// the exact bytes sent — re-serializing req.body would not byte-for-byte match what they signed.
app.use(express.json({ verify: (req, _res, buf) => { (req as express.Request).rawBody = buf; } }));

app.get('/health', (_req, res) => res.json({ ok: true }));
app.use(profileRoutes);
app.use(jobRoutes);
app.use(adminRoutes);
app.use(reviewRoutes);
app.use(billingRoutes);

export default app;
