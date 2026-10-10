import type { Metadata } from "next";
import Script from "next/script";
import "./globals.css";
import { SITE_NAME, SITE_URL } from "@/lib/site";
import { JsonLd } from "@/components/JsonLd";
import { website } from "@/lib/jsonld";

const GA_ID = "G-BZFQG9797Y";
const CLARITY_ID = "yv4vy55lfp";

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: `${SITE_NAME} — Same-day local help, verified nearby`,
    template: `%s — ${SITE_NAME}`,
  },
  description:
    "Jugaadi is a local services marketplace — shop owners and households book verified nearby help for short, same-day tasks, 1 day to 1 week.",
  verification: {
    google: "kCnHcd-bJBBVDMlmVNxSUX0BeGjeyEf17j31SsQBwP8",
  },
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
        <Script id="clarity-init">
          {`(function(c,l,a,r,i,t,y){
            c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
            t=l.createElement(r);t.async=1;t.src="https://www.clarity.ms/tag/"+i;
            y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);
          })(window, document, "clarity", "script", "${CLARITY_ID}");`}
        </Script>
        <JsonLd data={[website()]} />
        {children}
        {/* AdSense script goes here once real ID exists (see plan §5) */}
      </body>
    </html>
  );
}
