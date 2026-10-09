import { getAllContent, pathFor } from "@/lib/content";
import { SITE_URL } from "@/lib/site";

function linksFor(type: "landing" | "feature" | "alternative" | "blog") {
  return getAllContent(type)
    .map((m) => `- [${m.title}](${SITE_URL}${pathFor(m)}): ${m.description}`)
    .join("\n");
}

export function GET() {
  const body = `> Jugaadi connects shop owners and households with verified nearby workers for short, temporary gigs — from one day to one week.

Jugaadi is a two-sided marketplace: owners post a job and hire from nearby verified workers; workers browse nearby jobs and apply. Currently piloting in a single city.

## Pages
- [Home](${SITE_URL}/): what Jugaadi is, how it works, who it's for
- [Features](${SITE_URL}/features): verification, direct hiring
- [Alternatives](${SITE_URL}/alternatives): how Jugaadi compares to the usual ways of finding temp help
- [Blog](${SITE_URL}/blog): guides and updates

## Find workers
${linksFor("landing") || "(none yet)"}

## Features
${linksFor("feature") || "(none yet)"}

## Alternatives
${linksFor("alternative") || "(none yet)"}

## Blog
${linksFor("blog") || "(no posts yet)"}

## Notes for automated agents
Worker and owner profiles, phone numbers, and job details are private, per-account data — not represented here or indexed by search/AI crawlers. Only the public marketing site and content listed above are intended for indexing.
`;

  return new Response(body, { headers: { "Content-Type": "text/plain; charset=utf-8" } });
}
