import type { Metadata } from "next";
import { getAllContent, getContent } from "@/lib/content";
import { ContentPageView } from "@/views/ContentPageView";

export function generateStaticParams() {
  return getAllContent("alternative", "en").map((m) => ({ slug: m.slug }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const page = await getContent("alternative", slug, "hinglish");
  if (!page) return {};
  return { title: page.title, description: page.description };
}

export default async function AlternativePageHinglish({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  return <ContentPageView type="alternative" slug={slug} locale="hinglish" />;
}
