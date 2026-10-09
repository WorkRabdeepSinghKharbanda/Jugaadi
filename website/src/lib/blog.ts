import fs from 'node:fs';
import path from 'node:path';
import matter from 'gray-matter';
import { marked } from 'marked';

const BLOG_DIR = path.join(process.cwd(), 'content', 'blog');

export interface BlogPost {
  slug: string;
  title: string;
  description: string;
  date: string;
}

export function getAllPosts(): BlogPost[] {
  return fs
    .readdirSync(BLOG_DIR)
    .filter((file) => file.endsWith('.md'))
    .map((file) => {
      const { data } = matter(fs.readFileSync(path.join(BLOG_DIR, file), 'utf8'));
      return {
        slug: file.replace(/\.md$/, ''),
        title: data.title,
        description: data.description,
        date: data.date,
      };
    })
    .sort((a, b) => (a.date < b.date ? 1 : -1));
}

export async function getPost(slug: string): Promise<(BlogPost & { html: string }) | null> {
  const filePath = path.join(BLOG_DIR, `${slug}.md`);
  if (!fs.existsSync(filePath)) return null;
  const { data, content } = matter(fs.readFileSync(filePath, 'utf8'));
  const html = await marked(content);
  return { slug, title: data.title, description: data.description, date: data.date, html };
}
