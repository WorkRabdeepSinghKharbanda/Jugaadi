import type { Metadata } from "next";
import { pageMetadata } from "@/lib/seo";

// Placeholder text: keep out of the index (and sitemap) until a real policy replaces it.
export const metadata: Metadata = pageMetadata({
  locale: "en",
  enPath: "/privacy",
  title: "Privacy Policy: How Jugaadi Handles Your Data",
  description: "How Jugaadi collects, uses, and protects your data when you book or respond to nearby tasks. This pilot-stage page will be replaced by a full policy.",
  noindex: true,
});

export default function PrivacyPage() {
  return (
    <>
      <h1>Privacy Policy</h1>
      <p>
        <em>Last updated: 2026-10-09</em>
      </p>
      <p>
        This is a placeholder privacy policy for Jugaadi&apos;s pilot. Replace this with a real policy
        covering what data is collected (name, phone, location, skills), how it&apos;s stored (Supabase),
        who it&apos;s shared with (the other party on a booking, never sold to third parties), and how users
        can request deletion — before public launch or app store submission.
      </p>
    </>
  );
}
