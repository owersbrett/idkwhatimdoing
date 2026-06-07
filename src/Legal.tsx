import { useEffect, useState } from 'react';

const OPEN_EVENT = 'idkwhatimdoing:open-legal';

export function openLegal() {
  window.dispatchEvent(new CustomEvent(OPEN_EVENT));
}

export default function Legal() {
  const [open, setOpen] = useState(false);

  useEffect(() => {
    const onOpen = () => setOpen(true);
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') setOpen(false);
    };
    window.addEventListener(OPEN_EVENT, onOpen);
    window.addEventListener('keydown', onKey);
    return () => {
      window.removeEventListener(OPEN_EVENT, onOpen);
      window.removeEventListener('keydown', onKey);
    };
  }, []);

  if (!open) return null;

  return (
    <div className="legal" role="dialog" aria-modal aria-labelledby="legal-title">
      <div className="legal__scrim" onClick={() => setOpen(false)} aria-hidden />
      <div className="legal__card">
        <button
          className="legal__close"
          onClick={() => setOpen(false)}
          aria-label="Close terms and privacy"
          type="button"
        >
          ×
        </button>
        <h2 id="legal-title">Terms &amp; privacy</h2>
        <p className="legal__updated">Updated 2026-06-06</p>

        <p>
          This site is a static, single-page web app. There is no backend, no account system,
          no analytics, and no server-side logging owned by this site. Everything you read is
          delivered as a static bundle from a CDN.
        </p>

        <h3>The OpenAI key</h3>
        <p>
          The on-page chat and per-term example tutor call the OpenAI API directly from your
          browser using an API key that you provide. When you paste your key and click{' '}
          <code>Save</code>, it is written to <code>localStorage</code> on this device only.
          The key is read back from <code>localStorage</code> on subsequent visits so you do
          not have to paste it again.
        </p>
        <p>
          Your key is sent on each chat request to <code>api.openai.com</code> over HTTPS in
          the standard <code>Authorization: Bearer</code> header. It is not transmitted to any
          other host, including the host serving this site. There is no proxy and no logging
          server in between you and OpenAI.
        </p>

        <h3>If you would rather not store the key</h3>
        <p>
          Storing an API key in browser <code>localStorage</code> means any JavaScript running
          on this origin can read it. We do not knowingly load third-party scripts, but the
          theoretical risk is real for any browser-stored secret. If you would prefer not to
          store it:
        </p>
        <p>
          • Click <code>forget key</code> in the chat panel after each session.
          <br />
          • Or use the site in a private/incognito window — the key clears when you close it.
          <br />
          • Or do not use the chat / example features at all — every page works without them.
          <br />
          • For maximum isolation, create a dedicated OpenAI key for this site at{' '}
          <a href="https://platform.openai.com/api-keys" target="_blank" rel="noreferrer">
            platform.openai.com/api-keys
          </a>{' '}
          and set a low usage cap on it. Revoke it any time.
        </p>

        <h3>What this site stores</h3>
        <p>
          Local to your browser only: the OpenAI key (if you saved one). That is the entire
          list. No cookies are set. No fingerprinting. No telemetry.
        </p>

        <h3>What this site shares with OpenAI</h3>
        <p>
          When you send a chat message or open the example tutor for a term, the page content
          relevant to your question and your message are sent to OpenAI along with your key.
          OpenAI's own privacy policy governs what they do with those requests.
        </p>

        <h3>What this site shares with the host</h3>
        <p>
          This site is served by Cloudflare Pages. Cloudflare receives standard web request
          logs (IP, user agent, request path) as part of routing traffic. We do not run our
          own logging or analytics on top of that.
        </p>

        <h3>Liability</h3>
        <p>
          This site is provided as-is, with no warranty of any kind. By using the chat
          features, you take responsibility for keeping your own API key safe and for any
          charges OpenAI bills you for the requests made with it.
        </p>

        <h3>Questions</h3>
        <p>
          Reach out via the Potatuhs side of the world if anything here is unclear or you
          would like a change.
        </p>
      </div>
    </div>
  );
}
