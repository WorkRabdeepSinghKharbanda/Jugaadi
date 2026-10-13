import type { Metadata } from "next";
import { getAllContent } from "@/lib/content";
import { contentMetadata } from "@/lib/seo";
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
  return contentMetadata("alternative", slug, "hinglish");
}

export default async function AlternativePageHinglish({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  return <ContentPageView type="alternative" slug={slug} locale="hinglish" />;
}
