import { Router } from 'express';
import { requireAuth } from '../plugins/auth.js';
import { createOrUpdateProfile, getMyProfile } from '../controllers/profile.controller.js';

const router = Router();
router.post('/profile', requireAuth, createOrUpdateProfile);
router.get('/profile/me', requireAuth, getMyProfile);

export default router;
