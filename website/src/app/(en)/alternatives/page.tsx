import type { Metadata } from "next";
import { pageMetadata } from "@/lib/seo";
import { HubView } from "@/views/HubView";

export const metadata: Metadata = pageMetadata({
  locale: "en",
  enPath: "/alternatives",
  title: "Alternatives to Calling Around for Temporary Workers",
  description: "See how Jugaadi compares to calling contacts or waiting at a labour corner when you need temporary help nearby, for a day or a week.",
});

export default function AlternativesHubPage() {
  return <HubView type="alternative" locale="en" />;
}
