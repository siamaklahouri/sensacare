/* یک‌دستیِ بخش‌ها: وقتی بینِ بخش‌ها جابه‌جا می‌شوی، هیچ‌چیز نباید
   «بزرگ‌تر» یا «کوچک‌تر» به نظر برسد — عنوان، زیرنویس، کارت‌ها و
   جدول‌ها در همهٔ بخش‌ها یک اندازه‌اند.

   این یک بار خراب شده بود: کارت‌های بخش‌های تازه سرشان (آیکن و
   برچسب) زیرِ هم می‌افتاد، چون تعریفِ .stat-head فقط در کارتابلِ
   مالی بود. همان کارت ۴۵ پیکسل بلندتر از بقیه می‌شد.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { launch, calm } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const WHO = [
  { page: '/siamak/', api: 'kartabl', pass: 'siamaksiamak', name: 'کارتابلِ فنی' },
  { page: '/sina/', api: 'sina', pass: 'sinasinasina', name: 'کارتابلِ مالی' }
];

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

/* همهٔ مقدارها یکی‌اند؟ اگر نه، بگو کدام بخش از صف بیرون زده. */
function same(rows, key) {
  const seen = {};
  rows.forEach(r => {
    if (r[key] == null) return;
    (seen[r[key]] = seen[r[key]] || []).push(r.v);
  });
  const vals = Object.keys(seen);
  if (vals.length <= 1) return { ok: true, note: vals[0] == null ? 'جایی ندارد' : vals[0] };
  /* پُرتکرارترین مقدار «درست» است و بقیه بیرون‌زده */
  vals.sort((a, b) => seen[b].length - seen[a].length);
  const odd = vals.slice(1).map(v => seen[v].join('،') + ' = ' + v).join('  |  ');
  return { ok: false, note: 'بیشترشان ' + vals[0] + ' — ولی ' + odd };
}

const b = await launch();

for (const w of WHO) {
  console.log('===== ' + w.name + ' =====');
  const p = await b.newPage({ viewport: { width: 1500, height: 950 } });
  const errs = [];
  p.on('pageerror', e => errs.push(e.message));

  await p.goto(BASE + w.page, { waitUntil: 'domcontentloaded' });
  await p.evaluate(async (a) => {
    await fetch('/api/' + a.api + '/login', { method: 'POST', credentials: 'same-origin',
      headers: { 'content-type': 'application/json' }, body: JSON.stringify({ password: a.pass }) });
  }, w);
  await p.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await calm(p);

  const views = await p.evaluate(() => [].slice.call(document.querySelectorAll('.nav-list .navbtn'))
    .filter(x => x.offsetParent !== null).map(x => x.getAttribute('data-view')).filter(Boolean));
  t(views.length > 5, 'بخش‌های باز پیدا شدند', fa(views.length) + ' بخش');

  const rows = [];
  for (const v of views) {
    await p.evaluate(x => {
      const el = document.querySelector('.nav-list .navbtn[data-view="' + x + '"]');
      if (el) el.click();
    }, v);
    await p.waitForTimeout(220);
    rows.push(await p.evaluate((x) => {
      const sec = document.getElementById('view-' + x);
      if (!sec) return { v: x };
      const px = (el, prop) => el ? Math.round(parseFloat(getComputedStyle(el)[prop])) : null;
      const r = sec.getBoundingClientRect();
      const card = sec.querySelector('.cards .stat');
      return {
        v: x,
        width: Math.round(r.width),
        left: Math.round(r.left),
        title: px(sec.querySelector('.section-title'), 'fontSize'),
        sub: px(sec.querySelector('.section-sub'), 'fontSize'),
        cardH: card ? Math.round(card.getBoundingClientRect().height) : null,
        th: px(sec.querySelector('table th'), 'fontSize'),
        td: px(sec.querySelector('table tbody td'), 'fontSize')
      };
    }, v));
  }

  [['width', 'پهنای همهٔ بخش‌ها یکی است'],
   ['left', 'و همه از یک جا شروع می‌شوند'],
   ['title', 'قلمِ عنوانِ بخش‌ها یک اندازه است'],
   ['sub', 'قلمِ زیرنویسِ بخش‌ها هم'],
   ['cardH', 'کارت‌های خلاصه در همهٔ بخش‌ها یک قد دارند'],
   ['th', 'سرستونِ جدول‌ها یک اندازه است'],
   ['td', 'خانه‌های جدول‌ها هم']
  ].forEach(([k, m]) => { const r = same(rows, k); t(r.ok, m, r.note); });

  t(errs.length === 0, 'هیچ خطای جاوااسکریپتی نداد', errs.join(' | ') || '—');
  await p.close();
}

function fa(n) {
  return String(n).replace(/\d/g, d => '۰۱۲۳۴۵۶۷۸۹'[+d]);
}

await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
