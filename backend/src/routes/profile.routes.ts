import { Router } from 'express';
import { requireAuth } from '../plugins/auth.js';
import { createOrUpdateProfile, getMyProfile, deleteMyProfile } from '../controllers/profile.controller.js';

const router = Router();
router.post('/profile', requireAuth, createOrUpdateProfile);
router.get('/profile/me', requireAuth, getMyProfile);
router.post('/profile/delete', requireAuth, deleteMyProfile);

export default router;
