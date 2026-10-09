import type { Request, Response } from 'express';
import * as reviewRepo from '../repositories/review.repository.js';
import * as jobRepo from '../repositories/job.repository.js';

export async function postReview(req: Request, res: Response) {
  const { rating, comment } = req.body;
  if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
    return res.status(400).json({ error: 'rating must be an integer 1-5' });
  }

  const { data: job, error: jobError } = await jobRepo.getJobOwnerAndStatus(req.params.id);
  if (jobError) return res.status(500).json({ error: jobError.message });
  if (!job) return res.status(404).json({ error: 'not found' });
  if (job.status !== 'done') return res.status(409).json({ error: 'job is not done yet' });

  // Need hired_worker_id too — getJobOwnerAndStatus only selects owner_id/status.
  const { data: full, error: fullError } = await jobRepo.getJobWithContacts(req.params.id);
  if (fullError) return res.status(500).json({ error: fullError.message });
  if (!full) return res.status(404).json({ error: 'not found' });

  const isOwner = full.owner_id === req.userId;
  const isHiredWorker = full.hired_worker_id === req.userId;
  if (!isOwner && !isHiredWorker) return res.status(403).json({ error: 'forbidden' });

  const revieweeId = isOwner ? full.hired_worker_id : full.owner_id;
  if (!revieweeId) return res.status(409).json({ error: 'no counterpart to review' });

  const { data: existing, error: existingError } = await reviewRepo.hasReviewed(req.params.id, req.userId);
  if (existingError) return res.status(500).json({ error: existingError.message });
  if (existing) return res.status(409).json({ error: 'you already reviewed this job' });

  const { data, error } = await reviewRepo.createReview(req.params.id, req.userId, revieweeId, rating, comment);
  if (error) return res.status(500).json({ error: error.message });
  res.status(201).json(data);
}

export async function getProfileReviews(req: Request, res: Response) {
  const { data, error } = await reviewRepo.reviewsForProfile(req.params.id);
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
}
