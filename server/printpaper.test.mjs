/* آنچه روی کاغذ می‌افتد.

   گزارش شد: «چاپ‌ها خیلی بد است، تو کل سایت». هر بخش رندر شد و با
   خودِ صفحه مقایسه — نه چشمی، بلکه خانه‌به‌خانه.

   چهار چیزِ واقعی پیدا شد:

   ۱) ستونِ «مهلت» کاملاً خالی می‌رفت. چیپِ تاریخ یک <button> است و
      قاعدهٔ چاپ همهٔ دکمه‌ها را برمی‌داشت — دکمه‌ای که داده داشت، نه
      کار. در جدولی که نصفِ معنایش همان تاریخ است.

   ۲) ردیفِ افزودن چاپ می‌شد: یک فرمِ خالی ته هر جدول، با یک «+» و
      کشویی‌هایی که مقدارِ پیش‌فرضشان را نشان می‌دادند. قاعدهٔ قدیمی
      «addrow» را می‌گرفت و نامِ واقعی «add-row» است.

   ۳) جهتِ کاغذ از یک فهرستِ دستی می‌آمد که هیچ جدولِ مالی در آن
      نبود: فاکتورها با ده ستون روی کاغذِ ایستاده می‌رفتند.

   ۴) ستون‌های بی‌اسم و خالی (📎 پیوست، ⭐ ستاره، کلیدِ حذف/تغییر)
      روی کاغذ یک ردیف شکلکِ بی‌فایده می‌شدند.

   و دو تای دیگر که بعداً گزارش شد:

   ۵) نمودارها نیمه‌کشیده می‌افتادند. Chart.js با انیمیشن می‌کشد و
      ما ۱۴۰ میلی‌ثانیه بعد چاپ می‌کردیم — درست وسطِ همان کشیدن.

   ۶) کارت‌های آمار نامرئی چاپ می‌شدند: «animation:statIn backwards»
      یعنی فریمِ صفرشان شفاف است، و چیدمانِ کاغذ انیمیشن را از نو
      شروع می‌کرد. */
import { launch, calm } from './pw.mjs';
import { readFileSync } from 'node:fs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

console.log('===== سیم‌کشی =====');
{
  const css = readFileSync(new URL('../public/_t/p/printanycss.tpl', import.meta.url), 'utf8');
  const js = readFileSync(new URL('../public/_t/p/printany.tpl', import.meta.url), 'utf8');
  t(/\.kb-print tr\.add-row/.test(css), 'ردیفِ افزودن با نامِ درستش شناخته می‌شود',
    'add-row، نه addrow');
  t(/\.kb-print \.date-box\{/.test(css), 'چیپِ مهلت قابِ دکمه‌ای‌اش را روی کاغذ از دست می‌دهد');
  t(/colCount/.test(js) && /WIDE_COLS/.test(js), 'جهتِ کاغذ از شمارِ ستون‌ها می‌آید');
  t(/dh-clock/.test(css), 'ساعتِ زنده روی کاغذ نمی‌رود');
  for (const f of ['it.tpl', 'fin.tpl']) {
    const s = readFileSync(new URL('../public/_t/' + f, import.meta.url), 'utf8');
    t(/class="date-box keep-print/.test(s), f + ': چیپِ مهلت نشانِ ماندن دارد');
  }
}

async function cookiesFor(api, pass) {
  const r = await fetch(BASE + '/api/' + api + '/login', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST }, body: JSON.stringify({ password: pass }) });
  return (r.headers.getSetCookie ? r.headers.getSetCookie() : []).map(c => {
    const kv = c.split(';')[0];
    return { name: kv.split('=')[0], value: kv.slice(kv.indexOf('=') + 1), domain: HOST, path: '/' };
  });
}

/* متنِ دیده‌شدنیِ هر خانه — همان چیزی که روی کاغذ می‌افتد */
const readCells = (p, id) => p.evaluate(i => {
  const v = document.getElementById(i);
  if (!v) return [];
  const out = [];
  v.querySelectorAll('table').forEach((tb, ti) => {
    tb.querySelectorAll('tr').forEach((tr, ri) => {
      [...tr.children].forEach((td, ci) => {
        const st = getComputedStyle(td);
        const hidden = st.display === 'none' || st.visibility === 'hidden';
        let txt = '';
        const f = td.querySelector('input:not([type=checkbox]):not([type=radio]),select,textarea');
        if (f && getComputedStyle(f).display !== 'none') txt = (f.value || '').trim();
        else txt = (td.innerText || '').replace(/\s+/g, ' ').trim();
        out.push({ k: ti + '/' + ri + '/' + ci, hidden, txt });
      });
    });
  });
  return out;
}, id);

