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

/* این جدول‌ها هر دوی سایت‌ها را با هم دارند، پس خالی کردنشان غلط
   است — ولی دست‌نزده رها کردنشان هم غلط بود. */
const BOTH = [
  'settings', 'admin_log', 'job_runs', 'rate_limits',
  'bot_chats', 'bot_logins', 'support_msgs', 'support_relay',
];

/* ---------- ردیف‌های سایتِ دیگر، داخلِ جدول‌های مشترک ----------

   این‌جا اول نوشته بودم «تقسیمشان لازم نیست، هر سایت فقط پیشوندِ
   خودش را می‌خواند». آن حرف دربارهٔ خواندن درست بود و دربارهٔ چیزی
   که مهم است غلط: مسئله این نیست که هر سرویس چه می‌خواند، این است
   که هر دیتابیس چه دارد. و داشت:

     • توکنِ زندهٔ ربات‌های اس‌ال‌تک، داخلِ دیتابیسِ فروشگاه
       (کلیدِ sltechSite). یعنی سرویسِ فروشگاه می‌توانست جای رباتِ
       آن یکی سایت حرف بزند.
     • شمارهٔ تلفن و شناسهٔ گفتگوی مشتری‌های هر سایت، داخلِ دیتابیسِ
       آن یکی.

   همان وصل بودنی که قرار بود قطع شود.

   چهار جدولِ ربات ستونِ platform دارند و مقدارهایش قطعی است، نه
   حدسی: «sltg/slbale/slweb» مالِ اس‌ال‌تک و «telegram/bale» مالِ
   فروشگاه. فقط ردیفی پاک می‌شود که مقدارش در فهرستِ سایتِ دیگر
   باشد؛ مقدارِ ناشناس دست نمی‌خورد — همان قاعدهٔ جدولِ ناشناس. */
const PF_TABLES = ['bot_chats', 'bot_logins', 'support_msgs', 'support_relay'];
const PF = {
  panel: ['sltg', 'slbale', 'slweb'],
  shop:  ['telegram', 'bale'],
};

/* ---------- کلیدهای settings ----------

   این یکی حدس نیست، چون از روی نامِ کلید قضاوت نشده بلکه از روی
   اینکه کدام فایل می‌نویسدش: PassHash و PassGen و LastBackup فقط در
   admin-planer.js و kartabl.js نوشته می‌شوند، و escrow: و sid: و
   vaultEscrow و adminPlaner و sltechSite هم همین‌طور. هیچ‌کدام در
   کدِ فروشگاه نیستند.

   یک دام سرِ راه بود: «login:» در index.js هم هست، ولی آن‌جا کلیدِ
   rate_limits است نه settings. این‌جا فقط settings غربال می‌شود.

   kartablAiKey عمداً می‌ماند: فروشگاه وقتی shopAiKey نداشته باشد از
   همان می‌خواند، و پاک کردنش دستیارِ فروشگاه را بی‌صدا خاموش می‌کرد.

   کلیدی که به هیچ قاعده‌ای نخورد دست نمی‌خورد. */
const PANEL_KEY = k =>
  k !== 'kartablAiKey' && (
    k === 'sltechSite' ||
    /^vaultEscrow/.test(k) ||
    /^(escrow|sid|login):/.test(k) ||
    /^adminPlaner/.test(k) ||
    /^kartabl/.test(k) ||
    /(PassHash|PassGen|LastBackup)$/.test(k));

const SHOP_KEY = k => new Set([
  'shopName', 'shipZones', 'shipExpress', 'freeOver', 'freeOverSet',
  'refOn', 'refFriend', 'refReward', 'shopAiKey',
  'tgToken', 'baleToken', 'tgChat', 'baleChat',
]).has(k);

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

/* ---------- و داخلِ جدول‌های مشترک ---------- */
const dropPf = PF[side === 'shop' ? 'panel' : 'shop'];
const marks = dropPf.map(() => '?').join(',');
const pfRows = [];
for (const t of PF_TABLES) {
  if (!have.has(t)) continue;
  let n = 0;
  try { n = look.prepare(
    `SELECT COUNT(*) AS n FROM "${t}" WHERE platform IN (${marks})`).get(...dropPf).n; }
  catch (e) { continue; }
  if (n) pfRows.push([t, n]);
}

/* کلیدهای سایتِ دیگر */
const isOther = side === 'shop' ? PANEL_KEY : SHOP_KEY;
let keys = [];
try { keys = look.prepare('SELECT k FROM settings').all().map(r => r.k).filter(isOther); }
catch (e) {}

const inside = pfRows.reduce((a, [, n]) => a + n, 0) + keys.length;
if (inside) {
  console.log(`\nو داخلِ جدول‌های مشترک، ردِ ${other}:`);
  for (const [t, n] of pfRows)
    console.log(`   پاک  ${t.padEnd(18)} ${fa(n)} سطر  (platform: ${dropPf.join('، ')})`);
  if (keys.length) {
    console.log(`   پاک  ${'settings'.padEnd(18)} ${fa(keys.length)} کلید:`);
    for (let i = 0; i < keys.length; i += 3)
      console.log('        ' + keys.slice(i, i + 3).map(k => k.padEnd(24)).join(''));
  }
} else {
  console.log('\nدر جدول‌های مشترک، ردی از آن یکی سایت نماند.');
}
console.log(`\n   بقیهٔ جدول‌های مشترک (admin_log، job_runs، rate_limits) دست نمی‌خورند.`);
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
  for (const [t] of pfRows)
    db.prepare(`DELETE FROM "${t}" WHERE platform IN (${marks})`).run(...dropPf);
  for (const k of keys)
    db.prepare('DELETE FROM settings WHERE k = ?').run(k);
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
if (inside)
  console.log(`  و ${fa(pfRows.reduce((a, [, n]) => a + n, 0))} سطر و ${fa(keys.length)} کلیدِ ${other} از جدول‌های مشترک رفت.`);
console.log(`  قدیمی کنار گذاشته شد: ${bak}`);
console.log(`  تازه: ${file}  (${fa(Math.round(statSync(file).size / 1024))} کیلوبایت)\n`);
