import type { Metadata } from "next";
import "./globals.css";
import { SITE_NAME, SITE_URL } from "@/lib/site";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import { JsonLd } from "@/components/JsonLd";
import { website } from "@/lib/jsonld";

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
        <JsonLd data={[website()]} />
        <Header />
        <main>{children}</main>
        <Footer />
        {/* AdSense + GA4 scripts go here once real IDs exist (see plan §5) */}
      </body>
    </html>
  );
}
