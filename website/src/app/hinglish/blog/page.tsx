import type { Metadata } from "next";
import { HubView, TITLES } from "@/views/HubView";

export const metadata: Metadata = {
  title: TITLES.blog.hinglish,
  description: "Temporary workers hire karne aur local shops chalane par practical guides.",
};

export default function BlogHubPageHinglish() {
  return <HubView type="blog" locale="hinglish" />;
}
