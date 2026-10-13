export interface TocItem { id: string; title: string }

const stripTags = (s: string) => s.replace(/<[^>]+>/g, "").replace(/&amp;/g, "&").replace(/&quot;/g, '"').replace(/&#39;/g, "'").trim();

/** Adds `id="section-N"` to every <h2> of rendered Markdown and returns the TOC plus a reading-time estimate. */
export function prepareProse(html: string): { html: string; toc: TocItem[]; minutes: number } {
  const toc: TocItem[] = [];
  const out = html.replace(/<h2([^>]*)>([\s\S]*?)<\/h2>/g, (_m, _attrs, inner: string) => {
    const id = `section-${toc.length + 1}`;
    toc.push({ id, title: stripTags(inner) });
    return `<h2 id="${id}">${inner}</h2>`;
  });
  const words = stripTags(html).split(/\s+/).filter(Boolean).length;
  return { html: out, toc, minutes: Math.max(1, Math.round(words / 200)) };
}

const DATE_LOCALE = { en: "en-IN", hi: "hi-IN", hinglish: "en-IN" } as const;

/** Formats a fixed ISO date (YYYY-MM-DD) in UTC so output never depends on server timezone. */
export function formatDate(iso: string, locale: keyof typeof DATE_LOCALE): string {
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return iso;
  return d.toLocaleDateString(DATE_LOCALE[locale], { day: "numeric", month: "long", year: "numeric", timeZone: "UTC" });
}
