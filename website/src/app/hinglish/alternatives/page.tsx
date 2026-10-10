import type { Metadata } from "next";
import { HubView, TITLES } from "@/views/HubView";

export const metadata: Metadata = {
  title: TITLES.alternative.hinglish,
  description: "Temporary help dhoondhne ke usual tareekon se Jugaadi kaise compare karta hai.",
};

export default function AlternativesHubPageHinglish() {
  return <HubView type="alternative" locale="hinglish" />;
}
