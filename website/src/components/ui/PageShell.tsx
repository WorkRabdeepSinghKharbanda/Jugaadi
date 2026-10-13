import type { ReactNode } from "react";
import type { Locale } from "@/lib/locale";
import { Header } from "@/components/ui/Header";
import { Footer } from "@/components/ui/Footer";

/** Header + <main id="main"> + Footer. Every page renders inside this. `hideLocales` for English-only pages. */
export function PageShell({ locale, path = "/", hideLocales, children }: { locale: Locale; path?: string; hideLocales?: boolean; children: ReactNode }) {
  return (
    <>
      <Header locale={locale} path={path} hideLocales={hideLocales} />
      <main id="main" className="u-main">{children}</main>
      <Footer locale={locale} path={path} hideLocales={hideLocales} />
    </>
  );
}
