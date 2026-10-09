import Link from "next/link";

export interface PageListItem {
  title: string;
  description: string;
  path: string;
  date?: string;
}

export function PageList({ heading, items }: { heading?: string; items: PageListItem[] }) {
  if (items.length === 0) return null;
  return (
    <section className="page-list">
      {heading && <h2>{heading}</h2>}
      <ul className="cards">
        {items.map((p) => (
          <li key={p.path} className="card">
            <Link href={p.path}>
              <h3>{p.title}</h3>
            </Link>
            <p>{p.description}</p>
            {p.date && <p className="byline">{p.date}</p>}
          </li>
        ))}
      </ul>
    </section>
  );
}
