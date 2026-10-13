import type { Metadata } from "next";
import { DEFAULT_TITLE, pageMetadata } from "@/lib/seo";
import { HomeView } from "@/views/HomeView";

export const metadata: Metadata = pageMetadata({
  locale: "en",
  enPath: "/",
  title: { absolute: DEFAULT_TITLE },
  description: "Jugaadi is a local services marketplace — shop owners and households book verified nearby help for short, same-day tasks, 1 day to 1 week.",
});

export default function HomePage() {
  return <HomeView locale="en" />;
}
