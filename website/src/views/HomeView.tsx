import { getAllContent, pathFor } from "@/lib/content";
import { homeCopy } from "@/lib/home-copy";
import { ui } from "@/lib/i18n";
import { localePrefix, type Locale } from "@/lib/locale";
import { softwareApplication } from "@/lib/jsonld";
import { JsonLd } from "@/components/JsonLd";
import { PageShell } from "@/components/ui/PageShell";
import { Hero, PhoneMock } from "@/components/ui/Hero";
import { Section, LinkButton, Container } from "@/components/ui/primitives";
import { CtaBand, Faq, FeatureGrid, PricingCards, StatRow, Steps, StepsGroup, UseCaseGrid } from "@/components/ui/blocks";
import type { IconName } from "@/components/ui/Icon";

const LANDING_ICONS: Record<string, IconName> = {
  "temporary-worker-near-me": "users",
  "maid-for-a-day-near-me": "home",
  "shop-helper-near-me": "store",
};

export function HomeView({ locale }: { locale: Locale }) {
  const c = homeCopy(locale);
  const t = ui(locale);
  const prefix = localePrefix(locale);
  const landing = getAllContent("landing", locale).map((m) => ({
    title: m.title, description: m.description, href: pathFor(m), icon: LANDING_ICONS[m.slug] ?? ("tag" as IconName),
  }));
  const features = c.features.map((f) => ({
    title: f.title, text: f.text, icon: f.icon as IconName, href: f.slug ? `${prefix}/features/${f.slug}` : undefined,
  }));

  return (
    <PageShell locale={locale} path="/">
      <JsonLd data={[softwareApplication(`${prefix}/download`)]} />
      <Hero
        eyebrow={c.eyebrow}
        title={<>{c.heroH1[0]} <em>{c.heroH1[1]}</em></>}
        lede={c.heroLede}
        actions={<><LinkButton href={`${prefix}/download`} size="lg">{c.ctaOwner}</LinkButton><LinkButton href={`${prefix}/download`} variant="ghost" size="lg">{c.ctaWorker}</LinkButton></>}
        note={c.heroNote}
        visual={<PhoneMock copy={c.mock} />}
      />
      <section className="u-section tight" aria-label={c.trust[0]}>
        <Container><StatRow items={c.trust} label={c.trust[0]} /></Container>
      </section>

      <Section id="how" eyebrow={c.howEyebrow} title={c.howHeading} lede={c.howLede}>
        <StepsGroup>
          <Steps title={c.howOwnerH} steps={c.howOwnerSteps} />
          <Steps title={c.howWorkerH} steps={c.howWorkerSteps} />
        </StepsGroup>
      </Section>

      <Section id="use" eyebrow={c.useEyebrow} title={c.useHeading} lede={c.useLede}>
        <UseCaseGrid items={landing} moreLabel={t.learnMore} />
      </Section>

      <Section id="features" eyebrow={c.featEyebrow} title={c.featHeading} lede={c.featLede}>
        <FeatureGrid items={features} moreLabel={t.learnMore} />
      </Section>

      <Section id="pricing" eyebrow={c.priceEyebrow} title={c.priceHeading} lede={c.priceLede}>
        <PricingCards plans={c.plans} fine={c.priceFine} />
      </Section>

      <Section id="faq" eyebrow={c.faqEyebrow} title={t.faqHeading}>
        <Faq faqs={c.faqs} />
      </Section>

      <Section>
        <CtaBand
          title={c.pilotHeading}
          text={c.pilotText}
          primary={{ href: `${prefix}/download`, label: c.downloadBtn }}
          secondary={{ href: `${prefix}/features`, label: c.browseFeatures }}
        />
      </Section>
    </PageShell>
  );
}
