import { getAllContent, pathFor } from "@/lib/content";
import { homeCopy } from "@/lib/home-copy";
import { ui } from "@/lib/i18n";
import type { Locale } from "@/lib/locale";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import { PageList } from "@/components/PageList";
import { Faqs } from "@/components/Faqs";
import { CtaBand } from "@/components/CtaBand";

export function HomeView({ locale }: { locale: Locale }) {
  const c = homeCopy(locale);
  const landing = getAllContent("landing", locale).map((m) => ({ title: m.title, description: m.description, path: pathFor(m) }));

  return (
    <>
      <Header locale={locale} path="/" />
      <main>
        <section className="hero">
          <h1>{c.heroH1}</h1>
          <p className="lede">{c.heroLede}</p>
          <p className="cta-row">
            <a href="#waitlist" className="btn">
              {c.ctaOwner}
            </a>
            <a href="#waitlist" className="btn ghost">
              {c.ctaWorker}
            </a>
          </p>
        </section>

        <section>
          <h2>{c.howHeading}</h2>
          <h3>{c.howOwnerH}</h3>
          <ol>
            {c.howOwnerSteps.map((s) => (
              <li key={s}>{s}</li>
            ))}
          </ol>
          <h3>{c.howWorkerH}</h3>
          <ol>
            {c.howWorkerSteps.map((s) => (
              <li key={s}>{s}</li>
            ))}
          </ol>
        </section>

        <PageList heading={c.findWorkersHeading} items={landing} />

        <section>
          <h2>{c.whoHeading}</h2>
          <ul>
            {c.whoItems.map((s) => (
              <li key={s}>{s}</li>
            ))}
          </ul>
        </section>

        <Faqs faqs={c.faqs} locale={locale} />

        <section id="waitlist">
          <div className="cta-band">
            <h2>{c.pilotHeading}</h2>
            <p>{c.pilotText}</p>
            <form style={{ display: "flex", gap: 8, justifyContent: "center", flexWrap: "wrap" }}>
              <input
                type="text"
                name="contact"
                placeholder={c.waitlistPlaceholder}
                required
                style={{
                  padding: "10px 16px",
                  borderRadius: "var(--r-pill)",
                  border: "1px solid var(--outline)",
                  background: "var(--surface)",
                  color: "var(--text)",
                }}
              />
              <button type="submit" disabled title="Coming soon" className="btn">
                {ui(locale).joinWaitlist}
              </button>
            </form>
          </div>
        </section>

        <CtaBand title={c.seeHowHeading} text={c.seeHowText} primary={{ href: locale === "en" ? "/features" : `/${locale}/features`, label: c.browseFeatures }} />
      </main>
      <Footer locale={locale} />
    </>
  );
}
