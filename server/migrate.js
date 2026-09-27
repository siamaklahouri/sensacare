/* ==================== ساخت و به‌روزرسانی دیتابیس ====================
   روی کلادفلر این کار با wrangler d1 execute انجام می‌شد. این‌جا
   همان دو فایلِ SQL روی دیتابیسِ SQLite اجرا می‌شوند.

     node server/migrate.js            فقط migrations.sql (امن، تکرارپذیر)
     node server/migrate.js --fresh    اول schema.sql، بعد migrations.sql

   --fresh جدول‌ها را می‌اندازد و از نو می‌سازد؛ فقط برای دیتابیسِ خالی. */

import { DatabaseSync } from 'node:sqlite';
import { readFileSync, mkdirSync, existsSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(HERE, '..');

const envFile = process.env.SLTECH_ENV || '/etc/sltech/env';
let DB_FILE = process.env.DB_FILE;
if (!DB_FILE && existsSync(envFile)) {
  const m = readFileSync(envFile, 'utf8').match(/^\s*DB_FILE\s*=\s*(.+)$/m);
  if (m) DB_FILE = m[1].trim().replace(/^["']|["']$/g, '');
}
DB_FILE = DB_FILE || '/var/lib/sltech/sltech.db';

mkdirSync(dirname(DB_FILE), { recursive: true });
const db = new DatabaseSync(DB_FILE);
db.exec('PRAGMA journal_mode = WAL');

const apply = name => {
  const file = join(ROOT, name);
  if (!existsSync(file)) { console.log(`- ${name}: نیست، رد شد`); return; }
  db.exec(readFileSync(file, 'utf8'));
  console.log(`✓ ${name}`);
};

if (process.argv.includes('--fresh')) {
  console.log('!! schema.sql جدول‌ها را از نو می‌سازد');
  apply('schema.sql');
}
apply('migrations.sql');

const n = db.prepare("SELECT COUNT(*) c FROM sqlite_master WHERE type='table'").get().c;
console.log(`دیتابیس: ${DB_FILE}`);
console.log(`تعداد جدول‌ها: ${n}`);
db.close();
