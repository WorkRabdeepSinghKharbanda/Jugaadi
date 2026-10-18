import type { Request, Response } from 'express';
import * as safetyRepo from '../repositories/safety.repository.js';

const REASONS = ['spam', 'scam', 'abusive', 'wrong_info', 'other'];
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export async function postReport(req: Request, res: Response) {
  const { target_type, target_id, reason, details } = req.body;
  if (target_type !== 'job' && target_type !== 'user') return res.status(400).json({ error: 'target_type must be job or user' });
  const id = String(target_id ?? '');
  if (target_type === 'user' ? !UUID_RE.test(id) : !/^\d{1,18}$/.test(id)) return res.status(400).json({ error: 'invalid target_id' });
  if (!REASONS.includes(reason)) return res.status(400).json({ error: 'invalid reason' });
  if (details != null && (typeof details !== 'string' || details.length > 500)) return res.status(400).json({ error: 'details must be 500 characters or fewer' });

  const { error } = await safetyRepo.createReport({ reporter_id: req.userId, target_type, target_id: id, reason, details: details?.trim() || undefined });
  // Same reporter + same target again (unique index): already on file, treat as success.
  if (error && !('code' in error && error.code === '23505')) return res.status(500).json({ error: error.message });
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
  if (!UUID_RE.test(req.params.userId)) return res.status(400).json({ error: 'invalid user id' });
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
