# Feature index

## backend
| File | Route |
|---|---|
| [001-backend-profile](001-backend-profile.md) | `POST /profile`, `GET /profile/me`, `POST /profile/delete` |
| [002-backend-jobs](002-backend-jobs.md) | `POST /jobs`, `GET /jobs/nearby`, `GET /jobs/mine`, `GET /applications/mine`, `GET/PATCH /jobs/:id`, `POST /jobs/:id/apply`, `GET /jobs/:id/applicants`, `POST /jobs/:id/hire/:workerId`, `POST /jobs/:id/complete`, `POST /jobs/:id/remove`, `POST /jobs/:id/photos[/upload-url]` |
| [003-backend-admin](003-backend-admin.md) | `/admin/verify/:userId`, `/admin/users*`, `/admin/jobs*` |
| [008-backend-billing](008-backend-billing.md) | `GET /billing/me`, `POST /billing/checkout`, `POST /billing/verify`, `POST /billing/webhook` |
| [009-backend-reviews](009-backend-reviews.md) | `POST/PATCH /jobs/:id/review`, `GET /profiles/:id/reviews` |
| [012-safety-report-block](012-safety-report-block.md) | `POST /reports`, `/blocks*`, `GET /admin/reports` |

## app
| File | Route |
|---|---|
| [004-app-auth-flow](004-app-auth-flow.md) | RootRouter → PhoneAuth → OtpVerify → RoleSelect → ProfileSetup |
| [005-app-owner-flow](005-app-owner-flow.md) | OwnerHomeScreen → PostJob / JobApplicants / JobDetail |
| [006-app-worker-flow](006-app-worker-flow.md) | WorkerTabs → WorkerHome / MyJobs → JobDetail |
| [010-app-i18n](010-app-i18n.md) | LangScope, `context.tr`, Profile language picker |
| [011-app-share-job](011-app-share-job.md) | JobDetail share (image / copy text) |

## website
| File | Route |
|---|---|
| [007-website-marketing](007-website-marketing.md) | `/`, `/blog`, `/blog/[slug]`, `/privacy`, `/terms`, `/robots.txt`, `/sitemap.xml`, `/llms.txt` |
