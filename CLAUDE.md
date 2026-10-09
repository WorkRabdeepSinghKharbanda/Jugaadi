# Jugaadi

Read before touching code, in order:

1. This file (`CLAUDE.md`).
2. Everything in `.claude/rules/` (`branching.md`, `brain-sync.md`).
3. `.claude/brain/feature/000-index.md` — full feature/route inventory.
4. `.claude/docs/RUNNING.md` — install, configure, run.
5. `.claude/docs/ARCHITECTURE.md` — module shape, data flow, why.
6. Only then start the task.

## What it is

Jugaadi is a two-sided marketplace connecting shop owners/households with nearby verified temporary workers for 1 day–1 week gigs. Three deployables in one repo: `app/` (Flutter, owner + worker), `backend/` (Express API on Render, the only thing holding the Supabase service-role key), `website/` (Next.js marketing site + blog on Vercel). See `.claude/docs/ARCHITECTURE.md` for the full data-flow picture and why the backend sits between the app and Supabase instead of the app calling Supabase directly.

## Current state

Check `.claude/brain/feature/000-index.md` for what's actually built — don't assume anything in the plan exists in code yet unless verified there. As of this writing: schema + backend endpoints + Flutter screens + website pages all scaffolded; nothing yet deployed to Supabase/Render (no project created), website deployed to Vercel (`jugaadi.vercel.app`) but not yet connected to GitHub for auto-deploy.

## Conventions

Solo project, direct-to-`main`, no PR workflow (see `.claude/rules/branching.md`). Commit messages: plain, no filler.

**Doc-sync rule:** any change to setup steps, env vars, run commands, module boundaries, or data flow updates `.claude/docs/RUNNING.md`/`ARCHITECTURE.md` in the same commit — code wins if they ever disagree, fix the doc not the code. After feature work, audit: `RUNNING.md`, `ARCHITECTURE.md`, `.claude/brain/feature/`, this file's assumptions, root `README.md` — update what's now false, leave untouched what isn't.

**File layout rule:** every `.md` file lives under `.claude/docs/` except this file (agent entry point, stays root) and `README.md` (GitHub landing page, stays root). Apply new docs here going forward.

## Rule that bit us once

(none yet — add an entry here the first time a real bug costs real time debugging; not hypothetical, not pre-written)
