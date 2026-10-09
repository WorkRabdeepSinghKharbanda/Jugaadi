import { notFound } from "next/navigation";
import { getContent, pathFor, type ContentType } from "@/lib/content";
import type { Locale } from "@/lib/locale";
import { ui } from "@/lib/i18n";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import { Breadcrumbs } from "@/components/Breadcrumbs";
import { Faqs } from "@/components/Faqs";
import { CtaBand } from "@/components/CtaBand";
import { JsonLd } from "@/components/JsonLd";
import { TrustBadge } from "@/components/TrustBadge";
import { breadcrumbList, faqPage, blogPosting } from "@/lib/jsonld";

const HUB: Record<Exclude<ContentType, "landing">, string> = {
  feature: "features",
  alternative: "alternatives",
  blog: "blog",
};

export async function ContentPageView({ type, slug, locale }: { type: ContentType; slug: string; locale: Locale }) {
  const page = await getContent(type, slug, locale);
  if (!page) notFound();

  const t = ui(locale);
  const prefix = locale === "en" ? "" : `/${locale}`;
  const enPath = pathFor({ type, slug, locale: "en" });
  const path = pathFor(page);

  const crumbs = [{ name: t.home, path: locale === "en" ? "/" : `/${locale}` }];
  if (type !== "landing") {
    const hubSlug = HUB[type as Exclude<ContentType, "landing">];
    crumbs.push({ name: t.nav[hubSlug as keyof typeof t.nav], path: `${prefix}/${hubSlug}` });
  }
  crumbs.push({ name: page.title, path });

  const jsonld = [
    breadcrumbList(crumbs),
    faqPage(page.faqs),
    type === "blog" ? blogPosting(page, path) : null,
  ].filter((n): n is NonNullable<typeof n> => n !== null);

  return (
    <>
      <Header locale={locale} path={enPath} />
      <main>
        <article>
          <JsonLd data={jsonld} />
          <Breadcrumbs items={crumbs} />
          {type === "feature" && slug === "verified-workers" && (
            <TrustBadge label={locale === "hi" ? "वेरिफाइड" : locale === "hinglish" ? "Verified" : "Verified"} />
          )}
          <h1>{page.title}</h1>
          {page.date && (
            <p>
              <em>{page.date}</em>
            </p>
          )}
          <div className="prose" dangerouslySetInnerHTML={{ __html: page.html }} />
          <Faqs faqs={page.faqs} locale={locale} />
          {page.competitor && (
            <p style={{ fontSize: 12, color: "var(--text-3)" }}>
              {page.competitor} is a trademark of its respective owner. Jugaadi is not affiliated with,
              endorsed by, or sponsored by {page.competitor}.
            </p>
          )}
          {type === "landing" && (
            <CtaBand
              title={locale === "en" ? "Need a worker, or looking for work?" : t.downloadApp}
              text={locale === "en" ? "Download the app and try it out." : ""}
              primary={{ href: `${prefix}/#download`, label: t.downloadApp }}
            />
          )}
        </article>
      </main>
      <Footer locale={locale} />
    </>
  );
}
