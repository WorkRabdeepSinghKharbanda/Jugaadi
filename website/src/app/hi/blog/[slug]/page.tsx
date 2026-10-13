import type { Metadata } from "next";
import { getAllContent } from "@/lib/content";
import { contentMetadata } from "@/lib/seo";
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
  return contentMetadata("blog", slug, "hi");
}

export default async function BlogPostPageHi({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  return <ContentPageView type="blog" slug={slug} locale="hi" />;
}
