import type { Request, Response } from 'express';
import * as jobRepo from '../repositories/job.repository.js';
import '../types.js';

export async function postJob(req: Request, res: Response) {
  const { title, description, skill_needed, lat, lng, address_text, start_date, end_date, daily_wage, workers_needed } = req.body;
  if (!title || !skill_needed || lat == null || lng == null || !start_date || !end_date) {
    return res.status(400).json({ error: 'title, skill_needed, lat, lng, start_date, end_date are required' });
  }
  if (workers_needed != null && (!Number.isInteger(workers_needed) || workers_needed < 1)) {
    return res.status(400).json({ error: 'workers_needed must be a positive integer' });
  }

  const { data, error } = await jobRepo.createJob(req.userId, {
    title, description, skill_needed, lat, lng, address_text, start_date, end_date, daily_wage, workers_needed,
  });
  if (error) return res.status(500).json({ error: error.message });
  res.status(201).json(data);
}

export async function getNearbyJobs(req: Request, res: Response) {
  const lat = Number(req.query.lat);
  const lng = Number(req.query.lng);
  const radius = req.query.radius ? Number(req.query.radius) : 5000;
  if (Number.isNaN(lat) || Number.isNaN(lng)) {
    return res.status(400).json({ error: 'lat and lng query params are required' });
  }

  const { data, error } = await jobRepo.nearbyJobs(lat, lng, radius);
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
}

export async function getMyApplications(req: Request, res: Response) {
  const { data, error } = await jobRepo.applicationsByWorker(req.userId);
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
}

export async function getMyJobs(req: Request, res: Response) {
  const { data, error } = await jobRepo.jobsByOwner(req.userId);
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
}

// contact_phone (set on the profile) wins over the login phone when the user chose to share a
// different reach-out number; falls back to the login phone when they never set one.
function revealContact(p: any) {
  if (!p) return undefined;
  return p.is_deleted
    ? { full_name: 'Deleted user', phone: null, email: null }
    : { full_name: p.full_name, phone: p.contact_phone ?? p.phone, email: p.email };
}

export async function getJobDetail(req: Request, res: Response) {
  const { data: job, error } = await jobRepo.getJobWithOwner(req.params.id);
  if (error) return res.status(500).json({ error: error.message });
  if (!job) return res.status(404).json({ error: 'not found' });

  const isOwner = job.owner_id === req.userId;

  const { data: accepted, error: acceptedError } = await jobRepo.acceptedWorkersForJob(req.params.id);
  if (acceptedError) return res.status(500).json({ error: acceptedError.message });

  const myAcceptance = accepted?.find((a) => a.worker_id === req.userId);

  res.json({
    ...job,
    // Owner sees every hired worker's contact as soon as each is individually accepted —
    // independent of whether the job still has open slots (workers_needed > 1).
    hired_workers: isOwner ? accepted?.map((a) => ({ worker_id: a.worker_id, ...revealContact(a.worker) })) ?? [] : undefined,
    // A hired worker sees the owner's contact the moment their own application is accepted.
    owner: myAcceptance ? revealContact(job.owner) : undefined,
  });
}

export async function applyToJob(req: Request, res: Response) {
  const { data, error } = await jobRepo.applyToJob(req.params.id, req.userId);
  if (error) return res.status(500).json({ error: error.message });
  res.status(201).json(data);
}

export async function getApplicants(req: Request, res: Response) {
  const { data: job, error: jobError } = await jobRepo.getJobOwnerAndStatus(req.params.id);
  if (jobError) return res.status(500).json({ error: jobError.message });
  if (!job || job.owner_id !== req.userId) return res.status(403).json({ error: 'forbidden' });

  const { data, error } = await jobRepo.pendingApplicants(req.params.id);
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
}

export async function hireApplicant(req: Request, res: Response) {
  const { id, workerId } = req.params;

  const { data: job, error: jobError } = await jobRepo.getJobOwnerAndStatus(id);
  if (jobError) return res.status(500).json({ error: jobError.message });
  if (!job || job.owner_id !== req.userId) return res.status(403).json({ error: 'forbidden' });
  if (job.status !== 'open') return res.status(409).json({ error: 'job is not open' });

  const { error, conflict } = await jobRepo.hireWorker(id, workerId);
  if (conflict) return res.status(409).json({ error: error!.message });
  if (error) return res.status(500).json({ error: error.message });
  res.json({ ok: true });
}

export async function completeJob(req: Request, res: Response) {
  const { data: job, error: jobError } = await jobRepo.getJobOwnerAndStatus(req.params.id);
  if (jobError) return res.status(500).json({ error: jobError.message });
  if (!job || job.owner_id !== req.userId) return res.status(403).json({ error: 'forbidden' });
  if (job.status !== 'hired') return res.status(409).json({ error: 'job is not hired' });

  const { error } = await jobRepo.completeJob(req.params.id);
  if (error) return res.status(500).json({ error: error.message });
  res.json({ ok: true });
}

const EDITABLE_FIELDS = ['title', 'description', 'skill_needed', 'lat', 'lng', 'address_text', 'start_date', 'end_date', 'daily_wage'] as const;
// workers_needed is deliberately not editable once posted — it'd desync from hired_count,
// which only ever increases via the atomic hire_worker RPC.

export async function updateJob(req: Request, res: Response) {
  const { data: job, error: jobError } = await jobRepo.getJobOwnerAndStatus(req.params.id);
  if (jobError) return res.status(500).json({ error: jobError.message });
  if (!job || job.owner_id !== req.userId) return res.status(403).json({ error: 'forbidden' });
  if (job.status !== 'open') return res.status(409).json({ error: 'only open jobs can be edited' });

  const patch: Record<string, unknown> = {};
  for (const key of EDITABLE_FIELDS) {
    if (key in req.body) patch[key] = req.body[key];
  }
  if (Object.keys(patch).length === 0) return res.status(400).json({ error: 'no editable fields provided' });

  const { data, error } = await jobRepo.updateOpenJob(req.params.id, patch);
  if (error) return res.status(500).json({ error: error.message });
  if (!data) return res.status(409).json({ error: 'job is no longer open' });
  res.json(data);
}

export async function removeJob(req: Request, res: Response) {
  const { data: job, error: jobError } = await jobRepo.getJobOwnerAndStatus(req.params.id);
  if (jobError) return res.status(500).json({ error: jobError.message });
  if (!job || job.owner_id !== req.userId) return res.status(403).json({ error: 'forbidden' });
  if (job.status !== 'open') return res.status(409).json({ error: 'only open jobs can be removed' });

  const { data, error } = await jobRepo.removeOpenJob(req.params.id);
  if (error) return res.status(500).json({ error: error.message });
  if (!data) return res.status(409).json({ error: 'job is no longer open' });
  res.json({ ok: true });
}
