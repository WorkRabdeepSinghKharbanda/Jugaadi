import type { MetadataRoute } from "next";
import { getAllContent, pathFor } from "@/lib/content";
import { LOCALES } from "@/lib/locale";
import { SITE_URL } from "@/lib/site";

export default function sitemap(): MetadataRoute.Sitemap {
  const staticPages = LOCALES.flatMap((locale) => {
    const prefix = locale === "en" ? "" : `/${locale}`;
    return ["", "/blog", "/features", "/alternatives"].map((path) => ({
      url: path === "" ? `${SITE_URL}${prefix || "/"}` : `${SITE_URL}${prefix}${path}`,
      lastModified: new Date(),
    }));
  });

  const legalPages = ["/privacy", "/terms"].map((path) => ({ url: `${SITE_URL}${path}`, lastModified: new Date() }));

  const content = LOCALES.flatMap((locale) =>
    (["landing", "feature", "alternative", "blog"] as const).flatMap((type) =>
      getAllContent(type, locale).map((m) => ({
        url: `${SITE_URL}${pathFor(m)}`,
        lastModified: m.date ? new Date(m.date) : new Date(),
      })),
    ),
  );

  return [...staticPages, ...legalPages, ...content];
}
