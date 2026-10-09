export const LOCALES = ["en", "hi", "hinglish"] as const;
export type Locale = (typeof LOCALES)[number];

export const LOCALE_LABELS: Record<Locale, string> = {
  en: "English",
  hi: "हिंदी",
  hinglish: "Hinglish",
};

export function localePrefix(locale: Locale): string {
  return locale === "en" ? "" : `/${locale}`;
}

export function localizedPath(locale: Locale, path: string): string {
  if (locale === "en") return path;
  return path === "/" ? `/${locale}` : `/${locale}${path}`;
}
