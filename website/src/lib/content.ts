import fs from 'node:fs';
import path from 'node:path';
import matter from 'gray-matter';
import { marked } from 'marked';
import { LOCALES, type Locale } from './locale';
import { SITE_URL } from './site';

export type ContentType = 'landing' | 'feature' | 'alternative' | 'blog';

export interface Faq {
  q: string;
  a: string;
}

export interface ContentMeta {
  slug: string;
  type: ContentType;
  locale: Locale;
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

function fileName(slug: string, locale: Locale): string {
  return locale === 'en' ? `${slug}.md` : `${slug}.${locale}.md`;
}

/** English file is the base slug list; a locale only ever exposes slugs that also exist in English. */
export function getAllContent(type: ContentType, locale: Locale = 'en'): ContentMeta[] {
  const dir = dirFor(type);
  if (!fs.existsSync(dir)) return [];
  const baseSlugs = fs
    .readdirSync(dir)
    .filter((f) => f.endsWith('.md') && !f.includes('.hi.') && !f.includes('.hinglish.'))
    .map((f) => f.replace(/\.md$/, ''));

  return baseSlugs
    .map((slug) => {
      const file = path.join(dir, fileName(slug, locale));
      const fallback = path.join(dir, fileName(slug, 'en'));
      const target = fs.existsSync(file) ? file : fallback;
      const { data } = matter(fs.readFileSync(target, 'utf8'));
      return toMeta(type, slug, locale, data);
    })
    .sort((a, b) => (a.title < b.title ? -1 : 1));
}

export async function getContent(
  type: ContentType,
  slug: string,
  locale: Locale = 'en',
): Promise<(ContentMeta & { html: string }) | null> {
  const dir = dirFor(type);
  const file = path.join(dir, fileName(slug, locale));
  const fallback = path.join(dir, fileName(slug, 'en'));
  const target = fs.existsSync(file) ? file : fs.existsSync(fallback) ? fallback : null;
  if (!target) return null;
  const { data, content } = matter(fs.readFileSync(target, 'utf8'));
  const html = await marked(content);
  return { ...toMeta(type, slug, locale, data), html };
}

function toMeta(type: ContentType, slug: string, locale: Locale, data: Record<string, unknown>): ContentMeta {
  return {
    slug,
    type,
    locale,
    title: String(data.title ?? slug),
    description: String(data.description ?? ''),
    date: data.date ? String(data.date) : undefined,
    keywords: Array.isArray(data.keywords) ? (data.keywords as string[]) : [],
    related: Array.isArray(data.related) ? (data.related as string[]) : [],
    faqs: Array.isArray(data.faqs) ? (data.faqs as Faq[]) : [],
    competitor: data.competitor ? String(data.competitor) : undefined,
  };
}

/** Builds the `alternates.languages` object for a page's Metadata, pointing at its locale siblings. */
export function hreflangFor(type: ContentType, slug: string): Record<string, string> {
  return Object.fromEntries(LOCALES.map((locale) => [locale, `${SITE_URL}${pathFor({ type, slug, locale })}`]));
}

export function pathFor(meta: Pick<ContentMeta, 'type' | 'slug' | 'locale'>): string {
  const prefix = meta.locale === 'en' ? '' : `/${meta.locale}`;
  switch (meta.type) {
    case 'landing':
      return `${prefix}/${meta.slug}`;
    case 'feature':
      return `${prefix}/features/${meta.slug}`;
    case 'alternative':
      return `${prefix}/alternatives/${meta.slug}`;
    case 'blog':
      return `${prefix}/blog/${meta.slug}`;
  }
}
