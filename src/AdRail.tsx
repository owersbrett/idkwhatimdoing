import { ads } from './ads';

export default function AdRail() {
  return (
    <aside className="adrail" aria-label="Potatuhs storefront">
      <p className="adrail__kicker">Sponsored by the company that owns everything here</p>
      {ads.map((ad) => (
        <a key={ad.product} className="adcard" href={ad.href} target="_blank" rel="noopener noreferrer">
          <span className="adcard__eyebrow">{ad.eyebrow}</span>
          <span className="adcard__headline">{ad.headline}</span>
          <span className="adcard__body">{ad.body}</span>
          <span className="adcard__cta">{ad.cta} →</span>
        </a>
      ))}
    </aside>
  );
}
