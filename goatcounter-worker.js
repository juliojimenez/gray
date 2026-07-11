/* goatcounter-worker.js — a tiny Cloudflare Worker that serves Gray's
 * journey counter with FRESH numbers.
 *
 * Why it exists: GoatCounter's public counter endpoint
 * (…/counter/TOTAL.json) is served through a cache that refreshes only
 * every few hours, so the homepage number lags the dashboard badly.
 * The authenticated API (/api/v0/stats/total) is live — but it needs a
 * secret token, which must never ship inside a public webpage. This
 * worker holds the token server-side, asks GoatCounter for the live
 * total, caches it for one minute, and answers in the exact shape
 * index.html already parses: {"count": "123"}.
 *
 * Deploy once:
 *   1. GoatCounter dashboard → Settings → API tokens → create a token
 *      with ONLY the "Read statistics" permission.
 *   2. Cloudflare dashboard → Workers & Pages → Create Worker → paste
 *      this file as the worker code.
 *   3. Worker → Settings → Variables and Secrets → add a SECRET named
 *      GOATCOUNTER_TOKEN with the token from step 1.
 *   4. Note the worker URL (something.workers.dev), or give it a route
 *      like count.gray.academy.
 *   5. In index.html, set COUNTER_URL to that URL. Done — the homepage
 *      counter is now at most ~60 seconds behind reality.
 */

// counts everything since launch; the start date just needs to predate the site
const UPSTREAM =
  "https://grayacademy.goatcounter.com/api/v0/stats/total?start=2026-01-01";
const CACHE_SECONDS = 60;

export default {
  async fetch(request, env, ctx) {
    const headers = {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Cache-Control": "public, max-age=" + CACHE_SECONDS,
    };
    try {
      const cache = caches.default;
      const cacheKey = new Request("https://gray-counter.internal/total");
      const cached = await cache.match(cacheKey);
      if (cached) {
        return new Response(await cached.text(), { headers });
      }

      const upstream = await fetch(UPSTREAM, {
        headers: { Authorization: "Bearer " + env.GOATCOUNTER_TOKEN },
      });
      if (!upstream.ok) {
        throw new Error("goatcounter answered " + upstream.status);
      }
      const stats = await upstream.json();
      // the API returns { total: N, total_events: N, total_utc: N }
      const total = stats.total ?? stats.total_utc ?? 0;
      const body = JSON.stringify({ count: String(total) });

      ctx.waitUntil(
        cache.put(
          cacheKey,
          new Response(body, {
            headers: { "Cache-Control": "public, max-age=" + CACHE_SECONDS },
          })
        )
      );
      return new Response(body, { headers });
    } catch (err) {
      // index.html falls back to its remembered value on any non-OK reply
      return new Response(JSON.stringify({ error: String(err) }), {
        status: 502,
        headers,
      });
    }
  },
};
