/// <reference types="vite/client" />

declare const __BUILD_COMMIT__: string;
declare const __BUILD_TIME__: string;

interface ImportMetaEnv {
  readonly VITE_OPENAI_API_KEY?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}

declare module 'virtual:archive' {
  export type Vocab = { term: string; def: string };
  export type Quiz = {
    prompt: string;
    options: string[];
    answer: number;
    explanation: string;
  };
  export type Entry = {
    id: number;
    position: number;
    question: string;
    answer: string;
    vocab: Vocab[];
    quiz: Quiz | null;
  };
  export type Section = {
    position: number;
    kicker: string | null;
    label: string;
    body: string;
  };
  export type Day = {
    date: string;
    kind: 'manual' | 'qa';
    title: string | null;
    entries: Entry[];
    sections: Section[];
  };
  export const days: Day[];
  const _default: Day[];
  export default _default;
}
