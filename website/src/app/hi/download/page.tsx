import type { Metadata } from "next";
import { pageMetadata } from "@/lib/seo";
import { DownloadView } from "@/views/DownloadView";

export const metadata: Metadata = pageMetadata({
  locale: "hi",
  enPath: "/download",
  title: "Jugaadi एंड्रॉइड के लिए डाउनलोड करें",
  description: "Jugaadi अर्ली-एक्सेस APK एंड्रॉइड के लिए डाउनलोड करें, इंस्टॉल स्टेप्स के साथ।",
});

export default function DownloadPageHi() {
  return <DownloadView locale="hi" />;
}
