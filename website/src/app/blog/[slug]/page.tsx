import { notFound } from "next/navigation";
import type { Metadata } from "next";
import { getAllContent, getContent, pathFor } from "@/lib/content";
import { JsonLd } from "@/components/JsonLd";
import { Breadcrumbs } from "@/components/Breadcrumbs";
import { Faqs } from "@/components/Faqs";
import { blogPosting, breadcrumbList, faqPage } from "@/lib/jsonld";

export function generateStaticParams() {
  return getAllContent("blog").map((m) => ({ slug: m.slug }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const post = await getContent("blog", slug);
  if (!post) return {};
  return { title: post.title, description: post.description };
}

export default async function BlogPostPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const post = await getContent("blog", slug);
  if (!post) notFound();

  const path = pathFor(post);
  const crumbs = [
    { name: "Home", path: "/" },
    { name: "Blog", path: "/blog" },
    { name: post.title, path },
  ];

  return (
    <article>
      <JsonLd data={[blogPosting(post, path), breadcrumbList(crumbs), faqPage(post.faqs)].filter((n) => n !== null)} />
      <Breadcrumbs items={crumbs} />
      <h1>{post.title}</h1>
      {post.date && (
        <p>
          <em>{post.date}</em>
        </p>
      )}
      <div dangerouslySetInnerHTML={{ __html: post.html }} />
      <Faqs faqs={post.faqs} />
    </article>
  );
}
