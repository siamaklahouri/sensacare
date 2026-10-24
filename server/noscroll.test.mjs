/* فهرست نباید بالا و پایین بپرد: نه با عوض شدنِ وضعیت، نه با افزودن،
   نه وقتی پیامِ «انجام شد» می‌آید.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { launch } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const P1 = { slug: 'siamak', page: '/siamak/', api: 'kartabl', pass: 'siamaksiamak' };

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
await adm('/api/admin.planer/planners/' + P1.slug + '/password',
  { method: 'POST', body: JSON.stringify({ password: P1.pass }) });

const b = await launch();
const errs = [];

/* ======================= پنلِ ادمین ======================= */
console.log('===== پنلِ ادمین =====');
{
  const p = await b.newPage({ viewport: { width: 1280, height: 720 } });
  p.on('pageerror', e => errs.push('admin: ' + String(e).slice(0, 170)));
  p.on('dialog', d => d.accept());
  await p.goto(BASE + '/login', { waitUntil: 'domcontentloaded' });
  await p.evaluate(async x => {
    await fetch('/api/admin.planer/signin', { method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ user: x.u, password: x.p }) });
  }, { u: AUSER, p: APASS });
  await p.goto(BASE + '/login', { waitUntil: 'networkidle' });
  await p.waitForTimeout(2400);

  /* کادرِ پیام باید شناور باشد، وگرنه ظاهر شدنش فهرست را هل می‌دهد */
  const msgBox = await p.evaluate(() => {
    const el = document.getElementById('msg');
    return { pos: getComputedStyle(el).position, h: Math.round(el.getBoundingClientRect().height) };
  });
  t(msgBox.pos === 'fixed', 'کادرِ پیام شناور است، نه داخلِ خودِ صفحه', msgBox.pos);

  const seen = () => p.evaluate(() => {
    const cards = [...document.querySelectorAll('#tab-list .pcard')];
    const last = cards[cards.length - 1];
    return { y: Math.round(window.scrollY),
             cardTop: last ? Math.round(last.getBoundingClientRect().top) : null,
             n: cards.length };
  });

  /* تهِ فهرست می‌رویم و وضعیتِ آخرین کارتابل را عوض می‌کنیم */
  await p.evaluate(() => window.scrollTo(0, document.documentElement.scrollHeight));
  await p.waitForTimeout(500);
  const was = await seen();
  t(was.y > 200, 'از بالای صفحه پایین آمده‌ایم', String(was.y));
  const label = await p.evaluate(() => {
    const cards = [...document.querySelectorAll('#tab-list .pcard')];
    const card = cards[cards.length - 1];
    const btn = [...card.querySelectorAll('button')].find(x => /غیرفعال|فعال/.test(x.textContent));
    if (!btn) return '';
    btn.click();
    return btn.textContent.trim();
  });
  await p.waitForTimeout(1900);
  const now = await seen();
  t(!!label, 'دکمهٔ وضعیت زده شد', label);
  t(Math.abs(now.y - was.y) <= 2,
    'با عوض شدنِ وضعیت، صفحه همان‌جا می‌ماند — پیش از این می‌پرید بالای صفحه',
    was.y + ' → ' + now.y);
  t(now.cardTop !== null && Math.abs(now.cardTop - was.cardTop) <= 4,
    'و خودِ کارت هم سرِ جایش می‌ماند', was.cardTop + ' → ' + now.cardTop);
  const shown = await p.evaluate(() => ({
    txt: (document.querySelector('#msg .msg') || {}).textContent || '',
    hasX: !!document.querySelector('#msg .msg-x')
  }));
  t(/فعال/.test(shown.txt), 'و پیامِ نتیجه هم دیده می‌شود', shown.txt.trim().slice(0, 48));
  t(shown.hasX, 'با یک دکمهٔ بستن');
  t(!/✕/.test(shown.txt), 'و نشانهٔ بستن داخلِ متنِ پیام نیست');

  /* دوباره روشنش کن تا دادهٔ آزمون‌های دیگر عوض نشود */
  await p.evaluate(() => {
    const cards = [...document.querySelectorAll('#tab-list .pcard')];
    const card = cards[cards.length - 1];
    const btn = [...card.querySelectorAll('button')].find(x => /فعال/.test(x.textContent));
    if (btn) btn.click();
  });
  await p.waitForTimeout(1600);

  /* فهرستِ بخش‌های مشترک وسطِ تازه‌سازی خالی نمی‌شود */
  await p.evaluate(() => document.querySelector('.tabs button[data-tab="shared"]').click());
  await p.waitForTimeout(1400);
  const mid = await p.evaluate(async () => {
    const box = document.getElementById('shList');
    const before = Math.round(box.getBoundingClientRect().height);
    loadShared();
    await new Promise(r => setTimeout(r, 120));
    return { before, during: Math.round(box.getBoundingClientRect().height),
             busy: box.classList.contains('is-busy'),
             dots: box.textContent.trim() === '…' };
  });
  t(mid.before > 0 && Math.abs(mid.during - mid.before) < 12,
    'وسطِ تازه‌سازی، فهرست خالی نمی‌شود و بلندی‌اش نمی‌پرد',
    mid.before + ' → ' + mid.during);
  t(!mid.dots, 'و جایش «…» نمی‌نشیند');
  await p.close();
}

