import Link from "next/link";
import { getAllContent, pathFor } from "@/lib/content";
import { ui } from "@/lib/i18n";
import { HTML_LANG } from "@/lib/seo";
import { LOCALES, LOCALE_LABELS, localePrefix, localizedPath, type Locale } from "@/lib/locale";
import { Brand } from "@/components/ui/Header";

interface Item { title: string; path: string }

function Col({ heading, items }: { heading: string; items: Item[] }) {
  if (items.length === 0) return null;
  return (
    <div>
      <h2>{heading}</h2>
      <ul>
        {items.map((p) => <li key={p.path}><Link href={p.path}>{p.title}</Link></li>)}
      </ul>
    </div>
  );
}

export function Footer({ locale, path = "/", hideLocales }: { locale: Locale; path?: string; hideLocales?: boolean }) {
  const t = ui(locale);
  const p = localePrefix(locale);
  const toItems = (type: "landing" | "feature" | "alternative") =>
    getAllContent(type, locale).map((m) => ({ title: m.title, path: pathFor(m) }));

  return (
    <footer className="u-footer">
      <div className="u-container">
        <div className="u-footer-grid">
          <div className="u-footer-about">
            <Brand locale={locale} />
            <p>{t.footerAbout}</p>
          </div>
          <Col heading={t.footer.findWorkers} items={toItems("landing")} />
          <Col heading={t.footer.features} items={[{ title: t.allFeatures, path: `${p}/features` }, ...toItems("feature"), { title: t.downloadApp, path: `${p}/download` }]} />
          <Col heading={t.footer.compare} items={[{ title: t.allComparisons, path: `${p}/alternatives` }, ...toItems("alternative")]} />
          <Col heading={t.footer.company} items={[{ title: t.nav.blog, path: `${p}/blog` }]} />
          <Col heading={t.legal} items={[{ title: t.privacy, path: "/privacy" }, { title: t.terms, path: "/terms" }, { title: t.deleteAccount, path: "/delete-account" }]} />
        </div>
        <div className="u-footer-bottom">
          <p>&copy; 2026 Jugaadi. {t.footerCopy}</p>
          {!hideLocales && (
            <nav aria-label={t.language}>
              <div className="u-lang">
                {LOCALES.map((l) => (
                  <Link key={l} href={localizedPath(l, path)} lang={HTML_LANG[l]} hrefLang={HTML_LANG[l]} aria-current={l === locale ? "true" : undefined}>
                    {LOCALE_LABELS[l]}
                  </Link>
                ))}
              </div>
            </nav>
          )}
        </div>
      </div>
    </footer>
  );
}
