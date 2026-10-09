import { notFound } from "next/navigation";
import type { Metadata } from "next";
import { getAllContent, getContent, pathFor } from "@/lib/content";
import { JsonLd } from "@/components/JsonLd";
import { Breadcrumbs } from "@/components/Breadcrumbs";
import { Faqs } from "@/components/Faqs";
import { breadcrumbList, faqPage } from "@/lib/jsonld";

export function generateStaticParams() {
  return getAllContent("alternative").map((m) => ({ slug: m.slug }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const page = await getContent("alternative", slug);
  if (!page) return {};
  return { title: page.title, description: page.description };
}

export default async function AlternativePage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const page = await getContent("alternative", slug);
  if (!page) notFound();

  const path = pathFor(page);
  const crumbs = [
    { name: "Home", path: "/" },
    { name: "Alternatives", path: "/alternatives" },
    { name: page.title, path },
  ];

  return (
    <article>
      <JsonLd data={[breadcrumbList(crumbs), faqPage(page.faqs)].filter((n) => n !== null)} />
      <Breadcrumbs items={crumbs} />
      <h1>{page.title}</h1>
      <div dangerouslySetInnerHTML={{ __html: page.html }} />
      <Faqs faqs={page.faqs} />
      {page.competitor && (
        <p style={{ fontSize: 12, color: "var(--text-3)" }}>
          {page.competitor} is a trademark of its respective owner. Jugaadi is not affiliated with, endorsed
          by, or sponsored by {page.competitor}.
        </p>
      )}
    </article>
  );
}
