import type { Metadata } from "next";
import { pageMetadata } from "@/lib/seo";
import { HubView } from "@/views/HubView";

export const metadata: Metadata = pageMetadata({
  locale: "hi",
  enPath: "/blog",
  title: "ब्लॉग: पास में टेम्पररी वर्कर बुक करने की गाइड",
  description: "टेम्पररी वर्कर बुक करने, वेरिफिकेशन कैसे काम करता है, और लोकल दुकान या घर को कम नोटिस की मदद से चलाने पर प्रैक्टिकल गाइड।",
});

export default function BlogHubPageHi() {
  return <HubView type="blog" locale="hi" />;
}
