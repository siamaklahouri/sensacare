/* مناسبت‌های تقویم.

   تقویم تعطیلی‌ها را داشت ولی مناسبت‌ها را نه — «روز حسابدار»،
   «روز مهندس»، «روز معلم». کاربر خواستشان، و یک نکتهٔ ظریف تویش
   هست که اگر رعایت نشود تقویم دروغ می‌گوید:

   **مناسبت تعطیل نیست.** پانزدهم آذر روز حسابدار است و یک روزِ
   کاریِ کامل. اگر مثل تعطیلی‌ها نشان داده می‌شد — خانهٔ قرمز، شمارشِ
   روزهای کاری یکی کم — برنامهٔ ماه خراب می‌شد.

   پس این آزمون دو چیز را با هم نگه می‌دارد: مناسبت دیده شود، و
   هیچ‌جا به حسابِ تعطیلی گذاشته نشود. */
import { launch } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

async function session(api, pass) {
  const r = await fetch(BASE + '/api/' + api + '/login', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST },
    body: JSON.stringify({ password: pass }) });
  return (r.headers.getSetCookie ? r.headers.getSetCookie() : []).map(c => {
    const kv = c.split(';')[0];
    return { name: kv.split('=')[0], value: kv.slice(kv.indexOf('=') + 1), domain: HOST, path: '/' };
  });
}

const b = await launch();
const ctx = await b.newContext({ viewport: { width: 1440, height: 1000 } });
await ctx.addCookies(await session('kartabl', process.env.VS_IT_PASS || 'siamaksiamak'));
const p = await ctx.newPage();
const errs = [];
p.on('pageerror', e => errs.push(String(e).slice(0, 140)));
await p.goto('http://' + HOST + ':' + PORT + '/siamak/', { waitUntil: 'load' });
await p.waitForTimeout(3800);

console.log('===== جدول =====');
{
  const o = await p.evaluate(() => {
    const C = window.CAL || null;
    if (!C || !C.occasion) return null;
    return {
      count: Object.keys(C.events || {}).length,
      hesabdar: C.occasion(1405, 9, 15),
      mohandes: C.occasion(1405, 12, 5),
      moalem: C.occasion(1405, 2, 12),
      pezeshk: C.occasion(1405, 6, 1),
      empty: C.occasion(1405, 9, 14)
    };
  });
  if (!o) { t(false, 'تقویم تابعِ مناسبت را بیرون نمی‌دهد'); }
  else {
    t(o.count >= 20, 'جدولِ مناسبت‌ها پُر است', o.count + ' مناسبت');
    t(o.hesabdar === 'روز حسابدار', '۱۵ آذر روز حسابدار است', o.hesabdar || '—');
    t(o.mohandes === 'روز مهندس', '۵ اسفند روز مهندس', o.mohandes || '—');
    t(o.moalem === 'روز معلم', '۱۲ اردیبهشت روز معلم', o.moalem || '—');
    t(o.pezeshk === 'روز پزشک', '۱ شهریور روز پزشک', o.pezeshk || '—');
    t(o.empty === '', 'و روزِ بی‌مناسبت چیزی برنمی‌گرداند', JSON.stringify(o.empty));
  }
}

console.log('===== مناسبت تعطیل نیست =====');
{
  /* همان نکته‌ای که اگر از دست برود تقویم دروغ می‌گوید. */
  const o = await p.evaluate(() => {
    const C = window.CAL;
    const days = [[9, 15], [12, 5], [2, 12], [6, 1], [9, 16]];
    return days.map(([m, d]) => {
      const h = C.holiday(1405, m, d);
      return { m, d, off: h.off, name: h.name, ev: C.occasion(1405, m, d) };
    });
  });
  for (const x of o) {
    /* جمعه‌ها تعطیل‌اند و ربطی به مناسبت ندارند؛ آن‌ها را کنار
       می‌گذاریم وگرنه آزمون به تقویمِ یک سالِ خاص گره می‌خورد. */
    if (/جمعه/.test(x.name)) continue;
    t(!x.off, x.m + '/' + x.d + ' (' + x.ev + ') تعطیل حساب نمی‌شود',
      x.off ? 'تعطیل شد: ' + x.name : 'کاری');
    t(!new RegExp(x.ev).test(x.name || ''),
      'و نامش توی فهرستِ تعطیلی نرفته', x.name || '—');
  }
}

