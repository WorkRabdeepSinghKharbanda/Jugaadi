import type { Metadata } from "next";
import { pageMetadata } from "@/lib/seo";

export const metadata: Metadata = pageMetadata({
  locale: "en",
  enPath: "/terms",
  title: "Terms of Use: Rules for Using Jugaadi",
  description:
    "The rules for using Jugaadi: who can use it, how booking works, what you agree to when posting or responding to a task, payments, accounts, and limits of responsibility.",
});

const CONTACT_EMAIL = "rabdeepsinghkharbanda29@gmail.com";

export default function TermsPage() {
  return (
    <>
      <h1>Terms of Use</h1>
      <p>
        <em>Last updated: 14 October 2026</em>
      </p>
      <p>
        These terms apply when you use the Jugaadi Android app and website. By creating an account or using
        Jugaadi you agree to them. If you do not agree, please do not use Jugaadi.
      </p>

      <h2>What Jugaadi is</h2>
      <p>
        Jugaadi is a platform that connects people who need same-day help (owners, such as shops and
        households) with nearby workers for short tasks of one day to one week. Jugaadi only helps people
        find each other. We are not the employer of any worker, and we are not a party to the arrangement
        between an owner and a worker.
      </p>

      <h2>Who can use it</h2>
      <ul>
        <li>You must be 18 or older and able to enter a binding agreement.</li>
        <li>You sign in with your own mobile number and must give accurate information.</li>
        <li>You are responsible for activity on your account. Keep your sign-in codes private.</li>
      </ul>

      <h2>Posting and responding to tasks</h2>
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

      <h2>Contact details and conduct</h2>
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

      <h2>Plans and payments</h2>
      <p>
        Jugaadi has a free plan with monthly limits and an optional paid Pro plan, billed for a period of 30
        days through Razorpay. Prices and limits are shown in the app before you pay. A Pro plan does not
        renew automatically; you choose to buy it again. Payments are processed by Razorpay under its own
        terms.
      </p>

      <h2>Verification</h2>
      <p>
        A &quot;verified&quot; badge means we completed a basic check. It is not a guarantee of a
        person&apos;s skill, conduct or background, so please use your own judgement.
      </p>

      <h2>Suspension and deleting your account</h2>
      <p>
        We may suspend or remove accounts or tasks that break these terms or put others at risk. You can
        delete your account at any time from Profile → Delete account; see our{" "}
        <a href="/privacy">Privacy Policy</a> for what is erased and what is kept.
      </p>

      <h2>Limits of responsibility</h2>
      <p>
        Jugaadi is provided &quot;as is&quot;. To the extent the law allows, we are not responsible for the
        conduct of users, for the quality, safety or payment of any task, or for losses that arise from an
        arrangement made through Jugaadi. Nothing in these terms limits rights you have under law that
        cannot be limited.
      </p>

      <h2>Changes</h2>
      <p>
        We may update these terms. When we do, we will change the date above and, for significant changes,
        tell you in the app. Continuing to use Jugaadi after a change means you accept it.
      </p>

      <h2>Governing law and contact</h2>
      <p>
        These terms are governed by the laws of India. Questions or complaints:{" "}
        <a href={`mailto:${CONTACT_EMAIL}`}>{CONTACT_EMAIL}</a>.
      </p>
    </>
  );
}
