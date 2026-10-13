import { notFound } from "next/navigation";
import { getAllContent, getContent, pathFor, type ContentType } from "@/lib/content";
import { ui } from "@/lib/i18n";
import { blogPosting } from "@/lib/jsonld";
import { formatDate, prepareProse } from "@/lib/prose";
import { localePrefix, type Locale } from "@/lib/locale";
import { JsonLd } from "@/components/JsonLd";
import { PageShell } from "@/components/ui/PageShell";
import { DocLayout, PageHero, Prose, Toc } from "@/components/ui/doc";
import { Badge, Section } from "@/components/ui/primitives";
import { CtaBand, Faq, RelatedCards } from "@/components/ui/blocks";
import type { IconName } from "@/components/ui/Icon";

const HUB: Record<Exclude<ContentType, "landing">, string> = { feature: "features", alternative: "alternatives", blog: "blog" };
const TYPE_ICON: Record<ContentType, IconName> = { landing: "pin", feature: "shield", alternative: "call", blog: "book" };

export async function ContentPageView({ type, slug, locale }: { type: ContentType; slug: string; locale: Locale }) {
  const page = await getContent(type, slug, locale);
  if (!page) notFound();

  const t = ui(locale);
  const prefix = localePrefix(locale);
  const enPath = pathFor({ type, slug, locale: "en" });
  const path = pathFor(page);
  const { html, toc, minutes } = prepareProse(page.html);

  const crumbs = [{ name: t.home, path: prefix || "/" }];
  if (type !== "landing") {
    const hub = HUB[type];
    crumbs.push({ name: t.nav[hub as keyof typeof t.nav], path: `${prefix}/${hub}` });
  }
  crumbs.push({ name: page.title, path });

  // Related: up to 3 other pages, chosen to cross-link the clusters (not the same type first).
  const pool: { type: ContentType; first: boolean }[] =
    type === "blog" ? [{ type: "feature", first: true }, { type: "landing", first: true }]
    : type === "landing" ? [{ type: "landing", first: true }, { type: "feature", first: true }]
    : [{ type: "feature", first: true }, { type: "landing", first: true }];
  const related = pool
    .flatMap((p) => getAllContent(p.type, locale))
    .filter((m) => !(m.type === type && m.slug === slug))
    .slice(0, 3)
    .map((m) => ({ title: m.title, description: m.description, href: pathFor(m), icon: TYPE_ICON[m.type] }));

  const meta = type === "blog" ? (
    <>
      <span>{t.by}</span>
      {page.date && <time dateTime={page.date}>{formatDate(page.date, locale)}</time>}
      <span>{minutes} {t.readMin}</span>
    </>
  ) : type === "feature" && slug === "verified-workers" ? <Badge tone="live">{locale === "hi" ? "वेरिफाइड" : "Verified"}</Badge> : undefined;

  return (
    <PageShell locale={locale} path={enPath}>
      {type === "blog" && <JsonLd data={[blogPosting(page, path)]} />}
      <PageHero crumbs={crumbs} title={page.title} lede={page.description} meta={meta} />
      <DocLayout toc={type === "blog" && toc.length > 1 ? <Toc title={t.onThisPage} items={toc} /> : undefined}>
        <article>
          <Prose html={html} />
          {page.competitor && <p className="u-disclaimer">{t.notAffiliated.replaceAll("{c}", page.competitor)}</p>}
        </article>
      </DocLayout>
      {page.faqs.length > 0 && (
        <Section tight title={t.faqHeading} id="faq"><Faq faqs={page.faqs} /></Section>
      )}
      {related.length > 0 && (
        <Section tight title={t.related} id="related"><RelatedCards items={related} moreLabel={t.learnMore} /></Section>
      )}
      <Section tight>
        <CtaBand title={t.ctaTitle} text={t.ctaText} primary={{ href: `${prefix}/download`, label: t.downloadApp }} />
      </Section>
    </PageShell>
  );
}
