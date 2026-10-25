---
route: "OwnerHomeScreen → PostJobScreen / JobApplicantsScreen / JobDetailScreen"
entry_point: "app/lib/screens/owner/"
category: app
---
Owner posts/edits a job (live required-field validation gates the Post button and photo upload; optional shop/address line), views own jobs, views applicants and hires, marks complete, reviews the hired worker once (then edits that review). Share button on open jobs (see 011). All via the `backend/` API.
Each job's overflow menu has "Post again" (prefills a new job from it via `PostJobScreen(repostFrom:)`; dates and photos are not copied). Pending applicants have report/block in their overflow menu (see 012).
Hire is a `SlideToConfirm` per pending applicant.
