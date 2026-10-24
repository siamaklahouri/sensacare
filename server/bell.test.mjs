/* زنگوله‌ی خبرها — در پنلِ ادمین و در خودِ کارتابل.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { launch } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const P = { slug: 'siamak', page: '/siamak/', api: 'kartabl', pass: 'siamaksiamak' };

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

{
  let ck = '';
  const call = async (path, opt) => {
    const o = Object.assign({ headers: {} }, opt || {});
    o.headers = Object.assign({ 'Content-Type': 'application/json' }, o.headers, ck ? { cookie: ck } : {});
    const r = await fetch(BASE + path, o);
    for (const c of (r.headers.getSetCookie ? r.headers.getSetCookie() : [])) {
      const kv = c.split(';')[0], k = kv.split('=')[0];
      ck = ck.split('; ').filter(x => x && x.split('=')[0] !== k).concat([kv]).join('; ');
    }
    try { return await r.json(); } catch (e) { return {}; }
  };
  await call('/api/admin.planer/signin',
    { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
  await call('/api/admin.planer/planners/' + P.slug + '/password',
    { method: 'POST', body: JSON.stringify({ password: P.pass }) });
}

const b = await launch();
const errs = [];

/* ======================= پنلِ ادمین ======================= */
console.log('===== پنلِ ادمین =====');
{
  const p = await b.newPage({ viewport: { width: 1280, height: 900 } });
  p.on('pageerror', e => errs.push('admin: ' + String(e).slice(0, 150)));
  await p.goto(BASE + '/login', { waitUntil: 'domcontentloaded' });
  await p.evaluate(async a => {
    await fetch('/api/admin.planer/signin', { method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ user: a.u, password: a.p }) });
    try { localStorage.removeItem('sl-admin-bell-seen'); } catch (e) { }
  }, { u: AUSER, p: APASS });
  await p.goto(BASE + '/login', { waitUntil: 'networkidle' });
  await p.waitForTimeout(2200);

  const first = await p.evaluate(() => {
    const d = document.getElementById('bellDot');
    return { has: !!document.getElementById('bellBtn'), hidden: d.hidden, n: d.textContent.trim() };
  });
  t(first.has, 'زنگوله در نوارِ بالا هست');
  t(!first.hidden && first.n, 'و شمارنده‌اش خبرِ نخوانده دارد', first.n);

  await p.evaluate(() => document.getElementById('bellBtn').click());
  await p.waitForTimeout(400);
  const open = await p.evaluate(() => ({
    shown: !document.getElementById('bellPop').hidden,
    items: document.querySelectorAll('#bellList .bell-item').length,
    seen: document.querySelectorAll('#bellList .bell-item.b-seen').length,
    btn: !!document.getElementById('bellSeenAll'),
    dis: document.getElementById('bellSeenAll').disabled
  }));
  t(open.shown && open.items > 0, 'با زدنش پاپ‌آپ باز می‌شود و خبرها داخلش‌اند',
    open.items + ' خبر');
  t(open.btn && !open.dis, 'و دکمهٔ «همه را دیدم» فعال است');
  t(open.seen === 0, 'هنوز هیچ خبری دیده‌شده نیست');

  await p.evaluate(() => document.getElementById('bellSeenAll').click());
  await p.waitForTimeout(400);
  const after = await p.evaluate(() => {
    const d = document.getElementById('bellDot');
    return { hidden: d.hidden, n: d.textContent.trim(),
             items: document.querySelectorAll('#bellList .bell-item').length,
             seen: document.querySelectorAll('#bellList .bell-item.b-seen').length,
             dis: document.getElementById('bellSeenAll').disabled,
             store: (JSON.parse(localStorage.getItem('sl-admin-bell-seen') || '[]')).length };
  });
  t(after.hidden && !after.n, 'با زدنِ دکمه، شمارنده خاموش می‌شود');
  t(after.items > 0 && after.seen === after.items,
    'ولی خبرها پاک نمی‌شوند — فقط کم‌رنگ می‌شوند', after.seen + ' از ' + after.items);
  t(after.dis, 'و دکمه خودش غیرفعال می‌شود چون چیزی برای دیدن نمانده');
  t(after.store > 0, 'کلیدها ذخیره شدند', String(after.store));

  await p.reload({ waitUntil: 'networkidle' });
  await p.waitForTimeout(2200);
  const back = await p.evaluate(() => {
    const d = document.getElementById('bellDot');
    return { hidden: d.hidden, n: d.textContent.trim() };
  });
  t(back.hidden, 'و بعد از تازه‌کردنِ صفحه هم خاموش می‌ماند — همین بود که گیر می‌کرد',
    back.n || '—');
  await p.close();
}

