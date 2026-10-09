import Link from "next/link";
import { getAllContent, pathFor } from "@/lib/content";
import { SITE_NAME } from "@/lib/site";

function Col({ heading, items }: { heading: string; items: { title: string; path: string }[] }) {
  if (items.length === 0) return null;
  return (
    <div>
      <h2>{heading}</h2>
      <ul>
        {items.map((p) => (
          <li key={p.path}>
            <Link href={p.path}>{p.title}</Link>
          </li>
        ))}
      </ul>
    </div>
  );
}

export function Footer() {
  const landing = getAllContent("landing").map((m) => ({ title: m.title, path: pathFor(m) }));
  const features = getAllContent("feature").map((m) => ({ title: m.title, path: pathFor(m) }));
  const alternatives = getAllContent("alternative").map((m) => ({ title: m.title, path: pathFor(m) }));

  return (
    <footer className="site-footer">
      <div className="wrap top">
        <div className="about">
          <Link href="/" className="brand">
            <span className="bt">
              Jug<span>aadi</span>
            </span>
          </Link>
          <p>Verified temporary workers near you, for 1 day to 1 week gigs. Currently piloting in one city.</p>
        </div>
        <Col heading="Find workers" items={landing} />
        <Col heading="Features" items={[{ title: "All features", path: "/features" }, ...features]} />
        <Col heading="Compare" items={[{ title: "All comparisons", path: "/alternatives" }, ...alternatives]} />
        <Col
          heading="Company"
          items={[
            { title: "Blog", path: "/blog" },
            { title: "Privacy", path: "/privacy" },
            { title: "Terms", path: "/terms" },
          ]}
        />
      </div>
      <div className="wrap small">
        <p>
          &copy; 2026 {SITE_NAME}. A pilot marketplace connecting shop owners and households with verified
          nearby temporary workers.
        </p>
      </div>
    </footer>
  );
}
