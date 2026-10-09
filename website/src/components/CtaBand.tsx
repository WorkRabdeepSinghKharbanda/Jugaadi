import Link from "next/link";

export function CtaBand({
  title,
  text,
  primary,
}: {
  title: string;
  text: string;
  primary: { href: string; label: string };
}) {
  return (
    <section className="cta-band">
      <h2>{title}</h2>
      <p>{text}</p>
      <p className="cta-row" style={{ justifyContent: "center" }}>
        <Link href={primary.href} className="btn">
          {primary.label}
        </Link>
      </p>
    </section>
  );
}
