import Script from "next/script";
import "@/app/globals.css";
import { JsonLd } from "@/components/JsonLd";
import { website } from "@/lib/jsonld";

const GA_ID = "G-BZFQG9797Y";
const CLARITY_ID = "yv4vy55lfp";

/** Shared <html>/<body> for the per-locale root layouts, so `<html lang>` is correct without headers()/dynamic rendering. */
export function RootShell({ lang, children }: { lang: string; children: React.ReactNode }) {
  return (
    <html lang={lang}>
      <body>
        <Script async src={`https://www.googletagmanager.com/gtag/js?id=${GA_ID}`} />
        <Script id="ga4-init">
          {`window.dataLayer = window.dataLayer || [];
          function gtag(){dataLayer.push(arguments);}
          gtag('js', new Date());
          gtag('config', '${GA_ID}');`}
        </Script>
        <Script id="clarity-init" strategy="lazyOnload">
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
