/* «تاریخ انجام» در برنامهٔ روزانه — خودش می‌افتد، خودش پاک می‌شود.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const WHO = [
  { name: 'مدیر IT', slug: 'siamak', page: '/siamak/', api: 'kartabl', pass: 'siamaksiamak' },
  { name: 'مالی',    slug: 'sina',   page: '/sina/',   api: 'sina',    pass: 'sinasinasina' }
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

const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const errs = [];

for (const w of WHO) {
  console.log('===== ' + w.name + ' =====');
  const p = await b.newPage({ viewport: { width: 1400, height: 900 } });
  p.on('pageerror', e => errs.push(w.slug + ': ' + String(e).slice(0, 150)));
  p.on('dialog', d => d.accept());
  await p.goto(BASE + w.page, { waitUntil: 'domcontentloaded' });
  await p.evaluate(async a => {
    await fetch('/api/' + a.api + '/login', { method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ password: a.pass, remember: false }) });
  }, { api: w.api, pass: w.pass });
  await p.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await p.waitForTimeout(2600);
  await p.evaluate(() => {
    const nb = [...document.querySelectorAll('.navbtn')].find(x => x.dataset.view === 'daily');
    if (nb) nb.click();
  });
  await p.waitForTimeout(400);

  /* یک ردیفِ تازه و تمیز، تا آزمون به دادهٔ قبلی بند نباشد */
  await p.evaluate(() => document.getElementById('addDayRowBtn').click());
  await p.waitForTimeout(400);
  /* شمارهٔ همان ردیف در آرایهٔ داده. جدول حالا بر اساس تاریخ مرتب
     می‌شود، پس «آخرین ردیفِ روی صفحه» دیگر لزوماً «آخرین ردیفِ داده»
     نیست — ردیف را با data-idx دنبال می‌کنیم، نه با جایش. */
  const IDX = await p.evaluate(() => state.days.length - 1);

  const head = await p.evaluate(() => {
    const th = [...document.querySelectorAll('#view-daily .daily-plan-table thead tr:first-child th')]
      .map(x => x.textContent.trim());
    const filt = document.querySelectorAll('#view-daily .daily-plan-table thead tr.filter-row th').length;
    return { th, filt };
  });
  t(head.th.some(x => /تاریخ انجام/.test(x)), 'ستونِ «تاریخ انجام» در سرصفحه هست', head.th.join(' | '));
  t(head.th.length === head.filt, 'و ردیفِ پالایه هم همان تعداد خانه دارد',
    head.th.length + ' در برابر ' + head.filt);

  const sel = '#view-daily .daily-plan-table tbody tr[data-idx="' + IDX + '"]';
  const cell = async () => p.evaluate(a => {
    const tr = document.querySelector(a.sel);
    const td = tr ? tr.querySelector('.daily-done-cell') : null;
    return { txt: td ? td.textContent.trim() : null, on: td ? td.classList.contains('on') : false,
             val: (state.days[a.i] || {}).doneDate };
  }, { sel, i: IDX });

  const before = await cell();
  t(before.txt === '—' && !before.on && !before.val,
    'ردیفِ تازه تاریخِ انجام ندارد', JSON.stringify(before));

  const setStat = async v => { await p.selectOption(sel + ' select[data-field="status"]', v);
    await p.waitForTimeout(500); };

  await setStat('در حال انجام');
  const doing = await cell();
  t(doing.txt === '—' && !doing.val, '«در حال انجام» تاریخ نمی‌اندازد', JSON.stringify(doing));

  await setStat('انجام شد');
  const done = await cell();
  const today = await p.evaluate(() => fa(getTodayJalaliStr()));
  t(done.val === today && done.txt === today,
    'با «انجام شد»، تاریخِ امروز خودش می‌افتد', done.txt + ' / امروز: ' + today);
  t(done.on, 'و خانه‌اش سبز می‌شود');
  t(/^[۰-۹]{4}\/[۰-۹]{2}\/[۰-۹]{2}$/.test(done.txt), 'تاریخ شمسی و با رقمِ فارسی است', done.txt);

  /* دستی نوشتنی نیست: خانه ورودی ندارد */
  const typable = await p.evaluate(s => {
    const td = document.querySelector(s).querySelector('.daily-done-cell');
    return !!(td.querySelector('input,select,textarea') || td.getAttribute('contenteditable') === 'true');
  }, sel);
  t(!typable, 'و دستی عوض نمی‌شود — فقط خوانده می‌شود');

  await setStat('انجام نشده');
  const reopened = await cell();
  t(reopened.txt === '—' && !reopened.val && !reopened.on,
    'با برگشتنِ کار به حالتِ باز، تاریخ پاک می‌شود', JSON.stringify(reopened));

  /* ماندگاری: صفحه را از نو باز می‌کنیم */
  await setStat('انجام شد');
  await p.waitForTimeout(1200);
  await p.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await p.waitForTimeout(2600);
  await p.evaluate(() => {
    const nb = [...document.querySelectorAll('.navbtn')].find(x => x.dataset.view === 'daily');
    if (nb) nb.click();
  });
  await p.waitForTimeout(500);
  const kept = await cell();
  t(kept.val === today && kept.txt === today,
    'و بعد از باز شدنِ دوبارهٔ صفحه سرِ جایش است', kept.txt);

  /* خروجیِ اکسل هم باید همین ستون را ببیند */
  await p.evaluate(x => { window.__doneSel = x; }, sel);
  const inExport = await p.evaluate(() => {
    const th = [...document.querySelectorAll('#view-daily .daily-plan-table thead tr:first-child th')];
    const i = th.findIndex(x => /تاریخ انجام/.test(x.textContent));
    const tr = document.querySelector(window.__doneSel);
    return i >= 0 && tr ? tr.children[i].textContent.trim() : '';
  });
  t(inExport === today, 'و در همان ستونی نشسته که خروجیِ اکسل و PDF می‌خوانند', inExport);

  /* تمیزکاری: ردیفِ آزمون برود */
  await p.evaluate(s => document.querySelector(s).querySelector('[data-remove-day]').click(), sel);
  await p.waitForTimeout(600);
  await p.close();
}

t(errs.length === 0, 'و هیچ خطای جاوااسکریپتی در صفحه نیست', errs.join(' | ') || '—');
await b.close();
console.log('\n' + (bad ? 'BAD ' + bad : 'همه خوب') + '  —  ' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
