import type { Metadata } from "next";
import Link from "next/link";
import "@/app/globals.css";
import { SITE_URL } from "@/lib/site";

// Multiple root layouts (one per locale) means no shared layout for a 404, so this renders its own document.
export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: "Page not found — Jugaadi",
  robots: { index: false, follow: true },
};

export default function GlobalNotFound() {
  return (
    <html lang="en">
      <body>
        <main>
          <h1>Page not found</h1>
          <p>We couldn&apos;t find that page. Try one of these instead.</p>
          <ul>
            <li>
              <Link href="/">Jugaadi home</Link>
            </li>
            <li>
              <Link href="/features">Features</Link>
            </li>
            <li>
              <Link href="/download">Download the app</Link>
            </li>
          </ul>
        </main>
      </body>
    </html>
  );
}
