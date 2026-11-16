/* سه چیزِ کوچک که هر روز دیده می‌شوند.

   ۱) «برنامهٔ روزانه» تا سی‌ویک ردیف دارد و هیچ‌کدام نمی‌گفت کدام
      امروز است. تقویم این را از قبل داشت (قابِ دورِ خانهٔ امروز) و
      جدول نداشت — یعنی در پرکاربردترین بخش، آدم باید چشم می‌چرخاند.

   ۲) متنِ راهنمای سه ستون در تمامِ ردیف‌های خالی تکرار می‌شد: روی
      یک ماهِ سی‌ویک‌روزه نود بار روی یک صفحه. راهنما جایی لازم است
      که آدم می‌خواهد تویش بنویسد، نه همه‌جا.

   ۳) جدولِ خالی فقط یک سربرگ بود و یک صفحهٔ سفید — همان چیزی که
      کاربرِ تازه اول می‌بیند.

   این آزمون هر سه را در هر دو کارتابل می‌سنجد، و مرزشان را هم:
   ردیفی که امروز نیست نباید نشانه بگیرد، و جدولی که داده دارد
   نباید پیامِ «خالی» بدهد. */
import { launch, calm } from './pw.mjs';
import { readFileSync } from 'node:fs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

console.log('===== سیم‌کشی =====');
{
  const css = readFileSync(new URL('../public/_t/p/tidycss.tpl', import.meta.url), 'utf8');
  t(!/<\/?(script|style)\b/i.test(css), 'جزوِ شیوه‌نامه تگ ندارد');
  t(/tr\.is-today/.test(css) && /\.today-tag/.test(css), 'کلاس‌های ردیفِ امروز هست');
  t(/\.tbl-empty/.test(css), 'و کلاسِ جدولِ خالی');
  t(/prefers-reduced-motion/.test(css), 'و چشمک با prefers-reduced-motion خاموش می‌شود');
  const tpls = readFileSync(new URL('../src/templates.js', import.meta.url), 'utf8');
  t(/\['tidycss', *p_tidycss\]/.test(tpls), 'جزو ثبت شده است');
  for (const f of ['it.tpl', 'fin.tpl']) {
    const src = readFileSync(new URL('../public/_t/' + f, import.meta.url), 'utf8');
    t(/\{\{PART:tidycss\}\}/.test(src), f + ': جزو را می‌آورد');
    t(/class="is-today"/.test(src), f + ': ردیفِ امروز نشانه می‌گیرد');
    t(/tbl-empty/.test(src), f + ': جدولِ خالی پیام دارد');
  }
  const dj = readFileSync(new URL('../public/_t/p/dayjump.tpl', import.meta.url), 'utf8');
  t(/امروز/.test(dj) && /tr\.is-today/.test(dj), 'دکمهٔ «امروز» در نوارِ پرش هست');
}

async function cookiesFor(api, pass) {
  const r = await fetch(BASE + '/api/' + api + '/login', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST }, body: JSON.stringify({ password: pass }) });
  return (r.headers.getSetCookie ? r.headers.getSetCookie() : []).map(c => {
    const kv = c.split(';')[0];
    return { name: kv.split('=')[0], value: kv.slice(kv.indexOf('=') + 1), domain: HOST, path: '/' };
  });
}

