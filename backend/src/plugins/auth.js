import { supabase } from '../config/db.js';

// Verifies the Supabase session JWT sent by the Flutter app and attaches req.userId.
export async function requireAuth(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'missing bearer token' });

  const { data, error } = await supabase.auth.getUser(token);
  if (error || !data?.user) return res.status(401).json({ error: 'invalid token' });

  req.userId = data.user.id;
  next();
}

// MVP-only admin gate: single shared secret header, no multi-admin auth yet.
export function requireAdmin(req, res, next) {
  if (req.headers['x-admin-secret'] !== process.env.ADMIN_SECRET) {
    return res.status(403).json({ error: 'forbidden' });
  }
  next();
}
