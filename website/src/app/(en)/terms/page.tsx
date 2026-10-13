import type { Metadata } from "next";
import Link from "next/link";
import { pageMetadata } from "@/lib/seo";
import { PageShell } from "@/components/ui/PageShell";
import { LegalPage, type LegalSectionItem } from "@/components/ui/doc";

export const metadata: Metadata = pageMetadata({
  locale: "en",
  enPath: "/terms",
  title: "Terms of Use: Rules for Using Jugaadi",
  description:
    "The rules for using Jugaadi: who can use it, how booking works, what you agree to when posting or responding to a task, payments, and limits of responsibility.",
});

const CONTACT_EMAIL = "rabdeepsinghkharbanda29@gmail.com";

const CRUMBS = [
  { name: "Home", path: "/" },
  { name: "Terms of Use", path: "/terms" },
];

const SECTIONS: LegalSectionItem[] = [
    {
      id: "what-jugaadi-is",
      title: "What Jugaadi is",
      body: (
        <>
          <p>
        Jugaadi is a platform that connects people who need same-day help (owners, such as shops and
        households) with nearby workers for short tasks of one day to one week. Jugaadi only helps people
        find each other. We are not the employer of any worker, and we are not a party to the arrangement
        between an owner and a worker.
      </p>
        </>
      ),
    },
    {
      id: "who-can-use-it",
      title: "Who can use it",
      body: (
        <>
          <ul>
        <li>You must be 18 or older and able to enter a binding agreement.</li>
        <li>You sign in with your own mobile number and must give accurate information.</li>
        <li>You are responsible for activity on your account. Keep your sign-in codes private.</li>
      </ul>
        </>
      ),
    },
    {
      id: "posting-and-responding-to-tasks",
      title: "Posting and responding to tasks",
      body: (
        <>
          <ul>
        <li>Owners must describe tasks honestly, including the place, dates, skill needed and pay.</li>
        <li>
          Workers who respond should do so only if they can do the task, and should show up if they are
          booked.
        </li>
        <li>
          Pay, hours and safety are agreed directly between the owner and the worker. Jugaadi does not hold
          or pay out wages.
        </li>
        <li>
          Tasks must be lawful and safe. Do not post anything illegal, dangerous, discriminatory or
          misleading, and do not ask for work that needs a licence you do not have.
        </li>
      </ul>
        </>
      ),
    },
    {
      id: "contact-details-and-conduct",
      title: "Contact details and conduct",
      body: (
        <>
          <ul>
        <li>
          Contact details you see through Jugaadi are for arranging the task only. Do not use them for
          marketing, harassment or sharing with others.
        </li>
        <li>Treat other users with respect. Do not impersonate anyone or submit false reviews.</li>
        <li>
          Reviews should describe your genuine experience. We may remove reviews or accounts that break these
          rules.
        </li>
      </ul>
        </>
      ),
    },
    {
      id: "plans-and-payments",
      title: "Plans and payments",
      body: (
        <>
          <p>
        Jugaadi has a free plan with monthly limits, a 7-day free trial of Pro for new accounts, and an optional
        paid Pro plan billed for a period of 30 days through Razorpay. Prices and limits are shown in the app before you pay. A Pro plan does not
        renew automatically; you choose to buy it again. Payments are processed by Razorpay under its own
        terms.
      </p>
        </>
      ),
    },
    {
      id: "verification",
      title: "Verification",
      body: (
        <>
          <p>
        A &quot;verified&quot; badge means we completed a basic check. It is not a guarantee of a
        person&apos;s skill, conduct or background, so please use your own judgement.
      </p>
        </>
      ),
    },
    {
      id: "suspension-and-deleting-your-account",
      title: "Suspension and deleting your account",
      body: (
        <>
          <p>
        We may suspend or remove accounts or tasks that break these terms or put others at risk. You can
        delete your account at any time from Profile → Delete account; see our{" "}
        <Link href="/privacy">Privacy Policy</Link> for what is erased and what is kept.
      </p>
        </>
      ),
    },
    {
      id: "limits-of-responsibility",
      title: "Limits of responsibility",
      body: (
        <>
          <p>
        Jugaadi is provided &quot;as is&quot;. To the extent the law allows, we are not responsible for the
        conduct of users, for the quality, safety or payment of any task, or for losses that arise from an
        arrangement made through Jugaadi. Nothing in these terms limits rights you have under law that
        cannot be limited.
      </p>
        </>
      ),
    },
    {
      id: "changes",
      title: "Changes",
      body: (
        <>
          <p>
        We may update these terms. When we do, we will change the date above and, for significant changes,
        tell you in the app. Continuing to use Jugaadi after a change means you accept it.
      </p>
        </>
      ),
    },
    {
      id: "governing-law-and-contact",
      title: "Governing law and contact",
      body: (
        <>
          <p>
        These terms are governed by the laws of India. Questions or complaints:{" "}
        <a href={`mailto:${CONTACT_EMAIL}`}>{CONTACT_EMAIL}</a>.
      </p>
        </>
      ),
    },
];

export default function TermsPage() {
  return (
    <PageShell locale="en" path="/terms" hideLocales>
      <LegalPage
        crumbs={CRUMBS}
        title="Terms of Use"
        updated="Last updated: 14 October 2026"
        tocTitle="On this page"
        intro={
          <>
            <p>
        These terms cover your use of the Jugaadi Android app and website. By creating an account or using
        Jugaadi you agree to them. If you do not agree, please do not use Jugaadi.
      </p>
          </>
        }
        sections={SECTIONS}
      />
    </PageShell>
  );
}
