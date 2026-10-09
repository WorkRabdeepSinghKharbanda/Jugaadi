import type { Metadata } from "next";
import { DownloadView } from "@/views/DownloadView";

export const metadata: Metadata = {
  title: "Jugaadi एंड्रॉइड के लिए डाउनलोड करें",
  description: "Jugaadi अर्ली-एक्सेस APK एंड्रॉइड के लिए डाउनलोड करें, इंस्टॉल स्टेप्स के साथ।",
};

export default function DownloadPageHi() {
  return <DownloadView locale="hi" />;
}
