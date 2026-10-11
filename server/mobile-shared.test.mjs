/* دو چیز که با هم نمی‌خوانند ولی هر دو «چشمی»اند، پس هر دو در مرورگر:
   منوی گوشی، و رنگِ ردیفِ کارِ تمام‌شده در بخش‌های مشترک.

   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const PAGE = '/siamak/';
const API = 'kartabl';
const PASS = 'siamaksiamak';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const BOX = 'rowtone';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

/* ---------- یک بخشِ مشترک با یک کارِ باز و یک کارِ بسته ---------- */
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
  await call('/api/admin.planer/planners/siamak/password',
    { method: 'POST', body: JSON.stringify({ password: PASS }) });
  await call('/api/admin.planer/shared-boxes', {
    method: 'POST', body: JSON.stringify({
      id: BOX, title: 'کارهای مشترکِ آزمون', type: 'tasks',
      members: ['siamak'], mgrs: ['siamak']
    })
  });

  ck = '';
  await call('/api/' + API + '/login', { method: 'POST', body: JSON.stringify({ password: PASS }) });
  /* شناسهٔ ردیف را خودِ صفحه می‌سازد؛ این‌جا هم باید ساخته شود. */
  const r1 = await call('/api/' + API + '/shared/' + BOX + '/row',
    { method: 'POST', body: JSON.stringify({ rid: 'tstopen01', v: { task: 'کارِ باز', stat: 'انجام نشده' } }) });
  const r2 = await call('/api/' + API + '/shared/' + BOX + '/row',
    { method: 'POST', body: JSON.stringify({ rid: 'tstdone01', v: { task: 'کارِ تمام‌شده', stat: 'انجام شد' } }) });
  if (r1.error || r2.error) { console.log('   BAD  ردیف‌های آزمون ساخته نشدند — ' + (r1.error || r2.error)); process.exit(1); }
}

const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const errs = [];

/* ======================= منوی گوشی ======================= */
console.log('===== منوی گوشی =====');
const ph = await b.newPage({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 2 });
ph.on('pageerror', e => errs.push('phone: ' + String(e).slice(0, 160)));
await ph.goto(BASE + PAGE, { waitUntil: 'networkidle' });
await ph.evaluate(async w => {
  await fetch('/api/kartabl/login', { method: 'POST', credentials: 'same-origin',
    headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ password: w, remember: false }) });
}, PASS);
await ph.goto(BASE + PAGE, { waitUntil: 'networkidle' });
await ph.waitForTimeout(3000);

const shut = await ph.evaluate(() => {
  const bar = document.querySelector('.sidebar');
  const tg = bar.querySelector('.nav-toggle');
  const nav = bar.querySelector('.nav-list');
  const r = tg.getBoundingClientRect(), nr = nav.getBoundingClientRect();
  return {
    tgShown: !!tg.offsetParent, tgText: tg.querySelector('.t').textContent.trim(),
    tgIc: tg.querySelector('.ic').textContent.trim(),
    navShown: getComputedStyle(nav).display !== 'none',
    barH: Math.round(bar.getBoundingClientRect().height),
    tgW: Math.round(r.width), navH: Math.round(nr.height),
    btns: nav.querySelectorAll('.navbtn').length,
    pageW: document.documentElement.scrollWidth, winW: innerWidth
  };
});
t(shut.tgShown && !shut.navShown, 'در حالتِ بسته فقط یک دکمه دیده می‌شود، نه نوارِ بریده',
  'دکمه=' + shut.tgShown + ' فهرست=' + shut.navShown);
t(shut.tgText.length > 1 && shut.tgIc.length > 0,
  'و روی دکمه نامِ همان بخشی است که بازست', shut.tgIc + ' ' + shut.tgText);
t(shut.barH < 110, 'و کلِ نوار کمتر از ۱۱۰ پیکسل جا می‌گیرد', shut.barH + 'px');
t(shut.pageW <= shut.winW + 1, 'صفحه از عرضِ گوشی پهن‌تر نمی‌شود',
  shut.pageW + ' در برابر ' + shut.winW);

const open = await ph.evaluate(() => {
  document.querySelector('.nav-toggle').click();
  const nav = document.querySelector('.nav-list');
  const cs = getComputedStyle(nav);
  const bs = [...nav.querySelectorAll('.navbtn')];
  const seen = bs.filter(x => x.getBoundingClientRect().width > 20).length;
  const wide = bs.filter(x => x.getBoundingClientRect().right > innerWidth + 1).length;
  return { disp: cs.display, cols: cs.gridTemplateColumns.split(' ').length,
           total: bs.length, seen, wide,
           expanded: document.querySelector('.nav-toggle').getAttribute('aria-expanded') };
});
t(open.disp === 'grid' && open.cols === 2, 'با یک زدن، فهرست در دو ستون باز می‌شود',
  open.disp + ' / ' + open.cols + ' ستون');
t(open.seen === open.total && open.wide === 0,
  'و هر ' + open.total + ' بخش با هم دیده می‌شوند — نه بریده، نه بیرونِ صفحه',
  open.seen + ' از ' + open.total);
t(open.expanded === 'true', 'و aria-expanded هم درست است');

