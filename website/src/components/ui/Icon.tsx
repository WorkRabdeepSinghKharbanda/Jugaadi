const PATHS = {
  shield: "M12 3l7 3v5c0 4.5-3 8-7 10-4-2-7-5.5-7-10V6l7-3zM9 12l2 2 4-4",
  bolt: "M13 2L4 14h7l-1 8 9-12h-7l1-8z",
  lock: "M6 11h12v9H6zM8 11V8a4 4 0 018 0v3",
  star: "M12 3l2.7 5.6 6.1.9-4.4 4.3 1 6.1L12 17l-5.4 2.9 1-6.1L3.2 9.5l6.1-.9L12 3z",
  globe: "M12 3a9 9 0 100 18 9 9 0 000-18zM3 12h18M12 3c2.5 2.5 3.5 5.5 3.5 9s-1 6.5-3.5 9c-2.5-2.5-3.5-5.5-3.5-9S9.5 5.5 12 3z",
  pin: "M12 21s7-6.2 7-11a7 7 0 10-14 0c0 4.8 7 11 7 11zM12 12a2.5 2.5 0 100-5 2.5 2.5 0 000 5z",
  users: "M9 11a3.5 3.5 0 100-7 3.5 3.5 0 000 7zM2.5 20c.5-3.5 3-5.5 6.5-5.5s6 2 6.5 5.5M16 4.5a3.5 3.5 0 010 6.5M18 14.8c2 .6 3.3 2.3 3.5 5.2",
  home: "M4 11l8-7 8 7v9H4v-9zM10 20v-6h4v6",
  store: "M4 9l1.5-5h13L20 9M4 9h16M4 9v11h16V9M9 20v-5h6v5",
  check: "M5 12.5l4.5 4.5L19 7.5",
  arrow: "M5 12h14M13 6l6 6-6 6",
  menu: "M4 7h16M4 12h16M4 17h16",
  close: "M6 6l12 12M18 6L6 18",
  download: "M12 3v12M7 10l5 5 5-5M5 20h14",
  clock: "M12 3a9 9 0 100 18 9 9 0 000-18zM12 7v5l3 2",
  phone: "M7 3h10v18H7zM11 18h2",
  call: "M5 4h4l2 5-2.5 1.5a11 11 0 005 5L15 13l5 2v4a2 2 0 01-2 2A16 16 0 013 6a2 2 0 012-2z",
  file: "M7 3h7l5 5v13H7zM14 3v5h5M10 13h6M10 17h6",
  tag: "M3 12V4h8l10 10-8 8L3 12zM7.5 8.5h.01",
  book: "M5 4h9a4 4 0 014 4v12H9a4 4 0 01-4-4V4zM5 16a4 4 0 014-4h9",
} as const;

export type IconName = keyof typeof PATHS;

/** Inline stroke icon. Decorative by default (aria-hidden); pass `label` to expose it. */
export function Icon({ name, size = 22, label }: { name: IconName; size?: number; label?: string }) {
  return (
    <svg
      className="u-icon" width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor"
      strokeWidth={1.8} strokeLinecap="round" strokeLinejoin="round"
      role={label ? "img" : undefined} aria-label={label} aria-hidden={label ? undefined : true} focusable="false"
    >
      <path d={PATHS[name]} />
    </svg>
  );
}
