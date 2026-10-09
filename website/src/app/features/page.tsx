import type { Metadata } from "next";
import { HubView } from "@/views/HubView";

export const metadata: Metadata = {
  title: "Features",
  description: "What Jugaadi does for shop owners, households, and workers.",
};

export default function FeaturesHubPage() {
  return <HubView type="feature" locale="en" />;
}
