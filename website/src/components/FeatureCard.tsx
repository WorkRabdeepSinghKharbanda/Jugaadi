import Link from "next/link";

export function FeatureCard({
  icon,
  title,
  description,
  path,
  moreLabel,
}: {
  icon: string;
  title: string;
  description: string;
  path?: string;
  moreLabel?: string;
}) {
  const body = (
    <>
      <span className="icon-chip" aria-hidden="true">
        {icon}
      </span>
      <h3>{title}</h3>
      <p>{description}</p>
      {path && moreLabel && <span className="more">{moreLabel} →</span>}
    </>
  );
  if (!path) return <div className="feature-card">{body}</div>;
  return (
    <Link href={path} className="feature-card">
      {body}
    </Link>
  );
}
