/* پنلِ ادمین روی گوشی.

   از یک عکسِ صفحه شروع شد: کشویی خبرها از لبهٔ راست بیرون زده بود و
   اولِ هر سطر بریده شده بود — «ی تمام شده»، «موفق ورود». اندازه‌گیری
   نشان داد در ۴۱۲ پیکسل ۸۱ پیکسل بیرون است و در ۳۶۰ پیکسل ۱۰۱.

   علت: کشویی به دکمهٔ زنگوله می‌چسبید، و زنگوله وسطِ نوار است در حالی
   که پنجره از فاصله‌اش تا هر دو لبه پهن‌تر. پس به هر طرف که می‌چسبید
   از صفحه بیرون می‌زد. زنگولهٔ خودِ کارتابل این را نداشت — همان‌جا
   قاعدهٔ صفحهٔ باریک نوشته شده بود و در پنلِ ادمین نه.

   و موقعِ سنجیدن، یک چیزِ دیگر هم پیدا شد که ربطی به زنگوله نداشت:
   سطرِ گزارشِ پشتیبان در ۳۶۰ پیکسل ۳۷۹ پیکسل عرض می‌گرفت و کلِ صفحه
   را افقی می‌لغزاند، چون nowrapِ عمومیِ شمارنده‌های کنارش را به ارث
   می‌برد در حالی که خودش یک جملهٔ کامل است.

   پس این آزمون دو چیز را نگه می‌دارد:

   یک) هیچ‌چیزِ صفحه از قابِ گوشی بیرون نمی‌زند. اگر زد، نامِ همان
   عنصر چاپ می‌شود — وگرنه «۳۳ پیکسل لغزش» یعنی یک ساعت گشتن.

   دو) کشویی خبرها داخلِ صفحه می‌ماند. و روی دسکتاپ همچنان به زنگوله
   می‌چسبد، نه تمامِ عرض — وگرنه قاعدهٔ صفحهٔ باریک به بیرون نشت کرده. */
import { launch } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const b = await launch();
const errs = [];

async function adminPage(width) {
  const p = await b.newPage({ viewport: { width, height: 820 } });
  p.on('pageerror', e => errs.push(`${width}: ` + String(e).slice(0, 140)));
  await p.goto(BASE + '/login', { waitUntil: 'domcontentloaded' });
  await p.evaluate(async a => {
    await fetch('/api/admin.planer/signin', {
      method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ user: a.u, password: a.p })
    });
    try { localStorage.removeItem('sl-admin-bell-seen'); } catch (e) { }
  }, { u: AUSER, p: APASS });
  await p.goto(BASE + '/login', { waitUntil: 'networkidle' });
  await p.waitForTimeout(1900);
  return p;
}

/* پهن‌ترین چیزی که از قاب بیرون زده، با نامش. */
const widest = `(() => {
  const vw = innerWidth, out = [];
  document.querySelectorAll('body *').forEach(el => {
    const r = el.getBoundingClientRect();
    if (!r.width || !r.height) return;
    const over = Math.max(r.right - vw, -r.left);
    if (over > 1) out.push({ name: el.tagName.toLowerCase() + (el.id ? '#' + el.id : ''), over: Math.round(over) });
  });
  out.sort((a, b) => b.over - a.over);
  return { slip: Math.round(document.documentElement.scrollWidth - vw), worst: out[0] || null };
})()`;

console.log('— صفحه از قاب بیرون نمی‌زند —');
for (const w of [360, 412]) {
  const p = await adminPage(w);
  const r = await p.evaluate(widest);
  t(r.slip <= 1 && !r.worst, `در ${w} پیکسل هیچ لغزشِ افقی نیست`,
    r.worst ? `${r.worst.name} — ${r.worst.over} پیکسل بیرون` : 'پاک');
  await p.close();
}

console.log('— کشویی خبرها —');
for (const w of [360, 412]) {
  const p = await adminPage(w);
  await p.evaluate(() => document.getElementById('bellBtn').click());
  await p.waitForTimeout(400);
  const r = await p.evaluate(() => {
    const el = document.getElementById('bellPop');
    const b = el.getBoundingClientRect();
    return { hidden: el.hidden, left: Math.round(b.left), right: Math.round(b.right),
             vw: innerWidth, slip: Math.round(document.documentElement.scrollWidth - innerWidth) };
  });
  t(!r.hidden, `در ${w} پیکسل کشویی باز می‌شود`);
  t(r.left >= 4 && r.right <= r.vw - 4,
    `و از دو لبهٔ صفحه بیرون نمی‌زند`, `${r.left} تا ${r.right} از ${r.vw}`);
  t(r.slip <= 1, 'و باز بودنش صفحه را نمی‌لغزاند', String(r.slip));
  await p.close();
}

console.log('— دسکتاپ دست‌نخورده —');
{
  const p = await adminPage(1280);
  await p.evaluate(() => document.getElementById('bellBtn').click());
  await p.waitForTimeout(400);
  const r = await p.evaluate(() => {
    const b = document.getElementById('bellPop').getBoundingClientRect();
    const k = document.querySelector('.bell-wrap').getBoundingClientRect();
    return { w: Math.round(b.width), vw: innerWidth,
             nearBell: Math.round(Math.min(Math.abs(b.left - k.left), Math.abs(b.right - k.right))) };
  });
  t(r.w < r.vw * .55, 'روی دسکتاپ کشویی تمامِ عرض نمی‌شود', `${r.w} از ${r.vw}`);
  t(r.nearBell <= 2, 'و همچنان به زنگوله چسبیده است', `${r.nearBell} پیکسل`);
  await p.close();
}

t(errs.length === 0, 'هیچ خطای صفحه‌ای نبود', errs.join(' | ') || 'پاک');
await b.close();
console.log((bad ? 'BAD ' : '') + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
