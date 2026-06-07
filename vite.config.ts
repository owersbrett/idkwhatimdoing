import { defineConfig, type Plugin } from 'vite';
import react from '@vitejs/plugin-react';
import Database from 'better-sqlite3';
import { execSync } from 'node:child_process';
import { existsSync } from 'node:fs';
import { resolve } from 'node:path';

function gitCommit(): string {
  try {
    return execSync('git rev-parse --short HEAD', { stdio: ['ignore', 'pipe', 'ignore'] })
      .toString()
      .trim();
  } catch {
    return 'unknown';
  }
}

// Dev server: http://localhost:4747
export default defineConfig({
  plugins: [react(), archive({ dbPath: resolve(__dirname, 'archive.db') })],
  server: { port: 4747, strictPort: true },
  define: {
    __BUILD_COMMIT__: JSON.stringify(gitCommit()),
    __BUILD_TIME__: JSON.stringify(new Date().toISOString()),
  },
});

function archive(opts: { dbPath: string }): Plugin {
  const VIRTUAL_ID = 'virtual:archive';
  const RESOLVED_ID = '\0' + VIRTUAL_ID;
  const dbPath = opts.dbPath;

  function read() {
    if (!existsSync(dbPath)) {
      throw new Error(`archive.db not found at ${dbPath}. Run \`npm run db:build\` first.`);
    }
    const db = new Database(dbPath, { readonly: true });
    try {
      const days = db
        .prepare('SELECT date, kind, title FROM days ORDER BY date DESC')
        .all() as Array<{ date: string; kind: 'manual' | 'qa'; title: string | null }>;

      return days.map((d) => {
        const entries = db
          .prepare(
            'SELECT id, position, question, answer FROM entries WHERE day_date = ? ORDER BY position'
          )
          .all(d.date) as Array<{ id: number; position: number; question: string; answer: string }>;

        const entriesWithVocab = entries.map((e) => {
          const vocab = db
            .prepare('SELECT term, def FROM vocab WHERE entry_id = ? ORDER BY id')
            .all(e.id) as Array<{ term: string; def: string }>;
          return { ...e, vocab };
        });

        return { ...d, entries: entriesWithVocab };
      });
    } finally {
      db.close();
    }
  }

  return {
    name: 'vite-plugin-archive',
    resolveId(id) {
      if (id === VIRTUAL_ID) return RESOLVED_ID;
      return null;
    },
    load(id) {
      if (id !== RESOLVED_ID) return null;
      const data = read();
      return `export const days = ${JSON.stringify(data)};\nexport default days;`;
    },
    configureServer(server) {
      server.watcher.add(dbPath);
      server.watcher.on('change', (file) => {
        if (resolve(file) !== dbPath) return;
        const mod = server.moduleGraph.getModuleById(RESOLVED_ID);
        if (mod) server.moduleGraph.invalidateModule(mod);
        server.ws.send({ type: 'full-reload' });
      });
    },
  };
}
