/* «رمزِ اشتباه هم رد بشه» — تلاشِ ناموفقِ ورود شمرده می‌شود و در
   زنگولهٔ خبر می‌آید؛ هم در پنلِ ادمین، هم در خودِ کارتابل.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const DB = process.env.DB_FILE || '';
const P = { slug: 'sina', page: '/sina/', api: 'sina', pass: 'sinasinasina' };
const WRONG = 'ghalat-ghalat-1234';

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
  let j = {}; try { j = await r.json(); } catch (e) { }
  j.__status = r.status;
  return j;
}; };

const A = '/api/admin.planer';

/* ---------- از نقطهٔ صفر، تا آزمون دوباره‌اجراپذیر بماند ---------- */
let db = null, putSetting = null, rawOf = null;
if (DB) {
  const { DatabaseSync } = await import('node:sqlite');
  db = new DatabaseSync(DB);
  putSetting = (k, v) => db.prepare(
    'INSERT INTO settings(k,v) VALUES(?,?) ON CONFLICT(k) DO UPDATE SET v=excluded.v').run(k, JSON.stringify(v));
  rawOf = k => { const r = db.prepare('SELECT v FROM settings WHERE k=?').get(k); return r ? String(r.v) : ''; };
  db.prepare('DELETE FROM settings WHERE k LIKE ?').run('badpass:%');
  try { db.prepare('DELETE FROM rate_limits').run(); } catch (e) { }
}

