import fs from 'node:fs';
import path from 'node:path';
import matter from 'gray-matter';
import { marked } from 'marked';

export type ContentType = 'landing' | 'feature' | 'alternative' | 'blog';

export interface Faq {
  q: string;
  a: string;
}

export interface ContentMeta {
  slug: string;
  type: ContentType;
  title: string;
  description: string;
  date?: string;
  keywords: string[];
  related: string[];
  faqs: Faq[];
  competitor?: string;
}

const CONTENT_ROOT = path.join(process.cwd(), 'content');

function dirFor(type: ContentType): string {
  return path.join(CONTENT_ROOT, type);
}

export function getAllContent(type: ContentType): ContentMeta[] {
  const dir = dirFor(type);
  if (!fs.existsSync(dir)) return [];
  return fs
    .readdirSync(dir)
    .filter((f) => f.endsWith('.md'))
    .map((file) => {
      const { data } = matter(fs.readFileSync(path.join(dir, file), 'utf8'));
      return toMeta(type, file.replace(/\.md$/, ''), data);
    })
    .sort((a, b) => (a.title < b.title ? -1 : 1));
}

export async function getContent(
  type: ContentType,
  slug: string,
): Promise<(ContentMeta & { html: string }) | null> {
  const filePath = path.join(dirFor(type), `${slug}.md`);
  if (!fs.existsSync(filePath)) return null;
  const { data, content } = matter(fs.readFileSync(filePath, 'utf8'));
  const html = await marked(content);
  return { ...toMeta(type, slug, data), html };
}

function toMeta(type: ContentType, slug: string, data: Record<string, unknown>): ContentMeta {
  return {
    slug,
    type,
    title: String(data.title ?? slug),
    description: String(data.description ?? ''),
    date: data.date ? String(data.date) : undefined,
    keywords: Array.isArray(data.keywords) ? (data.keywords as string[]) : [],
    related: Array.isArray(data.related) ? (data.related as string[]) : [],
    faqs: Array.isArray(data.faqs) ? (data.faqs as Faq[]) : [],
    competitor: data.competitor ? String(data.competitor) : undefined,
  };
}

export function pathFor(meta: Pick<ContentMeta, 'type' | 'slug'>): string {
  switch (meta.type) {
    case 'landing':
      return `/${meta.slug}`;
    case 'feature':
      return `/features/${meta.slug}`;
    case 'alternative':
      return `/alternatives/${meta.slug}`;
    case 'blog':
      return `/blog/${meta.slug}`;
  }
}
