import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  cacheComponents: true,
  partialPrefetching: true,
  // Multiple root layouts (per-locale <html lang>) need a global 404.
  experimental: { globalNotFound: true },
  async redirects() {
    // Feature slug renamed hire-instantly -> book-instantly; keep old URLs alive (308) in every locale.
    return ["", "/hi", "/hinglish"].map((prefix) => ({
      source: `${prefix}/features/hire-instantly`,
      destination: `${prefix}/features/book-instantly`,
      permanent: true,
    }));
  },
};

export default nextConfig;
