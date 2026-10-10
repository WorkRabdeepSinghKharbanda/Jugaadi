import type { Request, Response } from 'express';
import * as profileRepo from '../repositories/profile.repository.js';
import * as planRepo from '../repositories/plan.repository.js';
import '../types.js';

export async function createOrUpdateProfile(req: Request, res: Response) {
  const { role, full_name, phone, photo_url, city, lat, lng, skills, contact_phone, bio, email } = req.body;
  if (!role || !full_name || !phone) {
    return res.status(400).json({ error: 'role, full_name, phone are required' });
  }

  const { error: profileError } = await profileRepo.upsertProfile(req.userId, {
    role, full_name, phone, photo_url, city, lat, lng, contact_phone, bio, email,
  });
  if (profileError) return res.status(500).json({ error: profileError.message });

  // Not gated on role — an account can act as both owner and worker (dual role, switchable
  // in-app), so skills are useful regardless of which role was chosen at signup.
  if (Array.isArray(skills)) {
    const { error: skillsError } = await profileRepo.replaceWorkerSkills(req.userId, skills);
    if (skillsError) return res.status(500).json({ error: skillsError.message });
  }

  // No-ops after the first call (upsert on the unique profile_id, ignoreDuplicates) — safe to
  // call on every profile save, not just the first, without resetting an existing trial/plan.
  const { error: trialError } = await planRepo.startTrialSubscription(req.userId);
  if (trialError) console.warn('[profile] startTrialSubscription failed:', trialError.message);

  res.json({ ok: true });
}

export async function getMyProfile(req: Request, res: Response) {
  const { data, error } = await profileRepo.getProfile(req.userId);
  if (error) return res.status(500).json({ error: error.message });
  if (!data) return res.status(404).json({ error: 'profile not found' });
  res.json(data);
}

export async function deleteMyProfile(req: Request, res: Response) {
  const { error } = await profileRepo.deactivateAccount(req.userId);
  if (error) return res.status(500).json({ error: error.message });
  res.json({ ok: true });
}
