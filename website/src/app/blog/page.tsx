import type { Metadata } from "next";
import { HubView } from "@/views/HubView";

export const metadata: Metadata = {
  title: "Blog",
  description: "Practical guides on hiring temporary workers and running local shops.",
};

export default function BlogIndexPage() {
  return <HubView type="blog" locale="en" />;
}
