export type ButtonVariant = "primary" | "ghost";
export type ButtonSize = "sm" | "md" | "lg";

/** Class string for anything that must look like a Button (e.g. client-side download link). */
export function buttonClass(variant: ButtonVariant = "primary", size: ButtonSize = "md"): string {
  return `u-btn ${variant}${size === "md" ? "" : ` ${size}`}`;
}
