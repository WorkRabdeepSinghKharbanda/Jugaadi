import { Router } from 'express';
import { requireAdmin } from '../plugins/auth.js';
import { verifyWorker } from '../controllers/admin.controller.js';

const router = Router();
router.patch('/admin/verify/:userId', requireAdmin, verifyWorker);

export default router;
