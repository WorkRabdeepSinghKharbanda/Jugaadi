import type { Metadata } from "next";
import { getAllContent, getContent } from "@/lib/content";
import { ContentPageView } from "@/views/ContentPageView";

export function generateStaticParams() {
  return getAllContent("feature", "en").map((m) => ({ slug: m.slug }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const page = await getContent("feature", slug, "hi");
  if (!page) return {};
  return { title: page.title, description: page.description };
}

export default async function FeaturePageHi({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  return <ContentPageView type="feature" slug={slug} locale="hi" />;
}
