import type { Metadata } from "next";
import { pageMetadata } from "@/lib/seo";
import { HubView } from "@/views/HubView";

export const metadata: Metadata = pageMetadata({
  locale: "hinglish",
  enPath: "/alternatives",
  title: "Calling Around Ke Alternatives: Temporary Workers",
  description: "Dekho jab paas mein ek din ya ek hafte ke liye temporary help chahiye, tab Jugaadi contacts ko call karne ya labour chowk par wait karne se kaise alag hai.",
});

export default function AlternativesHubPageHinglish() {
  return <HubView type="alternative" locale="hinglish" />;
}
