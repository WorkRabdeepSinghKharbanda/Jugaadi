import type { Metadata } from "next";
import { HomeView } from "@/views/HomeView";

export const metadata: Metadata = {
  title: "Jugaadi — Apne Paas Worker Dhoondo",
  description: "Jugaadi shop owners aur gharon ko paas ke verified temporary workers se jodta hai.",
};

export default function HomePageHinglish() {
  return <HomeView locale="hinglish" />;
}
