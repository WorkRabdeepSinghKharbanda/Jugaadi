import { getAllContent, pathFor, type ContentType } from "@/lib/content";
import type { Locale } from "@/lib/locale";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import { PageList } from "@/components/PageList";
import { FeatureCard } from "@/components/FeatureCard";

export const TITLES: Record<"feature" | "alternative" | "blog", Record<Locale, string>> = {
  feature: { en: "Features", hi: "सुविधाएं", hinglish: "Features" },
  alternative: { en: "Alternatives", hi: "विकल्प", hinglish: "Alternatives" },
  blog: { en: "Blog", hi: "ब्लॉग", hinglish: "Blog" },
};

const ICONS: Record<string, string> = {
  "verified-workers": "✅",
  "hire-instantly": "⚡",
  "alternative-to-calling-around-for-a-worker": "📞",
};

export function HubView({ type, locale }: { type: "feature" | "alternative" | "blog"; locale: Locale }) {
  const enPath = type === "feature" ? "/features" : type === "alternative" ? "/alternatives" : "/blog";
  const items = getAllContent(type as ContentType, locale)
    .map((m) => ({ title: m.title, description: m.description, path: pathFor(m), date: m.date, slug: m.slug }))
    .sort((a, b) => (type === "blog" ? ((a.date ?? "") < (b.date ?? "") ? 1 : -1) : 0));

  return (
    <>
      <Header locale={locale} path={enPath} />
      <main>
        <h1>{TITLES[type][locale]}</h1>
        {type === "blog" ? (
          <PageList items={items} />
        ) : (
          <div className="cards">
            {items.map((p) => (
              <FeatureCard key={p.path} icon={ICONS[p.slug] ?? "🔧"} title={p.title} description={p.description} path={p.path} />
            ))}
          </div>
        )}
      </main>
      <Footer locale={locale} />
    </>
  );
}
