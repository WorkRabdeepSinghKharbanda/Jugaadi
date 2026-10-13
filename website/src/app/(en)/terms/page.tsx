import type { Metadata } from "next";
import { pageMetadata } from "@/lib/seo";

// Placeholder text: keep out of the index (and sitemap) until real terms replace it.
export const metadata: Metadata = pageMetadata({
  locale: "en",
  enPath: "/terms",
  title: "Terms of Service: Using the Jugaadi Platform",
  description: "Terms for using the Jugaadi platform to book or respond to nearby tasks. This pilot-stage page will be replaced by full terms before public launch.",
  noindex: true,
});

export default function TermsPage() {
  return (
    <>
      <h1>Terms of Service</h1>
      <p>
        <em>Last updated: 2026-10-09</em>
      </p>
      <p>
        This is a placeholder terms page for Jugaadi&apos;s pilot. Replace this with real terms before
        public launch — covering that Jugaadi connects owners and workers but is not a party to payment
        (handled directly between them in the MVP), verification is a manual best-effort check and not a
        guarantee, and account/content rules.
      </p>
    </>
  );
}
