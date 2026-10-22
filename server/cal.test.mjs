/* تقویم: تعطیلی‌ها، یادداشتِ روز، رنگِ هر ماه، و رفتن به برنامهٔ
   روزانه. سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const WHO = [
  { page: '/siamak/', api: 'kartabl', pass: 'siamaksiamak', name: 'کارتابلِ فنی' },
  { page: '/sina/', api: 'sina', pass: 'sinasinasina', name: 'کارتابلِ مالی' }
];
const src = x => x ? (x.d + '/' + x.m) : '—';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const errs = [];
for (const w of WHO) {
  console.log('===== ' + w.name + ' =====');
  const p = await b.newPage({ viewport: { width: 1340, height: 950 } });
  p.on('pageerror', e => errs.push(w.api + ': ' + String(e).slice(0, 160)));
  p.on('dialog', d => d.accept());
  await p.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await p.evaluate(async a => {
    await fetch('/api/' + a.api + '/login', { method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ password: a.pass, remember: false }) });
  }, { api: w.api, pass: w.pass });
  await p.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await p.waitForTimeout(2800);

  /* ---------- خودِ بخش ---------- */
  const there = await p.evaluate(() => {
    const nb = document.querySelector('.navbtn[data-view="cal"]');
    return { nav: !!nb, feat: nb ? nb.getAttribute('data-feat') : 'x',
             sec: !!document.getElementById('view-cal'),
             grid: !!document.getElementById('calGrid'),
             side: !!document.getElementById('calSide') };
  });
  t(there.nav && there.sec, 'بخشِ تقویم در نوارِ کنار هست');
  t(there.feat === null, 'و بی‌قید است — برای همهٔ کارتابل‌ها، نه پشتِ اجازهٔ ادمین',
    String(there.feat));
  t(there.grid && there.side, 'شبکهٔ روزها و کنارهٔ روز هر دو ساخته شده‌اند');

  /* ---------- تعطیلی‌ها ---------- */
  const hol = await p.evaluate(() => {
    const H = (y, m, d) => CAL.holiday(y, m, d);
    const fri = (() => { for (let d = 1; d <= 30; d++) {
      const g = DatePick.toG(1405, 7, d);
      if (new Date(g.gy, g.gm - 1, g.gd).getDay() === 5) return d; } return 0; })();
    /* یک قمریِ تنها: نه جمعه، نه هم‌زمان با تعطیلیِ شمسی — وگرنه
       جابه‌جا شدنش زیرِ آن یکی گم می‌شد و آزمون چیزی ثابت نمی‌کرد. */
    const lunar = (() => { for (let m = 1; m <= 12; m++) for (let d = 1; d <= 28; d++) {
      const h = H(1405, m, d);
      if (h.approx && h.name.indexOf('·') < 0) return { m, d, name: h.name }; } return null; })();
    return {
      noruz: [1, 2, 3, 4].map(d => H(1405, 1, d).off),
      nature: H(1405, 1, 13).off, rev: H(1405, 11, 22).off, oil: H(1405, 12, 29).off,
      plain: H(1405, 5, 2).off || H(1405, 5, 3).off || H(1405, 5, 4).off,
      friday: fri ? H(1405, 7, fri) : null, fri: fri, lunar
    };
  });
  t(hol.noruz.every(Boolean), 'چهار روزِ نوروز تعطیل است');
  t(hol.nature && hol.rev && hol.oil,
    '۱۳ فروردین، ۲۲ بهمن و ۲۹ اسفند هم', JSON.stringify([hol.nature, hol.rev, hol.oil]));
  t(hol.friday && hol.friday.off && /جمعه/.test(hol.friday.name),
    'جمعه‌ها خودبه‌خود تعطیل‌اند', hol.fri + ' مهر');
  t(!!hol.lunar && hol.lunar.approx !== false,
    'تعطیلی‌های قمری هم پیدا می‌شوند', hol.lunar && (hol.lunar.name + ' — ' + hol.lunar.d + '/' + hol.lunar.m));

  /* جابه‌جاییِ یک‌روزه: همان مناسبت باید یک روز آن‌طرف‌تر بنشیند */
  const moved = await p.evaluate(src => {
    const sel = document.getElementById('calShift');
    const set = v => { sel.value = String(v); sel.dispatchEvent(new Event('change', { bubbles: true })); };
    set(1);
    const here = CAL.holiday(1405, src.m, src.d).name;
    const next = CAL.holiday(1405, src.m, src.d + 1).name;
    set(0);
    return { was: src.name, here, next, kept: CAL.holiday(1405, src.m, src.d).name };
  }, hol.lunar);
  t(moved.next === moved.was && moved.here !== moved.was,
    'با «یک روز جلو»، همان مناسبت یک روز جابه‌جا می‌شود — هلال را فرمول قطعی نمی‌گوید',
    moved.was + ': ' + src(hol.lunar) + ' → ' + (hol.lunar.d + 1) + '/' + hol.lunar.m);
  t(moved.kept === moved.was, 'و با برگرداندنِ تنظیم، سرِ جای اولش می‌نشیند');

  /* حرفِ خودِ کاربر بر همه می‌چربد */
  const own = await p.evaluate(f => {
    state.calOff = {};
    const k = '1405/07/' + ('0' + f).slice(-2);
    state.calOff[k] = 0;
    const openFri = CAL.holiday(1405, 7, f).off;
    state.calOff['1405/07/08'] = 1;
    const shutTue = CAL.holiday(1405, 7, 8).off;
    state.calOff = {};
    return { openFri, shutTue };
  }, hol.fri);
  t(own.openFri === false, 'یک جمعه را می‌شود «کاری» کرد');
  t(own.shutTue === true, 'و یک روزِ عادی را «تعطیل» — تقویمی که درست نشود بدتر از نبودنش است');

  /* ---------- کارهای روز ---------- */
  const items = await p.evaluate(() => {
    state.meta = { month: 'مهر', year: '1405' };
    state.currentMonthKey = '1405|مهر';
    state.monthsData['1405|مهر'] = {
      tasks: [{ category: 'شبکه', task: 'تمدیدِ گواهی', deadline: 12, status: 'انجام نشده' }],
      days: [{ day: 1, createdDate: '1405/07/12', main: 'نصبِ سرور', company: 'سنگ آهن', status: 'انجام شد' }]
    };
    state.tasks = state.monthsData['1405|مهر'].tasks;
    state.days = state.monthsData['1405|مهر'].days;
    document.querySelector('.navbtn[data-view="cal"]').click();
    CAL.render();
    const cell = document.querySelector('[data-cal-day="12"]');
    return { n: CAL.items(1405, 7, 12).length,
             kinds: CAL.items(1405, 7, 12).map(x => x.t).join(','),
             shown: cell ? cell.textContent : '',
             empty: CAL.items(1405, 7, 9).length };
  });
  t(items.n === 2 && /day/.test(items.kinds) && /task/.test(items.kinds),
    'هم ردیفِ برنامهٔ روزانه و هم مهلتِ چک‌لیست سرِ همان روز می‌آیند', items.kinds);
  t(/نصبِ سرور/.test(items.shown) && /تمدیدِ گواهی/.test(items.shown),
    'و روی خودِ خانهٔ تقویم نوشته می‌شوند');
  t(items.empty === 0, 'روزِ بی‌کار خالی می‌ماند');

  /* ---------- یادداشتِ روز ---------- */
  await p.evaluate(() => { document.querySelector('[data-cal-day="14"]').click(); });
  await p.waitForTimeout(300);
  await p.evaluate(() => {
    const ta = document.getElementById('calNote');
    ta.value = 'قرارِ ناهار با تیم';
    ta.dispatchEvent(new Event('input', { bubbles: true }));
  });
  await p.waitForTimeout(1000);
  const note = await p.evaluate(() => ({
    saved: (state.calNotes || {})['1405/07/14'] || '',
    mark: !!document.querySelector('[data-cal-day="14"] .c2-note'),
    back: (function () { CAL.render(); const ta = document.getElementById('calNote'); return ta ? ta.value : ''; })()
  }));
  t(note.saved === 'قرارِ ناهار با تیم', 'یادداشتِ روز در خودِ دادهٔ کارتابل می‌نشیند', note.saved);
  t(note.mark, 'و روی خانهٔ همان روز نشانه می‌گذارد');
  t(note.back === 'قرارِ ناهار با تیم', 'و با کشیدنِ دوبارهٔ تقویم سرِ جایش است');

  const gone = await p.evaluate(() => {
    const ta = document.getElementById('calNote');
    ta.value = '';
    ta.dispatchEvent(new Event('input', { bubbles: true }));
    return !!(state.calNotes || {})['1405/07/14'];
  });
  t(gone === false, 'یادداشتِ خالی پاک می‌شود، نه اینکه رشتهٔ خالی بماند');

  /* ---------- رنگِ هر ماه ---------- */
  const tone = await p.evaluate(() => {
    const h = document.getElementById('view-cal');
    const read = () => h.style.getPropertyValue('--c2').trim();
    CAL.render();
    const a = read(), ttlA = document.getElementById('calTtl').textContent;
    document.querySelector('[data-cal-step="1"]').click();
    const b2 = read(), ttlB = document.getElementById('calTtl').textContent;
    document.querySelector('[data-cal-step="-1"]').click();
    return { a, b: b2, ttlA, ttlB, back: read() };
  });
  t(tone.a && tone.b && tone.a !== tone.b,
    'هر ماه رنگِ خودش را دارد', tone.a + ' → ' + tone.b);
  t(tone.back === tone.a, 'و با برگشتن به ماهِ قبل، رنگ هم برمی‌گردد');
  t(tone.ttlA !== tone.ttlB && /مهر/.test(tone.ttlA),
    'عنوان هم با ماه عوض می‌شود', tone.ttlA.trim() + ' → ' + tone.ttlB.trim());

  /* ---------- رفتن به برنامهٔ روزانه ---------- */
  const jump = await p.evaluate(() => {
    document.querySelector('[data-cal-day="12"]').click();
    document.getElementById('calGoBtn').click();
    return { picked: (window.DAY_DATE ? DAY_DATE.get() : []).join(','),
             view: document.querySelector('.view.active').id,
             rows: document.querySelectorAll('#dailyBody tr').length };
  });
  t(/۱۴۰۵\/۰۷\/۱۲/.test(jump.picked), 'زدنِ «رفتن به برنامهٔ روزانه» همان روز را پالایه می‌کند', jump.picked);
  t(jump.view === 'view-daily', 'و خودِ بخش هم عوض می‌شود', jump.view);
  t(jump.rows === 1, 'پس جدول فقط همان روز را نشان می‌دهد', 'ردیف=' + jump.rows);

  await p.close();
}
await b.close();
console.log('\nخطای صفحه: ' + (errs.length ? errs.join(' | ') : 'نداشت'));
t(errs.length === 0, 'هیچ خطای جاوااسکریپتی در صفحه نیفتاد');
console.log('\n' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
