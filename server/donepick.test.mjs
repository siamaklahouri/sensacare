/* «تاریخِ انجام» در برنامهٔ روزانه، دستی هم عوض می‌شود.

   تا امروز این خانه فقط خوانده می‌شد: همان لحظه که وضعیت «انجام شد»
   می‌خورد، تاریخِ امروز می‌افتاد و تمام. ولی کاری که دیروز تمام شده و
   امروز تیک می‌خورَد، تاریخِ امروز را می‌گیرد — و آن غلط است.

   حالا خانه تقویمِ شمسیِ همین برنامه را باز می‌کند، همان که ستونِ
   تاریخِ فاکتورها دارد.

   مرزها:
   • خودکاری سرِ جایش می‌ماند: «انجام شد» هنوز تاریخِ امروز را
     می‌گذارد، و بازکردنِ دوبارهٔ کار هنوز پاکش می‌کند.
   • تاریخِ دستی وضعیت را عوض نمی‌کند — از طرفِ کاربر تصمیم
     نمی‌گیریم.
   • این فقط برنامهٔ روزانهٔ خودِ کارتابل است. در بخش‌های مشترک
     (کارهای تیمی) همان قاعدهٔ سرور برقرار است: دستِ هیچ‌کس نیست.
     donedate.test.mjs همان را می‌سنجد. */
import { launch, calm } from './pw.mjs';
import { readFileSync } from 'node:fs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

console.log('===== سیم‌کشی =====');
for (const f of ['it.tpl', 'fin.tpl']) {
  const s = readFileSync(new URL('../public/_t/' + f, import.meta.url), 'utf8');
  t(/daily-done-cell[^]{0,160}data-field="doneDate" data-date/.test(s),
    f + ': خانهٔ تاریخِ انجام تقویم‌دار است');
  t(/\.daily-done-cell:empty::before\{ content:"—"/.test(s),
    f + ': و خط تیره از شیوه‌نامه می‌آید، نه از متنِ خانه',
    'وگرنه «—» ذخیره می‌شد');
  t(/else if\(el\.isContentEditable\) el\.addEventListener\("blur", onDayFieldChange\)/.test(s),
    f + ': blur شنیده می‌شود', 'contenteditable رویداد change نمی‌دهد');
}
/* قاعدهٔ بخش‌های مشترک دست‌نخورده مانده باشد */
{
  const sh = readFileSync(new URL('../src/shared.js', import.meta.url), 'utf8');
  t(/edit: *'never'/.test(sh) || /edit: *"never"/.test(sh),
    'و قاعدهٔ بخش‌های مشترک همان است که بود', "edit:'never'");
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
  const ctx = await b.newContext({ viewport: { width: 1400, height: 900 } });
  await ctx.addCookies(await cookiesFor(api, pass));
  const p = await ctx.newPage();
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
  await p.goto('http://' + HOST + ':' + PORT + path, { waitUntil: 'load' });
  await p.waitForTimeout(3800); await calm(p);
  await p.evaluate(() => { const x = document.querySelector('.navbtn[data-view="daily"]'); if (x) x.click(); });
  await p.waitForTimeout(900);

  await p.evaluate(() => {
    if (!state.days.length) addDayRow();
    state.days[0].main = 'کارِ آزمونِ تاریخ';
    state.days[0].status = '';
    state.days[0].doneDate = '';
    renderDaily();
  });
  await p.waitForTimeout(600);

  const cell = await p.evaluate(() => {
    const td = document.querySelector('#dailyBody .daily-done-cell');
    return td ? { ce: td.isContentEditable, host: td.classList.contains('dp-host'), txt: td.textContent } : null;
  });
  t(!!cell && cell.ce, 'خانه ویرایش‌پذیر است');
  t(!!cell && cell.host, 'و تقویم به آن وصل است');
  t(!!cell && cell.txt === '', 'و وقتی خالی است، متنش هم خالی است',
    JSON.stringify(cell ? cell.txt : null) + ' — خط تیره از شیوه‌نامه می‌آید');

  await p.click('#dailyBody .daily-done-cell');
  await p.waitForTimeout(500);
  t(await p.evaluate(() => {
    const e = document.querySelector('.dp-pop');
    return !!e && !e.hidden;
  }), 'کلیک، تقویمِ شمسی را باز می‌کند');

  const picked = await p.evaluate(() => {
    const d = [...document.querySelectorAll('.dp-d, .dp-day')].filter(x => x.textContent.trim());
    if (!d.length) return null;
    const pick = d[Math.min(9, d.length - 1)];
    const txt = pick.textContent.trim();
    pick.click();
    return txt;
  });
  await p.waitForTimeout(600);
  const after = await p.evaluate(() => ({
    saved: state.days[0].doneDate,
    shown: document.querySelector('#dailyBody .daily-done-cell').textContent,
    green: document.querySelector('#dailyBody .daily-done-cell').classList.contains('on'),
    status: state.days[0].status
  }));
  t(!!picked, 'روزی در تقویم بود که زده شود', picked || '—');
  t(/^[۰-۹]{4}\/[۰-۹]{2}\/[۰-۹]{2}$/.test(after.saved || ''),
    'و تاریخِ انتخاب‌شده ذخیره شد', JSON.stringify(after.saved));
  t(after.shown === after.saved, 'و همان روی صفحه نشست', after.shown);
  t(after.green, 'و خانه سبز شد، بی آنکه جدول از نو کشیده شود');
  t(after.status === '', 'و وضعیت دست‌نخورده ماند — از طرفِ کاربر تصمیم نمی‌گیریم',
    JSON.stringify(after.status));

  /* خودکاری سرِ جایش است: «انجام شد» تاریخِ امروز را می‌گذارد و
     بازکردنِ دوباره پاکش می‌کند. */
  await p.evaluate(() => {
    const sel = document.querySelector('#dailyBody tr[data-idx] select[data-field="status"]');
    sel.value = 'انجام شد';
    sel.dispatchEvent(new Event('change', { bubbles: true }));
  });
  await p.waitForTimeout(600);
  const done = await p.evaluate(() => ({ v: state.days[0].doneDate, today: fa(getTodayJalaliStr()) }));
  /* و تاریخِ *امروز*، نه آن تاریخی که یک لحظه پیش دستی گذاشته شد.
     رندرِ دوباره خانهٔ فوکوس‌دار را برمی‌دارد و blumِ آن خانه متنِ
     قدیمی را حمل می‌کند — اگر گارد نباشد، همان را دوباره می‌نویسد. */
  t(done.v === done.today, '«انجام شد» تاریخِ امروز را می‌گذارد',
    done.v + (done.v === done.today ? '' : ' ≠ ' + done.today));

  await p.evaluate(() => {
    const sel = document.querySelector('#dailyBody tr[data-idx] select[data-field="status"]');
    sel.value = 'در حال انجام';
    sel.dispatchEvent(new Event('change', { bubbles: true }));
  });
  await p.waitForTimeout(600);
  t(await p.evaluate(() => state.days[0].doneDate) === '',
    'و بازکردنِ دوبارهٔ کار هنوز پاکش می‌کند');

  t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
  await ctx.close();
}

await b.close();
console.log(ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
