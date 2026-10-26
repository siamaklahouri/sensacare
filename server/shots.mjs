/* ==================== عکسِ صفحه‌های کارتابل ====================
   صفحهٔ اصلی هیچ تصویری از خودِ محصول نداشت: کسی که از گوگل می‌آمد
   نمی‌دید چه می‌خرد. این اسکریپت عکس‌ها را از خودِ کارتابلِ نمایشی
   می‌گیرد، نه از یک ماکتِ دستی — پس هیچ‌وقت با محصول دوصدایی نمی‌شود
   و با هر تغییرِ ظاهر، یک بار اجرا می‌شود و تمام.

     node server/shots.mjs            (سرورِ محلی باید بالا باشد)

   خروجی در public/shots/ می‌نشیند. دادهٔ داخلشان همان دادهٔ نمونهٔ
   کارتابلِ نمایشی است: چیزی از هیچ کاربرِ واقعی در این عکس‌ها نیست. */
import { mkdirSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { launch } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const DEMO = BASE + '/demo/';
const OUT = resolve(dirname(fileURLToPath(import.meta.url)), '..', 'public', 'shots');
mkdirSync(OUT, { recursive: true });

const SHOTS = [
  { view: 'checklist', file: 'checklist', label: 'چک‌لیست ماهانه' },
  { view: 'daily',     file: 'daily',     label: 'برنامهٔ روزانه' },
  { view: 'dashboard', file: 'dashboard', label: 'داشبورد' }
];

const b = await launch();
/* پهن‌تر از ۱۳۶۰: در آن پهنا ستونِ «وظیفه» بریده می‌شد و عکسی که
   متنش ناقص است، بدتر از نبودنش است. و deviceScaleFactor یک: عکسِ
   دو برابر ۶۵۰ کیلوبایت می‌شد که برای صفحهٔ اصلی زیاد است. */
const ctx = await b.newContext({ viewport: { width: 1680, height: 940 }, deviceScaleFactor: 1 });
const p = await ctx.newPage();
p.on('dialog', d => d.accept());
await p.goto(DEMO, { waitUntil: 'networkidle' });
await p.waitForTimeout(2500);

/* نوارِ «نسخهٔ نمایشی» و هر چیزِ شناور، در عکس جایی ندارد */
await p.addStyleTag({ content: '#demoBar,#tourScrim,.tour-pop{display:none!important}' });

for (const s of SHOTS) {
  const found = await p.evaluate(v => {
    const btn = [...document.querySelectorAll('.navbtn')].find(x => x.dataset.view === v);
    if (!btn) return false;
    btn.click(); window.scrollTo(0, 0); return true;
  }, s.view);
  if (!found) { console.log('  — ' + s.label + ': این بخش نیست، رد شد'); continue; }
  await p.waitForTimeout(1600);
  /* jpeg نه png: عکسِ رابطِ کاربری با کیفیت ۸۲ از چشم یکی است و
     یک‌پنجمِ حجم را می‌گیرد. */
  const path = join(OUT, s.file + '.jpg');
  await p.screenshot({ path, type: 'jpeg', quality: 82,
                       clip: { x: 0, y: 0, width: 1680, height: 880 } });
  console.log('  ✓ ' + s.label + ' → public/shots/' + s.file + '.jpg');
}

await b.close();
