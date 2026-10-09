import type { Metadata } from "next";
import Link from "next/link";
import "./globals.css";
import { SITE_NAME, SITE_URL } from "@/lib/site";

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: `${SITE_NAME} — Find temporary workers near you`,
    template: `%s — ${SITE_NAME}`,
  },
  description:
    "Jugaadi connects shop owners and households with verified nearby workers for 1 day to 1 week gigs.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <header>
          <nav style={{ display: "flex", gap: "1rem", marginBottom: "2rem" }}>
            <Link href="/">
              <strong>{SITE_NAME}</strong>
            </Link>
            <Link href="/blog">Blog</Link>
          </nav>
        </header>
        <main
          style={{
            maxWidth: "42rem",
            margin: "0 auto",
            padding: "1.5rem",
            fontFamily: "system-ui, sans-serif",
            lineHeight: 1.6,
          }}
        >
          {children}
          <footer style={{ marginTop: "3rem", fontSize: "0.875rem", color: "#666" }}>
            <p>
              &copy; 2026 {SITE_NAME} · <Link href="/privacy">Privacy</Link> ·{" "}
              <Link href="/terms">Terms</Link>
            </p>
          </footer>
        </main>
        {/* AdSense + GA4 scripts go here once real IDs exist (see plan §5) */}
      </body>
    </html>
  );
}
