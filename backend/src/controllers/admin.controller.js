import * as profileRepo from '../repositories/profile.repository.js';

export async function verifyWorker(req, res) {
  const { error } = await profileRepo.verifyProfile(req.params.userId);
  if (error) return res.status(500).json({ error: error.message });
  res.json({ ok: true });
}
