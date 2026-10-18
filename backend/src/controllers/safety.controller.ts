import type { Request, Response } from 'express';
import * as safetyRepo from '../repositories/safety.repository.js';

const REASONS = ['spam', 'scam', 'abusive', 'wrong_info', 'other'];
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export async function postReport(req: Request, res: Response) {
  const { target_type, target_id, reason, details } = req.body;
  if (target_type !== 'job' && target_type !== 'user') return res.status(400).json({ error: 'target_type must be job or user' });
  if (target_id == null || String(target_id).length === 0 || String(target_id).length > 64) return res.status(400).json({ error: 'target_id is required' });
  if (!REASONS.includes(reason)) return res.status(400).json({ error: 'invalid reason' });
  if (details != null && (typeof details !== 'string' || details.length > 500)) return res.status(400).json({ error: 'details must be 500 characters or fewer' });

  const { error } = await safetyRepo.createReport({ reporter_id: req.userId, target_type, target_id: String(target_id), reason, details: details?.trim() || undefined });
  if (error) return res.status(500).json({ error: error.message });
  res.status(201).json({ ok: true });
}

export async function blockUser(req: Request, res: Response) {
  const { userId } = req.params;
  if (!UUID_RE.test(userId)) return res.status(400).json({ error: 'invalid user id' });
  if (userId === req.userId) return res.status(400).json({ error: 'you cannot block yourself' });
  const { error } = await safetyRepo.addBlock(req.userId, userId);
  if (error) return res.status(500).json({ error: error.message });
  res.json({ ok: true });
}

export async function unblockUser(req: Request, res: Response) {
  const { error } = await safetyRepo.removeBlock(req.userId, req.params.userId);
  if (error) return res.status(500).json({ error: error.message });
  res.json({ ok: true });
}

export async function listBlocked(req: Request, res: Response) {
  const { data, error } = await safetyRepo.blockedProfiles(req.userId);
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
}

export async function adminListReports(_req: Request, res: Response) {
  const { data, error } = await safetyRepo.listReports();
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
}
