import type { Metadata } from "next";
import { pageMetadata } from "@/lib/seo";
import { DownloadView } from "@/views/DownloadView";

export const metadata: Metadata = pageMetadata({
  locale: "hinglish",
  enPath: "/download",
  title: "Jugaadi Android ke liye download karo",
  description: "Jugaadi early-access APK Android ke liye download karo, install steps ke saath.",
});

export default function DownloadPageHinglish() {
  return <DownloadView locale="hinglish" />;
}
