import type { Metadata } from "next";
import { pageMetadata } from "@/lib/seo";
import { HubView } from "@/views/HubView";

export const metadata: Metadata = pageMetadata({
  locale: "hi",
  enPath: "/alternatives",
  title: "इधर-उधर फोन करने के विकल्प: टेम्पररी वर्कर",
  description: "देखें कि जब आपको पास में एक दिन या एक हफ्ते के लिए टेम्पररी मदद चाहिए, तब Jugaadi फोन घुमाने या लेबर चौक पर इंतज़ार करने से कैसे अलग है।",
});

export default function AlternativesHubPageHi() {
  return <HubView type="alternative" locale="hi" />;
}
