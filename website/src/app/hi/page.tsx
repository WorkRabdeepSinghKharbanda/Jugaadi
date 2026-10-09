import type { Metadata } from "next";
import { HomeView } from "@/views/HomeView";

export const metadata: Metadata = {
  title: "Jugaadi — अपने पास वर्कर खोजें",
  description: "Jugaadi दुकान मालिकों और घरों को पास के वेरिफाइड टेम्पररी वर्कर से जोड़ता है।",
};

export default function HomePageHi() {
  return <HomeView locale="hi" />;
}
