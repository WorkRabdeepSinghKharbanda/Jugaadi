import express from 'express';
import profileRoutes from './routes/profile.routes.js';
import jobRoutes from './routes/job.routes.js';
import adminRoutes from './routes/admin.routes.js';

const app = express();
app.use(express.json());

app.get('/health', (_req, res) => res.json({ ok: true }));
app.use(profileRoutes);
app.use(jobRoutes);
app.use(adminRoutes);

export default app;
