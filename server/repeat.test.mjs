/* وظیفه‌های تکرارشونده: ماهِ تازه دیگر از صفر شروع نمی‌شود.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';

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
    return { n: boxes.length, checked: boxes.map(x => x.checked) };
  });
  t(col.n === 3, 'هر وظیفه یک تیکِ «تکرار» دارد', 'n=' + col.n);
  t(col.checked[0] === true && col.checked[1] === false,
    'آنچه تکرارشونده است تیک دارد، یک‌باره نه', JSON.stringify(col.checked));
  t(col.checked[2] === true,
    'ردیفِ قدیمی (بی‌کلیدِ repeat) تکرارشونده حساب می‌شود — وگرنه ایرادِ قبلی برای دادهٔ موجود می‌ماند');

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
    cb.checked = false;
    cb.dispatchEvent(new Event('change', { bubbles: true }));
    return { v: state.tasks[0].repeat, title: cb.title };
  });
  t(toggled.v === false, 'برداشتنِ تیک در خودِ داده می‌نشیند');
  t(/فقط همین ماه/.test(toggled.title), 'و راهنمای دکمه هم عوض می‌شود', toggled.title);

  await p.close();
}

await b.close();
console.log('\nخطای صفحه: ' + (errs.length ? errs.join(' | ') : 'نداشت'));
t(errs.length === 0, 'هیچ خطای جاوااسکریپتی در صفحه نیفتاد');
console.log('\n' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
