# Deploying `idk.potatocore.com` on Cloudflare Pages

This site is a static Vite build. The fastest path to `idk.potatocore.com` is **Cloudflare Pages** (free, instant cache invalidation, automatic TLS, and the DNS already lives in the same Cloudflare account as `potatocore.com`).

Roughly 10 minutes start to finish.

---

## 1. Push to a remote

Cloudflare Pages connects to a git host. If this repo isn't on GitHub yet:

```sh
gh repo create potatuhs/idkwhatimdoing --private --source=. --remote=origin --push
```

(swap `potatuhs` for whichever account/org should own it, and `--private` for `--public` if you want it open).

If it already has a remote, skip ahead.

## 2. Create the Pages project

1. Cloudflare dashboard → **Workers & Pages** → **Create application** → **Pages** → **Connect to Git**.
2. Pick the GitHub account, then the `idkwhatimdoing` repo. Authorize Cloudflare on the repo if asked.
3. Project name: `idk` (this becomes the default `idk.pages.dev` preview URL).
4. Production branch: `main` (or whatever you're shipping from — currently `master` based on `git status`).
5. **Build settings:**
   - Framework preset: **Vite**
   - Build command: `npm run build`
   - Build output directory: `dist`
   - Root directory: *(leave blank)*
   - Node version: set environment variable `NODE_VERSION=20` (Pages defaults to 18 which works, but 20 matches what `better-sqlite3@12` is happiest on).
6. Hit **Save and Deploy**. First build takes ~60 seconds.

Once the build is green you'll have a live URL at `https://idk.pages.dev`.

## 3. Point `idk.potatocore.com` at it

In the Cloudflare dashboard:

1. Open the **`potatocore.com`** zone.
2. **DNS → Records → Add record.**
   - Type: `CNAME`
   - Name: `idk`
   - Target: `idk.pages.dev`
   - Proxy status: **Proxied** (orange cloud — gives you free TLS via Cloudflare and edge caching).
   - TTL: Auto.
3. Save.

Then back in the Pages project:

1. **Custom domains → Set up a custom domain.**
2. Enter `idk.potatocore.com`. Cloudflare verifies the CNAME instantly (same account) and issues a cert.

Within ~30 seconds the domain is live.

## 4. (Optional) Environment variables

You **do not** want `VITE_OPENAI_API_KEY` set in production — that env var gets baked into the JavaScript bundle and shipped to every visitor. The BYOK flow is exactly so this isn't needed.

If you ever decide to ship a default key for a closed beta or similar, do not set it as `VITE_OPENAI_API_KEY`. Use a Cloudflare Worker or Pages Function as a proxy instead so the key stays server-side.

For local dev only, you can drop `VITE_OPENAI_API_KEY=sk-…` into a `.env.local` file (gitignored by `*.env` already) — the panel will fall back to it when `import.meta.env.DEV` is true.

## 5. Automatic deploys

By default Cloudflare Pages rebuilds and ships on every push to the production branch. Preview deploys spin up automatically for every other branch and PR.

To trigger a manual rebuild: **Deployments → Retry deployment** on the project page.

---

## Troubleshooting

**Build fails on `better-sqlite3`.** It's a native module compiled at install time. Pages runs the build inside a fresh Linux container, so this works out of the box on `NODE_VERSION=20`. If 18 gives you `NODE_MODULE_VERSION` errors, bump it.

**Build succeeds but the site is blank.** Open DevTools → Network. If `archive.db` is requested at runtime you've broken the Vite plugin contract — the db is *only* read at build time and inlined as JSON in the bundle.

**`idk.potatocore.com` 522/525.** TLS handshake issue. Make sure the DNS record is **proxied** (orange cloud) and the Pages custom domain was added through the Pages UI, not just DNS. The orange cloud + Pages domain combo is what wires the cert.

**OpenAI calls fail with 401.** The user's key is wrong, expired, or not authorized for the model. The error in the chat panel will surface the OpenAI status code verbatim.

**OpenAI calls fail with CORS.** Shouldn't happen — `api.openai.com` allows browser calls. If it does, the user's network may be intercepting (corporate proxy, ad blocker). Try a different network.

---

## What this gets you

- `https://idk.potatocore.com` serving the archive globally from Cloudflare's edge.
- Free, auto-renewing TLS.
- Push-to-deploy from git.
- Preview URLs for every branch.
- Zero servers to maintain.
- Zero recurring cost on the Cloudflare Pages free tier (500 builds/month, unlimited bandwidth).
