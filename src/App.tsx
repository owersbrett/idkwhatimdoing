import { useEffect, useRef, useState } from 'react';
import { days as archive, type Day } from 'virtual:archive';
import ManualDay from './manual';
import QADay from './qa';

const TODAY = new Date().toISOString().slice(0, 10);

function initialDate(): string {
  const hash = typeof window !== 'undefined' ? window.location.hash.replace(/^#/, '') : '';
  if (archive.some((d) => d.date === hash)) return hash;
  return archive[0]?.date ?? '';
}

export default function App() {
  const [date, setDate] = useState<string>(initialDate);

  useEffect(() => {
    const onHash = () => {
      const h = window.location.hash.replace(/^#/, '');
      setDate(archive.some((d) => d.date === h) ? h : archive[0]?.date ?? '');
    };
    window.addEventListener('hashchange', onHash);
    return () => window.removeEventListener('hashchange', onHash);
  }, []);

  useReveal(date);

  const day = archive.find((d) => d.date === date) ?? archive[0];
  if (!day) return null;

  return (
    <main className="page">
      <AppHeader days={archive} currentDate={day.date} />
      <div key={day.date} className="day">
        {day.kind === 'manual' ? <ManualDay /> : <QADay day={day} />}
      </div>
      <Colophon day={day} />
    </main>
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
    </footer>
  );
}

export function Divider() {
  return <hr className="divider" aria-hidden />;
}

export function PotatoGlyph() {
  return (
    <svg viewBox="0 0 40 32" width="28" height="22" aria-hidden>
      <path
        d="M6 18 C 4 8, 14 2, 22 4 C 32 6, 38 14, 36 22 C 34 28, 24 30, 16 28 C 8 26, 8 24, 6 18 Z"
        fill="currentColor"
        opacity="0.92"
      />
      <circle cx="16" cy="14" r="1.1" fill="var(--bg)" />
      <circle cx="25" cy="19" r="0.9" fill="var(--bg)" />
      <circle cx="20" cy="22" r="0.7" fill="var(--bg)" />
    </svg>
  );
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
