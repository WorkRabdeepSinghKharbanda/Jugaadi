import { Router } from 'express';
import { requireAuth } from '../plugins/auth.js';
import {
  postJob,
  getNearbyJobs,
  getMyApplications,
  getMyJobs,
  getJobDetail,
  applyToJob,
  getApplicants,
  hireApplicant,
  completeJob,
} from '../controllers/job.controller.js';

const router = Router();
router.post('/jobs', requireAuth, postJob);
router.get('/jobs/nearby', requireAuth, getNearbyJobs);
router.get('/jobs/mine', requireAuth, getMyJobs);
router.get('/applications/mine', requireAuth, getMyApplications);
router.get('/jobs/:id', requireAuth, getJobDetail);
router.post('/jobs/:id/apply', requireAuth, applyToJob);
router.get('/jobs/:id/applicants', requireAuth, getApplicants);
router.post('/jobs/:id/hire/:workerId', requireAuth, hireApplicant);
router.post('/jobs/:id/complete', requireAuth, completeJob);

export default router;
