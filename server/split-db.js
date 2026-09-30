/* ==================== جدا کردنِ دادهٔ دو سایت ====================
   یک دیتابیس داشتیم که هر دو سایت در آن بودند. حالا هر سایت سرویسِ
   خودش را دارد و باید دیتابیسِ خودش را هم داشته باشد — وگرنه فروشگاه
   جدول‌های کارتابل را با خود می‌برد و برعکس، و هر کدام نسخه‌ای از
   دادهٔ آن یکی را نگه می‌دارد که دیگر به‌روز نمی‌شود. چنین نسخه‌ای از
   نبودنش بدتر است: یک روز کسی بازش می‌کند و باورش می‌شود.

     node server/split-db.js <فایل> shop        گزارش می‌دهد
     node server/split-db.js <فایل> shop --yes  انجام می‌دهد

   «shop» یعنی این دیتابیس مالِ sensacare.ir است، پس جدول‌های کارتابل
   خالی می‌شوند. «panel» برعکس.

   سه قاعده که عمدی‌اند:

   • روی کپی کار می‌کند. فایلِ اصلی تا لحظهٔ آخر دست‌نخورده می‌ماند و
     بعد هم با نامِ .bak کنار گذاشته می‌شود، نه پاک.

   • جدولی که در فهرستِ زیر نیست دست نمی‌خورد و در گزارش می‌آید. اگر
     فردا جدولی اضافه شود و کسی یادش برود این‌جا بنویسدش، بدترین
     اتفاق این است که در هر دو بماند — نه اینکه از هر دو برود.

   • بی «--yes» چیزی نمی‌نویسد. */

import { DatabaseSync } from 'node:sqlite';
import { copyFileSync, renameSync, existsSync, statSync, unlinkSync } from 'node:fs';

/* ---------- کدام جدول مالِ کدام سایت ---------- */

const SHOP = [
  'products', 'product_images', 'categories', 'menu', 'pages',
  'articles', 'article_products', 'reviews', 'review_done', 'questions',
  'orders', 'order_items', 'order_extras', 'order_discounts', 'order_source',
  'carts', 'coupons', 'credit_use', 'users', 'otps', 'counters',
  'referrals', 'referral_uses', 'referral_credit',
  'restock_watch', 'reorder_sent', 'pay_nudged', 'feedback', 'visits',
];

const PANEL = [
  'kartabl', 'kartabl_hist', 'planners',
  'shared_boxes', 'shared_rows',
  'orgs', 'org_members', 'org_mgrs',
  'sl_orders', 'sl_coupons',
];

/* این‌ها مالِ هیچ‌کدام نیستند و در هر دو می‌مانند.

   «settings» عمداً تقسیم نمی‌شود. نودوپنج کلید در یک جدول‌اند و
   بعضی‌شان — botHealth، backupLast — مالِ هر دو. تقسیمشان یعنی حدس
   زدن، و حدس زدن سرِ داده همان کاری است که یک بار گران تمام شد. هر
   سایت نسخهٔ کاملِ خودش را می‌گیرد و از آن لحظه راهِ خودش را می‌رود؛
   کلیدی که به کارش نیاید فقط چند بایت جا می‌گیرد.

   جدول‌های ربات (bot_chats و بقیه) ستونِ platform دارند و دو سایت را
   با «tg/bale» و «sltg/slbale» از هم جدا می‌کنند. تقسیمشان ممکن است
   ولی لازم نیست: هر سایت فقط پیشوندِ خودش را می‌خواند. */
const BOTH = [
  'settings', 'admin_log', 'job_runs', 'rate_limits',
  'bot_chats', 'bot_logins', 'support_msgs', 'support_relay',
];

const fa = n => String(n).replace(/[0-9]/g, d => '۰۱۲۳۴۵۶۷۸۹'[d]);

function die(msg) { console.error('\n' + msg + '\n'); process.exit(1); }

/* ---------- ورودی ---------- */
const file = process.argv[2];
const side = process.argv[3];
const go   = process.argv.includes('--yes');

if (!file || !['shop', 'panel'].includes(side))
  die('node server/split-db.js <فایل> shop|panel [--yes]');
if (!existsSync(file)) die('این فایل نیست: ' + file);

const drop = side === 'shop' ? PANEL : SHOP;
const keep = side === 'shop' ? SHOP : PANEL;
const other = side === 'shop' ? 'کارتابل' : 'فروشگاه';

console.log(`دیتابیس : ${file}  (${fa(Math.round(statSync(file).size / 1024))} کیلوبایت)`);
console.log(`مالِ     : ${side === 'shop' ? 'فروشگاه — sensacare.ir' : 'کارتابل — sltech.ir'}`);
console.log(`خالی شود: جدول‌های ${other}\n`);

