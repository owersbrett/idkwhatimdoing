export type Glossary = { term: string; def: string };

export type Chapter = {
  num: string;
  topic: string;
  kicker: string;
  pitch: string;
  bag: string;
  glossary: Glossary[];
  inset?: InsetKind;
};

export type InsetKind = 'binder' | 'apprentice' | 'sign' | 'swatches' | 'wiring' | 'contract' | 'truck' | 'storefront';

export const chapters: Chapter[] = [
  {
    num: '01',
    topic: 'Git',
    kicker: 'A binder for every pitch you have ever written.',
    pitch:
      'A fresh notebook starts every season, and the old ones go up on the shelf. Imagine that for your sales pitches. Every time you change your pitch, you do not throw the old one away. You photograph it, label it ("Tuesday, post-rain price update"), and slip it into a binder. Tomorrow you can flip back to last Tuesday\'s exact pitch in seconds. You can compare two pitches side by side. You can keep one shelf for the festival circuit and another shelf for grocery wholesale, both alive at once. When the festival pitch finds a great closing line, you can lift just that line over to the wholesale pitch and keep going.',
    bag:
      'That binder is a git repository. Each labeled photo is a commit. The shelves are branches. Lifting a line from one shelf to another is a merge. Everything stays recoverable. Nothing is lost by changing your mind.',
    glossary: [
      { term: 'commit', def: 'a labeled snapshot of every file at a moment in time' },
      { term: 'branch', def: 'a parallel line of work' },
      { term: 'merge', def: 'combine work from two branches' },
      { term: 'repository', def: 'the project plus its full history' },
    ],
    inset: 'binder',
  },
  {
    num: '02',
    topic: 'Claude',
    kicker: 'A brilliant trainee with no memory of yesterday.',
    pitch:
      'Picture an apprentice who has read every book ever written about potatoes, sales, conversation, accounting, and customer psychology. Brilliant. The catch: every morning the apprentice wakes up with no memory of yesterday. So each day you write them a short brief. "Today we are at the Saturday market. We are selling russets. The regular at eleven likes them small. Our markup is forty percent." Hand them the brief and they can help you all day. When they reach for the scale, the register, or the phone, that is them using tools.',
    bag:
      'The brief is a prompt. Their universal knowledge is the model (in this case Claude, made by a company called Anthropic). Reaching for the scale or the phone is tool use. Claude Code, which is writing this manual, is the same apprentice equipped with different tools: read files on your computer, edit files, run shell commands. Stateless across sessions; warm and helpful within one.',
    glossary: [
      { term: 'model', def: 'the trained brain behind the conversation' },
      { term: 'prompt', def: 'the instructions handed in at the start of a turn' },
      { term: 'tool use', def: 'when the model runs a real action: reads a file, runs a command' },
    ],
    inset: 'apprentice',
  },
  {
    num: '03',
    topic: 'HTML',
    kicker: 'What exists, before anyone paints it.',
    pitch:
      'Walk up to your stand. There is a sign that reads POTATUHS. There is a bin labeled RUSSET. There is a chalkboard with today\'s price. There is a button that says BUY 5 GET 1 FREE. No colors yet, no paint, no behavior. Just the bones. The decision that a sign is a sign and a button is a button. That is HTML.',
    bag:
      'HTML names the meaning of each part of a page. A heading is a heading, a paragraph is a paragraph, a button is a button. Browsers and assistive tools (screen readers, voice control) read the structure to understand what to do. The look comes later, in CSS. The behavior comes later, in JavaScript.',
    glossary: [
      { term: 'element', def: 'a labeled piece of a page (heading, paragraph, button, image)' },
      { term: 'tag', def: 'the angle-bracketed name of an element, like <h1> or <p>' },
      { term: 'semantic HTML', def: 'choosing the right tag for the meaning, not the look' },
    ],
    inset: 'sign',
  },
  {
    num: '04',
    topic: 'CSS',
    kicker: 'All paint, no plumbing.',
    pitch:
      'Now you paint. The awning is burnt sienna. The chalkboard text is a hand-lettered serif. The bins sit eighteen inches apart. When the market lights come up at dusk, the whole stand warms into a softer light. When a customer walks up with a phone instead of standing in front of the stand, the stand rearranges itself to fit. CSS is the look, and the look on every surface.',
    bag:
      'CSS describes how each element appears: color, type, spacing, layout, transitions, responsiveness across screen sizes. It does not change what the elements are; it changes how they read. A good CSS file is mostly tokens (colors, spacing, type sizes) and a small number of rules using them.',
    glossary: [
      { term: 'selector', def: 'how a rule picks which elements it applies to' },
      { term: 'property', def: 'what aspect is being styled (color, font, padding)' },
      { term: 'token', def: 'a named value reused across the design' },
    ],
    inset: 'swatches',
  },
  {
    num: '05',
    topic: 'JavaScript',
    kicker: 'What happens when somebody touches the stand.',
    pitch:
      'A customer touches the BUY 5 GET 1 FREE sign and the prices update. They place six potatoes on the scale and the register applies the discount. They walk away and the stand quietly logs the time and waves goodbye. CSS does not do any of that. CSS is paint, and paint does not move. JavaScript is the wiring under the counter that responds to people.',
    bag:
      'JavaScript is the language of behavior in the browser. Clicks, form input, fetching data from a server, updating part of the page without reloading the rest. Everything interactive on a modern website is JavaScript, possibly wrapped in a friendly framework like React.',
    glossary: [
      { term: 'event', def: 'something that happened (click, key press, scroll)' },
      { term: 'function', def: 'a named piece of behavior you can run again' },
      { term: 'framework', def: 'a kit of conventions for building bigger apps (React is the popular one)' },
    ],
    inset: 'wiring',
  },
  {
    num: '06',
    topic: 'TypeScript',
    kicker: 'A second set of eyes that reads your note before the customer sees it.',
    pitch:
      'You write a note for the apprentice: "sell five potatoes for ducks." Plain JavaScript will try its best, get confused, and stand around looking for ducks. TypeScript is the colleague at the doorway who reads the note before the apprentice does and says: "you cannot sell potatoes for ducks. Only dollars or euros." It catches mistakes before the customer is in front of you.',
    bag:
      'TypeScript is JavaScript with a contract. You declare what kinds of things go where ("a price is a number, a customer name is a string") and the editor flags any line that breaks the contract before the code is ever run. Same language, same runtime, fewer surprises in production.',
    glossary: [
      { term: 'type', def: 'a label that says what kind of value lives here' },
      { term: 'interface', def: 'a named shape for an object' },
      { term: 'type-check', def: 'verifying the contract holds across the whole codebase' },
    ],
    inset: 'contract',
  },
  {
    num: '07',
    topic: 'Vite',
    kicker: 'How modern websites get from your laptop to your browser.',
    pitch:
      'You wrote your stand: bins, signs, chalkboard, register. Now you need a truck that takes everything to the market, sets it up the moment you arrive, and starts swapping in updates instantly the second you change a price tag, all without tearing the stand back down. Vite is that truck. Quiet, fast, mostly invisible. It is the reason this manual reloaded the moment a file was saved.',
    bag:
      'Vite is a development tool for modern websites. While you are working, it serves your site at a local address (this manual lives at localhost:4747) and instantly updates the page when you change a file; that is called hot module replacement. When you are ready to ship, Vite bundles everything into a small, fast set of files you can upload to a host. It is what runs underneath the command "npm run dev" in most modern React projects, including Shopify\'s Hydrogen framework next door.',
    glossary: [
      { term: 'dev server', def: 'the local web server used while building' },
      { term: 'HMR', def: 'hot module replacement: updating part of the running page without a full reload' },
      { term: 'bundle', def: 'the packaged-up version of the site, ready to publish' },
    ],
    inset: 'truck',
  },
  {
    num: '08',
    topic: 'Hydrogen and Shopify',
    kicker: 'The store, the system behind every store, and the React-shaped key that opens it.',
    pitch:
      'Shopify is the company that runs the back office of millions of small stores. Inventory, payments, taxes, shipping, receipts. If you opened a Potatuhs online store tomorrow, Shopify could be the engine doing the boring but critical work behind the curtain. Hydrogen is Shopify\'s own kit for the front of the store, the part the customer sees, built in React. You get a storefront that is fast, search-friendly, and already talking to your Shopify back office.',
    bag:
      'A Shopify store has two halves. The back office (admin, inventory, orders, payments) lives on Shopify\'s servers and is the same for every store. The front of the store (homepage, product pages, cart, checkout) is a website that can be designed any way you want. Hydrogen is a React framework Shopify ships specifically for building that front of the store, on top of Vite and React Router. You write components for product cards, collections, cart drawers; Hydrogen wires them to Shopify\'s data so you do not have to write the plumbing.',
    glossary: [
      { term: 'storefront', def: 'the customer-facing side of an online store' },
      { term: 'headless commerce', def: 'back office on Shopify, front built independently' },
      { term: 'framework', def: 'a kit of conventions and helpers (Hydrogen is one for stores)' },
    ],
    inset: 'storefront',
  },
];

