import { Router } from 'express';
import { requireAuth, requireAdminUser } from '../plugins/auth.js';
import { postReport, blockUser, unblockUser, listBlocked, adminListReports } from '../controllers/safety.controller.js';

const router = Router();
router.post('/reports', requireAuth, postReport);
router.get('/blocks', requireAuth, listBlocked);
router.post('/blocks/:userId', requireAuth, blockUser);
router.delete('/blocks/:userId', requireAuth, unblockUser);
router.get('/admin/reports', requireAuth, requireAdminUser, adminListReports);

export default router;
