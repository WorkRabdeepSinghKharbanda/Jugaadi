export default function HomePage() {
  return (
    <>
      <section>
        <h1>Need a worker for a day? Or found one for the day?</h1>
        <p>
          Jugaadi connects shop owners and households with verified temporary workers nearby — for 1 day, 3
          days, or a week.
        </p>
        <p>
          <a href="#waitlist">
            <strong>I need workers</strong>
          </a>{" "}
          ·{" "}
          <a href="#waitlist">
            <strong>I want work</strong>
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

      <section>
        <h2>Who it&apos;s for</h2>
        <ul>
          <li>Kirana shop owners</li>
          <li>Small businesses</li>
          <li>Households needing maids, helpers, cleaners</li>
          <li>Part-time and daily wage workers looking for work</li>
        </ul>
      </section>

      <section>
        <p>
          <strong>Now piloting in one city.</strong> Join the waitlist to be first in when we launch near
          you.
        </p>
        {/* Wire to the `leads` Supabase table once SUPABASE_URL/SUPABASE_ANON_KEY exist (see plan §5) */}
        <form id="waitlist">
          <input type="text" name="contact" placeholder="Phone or email" required />
          <button type="submit" disabled title="Coming soon">
            Join waitlist
          </button>
        </form>
      </section>
    </>
  );
}
