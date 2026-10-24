/* دکمهٔ «پایینِ لیست» بالای برنامهٔ روزانه — و برگشتش از ته.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { launch } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
/* یکی از هر دو قالب: کارتابلِ مدیرِ IT و کارتابلِ مالی */
const WHO = [
  { name: 'مدیر IT', slug: 'siamak', page: '/siamak/', api: 'kartabl', pass: 'siamaksiamak' },
  { name: 'مالی', slug: 'sina', page: '/sina/', api: 'sina', pass: 'sinasinasina' }
];

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
  for (const w of WHO)
    await call('/api/admin.planer/planners/' + w.slug + '/password',
      { method: 'POST', body: JSON.stringify({ password: w.pass }) });
}

const b = await launch();
const errs = [];

for (const w of WHO) {
  console.log('===== ' + w.name + ' =====');
  /* پنجرهٔ کوتاه، تا لیست از صفحه بلندتر شود — وگرنه «پایینِ لیست»
     معنایی ندارد و آزمون هرچه بنویسد پاس می‌شود. */
  const p = await b.newPage({ viewport: { width: 420, height: 700 } });
  p.on('pageerror', e => errs.push(w.slug + ': ' + String(e).slice(0, 160)));
  await p.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await p.evaluate(async (a) => {
    await fetch('/api/' + a.api + '/login', { method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ password: a.pass, remember: false }) });
  }, { api: w.api, pass: w.pass });
  await p.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await p.waitForTimeout(2500);
  await p.evaluate(() => {
    const nb = [...document.querySelectorAll('.navbtn')].find(x => x.dataset.view === 'daily');
    if (nb) nb.click();
  });

  const where = await p.evaluate(() => {
    const v = document.getElementById('view-daily');
    const j = v && v.querySelector('.day-jump');
    const btn = j && j.querySelector('.btn');
    const tbl = v && v.querySelector('.tbl-wrap');
    const ttl = v && v.querySelector('.section-title');
    if (!j || !btn || !tbl) return { miss: true, hasJump: !!j, hasBtn: !!btn };
    return {
      txt: btn.textContent.trim(),
      shown: !!btn.offsetParent,
      /* بالای جدول باشد، نه زیرش */
      aboveTable: j.getBoundingClientRect().bottom <= tbl.getBoundingClientRect().top + 1,
      belowTitle: ttl ? ttl.getBoundingClientRect().bottom <= j.getBoundingClientRect().top + 1 : false,
      /* و داخلِ نوارِ خروجی‌ها نباشد: آن نوار data-feat دارد و اگر
         ادمین دسترسیِ «خروجی» را نداده باشد از صفحه برداشته می‌شود،
         و این دکمه با آن می‌رفت. */
      inFeat: !!btn.closest('[data-feat]'),
      upShown: !!(v.querySelector('.day-jump-up') || {}).offsetParent
    };
  });
  t(!where.miss && where.shown, 'دکمه روی صفحه هست', where.txt || JSON.stringify(where));
  t(where.aboveTable && where.belowTitle, 'بالای جدول و زیرِ عنوانِ بخش نشسته',
    'بالای جدول=' + where.aboveTable + ' زیرِ عنوان=' + where.belowTitle);
  t(where.inFeat === false, 'و بیرونِ نوارِ خروجی‌هاست، پس با بسته‌شدنِ آن دسترسی نمی‌رود');
  t(where.upShown === true, 'و تهِ لیست هم دکمهٔ برگشت هست');

  /* چند ردیف تا لیست از صفحه بلندتر شود */
  for (let i = 0; i < 10; i++) {
    await p.evaluate(() => document.getElementById('addDayRowBtn').click());
    await p.waitForTimeout(110);
  }
  await p.waitForTimeout(600);
  const tall = await p.evaluate(() => ({
    rows: document.getElementById('dailyBody').childElementCount,
    docH: document.documentElement.scrollHeight, winH: innerHeight,
    y: scrollY, x: scrollX
  }));
  t(tall.docH > tall.winH + 100, 'لیست از پنجره بلندتر است، پس پایین‌رفتن معنا دارد',
    tall.rows + ' ردیف، ' + tall.docH + ' در برابر ' + tall.winH);

  await p.evaluate(() => window.scrollTo(0, 0));
  await p.waitForTimeout(200);
  await p.evaluate(() => document.querySelector('.day-jump .btn').click());
  await p.waitForTimeout(1400);
  const down = await p.evaluate(() => {
    const ab = document.querySelector('#view-daily .visit-add-bar').getBoundingClientRect();
    const rows = document.getElementById('dailyBody').children;
    const last = rows.length ? rows[rows.length - 1].getBoundingClientRect() : null;
    return { y: scrollY, x: scrollX, winH: innerHeight,
             abIn: ab.top >= 0 && ab.bottom <= innerHeight + 2,
             lastIn: last ? (last.bottom <= innerHeight + 2) : false };
  });
  t(down.y > 0, 'با یک زدن، صفحه پایین می‌رود', 'scrollY=' + Math.round(down.y));
  t(down.abIn && down.lastIn,
    'و تهِ لیست با دکمهٔ افزودنش داخلِ صفحه دیده می‌شود',
    'نوارِ افزودن=' + down.abIn + ' آخرین ردیف=' + down.lastIn);
  t(Math.round(down.x) === Math.round(tall.x),
    'و جدول پهلو نمی‌لغزد — inline:"nearest" کارش همین است',
    down.x + ' در برابر ' + tall.x);

  await p.evaluate(() => document.querySelector('.day-jump-up').click());
  await p.waitForTimeout(1400);
  const up = await p.evaluate(() => ({ y: scrollY,
    ttlIn: (() => { const r = document.querySelector('#view-daily .section-title').getBoundingClientRect();
                    return r.top >= 0 && r.bottom <= innerHeight; })() }));
  t(Math.round(up.y) === 0 && up.ttlIn, 'و دکمهٔ برگشت، سرِ لیست برمی‌گرداند',
    'scrollY=' + Math.round(up.y) + ' عنوان دیده می‌شود=' + up.ttlIn);

  /* چاپ: این دو دکمه در کاغذ معنایی ندارند */
  const pr = await p.evaluate(async () => {
    const j = document.querySelector('.day-jump');
    /* .day-ex در @media print برداشته می‌شود؛ همان کلاس را داریم. */
    return [...j.classList].includes('day-ex');
  });
  t(pr === true, 'کلاسِ .day-ex را دارد، پس در چاپ هم مثلِ بقیهٔ دکمه‌ها برداشته می‌شود');

  await p.close();
}

t(errs.length === 0, 'و هیچ خطای جاوااسکریپتی در صفحه نیست', errs.join(' | ') || '—');
await b.close();
console.log('\n' + (bad ? 'BAD ' + bad : 'همه خوب') + '  —  ' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
