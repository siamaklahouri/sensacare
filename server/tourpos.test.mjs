/* گشتِ اولِ کار باید کنارِ همان چیزی بنشیند که نشان می‌دهد.

   هر قدمِ گشت یک حلقهٔ برجسته دور یک دکمه می‌کشد و پنجره‌اش را
   کنارش می‌گذارد. ولی پنجره آن‌طرفِ صفحه می‌افتاد: دکمهٔ هدف روی
   ۱۲۹۹ و پنجره روی ۲۱۵ — هفتصد و پنجاه پیکسل دورتر از چیزی که
   دربارهٔ آن حرف می‌زد.

   علتش یک اشتباهِ ساده در جهت بود: در صفحهٔ راست‌به‌چپ،
   inset-inline-end یعنی «چپ»، و کد فاصله را از لبهٔ راست حساب
   می‌کرد و به آن می‌داد. نتیجه آینه‌وار بود.

   این آزمون با عدد می‌سنجد، نه با چشم: فاصلهٔ پنجره تا هدف. */
import { launch } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

async function cookiesFor(api, pass) {
  const r = await fetch(BASE + '/api/' + api + '/login', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST }, body: JSON.stringify({ password: pass }) });
  return (r.headers.getSetCookie ? r.headers.getSetCookie() : []).map(c => {
    const kv = c.split(';')[0];
    return { name: kv.split('=')[0], value: kv.slice(kv.indexOf('=') + 1), domain: HOST, path: '/' };
  });
}

const b = await launch();
for (const [label, api, pass, path] of [
  ['کارتابلِ فنی', 'kartabl', process.env.VS_IT_PASS || 'siamaksiamak', '/siamak/'],
  ['کارتابلِ مالی', 'sina', process.env.VS_FIN_PASS || 'sinasinasina', '/sina/']
]) {
  console.log('===== ' + label + ' =====');
  const ctx = await b.newContext({ viewport: { width: 1500, height: 950 } });
  await ctx.addCookies(await cookiesFor(api, pass));
  const p = await ctx.newPage();
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
  await p.goto('http://' + HOST + ':' + PORT + path, { waitUntil: 'load' });
  await p.waitForTimeout(3800);

  const steps = await p.evaluate(() => { if (!window.TOUR) return 0; TOUR.start(true); return 1; });
  t(steps === 1, 'گشت باز شد');
  if (!steps) { await ctx.close(); continue; }

  /* همهٔ قدم‌ها، نه فقط اولی: هر قدم هدفِ خودش را دارد. */
  const seen = [];
  for (let i = 0; i < 8; i++) {
    await p.waitForTimeout(350);
    const m = await p.evaluate(() => {
      const pop = document.querySelector('.tourbox:not([hidden]) .tr-pop');
      const on = document.querySelector('.tour-on');
      if (!pop || !on) return null;
      const a = pop.getBoundingClientRect(), c = on.getBoundingClientRect();
      const gapLeft = c.left - a.right;      /* پنجره سمتِ چپِ هدف */
      const gapRight = a.left - c.right;     /* یا سمتِ راستش */
      const inside = a.left >= 0 && a.right <= innerWidth && a.top >= 0 && a.bottom <= innerHeight;
      return { n: (document.querySelector('.tr-n') || {}).textContent || '',
               gap: Math.round(Math.max(gapLeft, gapRight)),
               vgap: Math.round(Math.abs(a.top - c.top)), inside,
               last: (document.querySelector('.tr-next') || {}).textContent === 'تمام' };
    });
    if (!m) break;
    seen.push(m);
    if (m.last) break;
    await p.evaluate(() => { const n = document.querySelector('.tr-next'); if (n) n.click(); });
  }

  t(seen.length >= 3, 'چند قدم دارد', seen.length + ' قدم');
  const far = seen.filter(s => s.gap > 40 || s.gap < 0);
  t(far.length === 0, 'پنجره در هر قدم کنارِ هدفش است',
    far.length ? far.map(s => s.n + ':' + s.gap + 'px').join('، ')
               : 'بیشترین فاصله ' + Math.max(...seen.map(s => s.gap)) + 'px');
  t(seen.every(s => s.vgap <= 60), 'و هم‌ترازِ آن است',
    'بیشترین اختلافِ عمودی ' + Math.max(...seen.map(s => s.vgap)) + 'px');
  t(seen.every(s => s.inside), 'و هیچ قدمی از قاب بیرون نمی‌زند');

  await p.evaluate(() => { if (window.TOUR) TOUR.done(); });
  t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
  await ctx.close();
}

await b.close();
console.log(ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
