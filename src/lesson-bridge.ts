// Lesson bridge — lets potatocore.com drive this site while it's embedded as
// CAM 02. The parent can't touch our DOM across the origin boundary, so it
// posts commands and we execute them on ourselves. Matches the sender in the
// potatocore repo (src/app/LessonPlayer.tsx / src/data/lessons.ts).

const MSG_KEY = '__potatocoreLesson';
const HIGHLIGHT_CLASS = 'lesson-bridge-highlight';

type Command =
  | { type: 'highlight'; selector: string }
  | { type: 'scrollTo'; selector: string }
  | { type: 'click'; selector: string }
  | { type: 'clear' }
  | { type: 'requestState' };

// Snapshot of what's on screen, broadcast to the parent so it can react
// (e.g. potatocore's character frame barks about the current page).
export interface LessonState {
  date: string;
  view: string;
  dayIndex: number;
  dayCount: number;
  entryCount: number;
  title: string | null;
  kind: string;
}

let lastState: LessonState | null = null;

export function reportLessonState(state: LessonState) {
  if (typeof window === 'undefined') return;
  lastState = state;
  if (window.self === window.top) return; // only when embedded
  window.parent.postMessage({ __potatocoreState: true, state }, '*');
}

function originAllowed(origin: string): boolean {
  if (origin.endsWith('://potatocore.com') || origin.endsWith('.potatocore.com')) return true;
  if (/^https?:\/\/localhost(:\d+)?$/.test(origin)) return true;
  if (/^https?:\/\/127\.0\.0\.1(:\d+)?$/.test(origin)) return true;
  return false;
}

function ensureStyle() {
  if (document.getElementById('lesson-bridge-style')) return;
  const style = document.createElement('style');
  style.id = 'lesson-bridge-style';
  style.textContent = `
    .${HIGHLIGHT_CLASS} {
      outline: 2px solid #e03030 !important;
      outline-offset: 4px;
      border-radius: 4px;
      box-shadow: 0 0 0 4px rgba(224, 48, 48, 0.18), 0 0 22px rgba(224, 48, 48, 0.5) !important;
      transition: outline-color 0.2s, box-shadow 0.2s;
      scroll-margin: 25vh;
    }
  `;
  document.head.appendChild(style);
}

function clearHighlights() {
  document.querySelectorAll('.' + HIGHLIGHT_CLASS).forEach((el) => el.classList.remove(HIGHLIGHT_CLASS));
}

function highlight(selector: string): boolean {
  const el = document.querySelector(selector);
  if (!el) return false;
  ensureStyle();
  clearHighlights();
  el.classList.add(HIGHLIGHT_CLASS);
  return true;
}

function run(cmd: Command): boolean {
  switch (cmd.type) {
    case 'clear':
      clearHighlights();
      return true;
    case 'highlight':
      return highlight(cmd.selector);
    case 'scrollTo': {
      const el = document.querySelector(cmd.selector);
      if (!el) return false;
      el.scrollIntoView({ behavior: 'smooth', block: 'center' });
      highlight(cmd.selector);
      return true;
    }
    case 'click': {
      const el = document.querySelector<HTMLElement>(cmd.selector);
      if (!el) return false;
      el.click();
      return true;
    }
    default:
      return false;
  }
}

export function installLessonBridge() {
  if (typeof window === 'undefined') return;
  // Only act when actually embedded — no-op on the standalone site.
  if (window.self === window.top) return;

  window.addEventListener('message', (event: MessageEvent) => {
    if (!originAllowed(event.origin)) return;
    const data = event.data;
    if (!data || data[MSG_KEY] !== true || !data.cmd) return;

    // Parent asking for the current state (it may have mounted after us).
    if ((data.cmd as Command).type === 'requestState') {
      if (lastState && event.source && 'postMessage' in event.source) {
        (event.source as Window).postMessage(
          { __potatocoreState: true, state: lastState },
          event.origin,
        );
      }
      return;
    }

    const ok = run(data.cmd as Command);

    if (event.source && 'postMessage' in event.source) {
      (event.source as Window).postMessage(
        { __potatocoreLessonAck: true, type: (data.cmd as Command).type, ok },
        event.origin,
      );
    }
  });
}
