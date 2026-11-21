/* یک کار، چند روز.

   چک‌لیستِ ماهانه یک ردیف را یک‌بار می‌گیرد و «مهلت»ِ هر ردیف یک
   روزِ ماه است. برای «هر چهارشنبه بکاپ را تست کن» باید چهار بار
   دکمهٔ افزودن را می‌زدی و چهار بار متن را می‌نوشتی.

   حالا یک بار می‌نویسی و روزها را روی تقویمِ همان ماه می‌زنی —
   سرستونِ «چ» همهٔ چهارشنبه‌ها را تیک می‌زند و بعد می‌شود یکی‌شان را
   برداشت.

   چیزهایی که این آزمون نگه می‌دارد:
   • روزِ هفته درست حساب شود. دو کارتابل یک تابع را دو شکل برمی‌گردانند
     (شیء و آرایه) و یکی‌شان بی‌صدا هیچ روزی را تیک نمی‌زد.
   • ردیف‌های ساخته‌شده تکرارِ ماهانه نداشته باشند: چهارشنبهٔ آبان،
     چهارشنبهٔ آذر نیست.
   • کلِ دسته با یک کلیک برگردد. */
import { launch, calm } from './pw.mjs';
import { readFileSync } from 'node:fs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

console.log('===== سیم‌کشی =====');
{
  const js = readFileSync(new URL('../public/_t/p/bulkadd.tpl', import.meta.url), 'utf8');
  const css = readFileSync(new URL('../public/_t/p/bulkaddcss.tpl', import.meta.url), 'utf8');
  t(!/<\/?(script|style)\b/i.test(js) && !/<!--/.test(js), 'جزوِ موتور تگ ندارد');
  t(!/<\/?(script|style)\b/i.test(css), 'جزوِ شیوه‌نامه تگ ندارد');
  t(/Array\.isArray\(g\)/.test(js),
    'هر دو شکلِ jalaliToGregorian پذیرفته می‌شود', 'شیء در فنی، آرایه در مالی');
  t(/every: 0/.test(js), 'ردیف‌ها تکرارِ ماهانه نمی‌گیرند');
  for (const f of ['it.tpl', 'fin.tpl']) {
    const s = readFileSync(new URL('../public/_t/' + f, import.meta.url), 'utf8');
    t(/id="bulkAddBtn"/.test(s), f + ': دکمه بالای چک‌لیست است');
    t(/BULKADD\.open\(\)/.test(s), f + ': و به همین جزو وصل است');
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

const b = await launch();
for (const [label, api, pass, path] of [
  ['کارتابلِ فنی', 'kartabl', process.env.VS_IT_PASS || 'siamaksiamak', '/siamak/'],
  ['کارتابلِ مالی', 'sina', process.env.VS_FIN_PASS || 'sinasinasina', '/sina/']
]) {
  console.log('===== ' + label + ' =====');
  const ctx = await b.newContext({ viewport: { width: 1300, height: 900 } });
  await ctx.addCookies(await cookiesFor(api, pass));
  const p = await ctx.newPage();
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
  await p.goto('http://' + HOST + ':' + PORT + path, { waitUntil: 'load' });
  await p.waitForTimeout(3800); await calm(p);
  await p.evaluate(() => { const x = document.querySelector('.navbtn[data-view="checklist"]'); if (x) x.click(); });
  await p.waitForTimeout(900);

  t(await p.evaluate(() => !!document.getElementById('bulkAddBtn')), 'دکمه روی صفحه است');
  await p.click('#bulkAddBtn');
  await p.waitForTimeout(500);

  const open = await p.evaluate(() => {
    const e = document.querySelector('.ba-box');
    return e ? { on: !e.hidden, days: e.querySelectorAll('.ba-d').length,
                 wd: e.querySelectorAll('.ba-w').length,
                 ttl: e.querySelector('.ba-m').textContent } : null;
  });
  t(!!open && open.on, 'و پنل را باز می‌کند');
  t(!!open && open.wd === 7, 'هفت روزِ هفته', open ? open.wd + '' : '—');
  t(!!open && open.days >= 29 && open.days <= 31,
    'و روزهای همین ماه، نه بیشتر و نه کمتر', open ? open.days + ' روز — ' + open.ttl : '—');

  /* همان ماهی که چک‌لیست نشان می‌دهد، نه ماهِ امروز */
  const meta = await p.evaluate(() => (state.meta || {}).month + ' ' + (state.meta || {}).year);
  t(!!open && open.ttl.indexOf(String(meta).split(' ')[0]) >= 0,
    'و همان ماهی است که چک‌لیست باز کرده', open ? open.ttl + ' ← ' + meta : '—');

  const n0 = await p.evaluate(() => state.tasks.length);
  await p.fill('.ba-task', 'کارِ آزمونِ هفتگی');

  /* سرستونِ «چ» = چهارشنبه */
  await p.evaluate(() => { [...document.querySelectorAll('.ba-w')][4].click(); });
  await p.waitForTimeout(400);
  const sum = await p.evaluate(() => ({
    txt: document.querySelector('.ba-sum').textContent,
    on: [...document.querySelectorAll('.ba-d.on')].map(x => x.textContent.trim()),
    wOn: document.querySelectorAll('.ba-w.on').length
  }));
  t(sum.on.length >= 4, 'زدنِ «چ» همهٔ چهارشنبه‌ها را تیک زد', sum.on.join('، '));
  t(sum.wOn === 1, 'و خودِ «چ» هم پر شد');

  /* و درست‌بودنِ روزها: هر روزِ تیک‌خورده باید واقعاً چهارشنبه باشد */
  const right = await p.evaluate(list => {
    const fa = s => String(s).replace(/[۰-۹]/g, d => '۰۱۲۳۴۵۶۷۸۹'.indexOf(d));
    const jm = JALALI_MONTH_NAMES.indexOf(String((state.meta || {}).month || '')) + 1;
    const jy = parseInt((state.meta || {}).year, 10);
    return list.map(s => +fa(s)).every(d => {
      const g = jalaliToGregorian(jy, jm, d);
      const a = Array.isArray(g);
      const w = new Date(a ? g[0] : g.gy, (a ? g[1] : g.gm) - 1, a ? g[2] : g.gd).getDay();
      return (w + 1) % 7 === 4;
    });
  }, sum.on);
  t(right, 'و هر کدامشان واقعاً چهارشنبه‌اند');

  /* یکی را برمی‌داریم: دستی هم می‌شود */
  await p.evaluate(() => { document.querySelector('.ba-d.on').click(); });
  await p.waitForTimeout(300);
  const less = await p.evaluate(() => ({
    n: document.querySelectorAll('.ba-d.on').length,
    wOn: document.querySelectorAll('.ba-w.on').length
  }));
  t(less.n === sum.on.length - 1, 'و می‌شود یکی را دستی برداشت', less.n + '');
  t(less.wOn === 0, 'آن‌وقت «چ» دیگر پر نیست — چون همه‌اش نیست');

  await p.evaluate(() => document.querySelector('.ba-go').click());
  await p.waitForTimeout(800);
  const made = await p.evaluate(n => {
    const made = state.tasks.slice(n);
    return {
      count: made.length,
      names: made.every(x => x.task === 'کارِ آزمونِ هفتگی'),
      every: made.every(x => x.every === 0),
      days: made.map(x => x.deadline),
      closed: !!document.querySelector('.ba-box[hidden]'),
      bar: !!document.querySelector('.undo-bar:not([hidden])')
    };
  }, n0);
  t(made.count === less.n, 'به‌تعدادِ روزها ردیف ساخت', made.count + ' ردیف');
  t(made.names, 'همه با همان متن');
  t(made.days.join(',') === made.days.slice().sort((a, c) => a - c).join(','),
    'و به ترتیبِ روز', made.days.join('، '));
  t(made.every, 'و هیچ‌کدام تکرارِ ماهانه ندارند — چهارشنبهٔ این ماه، چهارشنبهٔ ماهِ بعد نیست');
  t(made.closed, 'پنل بسته شد');
  t(made.bar, 'و نوارِ برگرداندن آمد');

  await p.evaluate(() => document.querySelector('.ub-go').click());
  await p.waitForTimeout(600);
  t(await p.evaluate(() => state.tasks.length) === n0,
    'و کلِ دسته با یک کلیک برگشت');

  /* بی‌متن چیزی ساخته نمی‌شود */
  await p.click('#bulkAddBtn');
  await p.waitForTimeout(400);
  await p.evaluate(() => { [...document.querySelectorAll('.ba-w')][4].click(); });
  await p.waitForTimeout(300);
  await p.evaluate(() => document.querySelector('.ba-go').click());
  await p.waitForTimeout(400);
  t(await p.evaluate(() => state.tasks.length) === n0, 'بی‌نوشتنِ متن، ردیفی ساخته نمی‌شود');
  await p.evaluate(() => document.querySelector('.ba-x').click());
  await p.waitForTimeout(300);
  t(await p.evaluate(() => !!document.querySelector('.ba-box[hidden]')), '«بی‌خیال» پنل را می‌بندد');

  t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
  await ctx.close();
}

await b.close();
console.log(ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
