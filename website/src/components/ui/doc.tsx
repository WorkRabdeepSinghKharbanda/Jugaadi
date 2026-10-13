import Link from "next/link";
import type { ReactNode } from "react";
import { breadcrumbList } from "@/lib/jsonld";
import type { TocItem } from "@/lib/prose";
import { JsonLd } from "@/components/JsonLd";
import { Container } from "@/components/ui/primitives";

export interface Crumb { name: string; path: string }

/** Visible breadcrumb trail; also emits BreadcrumbList JSON-LD. */
export function Breadcrumbs({ items, label = "Breadcrumb" }: { items: Crumb[]; label?: string }) {
  const ld = breadcrumbList(items);
  if (!ld) return null;
  return (
    <>
      <JsonLd data={[ld]} />
      <nav aria-label={label} className="u-crumbs">
        <ol>
          {items.map((c, i) => (
            <li key={c.path}>
              {i < items.length - 1 ? <Link href={c.path}>{c.name}</Link> : <span aria-current="page">{c.name}</span>}
            </li>
          ))}
        </ol>
      </nav>
    </>
  );
}

/** Top of every inner page: breadcrumbs, the page's single H1, lede and optional meta row. */
export function PageHero({ crumbs, crumbLabel, eyebrow, title, lede, meta, children }: { crumbs?: Crumb[]; crumbLabel?: string; eyebrow?: string; title: string; lede?: string; meta?: ReactNode; children?: ReactNode }) {
  return (
    <header className="u-pagehero">
      <Container>
        {crumbs && <Breadcrumbs items={crumbs} label={crumbLabel} />}
        {eyebrow && <p className="u-eyebrow">{eyebrow}</p>}
        <h1>{title}</h1>
        {lede && <p className="u-lede">{lede}</p>}
        {meta && <div className="u-meta">{meta}</div>}
        {children}
      </Container>
    </header>
  );
}

/** Rendered Markdown (trusted, from content/) with readable article typography. */
export function Prose({ html }: { html: string }) {
  return <div className="u-prose" dangerouslySetInnerHTML={{ __html: html }} />;
}

/** Table of contents: sticky list on desktop, collapsible <details> on mobile. */
export function Toc({ items, title }: { items: TocItem[]; title: string }) {
  if (items.length < 2) return null;
  const list = (
    <ol>{items.map((t) => <li key={t.id}><a href={`#${t.id}`}>{t.title}</a></li>)}</ol>
  );
  return (
    <>
      <nav className="u-toc u-toc-desktop" aria-label={title}><h2>{title}</h2>{list}</nav>
      <nav className="u-toc u-toc-mobile" aria-label={title}><details><summary>{title}</summary>{list}</details></nav>
    </>
  );
}

/** Two-column layout: TOC beside the body. Without a TOC the body is a single column. */
export function DocLayout({ toc, children }: { toc?: ReactNode; children: ReactNode }) {
  return (
    <Container>
      <div className={toc ? "u-doc" : "u-doc single"}>
        {toc}
        <div className="u-article-body">{children}</div>
      </div>
    </Container>
  );
}

export interface DataTableProps { caption: string; head: [string, string, ...string[]]; rows: { label: string; cells: ReactNode[] }[] }

/** Responsive table, e.g. "what we collect / why / who sees it". First column is a row header. */
export function DataTable({ caption, head, rows }: DataTableProps) {
  return (
    <div className="u-table-wrap" role="region" aria-label={caption} tabIndex={0}>
      <table className="u-table">
        <caption className="u-sr">{caption}</caption>
        <thead><tr>{head.map((h) => <th key={h} scope="col">{h}</th>)}</tr></thead>
        <tbody>
          {rows.map((r) => (
            <tr key={r.label}>
              <th scope="row">{r.label}</th>
              {r.cells.map((c, i) => <td key={i}>{c}</td>)}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export interface LegalSectionItem { id: string; title: string; body: ReactNode }

/** Legal document: header with updated date, TOC sidebar, numbered sections. */
export function LegalPage({ crumbs, crumbLabel, title, updated, intro, sections, tocTitle }: { crumbs: Crumb[]; crumbLabel?: string; title: string; updated: string; intro: ReactNode; sections: LegalSectionItem[]; tocTitle: string }) {
  return (
    <>
      <PageHero crumbs={crumbs} crumbLabel={crumbLabel} title={title} meta={<span>{updated}</span>} />
      <DocLayout toc={<Toc title={tocTitle} items={sections.map((s) => ({ id: s.id, title: s.title }))} />}>
        <div className="u-legal-body u-legal">
          <div className="u-legal-sec u-legal-intro">{intro}</div>
          {sections.map((s) => (
            <section key={s.id} id={s.id} className="u-legal-sec" aria-labelledby={`${s.id}-h`}>
              <h2 id={`${s.id}-h`}>{s.title}</h2>
              {s.body}
            </section>
          ))}
        </div>
      </DocLayout>
    </>
  );
}
