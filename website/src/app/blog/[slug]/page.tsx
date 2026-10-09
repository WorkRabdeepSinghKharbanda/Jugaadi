import type { Metadata } from "next";
import { getAllContent, getContent } from "@/lib/content";
import { ContentPageView } from "@/views/ContentPageView";

export function generateStaticParams() {
  return getAllContent("blog", "en").map((m) => ({ slug: m.slug }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const page = await getContent("blog", slug, "en");
  if (!page) return {};
  return { title: page.title, description: page.description };
}

export default async function BlogPostPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  return <ContentPageView type="blog" slug={slug} locale="en" />;
}
