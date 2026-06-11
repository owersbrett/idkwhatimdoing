import { useEffect, useRef, useState } from 'react';
import { days as archive, type Day } from 'virtual:archive';
import DebugPanel from './DebugPanel';
import Legal, { openLegal } from './Legal';
import ManualDay from './manual';
import QADay from './qa';

const TODAY = new Date().toISOString().slice(0, 10);

function initialDate(): string {
  const hash = typeof window !== 'undefined' ? window.location.hash.replace(/^#/, '') : '';
  if (archive.some((d) => d.date === hash)) return hash;

  return archive[0]?.date ?? '';
}

function isEntryAnchor(hash: string): boolean {
  return /^entry-\d+$/.test(hash);
}

export default function App() {
  const [date, setDate] = useState<string>(initialDate);

  useEffect(() => {
    const onHash = () => {
      const h = window.location.hash.replace(/^#/, '');
      if (isEntryAnchor(h)) return;
      setDate(archive.some((d) => d.date === h) ? h : archive[0]?.date ?? '');
    };
    window.addEventListener('hashchange', onHash);
    return () => window.removeEventListener('hashchange', onHash);
  }, []);

  useReveal(date);

  const day = archive.find((d) => d.date === date) ?? archive[0];
  if (!day) return null;

  return (
    <>
      <DebugPanel day={day} />
      <main className="page">
        <AppHeader days={archive} currentDate={day.date} />
        <div key={day.date} className="day">
          {day.kind === 'manual' ? <ManualDay /> : <QADay day={day} />}
        </div>
        <Colophon day={day} />
      </main>
      <Legal />
    </>
  );
}

function AppHeader({ days, currentDate }: { days: Day[]; currentDate: string }) {
  const current = days.find((d) => d.date === currentDate);
  const label = currentDate === TODAY ? 'Today' : prettyDate(currentDate);

  return (
    <header className="eyebrow">
      <span className="eyebrow__mark" aria-hidden>
        <PotatoGlyph />
      </span>
      <span className="eyebrow__text">idkwhatimdoing. Daily archive.</span>
      <span className="eyebrow__rule" aria-hidden />
      <span className="eyebrow__meta">
        {label}
        {current?.title ? ` · ${current.title}` : ''}
      </span>

      <div className="picker">
        <label className="picker__label" htmlFor="day-picker">
          Day
        </label>
        <select
          id="day-picker"
          className="picker__select"
          value={currentDate}
          onChange={(e) => {
            window.location.hash = e.target.value;
          }}
        >
          {days.map((d) => (
            <option key={d.date} value={d.date}>
              {d.date}
              {d.date === TODAY ? ' · today' : ''}
              {d.title ? ` — ${d.title}` : ''}
            </option>
          ))}
        </select>
      </div>
    </header>
  );
}

function Colophon({ day }: { day: Day }) {
  return (
    <footer className="colophon">
      <Divider />
      <div className="colophon__grid">
        <div>
          <p className="colophon__label">Set in</p>
          <p className="colophon__value">Fraunces and Inter</p>
        </div>
        <div>
          <p className="colophon__label">Built with</p>
          <p className="colophon__value">Vite, React, TypeScript, SQLite</p>
        </div>
        <div>
          <p className="colophon__label">Served at</p>
          <p className="colophon__value">localhost:4747</p>
        </div>
        <div>
          <p className="colophon__label">Viewing</p>
          <p className="colophon__value">{day.date}</p>
        </div>
      </div>
      <p className="colophon__mark">
        <PotatoGlyph />
        <span>Potatuhs</span>
      </p>
      <p className="colophon__legal">
        <button type="button" onClick={openLegal}>
          Terms &amp; privacy
        </button>
      </p>
    </footer>
  );
}

export function Divider() {
  return <hr className="divider" aria-hidden />;
}

export function PotatoGlyph() {
  return <img className="potatomark" src="/potatuhs.png" alt="" width={32} height={32} />;
}

function useReveal(key: string) {
  const observer = useRef<IntersectionObserver | null>(null);
  useEffect(() => {
    if (typeof IntersectionObserver === 'undefined') return;
    observer.current?.disconnect();
    observer.current = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            entry.target.classList.add('is-revealed');
            observer.current?.unobserve(entry.target);
          }
        }
      },
      { threshold: 0.12, rootMargin: '0px 0px -8% 0px' },
    );
    const nodes = document.querySelectorAll('.reveal:not(.is-revealed)');
    nodes.forEach((n) => observer.current?.observe(n));
    return () => observer.current?.disconnect();
  }, [key]);
}

function prettyDate(iso: string): string {
  try {
    const d = new Date(iso + 'T00:00:00');
    return d.toLocaleDateString(undefined, { month: 'long', day: 'numeric', year: 'numeric' });
  } catch {
    return iso;
  }
}
