import { useEffect, useState } from 'react';

export const KEY_STORAGE = 'idkwhatimdoing:openai_key';
export const KEY_EVENT = 'idkwhatimdoing:key-change';

export function readStoredKey(): string {
  if (typeof localStorage !== 'undefined') {
    const stored = localStorage.getItem(KEY_STORAGE);
    if (stored) return stored;
  }
  if (import.meta.env.DEV && import.meta.env.VITE_OPENAI_API_KEY) {
    return import.meta.env.VITE_OPENAI_API_KEY;
  }
  return '';
}

export function saveKey(key: string) {
  const trimmed = key.trim();
  try {
    if (trimmed) localStorage.setItem(KEY_STORAGE, trimmed);
    else localStorage.removeItem(KEY_STORAGE);
  } catch {
    // private browsing / storage disabled — in-memory only
  }
  window.dispatchEvent(new CustomEvent(KEY_EVENT));
}

export function useApiKey(): string {
  const [key, setKey] = useState<string>(readStoredKey);
  useEffect(() => {
    const sync = () => setKey(readStoredKey());
    window.addEventListener('storage', sync);
    window.addEventListener(KEY_EVENT, sync);
    return () => {
      window.removeEventListener('storage', sync);
      window.removeEventListener(KEY_EVENT, sync);
    };
  }, []);
  return key;
}