console.log('===== روی صفحه =====');
{
  await p.evaluate(() => document.querySelector('.nav-list .navbtn[data-view="cal"]').click());
  await p.waitForTimeout(1300);
  /* می‌رویم به آذر، ماهی که روز حسابدار تویش است. «CAL.go» کارِ
     دیگری می‌کند (رفتن به برنامهٔ روزانه)، پس با دکمهٔ ماه جلو
     می‌رویم — همان کاری که کاربر می‌کند. */
  for (let i = 0; i < 14; i++) {
    const at = await p.evaluate(() => (document.getElementById('calTtl') || {}).textContent || '');
    if (/آذر/.test(at)) break;
    await p.evaluate(() => document.querySelector('[data-cal-step="1"]').click());
    await p.waitForTimeout(220);
  }
  await p.waitForTimeout(900);

  const o = await p.evaluate(() => {
    const evs = [...document.querySelectorAll('#calGrid .c2-ev')];
    const cell = [...document.querySelectorAll('#calGrid .c2-cell')]
      .find(c => /حسابدار/.test(c.textContent));
    return {
      month: (document.getElementById('calTtl') || {}).textContent || '',
      count: evs.length,
      texts: evs.slice(0, 4).map(e => e.textContent.trim()),
      cellIsOff: cell ? cell.classList.contains('off') : null,
      cellTitle: cell ? cell.getAttribute('title') : null,
      color: evs.length ? getComputedStyle(evs[0]).color : '',
      holColor: (() => { const h = document.querySelector('#calGrid .c2-hol');
        return h ? getComputedStyle(h).color : ''; })()
    };
  });
  t(/آذر/.test(o.month), 'رفتیم به آذر', o.month);
  t(o.count > 0, 'و مناسبت‌ها روی خانه‌ها دیده می‌شوند', o.count + ' خانه');
  t(o.texts.some(x => /حسابدار/.test(x)), 'و روز حسابدار تویشان است', o.texts.join('، '));
  t(o.cellIsOff === false, 'و خانه‌اش قرمزِ تعطیلی نیست', 'off=' + o.cellIsOff);
  t(/حسابدار/.test(o.cellTitle || ''), 'و راهنمای موشواره‌اش هم می‌گوید', o.cellTitle || '—');
  if (o.holColor)
    t(o.color !== o.holColor, 'و رنگش با رنگِ تعطیلی یکی نیست',
      'مناسبت ' + o.color + ' ≠ تعطیلی ' + o.holColor);
}

console.log('===== پنجرهٔ کنار =====');
{
  const got = await p.evaluate(() => {
    const cell = [...document.querySelectorAll('#calGrid .c2-cell')]
      .find(c => /حسابدار/.test(c.textContent));
    if (!cell) return null;
    cell.click();
    return true;
  });
  t(got, 'روی روزِ مناسبت کلیک شد');
  await p.waitForTimeout(700);
  const side = await p.evaluate(() => {
    const e = document.querySelector('#calSide .c2-sh-e');
    const btn = document.getElementById('calOffBtn');
    return { ev: e ? e.textContent.trim() : '',
             btn: btn ? btn.textContent.trim() : '' };
  });
  t(/حسابدار/.test(side.ev), 'و پنجرهٔ کنار مناسبت را می‌گوید', side.ev || '—');
  t(/این روز تعطیل است/.test(side.btn),
    'و دکمه هنوز پیشنهادِ تعطیل کردن می‌دهد — یعنی تعطیل نیست', side.btn || '—');
}

t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
