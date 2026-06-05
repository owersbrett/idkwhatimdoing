import type { Day, Entry } from 'virtual:archive';
import { Divider } from './App';

const TODAY = new Date().toISOString().slice(0, 10);

export default function QADay({ day }: { day: Day }) {
  return (
    <>
      <DayHero day={day} />
      <section className="qa" aria-label="Entries">
        {day.entries.map((entry, i) => (
          <EntryBlock key={entry.id} entry={entry} side={i % 2 === 0 ? 'left' : 'right'} />
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
      <p className="dayhero__kicker reveal">
        {isToday ? 'Today' : prettyDate(day.date)} · {day.date}
      </p>
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

function EntryBlock({ entry, side }: { entry: Entry; side: 'left' | 'right' }) {
  const paragraphs = entry.answer.split(/\n{2,}/).map((p) => p.trim()).filter(Boolean);
  return (
    <article className={`entry entry--${side}`} id={`entry-${entry.position}`}>
      <div className="entry__numeral reveal" aria-hidden>
        {String(entry.position).padStart(2, '0')}
      </div>

      <div className="entry__body">
        <header className="entry__head reveal">
          <span className="chapter__kicker">Entry {String(entry.position).padStart(2, '0')}</span>
          <h2 className="entry__question">{entry.question}</h2>
        </header>

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

      <Divider />
    </article>
  );
}

function DayLexicon({ day }: { day: Day }) {
  const allVocab = day.entries.flatMap((e) => e.vocab);
  if (allVocab.length === 0) return null;
  return (
    <section className="lexicon" aria-labelledby="lexicon-title">
      <header className="lexicon__head reveal">
        <span className="chapter__kicker">Today's lexicon</span>
        <h2 id="lexicon-title" className="lexicon__title">
          Words and phrases that surfaced.
        </h2>
        <p className="lexicon__lead">
          The list grows one day at a time. Eval mode (coming soon) will turn these into a circle-back
          worksheet.
        </p>
      </header>
      <dl className="lexicon__grid">
        {allVocab.map((v, i) => (
          <div key={i} className="lexicon__row">
            <dt className="lexicon__term">{v.term}</dt>
            <dd className="lexicon__def">{v.def}</dd>
          </div>
        ))}
      </dl>
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
