import { notFound } from "next/navigation";
import type { Metadata } from "next";
import { getAllPosts, getPost } from "@/lib/blog";

export function generateStaticParams() {
  return getAllPosts().map((post) => ({ slug: post.slug }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const post = await getPost(slug);
  if (!post) return {};
  return { title: post.title, description: post.description };
}

export default async function BlogPostPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const post = await getPost(slug);
  if (!post) notFound();

  return (
    <article>
      <h1>{post.title}</h1>
      <p>
        <em>{post.date}</em>
      </p>
      <div dangerouslySetInnerHTML={{ __html: post.html }} />
    </article>
  );
}
