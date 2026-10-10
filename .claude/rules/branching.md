---
protected_branches: ["archive"]
---

# Branching strategy

Personal solo project. No feature-branch/PR workflow — commits go straight to `main`.

## Deploy after every push

- **Website (`website/`):** Vercel git-integrated auto-deploy once the GitHub repo is connected in the Vercel dashboard (Settings → Git). Until connected, deploy manually with `cd website && vercel deploy --prod`.
- **Backend (`backend/`):** Render git-integrated auto-deploy once the Render service is created pointing at this repo with root directory `backend/`. Confirm auto-deploy is enabled on the service (not manual-deploy mode).

Then verify with:
```
curl -s -o /dev/null -w "%{http_code}\n" https://jugaadi.vercel.app
curl -s -o /dev/null -w "%{http_code}\n" <render-backend-url>/health
```
to confirm the new build is live (200), not stale.
