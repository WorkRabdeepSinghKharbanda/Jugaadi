import { createClient } from '@supabase/supabase-js';
import { validateEnv } from './env.js';

validateEnv();

export const supabase = createClient(
  process.env.SUPABASE_URL as string,
  process.env.SUPABASE_SERVICE_ROLE_KEY as string,
  { auth: { persistSession: false } }
);
