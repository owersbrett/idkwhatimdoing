import { useEffect, useRef, useState, type FormEvent } from 'react';
import { readStoredKey } from './apikey';

const MODEL = 'gpt-4o-mini';

type Msg = { role: 'user' | 'assistant'; content: string };

export default function VocabExample({
  term,
  def,
  onClose,
}: {
  term: string;
  def: string;
  onClose: () => void;
}) {
  const [messages, setMessages] = useState<Msg[]>([]);
  const [input, setInput] = useState('');
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const startedRef = useRef(false);
  const listRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [onClose]);

  useEffect(() => {
    const el = listRef.current;
    if (!el) return;
    el.scrollTo({ top: el.scrollHeight, behavior: 'smooth' });
  }, [messages]);

  useEffect(() => {
    if (startedRef.current) return;
    startedRef.current = true;
    void send('Give me one short, vivid, concrete example that makes this term click. One paragraph. No filler.');
  }, []);

  async function send(userText: string) {
    const trimmed = userText.trim();
    if (!trimmed || busy) return;
    const key = readStoredKey();
    if (!key) {
      setErr('No API key registered. Open the debug panel to save one.');
      return;
    }
    setErr(null);
    const next: Msg[] = [...messages, { role: 'user', content: trimmed }];
    setMessages(next);
    setBusy(true);

    try {
      const res = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${key}`,
        },
        body: JSON.stringify({
          model: MODEL,
          stream: true,
          messages: [{ role: 'system', content: systemPrompt(term, def) }, ...next],
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
            // ignore malformed chunks
          }
        }
      }
    } catch (e) {
      setErr(e instanceof Error ? e.message : String(e));
    } finally {
      setBusy(false);
    }
  }

  function onSubmit(e: FormEvent) {
    e.preventDefault();
    const t = input.trim();
    if (!t) return;
    setInput('');
    void send(t);
  }

  return (
    <div className="vmodal" role="dialog" aria-modal aria-labelledby="vmodal-title">
      <div className="vmodal__scrim" onClick={onClose} aria-hidden />
      <div className="vmodal__card">
        <header className="vmodal__head">
          <div>
            <p className="vmodal__kicker">Example</p>
            <h2 id="vmodal-title" className="vmodal__term">
              {term}
            </h2>
            <p className="vmodal__def">{def}</p>
          </div>
          <button
            className="vmodal__close"
            onClick={onClose}
            aria-label="Close example"
            type="button"
          >
            ×
          </button>
        </header>

        <div ref={listRef} className="vmodal__list">
          {messages
            .filter((m) => m.role === 'assistant' || messages.indexOf(m) > 0)
            .map((m, i) => (
              <div key={i} className={`vmodal__msg vmodal__msg--${m.role}`}>
                {m.role === 'user' && <div className="vmodal__role">you</div>}
                <div className="vmodal__content">
                  {m.content || (busy && m.role === 'assistant' && i === messages.length - 1 ? '…' : '')}
                </div>
              </div>
            ))}
        </div>

        {err && <p className="vmodal__err">{err}</p>}

        <form className="vmodal__form" onSubmit={onSubmit}>
          <input
            className="vmodal__input"
            placeholder="Ask for another example, or push deeper..."
            value={input}
            onChange={(e) => setInput(e.target.value)}
            disabled={busy}
          />
          <button type="submit" className="vmodal__send" disabled={busy || !input.trim()}>
            {busy ? '…' : 'Send'}
          </button>
        </form>
        <p className="vmodal__meta">
          model <code>{MODEL}</code> · context: this term only
        </p>
      </div>
    </div>
  );
}

function systemPrompt(term: string, def: string): string {
  return [
    `You are a tutor whose job is to build deep, durable expertise in technical terms for a self-taught developer.`,
    `Focus only on the term below. Keep context small and cheap.`,
    `Voice: matter-of-fact, vivid, concrete. Lead with the example, then the takeaway. No throat-clearing. No filler. No restating the definition unless asked.`,
    `If the user asks a follow-up, stay on this term unless they explicitly pivot.`,
    ``,
    `TERM: ${term}`,
    `DEFINITION: ${def}`,
  ].join('\n');
}
