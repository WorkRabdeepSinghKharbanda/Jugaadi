import type { Metadata } from "next";
import { getAllContent, pathFor } from "@/lib/content";
import { PageList } from "@/components/PageList";

export const metadata: Metadata = {
  title: "Features",
  description: "What Jugaadi does for shop owners, households, and workers.",
};

export default function FeaturesHubPage() {
  const items = getAllContent("feature").map((m) => ({ title: m.title, description: m.description, path: pathFor(m) }));
  return (
    <>
      <h1>Features</h1>
      <PageList items={items} />
    </>
  );
}
