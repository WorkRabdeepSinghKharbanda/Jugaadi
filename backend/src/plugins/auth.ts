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

// MVP-only admin gate: single shared secret header, no multi-admin auth yet.
export function requireAdmin(req: Request, res: Response, next: NextFunction) {
  const secret = process.env.ADMIN_SECRET;
  if (!secret || req.headers['x-admin-secret'] !== secret) {
    return res.status(403).json({ error: 'forbidden' });
  }
  next();
}
