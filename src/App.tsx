import { useEffect, useRef } from 'react';
import { chapters, skills, type Chapter } from './content';

export default function App() {
  useReveal();

  return (
    <main className="page">
      <Eyebrow />
      <Hero />
      <Manual />
      <BehindTheCounter />
      <Closing />
      <Colophon />
    </main>
  );
}

function Eyebrow() {
  return (
    <div className="eyebrow reveal">
      <span className="eyebrow__mark" aria-hidden>
        <PotatoGlyph />
      </span>
      <span className="eyebrow__text">Potatuhs Salesman School. Volume I.</span>
      <span className="eyebrow__rule" aria-hidden />
      <span className="eyebrow__meta">For the master of the bin who has never typed a tag.</span>
    </div>
  );
}

function Hero() {
  return (
    <header className="hero">
      <p className="hero__kicker reveal">A short, friendly manual.</p>
      <h1 className="hero__title reveal" style={{ ['--reveal-delay' as string]: '60ms' }}>
        Eight things <em>under</em> the website,
        <br />
        explained at the stand.
      </h1>
      <p className="hero__lead reveal" style={{ ['--reveal-delay' as string]: '140ms' }}>
        Git, Claude, HTML, CSS, JavaScript, TypeScript, Vite, and Shopify Hydrogen. Each one
        described once for the master salesman who has never opened a code editor, then
        described once more for the back office. No need to remember any of it tomorrow.
      </p>
      <Divider />
    </header>
  );
}

function Manual() {
  return (
    <section className="manual" aria-label="Chapters">
      {chapters.map((ch, i) => (
        <ChapterBlock key={ch.num} ch={ch} side={i % 2 === 0 ? 'left' : 'right'} />
      ))}
    </section>
  );
}

function ChapterBlock({ ch, side }: { ch: Chapter; side: 'left' | 'right' }) {
  return (
    <article className={`chapter chapter--${side}`} id={`ch-${ch.num}`}>
      <div className="chapter__numeral reveal" aria-hidden>
        {ch.num}
      </div>

      <div className="chapter__body">
        <header className="chapter__head reveal">
          <span className="chapter__kicker">Chapter {ch.num}</span>
          <h2 className="chapter__topic">{ch.topic}</h2>
          <p className="chapter__tagline">{ch.kicker}</p>
        </header>

        <div className="chapter__cols">
          <div className="block reveal">
            <span className="block__eyebrow">The pitch</span>
            <p className="block__body block__body--lead">{ch.pitch}</p>
          </div>

          <div className="chapter__inset reveal" aria-hidden>
            <Inset kind={ch.inset} topic={ch.topic} />
          </div>

          <div className="block reveal">
            <span className="block__eyebrow">The bag</span>
            <p className="block__body">{ch.bag}</p>
          </div>

          <dl className="glossary reveal">
            {ch.glossary.map((g) => (
              <div className="glossary__row" key={g.term}>
                <dt className="glossary__term">{g.term}</dt>
                <dd className="glossary__def">{g.def}</dd>
              </div>
            ))}
          </dl>
        </div>
      </div>

      <Divider />
    </article>
  );
}

function BehindTheCounter() {
  return (
    <section className="counter" aria-labelledby="counter-title">
      <header className="counter__head reveal">
        <span className="chapter__kicker">Behind the counter</span>
        <h2 id="counter-title" className="counter__title">
          The apprentice keeps a small box of skills.
        </h2>
        <p className="counter__lead">
          A skill is a short manual the apprentice reads before starting a particular kind of
          work. It does not change what the apprentice can do; it changes how the apprentice
          approaches a kind of work, what to avoid, what to insist on. The list below is the
          set that came up during the writing of this manual.
        </p>
      </header>

      <ul className="skills">
        {skills.map((s) => (
          <li key={s.name} className={`skill ${s.used ? 'skill--used' : ''} reveal`}>
            <div className="skill__head">
              <span className="skill__name">{s.name}</span>
              <span className={`skill__chip ${s.used ? 'skill__chip--on' : ''}`}>
                {s.used ? 'used here' : 'on the shelf'}
              </span>
            </div>
            <p className="skill__blurb">{s.blurb}</p>
            {s.appliedHere && (
              <p className="skill__applied">
                <span className="skill__appliedLabel">Applied here. </span>
                {s.appliedHere}
              </p>
            )}
          </li>
        ))}
      </ul>
    </section>
  );
}

function Closing() {
  return (
    <section className="closing reveal" aria-labelledby="closing-title">
      <Divider />
      <h2 id="closing-title" className="closing__title">
        The whole stand, at a glance.
      </h2>
      <p className="closing__body">
        Most websites are this same set of ingredients in different proportions. HTML for the
        structure. CSS for the look. JavaScript, usually as TypeScript, for the behavior. Vite
        (or something like it) running the page while you build. A framework like React, or
        Hydrogen if you are running a Shopify store, sitting on top. Git keeping every version
        of the work. And an apprentice like Claude helping you write the whole thing.
      </p>
      <p className="closing__body">
        None of this needed to be known last week. None of it needs to be remembered tomorrow.
        The point is the words on the page when they are useful.
      </p>
    </section>
  );
}

