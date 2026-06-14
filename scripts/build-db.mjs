import Database from 'better-sqlite3';
import { readFileSync, existsSync, unlinkSync } from 'node:fs';
import { resolve } from 'node:path';

const root = resolve(import.meta.dirname, '..');
const dbPath = resolve(root, 'archive.db');
const seedPath = resolve(root, 'seed.sql');

if (!existsSync(seedPath)) {
  console.error(`seed.sql not found at ${seedPath}`);
  process.exit(1);
}

if (existsSync(dbPath)) unlinkSync(dbPath);

const db = new Database(dbPath);
const sql = readFileSync(seedPath, 'utf8');

try {
  db.exec(sql);
  const dayCount = db.prepare('SELECT COUNT(*) AS n FROM days').get().n;
  const entryCount = db.prepare('SELECT COUNT(*) AS n FROM entries').get().n;
  const vocabCount = db.prepare('SELECT COUNT(*) AS n FROM vocab').get().n;
  const sectionCount = db.prepare('SELECT COUNT(*) AS n FROM sections').get().n;
  console.log(`archive.db built: ${dayCount} days, ${entryCount} entries, ${vocabCount} vocab terms, ${sectionCount} brochure sections.`);
} catch (err) {
  console.error('seed.sql failed:', err.message);
  process.exit(1);
} finally {
  db.close();
}
