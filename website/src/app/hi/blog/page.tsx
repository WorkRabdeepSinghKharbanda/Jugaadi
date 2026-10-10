import type { Metadata } from "next";
import { HubView, TITLES } from "@/views/HubView";

export const metadata: Metadata = {
  title: TITLES.blog.hi,
  description: "टेम्पररी वर्कर हायर करने और लोकल दुकान चलाने पर प्रैक्टिकल गाइड।",
};

export default function BlogHubPageHi() {
  return <HubView type="blog" locale="hi" />;
}
