import type { MetadataRoute } from "next";
import { getAllContent, pathFor } from "@/lib/content";
import { SITE_URL } from "@/lib/site";

export default function sitemap(): MetadataRoute.Sitemap {
  const staticPages = ["", "/blog", "/features", "/alternatives", "/privacy", "/terms"].map((path) => ({
    url: `${SITE_URL}${path}`,
    lastModified: new Date(),
  }));

  const content = (["landing", "feature", "alternative", "blog"] as const).flatMap((type) =>
    getAllContent(type).map((m) => ({
      url: `${SITE_URL}${pathFor(m)}`,
      lastModified: m.date ? new Date(m.date) : new Date(),
    })),
  );

  return [...staticPages, ...content];
}
