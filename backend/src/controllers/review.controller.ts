import type { Request, Response } from 'express';
import * as reviewRepo from '../repositories/review.repository.js';
import * as jobRepo from '../repositories/job.repository.js';

export async function postReview(req: Request, res: Response) {
  const { rating, comment, worker_id } = req.body;
  if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
    return res.status(400).json({ error: 'rating must be an integer 1-5' });
  }

  const { data: job, error: jobError } = await jobRepo.getJobOwnerAndStatus(req.params.id);
  if (jobError) return res.status(500).json({ error: jobError.message });
  if (!job) return res.status(404).json({ error: 'not found' });
  if (job.status !== 'done') return res.status(409).json({ error: 'job is not done yet' });

  const isOwner = job.owner_id === req.userId;

  const { data: accepted, error: acceptedError } = await jobRepo.acceptedWorkersForJob(req.params.id);
  if (acceptedError) return res.status(500).json({ error: acceptedError.message });
  const isHiredWorker = accepted?.some((a) => a.worker_id === req.userId) ?? false;

  if (!isOwner && !isHiredWorker) return res.status(403).json({ error: 'forbidden' });

  // A job can have more than one hired worker — an owner reviewing must say which one;
  // a worker reviewing only ever has one owner to rate.
  let revieweeId: string | undefined;
  if (isOwner) {
    if (!worker_id) return res.status(400).json({ error: 'worker_id is required when reviewing as the owner' });
    if (!accepted?.some((a) => a.worker_id === worker_id)) return res.status(400).json({ error: 'that worker was not hired on this job' });
    revieweeId = worker_id;
  } else {
    revieweeId = job.owner_id;
  }
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
