import type { Metadata } from "next";
import { pageMetadata } from "@/lib/seo";
import { HubView } from "@/views/HubView";

export const metadata: Metadata = pageMetadata({
  locale: "hi",
  enPath: "/features",
  title: "सुविधाएं: वेरिफाइड वर्कर और तुरंत बुकिंग",
  description: "Jugaadi की सुविधाएं देखें: पास के मैन्युअली वेरिफाइड वर्कर, तुरंत बुकिंग, और दुकान मालिकों, घरों और वर्कर्स के लिए उसी दिन के आसान टास्क।",
});

export default function FeaturesHubPageHi() {
  return <HubView type="feature" locale="hi" />;
}
