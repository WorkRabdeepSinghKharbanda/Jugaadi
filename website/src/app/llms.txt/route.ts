import { getAllPosts } from "@/lib/blog";
import { SITE_URL } from "@/lib/site";

export function GET() {
  const posts = getAllPosts();
  const blogLinks = posts
    .map((post) => `- [${post.title}](${SITE_URL}/blog/${post.slug}): ${post.description}`)
    .join("\n");

  const body = `> Jugaadi connects shop owners and households with verified nearby workers for short, temporary gigs — from one day to one week.

Jugaadi is a two-sided marketplace: owners post a job and hire from nearby verified workers; workers browse nearby jobs and apply. Currently piloting in a single city.

## Pages
- [Home](${SITE_URL}/): what Jugaadi is, how it works, who it's for
- [Blog](${SITE_URL}/blog): guides and updates

## Blog
${blogLinks || "(no posts yet)"}

## Notes for automated agents
Worker and owner profiles, phone numbers, and job details are private, per-account data — not represented here or indexed by search/AI crawlers. Only the public marketing site and blog content above are intended for indexing.
`;

  return new Response(body, { headers: { "Content-Type": "text/plain; charset=utf-8" } });
}
