import Link from "next/link";
import type { Locale } from "@/lib/locale";
import { LOCALE_LABELS, LOCALES, localizedPath } from "@/lib/locale";
import { ui } from "@/lib/i18n";

export function Header({ locale, path = "/" }: { locale: Locale; path?: string }) {
  const t = ui(locale);
  const home = locale === "en" ? "/" : `/${locale}`;
  return (
    <header className="site-header">
      <div className="wrap row">
        <Link href={home} className="brand">
          <span className="bt">
            Jug<span>aadi</span>
          </span>
        </Link>
        <nav aria-label="Primary">
          <Link href={`${home === "/" ? "" : home}/features`}>{t.nav.features}</Link>
          <Link href={`${home === "/" ? "" : home}/alternatives`}>{t.nav.alternatives}</Link>
          <Link href={`${home === "/" ? "" : home}/blog`}>{t.nav.blog}</Link>
          <span className="lang-switch">
            {LOCALES.map((l) => (
              <Link key={l} href={localizedPath(l, path)} className={l === locale ? "active" : ""}>
                {LOCALE_LABELS[l]}
              </Link>
            ))}
          </span>
        </nav>
        <Link href={`${home === "/" ? "" : home}/#download`} className="btn sm">
          {t.downloadApp}
        </Link>
      </div>
    </header>
  );
}