/* ======================= کارتابل ======================= */
console.log('\n===== کارتابل =====');
{
  const p = await b.newPage({ viewport: { width: 1280, height: 860 } });
  p.on('pageerror', e => errs.push('planner: ' + String(e).slice(0, 150)));
  p.on('dialog', d => d.accept());
  await p.goto(BASE + P.page, { waitUntil: 'domcontentloaded' });
  await p.evaluate(async a => {
    await fetch('/api/' + a.api + '/login', { method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ password: a.pass, remember: false }) });
  }, { api: P.api, pass: P.pass });
  await p.goto(BASE + P.page, { waitUntil: 'networkidle' });
  await p.waitForTimeout(2800);

  /* از صفر: هیچ خبری دیده‌نشده، و یک کارِ عقب‌افتاده می‌سازیم */
  await p.evaluate(() => {
    state.bellSeen = [];
    state.tasks = state.tasks || [];
    state.tasks.push({ category: 'آزمون', task: 'کارِ عقب‌افتادهٔ آزمون',
      owner: '', deadline: '۱۴۰۴/۰۱/۰۱', status: 'انجام نشده', priority: 'بالا', note: '' });
    scheduleSave();
    if (window.BELL) window.BELL.refresh();
  });
  await p.waitForTimeout(600);

  const has = await p.evaluate(() => {
    const btn = document.getElementById('bellBtnK');
    const dot = btn && btn.querySelector('.nd');
    return { btn: !!btn, inBar: !!(btn && btn.closest('.topbar')),
             n: dot ? dot.textContent.trim() : '' };
  });
  t(has.btn && has.inBar, 'زنگوله در نوارِ بالای کارتابل هم هست');
  t(!!has.n, 'و خبرِ نخوانده را می‌شمارد', has.n);

  await p.evaluate(() => document.getElementById('bellBtnK').click());
  await p.waitForTimeout(400);
  const list = await p.evaluate(() => ({
    shown: !document.getElementById('bellPopK').hidden,
    items: [...document.querySelectorAll('#bellListK .bell-i b')].map(x => x.textContent.trim()),
    dis: document.getElementById('bellSeenK').disabled
  }));
  t(list.shown && list.items.length > 0, 'پاپ‌آپ باز می‌شود', list.items.join(' | '));
  t(list.items.some(x => /عقب‌افتاده/.test(x)), 'و کارِ عقب‌افتاده را خبر داده');
  t(!list.dis, 'دکمهٔ «همه را دیدم» فعال است');

  await p.evaluate(() => document.getElementById('bellSeenK').click());
  await p.waitForTimeout(500);
  const marked = await p.evaluate(() => {
    const btn = document.getElementById('bellBtnK');
    return { dot: !!btn.querySelector('.nd'),
             seen: document.querySelectorAll('#bellListK .bell-i.seen').length,
             items: document.querySelectorAll('#bellListK .bell-i').length,
             keys: (state.bellSeen || []).length,
             dis: document.getElementById('bellSeenK').disabled };
  });
  t(!marked.dot, 'با زدنِ دکمه شمارنده خاموش می‌شود');
  t(marked.items > 0 && marked.seen === marked.items, 'و خبرها کم‌رنگ می‌مانند، نه پاک',
    marked.seen + ' از ' + marked.items);
  t(marked.keys > 0 && marked.dis, 'کلیدها داخلِ state نشستند', String(marked.keys));

  /* ماندگاری روی سرور: صفحه از نو */
  await p.waitForTimeout(2500);
  await p.goto(BASE + P.page, { waitUntil: 'networkidle' });
  await p.waitForTimeout(2800);
  const back = await p.evaluate(() => {
    const btn = document.getElementById('bellBtnK');
    return { dot: !!(btn && btn.querySelector('.nd')), keys: (state.bellSeen || []).length };
  });
  t(!back.dot && back.keys > 0,
    'و بعد از باز شدنِ دوبارهٔ صفحه هم خاموش است — «دیده‌شده» روی سرور مانده',
    String(back.keys));

  /* خبرِ تازه باید دوباره بشمارد */
  await p.evaluate(() => {
    state.tasks.push({ category: 'آزمون', task: 'کارِ عقب‌افتادهٔ دوم',
      owner: '', deadline: '۱۴۰۴/۰۱/۰۱', status: 'انجام نشده', priority: 'بالا', note: '' });
    scheduleSave();
    if (window.BELL) window.BELL.refresh();
  });
  await p.waitForTimeout(500);
  const again = await p.evaluate(() => {
    const btn = document.getElementById('bellBtnK');
    const dot = btn.querySelector('.nd');
    return dot ? dot.textContent.trim() : '';
  });
  t(!!again, 'و خبرِ تازه دوباره شمرده می‌شود، نه اینکه برای همیشه ساکت بماند', again || '—');

  /* تمیزکاری */
  await p.evaluate(() => {
    state.tasks = state.tasks.filter(x => !/آزمون/.test(x.category || ''));
    state.bellSeen = [];
    scheduleSave();
  });
  await p.waitForTimeout(1500);
  await p.close();
}

t(errs.length === 0, 'و هیچ خطای جاوااسکریپتی نبود', errs.join(' | ') || '—');
await b.close();
console.log('\n' + (bad ? 'BAD ' + bad : 'همه خوب') + '  —  ' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
