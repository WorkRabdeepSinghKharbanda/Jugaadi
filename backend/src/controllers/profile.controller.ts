import type { Request, Response } from 'express';
import * as profileRepo from '../repositories/profile.repository.js';
import '../types.js';

export async function createOrUpdateProfile(req: Request, res: Response) {
  const { role, full_name, phone, photo_url, city, lat, lng, skills, contact_phone, bio } = req.body;
  if (!role || !full_name || !phone) {
    return res.status(400).json({ error: 'role, full_name, phone are required' });
  }

  const { error: profileError } = await profileRepo.upsertProfile(req.userId, {
    role, full_name, phone, photo_url, city, lat, lng, contact_phone, bio,
  });
  if (profileError) return res.status(500).json({ error: profileError.message });

  if (role === 'worker' && Array.isArray(skills)) {
    const { error: skillsError } = await profileRepo.replaceWorkerSkills(req.userId, skills);
    if (skillsError) return res.status(500).json({ error: skillsError.message });
  }

  res.json({ ok: true });
}

export async function getMyProfile(req: Request, res: Response) {
  const { data, error } = await profileRepo.getProfile(req.userId);
  if (error) return res.status(500).json({ error: error.message });
  if (!data) return res.status(404).json({ error: 'profile not found' });
  res.json(data);
}
