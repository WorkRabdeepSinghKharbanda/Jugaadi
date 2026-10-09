import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Privacy Policy",
  description: "How Jugaadi collects, uses, and protects your data.",
};

export default function PrivacyPage() {
  return (
    <>
      <h1>Privacy Policy</h1>
      <p>
        <em>Last updated: 2026-10-09</em>
      </p>
      <p>
        This is a placeholder privacy policy for Jugaadi&apos;s pilot. Replace this with a real policy
        covering what data is collected (name, phone, location, skills), how it&apos;s stored (Supabase),
        who it&apos;s shared with (the other party on a hire, never sold to third parties), and how users
        can request deletion — before public launch or app store submission.
      </p>
    </>
  );
}