/* ---------- نگاه، پیش از هر نوشتنی ---------- */
const look = new DatabaseSync(file, { readOnly: true });
const have = new Set(look.prepare(
  "SELECT name FROM sqlite_master WHERE type='table'").all().map(r => r.name));
const count = t => {
  try { return look.prepare(`SELECT COUNT(*) AS n FROM "${t}"`).get().n; }
  catch (e) { return null; }
};

let willGo = 0, willStay = 0;
const lines = [];
for (const t of drop) {
  if (!have.has(t)) { lines.push(['—', t, 'نیست']); continue; }
  const n = count(t);
  willGo += n || 0;
  lines.push([n ? 'پاک' : '·', t, fa(n) + ' سطر']);
}
for (const t of keep) if (have.has(t)) willStay += count(t) || 0;

const known = new Set([...SHOP, ...PANEL, ...BOTH]);
const unknown = [...have].filter(t =>
  !known.has(t) && !t.startsWith('_cf_') && !t.startsWith('sqlite_'));

console.log(`جدول‌هایی که خالی می‌شوند (${fa(drop.length)}):`);
for (const [mark, t, n] of lines) console.log(`   ${mark.padEnd(4)} ${t.padEnd(18)} ${n}`);
console.log(`\n   ${fa(willGo)} سطر می‌رود، ${fa(willStay)} سطرِ خودِ این سایت می‌ماند.`);
console.log(`   ${fa(BOTH.length)} جدولِ مشترک (settings و …) دست نمی‌خورند.`);
if (unknown.length) {
  console.log(`\n   جدول‌هایی که نمی‌شناسم و دست نمی‌زنم: ${unknown.join('، ')}`);
  console.log('   (اگر مالِ یکی از دو سایت‌اند، در split-db.js فهرستشان کن)');
}
look.close();

if (!go) {
  console.log('\nچیزی نوشته نشد. برای انجام دادن: --yes\n');
  process.exit(0);
}

/* ---------- انجام، روی کپی ---------- */
const tmp = file + '.new';
const bak = file + '.' + new Date().toISOString().replace(/[:.]/g, '-') + '.bak';
for (const f of [tmp, tmp + '-wal', tmp + '-shm']) { try { unlinkSync(f); } catch (e) {} }

console.log('\nکپی گرفته می‌شود…');
copyFileSync(file, tmp);

const db = new DatabaseSync(tmp);
db.exec('PRAGMA journal_mode = DELETE');   /* تا فایل یک‌تکه بماند */
let gone = 0;
db.exec('BEGIN');
try {
  for (const t of drop) {
    if (!have.has(t)) continue;
    db.exec(`DELETE FROM "${t}"`);
    gone++;
  }
  db.exec('COMMIT');
} catch (e) {
  try { db.exec('ROLLBACK'); } catch (e2) {}
  db.close();
  try { unlinkSync(tmp); } catch (e3) {}
  die('وسطِ کار خطا داد و چیزی عوض نشد: ' + e.message);
}

/* جدول‌های خودمان باید دست‌نخورده باشند — وگرنه نسخهٔ تازه را
   نمی‌گذاریم جای قدیمی. */
let bad = null;
for (const t of keep) {
  if (!have.has(t)) continue;
  const n = db.prepare(`SELECT COUNT(*) AS n FROM "${t}"`).get().n;
  const was = (() => { const l = new DatabaseSync(file, { readOnly: true });
                       const v = l.prepare(`SELECT COUNT(*) AS n FROM "${t}"`).get().n;
                       l.close(); return v; })();
  if (n !== was) { bad = `${t}: ${was} -> ${n}`; break; }
}
if (bad) { db.close(); try { unlinkSync(tmp); } catch (e) {} die('دادهٔ خودِ این سایت عوض شد! ' + bad); }

const chk = db.prepare('PRAGMA integrity_check').get();
if (!chk || String(Object.values(chk)[0]) !== 'ok') {
  db.close(); try { unlinkSync(tmp); } catch (e) {}
  die('نسخهٔ تازه سالم نیست، دور ریخته شد.');
}
db.exec('VACUUM');
db.close();

renameSync(file, bak);
renameSync(tmp, file);
for (const s of ['-wal', '-shm']) { try { unlinkSync(file + s); } catch (e) {} }

console.log(`\n✓ ${fa(gone)} جدول خالی شد.`);
console.log(`  قدیمی کنار گذاشته شد: ${bak}`);
console.log(`  تازه: ${file}  (${fa(Math.round(statSync(file).size / 1024))} کیلوبایت)\n`);
