/* جست‌وجوی سراسری: بینِ همهٔ ماه‌ها و جدول‌ها، و پریدن سرِ نتیجه.
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

  /* دو ماه: چیزی که دنبالش می‌گردیم در ماهِ بسته است، نه ماهِ باز. */
  await p.evaluate(() => {
    const task = (name, note) => ({ category: 'سایر', task: name, owner: '', deadline: 3,
      status: 'انجام نشده', priority: 'متوسط', note: note || '' });
    state.meta = { month: 'مهر', year: '1405' };
    state.currentMonthKey = '1405|مهر';
    state.tasks = [task('تمدید گواهیِ اس‌اس‌ال', 'سالانه')];
    state.days = [{ day: 1, createdDate: '1405/07/02', main: 'جلسه با آفتاب‌گستر',
                    meet: '', company: 'آفتاب‌گستر', status: 'انجام شد', doneDate: '' }];
    state.monthsData = {
      '1405|مهر': { tasks: state.tasks, days: state.days },
      '1404|شهریور': { tasks: [task('خریدِ هاردِ بکاپ', 'پارسال')], days: [] }
    };
    if (typeof renderAll === 'function') renderAll();
    else { renderChecklist(); renderDaily(); }
  });
  await p.waitForTimeout(600);

  /* ---------- موتورِ جست‌وجو ---------- */
  const r = await p.evaluate(() => ({
    old: FIND.search('هارد').map(x => x.where + '|' + x.monthLabel + '|' + x.title),
    cur: FIND.search('اس‌اس‌ال').length,
    day: FIND.search('آفتاب').map(x => x.view),
    short: FIND.search('ه').length,
    none: FIND.search('هیچ‌چیزِ پیدانشدنی').length
  }));
  t(r.old.length === 1 && /شهریور/.test(r.old[0]),
    'چیزی که در ماهِ بسته است هم پیدا می‌شود', r.old.join(' , '));
  t(r.cur === 1, 'و ماهِ باز هم همین‌طور');
  t(r.day.indexOf('daily') >= 0, 'برنامهٔ روزانه هم گشته می‌شود', r.day.join(','));
  t(r.short === 0, 'با یک حرف نمی‌گردد — وگرنه هر بار نیمی از کارتابل برمی‌گشت');
  t(r.none === 0, 'و چیزی که نیست، نتیجه نمی‌دهد');

  /* نوشتنِ «می شود» و «ميشود» باید یکی حساب شود */
  const nrm = await p.evaluate(() => {
    state.tasks.push({ category: 'سایر', task: 'بررسيِ ليستِ كاربران', owner: '', deadline: 1,
      status: 'انجام نشده', priority: 'پایین', note: '' });
    try { syncWorkingMonth(); } catch (e) { }
    return { a: FIND.search('بررسی لیست').length, b: FIND.search('كاربران').length };
  });
  t(nrm.a >= 1 && nrm.b >= 1,
    'ی/ي و ک/ك و نیم‌فاصله یکی حساب می‌شوند', JSON.stringify(nrm));

  /* ---------- دیتای شخصی گشته نمی‌شود ---------- */
  const vault = await p.evaluate(() => {
    state.personalVault = { cipher: 'xxx', secretWordInside: 'رمزِ بانک' };
    return FIND.search('رمزِ بانک').length;
  });
  t(vault === 0, 'دیتای شخصی گشته نمی‌شود — عمدی است، نه از قلم افتاده');

  /* ---------- خودِ کشو ---------- */
  const ui = await p.evaluate(async () => {
    document.getElementById('findBtn').click();
    await new Promise(r => setTimeout(r, 150));
    const box = document.getElementById('findBox');
    const inp = document.getElementById('findInput');
    inp.value = 'هارد';
    inp.dispatchEvent(new Event('input', { bubbles: true }));
    await new Promise(r => setTimeout(r, 150));
    const rows = [...document.querySelectorAll('#findList .find-row')];
    return { open: !box.hidden, n: rows.length,
             first: rows[0] ? rows[0].textContent.replace(/\s+/g, ' ').trim() : '',
             foot: (document.querySelector('.find-foot') || {}).textContent || '' };
  });
  t(ui.open, 'دکمهٔ ذره‌بین کشو را باز می‌کند');
  t(ui.n === 1 && /هارد/.test(ui.first), 'و نتیجه را با نامِ بخش و ماهش نشان می‌دهد', ui.first);
  t(/دیتای شخصی/.test(ui.foot), 'و پایینش می‌گوید چه چیزی گشته نمی‌شود');

  /* زدنِ نتیجه: ماه عوض می‌شود و همان ردیف روشن می‌ماند */
  const jumped = await p.evaluate(async () => {
    document.querySelector('#findList .find-row').click();
    await new Promise(r => setTimeout(r, 900));
    return {
      month: state.currentMonthKey,
      view: (document.querySelector('.view.active') || {}).id,
      closed: document.getElementById('findBox').hidden,
      lit: !!document.querySelector('#checklistBody tr.find-hit')
    };
  });
  t(jumped.month === '1404|شهریور', 'زدنِ نتیجه، ماه را هم عوض می‌کند', jumped.month);
  t(jumped.view === 'view-checklist', 'و همان بخش را باز می‌کند', jumped.view);
  t(jumped.closed, 'و کشو بسته می‌شود');
  t(jumped.lit, 'و ردیفِ پیداشده یک لحظه روشن می‌ماند');

  /* Ctrl+K */
  const kb = await p.evaluate(async () => {
    document.dispatchEvent(new KeyboardEvent('keydown', { key: 'k', ctrlKey: true, bubbles: true }));
    await new Promise(r => setTimeout(r, 150));
    const o = !document.getElementById('findBox').hidden;
    document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));
    await new Promise(r => setTimeout(r, 150));
    return { o, c: document.getElementById('findBox').hidden };
  });
  t(kb.o && kb.c, 'Ctrl+K بازش می‌کند و Escape می‌بنددش');

  await p.close();
}

await b.close();
console.log('\nخطای صفحه: ' + (errs.length ? errs.join(' | ') : 'نداشت'));
t(errs.length === 0, 'هیچ خطای جاوااسکریپتی در صفحه نیفتاد');
console.log('\n' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
