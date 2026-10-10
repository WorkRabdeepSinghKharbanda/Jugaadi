import type { Request, Response } from 'express';
import * as jobRepo from '../repositories/job.repository.js';
import * as planRepo from '../repositories/plan.repository.js';
import { JobStatus } from '../types.js';

/// Returns an error message if the caller is over their plan's monthly limit, else null.
/// Fails open (null = allowed) on a plan/usage lookup error — a billing-state hiccup shouldn't
/// block someone from posting a job or applying.
async function planLimitError(profileId: string, role: 'owner' | 'worker'): Promise<string | null> {
  const { data: plan, error: planError } = await planRepo.effectivePlan(profileId);
  if (planError || !plan || plan.unlimited) return null;

  const { data: used, error: usageError } = await planRepo.usageThisMonth(profileId, role);
  if (usageError) return null;

  if (used >= plan.limit!) {
    const noun = role === 'owner' ? 'job posts' : 'applications';
    return `Free plan limit reached (${plan.limit} ${noun}/month). Upgrade to Pro for unlimited.`;
  }
  return null;
}

export async function postJob(req: Request, res: Response) {
  const { title, description, skill_needed, lat, lng, address_text, start_date, end_date, daily_wage, workers_needed } = req.body;
  if (!title || !skill_needed || lat == null || lng == null || !start_date || !end_date) {
    return res.status(400).json({ error: 'title, skill_needed, lat, lng, start_date, end_date are required' });
  }
  if (workers_needed != null && (!Number.isInteger(workers_needed) || workers_needed < 1)) {
    return res.status(400).json({ error: 'workers_needed must be a positive integer' });
  }

  const limitError = await planLimitError(req.userId, 'owner');
  if (limitError) return res.status(409).json({ error: limitError, code: 'plan_limit' });

  const { data, error } = await jobRepo.createJob(req.userId, {
    title, description, skill_needed, lat, lng, address_text, start_date, end_date, daily_wage, workers_needed,
  });
  if (error) return res.status(500).json({ error: error.message });
  res.status(201).json(data);
}

const DEFAULT_NEARBY_LIMIT = 50;
const MAX_NEARBY_LIMIT = 100;

export async function getNearbyJobs(req: Request, res: Response) {
  const lat = Number(req.query.lat);
  const lng = Number(req.query.lng);
  const radius = req.query.radius ? Number(req.query.radius) : 5000;
  if (Number.isNaN(lat) || Number.isNaN(lng)) {
    return res.status(400).json({ error: 'lat and lng query params are required' });
  }

  let limit = DEFAULT_NEARBY_LIMIT;
  if (req.query.limit != null) {
    limit = Number(req.query.limit);
    if (!Number.isInteger(limit) || limit < 1) return res.status(400).json({ error: 'limit must be a positive integer' });
    limit = Math.min(limit, MAX_NEARBY_LIMIT);
  }

  const { data, error } = await jobRepo.nearbyJobs(lat, lng, radius, limit);
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
  if (p.is_deleted) return { full_name: 'Deleted user', phone: null, email: null };
  return {
    full_name: p.full_name,
    phone: p.contact_phone ?? p.phone,
    email: p.email,
    is_verified: p.is_verified,
    bio: p.bio,
    city: p.city,
    worker_skills: p.worker_skills,
  };
}

export async function getJobDetail(req: Request, res: Response) {
  const { data: job, error } = await jobRepo.getJobWithOwner(req.params.id);
  if (error) return res.status(500).json({ error: error.message });
  if (!job) return res.status(404).json({ error: 'not found' });

  const isOwner = job.owner_id === req.userId;

  const { data: accepted, error: acceptedError } = await jobRepo.acceptedWorkersForJob(req.params.id);
  if (acceptedError) return res.status(500).json({ error: acceptedError.message });

  const myAcceptance = accepted?.find((a) => a.worker_id === req.userId);

  // Lets the worker's UI show "Applied" (and disable the button) without them having to remember
  // they already applied — null if they never did.
  let myApplicationStatus: string | null = null;
  if (!isOwner) {
    const { data: myApp } = await jobRepo.myApplicationStatus(req.params.id, req.userId);
    myApplicationStatus = myApp?.status ?? null;
  }

  res.json({
    ...job,
    // Owner sees every hired worker's contact as soon as each is individually accepted —
    // independent of whether the job still has open slots (workers_needed > 1).
    hired_workers: isOwner ? accepted?.map((a) => ({ worker_id: a.worker_id, ...revealContact(a.worker) })) ?? [] : undefined,
    // A hired worker sees the owner's contact the moment their own application is accepted.
    owner: myAcceptance ? revealContact(job.owner) : undefined,
    my_application_status: myApplicationStatus,
  });
}

