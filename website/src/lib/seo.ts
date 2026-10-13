import type { Metadata } from "next";
import { alternatesFor, getContent, pathFor, type ContentType } from "./content";
import type { Locale } from "./locale";
import { SITE_NAME, SITE_URL } from "./site";

export const HTML_LANG: Record<Locale, string> = { en: "en", hi: "hi", hinglish: "hi-Latn" };
// Served by app/opengraph-image.tsx. Referenced explicitly because there is no app-root layout to auto-attach it
// (each locale has its own root layout).
const OG_IMAGE = "/opengraph-image";
const OG_LOCALE: Record<Locale, string> = { en: "en_IN", hi: "hi_IN", hinglish: "en_IN" };

export const DEFAULT_TITLE = `${SITE_NAME} — Same-day local help, verified nearby`;
const DEFAULT_DESCRIPTION =
  "Jugaadi is a local services marketplace — shop owners and households book verified nearby help for short, same-day tasks, 1 day to 1 week.";

/** Shared layout metadata for each locale's root layout. */
export function rootMetadata(locale: Locale): Metadata {
  return {
    metadataBase: new URL(SITE_URL),
    title: { default: DEFAULT_TITLE, template: `%s — ${SITE_NAME}` },
    description: DEFAULT_DESCRIPTION,
    openGraph: { type: "website", siteName: SITE_NAME, locale: OG_LOCALE[locale], title: DEFAULT_TITLE, description: DEFAULT_DESCRIPTION, images: [OG_IMAGE] },
    twitter: { card: "summary_large_image", title: DEFAULT_TITLE, description: DEFAULT_DESCRIPTION, images: [OG_IMAGE] },
    verification: { google: "kCnHcd-bJBBVDMlmVNxSUX0BeGjeyEf17j31SsQBwP8" },
  };
}

/**
 * Per-page metadata: canonical + hreflang + OG/Twitter. Page-level `alternates`/`openGraph` replace the
 * layout's, so every page goes through this. `title` is `{ absolute }` when the page title already has the brand.
 */
export function pageMetadata({
  locale,
  enPath,
  title,
  description,
  noindex,
}: {
  locale: Locale;
  enPath: string;
  title: string | { absolute: string };
  description: string;
  noindex?: boolean;
}): Metadata {
  const plain = typeof title === "string" ? title : title.absolute;
  const full = alternatesFor(locale, enPath);
  // noindex pages (placeholder legal) only exist in English: canonical, no hreflang cluster.
  const alternates = noindex ? { canonical: full.canonical } : full;
  return {
    title,
    description,
    alternates,
    ...(noindex && { robots: { index: false, follow: true } }),
    openGraph: { type: "website", siteName: SITE_NAME, locale: OG_LOCALE[locale], title: plain, description, url: alternates.canonical, images: [OG_IMAGE] },
    twitter: { card: "summary_large_image", title: plain, description, images: [OG_IMAGE] },
  };
}

export async function contentMetadata(type: ContentType, slug: string, locale: Locale): Promise<Metadata> {
  const page = await getContent(type, slug, locale);
  if (!page) return {};
  return pageMetadata({ locale, enPath: pathFor({ type, slug, locale: "en" }), title: page.title, description: page.description });
}
