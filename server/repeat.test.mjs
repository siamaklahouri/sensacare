/* وظیفه‌های تکرارشونده: ماهِ تازه دیگر از صفر شروع نمی‌شود.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { launch } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
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

  /* سه وظیفه: یکی تکرارشونده، یکی یک‌باره، و یکی از دادهٔ قدیمی که
     اصلاً کلیدِ repeat ندارد. */
  await p.evaluate(() => {
    state.meta = { month: 'مهر', year: '1405' };
    state.currentMonthKey = '1405|مهر';
    state.tasks = [
      { category: 'بکاپ‌گیری', task: 'کارِ هرماهه', owner: 'سیامک', deadline: 5,
        status: 'انجام شد', priority: 'بالا', note: 'یادداشتِ ماندگار', repeat: true },
      { category: 'سایر', task: 'کارِ یک‌بارهٔ مهر', owner: '', deadline: 9,
        status: 'انجام شد', priority: 'متوسط', note: '', repeat: false },
      { category: 'شبکه', task: 'ردیفِ قدیمیِ بی‌کلید', owner: '', deadline: 2,
        status: 'در حال انجام', priority: 'پایین', note: '' }
    ];
    state.monthsData = { '1405|مهر': { tasks: state.tasks, days: state.days } };
    renderChecklist();
  });
  await p.waitForTimeout(500);

  /* ---------- ستونِ تیک ---------- */
  const col = await p.evaluate(() => {
    const boxes = [...document.querySelectorAll('#checklistBody .rep-box')];
    return { n: boxes.length, tag: boxes[0] ? boxes[0].tagName : '',
             val: boxes.map(x => x.value),
             opts: boxes[0] ? [...boxes[0].options].map(o => o.value).join(',') : '' };
  });
  t(col.n === 3 && col.tag === 'SELECT',
    'هر وظیفه دورهٔ تکرارِ خودش را دارد — از تیکِ دوحالته به یک فهرست', col.tag);
  t(col.opts === '0,1,3,6,12',
    'هرگز / هر ماه / هر ۳ ماه / هر ۶ ماه / سالانه', col.opts);
  t(col.val[0] === '1' && col.val[1] === '0',
    'آنچه تکرارشونده بود «هر ماه» است و یک‌باره «هرگز»', JSON.stringify(col.val));
  t(col.val[2] === '1',
    'ردیفِ قدیمی (بی‌کلیدِ repeat) هر ماه حساب می‌شود — دادهٔ موجود همان‌طور می‌ماند');

  /* ---------- ماهِ تازه، با آوردن ---------- */
  const carried = await p.evaluate(() => {
    switchToMonth('آبان', '1405', { carryTasks: true });
    return state.tasks.map(x => ({ task: x.task, status: x.status, cat: x.category,
      owner: x.owner, dl: x.deadline, note: x.note, pr: x.priority }));
  });
  t(carried.length === 2, 'در ماهِ تازه فقط وظیفه‌های تکرارشونده می‌آیند',
    carried.map(x => x.task).join(' | '));
  t(!carried.some(x => x.task === 'کارِ یک‌بارهٔ مهر'), 'کارِ یک‌بارهٔ ماهِ قبل نمی‌آید');
  t(carried.every(x => x.status === 'انجام نشده'),
    'و وضعیتشان صفر می‌شود — وگرنه ماهِ تازه از همان اول «انجام شد» بود',
    carried.map(x => x.status).join(' , '));
  const first = carried.find(x => x.task === 'کارِ هرماهه') || {};
  t(first.cat === 'بکاپ‌گیری' && first.owner === 'سیامک' && first.dl === 5 && first.pr === 'بالا',
    'دسته و مسئول و روزِ مهلت و اولویت با خودشان می‌آیند',
    [first.cat, first.owner, first.dl, first.pr].join(' / '));
  t(first.note === 'یادداشتِ ماندگار', 'یادداشت هم می‌ماند — پاک کردنش کارِ کاربر است');

  /* ماهِ قبل دست‌نخورده مانده */
  const back = await p.evaluate(() => {
    switchToMonth('مهر', '1405');
    return state.tasks.map(x => x.task + ':' + x.status);
  });
  t(back.length === 3 && back[0] === 'کارِ هرماهه:انجام شد',
    'و ماهِ قبل همان‌طور که بود می‌ماند', back.join(' | '));

  /* ---------- ماهِ تازه، بی‌آوردن ---------- */
  const empty = await p.evaluate(() => {
    switchToMonth('آذر', '1405', { carryTasks: false });
    return state.tasks.length;
  });
  t(empty === 0, 'اگر تیکِ «بیاور» برداشته شود، ماه خالی ساخته می‌شود', 'n=' + empty);

  /* ---------- خودِ پنجرهٔ ماه‌ها ---------- */
  const popup = await p.evaluate(() => {
    document.getElementById('monthBtn').click();
    const el = document.getElementById('newMonthCarry');
    return { there: !!el, on: el ? el.checked : null,
             label: el ? (el.closest('label') || {}).textContent.replace(/\s+/g, ' ').trim() : '' };
  });
  t(popup.there && popup.on === true,
    'پنجرهٔ ماه‌ها گزینه‌اش را دارد و پیش‌فرض روشن است', popup.label);
  await p.evaluate(() => { const x = document.getElementById('monthPopX'); if (x) x.click(); });

  /* زدنِ تیک در جدول، در داده می‌نشیند */
  const toggled = await p.evaluate(async () => {
    switchToMonth('مهر', '1405');
    renderChecklist();
    await new Promise(r => setTimeout(r, 200));
    const cb = document.querySelector('#checklistBody .rep-box[data-rep="0"]');
    cb.value = '0';
    cb.dispatchEvent(new Event('change', { bubbles: true }));
    const off = { v: state.tasks[0].every, r: state.tasks[0].repeat, title: cb.title };
    cb.value = '3';
    cb.dispatchEvent(new Event('change', { bubbles: true }));
    return { off, ev: state.tasks[0].every, since: state.tasks[0].since,
             rid: !!state.tasks[0].rid, title: cb.title };
  });
  t(toggled.off.v === 0 && toggled.off.r === false, '«هرگز» در خودِ داده می‌نشیند');
  t(/فقط همین ماه/.test(toggled.off.title), 'و راهنمای خانه هم عوض می‌شود', toggled.off.title);
  t(toggled.ev === 3 && /۳ ماه/.test(toggled.title),
    'و دورهٔ سه‌ماهه هم', toggled.ev + ' — ' + toggled.title);
  t(toggled.since === '1405|مهر' && toggled.rid,
    'وظیفه ماهِ شروع و شناسهٔ خودش را می‌گیرد — شمردنِ دوره از همین‌جاست',
    toggled.since);

  /* ---------- دوره‌های بلندتر ---------- */
  const cycle = await p.evaluate(() => {
    state.monthsData = {};
    state.currentMonthKey = '1405|مهر';
    state.meta = { month: 'مهر', year: '1405' };
    state.monthsData['1405|مهر'] = { tasks: [
      { rid: 'a', category: 'شبکه', task: 'ماهانه', deadline: 1, status: 'انجام شد',
        every: 1, since: '1405|مهر' },
      { rid: 'b', category: 'بکاپ', task: 'سه‌ماهه', deadline: 2, status: 'انجام شد',
        every: 3, since: '1405|مهر' },
      { rid: 'c', category: 'لایسنس', task: 'سالانه', deadline: 3, status: 'انجام شد',
        every: 12, since: '1405|مهر' }
    ], days: [] };
    state.tasks = state.monthsData['1405|مهر'].tasks;
    state.days = [];
    const out = {};
    ['آبان', 'آذر', 'دی'].forEach(m => {
      switchToMonth(m, '1405');
      out[m] = state.tasks.map(x => x.task).join(',');
    });
    switchToMonth('مهر', '1406');
    out.next = state.tasks.map(x => x.task).join(',');
    return out;
  });
  t(cycle['آبان'] === 'ماهانه' && cycle['آذر'] === 'ماهانه',
    'کارِ سه‌ماهه در دو ماهِ میانی نمی‌آید', cycle['آبان'] + ' / ' + cycle['آذر']);
  t(/سه‌ماهه/.test(cycle['دی']),
    'و سرِ ماهِ سوم می‌آید — شمارش از ماهِ شروع است، نه از ماهِ قبل', cycle['دی']);
  t(/سالانه/.test(cycle.next) && /سه‌ماهه/.test(cycle.next),
    'سالانه یک سال بعد می‌آید، و سه‌ماهه هم همان‌جا هست', cycle.next);

  await p.close();
}

await b.close();
console.log('\nخطای صفحه: ' + (errs.length ? errs.join(' | ') : 'نداشت'));
t(errs.length === 0, 'هیچ خطای جاوااسکریپتی در صفحه نیفتاد');
console.log('\n' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
