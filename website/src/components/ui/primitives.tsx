import Link from "next/link";
import type { ReactNode } from "react";
import { Icon, type IconName } from "@/components/ui/Icon";
import { buttonClass, type ButtonSize, type ButtonVariant } from "@/components/ui/button-class";

export function Container({ children, narrow, as: Tag = "div" }: { children: ReactNode; narrow?: boolean; as?: "div" | "section" }) {
  return <Tag className={`u-container${narrow ? " narrow" : ""}`}>{children}</Tag>;
}

export function SectionHead({
  eyebrow, title, lede, center, id, as: H = "h2",
}: { eyebrow?: string; title: string; lede?: string; center?: boolean; id?: string; as?: "h1" | "h2" }) {
  return (
    <div className={`u-section-head${center ? " center" : ""}`}>
      {eyebrow && <p className="u-eyebrow">{eyebrow}</p>}
      <H id={id}>{title}</H>
      {lede && <p>{lede}</p>}
    </div>
  );
}

/** Page section with rhythm. Pass `title` to render a SectionHead and label the region. */
export function Section({
  id, eyebrow, title, lede, center, tight, first, children,
}: { id?: string; eyebrow?: string; title?: string; lede?: string; center?: boolean; tight?: boolean; first?: boolean; children: ReactNode }) {
  const labelId = id && title ? `${id}-title` : undefined;
  return (
    <section id={id} aria-labelledby={labelId} className={`u-section${tight ? " tight" : ""}${first ? " first" : ""}`}>
      <Container>
        {title && <SectionHead eyebrow={eyebrow} title={title} lede={lede} center={center} id={labelId} />}
        {children}
      </Container>
    </section>
  );
}

export function LinkButton({
  href, children, variant = "primary", size = "md", arrow,
}: { href: string; children: ReactNode; variant?: ButtonVariant; size?: ButtonSize; arrow?: boolean }) {
  return (
    <Link href={href} className={buttonClass(variant, size)}>
      {children}
      {arrow && <Icon name="arrow" size={18} />}
    </Link>
  );
}

export function Badge({ children, tone = "accent" }: { children: ReactNode; tone?: "accent" | "live" }) {
  return <span className={`u-badge${tone === "live" ? " live" : ""}`}>{children}</span>;
}

/** Surface card. With `href` it becomes a whole-card link. */
export function Card({ children, href, icon }: { children: ReactNode; href?: string; icon?: IconName }) {
  const body = (
    <>
      {icon && <span className="u-chip-icon"><Icon name={icon} /></span>}
      {children}
    </>
  );
  return href ? <Link href={href} className="u-card">{body}</Link> : <div className="u-card">{body}</div>;
}
