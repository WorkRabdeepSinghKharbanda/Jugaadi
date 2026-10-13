# Jugaadi website design system

Inspired by the ThelaWala site (structure only, no copied text/code). Dark-first, no light theme. Lives in `website/`.

## Tokens
`website/src/styles/tokens.css` mirrors `app/lib/core/theme/tokens.dart` (AppColors.dark): bg `#0B0B0F`, surface `#17171A`, surface-high `#1E1E22`, accent `#E8A33D` / deep `#C17B1D`, on-accent `#0B0B0F`, text `#F5F5F7`, text-2 `#A6A6B3`, live `#3DDC97`, danger `#FF5A5F`, warning `#FFB547`. Radii 12/20/28, spacing 4-48, shadows `--raised/--floating/--glow`, fluid type (`--fs-display/h1/h2/h3/lede`), `--container` 1200px, `--section` rhythm, `--tap` 44px, reduced-motion zeroes `--dur`. `--text-3` is `#8A8A97` on the web (AA on bg). Font: Inter via `next/font` in `RootShell` (`--font-inter`).

## Styling
One scoped stylesheet `src/components/ui/ui.css` (classes prefixed `u-`), imported from `globals.css`. No inline styles, no Tailwind, no new dependencies. Zero client JS in the kit; only `ApkDownloadLink` is a client component (gtag `apk_download`).

## Components (`src/components/ui/`)
| Component | File | Use |
|---|---|---|
| Container, Section (+SectionHead), LinkButton, Badge, Card | primitives.tsx | Layout and basics. `Section` with `title` renders the eyebrow/H2/lede head and labels the region. `Card href` = whole-card link. |
| `buttonClass()` | button-class.ts | Class string for non-Link buttons (client download link). |
| Icon | Icon.tsx | Inline SVG set; decorative unless `label` given. Add paths to `PATHS`. |
| Header, Brand, BrandMark | Header.tsx | Sticky, skip link, locale switcher, CTA. Mobile menu is a native `<details>` (no JS). `hideLocales` for English-only pages. |
| Footer | Footer.tsx | Find workers / Features / Compare / Company / Legal columns + language links. |
| PageShell | PageShell.tsx | Header + `<main id="main">` + Footer. Every page uses it. |
| Hero, PhoneMock | Hero.tsx | Home hero (single H1) with CSS phone mock. |
| StatRow/TrustBar, Steps(+StepsGroup), FeatureGrid (first card wide), UseCaseGrid/RelatedCards, Faq (emits FAQPage JSON-LD), CtaBand, PricingCards, PostGrid | blocks.tsx | Page sections. |
| Breadcrumbs (emits BreadcrumbList JSON-LD), PageHero (inner-page H1), Prose, Toc, DocLayout, DataTable, LegalPage | doc.tsx | Articles and legal. |

Helpers: `lib/prose.ts` (`prepareProse` adds `section-N` ids to `<h2>`, TOC, reading time; `formatDate`), `lib/home-copy.ts` (home strings, en/hi/hinglish), `lib/i18n.ts` (UI strings, en/hi/hinglish).

## Page templates
- Home (`views/HomeView.tsx`): Hero, StatRow, how it works (owner + worker), use cases, bento features, pricing, FAQ, download CTA.
- Hubs (`HubView`): PageHero + card grid (blog: featured post + grid) + CtaBand.
- Content pages (`ContentPageView`): PageHero, Prose (blog adds byline, reading time, TOC), FAQ, related cards, CtaBand.
- Download (`DownloadView`), legal (`app/(en)/privacy|terms/page.tsx` via `LegalPage`), 404 (`NotFoundContent`).

## Adding a page
1. Markdown: add `content/<type>/<slug>.md` (+ `.hi.md`, `.hinglish.md`) with `title` (about 20-54 chars, the site appends " — Jugaadi"), `description` (70-165 chars). Routes, sitemap and hreflang come from `lib/content.ts`.
2. Custom page: compose `PageShell` + `PageHero`/`Section` blocks; set metadata with `pageMetadata()`; add to `sitemap.ts`.
3. Run `npm run build && npm start`, then `npm run check`.

## Pricing facts (verified in backend)
Free: limit 3 per month (owner task posts / worker responses) (`plan.repository.ts`, `job.controller.ts`). New accounts get a 7-day Pro trial. Pro: owner Rs399, worker Rs199 per 30 days, one-time Razorpay order, no auto-renew (`billing.controller.ts`). Update `home-copy.ts` if these change.

## A11y / SEO checklist
- Exactly one H1 per page; heading order H1 > H2 > H3.
- Landmarks: skip link, header, labelled navs, `<main id="main">`, footer.
- 44px targets, `:focus-visible` outline, `prefers-reduced-motion`, details/menu keyboard-operable.
- Decorative SVG/mocks `aria-hidden`; meaningful ones have labels.
- No raster images; explicit sizes on SVGs; no client JS unless needed.
- Copy: use task / respond / book / choose. Never job(s), hire, apply/application, vacancy, recruit, gig (RazorPay review). `npm run check` greps visible text.
- `npm run check` (needs a running server, `BASE_URL` default `http://localhost:3000`): every sitemap URL returns 200, one H1, title 30-65, description 70-165, canonical, 4+ hreflang, html lang, `<main>`, no banned words.
