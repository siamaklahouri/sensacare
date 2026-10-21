/* ردیف‌های قدیمیِ برنامهٔ روزانه که «تاریخِ ایجاد» ندارند باید روزِ اولِ
   ماهِ خودشان را بگیرند — نه امروز، و نه ماهی که جدول رویش باز است.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
/* هر دو قالب: فنی (سیامک) و مالی (سینا) — ایراد در هر دو بود. */
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

const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const errs = [];
const latin = s => String(s).replace(/[۰-۹]/g, d => '۰۱۲۳۴۵۶۷۸۹'.indexOf(d));

for (const w of WHO) {
  console.log('===== ' + w.name + ' =====');
  const p = await b.newPage({ viewport: { width: 1340, height: 920 } });
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

  /* ---------- خودِ مهاجرت ----------
     سه ماه: مهرِ باز، شهریورِ بایگانی، و یک ماهِ بی‌نام که نباید دست
     بخورد. در هر ماه یک ردیفِ پُرِ بی‌تاریخ، یک ردیفِ تاریخ‌دار و یک
     ردیفِ کاملاً خالی. */
  const r1 = await p.evaluate(() => {
    const row = (dd, main, status) => ({ day: 1, createdDate: dd, main: main || '',
      meet: '', company: '', status: status || '', doneDate: '' });
    state.meta = { month: 'مهر', year: '1405' };
    state.currentMonthKey = '1405|مهر';
    state.monthsData = {
      '1405|مهر': { tasks: [], days: [
        row('', 'کارِ بی‌تاریخِ مهر', 'در حال انجام'),
        row('1405/07/14', 'کارِ تاریخ‌دارِ مهر', 'انجام شد'),
        row('', '', '')
      ] },
      '1404|شهریور': { tasks: [], days: [
        row('', 'کارِ بی‌تاریخِ شهریور', 'انجام نشده'),
        row('', '', '')
      ] },
      '?|?': { tasks: [], days: [ row('', 'کارِ ماهِ بی‌نام', 'در حال انجام') ] }
    };
    state.days = state.monthsData['1405|مهر'].days;
    delete state.datesFilled;
    const n = backfillCreatedDates();
    const d = k => state.monthsData[k].days.map(x => x.createdDate);
    return { n, mehr: d('1405|مهر'), sh: d('1404|شهریور'), unnamed: d('?|?'),
             again: backfillCreatedDates(), flag: Object.keys(state.datesFilled || {}).sort() };
  });
  t(r1.n === 2, 'دو ردیفِ قدیمیِ پُر مُهر خورد — نه بیشتر', 'n=' + r1.n);
  t(r1.mehr[0] === '1405/07/01', 'ردیفِ بی‌تاریخِ مهر، روزِ اولِ مهر شد', r1.mehr[0]);
  t(r1.mehr[1] === '1405/07/14', 'ردیفی که از قبل تاریخ داشت دست نخورد', r1.mehr[1]);
  t(r1.mehr[2] === '', 'ردیفِ خالی خالی ماند — وگرنه پالایهٔ تاریخ پُر از روزِ اول می‌شد');
  t(r1.sh[0] === '1404/06/01', 'بایگانیِ شهریورِ ۱۴۰۴ هم ماهِ خودش را گرفت، نه ماهِ باز را', r1.sh[0]);
  t(r1.sh[1] === '', 'و ردیفِ خالیِ شهریور خالی ماند');
  t(r1.unnamed[0] === '', 'ماهی که نام و سالش خوانا نیست دست نمی‌خورد', JSON.stringify(r1.unnamed));
  t(r1.again === 0, 'بارِ دوم چیزی عوض نمی‌شود — هر ماه یک بار', 'n=' + r1.again);
  t(r1.flag.join() === '1404|شهریور,1405|مهر',
    'و نشانهٔ «انجام شد» فقط برای ماه‌های خوانا نوشته می‌شود', r1.flag.join(' , '));
  t(/^\d{4}\/\d{2}\/\d{2}$/.test(r1.mehr[0]),
    'تاریخِ مُهرخورده رقمِ انگلیسی دارد — عینِ تاریخِ ردیفِ تازه');

  /* کسی که تاریخی را دستی پاک کرده، دفعهٔ بعد پاک می‌ماند */
  const cleared = await p.evaluate(() => {
    state.monthsData['1405|مهر'].days[0].createdDate = '';
    const n = backfillCreatedDates();
    return { n, v: state.monthsData['1405|مهر'].days[0].createdDate };
  });
  t(cleared.n === 0 && cleared.v === '',
    'تاریخی که کاربر پاک کرده دوباره برنمی‌گردد', 'n=' + cleared.n);

  /* ---------- از این سر تا آن سر ----------
     دادهٔ بی‌تاریخ روی سرور می‌نشیند، صفحه از نو باز می‌شود، و جدول
     باید تاریخ‌ها را داشته باشد. */
  await p.evaluate(() => {
    const row = (dd, main, status) => ({ day: 1, createdDate: dd, main: main || '',
      meet: '', company: '', status: status || '', doneDate: '' });
    state.meta = { month: 'مهر', year: '1405' };
    state.currentMonthKey = '1405|مهر';
    state.monthsData = { '1405|مهر': { tasks: [], days: [
      row('', 'ردیفِ قدیمیِ یک', 'در حال انجام'),
      row('', 'ردیفِ قدیمیِ دو', 'انجام نشده'),
      row('1405/07/20', 'ردیفِ تاریخ‌دار', '')
    ] } };
    state.days = state.monthsData['1405|مهر'].days;
    delete state.datesFilled;
  });
  /* با force بالا می‌رود: نسخهٔ آزمونیِ سرور ردیف‌های دیگری دارد و
     نگهبانِ «از دست رفتنِ ردیف» جلوی ذخیرهٔ معمولی را می‌گیرد. */
  await p.evaluate(async () => { await Cloud.pushNow(true, true); });
  await p.waitForTimeout(800);
  await p.reload({ waitUntil: 'networkidle' });
  await p.waitForTimeout(3500);
  const shown = await p.evaluate(() => {
    const nb = document.querySelector('.navbtn[data-view="daily"]');
    if (nb) nb.click();
    renderDaily();
    return [...document.querySelectorAll('#dailyBody .daily-date-cell:not(.daily-done-cell)')]
      .map(x => x.textContent.trim());
  });
  const sh = shown.map(latin);
  t(sh.length === 3 && sh.filter(x => x === '1405/07/01').length === 2,
    'بعد از باز شدنِ دوبارهٔ صفحه، ردیف‌های قدیمی در جدول تاریخ دارند', sh.join(' | '));
  t(sh[2] === '1405/07/20', 'و ردیفِ تاریخ‌دار همان تاریخِ خودش را دارد', sh[2]);
  t(!sh.some(x => x === '—'), 'هیچ ردیفِ پُری دیگر «—» نشان نمی‌دهد', sh.join(' | '));

  const opts = await p.evaluate(() => {
    const el = document.getElementById('msfDailyDate');
    if (!el) return [];
    el.querySelector('.msf-btn').click();
    const panel = document.querySelector('.msf-panel, [class*=msf][class*=panel]');
    return panel ? [...panel.querySelectorAll('.msf-opt span')].map(x => x.textContent.trim()) : [];
  });
  t(opts.length === 2 && opts.map(latin).join() === '1405/07/01,1405/07/20',
    'و همان تاریخ در پالایهٔ ستونِ تاریخ هم پیدا می‌شود', opts.join(' , '));

  /* تقویمِ روزها هم باید همان روز را بشناسد */
  const dayCount = await p.evaluate(() => {
    const btn = document.getElementById('dayCalBtn');
    if (btn) btn.click();
    const d = [...document.querySelectorAll('.dcal-d')].find(x => x.classList.contains('has'));
    return { has: [...document.querySelectorAll('.dcal-d.has')].length,
             day: d ? d.getAttribute('data-dcal-day') : '',
             n: d ? (d.querySelector('b') || {}).textContent : '' };
  });
  t(dayCount.has === 2, 'تقویمِ روزها دو روزِ کاردار نشان می‌دهد', 'has=' + dayCount.has);
  t(dayCount.day === '1' && latin(dayCount.n) === '2',
    'که اولی‌شان روزِ اولِ ماه است با دو کار', dayCount.day + ' / ' + dayCount.n);

  await p.close();
}

await b.close();
console.log('\nخطای صفحه: ' + (errs.length ? errs.join(' | ') : 'نداشت'));
t(errs.length === 0, 'هیچ خطای جاوااسکریپتی در صفحه نیفتاد');
console.log('\n' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
