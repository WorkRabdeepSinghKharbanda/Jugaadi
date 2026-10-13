import type { Metadata } from "next";
import { pageMetadata } from "@/lib/seo";

export const metadata: Metadata = pageMetadata({
  locale: "en",
  enPath: "/privacy",
  title: "Privacy Policy: How Jugaadi Handles Your Data",
  description:
    "What Jugaadi collects, why, who sees it, how long we keep it, and how to delete your account and data. Plain-language privacy policy for the Jugaadi Android app and website.",
});

const CONTACT_EMAIL = "rabdeepsinghkharbanda29@gmail.com";

export default function PrivacyPage() {
  return (
    <>
      <h1>Privacy Policy</h1>
      <p>
        <em>Last updated: 13 October 2026</em>
      </p>
      <p>
        Jugaadi connects people who need same-day help (shop owners and households) with nearby verified
        workers for short tasks of one day to one week. This policy explains what we collect when you use
        the Jugaadi Android app and this website, why we collect it, who can see it, and the choices you
        have. We do not sell your personal data.
      </p>

      <h2>Who we are</h2>
      <p>
        Jugaadi is operated by Rabdeep Singh Kharbanda, India. For anything in this policy, write to{" "}
        <a href={`mailto:${CONTACT_EMAIL}`}>{CONTACT_EMAIL}</a>.
      </p>

      <h2>What we collect</h2>
      <ul>
        <li>
          <strong>Account:</strong> your mobile number (used to sign in with a one-time code), your name,
          your role (owner or worker), your city, and your preferred app language.
        </li>
        <li>
          <strong>Profile (optional):</strong> email address, a short bio, your skills, and a separate contact
          number if you choose to show one instead of your sign-in number.
        </li>
        <li>
          <strong>Location:</strong> the location you set for your profile and the location of each task you
          post. We read your device location only when you ask the app to use your current location, and
          only while you are using the app. If you deny permission you can search for a place instead.
        </li>
        <li>
          <strong>Task content:</strong> task title, skill needed, dates, daily pay, address and shop or
          landmark details, and any photos you upload for a task.
        </li>
        <li>
          <strong>Activity:</strong> tasks you respond to, who was booked, task status, and reviews and star
          ratings you give or receive.
        </li>
        <li>
          <strong>Payments:</strong> if you buy a Pro plan, payment is handled by Razorpay. We store the plan,
          its dates, and payment reference IDs. We never see or store your card, UPI PIN, or bank details.
        </li>
        <li>
          <strong>Usage and device data:</strong> with Microsoft Clarity (app and website) and Google
          Analytics (website) we collect anonymised usage information such as screens and pages viewed,
          taps, device type and approximate region, to find bugs and improve the product.
        </li>
      </ul>

      <h2>How we use it</h2>
      <ul>
        <li>To sign you in and keep your account secure.</li>
        <li>To show tasks near you and show your task to nearby workers.</li>
        <li>To let owners and workers get in touch once a booking is confirmed.</li>
        <li>To enforce plan limits, process payments, and prevent misuse or fraud.</li>
        <li>To show ratings and reviews that help others decide whom to trust.</li>
        <li>To understand how the app is used and fix problems.</li>
      </ul>

      <h2>Who can see what</h2>
      <ul>
        <li>
          <strong>Your phone number stays private until a booking is confirmed.</strong> When an owner books a
          worker, each side can see the other&apos;s name and contact number — the separate contact number
          if one was set, otherwise the sign-in number. Nobody else sees it.
        </li>
        <li>
          Owners see a worker&apos;s name, skills, city, verification badge, bio and ratings when the worker
          responds to a task. Workers nearby see a task&apos;s title, skill, dates, pay, address, shop or
          landmark line, and photos.
        </li>
        <li>Reviews you write are shown on the reviewed person&apos;s profile with your name.</li>
        <li>We do not sell personal data and do not use it for third-party advertising.</li>
      </ul>

      <h2>Service providers we rely on</h2>
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

      <h2>How long we keep it</h2>
      <p>
        We keep your account data while your account is active. When you delete your account we remove your
        personal details (see below). Records needed to keep other users&apos; history intact, such as a
        review or a completed booking, are kept without your personal details.
      </p>

      <h2>Your choices and deleting your data</h2>
      <ul>
        <li>
          <strong>Edit:</strong> change your name details, email, bio, skills, contact number and language
          anytime in Profile.
        </li>
        <li>
          <strong>Delete your account:</strong> in the app go to Profile → Delete account. Your name, number,
          email, bio, photo and contact number are erased or replaced with &quot;Deleted user&quot;, and
          you can no longer sign in with that number.
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

      <h2>Security</h2>
      <p>
        Data travels over encrypted (HTTPS) connections and the database is only accessible through our
        server, not directly from the app. No system is perfectly secure, so please keep your phone and
        sign-in code private.
      </p>

      <h2>Children</h2>
      <p>Jugaadi is for people aged 18 and over. We do not knowingly collect data from children.</p>

      <h2>Changes to this policy</h2>
      <p>
        If we change this policy we will update the date above and, for significant changes, tell you in the
        app.
      </p>

      <h2>Contact and complaints</h2>
      <p>
        Questions, requests or a complaint about how your data is handled:{" "}
        <a href={`mailto:${CONTACT_EMAIL}`}>{CONTACT_EMAIL}</a>.
      </p>
    </>
  );
}
