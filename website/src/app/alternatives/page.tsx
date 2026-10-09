import type { Metadata } from "next";
import { getAllContent, pathFor } from "@/lib/content";
import { PageList } from "@/components/PageList";

export const metadata: Metadata = {
  title: "Alternatives",
  description: "How Jugaadi compares to the usual ways of finding temporary help.",
};

export default function AlternativesHubPage() {
  const items = getAllContent("alternative").map((m) => ({ title: m.title, description: m.description, path: pathFor(m) }));
  return (
    <>
      <h1>Alternatives</h1>
      <PageList items={items} />
    </>
  );
}
