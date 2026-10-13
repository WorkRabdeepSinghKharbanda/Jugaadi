import Link from "next/link";
import { getAllContent, pathFor } from "@/lib/content";
import type { Locale } from "@/lib/locale";
import { localePrefix } from "@/lib/locale";
import { ui } from "@/lib/i18n";

/** Small keyword-anchored link block: landing + feature pages and /download, locale-aware. */
export function RelatedLinks({ locale }: { locale: Locale }) {
  const t = ui(locale);
  const links = [...getAllContent("landing", locale), ...getAllContent("feature", locale)].map((m) => ({
    title: m.title,
    path: pathFor(m),
  }));
  links.push({ title: t.downloadApp, path: `${localePrefix(locale)}/download` });
  return (
    <nav aria-label={t.related}>
      <h2>{t.related}</h2>
      <ul>
        {links.map((l) => (
          <li key={l.path}>
            <Link href={l.path}>{l.title}</Link>
          </li>
        ))}
      </ul>
    </nav>
  );
}
