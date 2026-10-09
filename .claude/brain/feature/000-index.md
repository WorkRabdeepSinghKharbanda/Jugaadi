# Feature index

## backend
| File | Route |
|---|---|
| [001-backend-profile](001-backend-profile.md) | `POST /profile`, `GET /profile/me` |
| [002-backend-jobs](002-backend-jobs.md) | `POST /jobs`, `GET /jobs/nearby`, `GET /jobs/mine`, `GET /jobs/:id`, `POST /jobs/:id/apply`, `GET /jobs/:id/applicants`, `POST /jobs/:id/hire/:workerId`, `POST /jobs/:id/complete`, `GET /applications/mine` |
| [003-backend-admin](003-backend-admin.md) | `PATCH /admin/verify/:userId` |

## app
| File | Route |
|---|---|
| [004-app-auth-flow](004-app-auth-flow.md) | RootRouter → PhoneAuth → OtpVerify → RoleSelect → ProfileSetup |
| [005-app-owner-flow](005-app-owner-flow.md) | OwnerHomeScreen → PostJob / JobApplicants / JobDetail |
| [006-app-worker-flow](006-app-worker-flow.md) | WorkerTabs → WorkerHome / MyJobs → JobDetail |

## website
| File | Route |
|---|---|
| [007-website-marketing](007-website-marketing.md) | `/`, `/blog`, `/blog/[slug]`, `/privacy`, `/terms`, `/robots.txt`, `/sitemap.xml`, `/llms.txt` |
