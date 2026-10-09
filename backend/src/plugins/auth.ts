import type { Request, Response, NextFunction } from 'express';
import { supabase } from '../config/db.js';
import '../types.js';

// Verifies the Supabase session JWT sent by the Flutter app and attaches req.userId.
export async function requireAuth(req: Request, res: Response, next: NextFunction) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'missing bearer token' });

  const { data, error } = await supabase.auth.getUser(token);
  if (error || !data?.user) return res.status(401).json({ error: 'invalid token' });

  req.userId = data.user.id;
  next();
}

// MVP-only admin gate: single shared secret header, no multi-admin auth yet. Kept for
// scripts/curl (e.g. the one-off PATCH /admin/verify) alongside requireAdminUser below.
export function requireAdmin(req: Request, res: Response, next: NextFunction) {
  const secret = process.env.ADMIN_SECRET;
  if (!secret || req.headers['x-admin-secret'] !== secret) {
    return res.status(403).json({ error: 'forbidden' });
  }
  next();
}

// Real admin gate for the in-app admin panel: the caller's own JWT-verified profile must
// have is_admin=true (flipped manually via SQL for the pilot, same spirit as is_verified).
// Must run after requireAuth (needs req.userId already set).
export async function requireAdminUser(req: Request, res: Response, next: NextFunction) {
  const { data, error } = await supabase.from('profiles').select('is_admin').eq('id', req.userId).maybeSingle();
  if (error) return res.status(500).json({ error: error.message });
  if (!data?.is_admin) return res.status(403).json({ error: 'forbidden' });
  next();
}