export type SkillNote = {
  name: string;
  used: boolean;
  blurb: string;
  appliedHere?: string;
};

export const skills: SkillNote[] = [
  {
    name: 'impeccable',
    used: true,
    blurb:
      'A senior design partner. Loads shared design laws and a register-specific reference, then applies them to whatever interface is being built. Enforces OKLCH color, intentional theme, strong type hierarchy, restrained palettes, varied spacing, no glassmorphism-by-reflex, no gradient text, no em dashes in copy, no first-reflex category aesthetics (a finance app should not default to navy and gold, an AI app should not default to dark mode by reflex).',
    appliedHere:
      'Chose Restrained as the color strategy: warm cream surface, deep ink, a single russet accent under ten percent of any view. Picked the theme from a one-sentence physical scene (a salesman reading at a daylit stand). Built the chapter rhythm with varied numeral sides instead of an identical card grid. Stripped every em dash from the copy.',
  },
  {
    name: 'frontend-design',
    used: false,
    blurb: 'Builds distinctive, production-grade interfaces. Avoids the AI-generic aesthetic that creeps in by default.',
  },
  {
    name: 'extract-design',
    used: false,
    blurb:
      'Point it at any website URL and it returns the full design language: colors, typography, tokens, a Tailwind config, a shadcn theme, Figma variables, W3C tokens, plus an accessibility score.',
  },
  {
    name: 'claude-code-guide',
    used: false,
    blurb:
      'A specialist agent that answers questions about Claude Code itself: hooks, slash commands, MCP servers, settings, IDE integrations, keyboard shortcuts, and the Anthropic SDK.',
  },
  {
    name: 'init',
    used: false,
    blurb:
      'Walks a project, reads how it is built, and writes the project\'s own CLAUDE.md file so future sessions arrive oriented.',
  },
];
