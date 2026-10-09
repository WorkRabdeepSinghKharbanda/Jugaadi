import type { Metadata } from "next";
import { getAllContent, pathFor } from "@/lib/content";
import { PageList } from "@/components/PageList";

export const metadata: Metadata = {
  title: "Blog",
  description: "Practical guides on hiring temporary workers and running local shops.",
};

export default function BlogIndexPage() {
  const posts = getAllContent("blog")
    .map((m) => ({ title: m.title, description: m.description, path: pathFor(m), date: m.date }))
    .sort((a, b) => ((a.date ?? "") < (b.date ?? "") ? 1 : -1));

  return (
    <>
      <h1>Blog</h1>
      <PageList items={posts} />
    </>
  );
}
