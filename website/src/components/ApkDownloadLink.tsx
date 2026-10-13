"use client";

import { APK_DOWNLOAD_URL } from "@/lib/site";

export function ApkDownloadLink({ children }: { children: React.ReactNode }) {
  return (
    <a
      className="btn"
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
