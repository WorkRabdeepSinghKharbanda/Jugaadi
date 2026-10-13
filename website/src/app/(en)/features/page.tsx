import type { Metadata } from "next";
import { pageMetadata } from "@/lib/seo";
import { HubView } from "@/views/HubView";

export const metadata: Metadata = pageMetadata({
  locale: "en",
  enPath: "/features",
  title: "Features: Verified Workers & Instant Booking",
  description: "Explore Jugaadi features: manually verified nearby workers, instant booking, and simple same-day tasks for shop owners, households, and workers.",
});

export default function FeaturesHubPage() {
  return <HubView type="feature" locale="en" />;
}
