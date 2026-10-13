import type { Metadata } from "next";
import { pageMetadata } from "@/lib/seo";
import { PageShell } from "@/components/ui/PageShell";
import { DataTable, LegalPage, type LegalSectionItem } from "@/components/ui/doc";

export const metadata: Metadata = pageMetadata({
  locale: "en",
  enPath: "/privacy",
  title: "Privacy Policy: How Jugaadi Handles Your Data",
  description:
    "What Jugaadi collects, why, who sees it, how long we keep it, and how to delete your account and data. Plain-language policy for the Android app and website.",
});

const CONTACT_EMAIL = "rabdeepsinghkharbanda29@gmail.com";

const CRUMBS = [
  { name: "Home", path: "/" },
  { name: "Privacy Policy", path: "/privacy" },
];

const SECTIONS: LegalSectionItem[] = [
    {
      id: "who-we-are",
      title: "Who we are",
      body: (
        <>
          <p>
        Jugaadi is operated by Rabdeep Singh Kharbanda, India. For anything in this policy, write to{" "}
        <a href={`mailto:${CONTACT_EMAIL}`}>{CONTACT_EMAIL}</a>.
      </p>
        </>
      ),
    },
    {
      id: "what-we-collect",
      title: "What we collect",
      body: (
        <>
          <DataTable caption="What we collect" head={["Data", "What we collect"]} rows={[
            { label: "Account", cells: [<>Your mobile number (used to sign in with a one-time code), your name, your role (owner or worker), your city, and your preferred app language.</>] },
            { label: "Profile (optional)", cells: [<>Email address, a short bio, your skills, and a separate contact number if you choose to show one instead of your sign-in number.</>] },
            { label: "Location", cells: [<>The location you set for your profile and the location of each task you post. We read your device location only when you ask the app to use your current location, and only while you are using the app. If you deny permission you can search for a place instead.</>] },
            { label: "Task content", cells: [<>Task title, skill needed, dates, daily pay, address and shop or landmark details, and any photos you upload for a task.</>] },
            { label: "Activity", cells: [<>Tasks you respond to, who was booked, task status, and reviews and star ratings you give or receive.</>] },
            { label: "Payments", cells: [<>If you buy a Pro plan, payment is handled by Razorpay. We store the plan, its dates, and payment reference IDs. We never see or store your card, UPI PIN, or bank details.</>] },
            { label: "Usage and device data", cells: [<>Microsoft Clarity (app and website) and Google Analytics (website) collect usage and interaction information such as screens and pages viewed, taps and scrolls, device type and approximate region, to find bugs and improve the product. On the website these tools use cookies.</>] },
          ]} />
        </>
      ),
    },
    {
      id: "how-we-use-it",
      title: "How we use it",
      body: (
        <>
          <ul>
        <li>To sign you in and keep your account secure.</li>
        <li>To show tasks near you and show your task to nearby workers.</li>
        <li>To let owners and workers get in touch once a booking is confirmed.</li>
        <li>To enforce plan limits, process payments, and prevent misuse or fraud.</li>
        <li>To show ratings and reviews that help others decide whom to trust.</li>
        <li>To understand how the app is used and fix problems.</li>
      </ul>
        </>
      ),
    },
    {
      id: "who-can-see-what",
      title: "Who can see what",
      body: (
        <>
          <ul>
        <li>
          <strong>Workers who respond to a task:</strong> the owner of that task sees the worker&apos;s name,
          mobile number, skills, city, verification badge and bio. The worker&apos;s optional email and
          separate contact number are shared only once the owner books them.
        </li>
        <li>
          <strong>Owners:</strong> an owner&apos;s name and contact number are shared with a worker only
          after that worker is booked — the separate contact number if one was set, otherwise the sign-in
          number. Other users do not see it.
        </li>
        <li>
          Workers nearby see a task&apos;s title, skill, dates, pay, address, shop or landmark line, and
          photos.
        </li>
        <li>Reviews you write are shown on the reviewed person&apos;s profile with your name.</li>
        <li>We do not sell personal data and do not use it for third-party advertising.</li>
      </ul>
        </>
      ),
    },
    {
      id: "service-providers-we-rely-on",
      title: "Service providers we rely on",
      body: (
        <>
          <p>These providers process data on our behalf to run Jugaadi:</p>
      <ul>
        <li>Supabase — sign-in, database and photo storage.</li>
        <li>Render — hosting for our server.</li>
        <li>Vercel — hosting for this website.</li>
        <li>Razorpay — payment processing for Pro plans.</li>
        <li>Microsoft Clarity and Google Analytics — usage analytics.</li>
        <li>Google Drive — hosting the Android app download file.</li>
      </ul>
      <p>
        Some of these providers process data outside India. We may also disclose information if the law
        requires it.
      </p>
        </>
      ),
    },
    {
      id: "how-long-we-keep-it",
      title: "How long we keep it",
      body: (
        <>
          <p>
        We keep your account data while your account is active. When you delete your account we erase your
        personal details (see below). Task records, reviews and booking history involving other people are
        kept so their history stays intact, but they show you only as &quot;Deleted user&quot;. We also keep
        payment reference IDs for accounting and legal reasons.
      </p>
        </>
      ),
    },
    {
      id: "your-choices-and-deleting-your-data",
      title: "Your choices and deleting your data",
      body: (
        <>
          <ul>
        <li>
          <strong>Edit:</strong> change your name details, email, bio, skills, contact number and language
          anytime in Profile.
        </li>
        <li>
          <strong>Delete your account:</strong> in the app go to Profile → Delete account. Your name, mobile
          number, contact number, email, bio, profile photo link, city, saved location and skills are erased
          (your name becomes &quot;Deleted user&quot;), tasks you posted that are still open are taken down,
          and you can no longer sign in with that number. Text you wrote in a review and the details or
          photos of tasks you posted stay as part of the other person&apos;s record; if you want those
          removed too, email us and we will review the request.
        </li>
        <li>
          <strong>Other requests:</strong> to see, correct or remove data, or to withdraw consent, email{" "}
          <a href={`mailto:${CONTACT_EMAIL}`}>{CONTACT_EMAIL}</a> and mention your registered mobile number so we can find your account. We aim to respond within 30 days.
        </li>
        <li>
          <strong>Location:</strong> you can turn off location permission in your phone&apos;s app settings
          at any time.
        </li>
      </ul>
        </>
      ),
    },
    {
      id: "security",
      title: "Security",
      body: (
        <>
          <p>
        Data travels over encrypted (HTTPS) connections and the database is only accessible through our
        server, not directly from the app. No system is perfectly secure, so please keep your phone and
        sign-in code private.
      </p>
        </>
      ),
    },
    {
      id: "children",
      title: "Children",
      body: (
        <>
          <p>Jugaadi is for people aged 18 and over. We do not knowingly collect data from children.</p>
        </>
      ),
    },
    {
      id: "changes-to-this-policy",
      title: "Changes to this policy",
      body: (
        <>
          <p>
        If we change this policy we will update the date above and, for significant changes, tell you in the
        app.
      </p>
        </>
      ),
    },
    {
      id: "contact-and-complaints",
      title: "Contact and complaints",
      body: (
        <>
          <p>
        Questions, requests or a complaint about how your data is handled:{" "}
        <a href={`mailto:${CONTACT_EMAIL}`}>{CONTACT_EMAIL}</a>.
      </p>
        </>
      ),
    },
];

export default function PrivacyPage() {
  return (
    <PageShell locale="en" path="/privacy" hideLocales>
      <LegalPage
        crumbs={CRUMBS}
        title="Privacy Policy"
        updated="Last updated: 13 October 2026"
        tocTitle="On this page"
        intro={
          <>
            <p>
        Jugaadi connects people who need same-day help (shop owners and households) with nearby verified
        workers for short tasks of one day to one week. This policy explains what we collect when you use
        the Jugaadi Android app and this website, why we collect it, who can see it, and the choices you
        have. We do not sell your personal data.
      </p>
          </>
        }
        sections={SECTIONS}
      />
    </PageShell>
  );
}
