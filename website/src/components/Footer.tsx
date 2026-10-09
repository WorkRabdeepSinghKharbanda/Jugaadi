import Link from "next/link";
import { getAllContent, pathFor } from "@/lib/content";
import type { Locale } from "@/lib/locale";
import { ui } from "@/lib/i18n";

function Col({ heading, items }: { heading: string; items: { title: string; path: string }[] }) {
  if (items.length === 0) return null;
  return (
    <div>
      <h2>{heading}</h2>
      <ul>
        {items.map((p) => (
          <li key={p.path}>
            <Link href={p.path}>{p.title}</Link>
          </li>
        ))}
      </ul>
    </div>
  );
}

export function Footer({ locale }: { locale: Locale }) {
  const t = ui(locale);
  const home = locale === "en" ? "/" : `/${locale}`;
  const prefix = home === "/" ? "" : home;

  const landing = getAllContent("landing", locale).map((m) => ({ title: m.title, path: pathFor(m) }));
  const features = getAllContent("feature", locale).map((m) => ({ title: m.title, path: pathFor(m) }));
  const alternatives = getAllContent("alternative", locale).map((m) => ({ title: m.title, path: pathFor(m) }));

  return (
    <footer className="site-footer">
      <div className="wrap top">
        <div className="about">
          <Link href={home} className="brand">
            <span className="bt">
              Jug<span>aadi</span>
            </span>
          </Link>
          <p>{t.footerAbout}</p>
        </div>
        <Col heading={t.footer.findWorkers} items={landing} />
        <Col heading={t.footer.features} items={[{ title: t.allFeatures, path: `${prefix}/features` }, ...features]} />
        <Col heading={t.footer.compare} items={[{ title: t.allComparisons, path: `${prefix}/alternatives` }, ...alternatives]} />
        <Col
          heading={t.footer.company}
          items={[
            { title: t.nav.blog, path: `${prefix}/blog` },
            { title: t.privacy, path: "/privacy" },
            { title: t.terms, path: "/terms" },
          ]}
        />
      </div>
      <div className="wrap small">
        <p>&copy; 2026 Jugaadi. {t.footerCopy}</p>
      </div>
    </footer>
  );
}
