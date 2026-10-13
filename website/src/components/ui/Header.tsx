import Link from "next/link";
import { ui } from "@/lib/i18n";
import { HTML_LANG } from "@/lib/seo";
import { LOCALES, LOCALE_LABELS, localePrefix, localizedPath, type Locale } from "@/lib/locale";
import { Icon } from "@/components/ui/Icon";
import { LinkButton } from "@/components/ui/primitives";

export function BrandMark({ size = 30 }: { size?: number }) {
  return (
    <svg className="u-brand-mark" width={size} height={size} viewBox="0 0 32 32" aria-hidden="true" focusable="false">
      <defs>
        <linearGradient id="bm" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stopColor="#E8A33D" /><stop offset="1" stopColor="#C17B1D" />
        </linearGradient>
      </defs>
      <rect width="32" height="32" rx="9" fill="url(#bm)" />
      <path d="M19 7v12a4 4 0 01-8 0" fill="none" stroke="#0B0B0F" strokeWidth="3.4" strokeLinecap="round" />
    </svg>
  );
}

export function Brand({ locale }: { locale: Locale }) {
  return (
    <Link href={localePrefix(locale) || "/"} className="u-brand" aria-label="Jugaadi">
      <BrandMark />
      <span>Jug<span>aadi</span></span>
    </Link>
  );
}

function LangSwitch({ locale, path }: { locale: Locale; path: string }) {
  const t = ui(locale);
  return (
    <div className="u-lang" role="group" aria-label={t.language}>
      {LOCALES.map((l) => (
        <Link key={l} href={localizedPath(l, path)} lang={HTML_LANG[l]} hrefLang={HTML_LANG[l]} aria-current={l === locale ? "true" : undefined}>
          {LOCALE_LABELS[l]}
        </Link>
      ))}
    </div>
  );
}

/** Sticky header. Mobile menu is a native <details>, so it is keyboard-operable and needs no client JS. */
export function Header({ locale, path = "/", hideLocales }: { locale: Locale; path?: string; hideLocales?: boolean }) {
  const t = ui(locale);
  const p = localePrefix(locale);
  const links = [
    { href: `${p}/features`, label: t.nav.features },
    { href: `${p}/alternatives`, label: t.nav.alternatives },
    { href: `${p}/blog`, label: t.nav.blog },
    { href: `${p || "/"}#pricing`, label: t.nav.pricing }, // pricing lives on each locale's home page
  ];
  return (
    <header className="u-header">
      <a className="u-skip" href="#main">{t.skip}</a>
      <div className="u-container u-header-row">
        <Brand locale={locale} />
        <nav className="u-nav" aria-label={t.primaryNav}>
          {links.map((l) => <Link key={l.label} className="u-link" href={l.href}>{l.label}</Link>)}
        </nav>
        <div className="u-header-right">
          {!hideLocales && <div className="u-nav"><LangSwitch locale={locale} path={path} /></div>}
          <span className="u-header-cta"><LinkButton href={`${p}/download`} size="sm">{t.downloadApp}</LinkButton></span>
          <details className="u-menu">
            <summary aria-label={t.menu}><Icon name="menu" /></summary>
            <nav className="u-menu-panel" aria-label={t.mobileNav}>
              {links.map((l) => <Link key={l.label} className="u-link" href={l.href}>{l.label}</Link>)}
              {!hideLocales && <LangSwitch locale={locale} path={path} />}
              <LinkButton href={`${p}/download`}>{t.downloadApp}</LinkButton>
            </nav>
          </details>
        </div>
      </div>
    </header>
  );
}
