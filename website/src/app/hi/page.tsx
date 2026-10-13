import type { Metadata } from "next";
import { pageMetadata } from "@/lib/seo";
import { HomeView } from "@/views/HomeView";

export const metadata: Metadata = pageMetadata({
  locale: "hi",
  enPath: "/",
  title: { absolute: "Jugaadi — अपने पास वर्कर खोजें" },
  description: "Jugaadi दुकान मालिकों और घरों को पास के वेरिफाइड टेम्पररी वर्कर से जोड़ता है। टास्क पोस्ट करें, पास के वर्कर देखें और उसी दिन बुक करें।",
});

export default function HomePageHi() {
  return <HomeView locale="hi" />;
}
