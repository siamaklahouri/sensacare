/* بودجهٔ حجمِ صفحه، و نشانهٔ «پایین‌تر هم چیزی هست».

   یک فایلِ ۱۶۰ کیلوبایتی سال‌ها در هر صفحه دانلود می‌شد و هیچ آزمونی
   نمی‌دیدش: نشانهٔ ۵۱۲ پیکسلیِ برنامه، هم به‌عنوان favicon اعلام شده
   بود و هم به‌عنوان نشانِ دیدنیِ صفحه‌ها کشیده می‌شد — جایی که ۳۸ تا
   ۶۸ پیکسل دیده می‌شود. در صفحهٔ اصلی ۴۲٪ کلِ حجم بود.

   پس حجم هم سنجه می‌خواهد. عددها سخت‌گیر نیستند، فقط جلوی برگشتنِ
   همان اشتباه را می‌گیرند: اگر فردا کسی دوباره فایلی از این دست را
   به صفحه ببندد، این‌جا قرمز می‌شود. */
import { launch } from './pw.mjs';
import { readFileSync } from 'node:fs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const b = await launch();

async function cookiesFor(api, body) {
  const r = await fetch(BASE + '/api/' + api + (api === 'admin.planer' ? '/signin' : '/login'),
    { method: 'POST', headers: { 'Content-Type': 'application/json', Host: HOST },
      body: JSON.stringify(body) });
  return (r.headers.getSetCookie ? r.headers.getSetCookie() : []).map(c => {
    const kv = c.split(';')[0];
    return { name: kv.split('=')[0], value: kv.slice(kv.indexOf('=') + 1), domain: HOST, path: '/' };
  });
}

/* یک بار باز کردن، نه دو بار: signIn دو ناوبری می‌کند و هر فایل را
   دوبار می‌شمارد. بارِ اول با همان اندازه گرفتم و «سه مگابایت» درآمد
   که غلط بود. */
async function weigh(label, path, cookies, budgetKB, maxFileKB) {
  const ctx = await b.newContext({ viewport: { width: 1400, height: 900 } });
  if (cookies && cookies.length) await ctx.addCookies(cookies);
  const p = await ctx.newPage();
  const seen = new Map();
  p.on('response', async r => {
    const u = r.url().replace(/^https?:\/\/[^/]+/, '');
    if (seen.has(u)) return;
    let n = 0;
    try { n = Number(r.headers()['content-length'] || 0) ||
              (await r.body().catch(() => Buffer.alloc(0))).length; } catch (e) { }
    seen.set(u, n);
  });
  await p.goto('http://' + HOST + ':' + PORT + path, { waitUntil: 'load' });
  await p.waitForTimeout(3600);
  const rows = [...seen.entries()].sort((a, b2) => b2[1] - a[1]);
  const total = Math.round(rows.reduce((s, [, n]) => s + n, 0) / 1024);
  console.log('── ' + label + ': ' + total + 'KB در ' + rows.length + ' فایل');
  t(total <= budgetKB, label + ': زیرِ بودجهٔ ' + budgetKB + 'KB است', total + 'KB');
  const heavy = rows.filter(([u, n]) => n / 1024 > maxFileKB && !/\/_a\//.test(u));
  t(heavy.length === 0,
    label + ': هیچ فایلی جز بسته‌های ساخته‌شده از ' + maxFileKB + 'KB بزرگ‌تر نیست',
    heavy.length ? heavy.map(([u, n]) => u + ' ' + Math.round(n / 1024) + 'KB').join(' · ') : '—');
  await ctx.close();
  return rows;
}

console.log('===== حجمِ صفحه‌ها =====');
const home = await weigh('صفحهٔ اصلی', '/', null, 330, 60);
await weigh('پنلِ مدیر', '/login',
  await cookiesFor('admin.planer', { user: process.env.VS_ADMIN || 'admin',
                                     password: process.env.VS_ADMIN_PASS || 'adminadminadmin' }),
  520, 70);
await weigh('کارتابلِ فنی', '/siamak/',
  await cookiesFor('kartabl', { password: process.env.VS_IT_PASS || 'siamaksiamak' }),
  1700, 240);

console.log('===== نشانهٔ برنامه =====');
{
  const names = home.map(([u]) => u);
  t(!names.includes('/icon-sl.4.png'),
    'نشانهٔ ۵۱۲ پیکسلی دیگر در صفحهٔ اصلی دانلود نمی‌شود',
    names.filter(x => /icon-sl/.test(x)).join(' · '));
  t(names.includes('/icon-sl-144.1.png'), 'و به‌جایش نسخهٔ کوچک می‌آید');
  /* ولی باید همچنان برای نصبِ برنامه سرو شود */
  const r = await fetch(BASE + '/icon-sl.4.png', { headers: { Host: HOST } });
  t(r.status === 200, 'و خودِ ۵۱۲ هنوز سرو می‌شود — مانیفست به آن نیاز دارد', 'کد ' + r.status);
  const mf = await (await fetch(BASE + '/app.webmanifest', { headers: { Host: HOST } })).json();
  t((mf.icons || []).some(i => i.src === '/icon-sl.4.png'), 'و در مانیفست هست');
  /* و هیچ صفحه‌ای دیگر آن را به‌عنوان favicon اعلام نکند */
  for (const f of ['home.tpl', 'admin.tpl']) {
    const src = readFileSync(new URL('../public/_t/' + f, import.meta.url), 'utf8');
    /* با اسلشِ اول: «favicon-sl.4.png» خودش رشتهٔ «icon-sl.4.png» را
       در خود دارد و الگوی بی‌اسلش، نسخهٔ ۶۴ را هم می‌گرفت. */
    t(!/rel="icon"[^>]*href="\/icon-sl\.4\.png"/.test(src),
      f + ': نشانهٔ ۵۱۲ را به‌عنوان favicon اعلام نمی‌کند');
    t(/rel="icon"[^>]*href="\/favicon-sl\.4\.png"/.test(src),
      f + ': ولی نشانهٔ ۶۴ سرِ جایش است');
  }
}

console.log('===== نشانهٔ «پایین‌تر هم چیزی هست» =====');
{
  const cookies = await cookiesFor('kartabl', { password: process.env.VS_IT_PASS || 'siamaksiamak' });
  for (const [h, want] of [[1100, false], [820, true]]) {
    const ctx = await b.newContext({ viewport: { width: 1400, height: h } });
    await ctx.addCookies(cookies);
    const p = await ctx.newPage();
    await p.goto('http://' + HOST + ':' + PORT + '/siamak/', { waitUntil: 'load' });
    await p.waitForTimeout(3200);
    const st = await p.evaluate(() => {
      const l = document.querySelector('.nav-list');
      return { fade: l.classList.contains('more-bottom'),
               over: l.scrollHeight - l.clientHeight,
               masked: getComputedStyle(l).maskImage !== 'none' };
    });
    t(st.fade === want && st.masked === want,
      'ارتفاع ' + h + ': محوشدگی ' + (want ? 'هست' : 'نیست') + ' — همان‌طور که باید',
      'سرریز ' + st.over + 'px، کلاس ' + st.fade + '، ماسک ' + st.masked);
    await ctx.close();
  }
}

await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
