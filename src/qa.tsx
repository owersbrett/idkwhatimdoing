import { useEffect, useState } from 'react';
import type { Day, Entry, Vocab } from 'virtual:archive';
import { Divider } from './App';
import { useApiKey } from './apikey';
import VocabExample from './VocabExample';

const TODAY = new Date().toISOString().slice(0, 10);

export default function QADay({ day }: { day: Day }) {
  return (
    <>
      <DayHero day={day} />
      <JumpIndex day={day} />
      <section className="qa" aria-label="Entries">
        {day.entries.map((entry, i) => (
          <EntryBlock
            key={entry.id}
            entry={entry}
            side={i % 2 === 0 ? 'left' : 'right'}
            defaultOpen
          />
        ))}
      </section>
      <DayLexicon day={day} />
    </>
  );
}

function DayHero({ day }: { day: Day }) {
  const isToday = day.date === TODAY;
  return (
    <header className="dayhero">
      <div className="dayhero__kicker reveal">
        {isToday ? 'Today' : prettyDate(day.date)} · {day.date}
      </div>
      {day.title && (
        <h1 className="dayhero__title reveal" style={{ ['--reveal-delay' as string]: '60ms' }}>
          {day.title}.
        </h1>
      )}
      <p className="dayhero__lead reveal" style={{ ['--reveal-delay' as string]: '140ms' }}>
        {day.entries.length === 1
          ? 'One question, with an answer and the vocabulary it surfaced.'
          : `${numberWord(day.entries.length)} questions, each with an answer and the vocabulary it surfaced.`}
      </p>
      <Divider />
    </header>
  );
}

function JumpIndex({ day }: { day: Day }) {
  if (day.entries.length < 2) return null;
  return (
    <nav className="jump reveal" aria-label="Entries on this page">
      <span className="jump__label">On this page</span>
      <ol className="jump__list">
        {day.entries.map((e) => (
          <li key={e.id} className="jump__item">
            <a className="jump__link" href={`#entry-${e.position}`}>
              <span className="jump__num">{String(e.position).padStart(2, '0')}</span>
              <span className="jump__q">{e.question}</span>
            </a>
          </li>
        ))}
      </ol>
    </nav>
  );
}

function EntryBlock({
  entry,
  side,
  defaultOpen,
}: {
  entry: Entry;
  side: 'left' | 'right';
  defaultOpen: boolean;
}) {
  const [open, setOpen] = useState(defaultOpen);
  const paragraphs = entry.answer.split(/\n{2,}/).map((p) => p.trim()).filter(Boolean);
  const numeral = String(entry.position).padStart(2, '0');
  const contentId = `entry-${entry.position}-content`;

  useEffect(() => {
    const want = `#entry-${entry.position}`;
    const onHash = () => {
      if (window.location.hash === want) setOpen(true);
    };
    onHash();
    window.addEventListener('hashchange', onHash);
    return () => window.removeEventListener('hashchange', onHash);
  }, [entry.position]);

  return (
    <article className={`entry entry--${side}`} id={`entry-${entry.position}`}>
      <div className="entry__numeral reveal" aria-hidden>
        {numeral}
      </div>

      <div className="entry__body">
        <header className="entry__head reveal">
          <div className="entry__meta">
            <span className="chapter__kicker">Entry {numeral}</span>
            <ListenButton text={entry.answer} />
          </div>
          <h2 className="entry__question">
            <button
              type="button"
              className="entry__qtoggle"
              aria-expanded={open}
              aria-controls={contentId}
              onClick={() => setOpen((o) => !o)}
            >
              <span className="entry__qtext">{entry.question}</span>
              <span className="entry__caret" aria-hidden>
                {open ? '−' : '+'}
              </span>
            </button>
          </h2>
        </header>

        <div className="entry__content" id={contentId} hidden={!open}>
          <div className="entry__answer reveal">
            {paragraphs.map((p, i) => (
              <p key={i} className="entry__para">
                {p}
              </p>
            ))}
          </div>

          {entry.vocab.length > 0 && (
            <dl className="glossary reveal">
              {entry.vocab.map((v) => (
                <div className="glossary__row" key={v.term}>
                  <dt className="glossary__term">{v.term}</dt>
                  <dd className="glossary__def">{v.def}</dd>
                </div>
              ))}
            </dl>
          )}
        </div>
      </div>

      <Divider />
    </article>
  );
}

