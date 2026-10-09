import { notFound } from "next/navigation";
import type { Metadata } from "next";
import { getAllContent, getContent, pathFor } from "@/lib/content";
import { JsonLd } from "@/components/JsonLd";
import { Breadcrumbs } from "@/components/Breadcrumbs";
import { Faqs } from "@/components/Faqs";
import { CtaBand } from "@/components/CtaBand";
import { breadcrumbList, faqPage } from "@/lib/jsonld";

export function generateStaticParams() {
  return getAllContent("landing").map((m) => ({ slug: m.slug }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const page = await getContent("landing", slug);
  if (!page) return {};
  return { title: page.title, description: page.description };
}

export default async function LandingPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const page = await getContent("landing", slug);
  if (!page) notFound();

  const path = pathFor(page);
  const crumbs = [
    { name: "Home", path: "/" },
    { name: page.title, path },
  ];

  return (
    <article>
      <JsonLd data={[breadcrumbList(crumbs), faqPage(page.faqs)].filter((n) => n !== null)} />
      <Breadcrumbs items={crumbs} />
      <h1>{page.title}</h1>
      <div dangerouslySetInnerHTML={{ __html: page.html }} />
      <Faqs faqs={page.faqs} />
      <CtaBand
        title="Need a worker, or looking for work?"
        text="Join the waitlist and be first in when Jugaadi launches in your city."
        primary={{ href: "/#waitlist", label: "Join the waitlist" }}
      />
    </article>
  );
}
