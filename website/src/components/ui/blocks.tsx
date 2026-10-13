import Link from "next/link";
import type { ReactNode } from "react";
import { faqPage } from "@/lib/jsonld";
import type { Faq as FaqItem } from "@/lib/content";
import { JsonLd } from "@/components/JsonLd";
import { Icon, type IconName } from "@/components/ui/Icon";
import { Card, LinkButton } from "@/components/ui/primitives";

const TRUST_ICONS: IconName[] = ["shield", "clock", "lock", "users"];

/** Short row of trust facts under the hero. */
export function StatRow({ items, label }: { items: string[]; label: string }) {
  return (
    <ul className="u-trust" aria-label={label}>
      {items.map((s, i) => (
        <li key={s} className="u-trust-item">
          <span className="u-chip-icon"><Icon name={TRUST_ICONS[i % TRUST_ICONS.length]} /></span>{s}
        </li>
      ))}
    </ul>
  );
}
export const TrustBar = StatRow;

export interface StepItem { title?: string; text: string }

/** Numbered "how it works" cards. Numbers come from a CSS counter. */
export function Steps({ title, steps, cols = 3 }: { title?: string; steps: StepItem[]; cols?: 2 | 3 }) {
  return (
    <div>
      {title && <h3 className="u-steps-title">{title}</h3>}
      <ol className={`u-steps${cols === 2 ? " two" : ""}`}>
        {steps.map((s) => (
          <li key={s.text} className="u-step u-card">{s.title && <h3>{s.title}</h3>}<p>{s.text}</p></li>
        ))}
      </ol>
    </div>
  );
}
export function StepsGroup({ children }: { children: ReactNode }) {
  return <div className="u-steps-wrap">{children}</div>;
}

export interface FeatureItem { title: string; text: string; icon: IconName; href?: string }

/** Bento grid; the first item spans two columns. */
export function FeatureGrid({ items, moreLabel }: { items: FeatureItem[]; moreLabel: string }) {
  return (
    <ul className="u-bento">
      {items.map((f, i) => (
        <li key={f.title} className={i === 0 ? "wide" : undefined}>
          <Card icon={f.icon} href={f.href}>
            <h3>{f.title}</h3>
            <p>{f.text}</p>
            {f.href && <span className="u-more">{moreLabel} <Icon name="arrow" size={16} /></span>}
          </Card>
        </li>
      ))}
    </ul>
  );
}

export interface LinkCardItem { title: string; description: string; href: string; icon?: IconName }

/** Cards that link to landing/feature pages. */
export function UseCaseGrid({ items, moreLabel }: { items: LinkCardItem[]; moreLabel: string }) {
  return (
    <ul className="u-grid">
      {items.map((p) => (
        <li key={p.href}>
          <Card href={p.href} icon={p.icon ?? "tag"}>
            <h3>{p.title}</h3><p>{p.description}</p>
            <span className="u-more">{moreLabel} <Icon name="arrow" size={16} /></span>
          </Card>
        </li>
      ))}
    </ul>
  );
}
export const RelatedCards = UseCaseGrid;

/** Native <details> FAQ; also emits FAQPage JSON-LD. */
export function Faq({ faqs }: { faqs: FaqItem[] }) {
  if (faqs.length === 0) return null;
  const ld = faqPage(faqs);
  return (
    <>
      {ld && <JsonLd data={[ld]} />}
      <div className="u-faq">
        {faqs.map((f) => (
          <details key={f.q}><summary>{f.q}</summary><p>{f.a}</p></details>
        ))}
      </div>
    </>
  );
}

export function CtaBand({ title, text, primary, secondary }: { title: string; text?: string; primary: { href: string; label: string }; secondary?: { href: string; label: string } }) {
  return (
    <div className="u-cta">
      <h2>{title}</h2>
      {text && <p>{text}</p>}
      <div className="u-cta-row">
        <LinkButton href={primary.href} size="lg">{primary.label}</LinkButton>
        {secondary && <LinkButton href={secondary.href} variant="ghost" size="lg">{secondary.label}</LinkButton>}
      </div>
    </div>
  );
}

export interface PlanItem { name: string; price: string; unit: string; blurb: string; points: string[]; featured?: boolean }

export function PricingCards({ plans, fine }: { plans: PlanItem[]; fine?: string }) {
  return (
    <>
      <div className="u-pricing">
        {plans.map((p) => (
          <div key={p.name} className={`u-card u-plan${p.featured ? " featured" : ""}`}>
            <h3>{p.name}</h3>
            <p className="u-blurb">{p.blurb}</p>
            <div className="price">{p.price}<small>{p.unit}</small></div>
            <ul>{p.points.map((pt) => <li key={pt}><Icon name="check" size={18} />{pt}</li>)}</ul>
          </div>
        ))}
      </div>
      {fine && <p className="u-fine">{fine}</p>}
    </>
  );
}

export interface PostCardItem { title: string; description: string; href: string; meta?: string }

export function PostGrid({ items, readLabel }: { items: PostCardItem[]; readLabel: string }) {
  return (
    <ul className="u-grid">
      {items.map((p) => (
        <li key={p.href} className="u-card u-post">
          {p.meta && <p className="u-meta">{p.meta}</p>}
          <h3><Link href={p.href}>{p.title}</Link></h3>
          <p>{p.description}</p>
          <span className="u-more">{readLabel} <Icon name="arrow" size={16} /></span>
        </li>
      ))}
    </ul>
  );
}