await ph.evaluate(() => {
  [...document.querySelectorAll('.nav-list .navbtn')]
    .find(x => x.getAttribute('data-view') === 'checklist').click();
});
await ph.waitForTimeout(400);
const pick = await ph.evaluate(() => ({
  closed: !document.querySelector('.sidebar').classList.contains('nav-open'),
  label: document.querySelector('.nav-toggle .t').textContent.trim(),
  view: !!document.querySelector('#view-checklist.active')
}));
t(pick.closed, 'زدنِ یک بخش، فهرست را می‌بندد — دو بار زدن لازم نیست');
t(pick.view && /چک/.test(pick.label), 'و نامِ دکمه همان بخشِ تازه می‌شود', pick.label);
await ph.screenshot({ path: process.env.SHOT_DIR ? process.env.SHOT_DIR + '/phone-shut.png' : '/dev/null' })
  .catch(() => {});

/* ======================= رنگِ ردیفِ تمام‌شده ======================= */
console.log('\n===== ردیفِ کارِ تمام‌شده =====');
const d = await b.newPage({ viewport: { width: 1440, height: 1000 } });
d.on('pageerror', e => errs.push('desk: ' + String(e).slice(0, 160)));
await d.goto(BASE + PAGE, { waitUntil: 'networkidle' });
await d.evaluate(async w => {
  await fetch('/api/kartabl/login', { method: 'POST', credentials: 'same-origin',
    headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ password: w, remember: false }) });
}, PASS);
await d.goto(BASE + PAGE, { waitUntil: 'networkidle' });
await d.waitForTimeout(3500);

t(await d.evaluate(() => !document.querySelector('.nav-toggle').offsetParent),
  'روی صفحهٔ بزرگ دکمهٔ منو اصلاً نمی‌آید — آن‌جا جا هست');

const openBox = await d.evaluate(id => {
  const b2 = document.querySelector('.navbtn[data-view="shared-' + id + '"]');
  if (!b2) return false;
  b2.click();
  return true;
}, BOX);
t(openBox, 'بخشِ مشترک در نوار آمد');
await d.waitForTimeout(1200);

const lum = 'const L=c=>{const m=c.match(/[\\d.]+/g).slice(0,3).map(Number).map(v=>{v/=255;' +
  'return v<=0.03928?v/12.92:Math.pow((v+0.055)/1.055,2.4)});' +
  'return 0.2126*m[0]+0.7152*m[1]+0.0722*m[2]};';

const read = async () => d.evaluate(new Function(lum + `
  const rows = [...document.querySelectorAll('tr.sh-row')];
  const pick = r => {
    const td = r.querySelector('td');
    const cs = getComputedStyle(td);
    const ro = r.querySelector('.ro') || td;
    return { shut: r.classList.contains('sh-shut'),
             bg: cs.backgroundColor, fg: cs.color,
             line: getComputedStyle(ro).textDecorationLine,
             op: cs.opacity, bar: cs.boxShadow,
             txt: r.textContent.replace(/\\s+/g,' ').trim().slice(0,22) };
  };
  const out = rows.map(pick);
  const cr = (a,b2) => { const x=L(a), y=L(b2);
    return Math.round(((Math.max(x,y)+0.05)/(Math.min(x,y)+0.05))*10)/10; };
  out.forEach(o => { o.contrast = cr(o.fg, o.bg); });
  return out;
`));

for (const theme of ['light', 'dark']) {
  await d.evaluate(th => document.documentElement.setAttribute('data-theme', th), theme);
  await d.waitForTimeout(200);
  const rows = await read();
  const done = rows.filter(r => r.shut), live = rows.filter(r => !r.shut);
  t(done.length === 1 && live.length === 1, 'تم ' + theme + ': یک ردیفِ باز و یک ردیفِ بسته',
    rows.map(r => r.txt).join(' | '));
  if (!done.length || !live.length) continue;
  t(done[0].bg !== live[0].bg && done[0].fg !== live[0].fg,
    'تم ' + theme + ': کلِ ردیفِ تمام‌شده رنگِ دیگری دارد — زمینه و متن، هر دو',
    done[0].bg + ' / ' + done[0].fg);
  t(/none/.test(done[0].line),
    'تم ' + theme + ': و خطِ روی نوشته برداشته شده', done[0].line);
  t(Number(done[0].op) === 1,
    'تم ' + theme + ': و کم‌رنگ هم نیست — خوانده می‌شود', done[0].op);
  t(done[0].contrast >= 4.5,
    'تم ' + theme + ': متنش روی زمینهٔ خودش خوانا است', done[0].contrast + ':۱');
  t(/rgb/.test(done[0].bar),
    'تم ' + theme + ': و نوارِ کناری هم دارد', done[0].bar.slice(0, 40));
}

console.log('\n===== خطای صفحه =====');
t(errs.length === 0, 'هیچ خطای جاوااسکریپتی نداد', errs.join(' // ') || '—');

await b.close();
console.log('\n' + (bad ? 'BAD ' + bad : 'همه درست') + '  (' + ok + ' تا درست)');
process.exit(bad ? 1 : 0);
