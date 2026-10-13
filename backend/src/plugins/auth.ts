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

  // A banned auth user's already-issued access token stays valid until it expires, so also
  // reject soft-deleted accounts here. A missing profile row (new user mid-signup) is allowed.
  const { data: profile, error: profileError } = await supabase.from('profiles').select('is_deleted').eq('id', data.user.id).maybeSingle();
  if (profileError) console.warn('[auth] is_deleted lookup failed, allowing request:', profileError.message);
  if (profile?.is_deleted) return res.status(401).json({ error: 'account deleted' });

  req.userId = data.user.id;
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
