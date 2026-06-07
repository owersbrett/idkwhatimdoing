import { useEffect, useMemo, useRef, useState, type MouseEvent as ReactMouseEvent } from 'react';
import type { Day } from 'virtual:archive';
import { days as archive } from 'virtual:archive';
import { saveKey, useApiKey } from './apikey';
import { openLegal as triggerLegal } from './Legal';

const DEFAULT_MODEL = 'gpt-4o-mini';

const LOOPBACK_HOSTS = new Set(['localhost', '127.0.0.1', '::1', '0.0.0.0']);

export default function DebugPanel({ day }: { day: Day }) {
  const [open, setOpen] = useState(false);
  const [tab, setTab] = useState<'debug' | 'chat' | 'index'>('debug');

  useEffect(() => {
    document.body.classList.toggle('debug-open', open);
    return () => document.body.classList.remove('debug-open');
  }, [open]);

  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') setOpen(false);
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [open]);

  return (
    <>
      <nav className="dock" aria-label="Debug dock">
        <button
          className={`dock__toggle ${open ? 'is-open' : ''}`}
          onClick={() => setOpen((o) => !o)}
          aria-label={open ? 'Close debug panel' : 'Open debug panel'}
          aria-expanded={open}
          title={open ? 'Close debug panel (Esc)' : 'Open debug panel'}
        >
          <span className="dock__glyph" aria-hidden>
            <svg viewBox="0 0 16 16" width="18" height="18">
              <rect
                x="2.5"
                y="3"
                width="11"
                height="10"
                rx="2"
                fill="none"
                stroke="currentColor"
                strokeWidth="1.3"
              />
              <line x1="2.5" y1="6" x2="13.5" y2="6" stroke="currentColor" strokeWidth="1.3" />
              <circle cx="4.4" cy="4.5" r="0.55" fill="currentColor" />
              <circle cx="6.1" cy="4.5" r="0.55" fill="currentColor" />
              <line x1="5" y1="9" x2="11" y2="9" stroke="currentColor" strokeWidth="1.1" strokeLinecap="round" />
              <line x1="5" y1="11" x2="9" y2="11" stroke="currentColor" strokeWidth="1.1" strokeLinecap="round" />
            </svg>
          </span>
        </button>
      </nav>

      {open && <div className="dpanel__scrim" onClick={() => setOpen(false)} aria-hidden />}

      <aside
        className={`dpanel ${open ? 'is-open' : ''}`}
        aria-hidden={!open}
        aria-label="Debug panel"
      >
        <header className="dpanel__head">
          <div className="dpanel__tabs" role="tablist">
            <button
              role="tab"
              aria-selected={tab === 'debug'}
              className={`dpanel__tab ${tab === 'debug' ? 'is-active' : ''}`}
              onClick={() => setTab('debug')}
            >
              Debug
            </button>
            <button
              role="tab"
              aria-selected={tab === 'index'}
              className={`dpanel__tab ${tab === 'index' ? 'is-active' : ''}`}
              onClick={() => setTab('index')}
            >
              Index
            </button>
            <button
              role="tab"
              aria-selected={tab === 'chat'}
              className={`dpanel__tab ${tab === 'chat' ? 'is-active' : ''}`}
              onClick={() => setTab('chat')}
            >
              Chat
            </button>
          </div>
          <button
            className="dpanel__close"
            onClick={() => setOpen(false)}
            aria-label="Close debug panel"
          >
            ×
          </button>
        </header>
        <div className="dpanel__body">
          {tab === 'debug' && <DebugInfo day={day} />}
          {tab === 'index' && <Index onPick={(date) => { window.location.hash = date; setOpen(false); }} />}
          {tab === 'chat' && <Chat day={day} />}
        </div>
      </aside>
    </>
  );
}

function DebugInfo({ day }: { day: Day }) {
  const [vp, setVp] = useState(() => ({
    w: typeof window !== 'undefined' ? window.innerWidth : 0,
    h: typeof window !== 'undefined' ? window.innerHeight : 0,
  }));

  useEffect(() => {
    const onResize = () => setVp({ w: window.innerWidth, h: window.innerHeight });
    window.addEventListener('resize', onResize);
    return () => window.removeEventListener('resize', onResize);
  }, []);

  const totalEntries = archive.reduce((sum, d) => sum + d.entries.length, 0);
  const totalVocab = archive.reduce(
    (sum, d) => sum + d.entries.reduce((s, e) => s + e.vocab.length, 0),
    0,
  );
  const dayVocab = day.entries.reduce((s, e) => s + e.vocab.length, 0);

  const hostname = window.location.hostname;
  const isLoopback = LOOPBACK_HOSTS.has(hostname) || hostname.startsWith('127.');

  const rows: Array<[string, string]> = [
    ['date', day.date],
    ['title', day.title ?? '—'],
    ['kind', day.kind],
    ['entries (day)', String(day.entries.length)],
    ['vocab (day)', String(dayVocab)],
    ['days (db)', String(archive.length)],
    ['entries (db)', String(totalEntries)],
    ['vocab (db)', String(totalVocab)],
    ['build commit', __BUILD_COMMIT__],
    ['build time', __BUILD_TIME__],
    ['hostname', hostname],
    ['protocol', window.location.protocol],
    ['port', window.location.port || '(default)'],
    ['origin', window.location.origin],
    ['loopback?', isLoopback ? 'yes (this machine)' : 'no (public network)'],
    ['viewport', `${vp.w} × ${vp.h}`],
    ['user agent', navigator.userAgent],
  ];

  return (
    <div className="debug">
      <h3 className="dpanel__heading">Page state</h3>
      <dl className="debug__list">
        {rows.map(([k, v]) => (
          <div key={k} className="debug__row">
            <dt className="debug__key">{k}</dt>
            <dd className="debug__val">{v}</dd>
          </div>
        ))}
      </dl>

      <h3 className="dpanel__heading">Raw entries</h3>
      <pre className="debug__pre">{JSON.stringify(day, null, 2)}</pre>
    </div>
  );
}

