import Link from "next/link";
import { getAllContent, getContent, pathFor } from "@/lib/content";
import { ui } from "@/lib/i18n";
import { formatDate, prepareProse } from "@/lib/prose";
import type { Locale } from "@/lib/locale";
import { localePrefix } from "@/lib/locale";
import { PageShell } from "@/components/ui/PageShell";
import { PageHero } from "@/components/ui/doc";
import { Section, LinkButton } from "@/components/ui/primitives";
import { CtaBand, PostGrid, UseCaseGrid } from "@/components/ui/blocks";
import type { IconName } from "@/components/ui/Icon";

export const TITLES: Record<"feature" | "alternative" | "blog", Record<Locale, string>> = {
  feature: { en: "Features", hi: "सुविधाएं", hinglish: "Features" },
  alternative: { en: "Alternatives", hi: "विकल्प", hinglish: "Alternatives" },
  blog: { en: "Blog", hi: "ब्लॉग", hinglish: "Blog" },
};

const ICONS: Record<string, IconName> = {
  "verified-workers": "shield",
  "book-instantly": "bolt",
  "alternative-to-calling-around-for-a-worker": "call",
};

const HUB_PATH = { feature: "/features", alternative: "/alternatives", blog: "/blog" } as const;

export async function HubView({ type, locale }: { type: "feature" | "alternative" | "blog"; locale: Locale }) {
  const t = ui(locale);
  const p = localePrefix(locale);
  const metas = getAllContent(type, locale);
  const items = metas.map((m) => ({ title: m.title, description: m.description, href: pathFor(m), date: m.date, slug: m.slug }));
  if (type === "blog") items.sort((a, b) => ((a.date ?? "") < (b.date ?? "") ? 1 : -1));

  const crumbs = [{ name: t.home, path: p || "/" }, { name: TITLES[type][locale], path: `${p}${HUB_PATH[type]}` }];

  const minutesFor = async (slug: string) => {
    const page = await getContent("blog", slug, locale);
    return page ? prepareProse(page.html).minutes : 1;
  };
  const posts = type === "blog"
    ? await Promise.all(items.map(async (i) => ({ ...i, meta: `${i.date ? formatDate(i.date, locale) + " · " : ""}${await minutesFor(i.slug)} ${t.readMin}` })))
    : [];
  const [featured, ...rest] = posts;

  return (
    <PageShell locale={locale} path={HUB_PATH[type]}>
      <PageHero crumbs={crumbs} crumbLabel="Breadcrumb" title={TITLES[type][locale]} />
      {type === "blog" ? (
        <>
          {featured && (
            <Section first>
              <div className="u-card u-featured u-post">
                <div>
                  <span className="u-badge">{t.featured}</span>
                  <p className="u-meta">{featured.meta}</p>
                  <h2><Link href={featured.href}>{featured.title}</Link></h2>
                  <p>{featured.description}</p>
                  <LinkButton href={featured.href} arrow>{t.readPost}</LinkButton>
                </div>
              </div>
            </Section>
          )}
          {rest.length > 0 && (
            <Section tight>
              <PostGrid items={rest} readLabel={t.readPost} />
            </Section>
          )}
        </>
      ) : (
        <Section first>
          <UseCaseGrid items={items.map((i) => ({ title: i.title, description: i.description, href: i.href, icon: ICONS[i.slug] ?? "tag" }))} moreLabel={t.learnMore} />
        </Section>
      )}
      <Section>
        <CtaBand title={t.ctaTitle} text={t.ctaText} primary={{ href: `${p}/download`, label: t.downloadApp }} />
      </Section>
    </PageShell>
  );
}
