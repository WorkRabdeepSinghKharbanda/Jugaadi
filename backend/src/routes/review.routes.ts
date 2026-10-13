import { Router } from 'express';
import { requireAuth } from '../plugins/auth.js';
import { postReview, patchReview, getProfileReviews } from '../controllers/review.controller.js';

const router = Router();
router.post('/jobs/:id/review', requireAuth, postReview);
router.patch('/jobs/:id/review', requireAuth, patchReview);
router.get('/profiles/:id/reviews', requireAuth, getProfileReviews);

export default router;
