import Link from "next/link";
import type { Locale } from "@/lib/locale";
import { localePrefix } from "@/lib/locale";
import { ui } from "@/lib/i18n";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";

const COPY: Record<Locale, { title: string; text: string }> = {
  en: { title: "Page not found", text: "We couldn't find that page. Try one of these instead." },
  hi: { title: "पेज नहीं मिला", text: "यह पेज नहीं मिला। इनमें से कोई दूसरा पेज आज़माएं।" },
  hinglish: { title: "Page nahi mila", text: "Yeh page nahi mila. Inme se koi aur page try karo." },
};

export function NotFoundContent({ locale }: { locale: Locale }) {
  const t = ui(locale);
  const prefix = localePrefix(locale);
  return (
    <>
      <Header locale={locale} />
      <main>
        <h1>{COPY[locale].title}</h1>
        <p>{COPY[locale].text}</p>
        <ul>
          <li>
            <Link href={prefix || "/"}>{t.home}</Link>
          </li>
          <li>
            <Link href={`${prefix}/features`}>{t.nav.features}</Link>
          </li>
          <li>
            <Link href={`${prefix}/download`}>{t.downloadApp}</Link>
          </li>
        </ul>
      </main>
      <Footer locale={locale} />
    </>
  );
}