const adm = mk();
await adm(A + '/signin', { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
await adm(A + '/planners/' + P.slug + '/password',
  { method: 'POST', body: JSON.stringify({ password: P.pass }) });

const payload = () => adm(A + '/planners');
const rowOf = async () => {
  const r = await payload();
  return (r.items || []).find(x => x.slug === P.slug) || {};
};

console.log('===== شمردنِ رمزِ غلط =====');
const zero = await rowOf();
t(Object.prototype.hasOwnProperty.call(zero, 'badPass'),
  'فهرستِ کارتابل‌ها خانهٔ «تلاشِ ناموفق» را دارد');
t(!zero.badPass || !Number(zero.badPass.n), 'و سرِ شروع خالی است',
  JSON.stringify(zero.badPass || null));

const me = mk();
const t0 = Date.now();
for (let i = 0; i < 3; i++) {
  const r = await me('/api/' + P.api + '/login', { method: 'POST', body: JSON.stringify({ password: WRONG }) });
  if (i === 0) t(r.__status === 401 && !!r.error, 'رمزِ غلط با ۴۰۱ رد می‌شود', String(r.__status));
}
const three = await rowOf();
t(three.badPass && Number(three.badPass.n) === 3,
  'سه بار رمزِ غلط، سه بار شمرده شد — نه یک بار، نه هیچ‌بار',
  JSON.stringify(three.badPass || null));
t(three.badPass && Number(three.badPass.at) >= t0 - 2000 && Number(three.badPass.at) <= Date.now() + 2000,
  'و زمانِ آخرین تلاش همین حالاست',
  three.badPass ? new Date(Number(three.badPass.at)).toISOString() : '—');
t(three.badPass && !!String(three.badPass.ip || '').length,
  'نشانیِ اینترنتیِ تلاش هم هست', (three.badPass || {}).ip);

if (rawOf) {
  const raw = rawOf('badpass:' + P.slug);
  t(raw.length > 0 && !raw.includes(WRONG),
    'خودِ رمزِ غلط هیچ‌جا ذخیره نشده — فقط شمار و زمان و IP', raw);
}

console.log('\n===== ورودِ درست نباید پاکش بکند یا بشمارد =====');
const good = await me('/api/' + P.api + '/login', { method: 'POST', body: JSON.stringify({ password: P.pass }) });
t(!good.error, 'ورود با رمزِ درست انجام شد', good.error);
const after = await rowOf();
t(after.badPass && Number(after.badPass.n) === 3,
  'ورودِ درست به پای تلاشِ ناموفق نوشته نمی‌شود و شمارنده را هم صفر نمی‌کند',
  JSON.stringify(after.badPass || null));

console.log('\n===== /me =====');
const mine = await me('/api/' + P.api + '/me');
t(mine.in === true && mine.badPass && Number(mine.badPass.n) === 3,
  'کسی که وارد شده، از راهِ /me تلاش‌های ناموفق را می‌بیند',
  JSON.stringify(mine.badPass || null));
const out = await mk()('/api/' + P.api + '/me');
t(out.in === false && !('badPass' in out),
  'ولی بیرونِ در هیچ‌چیز نمی‌گوید — این عدد خودش خبر است و به هر کسی که آدرس را دارد داده نمی‌شود',
  JSON.stringify(out));

console.log('\n===== پنلِ ادمین =====');
const wa = await mk()(A + '/signin', { method: 'POST', body: JSON.stringify({ user: AUSER, password: WRONG }) });
t(wa.__status === 401, 'رمزِ غلطِ ادمین هم رد می‌شود', String(wa.__status));
const pay1 = await payload();
t(pay1.adminBadPass && Number(pay1.adminBadPass.n) === 1,
  'و برای خودِ پنلِ ادمین شمرده می‌شود',
  JSON.stringify(pay1.adminBadPass || null));

/* ورودِ مشترک با نام کاربری: این هم باید به پای همان کارتابل برود */
await mk()(A + '/signin', { method: 'POST', body: JSON.stringify({ user: P.slug, password: WRONG }) });
const four = await rowOf();
t(four.badPass && Number(four.badPass.n) === 4,
  'رمزِ غلط از صفحهٔ ورودِ مشترک هم به پای همان کارتابل می‌رود',
  JSON.stringify(four.badPass || null));

/* نامِ کاربریِ ناموجود جایی را شلوغ نمی‌کند */
await mk()(A + '/signin', { method: 'POST', body: JSON.stringify({ user: 'kasi-nist-' + Date.now(), password: WRONG }) });
if (rawOf) {
  const keys = db.prepare('SELECT k FROM settings WHERE k LIKE ?').all('badpass:%').map(r => r.k).sort();
  t(keys.length === 2 && keys.includes('badpass:admin.planer') && keys.includes('badpass:' + P.slug),
    'نامِ کاربریِ ناموجود هیچ ردیفی نمی‌سازد', keys.join(', '));
}

/* ======================= زنگوله‌ها ======================= */
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const errs = [];

console.log('\n===== زنگولهٔ پنلِ ادمین =====');
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
  await p.evaluate(() => document.getElementById('bellBtn').click());
  await p.waitForTimeout(400);
  const items = await p.evaluate(() =>
    [...document.querySelectorAll('#bellList .bell-item')].map(x => x.textContent.replace(/\s+/g, ' ').trim()));
  const row = items.find(x => /ناموفق/.test(x)) || '';
  t(!!row, 'خبرِ «تلاشِ ناموفقِ ورود» در زنگولهٔ ادمین هست', row.slice(0, 160));
  t(/۴/.test(row) && /۱/.test(row), 'و شمارِ هر دو را با رقمِ فارسی می‌گوید');
  t(/ادمین/.test(row), 'پنلِ ادمین هم در همان خبر آمده');
  t(!/ghalat/.test(items.join(' ')), 'و هیچ‌جا خودِ رمزِ غلط را نشان نمی‌دهد');
  await p.close();
}

console.log('\n===== زنگولهٔ کارتابل =====');
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
  await p.evaluate(() => { state.bellSeen = []; scheduleSave(); if (window.BELL) window.BELL.refresh(); });
  await p.waitForTimeout(600);

  const got = await p.evaluate(() => {
    const btn = document.getElementById('bellBtnK');
    const dot = btn && btn.querySelector('.nd');
    return { n: dot ? dot.textContent.trim() : '', bp: JSON.stringify(window.__badPass || null) };
  });
  t(/^\{/.test(got.bp) && /"n":4/.test(got.bp), 'صفحهٔ کارتابل عددِ تلاش‌های ناموفق را دارد', got.bp);
  t(!!got.n, 'و زنگوله خبرِ نخوانده دارد', got.n);

  await p.evaluate(() => document.getElementById('bellBtnK').click());
  await p.waitForTimeout(400);
  const list = await p.evaluate(() =>
    [...document.querySelectorAll('#bellListK .bell-i')].map(x => x.textContent.replace(/\s+/g, ' ').trim()));
  const mine2 = list.find(x => /رمزِ اشتباه/.test(x)) || '';
  t(!!mine2, 'صاحبِ کارتابل خبرِ «رمزِ اشتباه زده شده» را می‌بیند', mine2.slice(0, 170));
  t(/۴ بار/.test(mine2), 'با شمارِ درست و رقمِ فارسی');
  t(mine2.replace(/\s+/g, ' ').length < 70, 'و کوتاه است، نه یک بندِ کامل',
    String(mine2.replace(/\s+/g, ' ').length) + ' نویسه');
  t(!/ghalat/.test(list.join(' ')), 'و خودِ رمزِ غلط این‌جا هم نیست');
  const kind = await p.evaluate(() => {
    const el = [...document.querySelectorAll('#bellListK .bell-i')].find(x => /رمزِ اشتباه/.test(x.textContent));
    return el ? el.className : '';
  });
  t(/k-bad/.test(kind), 'و رنگش هشدار است، نه خبرِ معمولی', kind);

  await p.evaluate(() => document.getElementById('bellSeenK').click());
  await p.waitForTimeout(600);
  const quiet = await p.evaluate(() => {
    const btn = document.getElementById('bellBtnK');
    return { dot: !!btn.querySelector('.nd'),
             seen: (state.bellSeen || []).some(k => /^badpass\|/.test(k)) };
  });
  t(!quiet.dot && quiet.seen, 'با «همه را دیدم» ساکت می‌شود و کلیدش می‌نشیند');

  /* تلاشِ تازه باید دوباره بشمارد — نه اینکه برای همیشه ساکت بماند */
  await p.waitForTimeout(2200);
  await mk()('/api/' + P.api + '/login', { method: 'POST', body: JSON.stringify({ password: WRONG }) });
  await p.goto(BASE + P.page, { waitUntil: 'networkidle' });
  await p.waitForTimeout(2800);
  const again = await p.evaluate(() => {
    const btn = document.getElementById('bellBtnK');
    const dot = btn && btn.querySelector('.nd');
    return { n: dot ? dot.textContent.trim() : '', bp: JSON.stringify(window.__badPass || null) };
  });
  t(/"n":5/.test(again.bp), 'تلاشِ پنجم هم شمرده شد', again.bp);
  t(!!again.n, 'و زنگوله دوباره خبر می‌دهد، چون کلیدِ خبر شمار را در خودش دارد', again.n || '—');

  await p.evaluate(() => { state.bellSeen = []; scheduleSave(); });
  await p.waitForTimeout(1500);
  await p.close();
}

t(errs.length === 0, 'و هیچ خطای جاوااسکریپتی نبود', errs.join(' | ') || '—');
await b.close();
console.log('\n' + (bad ? 'BAD ' + bad : 'همه خوب') + '  —  ' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
