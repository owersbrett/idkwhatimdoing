export type Ad = {
  product: 'collection' | 'hat' | 'hoodie' | 'tee';
  eyebrow: string;
  headline: string;
  body: string;
  cta: string;
  href: string;
};

// Creative authored in Butter's voice (Potatuhs CMO). Sponsors the reader's
// side margin instead of leaving it empty. Links out to the storefront.
export const ads: Ad[] = [
  {
    product: 'collection',
    eyebrow: 'Potatuhs',
    headline: 'Everything We Make. All Potato.',
    body: "The full catalog. We've always been here. You just found us.",
    cta: 'Browse all',
    href: 'https://potatuhs.com/collections/all',
  },
  {
    product: 'hat',
    eyebrow: 'For the head',
    headline: 'A Hat. For Your Head.',
    body: 'Covers the top of you. Says Potatuhs. Asks nothing further.',
    cta: 'Get the hat',
    href: 'https://potatuhs.com/collections/all',
  },
  {
    product: 'hoodie',
    eyebrow: 'Outerwear division',
    headline: 'Uhhh... Just Wear The Hoodie.',
    body: 'Soft. Warm. Faintly potato. It will be here when the cold comes.',
    cta: 'Get warm',
    href: 'https://potatuhs.com/collections/all',
  },
  {
    product: 'tee',
    eyebrow: 'Daily wear',
    headline: 'One Shirt. Endless Potato.',
    body: 'A t-shirt you can wear every day. Nobody will ask questions.',
    cta: 'Get the tee',
    href: 'https://potatuhs.com/collections/all',
  },
];
