import type { Metadata } from "next";
import { pageMetadata } from "@/lib/seo";
import { DownloadView } from "@/views/DownloadView";

export const metadata: Metadata = pageMetadata({
  locale: "en",
  enPath: "/download",
  title: "Download Jugaadi for Android",
  description: "Download the Jugaadi early-access APK for Android, with install steps and what to know before the Play Store listing.",
});

export default function DownloadPage() {
  return <DownloadView locale="en" />;
}
