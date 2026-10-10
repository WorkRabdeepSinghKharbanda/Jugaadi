export {};

declare global {
  namespace Express {
    interface Request {
      userId: string;
      rawBody?: Buffer;
    }
  }
}

// Single source of truth for job/application status strings — kills typo risk from raw string
// literals scattered across controllers/repositories. Mirrors the DB check constraints in
// supabase/migrations/0001_init_schema.sql and 0003_job_status_rename.sql (not enforced here,
// just typed consistently on the TS side).
export const JobStatus = {
  OPEN: 'open',
  HIRED: 'hired',
  DONE: 'done',
  REMOVED: 'removed',
} as const;
export type JobStatus = (typeof JobStatus)[keyof typeof JobStatus];

export const ApplicationStatus = {
  PENDING: 'pending',
  ACCEPTED: 'accepted',
  REJECTED: 'rejected',
} as const;
export type ApplicationStatus = (typeof ApplicationStatus)[keyof typeof ApplicationStatus];
