import { chapters, skills, type Chapter } from './content';
import { Divider } from './App';

export default function ManualDay() {
  return (
    <>
      <Hero />
      <Manual />
      <BehindTheCounter />
      <Closing />
    </>
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

function Inset({ kind, topic }: { kind?: Chapter['inset']; topic: string }) {
  switch (kind) {
    case 'binder':
      return (
        <figure className="inset inset--binder" aria-label="Binder of pitches">
          <div className="binder">
            {['Mon', 'Tue', 'Wed', 'Thu', 'Fri'].map((d, i) => (
              <div className="binder__tab" key={d}>
                <span className="binder__day">{d}</span>
                <span className="binder__note">pitch v{((i * 3) % 9) + 1}</span>
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