function ListenButton({ text }: { text: string }) {
  const [speaking, setSpeaking] = useState(false);

  useEffect(() => {
    return () => {
      if ('speechSynthesis' in window) window.speechSynthesis.cancel();
    };
  }, []);

  if (typeof window === 'undefined' || !('speechSynthesis' in window)) return null;

  function toggle() {
    const synth = window.speechSynthesis;
    if (speaking) {
      synth.cancel();
      setSpeaking(false);
      return;
    }
    synth.cancel();
    const utterance = new SpeechSynthesisUtterance(text);
    utterance.onend = () => setSpeaking(false);
    utterance.onerror = () => setSpeaking(false);
    synth.speak(utterance);
    setSpeaking(true);
  }

  return (
    <button
      type="button"
      className="entry__listen"
      onClick={toggle}
      aria-pressed={speaking}
      aria-label={speaking ? 'Stop reading this answer aloud' : 'Read this answer aloud'}
      title={speaking ? 'Stop reading this answer aloud' : 'Read this answer aloud'}
    >
      {speaking ? (
        <>
          <span aria-hidden>◼</span> Stop
        </>
      ) : (
        <svg viewBox="0 0 16 16" width="13" height="13" aria-hidden fill="none" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round">
          <path d="M2.5 6v4h2.6L9 13V3L5.1 6H2.5z" fill="currentColor" stroke="none" />
          <path d="M11 5.5a3.4 3.4 0 0 1 0 5" />
          <path d="M12.8 3.8a6 6 0 0 1 0 8.4" />
        </svg>
      )}
    </button>
  );
}

function DayLexicon({ day }: { day: Day }) {
  const allVocab = day.entries.flatMap((e) => e.vocab);
  const hasKey = Boolean(useApiKey());
  const [openTerm, setOpenTerm] = useState<Vocab | null>(null);

  if (allVocab.length === 0) return null;
  return (
    <section className="lexicon" aria-labelledby="lexicon-title">
      <header className="lexicon__head reveal">
        <span className="chapter__kicker">Today's lexicon</span>
        <h2 id="lexicon-title" className="lexicon__title">
          Words and phrases that surfaced.
        </h2>
        <p className="lexicon__lead">
          The list grows one day at a time.{' '}
          {hasKey
            ? 'Tap the example chip beside any term to drill in with a focused tutor chat.'
            : 'Add your OpenAI key in the debug panel to get an example tutor for every term.'}
        </p>
      </header>
      <dl className="lexicon__grid">
        {allVocab.map((v, i) => (
          <div key={i} className="lexicon__row">
            <dt className="lexicon__term">
              {v.term}
              {hasKey && (
                <button
                  type="button"
                  className="lexicon__example"
                  onClick={() => setOpenTerm(v)}
                  aria-label={`Show example for ${v.term}`}
                >
                  ex.
                </button>
              )}
            </dt>
            <dd className="lexicon__def">{v.def}</dd>
          </div>
        ))}
      </dl>
      {openTerm && (
        <VocabExample
          key={`${openTerm.term}-${openTerm.def}`}
          term={openTerm.term}
          def={openTerm.def}
          onClose={() => setOpenTerm(null)}
        />
      )}
    </section>
  );
}

function numberWord(n: number): string {
  const words = ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten'];
  return words[n] ?? String(n);
}

function prettyDate(iso: string): string {
  try {
    const d = new Date(iso + 'T00:00:00');
    return d.toLocaleDateString(undefined, { month: 'long', day: 'numeric', year: 'numeric' });
  } catch {
    return iso;
  }
}
