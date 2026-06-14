import type { Day, Section } from 'virtual:archive';

const PER_SIDE = 9; // 3 columns x 3 rows

export default function Brochure({ day }: { day: Day }) {
  const sides = chunk(day.sections, PER_SIDE);
  const total = day.sections.length;

  return (
    <section className="brochure" aria-label="Brochure for this day">
      <header className="brochure__masthead reveal">
        <span className="brochure__eyebrow">Field brochure</span>
        <h1 className="brochure__title">{day.title ?? day.date}</h1>
        <p className="brochure__sub">
          {total === 1 ? 'One thing we learned' : `${total} things we learned`} · {day.date}
        </p>
      </header>

      <div className="brochure__sheets">
        {sides.map((sections, i) => (
          <BrochureSide key={i} sections={sections} sideIndex={i} startNum={i * PER_SIDE} />
        ))}
      </div>
    </section>
  );
}

function BrochureSide({
  sections,
  sideIndex,
  startNum,
}: {
  sections: Section[];
  sideIndex: number;
  startNum: number;
}) {
  return (
    <article className="sheet reveal">
      <div className="sheet__grid">
        {sections.map((s, i) => (
          <div className="panel" key={s.position}>
            <span className="panel__num" aria-hidden>
              {String(startNum + i + 1).padStart(2, '0')}
            </span>
            {s.kicker && <span className="panel__kicker">{s.kicker}</span>}
            <h3 className="panel__label">{s.label}</h3>
            <p className="panel__body">{s.body}</p>
          </div>
        ))}
        {pad(sections.length).map((_, i) => (
          <div className="panel panel--empty" key={`empty-${i}`} aria-hidden />
        ))}
      </div>
      <div className="sheet__folio">
        <span className="sheet__dot" aria-hidden />
        Side {sideIndex + 1}
      </div>
    </article>
  );
}

function chunk<T>(arr: T[], size: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < arr.length; i += size) out.push(arr.slice(i, i + size));
  return out;
}

// Fill the rest of a 3x3 grid so the last side keeps its shape.
function pad(filled: number): undefined[] {
  const rem = filled % 3 === 0 ? 0 : 3 - (filled % 3);
  return new Array(rem).fill(undefined);
}