type Msg = { role: 'user' | 'assistant'; content: string };

function Chat({ day }: { day: Day }) {
  const key = useApiKey();
  const [pendingKey, setPendingKey] = useState<string>('');
  const [messages, setMessages] = useState<Msg[]>([]);
  const [input, setInput] = useState<string>('');
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const listRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const el = listRef.current;
    if (!el) return;
    el.scrollTo({ top: el.scrollHeight, behavior: 'smooth' });
  }, [messages]);

  if (!key) {
    return (
      <div className="byok">
        <h3 className="dpanel__heading">Bring your own key</h3>
        <p className="byok__lead">
          The chat calls the OpenAI API directly from your browser using a key you paste here.
          The key is stored in <code>localStorage</code> on this device only and is sent nowhere
          except <code>api.openai.com</code>. By saving, you accept the{' '}
          <a href="#legal" onClick={openLegal}>
            terms &amp; privacy notes
          </a>
          .
        </p>
        <form
          className="byok__form"
          onSubmit={(e) => {
            e.preventDefault();
            const trimmed = pendingKey.trim();
            if (!trimmed) return;
            saveKey(trimmed);
            setPendingKey('');
          }}
        >
          <input
            type="password"
            value={pendingKey}
            onChange={(e) => setPendingKey(e.target.value)}
            placeholder="sk-..."
            className="byok__input"
            autoComplete="off"
            spellCheck={false}
          />
          <button type="submit" className="byok__submit" disabled={!pendingKey.trim()}>
            Save
          </button>
        </form>
        <p className="byok__note">
          Get a key at{' '}
          <a href="https://platform.openai.com/api-keys" target="_blank" rel="noreferrer">
            platform.openai.com/api-keys
          </a>
          .
        </p>
      </div>
    );
  }

  async function send() {
    const trimmed = input.trim();
    if (!trimmed || busy) return;
    setErr(null);
    const next: Msg[] = [...messages, { role: 'user', content: trimmed }];
    setMessages(next);
    setInput('');
    setBusy(true);

    try {
      const res = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${key}`,
        },
        body: JSON.stringify({
          model: DEFAULT_MODEL,
          stream: true,
          messages: [{ role: 'system', content: systemPrompt(day) }, ...next],
        }),
      });

      if (!res.ok || !res.body) {
        const text = await res.text().catch(() => '');
        throw new Error(`OpenAI ${res.status}: ${text.slice(0, 200) || 'request failed'}`);
      }

      setMessages((m) => [...m, { role: 'assistant', content: '' }]);

      const reader = res.body.getReader();
      const decoder = new TextDecoder();
      let buf = '';
      for (;;) {
        const { value, done } = await reader.read();
        if (done) break;
        buf += decoder.decode(value, { stream: true });
        const lines = buf.split('\n');
        buf = lines.pop() ?? '';
        for (const raw of lines) {
          const line = raw.trim();
          if (!line.startsWith('data:')) continue;
          const data = line.slice(5).trim();
          if (data === '[DONE]') continue;
          try {
            const json = JSON.parse(data);
            const delta: unknown = json?.choices?.[0]?.delta?.content;
            if (typeof delta === 'string' && delta.length > 0) {
              setMessages((m) => {
                const copy = m.slice();
                const last = copy[copy.length - 1];
                if (last && last.role === 'assistant') {
                  copy[copy.length - 1] = { ...last, content: last.content + delta };
                }
                return copy;
              });
            }
          } catch {
            // ignore malformed SSE chunks
          }
        }
      }
    } catch (e) {
      setErr(e instanceof Error ? e.message : String(e));
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="chat">
      <div className="chat__meta">
        <span>
          model <code>{DEFAULT_MODEL}</code>
        </span>
        <button
          className="chat__forget"
          onClick={() => {
            saveKey('');
            setMessages([]);
          }}
          type="button"
        >
          forget key
        </button>
      </div>
      <div ref={listRef} className="chat__list">
        {messages.length === 0 && (
          <p className="chat__empty">
            Ask anything about this page. The model sees today's entries and vocab as context.
          </p>
        )}
        {messages.map((m, i) => (
          <div key={i} className={`chat__msg chat__msg--${m.role}`}>
            <div className="chat__role">{m.role}</div>
            <div className="chat__content">
              {m.content || (busy && m.role === 'assistant' && i === messages.length - 1 ? '…' : '')}
            </div>
          </div>
        ))}
      </div>
      {err && <p className="chat__err">{err}</p>}
      <form
        className="chat__form"
        onSubmit={(e) => {
          e.preventDefault();
          send();
        }}
      >
        <textarea
          className="chat__input"
          rows={2}
          placeholder="Ask about this page..."
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
              e.preventDefault();
              send();
            }
          }}
          disabled={busy}
        />
        <button type="submit" className="chat__send" disabled={busy || !input.trim()}>
          {busy ? '…' : 'Send'}
        </button>
      </form>
    </div>
  );
}

type QuestionHit = {
  date: string;
  position: number;
  question: string;
  hit: 'question' | 'answer';
};

type VocabHit = {
  date: string;
  position: number;
  term: string;
  def: string;
};

function Index({ onPick }: { onPick: (date: string) => void }) {
  const [q, setQ] = useState('');
  const query = q.trim().toLowerCase();

  const results = useMemo(() => {
    if (!query) return null;
    const questions: QuestionHit[] = [];
    const vocab: VocabHit[] = [];

    for (const d of archive) {
      for (const e of d.entries) {
        const qHit = e.question.toLowerCase().includes(query);
        const aHit = !qHit && e.answer.toLowerCase().includes(query);
        if (qHit || aHit) {
          questions.push({
            date: d.date,
            position: e.position,
            question: e.question,
            hit: qHit ? 'question' : 'answer',
          });
        }
        for (const v of e.vocab) {
          if (v.term.toLowerCase().includes(query) || v.def.toLowerCase().includes(query)) {
            vocab.push({ date: d.date, position: e.position, term: v.term, def: v.def });
          }
        }
      }
    }

    questions.sort((a, b) => {
      if (a.hit !== b.hit) return a.hit === 'question' ? -1 : 1;
      return b.date.localeCompare(a.date);
    });
    vocab.sort((a, b) => b.date.localeCompare(a.date));

    return { questions, vocab, total: questions.length + vocab.length };
  }, [query]);

  return (
    <div className="idx">
      <input
        className="idx__input"
        type="search"
        placeholder="Search questions, answers, vocab…"
        value={q}
        onChange={(e) => setQ(e.target.value)}
        autoFocus
        spellCheck={false}
      />
      {results === null ? (
        <p className="idx__hint">Start typing to search the archive.</p>
      ) : results.total === 0 ? (
        <p className="idx__empty">No matches. Try a shorter query.</p>
      ) : (
        <>
          <p className="idx__count">
            {results.total} match{results.total === 1 ? '' : 'es'}
          </p>
          {results.questions.length > 0 && (
            <>
              <h3 className="dpanel__heading">Questions</h3>
              <ul className="idx__list">
                {results.questions.map((r, i) => (
                  <li key={`q-${i}`} className="idx__row">
                    <button
                      type="button"
                      className={`idx__btn ${r.hit === 'answer' ? 'idx__btn--soft' : ''}`}
                      onClick={() => onPick(r.date)}
                    >
                      <span className="idx__qtext">{r.question}</span>
                      <span className="idx__loc">
                        {r.date} · #{r.position}
                        {r.hit === 'answer' ? ' · matched in answer' : ''}
                      </span>
                    </button>
                  </li>
                ))}
              </ul>
            </>
          )}
          {results.vocab.length > 0 && (
            <>
              <h3 className="dpanel__heading">Vocab</h3>
              <ul className="idx__list">
                {results.vocab.map((r, i) => (
                  <li key={`v-${i}`} className="idx__row">
                    <button type="button" className="idx__btn" onClick={() => onPick(r.date)}>
                      <span className="idx__term">{r.term}</span>
                      <span className="idx__def">{r.def}</span>
                      <span className="idx__loc">
                        {r.date} · #{r.position}
                      </span>
                    </button>
                  </li>
                ))}
              </ul>
            </>
          )}
        </>
      )}
    </div>
  );
}

function openLegal(e: ReactMouseEvent) {
  e.preventDefault();
  triggerLegal();
}

function systemPrompt(day: Day): string {
  const entries = day.entries.map((e) => ({
    position: e.position,
    question: e.question,
    answer: e.answer,
    vocab: e.vocab,
  }));
  return [
    `You are a tutor embedded in a personal Q&A archive called "idkwhatimdoing".`,
    `The user is viewing the page for ${day.date}${day.title ? ` ("${day.title}")` : ''}.`,
    `Below is the full content of that page as JSON. Answer questions about it directly and concisely. When asked about a term, prefer the definitions in the vocab field. If the user asks about something not on this page, say so briefly and then give a short external answer.`,
    ``,
    `PAGE DATA:`,
    JSON.stringify({ date: day.date, title: day.title, entries }, null, 2),
  ].join('\n');
}
