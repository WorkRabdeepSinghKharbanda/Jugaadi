import { getAllContent, pathFor } from "@/lib/content";
import { homeCopy } from "@/lib/home-copy";
import { ui } from "@/lib/i18n";
import type { Locale } from "@/lib/locale";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import { FeatureCard } from "@/components/FeatureCard";
import { HowItWorksTabs } from "@/components/HowItWorksTabs";
import { Faqs } from "@/components/Faqs";
import { CtaBand } from "@/components/CtaBand";

const LANDING_ICONS: Record<string, string> = {
  "temporary-worker-near-me": "🧑‍🔧",
  "maid-for-a-day-near-me": "🏠",
  "shop-helper-near-me": "🏪",
};
const WHO_ICONS = ["🏪", "🏢", "🏠", "💼"];

export function HomeView({ locale }: { locale: Locale }) {
  const c = homeCopy(locale);
  const prefix = locale === "en" ? "" : `/${locale}`;
  const landing = getAllContent("landing", locale).map((m) => ({
    title: m.title,
    description: m.description,
    path: pathFor(m),
    icon: LANDING_ICONS[m.slug] ?? "🔧",
  }));

  return (
    <>
      <Header locale={locale} path="/" />
      <main>
        <section className="hero">
          <p className="eyebrow">{c.eyebrow}</p>
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
          <div className="stat-strip">
            {c.statStrip.map((s) => (
              <span key={s}>
                <strong>{s}</strong>
              </span>
            ))}
          </div>
        </section>

        <HowItWorksTabs
          heading={c.howHeading}
          ownerLabel={c.howOwnerH}
          workerLabel={c.howWorkerH}
          ownerSteps={c.howOwnerSteps}
          workerSteps={c.howWorkerSteps}
        />

        <section>
          <div className="section-head">
            <h2>{c.findWorkersHeading}</h2>
          </div>
          <div className="cards">
            {landing.map((p) => (
              <FeatureCard key={p.path} icon={p.icon} title={p.title} description={p.description} path={p.path} />
            ))}
          </div>
        </section>

        <section>
          <div className="section-head">
            <h2>{c.whoHeading}</h2>
          </div>
          <div className="cards">
            {c.whoItems.map((s, i) => (
              <FeatureCard key={s} icon={WHO_ICONS[i] ?? "👤"} title={s} description="" />
            ))}
          </div>
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

        <CtaBand title={c.seeHowHeading} text={c.seeHowText} primary={{ href: `${prefix}/features`, label: c.browseFeatures }} />
      </main>
      <Footer locale={locale} />
    </>
  );
}
