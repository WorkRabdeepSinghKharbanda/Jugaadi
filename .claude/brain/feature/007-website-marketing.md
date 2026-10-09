---
route: "/, /blog, /blog/[slug], /privacy, /terms, /robots.txt, /sitemap.xml, /llms.txt"
entry_point: "website/src/app/"
category: website
---
Next.js (App Router) landing page, Markdown-backed blog (`website/content/blog/*.md` via `src/lib/blog.ts`), static legal pages, and SEO surfaces (`robots.ts`, `sitemap.ts`, `llms.txt/route.ts`) generated from the same post data — no hand-maintained duplicates. Deployed to Vercel project `jugaadi` (`jugaadi.vercel.app`).
