/* coi-serviceworker.js — makes SharedArrayBuffer work on GitHub Pages.
 *
 * Browsers only enable SharedArrayBuffer on cross-origin-isolated pages,
 * which requires COOP/COEP response headers that static hosts like GitHub
 * Pages cannot send. This script plays both roles:
 *
 *  - loaded with <script src="coi-serviceworker.js"> on a page, it
 *    registers itself as a service worker and reloads the page once so
 *    the worker controls it;
 *  - running as that service worker, it re-serves every response with
 *    the COOP/COEP headers added.
 */

if (typeof window === "undefined") {
  // ---- service worker side ----
  self.addEventListener("install", () => self.skipWaiting());
  self.addEventListener("activate", (event) => event.waitUntil(self.clients.claim()));
  self.addEventListener("fetch", (event) => {
    const request = event.request;
    if (request.cache === "only-if-cached" && request.mode !== "same-origin") return;
    event.respondWith(
      fetch(request).then((response) => {
        if (response.status === 0) return response; // opaque — pass through
        const headers = new Headers(response.headers);
        headers.set("Cross-Origin-Opener-Policy", "same-origin");
        headers.set("Cross-Origin-Embedder-Policy", "require-corp");
        headers.set("Cross-Origin-Resource-Policy", "cross-origin");
        return new Response(response.body, {
          status: response.status,
          statusText: response.statusText,
          headers,
        });
      })
    );
  });
} else {
  // ---- page side ----
  (() => {
    const script = document.currentScript;
    if (window.crossOriginIsolated) {
      // isolation achieved — clear the guard so a later hard refresh
      // (which bypasses the service worker) can trigger a fresh reload
      window.sessionStorage.removeItem("coi-reloaded");
      return;
    }
    if (!window.isSecureContext || !("serviceWorker" in navigator)) return;
    const reloadOnce = () => {
      // the once-per-tab guard stops a reload loop if isolation still
      // fails after the service worker is in charge
      if (!window.sessionStorage.getItem("coi-reloaded")) {
        window.sessionStorage.setItem("coi-reloaded", "1");
        window.location.reload();
      }
    };
    navigator.serviceWorker.register(script.src)
      .then(() => navigator.serviceWorker.ready)
      .then(reloadOnce)
      .catch(() => { /* unsupported — the page shows its own fallback */ });
  })();
}
