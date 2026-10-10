import type { Metadata } from "next";
import { HubView, TITLES } from "@/views/HubView";

export const metadata: Metadata = {
  title: TITLES.feature.hinglish,
  description: "Shop owners, households, aur workers ke liye Jugaadi kya karta hai.",
};

export default function FeaturesHubPageHinglish() {
  return <HubView type="feature" locale="hinglish" />;
}
