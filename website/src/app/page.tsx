import { getAllContent, pathFor } from "@/lib/content";
import { PageList } from "@/components/PageList";
import { Faqs } from "@/components/Faqs";
import { CtaBand } from "@/components/CtaBand";

const HOME_FAQS = [
  {
    q: "What does Jugaadi actually do?",
    a: "Connects shop owners and households who need short-term help with nearby workers who can do that specific job, for 1 day to 1 week.",
  },
  {
    q: "Is Jugaadi live in my city?",
    a: "We're running a single-city pilot right now. Join the waitlist below and we'll reach out as coverage expands.",
  },
  {
    q: "Do workers need to pay anything?",
    a: "No. Sign up, add your skills, and apply to nearby jobs — Jugaadi doesn't charge workers in this pilot.",
  },
];

export default function HomePage() {
  const landing = getAllContent("landing").map((m) => ({ title: m.title, description: m.description, path: pathFor(m) }));

  return (
    <>
      <section className="hero">
        <h1>Need a worker for a day? Or found one for the day?</h1>
        <p className="lede">
          Jugaadi connects shop owners and households with verified temporary workers nearby — for 1 day, 3
          days, or a week.
        </p>
        <p className="cta-row">
          <a href="#waitlist" className="btn">
            I need workers
          </a>
          <a href="#waitlist" className="btn ghost">
            I want work
          </a>
        </p>
      </section>

      <section>
        <h2>How it works</h2>
        <h3>For shop &amp; home owners</h3>
        <ol>
          <li>Post what help you need and for how long</li>
          <li>See verified workers nearby</li>
          <li>Hire directly and pay them yourself</li>
        </ol>
        <h3>For workers</h3>
        <ol>
          <li>Register and add your skills</li>
          <li>See nearby jobs matching what you do</li>
          <li>Accept work and get hired</li>
        </ol>
      </section>

      <PageList heading="Find workers near you" items={landing} />

      <section>
        <h2>Who it&apos;s for</h2>
        <ul>
          <li>Kirana shop owners</li>
          <li>Small businesses</li>
          <li>Households needing maids, helpers, cleaners</li>
          <li>Part-time and daily wage workers looking for work</li>
        </ul>
      </section>

      <Faqs faqs={HOME_FAQS} />

      <section id="waitlist">
        <div className="cta-band">
          <h2>Now piloting in one city</h2>
          <p>Join the waitlist to be first in when we launch near you.</p>
          {/* Wire to the `leads` Supabase table once SUPABASE_URL/SUPABASE_ANON_KEY exist (see plan §5) */}
          <form style={{ display: "flex", gap: 8, justifyContent: "center", flexWrap: "wrap" }}>
            <input
              type="text"
              name="contact"
              placeholder="Phone or email"
              required
              style={{
                padding: "10px 16px",
                borderRadius: "var(--r-pill)",
                border: "1px solid var(--outline)",
                background: "var(--surface)",
                color: "var(--text)",
              }}
            />
            <button type="submit" disabled title="Coming soon" className="btn">
              Join waitlist
            </button>
          </form>
        </div>
      </section>

      <CtaBand
        title="See how it works"
        text="Read about direct hiring and worker verification."
        primary={{ href: "/features", label: "Browse features" }}
      />
    </>
  );
}