export async function applyToJob(req: Request, res: Response) {
  const limitError = await planLimitError(req.userId, 'worker');
  if (limitError) return res.status(409).json({ error: limitError, code: 'plan_limit' });

  const { data, error } = await jobRepo.applyToJob(req.params.id, req.userId);
  if (error) {
    // Postgres unique violation (job_id, worker_id) — the Flutter button should already be
    // disabled once applied, but guard the race/stale-UI case with a clean message instead of
    // leaking the raw constraint-violation text.
    if ('code' in error && error.code === '23505') {
      return res.status(409).json({ error: 'You already applied to this job', code: 'already_applied' });
    }
    return res.status(500).json({ error: error.message });
  }
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
  if (job.status !== JobStatus.OPEN) return res.status(409).json({ error: 'job is not open' });

  const { error, conflict } = await jobRepo.hireWorker(id, workerId);
  if (conflict) return res.status(409).json({ error: error!.message });
  if (error) return res.status(500).json({ error: error.message });
  res.json({ ok: true });
}

export async function completeJob(req: Request, res: Response) {
  const { data: job, error: jobError } = await jobRepo.getJobOwnerAndStatus(req.params.id);
  if (jobError) return res.status(500).json({ error: jobError.message });
  if (!job || job.owner_id !== req.userId) return res.status(403).json({ error: 'forbidden' });
  if (job.status !== JobStatus.HIRED) return res.status(409).json({ error: 'job is not hired' });

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
  if (job.status !== JobStatus.OPEN) return res.status(409).json({ error: 'only open jobs can be edited' });

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
  if (job.status !== JobStatus.OPEN) return res.status(409).json({ error: 'only open jobs can be removed' });

  const { data, error } = await jobRepo.removeOpenJob(req.params.id);
  if (error) return res.status(500).json({ error: error.message });
  if (!data) return res.status(409).json({ error: 'job is no longer open' });
  res.json({ ok: true });
}

const ALLOWED_PHOTO_EXT = ['jpg', 'jpeg', 'png', 'webp'];
const MAX_PHOTOS = 6;

export async function createPhotoUploadUrl(req: Request, res: Response) {
  const { data: job, error: jobError } = await jobRepo.getJobOwnerAndStatus(req.params.id);
  if (jobError) return res.status(500).json({ error: jobError.message });
  if (!job || job.owner_id !== req.userId) return res.status(403).json({ error: 'forbidden' });

  const ext = String(req.body.ext ?? '').toLowerCase().replace(/^\./, '');
  if (!ALLOWED_PHOTO_EXT.includes(ext)) {
    return res.status(400).json({ error: `ext must be one of ${ALLOWED_PHOTO_EXT.join(', ')}` });
  }

  const result = await jobRepo.createPhotoUploadUrl(req.params.id, ext);
  if (result.error) return res.status(500).json({ error: result.error.message });
  res.json({ path: result.path, token: result.token, publicUrl: result.publicUrl });
}

export async function addJobPhoto(req: Request, res: Response) {
  const { data: job, error: jobError } = await jobRepo.getJobOwnerAndStatus(req.params.id);
  if (jobError) return res.status(500).json({ error: jobError.message });
  if (!job || job.owner_id !== req.userId) return res.status(403).json({ error: 'forbidden' });

  const photoUrl = req.body.photo_url;
  if (typeof photoUrl !== 'string' || !photoUrl) return res.status(400).json({ error: 'photo_url is required' });

  const { data: photoCount, error: countError } = await jobRepo.photoCount(req.params.id);
  if (countError) return res.status(500).json({ error: countError.message });
  if (photoCount >= MAX_PHOTOS) return res.status(400).json({ error: `a job can have at most ${MAX_PHOTOS} photos` });

  const { data, error } = await jobRepo.addJobPhoto(req.params.id, photoUrl);
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
}
