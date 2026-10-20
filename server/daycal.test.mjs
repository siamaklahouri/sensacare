/* برنامهٔ روزانه: تاریخِ ایجاد، مرتب‌سازیِ تاریخ، و تقویمِ روزها.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
/* هر دو قالب: فنی (سیامک) و مالی (سینا) — ایراد «در بعضی کارتابل‌ها
   تاریخ نمی‌افتد» یعنی باید هر دو آزموده شوند. */
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

  /* ردیف‌هایی با تاریخ‌های درهم، یکی هم بی‌تاریخ — مثلِ ردیف‌های آمادهٔ
     ماه که ایرادشان گزارش شده بود. */
  const seed = await p.evaluate(() => {
    const t0 = DatePick.today();
    const k = (y, m, d) => y + '/' + ('0' + m).slice(-2) + '/' + ('0' + d).slice(-2);
    const mk2 = (dd, main, status) => ({ createdDate: dd, main, meet: '', company: '',
      status: status || '', doneDate: '' });
    state.days = [
      mk2(k(t0.jy, t0.jm, Math.min(26, t0.jd)), 'کارِ میانی', 'در حال انجام'),
      mk2(k(t0.jy, t0.jm, 2), 'کارِ دومِ ماه', 'انجام شد'),
      mk2(k(t0.jy, t0.jm, Math.min(26, t0.jd)), 'کارِ میانیِ دوم', 'انجام نشده'),
      mk2(k(t0.jy, t0.jm === 12 ? 1 : t0.jm + 1, 3), 'کارِ ماهِ بعد', ''),
      mk2('', '', '')
    ];
    scheduleSave();
    document.querySelector('.navbtn[data-view="daily"]').click();
    if (window.DAYCAL) DAYCAL.refresh();
    renderDaily();
    return { mid: ('0' + Math.min(26, t0.jd)).slice(-2), jy: t0.jy, jm: t0.jm, jd: t0.jd };
  });
  await p.waitForTimeout(900);

  const dates = () => p.evaluate(() =>
    [...document.querySelectorAll('#dailyBody .daily-date-cell:not(.daily-done-cell)')]
      .map(x => x.textContent.trim()));
  const latin = s => String(s).replace(/[۰-۹]/g, d => '۰۱۲۳۴۵۶۷۸۹'.indexOf(d));

  /* ---------- مرتب‌سازی ---------- */
  const asc = (await dates()).map(latin);
  const sorted = asc.filter(x => x !== '—');
  t(sorted.length === 4 && sorted.join() === sorted.slice().sort().join(),
    'جدول از ابتدا بر اساس تاریخ مرتب است', asc.join(' | '));
  t(asc[asc.length - 1] === '—', 'و ردیفِ بی‌تاریخ ته فهرست می‌ماند');

  const th = () => p.evaluate(() => {
    const el = document.querySelector('#view-daily th.dcal-sort');
    return el ? { txt: el.textContent.replace(/\s+/g, ' ').trim(),
                  mark: (el.querySelector('.dcal-arrow') || {}).textContent } : null;
  });
  t((await th()) && /▲/.test((await th()).mark), 'سرستونِ تاریخ نشانِ صعودی دارد', (await th()).mark);
  await p.evaluate(() => document.querySelector('#view-daily th.dcal-sort').click());
  await p.waitForTimeout(500);
  const desc = (await dates()).map(latin).filter(x => x !== '—');
  t(desc.join() === sorted.slice().reverse().join(), 'با یک کلیک، نزولی می‌شود', desc.join(' | '));
  t(/▼/.test((await th()).mark), 'و نشانش هم برمی‌گردد');
  await p.evaluate(() => document.querySelector('#view-daily th.dcal-sort').click());
  await p.waitForTimeout(500);
  const manual = (await dates()).map(latin);
  t(manual.join() !== desc.join() && /↕/.test((await th()).mark),
    'کلیکِ بعدی ترتیبِ دستی است — همان‌طور که ردیف‌ها چیده شده‌اند', manual.join(' | '));
  await p.evaluate(() => document.querySelector('#view-daily th.dcal-sort').click());
  await p.waitForTimeout(500);
  t((await dates()).map(latin).join() === asc.join(), 'و دوباره صعودی');

  /* ---------- تقویم ---------- */
  const btn = await p.evaluate(() => {
    const el = document.getElementById('dayCalBtn');
    if (!el) return null;
    const ex = el.closest('.day-ex');
    return { txt: el.textContent.trim(),
             nearExports: !!(ex && ex.querySelector('#dayXlsxBtn, #dayPdfBtn')) || !!ex };
  });
  t(btn && /تقویم/.test(btn.txt), 'دکمهٔ تقویم هست', btn && btn.txt);
  t(btn && btn.nearExports, 'و کنارِ خروجی‌ها نشسته');

  await p.evaluate(() => document.getElementById('dayCalBtn').click());
  await p.waitForTimeout(600);
  const cal = await p.evaluate(() => {
    const pop = document.querySelector('.dcal-pop');
    return { open: !pop.hidden, ttl: pop.querySelector('.dcal-ttl').textContent.trim(),
             cells: pop.querySelectorAll('.dcal-d').length,
             withWork: [...pop.querySelectorAll('.dcal-d.has')]
               .map(x => x.getAttribute('data-dcal-day') + ':' + (x.querySelector('b') || {}).textContent),
             dead: [...pop.querySelectorAll('.dcal-d[disabled]')].length,
             now: !!pop.querySelector('.dcal-d.now') };
  });
  t(cal.open && cal.cells >= 29, 'تقویم باز می‌شود و روزهای ماه را دارد',
    cal.ttl + ' — ' + cal.cells + ' روز');
  t(cal.withWork.length === 2, 'فقط روزهایی که کار دارند نشان دارند', cal.withWork.join(' , '));
  t(cal.withWork.some(x => x.indexOf(String(Number(seed.mid)) + ':۲') === 0),
    'و شمارِ کارِ هر روز درست است — دو کار در یک روز', cal.withWork.join(' , '));
  t(cal.dead > 20, 'روزهای بی‌کار زدنی نیستند', String(cal.dead));
  t(cal.now, 'و امروز نشانِ خودش را دارد');

  /* روی روزِ دوکاره بزن */
  await p.evaluate(d => {
    const el = [...document.querySelectorAll('.dcal-pop .dcal-d')]
      .find(x => Number(x.getAttribute('data-dcal-day')) === d);
    el.click();
  }, Number(seed.mid));
  await p.waitForTimeout(700);
  const picked = await dates();
  const chip = await p.evaluate(() => (document.getElementById('dayCalChip') || {}).textContent || '');
  t(picked.length === 2 && new Set(picked).size === 1,
    'با زدنِ یک روز، جدول همان روز می‌شود', picked.join(' | '));
  t(/۲/.test(chip) && /کار/.test(chip), 'و یک نشان بالای جدول می‌گوید کدام روز و چند کار',
    chip.replace(/\s+/g, ' ').trim());
  const rowsNow = await p.evaluate(() => document.querySelectorAll('#dailyBody tr').length);
  t(rowsNow === 2, 'و هیچ ردیفِ دیگری نیست', String(rowsNow));

  /* همان روز را دوباره زدن، فیلتر را برمی‌دارد */
  await p.evaluate(d => {
    const el = [...document.querySelectorAll('.dcal-pop .dcal-d')]
      .find(x => Number(x.getAttribute('data-dcal-day')) === d);
    el.click();
  }, Number(seed.mid));
  await p.waitForTimeout(700);
  t((await dates()).length === 5, 'و زدنِ دوبارهٔ همان روز، همه را برمی‌گرداند');

  /* زدنِ تاریخ داخلِ خودِ جدول */
  await p.evaluate(() => {
    const td = [...document.querySelectorAll('#dailyBody .daily-date-cell:not(.daily-done-cell)')]
      .find(x => !/—/.test(x.textContent));
    td.click();
  });
  await p.waitForTimeout(700);
  const byCell = await dates();
  t(byCell.length >= 1 && byCell.length < 5 && new Set(byCell).size === 1,
    'زدنِ خودِ تاریخ در جدول هم همان روز را نشان می‌دهد', byCell.join(' | '));
  await p.evaluate(() => { const c = document.getElementById('dayCalClear'); if (c) c.click(); });
  await p.waitForTimeout(600);

  /* ---------- تاریخِ ایجاد ---------- */
  const stamp = await p.evaluate(() => {
    const tr = [...document.querySelectorAll('#dailyBody tr')]
      .find(x => /—/.test((x.querySelector('.daily-date-cell') || {}).textContent || ''));
    if (!tr) return { no: true };
    const idx = Number(tr.getAttribute('data-idx'));
    const before = state.days[idx].createdDate;
    const inp = tr.querySelector('input[data-field="main"]');
    inp.value = 'کاری که تازه نوشته شد';
    inp.dispatchEvent(new Event('change', { bubbles: true }));
    return { before, after: state.days[idx].createdDate, today: (function () {
      const x = DatePick.today();
      return x.jy + '/' + ('0' + x.jm).slice(-2) + '/' + ('0' + x.jd).slice(-2);
    })() };
  });
  t(!stamp.no && !stamp.before && stamp.after === stamp.today,
    'ردیفِ بی‌تاریخ، با اولین نوشتن تاریخِ امروز را می‌گیرد — همان ایرادی که گزارش شد',
    JSON.stringify(stamp));

  /* و تاریخِ ردیفی که از قبل تاریخ دارد دست نمی‌خورد */
  const kept = await p.evaluate(() => {
    const tr = [...document.querySelectorAll('#dailyBody tr')]
      .find(x => !/—/.test((x.querySelector('.daily-date-cell') || {}).textContent || ''));
    const idx = Number(tr.getAttribute('data-idx'));
    const before = state.days[idx].createdDate;
    const inp = tr.querySelector('input[data-field="meet"]');
    inp.value = 'توضیحِ تازه';
    inp.dispatchEvent(new Event('change', { bubbles: true }));
    return { before, after: state.days[idx].createdDate };
  });
  t(kept.before === kept.after, 'و تاریخِ ردیفِ قدیمی دست‌نخورده می‌ماند',
    kept.before + ' → ' + kept.after);

  /* کشیدنِ ردیف یعنی ترتیبِ دستی */
  await p.evaluate(() => { if (window.DAYCAL) DAYCAL.manual(); });
  await p.waitForTimeout(300);
  t(/↕/.test((await th()).mark),
    'جابه‌جا کردنِ ردیف‌ها، مرتب‌سازی را به «دستی» برمی‌گرداند', (await th()).mark);

  await p.evaluate(() => { state.days = []; scheduleSave(); });
  await p.waitForTimeout(1600);
  await p.close();
  console.log('');
}

t(errs.length === 0, 'و هیچ خطای جاوااسکریپتی نبود', errs.join(' | ') || '—');
await b.close();
console.log((bad ? 'BAD ' + bad : 'همه خوب') + '  —  ' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
