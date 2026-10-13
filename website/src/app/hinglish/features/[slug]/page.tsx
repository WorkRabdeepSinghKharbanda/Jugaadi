import type { Metadata } from "next";
import { getAllContent } from "@/lib/content";
import { contentMetadata } from "@/lib/seo";
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
  return contentMetadata("feature", slug, "hinglish");
}

export default async function FeaturePageHinglish({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  return <ContentPageView type="feature" slug={slug} locale="hinglish" />;
}
