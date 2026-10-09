import type { Request, Response } from 'express';
import * as profileRepo from '../repositories/profile.repository.js';
import * as adminRepo from '../repositories/admin.repository.js';

export async function verifyWorker(req: Request, res: Response) {
  const { error } = await profileRepo.verifyProfile(req.params.userId);
  if (error) return res.status(500).json({ error: error.message });
  res.json({ ok: true });
}

// --- In-app admin panel (requireAdminUser-gated) ---

const USER_EDITABLE_FIELDS = ['full_name', 'phone', 'contact_phone', 'city', 'bio', 'is_verified', 'is_admin'] as const;

export async function listUsers(_req: Request, res: Response) {
  const { data, error } = await adminRepo.listUsers();
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
}

export async function updateUser(req: Request, res: Response) {
  const patch: Record<string, unknown> = {};
  for (const key of USER_EDITABLE_FIELDS) {
    if (key in req.body) patch[key] = req.body[key];
  }
  if (Object.keys(patch).length === 0) return res.status(400).json({ error: 'no editable fields provided' });

  const { data, error } = await adminRepo.updateUser(req.params.id, patch);
  if (error) return res.status(500).json({ error: error.message });
  if (!data) return res.status(404).json({ error: 'not found' });
  res.json(data);
}

export async function deleteUser(req: Request, res: Response) {
  const { error } = await profileRepo.softDeleteProfile(req.params.id);
  if (error) return res.status(500).json({ error: error.message });
  res.json({ ok: true });
}

const JOB_STATUSES = ['open', 'hired', 'done', 'removed'] as const;

export async function listAllJobs(_req: Request, res: Response) {
  const { data, error } = await adminRepo.listAllJobs();
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
}

export async function forceUpdateJob(req: Request, res: Response) {
  const patch: Record<string, unknown> = {};
  if ('status' in req.body) {
    if (!JOB_STATUSES.includes(req.body.status)) return res.status(400).json({ error: `status must be one of ${JOB_STATUSES.join(', ')}` });
    patch.status = req.body.status;
  }
  for (const key of ['title', 'description', 'skill_needed', 'daily_wage'] as const) {
    if (key in req.body) patch[key] = req.body[key];
  }
  if (Object.keys(patch).length === 0) return res.status(400).json({ error: 'no editable fields provided' });

  const { data, error } = await adminRepo.updateAnyJob(req.params.id, patch);
  if (error) return res.status(500).json({ error: error.message });
  if (!data) return res.status(404).json({ error: 'not found' });
  res.json(data);
}

export async function hardDeleteJob(req: Request, res: Response) {
  const { error } = await adminRepo.deleteJob(req.params.id);
  if (error) return res.status(500).json({ error: error.message });
  res.json({ ok: true });
}
