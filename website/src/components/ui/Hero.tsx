import type { ReactNode } from "react";
import { Icon } from "@/components/ui/Icon";

export interface PhoneMockCopy {
  title: string; skills: string[];
  tasks: { title: string; place: string; pay: string; cta: string }[];
  chipVerified: string; chipVerifiedSub: string; chipBook: string; chipBookSub: string; alt: string;
}

/** Product visual built from CSS: a phone showing the nearby-tasks list. Illustrative sample data, decorative. */
export function PhoneMock({ copy }: { copy: PhoneMockCopy }) {
  return (
    <div className="u-phone-wrap" role="img" aria-label={copy.alt}>
      <div className="u-phone" aria-hidden="true">
        <div className="u-phone-top"><span>{copy.title}</span><span className="u-badge live">LIVE</span></div>
        <div className="u-phone-skills">{copy.skills.map((s) => <span key={s}>{s}</span>)}</div>
        {copy.tasks.map((t) => (
          <div className="u-task" key={t.title}>
            <b>{t.title}</b><small>{t.place}</small>
            <div className="u-task-row"><span className="u-task-pay">{t.pay}</span><span className="u-task-btn">{t.cta}</span></div>
          </div>
        ))}
      </div>
      <div className="u-float a" aria-hidden="true"><Icon name="shield" size={20} /><span><b>{copy.chipVerified}</b><small>{copy.chipVerifiedSub}</small></span></div>
      <div className="u-float b" aria-hidden="true"><Icon name="check" size={20} /><span><b>{copy.chipBook}</b><small>{copy.chipBookSub}</small></span></div>
    </div>
  );
}

/** Home hero. `title` holds the single page H1; `visual` is typically <PhoneMock/>. */
export function Hero({ eyebrow, title, lede, actions, note, visual }: { eyebrow: string; title: ReactNode; lede: string; actions: ReactNode; note?: string; visual?: ReactNode }) {
  return (
    <section className="u-hero" aria-labelledby="hero-title">
      <div className="u-container u-hero-grid">
        <div>
          <p className="u-eyebrow">{eyebrow}</p>
          <h1 id="hero-title">{title}</h1>
          <p className="u-lede">{lede}</p>
          <div className="u-cta-row">{actions}</div>
          {note && <p className="u-hero-note">{note}</p>}
        </div>
        {visual}
      </div>
    </section>
  );
}
