import type { Locale } from "@/lib/locale";
import { localePrefix } from "@/lib/locale";
import { ui } from "@/lib/i18n";
import { Container, LinkButton } from "@/components/ui/primitives";
import { PageShell } from "@/components/ui/PageShell";

const COPY: Record<Locale, { title: string; text: string }> = {
  en: { title: "Page not found", text: "We couldn't find that page. Try one of these instead." },
  hi: { title: "पेज नहीं मिला", text: "यह पेज नहीं मिला। इनमें से कोई दूसरा पेज आज़माएं।" },
  hinglish: { title: "Page nahi mila", text: "Yeh page nahi mila. Inme se koi aur page try karo." },
};

export function NotFoundContent({ locale }: { locale: Locale }) {
  const t = ui(locale);
  const prefix = localePrefix(locale);
  return (
    <PageShell locale={locale} hideLocales>
      <Container>
        <div className="u-notfound">
          <div className="code" aria-hidden="true">404</div>
          <h1>{COPY[locale].title}</h1>
          <p>{COPY[locale].text}</p>
          <div className="u-cta-row">
            <LinkButton href={prefix || "/"}>{t.home}</LinkButton>
            <LinkButton href={`${prefix}/features`} variant="ghost">{t.nav.features}</LinkButton>
            <LinkButton href={`${prefix}/download`} variant="ghost">{t.downloadApp}</LinkButton>
          </div>
        </div>
      </Container>
    </PageShell>
  );
}
