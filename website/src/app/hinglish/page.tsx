import type { Metadata } from "next";
import { pageMetadata } from "@/lib/seo";
import { HomeView } from "@/views/HomeView";

export const metadata: Metadata = pageMetadata({
  locale: "hinglish",
  enPath: "/",
  title: { absolute: "Jugaadi — Apne Paas Worker Dhoondo" },
  description: "Jugaadi shop owners aur gharon ko paas ke verified temporary workers se jodta hai. Task post karo, nearby workers dekho aur usi din book karo.",
});

export default function HomePageHinglish() {
  return <HomeView locale="hinglish" />;
}
