const REQUIRED_VARS = ['SUPABASE_URL', 'SUPABASE_SERVICE_ROLE_KEY'] as const;

export function validateEnv(): void {
  const missing = REQUIRED_VARS.filter((key) => !process.env[key]);
  if (missing.length > 0) {
    throw new Error(`Missing required environment variables: ${missing.join(', ')}`);
  }
  if (process.env.NODE_ENV === 'production' && !process.env.ADMIN_SECRET) {
    console.warn('[env] ADMIN_SECRET is not set: PATCH /admin/verify/:userId will always refuse (403).');
  }
}