function Colophon() {
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
          <p className="colophon__value">Vite, React, TypeScript</p>
        </div>
        <div>
          <p className="colophon__label">Served at</p>
          <p className="colophon__value">localhost:4747</p>
        </div>
        <div>
          <p className="colophon__label">Hand on the pen</p>
          <p className="colophon__value">Claude (Anthropic)</p>
        </div>
      </div>
      <p className="colophon__mark">
        <PotatoGlyph />
        <span>Potatuhs</span>
      </p>
    </footer>
  );
}

function Divider() {
  return (
    <svg className="divider" viewBox="0 0 600 16" preserveAspectRatio="none" aria-hidden>
      <path
        d="M0 8 C 40 2, 80 14, 120 8 S 200 2, 240 8 320 14, 360 8 440 2, 480 8 560 14, 600 8"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.25"
        strokeLinecap="round"
      />
    </svg>
  );
}

function PotatoGlyph() {
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

function Inset({ kind, topic }: { kind?: Chapter['inset']; topic: string }) {
  switch (kind) {
    case 'binder':
      return (
        <figure className="inset inset--binder" aria-label="Binder of pitches">
          <div className="binder">
            {['Mon', 'Tue', 'Wed', 'Thu', 'Fri'].map((d) => (
              <div className="binder__tab" key={d}>
                <span className="binder__day">{d}</span>
                <span className="binder__note">pitch v{Math.floor(Math.random() * 9) + 1}</span>
              </div>
            ))}
          </div>
          <figcaption>Five labeled pitches, all recoverable.</figcaption>
        </figure>
      );
    case 'apprentice':
      return (
        <figure className="inset inset--apprentice" aria-label="Morning brief">
          <div className="brief">
            <p className="brief__title">Brief for Tuesday</p>
            <ul>
              <li>Saturday market. Russets, golds.</li>
              <li>Markup forty percent.</li>
              <li>The eleven a.m. regular likes them small.</li>
              <li>If it rains, hold the bins on the left.</li>
            </ul>
          </div>
          <figcaption>The brief you would hand the apprentice.</figcaption>
        </figure>
      );
    case 'sign':
      return (
        <figure className="inset inset--sign" aria-label="Plain HTML structure">
          <div className="bones">
            <div className="bones__row" data-tag="h1">POTATUHS</div>
            <div className="bones__row" data-tag="p">Today: russets, golds, blues.</div>
            <div className="bones__row" data-tag="label">RUSSET</div>
            <div className="bones__row" data-tag="button">BUY 5 GET 1 FREE</div>
          </div>
          <figcaption>The stand in pure structure, no paint yet.</figcaption>
        </figure>
      );
    case 'swatches':
      return (
        <figure className="inset inset--swatches" aria-label="Color and type tokens">
          <div className="swatches">
            <div className="swatch" style={{ background: 'var(--bg)' }}><span>cream</span></div>
            <div className="swatch" style={{ background: 'var(--surface)' }}><span>sand</span></div>
            <div className="swatch" style={{ background: 'var(--ink)', color: 'var(--bg)' }}><span>ink</span></div>
            <div className="swatch" style={{ background: 'var(--accent)', color: 'var(--bg)' }}><span>russet</span></div>
          </div>
          <figcaption>Tokens: a small set of named values used everywhere.</figcaption>
        </figure>
      );
    case 'wiring':
      return (
        <figure className="inset inset--wiring" aria-label="Tiny snippet of behavior">
          <pre className="snippet"><code>{`button.addEventListener('click', () => {
  total = price * count;
  if (count >= 5) total -= price;
  render();
});`}</code></pre>
          <figcaption>A little wiring under the counter.</figcaption>
        </figure>
      );
    case 'contract':
      return (
        <figure className="inset inset--contract" aria-label="Type contract">
          <pre className="snippet"><code>{`type Sale = {
  potatoes: number;
  paidIn: 'USD' | 'EUR';   // not 'ducks'
  buyer: string;
};`}</code></pre>
          <figcaption>The contract the colleague enforces.</figcaption>
        </figure>
      );
    case 'truck':
      return (
        <figure className="inset inset--truck" aria-label="The dev command">
          <pre className="snippet"><code>{`$ npm run dev
  VITE v6 ready in 312 ms
  ➜  Local:  http://localhost:4747/`}</code></pre>
          <figcaption>The truck pulling up to the market.</figcaption>
        </figure>
      );
    case 'storefront':
      return (
        <figure className="inset inset--storefront" aria-label="Hydrogen component">
          <pre className="snippet"><code>{`export function ProductCard({ product }: Props) {
  return (
    <Link to={\`/products/\${product.handle}\`}>
      <Image data={product.featuredImage} />
      <h3>{product.title}</h3>
      <Money data={product.priceRange.minVariantPrice} />
    </Link>
  );
}`}</code></pre>
          <figcaption>A Hydrogen component, the front of the store.</figcaption>
        </figure>
      );
    default:
      return <span className="inset__placeholder">{topic}</span>;
  }
}

function useReveal() {
  const observer = useRef<IntersectionObserver | null>(null);
  useEffect(() => {
    if (typeof IntersectionObserver === 'undefined') return;
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
    const nodes = document.querySelectorAll('.reveal');
    nodes.forEach((n) => observer.current?.observe(n));
    return () => observer.current?.disconnect();
  }, []);
}
