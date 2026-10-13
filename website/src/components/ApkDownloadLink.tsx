"use client";

import { APK_DOWNLOAD_URL } from "@/lib/site";
import { buttonClass } from "@/components/ui/button-class";

export function ApkDownloadLink({ children, size = "lg" }: { children: React.ReactNode; size?: "sm" | "md" | "lg" }) {
  return (
    <a
      className={buttonClass("primary", size)}
      data-cta="download-apk"
      href={APK_DOWNLOAD_URL}
      rel="noopener noreferrer"
      onClick={() => {
        const gtag = (window as unknown as { gtag?: (...args: unknown[]) => void }).gtag;
        if (typeof gtag === "function") gtag("event", "apk_download");
      }}
    >
      {children}
    </a>
  );
}
