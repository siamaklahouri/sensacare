/* ویرایشِ ردیف روی گوشی: کشویی که همان کنترل‌های جدول را از راه دور
   می‌زند. سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { launch } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const WHO = [
  { slug: 'siamak', page: '/siamak/', api: 'kartabl', pass: 'siamaksiamak', name: 'کارتابلِ فنی' },
  { slug: 'sina', page: '/sina/', api: 'sina', pass: 'sinasinasina', name: 'کارتابلِ مالی' }
];

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
  try { return await r.json(); } catch (e) { return {}; }
}; };
const adm = mk();
await adm('/api/admin.planer/signin',
  { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
for (const w of WHO)
  await adm('/api/admin.planer/planners/' + w.slug + '/password',
    { method: 'POST', body: JSON.stringify({ password: w.pass }) });

const b = await launch();
const errs = [];

for (const w of WHO) {
  console.log('===== ' + w.name + ' =====');
  const ctx = await b.newContext({ viewport: { width: 412, height: 880 }, isMobile: true, hasTouch: true });
  /* حالتِ نصب‌شده را همان‌طور که اندروید می‌گوید وانمود می‌کنیم */
  await ctx.addInitScript(() => {
    const o = window.matchMedia.bind(window);
    window.matchMedia = q => /display-mode:\s*standalone/.test(String(q))
      ? { matches: true, media: String(q), onchange: null, addListener() {}, removeListener() {},
          addEventListener() {}, removeEventListener() {}, dispatchEvent() { return false; } }
      : o(q);
  });
  const p = await ctx.newPage();
  p.on('pageerror', e => errs.push(w.slug + ': ' + String(e).slice(0, 160)));
  p.on('dialog', d => d.accept());
  await p.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await p.evaluate(async a => {
    await fetch('/api/' + a.api + '/login', { method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ password: a.pass, remember: false }) });
  }, { api: w.api, pass: w.pass });
  await p.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await p.waitForTimeout(3000);

  await p.evaluate(() => {
    state.days = [{ day: 1, createdDate: '1405/07/01', main: 'کارِ اول', meet: '',
                    company: 'آفتاب', status: 'انجام نشده', doneDate: '' }];
    const nb = document.querySelector('.navbtn[data-view="daily"]');
    if (nb) nb.click();
    renderDaily();
  });
  await p.waitForTimeout(600);

  /* ---------- دستهٔ ردیف ---------- */
  const handle = await p.evaluate(() => {
    const td = document.querySelector('#dailyBody tr[data-idx="0"] td');
    const cs = getComputedStyle(td, '::after');
    return { cursor: getComputedStyle(td).cursor, mark: cs.content };
  });
  t(handle.cursor === 'pointer' && /✎/.test(handle.mark),
    'شمارهٔ ردیف در حالتِ برنامه دستهٔ ویرایش می‌شود', handle.mark);

  /* ---------- باز شدن و خانه‌ها ---------- */
  const open = await p.evaluate(async () => {
    document.querySelector('#dailyBody tr[data-idx="0"] td').click();
    await new Promise(r => setTimeout(r, 300));
    const sh = document.getElementById('rowSheet');
    const labs = [...sh.querySelectorAll('.rs-f > span')].map(x => x.textContent.trim());
    return { open: !sh.hidden, labs,
             vals: [...sh.querySelectorAll('[data-k]')].map(x => x.getAttribute('data-k')),
             locked: getComputedStyle(document.body).overflow };
  });
  t(open.open, 'زدنِ شماره، کشوی ویرایش را باز می‌کند');
  t(open.vals.indexOf('main') >= 0 && open.vals.indexOf('status') >= 0,
    'همهٔ خانه‌های همان ردیف داخلش هستند', open.vals.join(','));
  t(open.labs.some(x => /وظایف اصلی|وظیفه/.test(x)),
    'و نامِ هر خانه از سرستونِ خودِ جدول می‌آید', open.labs.join(' | '));
  t(open.locked === 'hidden', 'و پشتِ کشو نمی‌لغزد');

  /* ---------- نوشتن: باید در داده بنشیند ---------- */
  const typed = await p.evaluate(async () => {
    const el = document.querySelector('#rowSheet [data-k="main"]');
    el.value = 'کارِ عوض‌شده از کشو';
    el.dispatchEvent(new Event('input', { bubbles: true }));
    await new Promise(r => setTimeout(r, 250));
    return { data: state.days[0].main,
             cell: (document.querySelector('#dailyBody tr[data-idx="0"] [data-field="main"]') || {}).value };
  });
  t(typed.data === 'کارِ عوض‌شده از کشو', 'نوشتن در کشو، در خودِ داده می‌نشیند', typed.data);
  t(typed.cell === 'کارِ عوض‌شده از کشو', 'و خانهٔ جدول هم همان را نشان می‌دهد');

  /* وضعیت: جدول را از نو می‌کشد؛ کشو باید باز هم درست بنویسد */
  const after = await p.evaluate(async () => {
    const sel = document.querySelector('#rowSheet [data-k="status"]');
    sel.value = 'انجام شد';
    sel.dispatchEvent(new Event('change', { bubbles: true }));
    await new Promise(r => setTimeout(r, 450));
    const el = document.querySelector('#rowSheet [data-k="main"]');
    el.value = 'نوشتنِ بعد از رسمِ دوباره';
    el.dispatchEvent(new Event('input', { bubbles: true }));
    await new Promise(r => setTimeout(r, 300));
    return { st: state.days[0].status, done: !!state.days[0].doneDate, main: state.days[0].main };
  });
  t(after.st === 'انجام شد' && after.done,
    'عوض کردنِ وضعیت از کشو، تاریخِ انجام را هم می‌اندازد — یعنی کدِ خودِ جدول اجرا شده');
  t(after.main === 'نوشتنِ بعد از رسمِ دوباره',
    'و بعد از رسمِ دوبارهٔ جدول هم نوشتن گم نمی‌شود', after.main);

  /* ---------- بستن ---------- */
  const closed = await p.evaluate(async () => {
    document.querySelector('#rowSheet .rs-done').click();
    await new Promise(r => setTimeout(r, 250));
    return { h: document.getElementById('rowSheet').hidden,
             free: getComputedStyle(document.body).overflow };
  });
  t(closed.h && closed.free !== 'hidden', 'دکمهٔ «تمام» می‌بنددش');

  await ctx.close();

  /* ---------- در مرورگر ----------
     این بخش قبلاً می‌سنجید که کشو «در مرورگر اصلاً باز نشود»، چون
     ساخته شده بود برای حالتِ نصب‌شده. آن انتظار عوض شد و دلیلش
     اندازه‌گیری بود: جدولِ چک‌لیست روی گوشیِ ۳۹۰ پیکسلی ۵۵۸ پیکسل عرض
     داشت و ستونِ «وظیفه» ۴۲ پیکسل — و همان جدول را کسی که با مرورگرِ
     گوشی باز می‌کرد هم داشت، بی‌آنکه کشویی داشته باشد.

     حالا روی هر صفحهٔ باریک ستون‌های درجهٔ دوم به کشو می‌روند، پس کشو
     هم باید همان‌جا باز شود — وگرنه داده از دسترس خارج می‌شود. چیزی
     که سرِ جایش ماند این است: روی پنجرهٔ پهن، هیچ‌چیز عوض نشده. */
  const narrowWeb = await b.newContext({ viewport: { width: 412, height: 880 }, isMobile: true, hasTouch: true });
  const p2 = await narrowWeb.newPage();
  await p2.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await p2.evaluate(async a => {
    await fetch('/api/' + a.api + '/login', { method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ password: a.pass, remember: false }) });
  }, { api: w.api, pass: w.pass });
  await p2.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await p2.waitForTimeout(2500);
  const inWeb = await p2.evaluate(async () => {
    const nb = document.querySelector('.navbtn[data-view="daily"]');
    if (nb) nb.click();
    await new Promise(r => setTimeout(r, 300));
    const td = document.querySelector('#dailyBody tr[data-idx="0"] td');
    if (td) td.click();
    await new Promise(r => setTimeout(r, 250));
    const sh = document.getElementById('rowSheet');
    return { sheet: !!sh && !sh.hidden, cursor: td ? getComputedStyle(td).cursor : '' };
  });
  t(inWeb.sheet, 'در مرورگرِ گوشی هم کشو باز می‌شود — ستون‌هایی که آن‌جا پنهان‌اند باید جایی باشند');
  await narrowWeb.close();

  /* و پنجرهٔ پهن: همان جدولِ همیشگی، بی‌کشو */
  const wideWeb = await b.newContext({ viewport: { width: 1400, height: 900 } });
  const p3 = await wideWeb.newPage();
  await p3.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await p3.evaluate(async a => {
    await fetch('/api/' + a.api + '/login', { method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ password: a.pass, remember: false }) });
  }, { api: w.api, pass: w.pass });
  await p3.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await p3.waitForTimeout(2500);
  const inWide = await p3.evaluate(async () => {
    const nb = document.querySelector('.navbtn[data-view="daily"]');
    if (nb) nb.click();
    await new Promise(r => setTimeout(r, 300));
    const td = document.querySelector('#dailyBody tr[data-idx="0"] td');
    if (td) td.click();
    await new Promise(r => setTimeout(r, 250));
    const sh = document.getElementById('rowSheet');
    const tbl = document.querySelector('#view-daily table');
    const ths = tbl ? [...tbl.querySelectorAll('thead tr:first-child th')] : [];
    return { sheet: !!sh && !sh.hidden, cursor: td ? getComputedStyle(td).cursor : '',
      hidden: ths.filter(th => getComputedStyle(th).display === 'none').length };
  });
  t(!inWide.sheet, 'روی پنجرهٔ پهن هیچ کشویی باز نمی‌شود — جدول همان جدولِ همیشگی است');
  t(inWide.cursor !== 'pointer', 'و شمارهٔ ردیف هم دسته نمی‌شود', inWide.cursor);
  t(inWide.hidden === 0, 'و هیچ ستونی پنهان نیست', inWide.hidden + ' ستونِ پنهان');
  await wideWeb.close();
}

await b.close();
console.log('\nخطای صفحه: ' + (errs.length ? errs.join(' | ') : 'نداشت'));
t(errs.length === 0, 'هیچ خطای جاوااسکریپتی در صفحه نیفتاد');
console.log('\n' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
