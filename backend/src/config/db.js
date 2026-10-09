import { createClient } from '@supabase/supabase-js';
import { validateEnv } from './env.js';

validateEnv();

export const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY,
  { auth: { persistSession: false } }
);