/* ======================= کارتابل ======================= */
console.log('\n===== کارتابل =====');
{
  const p = await b.newPage({ viewport: { width: 1280, height: 720 } });
  p.on('pageerror', e => errs.push('planner: ' + String(e).slice(0, 170)));
  p.on('dialog', d => d.accept());
  await p.goto(BASE + P1.page, { waitUntil: 'networkidle' });
  await p.evaluate(async a => {
    await fetch('/api/' + a.api + '/login', { method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ password: a.pass, remember: false }) });
  }, { api: P1.api, pass: P1.pass });
  await p.goto(BASE + P1.page, { waitUntil: 'networkidle' });
  await p.waitForTimeout(2800);

  await p.evaluate(() => {
    state.days = [];
    for (let i = 1; i <= 20; i++)
      state.days.push({ createdDate: '۱۴۰۵/۰۷/' + String(i).padStart(2, '۰'),
        main: 'کارِ شمارهٔ ' + i, meet: '', company: '', status: 'در حال انجام', doneDate: '' });
    scheduleSave();
    document.querySelector('.navbtn[data-view="daily"]').click();
    renderDaily();
  });
  await p.waitForTimeout(900);

  const rowTop = () => p.evaluate(() => {
    const r = document.querySelector('#dailyBody tr:nth-child(10)');
    return { y: Math.round(window.scrollY),
             top: r ? Math.round(r.getBoundingClientRect().top) : null };
  });
  await p.evaluate(() => window.scrollTo(0, 500));
  await p.waitForTimeout(400);
  const w1 = await rowTop();
  await p.locator('#dailyBody select[data-field="status"]').nth(9).selectOption('انجام شد');
  await p.waitForTimeout(900);
  const w2 = await rowTop();
  t(w2.top !== null && Math.abs(w2.top - w1.top) <= 4,
    'در برنامهٔ روزانه، ردیف با عوض شدنِ وضعیت سرِ جایش می‌ماند',
    w1.top + ' → ' + w2.top);
  const done = await p.evaluate(() =>
    (document.querySelector('#dailyBody tr:nth-child(10) .daily-done-cell') || {}).textContent || '');
  t(/[۰-۹]/.test(done), 'و تاریخِ انجامش همان لحظه نشست', done.trim());

  await p.evaluate(() => window.scrollTo(0, 500));
  await p.waitForTimeout(300);
  const a1 = await rowTop();
  await p.evaluate(() => {
    const btn = [...document.querySelectorAll('#view-daily button')]
      .find(x => /افزودن|＋/.test(x.textContent));
    if (btn) btn.click();
  });
  await p.waitForTimeout(900);
  const a2 = await rowTop();
  t(a2.top !== null && Math.abs(a2.top - a1.top) <= 4,
    'و با افزودنِ ردیف هم جای فهرست نمی‌پرد', a1.top + ' → ' + a2.top);

  /* تمیزکاری */
  await p.evaluate(() => { state.days = []; scheduleSave(); });
  await p.waitForTimeout(1500);
  await p.close();
}

t(errs.length === 0, 'و هیچ خطای جاوااسکریپتی نبود', errs.join(' | ') || '—');
await b.close();
console.log('\n' + (bad ? 'BAD ' + bad : 'همه خوب') + '  —  ' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
