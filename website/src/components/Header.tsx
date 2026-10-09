import Link from "next/link";
import { SITE_NAME } from "@/lib/site";

export function Header() {
  return (
    <header className="site-header">
      <div className="wrap row">
        <Link href="/" className="brand">
          <span className="bt">
            Jug<span>aadi</span>
          </span>
        </Link>
        <nav aria-label="Primary">
          <Link href="/features">Features</Link>
          <Link href="/alternatives">Alternatives</Link>
          <Link href="/blog">Blog</Link>
        </nav>
        <Link href="/#waitlist" className="btn sm">
          Join waitlist
        </Link>
      </div>
    </header>
  );
}