const b = await launch();
for (const [label, api, pass, path, view] of [
  ['کارتابلِ فنی', 'kartabl', process.env.VS_IT_PASS || 'siamaksiamak', '/siamak/', 'checklist'],
  ['کارتابلِ مالی', 'sina', process.env.VS_FIN_PASS || 'sinasinasina', '/sina/', 'checklist']
]) {
  console.log('===== ' + label + ' =====');
  const ctx = await b.newContext({ viewport: { width: 1400, height: 900 } });
  await ctx.addCookies(await cookiesFor(api, pass));
  const p = await ctx.newPage();
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
  await p.goto('http://' + HOST + ':' + PORT + path, { waitUntil: 'load' });
  await p.waitForTimeout(3800); await calm(p);
  await p.evaluate(v => { const x = document.querySelector('.navbtn[data-view="' + v + '"]'); if (x) x.click(); }, view);
  await p.waitForTimeout(900);

  /* دستِ‌کم یک ردیف با مهلت لازم داریم */
  await p.evaluate(() => {
    /* کارتابلِ مالیِ آزمون ممکن است چک‌لیستِ خالی داشته باشد */
    if (!state.tasks.length)
      state.tasks.push({ category: '', task: 'کارِ آزمونِ چاپ', owner: '', deadline: 7,
        status: 'انجام نشده', priority: 'متوسط', note: '', rid: 'pp-1', since: '', every: 0 });
    state.tasks[0].deadline = 7;
    if (typeof renderAll === 'function') renderAll();
    else if (typeof renderChecklist === 'function') renderChecklist();
  });
  await p.waitForTimeout(600);

  const before = await readCells(p, 'view-' + view);
  t(before.length > 0, 'جدولِ چک‌لیست روی صفحه هست', before.length + ' خانه');

  await p.evaluate(() => { window.print = function () { }; try { localStorage.removeItem('kb-print-orient-v1'); } catch (e) { } });
  await p.emulateMedia({ media: 'print' });
  await p.evaluate(() => kbPrint(document.getElementById('view-checklist')));
  await p.waitForTimeout(600);
  const guess = await p.evaluate(() => {
    const on = document.querySelector('.ko-opt.on');
    return on ? on.getAttribute('data-o') : '';
  });
  t(guess === 'landscape', 'جدولِ پهن، کاغذِ خوابیده پیشنهاد می‌شود', guess);
  await p.evaluate(() => { const ov = document.querySelector('.kb-orient-ov'); if (ov) ov.querySelector('.ko-go').click(); });
  await p.waitForTimeout(1200);

  const after = await readCells(p, 'view-' + view);
  const m = new Map(after.map(x => [x.k, x]));
  /* چه چیزی روی صفحه بود و روی کاغذ نیست؟ دکمه‌ها باید بروند،
     داده نباید. */
  const CONTROLS = /^(✕|🗑|📎|☆|⭐|⏰|📝|✏️|🔁|افزودن|\+|＋)$/;
  const lost = before.filter(x => x.txt && !x.hidden)
    .filter(x => { const a = m.get(x.k); return !a || a.hidden || !a.txt; })
    .filter(x => !CONTROLS.test(x.txt));
  t(lost.length === 0, 'هیچ داده‌ای روی کاغذ گم نشد',
    lost.slice(0, 4).map(x => x.txt.slice(0, 26)).join(' | ') || 'هیچ');

  const paper = await p.evaluate(() => {
    const v = document.getElementById('view-checklist');
    const vis = el => { const s = getComputedStyle(el); return s.display !== 'none' && s.visibility !== 'hidden'; };
    const row = v.querySelector('tr.add-row');
    const chip = v.querySelector('.date-box');
    const toggle = v.querySelector('.edit-toggle-wrap, .del-toggle-wrap');
    return {
      addRow: !row || !vis(row),
      chip: !!chip && vis(chip),
      chipText: chip ? (chip.innerText || '').replace(/\s+/g, ' ').trim() : '',
      chipBorder: chip ? getComputedStyle(chip).borderTopWidth : '',
      toggleCol: !toggle || !vis(toggle.closest('th') || toggle),
      btns: [...v.querySelectorAll('button:not(.keep-print)')].filter(vis).length
    };
  });
  t(paper.addRow, 'ردیفِ افزودن روی کاغذ نمی‌رود');
  t(paper.chip, 'ولی چیپِ مهلت می‌ماند', paper.chipText);
  t(/^[۰-۹]/.test(paper.chipText), 'و خودِ عدد را می‌گوید، بی شکلکِ تقویم', paper.chipText);
  t(paper.chipBorder === '0px', 'و قابِ دکمه‌ای ندارد', paper.chipBorder);
  t(paper.toggleCol, 'ستونِ کلیدِ «حذف/تغییر» برداشته می‌شود');
  t(paper.btns === 0, 'و هیچ دکمهٔ دیگری روی کاغذ نیست', paper.btns + ' دکمه');

  /* ---- نمودارها و حرکت ---- */
  await p.evaluate(() => { try { if (window.KBPRINT) KBPRINT = KBPRINT; } catch (e) { } });
  await p.emulateMedia({ media: null });
  await p.reload({ waitUntil: 'load' });
  await p.waitForTimeout(2800); await calm(p);
  await p.evaluate(() => {
    const x = document.querySelector('.navbtn[data-view="dashboard"]'); if (x) x.click();
  });
  await p.waitForTimeout(900);
  await p.evaluate(() => {
    window.__snap = null;
    window.print = function () {
      const out = [];
      /* فقط بوم‌هایی که واقعاً روی کاغذ می‌روند: نمودارِ بی‌داده
         اصلاً چاپ نمی‌شود و بومِ پنهان هم اندازه ندارد. */
      [...document.querySelectorAll('.kb-print canvas')].filter(cv => {
        if (cv.getAttribute('data-empty') === '1') return false;
        if (!cv.width || !cv.height) return false;
        const box = cv.closest('.panel') || cv;
        return getComputedStyle(box).display !== 'none' && cv.offsetParent !== null;
      }).forEach(cv => {
        let c = null; try { c = Chart.getChart(cv); } catch (e) { }
        let ink = -1;
        try {
          const g = cv.getContext('2d');
          const d = g.getImageData(0, 0, cv.width, cv.height).data;
          let n = 0; for (let i = 3; i < d.length; i += 148) if (d[i] > 8) n++;
          ink = n;
        } catch (e) { }
        out.push({ anim: String((window.Chart && Chart.defaults) ? Chart.defaults.animation : '?'), busy: (c && c.$animations) ? Object.keys(c.$animations).length : -1, ink });
      });
      const card = document.querySelector('.kb-print .stat');
      window.__snap = { charts: out, cardOpacity: card ? getComputedStyle(card).opacity : '',
                        cardAnim: card ? getComputedStyle(card).animationName : '' };
    };
    try { localStorage.removeItem('kb-print-orient-v1'); } catch (e) { }
  });
  await p.emulateMedia({ media: 'print' });
  await p.evaluate(() => kbPrint(document.getElementById('view-dashboard')));
  await p.waitForTimeout(700);
  await p.evaluate(() => { const ov = document.querySelector('.kb-orient-ov'); if (ov) ov.querySelector('.ko-go').click(); });
  await p.waitForTimeout(2200);
  const snap = await p.evaluate(() => window.__snap);
  t(!!snap, 'چاپِ داشبورد راه افتاد');
  if (snap) {
    t(snap.charts.length > 0, 'نمودار روی کاغذ هست', snap.charts.length + ' تا');
    t(snap.charts.every(c => c.anim === 'false'),
      'و انیمیشنِ نمودارها پیش از چاپ خاموش است', JSON.stringify(snap.charts.map(c => c.anim)));
    t(snap.charts.every(c => c.busy <= 0),
      'و هیچ‌کدام وسطِ کشیدن نیستند', JSON.stringify(snap.charts.map(c => c.busy)));
    t(snap.charts.every(c => c.ink > 20),
      'و همه واقعاً کشیده شده‌اند، نه نصفه', JSON.stringify(snap.charts.map(c => c.ink)));
    t(snap.cardOpacity === '1', 'کارت‌های آمار نامرئی چاپ نمی‌شوند', 'شفافیت ' + snap.cardOpacity);
    t(snap.cardAnim === 'none', 'چون روی کاغذ هیچ‌چیز حرکت نمی‌کند', snap.cardAnim);
  }
  await p.emulateMedia({ media: null });

  t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
  await ctx.close();
}

await b.close();
console.log(ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
