// Mechanical SEO/copy guard. Usage: `npm run build && npm start` in one shell, then `npm run check`
// (BASE_URL defaults to http://localhost:3000). Reads /sitemap.xml and checks every URL.
const BASE = (process.env.BASE_URL ?? "http://localhost:3000").replace(/\/$/, "");
const BANNED = /\b(jobs?|hir(?:e|es|ed|ing)|appl(?:y|ies|ied|ication|ications|icant|icants)|vacanc(?:y|ies)|recruit\w*|gigs?)\b|गिग/i;

const strip = (h) => h.replace(/<(script|style|noscript)[\s\S]*?<\/\1>/gi, " ").replace(/<[^>]+>/g, " ").replace(/&[a-z#0-9]+;/gi, " ");
const decode = (s) => s.replace(/&amp;/g, "&").replace(/&quot;/g, '"').replace(/&#x27;|&#39;/g, "'").replace(/&lt;/g, "<").replace(/&gt;/g, ">");

const sitemap = await (await fetch(`${BASE}/sitemap.xml`)).text();
const urls = [...sitemap.matchAll(/<loc>(.*?)<\/loc>/g)].map((m) => new URL(m[1]).pathname);
if (urls.length === 0) { console.error("No URLs in sitemap"); process.exit(1); }

let failures = 0;
for (const path of urls) {
  const errs = [];
  const res = await fetch(BASE + path);
  const html = await res.text();
  if (res.status !== 200) errs.push(`status ${res.status}`);
  const h1s = (html.match(/<h1[\s>]/g) ?? []).length;
  if (h1s !== 1) errs.push(`${h1s} <h1>`);
  const title = decode((html.match(/<title>([\s\S]*?)<\/title>/) ?? [])[1] ?? "");
  if (title.length < 30 || title.length > 65) errs.push(`title ${title.length} chars: "${title}"`);
  const desc = decode((html.match(/<meta name="description" content="([^"]*)"/) ?? [])[1] ?? "");
  if (desc.length < 70 || desc.length > 165) errs.push(`description ${desc.length} chars`);
  if (!/<link rel="canonical" href="[^"]+"/.test(html)) errs.push("no canonical");
  const hreflangs = (html.match(/<link rel="alternate" hrefLang="[^"]+"/gi) ?? []).length;
  if (hreflangs < 4) errs.push(`hreflang ${hreflangs} (<4)`);
  if (!/<html[^>]* lang="[^"]+"/.test(html)) errs.push("no html lang");
  if (!/<main[\s>]/.test(html)) errs.push("no <main>");
  const bad = strip(html).match(BANNED);
  if (bad) errs.push(`banned word "${bad[0]}"`);
  if (errs.length) { failures++; console.error(`FAIL ${path}\n   ${errs.join("\n   ")}`); }
}
console.log(`${urls.length - failures}/${urls.length} pages passed`);
process.exit(failures ? 1 : 0);
