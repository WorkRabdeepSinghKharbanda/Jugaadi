import type { Metadata } from "next";
import { getAllContent, getContent, hreflangFor } from "@/lib/content";
import { ContentPageView } from "@/views/ContentPageView";

export function generateStaticParams() {
  return getAllContent("landing", "en").map((m) => ({ slug: m.slug }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const page = await getContent("landing", slug, "hinglish");
  if (!page) return {};
  return { title: page.title, description: page.description, alternates: { languages: hreflangFor("landing", slug) } };
}

export default async function LandingPageHinglish({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  return <ContentPageView type="landing" slug={slug} locale="hinglish" />;
}
