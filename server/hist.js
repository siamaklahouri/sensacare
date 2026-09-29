/* ==================== نسخه‌های پیشینِ یک کارتابل ====================
   همان فهرستی که در صفحهٔ «تنظیمات» دیده می‌شود، از خطِ فرمانِ سرور —
   و برگرداندنِ هر کدام.

     node server/hist.js                 کدام کارتابل‌ها هستند
     node server/hist.js siamak          فهرستِ نسخه‌ها
     node server/hist.js siamak 1234     برگرداندنِ نسخهٔ ۱۲۳۴

   چرا از خطِ فرمان: وقتی داده‌ای گم می‌شود، اولین کاری که باید بشود
   نگاه کردن است، نه کلیک کردن. از این‌جا می‌شود فهرست را کامل دید و
   دقیقاً گفت کدام نسخه چه دارد — بی‌آنکه لازم باشد کسی وارد کارتابل
   شود و با باز شدنِ صفحه چیزی روی چیزی بنویسد. */

import { openDB } from './d1.js';
import { readFileSync, existsSync } from 'node:fs';

function loadEnvFile(file) {
  const out = {};
  if (!file || !existsSync(file)) return out;
  for (const raw of readFileSync(file, 'utf8').split('\n')) {
    const line = raw.trim();
    if (!line || line.startsWith('#')) continue;
    const i = line.indexOf('=');
    if (i < 0) continue;
    let v = line.slice(i + 1).trim();
    if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'")))
      v = v.slice(1, -1);
    out[line.slice(0, i).trim()] = v;
  }
  return out;
}

const cfg = { ...loadEnvFile(process.env.SLTECH_ENV || '/etc/sltech/env'), ...process.env };
const DB  = openDB(cfg.DB_FILE || '/var/lib/sltech/sltech.db');
const env = { ...cfg, DB };

const K = await import('../src/kartabl.js');

const fa = n => String(n).replace(/[0-9]/g, d => '۰۱۲۳۴۵۶۷۸۹'[d]);
const when = ms => {
  try {
    return new Intl.DateTimeFormat('fa-IR',
      { dateStyle: 'short', timeStyle: 'short', timeZone: 'Asia/Tehran' }).format(new Date(ms));
  } catch { return String(ms); }
};

const slug = process.argv[2];
const id   = process.argv[3];

const panels = await K.allPanels(env);

if (!slug) {
  console.log('کارتابل‌ها:\n');
  for (const p of panels) {
    const cur = await K.loadKartabl(env, p).catch(() => null);
    const n = cur && cur.state ? (cur.state.days || []).length : 0;
    console.log(`  ${String(p.slug).padEnd(12)} ${String(p.name || '').padEnd(16)}` +
                ` rev ${String(cur ? cur.rev : '—').padEnd(6)} ${fa(n)} سطرِ برنامهٔ روزانه`);
  }
  console.log('\nفهرستِ نسخه‌ها:  node server/hist.js <slug>');
  DB.close();
  process.exit(0);
}

const panel = panels.find(p => p.slug === slug || p.id === slug || p.user === slug);
if (!panel) {
  console.error(`کارتابلی به نامِ «${slug}» نیست. بدونِ آرگومان بزن تا فهرست را ببینی.`);
  DB.close();
  process.exit(1);
}

/* ---------- برگرداندن ---------- */
if (id) {
  const r = await K.restoreKartablSnapshot(env, panel, Number(id));
  if (!r.ok) { console.error('نشد: ' + r.error); DB.close(); process.exit(1); }
  console.log(`✓ نسخهٔ ${fa(id)} برگشت (${r.which}) — rev تازه: ${fa(r.rev)}`);
  const cur = await K.loadKartabl(env, panel);
  console.log(`   برنامهٔ روزانه حالا ${fa((cur.state.days || []).length)} سطر دارد.`);
  DB.close();
  process.exit(0);
}

/* ---------- فهرست ---------- */
const cur = await K.loadKartabl(env, panel);
console.log(`کارتابلِ «${panel.name}»  —  rev ${fa(cur.rev)}  —  آخرین نوشتن ${when(cur.updated)}`);
if (cur.state) {
  const md = cur.state.monthsData || {};
  const ck = cur.state.currentMonthKey;
  console.log(`   ماهِ جاری: ${ck}   ماه‌ها: ${Object.keys(md).length}`);
  console.log(`   برنامهٔ روزانه: ${fa((cur.state.days || []).length)} سطر` +
              `   بایگانیِ همان ماه: ${fa(((md[ck] || {}).days || []).length)} سطر`);
}
console.log('');

const items = await K.listKartablHistory(env, panel);
if (!items.length) { console.log('هیچ نسخه‌ای ثبت نشده.'); DB.close(); process.exit(0); }

console.log(`${fa(items.length)} نسخه (تازه‌ترین بالا):\n`);
console.log('    شناسه   چه وقت              چه چیزی');
console.log('    ' + '-'.repeat(62));
for (const it of items) {
  const what = it.which === 'db' ? 'دیتابیس' : 'کارها و ماه‌ها';
  const sum = it.sum ? Object.keys(it.sum).map(k => k + ' ' + fa(it.sum[k])).join(' · ') : '—';
  console.log(`    ${String(it.id).padStart(5)}   ${when(it.at).padEnd(18)}  ${what} — ${sum}`);
}
console.log('\nبرگرداندن:  node server/hist.js ' + panel.slug + ' <شناسه>');
DB.close();
