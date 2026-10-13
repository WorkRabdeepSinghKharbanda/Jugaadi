import type { Metadata } from "next";
import { NotFoundContent } from "@/components/NotFoundContent";
import { RootShell } from "@/components/RootShell";
import { SITE_URL } from "@/lib/site";

// Multiple root layouts (one per locale) means no shared layout for a 404, so this renders its own document.
export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: "Page not found — Jugaadi",
  robots: { index: false, follow: true },
};

export default function GlobalNotFound() {
  return (
    <RootShell lang="en">
      <NotFoundContent locale="en" />
    </RootShell>
  );
}
