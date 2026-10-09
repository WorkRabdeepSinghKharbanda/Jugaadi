import type { Metadata } from "next";
import { HubView } from "@/views/HubView";

export const metadata: Metadata = {
  title: "Alternatives",
  description: "How Jugaadi compares to the usual ways of finding temporary help.",
};

export default function AlternativesHubPage() {
  return <HubView type="alternative" locale="en" />;
}
