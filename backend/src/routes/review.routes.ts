import { Router } from 'express';
import { requireAuth } from '../plugins/auth.js';
import { postReview, getProfileReviews } from '../controllers/review.controller.js';

const router = Router();
router.post('/jobs/:id/review', requireAuth, postReview);
router.get('/profiles/:id/reviews', requireAuth, getProfileReviews);

export default router;
