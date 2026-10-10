import type { Metadata } from "next";
import { HubView, TITLES } from "@/views/HubView";

export const metadata: Metadata = {
  title: TITLES.feature.hi,
  description: "दुकान मालिकों, घरों, और वर्कर्स के लिए Jugaadi क्या करता है।",
};

export default function FeaturesHubPageHi() {
  return <HubView type="feature" locale="hi" />;
}
