/* برنامهٔ روزانه: تاریخِ ایجاد، مرتب‌سازیِ تاریخ، و تقویمِ روزها.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { launch } from './pw.mjs';

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

const b = await launch();
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
    /* ماهِ کاریِ کارتابل روی همین ماهِ واقعی گذاشته می‌شود: «همهٔ این
       ماه» ماهی را می‌گیرد که تقویم نشان می‌دهد، و اگر آن با ماهِ
       تاریخ‌های آزمون یکی نباشد، آزمون سرِ اولِ ماه می‌افتاد — ایرادِ
       خودِ آزمون بود، نه کارتابل. */
    try {
      const names = ["فروردین","اردیبهشت","خرداد","تیر","مرداد","شهریور",
                     "مهر","آبان","آذر","دی","بهمن","اسفند"];
      state.meta = { month: names[t0.jm - 1], year: String(t0.jy) };
      state.currentMonthKey = String(t0.jy) + "|" + names[t0.jm - 1];
      if (!state.monthsData[state.currentMonthKey])
        state.monthsData[state.currentMonthKey] = { tasks: state.tasks, days: state.days };
      renderMeta();
    } catch (e) { }
    const k = (y, m, d) => y + '/' + ('0' + m).slice(-2) + '/' + ('0' + d).slice(-2);
    /* دو روزِ ثابت که هیچ‌کدام «امروز» نباشند: ردیفِ بی‌تاریخِ آزمون
       بعداً تاریخِ امروز را می‌گیرد و اگر یکی از این دو همان روز بود،
       شمارشِ ردیف‌ها به‌هم می‌ریخت — آزمون سرِ دوم و چهاردهمِ ماه
       می‌افتاد و بقیهٔ روزها پاس می‌شد. */
    const pick = [2, 3, 14, 15, 20].filter(d => d !== t0.jd);
    const mk2 = (dd, main, status) => ({ createdDate: dd, main, meet: '', company: '',
      status: status || '', doneDate: '' });
    state.days = [
      mk2(k(t0.jy, t0.jm, pick[1]), 'کارِ میانی', 'در حال انجام'),
      mk2(k(t0.jy, t0.jm, pick[0]), 'کارِ دومِ ماه', 'انجام شد'),
      mk2(k(t0.jy, t0.jm, pick[1]), 'کارِ میانیِ دوم', 'انجام نشده'),
      mk2(k(t0.jy, t0.jm === 12 ? 1 : t0.jm + 1, 3), 'کارِ ماهِ بعد', ''),
      mk2('', '', '')
    ];
    scheduleSave();
    document.querySelector('.navbtn[data-view="daily"]').click();
    if (window.DAYCAL) DAYCAL.refresh();
    renderDaily();
    /* روزِ «میانی» نباید خودِ امروز باشد: ردیفِ بی‌تاریخِ آزمون بعداً
       تاریخِ امروز را می‌گیرد و شمارش را به‌هم می‌ریخت. */
    return { mid: ('0' + pick[1]).slice(-2), d2: pick[0],
             jy: t0.jy, jm: t0.jm, jd: t0.jd };
  });
  await p.waitForTimeout(900);

  const dates = () => p.evaluate(() =>
    [...document.querySelectorAll('#dailyBody .daily-date-cell:not(.daily-done-cell)')]
      .map(x => x.textContent.trim()));
  const latin = s => String(s).replace(/[۰-۹]/g, d => '۰۱۲۳۴۵۶۷۸۹'.indexOf(d));

  /* ---------- پالایهٔ ستونِ تاریخ ---------- */
  const asc = (await dates()).map(latin);
  t(asc.length === 5, 'همهٔ ردیف‌ها دیده می‌شوند', asc.join(' | '));
  t(!(await p.evaluate(() => !!document.querySelector('#view-daily th.dcal-sort'))),
    'سرستونِ تاریخ دیگر مرتب‌سازی ندارد — خواسته شد که نباشد');

  const msf = await p.evaluate(() => {
    const el = document.getElementById('msfDailyDate');
    if (!el) return null;
    el.querySelector('.msf-btn').click();
    const panel = document.querySelector('.msf-panel, [class*=msf][class*=panel]');
    return { label: el.querySelector('.lbl').textContent.trim(),
             opts: panel ? [...panel.querySelectorAll('.msf-opt span')].map(x => x.textContent.trim()) : [] };
  });
  t(!!msf, 'ستونِ تاریخ پالایه دارد — مثلِ وضعیت و شرکت');
  t(msf && msf.label === 'همه', 'و سرِ شروع روی «همه» است', msf && msf.label);
  t(msf && msf.opts.length === 3 &&
    msf.opts.join() === msf.opts.slice().sort().join(),
    'فهرستش تاریخ‌های موجود است، مرتب و بی‌تکرار', msf && msf.opts.join(' , '));
  t(msf && msf.opts.every(x => /^[۰-۹]{4}\/[۰-۹]{2}\/[۰-۹]{2}$/.test(x)),
    'و با رقمِ فارسی نوشته شده — همان‌طور که در ستون دیده می‌شود');

  /* یک تاریخ را تیک می‌زنیم */
  await p.evaluate(d => {
    const panel = document.querySelector('.msf-panel, [class*=msf][class*=panel]');
    /* با خودِ تاریخِ کامل، نه فقط روز: «۱۴» در «۱۴۰۵/۰۸/۰۲» هم هست
       و آزمون ردیفِ اشتباه را تیک می‌زد. */
    const row = [...panel.querySelectorAll('.msf-opt')]
      .find(x => x.textContent.replace(/\s+/g, ' ').trim().indexOf(d) >= 0);
    const cb = row.querySelector('input');
    cb.checked = true;
    cb.dispatchEvent(new Event('change', { bubbles: true }));
  }, (function () {
    const f = '۰۱۲۳۴۵۶۷۸۹';
    const en = String(seed.jy) + '/' + ('0' + seed.jm).slice(-2) + '/' + seed.mid;
    return en.split('').map(c => (c >= '0' && c <= '9') ? f[+c] : c).join('');
  })());
  await p.waitForTimeout(700);
  const filtered = await dates();
  t(filtered.length === 2 && new Set(filtered).size === 1,
    'با تیکِ یک تاریخ، جدول همان روز می‌شود', filtered.join(' | '));
  const chip1 = await p.evaluate(() => (document.getElementById('dayCalChip') || {}).textContent || '');
  t(/۲/.test(chip1) && /کار/.test(chip1),
    'و نشانِ بالای جدول هم همان را می‌گوید', chip1.replace(/\s+/g, ' ').trim());
  await p.evaluate(() => { const c = document.getElementById('dayCalClear'); if (c) c.click(); });
  await p.waitForTimeout(600);
  t((await dates()).length === 5, 'و با ✕ همه برمی‌گردند');

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

  /* ---------- چند روز با هم ---------- */
  const dayBtn = (d, shift) => p.evaluate(a => {
    const el = [...document.querySelectorAll('.dcal-pop .dcal-d')]
      .find(x => Number(x.getAttribute('data-dcal-day')) === a.d);
    if (!el) return false;
    el.dispatchEvent(new MouseEvent('click', { bubbles: true, shiftKey: !!a.sh }));
    return true;
  }, { d, sh: shift });
  const calState = () => p.evaluate(() => ({
    open: !document.querySelector('.dcal-pop').hidden,
    on: [...document.querySelectorAll('.dcal-pop .dcal-d.on')].map(x => Number(x.getAttribute('data-dcal-day'))),
    ttl: (document.querySelector('.dcal-ttl') || {}).textContent.trim(),
    rows: document.querySelectorAll('#dailyBody tr').length,
    chip: (document.getElementById('dayCalChip') || {}).textContent || ''
  }));

  await p.evaluate(() => document.getElementById('dayCalBtn').click());
  await p.waitForTimeout(500);
  await dayBtn(seed.d2); await p.waitForTimeout(500);
  const one = await calState();
  t(one.open, 'تقویم با اولین انتخاب بسته نمی‌شود — پیش از این می‌بست');
  t(one.on.join() === String(seed.d2), 'روزِ اول انتخاب شد', one.on.join(','));

  await dayBtn(Number(seed.mid)); await p.waitForTimeout(500);
  const two = await calState();
  t(two.on.length === 2 && two.on.indexOf(seed.d2) >= 0,
    'روزِ دوم به انتخاب اضافه می‌شود، نه اینکه جایش را بگیرد', two.on.join(','));
  t(two.rows === 3, 'و جدول کارهای هر دو روز را نشان می‌دهد', String(two.rows));
  t(/۲ روز/.test(two.chip) && /۳/.test(two.chip),
    'نشانِ بالای جدول می‌گوید چند روز و چند کار', two.chip.replace(/\s+/g, ' ').trim());
  t(/۲ روز/.test(two.ttl), 'سرستونِ تقویم هم شمارِ روزها را می‌گوید', two.ttl);

  await dayBtn(seed.d2); await p.waitForTimeout(500);
  const back = await calState();
  t(back.on.length === 1 && back.on[0] === Number(seed.mid),
    'و زدنِ دوبارهٔ یک روز فقط همان را برمی‌دارد', back.on.join(','));

  /* انتظار را از خودِ داده درمی‌آوریم، نه از عددِ دستی: ردیف‌های آزمون
     در همین فایل عوض می‌شوند (یکی‌شان تاریخِ امروز را می‌گیرد). */
  const monthFacts = await p.evaluate(() => {
    const t0 = DatePick.today();
    const pre = t0.jy + '/' + ('0' + t0.jm).slice(-2) + '/';
    const mine = state.days.filter(d => String(d.createdDate || '').indexOf(pre) === 0);
    return { days: new Set(mine.map(d => d.createdDate)).size, rows: mine.length };
  });
  await p.evaluate(() => document.querySelector('.dcal-month').click());
  await p.waitForTimeout(600);
  const month = await calState();
  t(month.on.length === monthFacts.days && month.rows === monthFacts.rows,
    '«همهٔ این ماه» همهٔ روزهای کاردارِ ماه را با هم می‌گیرد',
    month.on.join(',') + ' / ' + month.rows + ' ردیف، انتظار: ' +
    monthFacts.days + ' روز و ' + monthFacts.rows + ' ردیف');

  await p.evaluate(() => document.querySelector('.dcal-all').click());
  await p.waitForTimeout(600);
  const none = await calState();
  t(none.on.length === 0 && none.rows === 5, '«همهٔ روزها» انتخاب را پاک می‌کند',
    String(none.rows));

  /* بازه با Shift: از روزِ دوم تا روزِ میانی — هر روزی که در این
     بازه کاری داشته باشد. */
  const want = await p.evaluate(a => {
    const t0 = DatePick.today();
    const pre = t0.jy + '/' + ('0' + t0.jm).slice(-2) + '/';
    const inRange = state.days.filter(d => {
      const v = String(d.createdDate || '');
      if (v.indexOf(pre) !== 0) return false;
      const dd = Number(v.slice(-2));
      /* بازه از همان روزی است که آزمون زده، نه از عددِ دستی: وگرنه
         روزی که ردیفِ بی‌تاریخ تاریخِ امروز را گرفته هم داخلِ انتظار
         می‌افتاد و فقط چند روزِ سال پاس می‌شد. */
      return dd >= a.lo && dd <= a.hi;
    });
    return { days: new Set(inRange.map(d => d.createdDate)).size, rows: inRange.length };
  }, { lo: Number(seed.d2), hi: Number(seed.mid) });
  await dayBtn(seed.d2); await p.waitForTimeout(400);
  await dayBtn(Number(seed.mid), true); await p.waitForTimeout(600);
  const range = await calState();
  t(range.on.length === want.days && range.rows === want.rows,
    'با Shift، بازهٔ بینِ دو روز انتخاب می‌شود',
    range.on.join(',') + ' / ' + range.rows + ' ردیف، انتظار: ' +
    want.days + ' روز و ' + want.rows + ' ردیف');
  await p.evaluate(() => document.querySelector('.dcal-all').click());
  await p.waitForTimeout(500);

  /* تقویم و پالایهٔ ستون، یک حالتِ مشترک دارند.
     باز بودنش را صریح می‌خواهیم: دکمه کلید است و اگر باز باشد می‌بندد. */
  await p.evaluate(() => { if (window.DAYCAL) DAYCAL.open(); });
  await p.waitForTimeout(500);
  await p.evaluate(d => {
    const el = [...document.querySelectorAll('.dcal-pop .dcal-d')]
      .find(x => Number(x.getAttribute('data-dcal-day')) === d);
    el.click();
  }, Number(seed.mid));
  await p.waitForTimeout(700);
  const sync = await p.evaluate(() => ({
    lbl: document.getElementById('msfDailyDate').querySelector('.lbl').textContent.trim(),
    on: [...document.querySelectorAll('.dcal-pop .dcal-d.on')].map(x => x.getAttribute('data-dcal-day'))
  }));
  t(sync.on.length === 1 && /[۰-۹]{4}\//.test(sync.lbl),
    'زدنِ روز در تقویم، همان تاریخ را در پالایهٔ ستون تیک می‌زند — یک حالت، دو راهِ تنظیم',
    sync.lbl + ' / ' + sync.on.join(','));
  await p.evaluate(() => { const c = document.getElementById('dayCalClear'); if (c) c.click(); });
  await p.waitForTimeout(600);

  await p.evaluate(() => { state.days = []; scheduleSave(); });
  await p.waitForTimeout(1600);
  await p.close();
  console.log('');
}

t(errs.length === 0, 'و هیچ خطای جاوااسکریپتی نبود', errs.join(' | ') || '—');
await b.close();
console.log((bad ? 'BAD ' + bad : 'همه خوب') + '  —  ' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
