/* مقاله‌های دامنهٔ پنل: از پنل نوشته می‌شوند، روی sltech.ir منتشر
   می‌شوند، و متنِ ساده‌شان بی‌هیچ تگی به HTML تبدیل می‌شود. */
import { launch } from './pw.mjs';
import { ADMIN, HOME } from './where.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const PORT = new URL(BASE).port;
const P = p => `http://sltech.ir:${PORT}${p}`;

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const mk = () => { let ck = ''; return async (path, opt) => {
  const o = Object.assign({ headers: {} }, opt || {});
  o.headers = Object.assign({ 'Content-Type': 'application/json' }, o.headers, ck ? { cookie: ck } : {});
  const r = await fetch(BASE + path, o);
  for (const c of (r.headers.getSetCookie ? r.headers.getSetCookie() : [])) {
    const kv = c.split(';')[0], k = kv.split('=')[0];
    ck = ck.split('; ').filter(x => x && x.split('=')[0] !== k).concat([kv]).join('; ');
  }
  let d = null; try { d = await r.json(); } catch (e) {}
  return { status: r.status, data: d || {} };
}; };

const adm = mk();
await adm('/api/admin.planer/signin', { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });

console.log('— نوشتن —');
{
  const r = await adm('/api/admin.planer/articles', { method: 'POST', body: JSON.stringify({
    slug: 'azmoon-maghale', title: 'نوشتهٔ آزمون',
    excerpt: 'یک جملهٔ کوتاه برای فهرست.',
    body: '## تیترِ دو\nپاراگرافِ اول.\n\n- گزینهٔ یک\n- گزینهٔ دو\n\n<script>bad()</script>',
    published: 1 }) });
  t(r.status === 200 && r.data.ok, 'مقاله ذخیره شد', r.data.url || r.data.error);

  const bad1 = await adm('/api/admin.planer/articles', { method: 'POST', body: JSON.stringify({
    slug: 'BAD SLUG', title: 'x' }) });
  t(bad1.status !== 200, 'نشانیِ نادرست رد می‌شود', bad1.data.error || '-');

  const bad2 = await adm('/api/admin.planer/articles', { method: 'POST', body: JSON.stringify({
    slug: 'maghale', title: 'x' }) });
  t(bad2.status !== 200, 'نشانیِ «maghale» که مالِ فهرست است رد می‌شود', bad2.data.error || '-');
}

console.log('— دیده شدن —');
const b = await launch();
{
  const p = await b.newPage({ viewport: { width: 1100, height: 900 } });
  const errs = []; p.on('pageerror', e => errs.push(String(e).slice(0, 90)));

  await p.goto(P('/maghale/'), { waitUntil: 'networkidle' });
  const list = await p.evaluate(() => ({
    cards: document.querySelectorAll('.card').length,
    has: /نوشتهٔ آزمون/.test(document.body.textContent) }));
  t(list.cards > 0 && list.has, 'در فهرست دیده می‌شود', list.cards + ' نوشته');

  await p.goto(P('/maghale/azmoon-maghale/'), { waitUntil: 'networkidle' });
  const art = await p.evaluate(() => ({
    h1: (document.querySelector('h1') || {}).textContent || '',
    h2: document.querySelectorAll('h2').length,
    li: document.querySelectorAll('li').length,
    ld: document.querySelectorAll('script[type="application/ld+json"]').length,
    /* متنِ مقاله «<script>bad()</script>» داشت. باید به‌شکلِ متن
       دیده شود، نه به‌شکلِ تگ: یعنی در innerHTML باید escape شده
       باشد و هیچ <script> تازه‌ای در صفحه نباشد. */
    asText: /&lt;script&gt;/.test(document.body.innerHTML),
    scripts: document.querySelectorAll('script:not([type])').length }));
  t(art.h1 === 'نوشتهٔ آزمون', 'عنوان درست است', art.h1);
  t(art.h2 >= 1 && art.li === 2, '«## » تیتر شد و «- » فهرست', 'h2=' + art.h2 + ' li=' + art.li);
  t(art.ld >= 1, 'دادهٔ ساختاریافته دارد');
  t(art.asText && art.scripts === 0,
    'تگی که در متنِ مقاله بود، متن ماند و اجرا نشد',
    'متن=' + art.asText + ' اسکریپت=' + art.scripts);
  t(errs.length === 0, 'بی‌خطا', errs[0] || 'بی‌خطا');

  await p.goto(P('/maghale/nist-inja/'), { waitUntil: 'domcontentloaded' });
  t(/پیدا نشد/.test(await p.evaluate(() => document.body.textContent)),
    'نشانیِ ناموجود صفحهٔ ۴۰۴ِ خودِ پنل را می‌دهد');
  await p.close();
}

console.log('— نقشهٔ سایت —');
{
  const r = await fetch(BASE + '/sitemap.xml', { headers: { Host: 'sltech.ir' } });
  const xml = await r.text();
  t(xml.includes('/maghale/'), 'فهرستِ مقاله‌ها در نقشهٔ سایت هست');
  t(xml.includes('/maghale/azmoon-maghale/'), 'و خودِ مقاله هم');
}

console.log('— پاک کردن —');
{
  const r = await adm('/api/admin.planer/articles/azmoon-maghale', { method: 'DELETE' });
  t(r.status === 200, 'پاک شد');
  const g = await fetch(BASE + '/maghale/azmoon-maghale/', { headers: { Host: 'sltech.ir' } });
  t(g.status === 404, 'و دیگر باز نمی‌شود', 'status=' + g.status);
}

await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
