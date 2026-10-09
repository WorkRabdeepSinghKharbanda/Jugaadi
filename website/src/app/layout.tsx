import type { Metadata } from "next";
import Script from "next/script";
import "./globals.css";
import { SITE_NAME, SITE_URL } from "@/lib/site";
import { JsonLd } from "@/components/JsonLd";
import { website } from "@/lib/jsonld";

const GA_ID = "G-BZFQG9797Y";

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
        <Script async src={`https://www.googletagmanager.com/gtag/js?id=${GA_ID}`} />
        <Script id="ga4-init">
          {`window.dataLayer = window.dataLayer || [];
          function gtag(){dataLayer.push(arguments);}
          gtag('js', new Date());
          gtag('config', '${GA_ID}');`}
        </Script>
        <JsonLd data={[website()]} />
        {children}
        {/* AdSense script goes here once real ID exists (see plan §5) */}
      </body>
    </html>
  );
}
