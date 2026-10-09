import type { MetadataRoute } from "next";
import { SITE_URL } from "@/lib/site";

const AI_BOTS = [
  "GPTBot",
  "ChatGPT-User",
  "OAI-SearchBot",
  "ClaudeBot",
  "Claude-Web",
  "anthropic-ai",
  "PerplexityBot",
  "Perplexity-User",
  "Google-Extended",
  "CCBot",
  "Bytespider",
];

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [{ userAgent: "*", allow: "/" }, ...AI_BOTS.map((userAgent) => ({ userAgent, allow: "/" }))],
    sitemap: `${SITE_URL}/sitemap.xml`,
  };
}
