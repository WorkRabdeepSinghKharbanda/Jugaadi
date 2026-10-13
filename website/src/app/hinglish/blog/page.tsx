import type { Metadata } from "next";
import { pageMetadata } from "@/lib/seo";
import { HubView } from "@/views/HubView";

export const metadata: Metadata = pageMetadata({
  locale: "hinglish",
  enPath: "/blog",
  title: "Blog: Temporary Workers Book Karne Ki Guides",
  description: "Temporary workers book karne, verification kaise kaam karta hai, aur local shop ya ghar ko kam notice ki help se chalane par practical guides.",
});

export default function BlogHubPageHinglish() {
  return <HubView type="blog" locale="hinglish" />;
}
