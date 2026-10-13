import type { Metadata } from "next";
import Link from "next/link";
import { pageMetadata } from "@/lib/seo";
import { PageShell } from "@/components/ui/PageShell";
import { LegalPage, type LegalSectionItem } from "@/components/ui/doc";

export const metadata: Metadata = pageMetadata({
  locale: "en",
  enPath: "/delete-account",
  title: "Delete Your Jugaadi Account and Data",
  description:
    "How to delete your Jugaadi account and personal data from the app or by email, what is erased, what is kept, and how long it takes.",
});

const CONTACT_EMAIL = "rabdeepsinghkharbanda29@gmail.com";

const CRUMBS = [
  { name: "Home", path: "/" },
  { name: "Delete account", path: "/delete-account" },
];

const SECTIONS: LegalSectionItem[] = [
  {
    id: "delete-in-the-app",
    title: "Delete your account in the app",
    body: (
      <>
        <ol>
          <li>Open the Jugaadi app and sign in.</li>
          <li>Go to Profile.</li>
          <li>Tap Delete account and confirm.</li>
        </ol>
        <p>
          Deletion happens straight away and cannot be undone. You will be signed out and cannot sign in
          again with that mobile number.
        </p>
      </>
    ),
  },
  {
    id: "if-you-cannot-use-the-app",
    title: "If you cannot use the app",
    body: (
      <>
        <p>
          Email <a href={`mailto:${CONTACT_EMAIL}`}>{CONTACT_EMAIL}</a> with the subject &quot;Delete my
          account&quot; and the mobile number you signed up with, so we can find your account. We aim to
          complete the request within 30 days.
        </p>
      </>
    ),
  },
  {
    id: "what-is-erased",
    title: "What is erased",
    body: (
      <>
        <ul>
          <li>Your name (it becomes &quot;Deleted user&quot;) and your mobile number.</li>
          <li>Your separate contact number, email address, bio and profile photo link.</li>
          <li>Your city, saved location and skills.</li>
          <li>Any responses you made that were still waiting for an answer.</li>
          <li>Tasks you posted that were still open are taken down.</li>
        </ul>
      </>
    ),
  },
  {
    id: "what-is-kept",
    title: "What is kept, and why",
    body: (
      <>
        <ul>
          <li>
            Records that involve other people, such as completed bookings, the details and photos of tasks
            you posted, and the text of reviews you wrote. They stay so the other person&apos;s history
            stays intact, and they show you only as &quot;Deleted user&quot;.
          </li>
          <li>Payment reference IDs, kept for accounting and legal reasons.</li>
        </ul>
        <p>
          If you want the task details, photos or review text removed as well, email us at{" "}
          <a href={`mailto:${CONTACT_EMAIL}`}>{CONTACT_EMAIL}</a> and we will review the request.
        </p>
      </>
    ),
  },
  {
    id: "more-information",
    title: "More information",
    body: (
      <>
        <p>
          See our <Link href="/privacy">Privacy Policy</Link> for everything we collect and how we use it.
        </p>
      </>
    ),
  },
];

export default function DeleteAccountPage() {
  return (
    <PageShell locale="en" path="/delete-account" hideLocales>
      <LegalPage
        crumbs={CRUMBS}
        title="Delete your Jugaadi account"
        updated="Last updated: 14 October 2026"
        tocTitle="On this page"
        intro={
          <>
            <p>
              You can delete your Jugaadi account and personal data at any time. This page explains how, what
              is erased, and what is kept.
            </p>
          </>
        }
        sections={SECTIONS}
      />
    </PageShell>
  );
}
