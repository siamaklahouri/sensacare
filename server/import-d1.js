/* ==================== آوردنِ دادهٔ D1 ====================
   خروجیِ «wrangler d1 export» یک فایلِ SQL است. این ابزار آن را داخلِ
   دیتابیسِ سرور می‌ریزد.

     node server/import-d1.js dump.sql

   ترتیبِ کار عمدی است: اول همه‌چیز در یک فایلِ *تازه* ساخته می‌شود و
   فقط وقتی کامل و سالم درآمد، جایِ دیتابیسِ فعلی می‌نشیند. اگر وسطِ
   کار خطایی بیفتد، فایلِ نیمه‌کاره دور ریخته می‌شود و دیتابیسِ فعلی
   دست‌نخورده سرِ جایش می‌ماند. (اول کنار گذاشتن و بعد وارد کردن،
   یعنی یک خطا سرور را بی‌دیتابیس رها می‌کند.)

   دو نکته که ساده‌اش نمی‌گذارد:
   • دستورها را نمی‌شود سرِ «;» تکه کرد: دادهٔ کارتابل‌ها JSON است و
     داخلش هم «;» هست هم خطِ جدید. پس جداکننده باید بفهمد کِی داخلِ
     رشته است و کِی بیرون.
   • D1 چند جدولِ داخلیِ خودش را هم در خروجی می‌گذارد (_cf_…) که این‌جا
     معنایی ندارند و باید کنار گذاشته شوند. */

import { DatabaseSync } from 'node:sqlite';
import { readFileSync, existsSync, renameSync, unlinkSync, mkdirSync } from 'node:fs';
import { dirname } from 'node:path';

/* دستورها را جدا می‌کند، با حواس به رشته‌ها و توضیح‌ها. */
function statements(sql) {
  const out = [];
  let buf = '', i = 0;
  while (i < sql.length) {
    const c = sql[i];

    if (c === "'") {                       /* رشته: دو آپوستروف یعنی یکی */
      let j = i + 1;
      while (j < sql.length) {
        if (sql[j] === "'") { if (sql[j + 1] === "'") j += 2; else { j++; break; } }
        else j++;
      }
      buf += sql.slice(i, j); i = j; continue;
    }
    if (c === '"' || c === '`') {          /* نامِ جدول یا ستون */
      const q = c; let j = i + 1;
      while (j < sql.length && sql[j] !== q) j++;
      buf += sql.slice(i, j + 1); i = j + 1; continue;
    }
    if (c === '-' && sql[i + 1] === '-') { /* توضیحِ تک‌خطی */
      while (i < sql.length && sql[i] !== '\n') i++;
      continue;
    }
    if (c === '/' && sql[i + 1] === '*') {
      const e = sql.indexOf('*/', i + 2);
      i = e < 0 ? sql.length : e + 2; continue;
    }
    if (c === ';') { const s = buf.trim(); if (s) out.push(s); buf = ''; i++; continue; }

    buf += c; i++;
  }
  const s = buf.trim();
  if (s) out.push(s);
  return out;
}

/* چیزهایی که نباید وارد شوند. */
const SKIP = [
  /^PRAGMA\b/i,
  /^BEGIN\b/i, /^COMMIT\b/i, /^ROLLBACK\b/i,
  /^(CREATE|INSERT\s+INTO|DELETE\s+FROM|DROP)\s+(TABLE\s+)?(IF\s+(NOT\s+)?EXISTS\s+)?["'`]?(_cf_|sqlite_)/i,
];

const file = process.argv[2];
if (!file || !existsSync(file)) {
  console.error('کاربرد: node server/import-d1.js <فایل dump.sql>');
  process.exit(1);
}

let DB_FILE = process.env.DB_FILE;
const envFile = process.env.SLTECH_ENV || '/etc/sltech/env';
if (!DB_FILE && existsSync(envFile)) {
  const m = readFileSync(envFile, 'utf8').match(/^\s*DB_FILE\s*=\s*(.+)$/m);
  if (m) DB_FILE = m[1].trim().replace(/^["']|["']$/g, '');
}
DB_FILE = DB_FILE || '/var/lib/sltech/sltech.db';
mkdirSync(dirname(DB_FILE), { recursive: true });

const NEW = DB_FILE + '.new';
const drop = p => { try { if (existsSync(p)) unlinkSync(p); } catch {} };
const dropNew = () => { drop(NEW); drop(NEW + '-wal'); drop(NEW + '-shm'); };
dropNew();

const sql = readFileSync(file, 'utf8');
const all = statements(sql);
const use = all.filter(s => !SKIP.some(re => re.test(s)));
console.log(`دستورها: ${all.length} — واردشدنی: ${use.length} — ردشده: ${all.length - use.length}`);

/* ---------- ساختِ فایلِ تازه ---------- */
let db = new DatabaseSync(NEW);
db.exec('PRAGMA foreign_keys = OFF');
db.exec('PRAGMA journal_mode = WAL');
db.exec('BEGIN');
let done = 0;
try {
  for (const s of use) { db.exec(s); done++; }
  db.exec('COMMIT');
} catch (e) {
  try { db.exec('ROLLBACK'); } catch {}
  try { db.close(); } catch {}
  dropNew();
  console.error(`\n✗ دستورِ شمارهٔ ${done + 1} خطا داد. چیزی عوض نشد؛ دیتابیسِ فعلی سرِ جایش است.`);
  console.error((use[done] || '').slice(0, 300));
  console.error(e.message);
  process.exit(1);
}

/* ---------- شمارش، پیش از جابه‌جایی ---------- */
const tables = db.prepare(
  "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name").all();
console.log(`\n✓ ${done} دستور اجرا شد. ${tables.length} جدول.\n`);
let total = 0;
const counts = [];
for (const t of tables) {
  const c = db.prepare(`SELECT COUNT(*) c FROM "${t.name}"`).get().c;
  total += c;
  if (c) counts.push([c, t.name]);
}
for (const [c, n] of counts) console.log(`  ${String(c).padStart(7)}  ${n}`);
console.log(`\nمجموعِ ردیف‌ها: ${total}`);

/* دیتابیسِ خالی نشانهٔ خرابیِ خروجی است، نه یک واردکردنِ موفق. */
if (!tables.length || !total) {
  db.close(); dropNew();
  console.error('\n✗ چیزی وارد نشد. دیتابیسِ فعلی دست نخورد.');
  process.exit(1);
}

/* WAL را داخلِ خودِ فایل می‌نشاند تا جابه‌جایی یک فایلِ کامل باشد. */
db.exec('PRAGMA wal_checkpoint(TRUNCATE)');
db.exec('PRAGMA journal_mode = DELETE');
db.close();

/* ---------- جابه‌جایی ---------- */
if (existsSync(DB_FILE)) {
  const bak = `${DB_FILE}.${new Date().toISOString().replace(/[:.]/g, '-')}.bak`;
  renameSync(DB_FILE, bak);
  for (const ext of ['-wal', '-shm'])
    if (existsSync(DB_FILE + ext)) renameSync(DB_FILE + ext, bak + ext);
  console.log(`\nدیتابیسِ قبلی کنار گذاشته شد: ${bak}`);
}
renameSync(NEW, DB_FILE);
drop(NEW + '-wal'); drop(NEW + '-shm');
console.log(`دیتابیسِ تازه: ${DB_FILE}`);
console.log('\nحالا: chown sltech:sltech ' + DB_FILE + ' && systemctl start sltech');
