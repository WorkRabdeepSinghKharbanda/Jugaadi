import type { MetadataRoute } from "next";
import { getAllContent, pathFor } from "@/lib/content";
import { LOCALES, localizedPath } from "@/lib/locale";
import { SITE_URL } from "@/lib/site";

// Last real edit per page group (bump when that group's copy changes).
const LAST_MODIFIED = {
  "/": "2026-10-10",
  "/blog": "2026-10-10",
  "/features": "2026-10-10",
  "/alternatives": "2026-10-10",
  "/download": "2026-10-13",
  landing: "2026-10-10",
  feature: "2026-10-10",
  alternative: "2026-10-10",
  blog: "2026-10-10",
} as const;

export default function sitemap(): MetadataRoute.Sitemap {
  const staticPages = LOCALES.flatMap((locale) =>
    (["/", "/blog", "/features", "/alternatives", "/download"] as const).map((path) => ({
      url: `${SITE_URL}${localizedPath(locale, path)}`,
      lastModified: new Date(LAST_MODIFIED[path]),
    })),
  );

  const content = LOCALES.flatMap((locale) =>
    (["landing", "feature", "alternative", "blog"] as const).flatMap((type) =>
      getAllContent(type, locale).map((m) => ({
        url: `${SITE_URL}${pathFor(m)}`,
        lastModified: new Date(m.date ?? LAST_MODIFIED[type]),
      })),
    ),
  );

  const legal = [
    { url: `${SITE_URL}/privacy`, lastModified: new Date("2026-10-13") },
    { url: `${SITE_URL}/terms`, lastModified: new Date("2026-10-14") },
  ];

  return [...staticPages, ...legal, ...content];
}
