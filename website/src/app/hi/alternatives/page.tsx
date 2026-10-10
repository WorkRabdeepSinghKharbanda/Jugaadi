import type { Metadata } from "next";
import { HubView, TITLES } from "@/views/HubView";

export const metadata: Metadata = {
  title: TITLES.alternative.hi,
  description: "अस्थायी मदद ढूंढने के सामान्य तरीकों से Jugaadi कैसे अलग है।",
};

export default function AlternativesHubPageHi() {
  return <HubView type="alternative" locale="hi" />;
}