const b = await launch();
for (const [label, api, pass, path] of [
  ['کارتابلِ فنی', 'kartabl', process.env.VS_IT_PASS || 'siamaksiamak', '/siamak/'],
  ['کارتابلِ مالی', 'sina', process.env.VS_FIN_PASS || 'sinasinasina', '/sina/']
]) {
  console.log('===== ' + label + ' =====');
  const ctx = await b.newContext({ viewport: { width: 1500, height: 1000 } });
  await ctx.addCookies(await cookiesFor(api, pass));
  const p = await ctx.newPage();
  const errs = [];
  p.on('dialog', d => d.accept());
  p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
  await p.goto('http://' + HOST + ':' + PORT + path, { waitUntil: 'load' });
  await p.waitForTimeout(3800); await calm(p);

  /* یک ردیفِ امروز و یک ردیفِ کهنه. ردیف‌های پیشین پاک می‌شوند تا
     شمارش‌ها معنا داشته باشند. */
  await p.evaluate(() => {
    const today = getTodayJalaliStr();
    state.days = [
      { day: 1, createdDate: '1404/01/01', main: 'کارِ کهنه', meet: '', company: '', status: 'انجام شد', doneDate: '' },
      { day: 2, createdDate: today, main: '', meet: '', company: '', status: '', doneDate: '' },
      { day: 3, createdDate: '1404/01/02', main: '', meet: '', company: '', status: '', doneDate: '' }
    ];
    renderDaily();
  });
  await p.evaluate(() => { const x = document.querySelector('.navbtn[data-view="daily"]'); if (x) x.click(); });
  await p.waitForTimeout(1100);

  const o = await p.evaluate(() => {
    const rows = [...document.querySelectorAll('#dailyBody tr')];
    const todayRow = document.querySelector('#dailyBody tr.is-today');
    const cs = todayRow ? getComputedStyle(todayRow.querySelector('td')) : null;
    return {
      rows: rows.length,
      marked: rows.filter(r => r.classList.contains('is-today')).length,
      tag: document.querySelectorAll('#dailyBody .today-tag').length,
      hintRows: rows.filter(r => r.querySelector('input[placeholder]')).length,
      hints: document.querySelectorAll('#dailyBody input[placeholder]').length,
      tinted: cs ? cs.backgroundColor : '',
      plainTinted: (() => {
        const other = rows.find(r => !r.classList.contains('is-today'));
        return other ? getComputedStyle(other.querySelector('td')).backgroundColor : '';
      })(),
      btn: [...document.querySelectorAll('#view-daily .day-jump button')]
        .some(x => /امروز/.test(x.textContent))
    };
  });
  t(o.rows === 3, 'سه ردیف روی صفحه است', o.rows + '');
  t(o.marked === 1, 'فقط ردیفِ امروز نشانه گرفت', o.marked + ' ردیف');
  t(o.tag === 1, 'و برچسبِ «امروز» یکی است', o.tag + '');
  t(o.tinted !== o.plainTinted, 'و زمینه‌اش با بقیه فرق دارد', o.tinted + ' ≠ ' + o.plainTinted);
  t(o.hintRows === 1, 'متنِ راهنما فقط در یک ردیف است', o.hintRows + ' ردیف');
  t(o.hints === 3, 'و همان سه ستون', o.hints + ' خانه');
  t(o.btn, 'دکمهٔ «امروز» در نوارِ بالای جدول هست');

  /* دکمه: می‌رود و چشمک می‌زند */
  await p.evaluate(() => {
    const x = [...document.querySelectorAll('#view-daily .day-jump button')].find(z => /امروز/.test(z.textContent));
    if (x) x.click();
  });
  await p.waitForTimeout(500);
  t(await p.evaluate(() => document.querySelectorAll('#dailyBody tr.row-flash').length === 1),
    'و ردیفِ امروز چشمک می‌زند');

  /* جدولِ پُر نباید پیامِ «خالی» بدهد */
  t(await p.evaluate(() => !document.querySelector('#dailyBody tr.tbl-empty')),
    'جدولی که داده دارد پیامِ خالی نمی‌دهد');

  /* و حالا خالی */
  await p.evaluate(() => {
    state.days = []; state.tasks = [];
    if (typeof renderAll === 'function') renderAll(); else renderEverything();
  });
  await p.waitForTimeout(800);
  const e = await p.evaluate(() => ({
    daily: (document.querySelector('#dailyBody .te-h') || {}).textContent || '',
    chk: (document.querySelector('#checklistBody .te-h') || {}).textContent || '',
    dailyCols: (document.querySelector('#dailyBody .tbl-empty td') || {}).getAttribute
      ? +document.querySelector('#dailyBody .tbl-empty td').getAttribute('colspan') : 0,
    heads: document.querySelectorAll('#view-daily thead tr:first-child th').length
  }));
  t(/خالی/.test(e.daily), 'برنامهٔ خالی پیام دارد', e.daily || '—');
  t(/چک‌لیست/.test(e.chk), 'چک‌لیستِ خالی هم', e.chk || '—');
  t(e.dailyCols >= e.heads, 'و پیام تمامِ پهنای جدول را می‌گیرد',
    e.dailyCols + ' از ' + e.heads + ' ستون');

  t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
  await ctx.close();
}

await b.close();
console.log(ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
