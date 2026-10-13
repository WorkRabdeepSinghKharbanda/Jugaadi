import { RootShell } from "@/components/RootShell";
import { HTML_LANG, rootMetadata } from "@/lib/seo";

export const metadata = rootMetadata("hinglish");

export default function Layout({ children }: { children: React.ReactNode }) {
  return <RootShell lang={HTML_LANG["hinglish"]}>{children}</RootShell>;
}
