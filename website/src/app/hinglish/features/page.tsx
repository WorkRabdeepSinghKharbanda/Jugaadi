import type { Metadata } from "next";
import { pageMetadata } from "@/lib/seo";
import { HubView } from "@/views/HubView";

export const metadata: Metadata = pageMetadata({
  locale: "hinglish",
  enPath: "/features",
  title: "Features: Verified Workers Aur Instant Booking",
  description: "Jugaadi ke features dekho: paas ke manually verified workers, instant booking, aur shop owners, gharon aur workers ke liye usi din ke aasaan tasks.",
});

export default function FeaturesHubPageHinglish() {
  return <HubView type="feature" locale="hinglish" />;
}
