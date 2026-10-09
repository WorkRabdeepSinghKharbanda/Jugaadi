import { Router } from 'express';
import { requireAdmin, requireAuth, requireAdminUser } from '../plugins/auth.js';
import {
  verifyWorker,
  listUsers,
  updateUser,
  deleteUser,
  listAllJobs,
  forceUpdateJob,
  hardDeleteJob,
} from '../controllers/admin.controller.js';

const router = Router();
router.patch('/admin/verify/:userId', requireAdmin, verifyWorker);

router.get('/admin/users', requireAuth, requireAdminUser, listUsers);
router.patch('/admin/users/:id', requireAuth, requireAdminUser, updateUser);
router.post('/admin/users/:id/delete', requireAuth, requireAdminUser, deleteUser);
router.get('/admin/jobs', requireAuth, requireAdminUser, listAllJobs);
router.patch('/admin/jobs/:id', requireAuth, requireAdminUser, forceUpdateJob);
router.delete('/admin/jobs/:id', requireAuth, requireAdminUser, hardDeleteJob);

export default router;
