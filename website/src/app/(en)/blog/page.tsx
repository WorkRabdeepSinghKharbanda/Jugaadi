import type { Metadata } from "next";
import { pageMetadata } from "@/lib/seo";
import { HubView } from "@/views/HubView";

export const metadata: Metadata = pageMetadata({
  locale: "en",
  enPath: "/blog",
  title: "Blog: Guides on Booking Temporary Workers Nearby",
  description: "Practical guides on booking temporary workers, how verification works, and running a local shop or household with short-notice help.",
});

export default function BlogHubPage() {
  return <HubView type="blog" locale="en" />;
}
