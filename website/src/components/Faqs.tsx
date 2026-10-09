import type { Faq } from "@/lib/content";
import type { Locale } from "@/lib/locale";
import { ui } from "@/lib/i18n";

export function Faqs({ faqs, locale = "en" }: { faqs: Faq[]; locale?: Locale }) {
  if (faqs.length === 0) return null;
  return (
    <section className="faqs">
      <h2>{ui(locale).faqHeading}</h2>
      {faqs.map((f) => (
        <details key={f.q}>
          <summary>{f.q}</summary>
          <p>{f.a}</p>
        </details>
      ))}
    </section>
  );
}
