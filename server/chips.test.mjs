/* دو کارِ ظاهری، و مرزی که نباید از آن گذشت.

   ۱) «اولویت» متنِ خامِ یک select بود در حالی که «وضعیت» چیپِ رنگی
      داشت — با اینکه رنگ‌هایش (pr-high/mid/low) سال‌ها در قالب نوشته
      شده بود و روی مسیرِ رسمِ دیگری می‌نشست که دیده نمی‌شد.

      و یک درسِ طراحی که وسطِ کار با عکس گرفتن درآمد: بارِ اول قابِ
      اولویت را هم رنگی کردم و بد شد — کنارِ «انجام نشده»ی قرمز، یک
      «بالا»ی قرمزِ قاب‌دار می‌نشست و ردیف دو آژیر داشت. حالا قاب خنثی
      است و فقط متن رنگ دارد: رنگِ پُر محورِ وضعیت است، اولویت فقط
      خوانده می‌شود. این آزمون همین مرز را نگه می‌دارد.

   ۲) در تقویم، ستونِ کنار یک کارتِ ۳۰۰ پیکسلی بود با یک جملهٔ راهنما
      تویش — یعنی یک‌پنجمِ عرضِ صفحه برای چیزی که هنوز حرفی ندارد. */
import { launch } from './pw.mjs';
import { readFileSync } from 'node:fs';

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

/* ================= یک جا نوشته شده، نه دو جا ================= */
console.log('===== بی‌تکرار =====');
{
  const part = readFileSync(new URL('../public/_t/p/selchipcss.tpl', import.meta.url), 'utf8');
  t(/select\.st-select/.test(part) && /select\.pr-select/.test(part),
    'شیوه‌نامهٔ هر دو چیپ در بخشِ مشترک است');
  for (const f of ['it.tpl', 'fin.tpl']) {
    const src = readFileSync(new URL('../public/_t/' + f, import.meta.url), 'utf8');
    t(!/select\.st-select\s*\{/.test(src), f + ': نسخهٔ محلیِ وضعیت را ندارد');
    t(/\{\{PART:selchipcss\}\}/.test(src), f + ': بخشِ مشترک را می‌آورد');
    t(/class="pr-select"/.test(src), f + ': و اولویتش کلاسِ چیپ را دارد');
  }
}

/* ================= چیپ‌ها در مرورگر ================= */
for (const [label, api, pass, path] of [
  ['کارتابلِ فنی', 'kartabl', process.env.VS_IT_PASS || 'siamaksiamak', '/siamak/'],
  ['کارتابلِ مالی', 'sina', process.env.VS_FIN_PASS || 'sinasinasina', '/sina/']
]) {
  console.log('===== ' + label + ' =====');
  const ctx = await b.newContext({ viewport: { width: 1500, height: 1000 } });
  await ctx.addCookies(await session(api, pass));
  const p = await ctx.newPage();
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 140)));
  await p.goto('http://' + HOST + ':' + PORT + path, { waitUntil: 'load' });
  await p.waitForTimeout(3600);
  await p.evaluate(() => {
    const x = document.querySelector('.nav-list .navbtn[data-view="checklist"]'); if (x) x.click();
  });
  await p.waitForTimeout(1500);

  const o = await p.evaluate(() => {
    const clear = c => c === 'rgba(0, 0, 0, 0)' || c === 'transparent';
    const pr = [...document.querySelectorAll('select.pr-select')];
    const st = [...document.querySelectorAll('select.st-select')];
    return {
      pr: pr.length, st: st.length,
      prHasData: pr.every(x => x.hasAttribute('data-pr')),
      prFilled: pr.filter(x => !clear(getComputedStyle(x).backgroundColor)).length,
      stFilled: st.filter(x => !clear(getComputedStyle(x).backgroundColor)).length,
      /* قابِ اولویت باید خنثی بماند: همان رنگی که یک اولویتِ بی‌مقدار
         دارد. اگر رنگی شود، همان دو-آژیرِ کنارِ هم برمی‌گردد. */
      prBorders: [...new Set(pr.map(x => getComputedStyle(x).borderTopColor))].length,
      prColors: [...new Set(pr.filter(x => x.value).map(x => getComputedStyle(x).color))].length,
      values: [...new Set(pr.map(x => x.value).filter(Boolean))]
    };
  });
  t(o.pr > 0, 'ستونِ اولویت چیپ دارد', o.pr + ' تا');
  t(o.prHasData, 'و هرکدام مقدارش را روی data-pr دارد — وگرنه CSS رنگ نمی‌بیند');
  t(o.stFilled === o.st && o.st > 0, 'وضعیت پُر است', o.stFilled + '/' + o.st);
  t(o.prFilled === 0, 'و اولویت پُر نیست — رنگِ پُر مالِ وضعیت است', o.prFilled + ' پُر');
  t(o.prBorders === 1, 'و قابِ اولویت در همهٔ ردیف‌ها یک‌رنگ و خنثی است',
    o.prBorders + ' رنگِ قاب');
  if (o.values.length > 1)
    t(o.prColors === o.values.length, 'و هر اولویت رنگِ متنِ خودش را دارد',
      o.values.join('، ') + ' → ' + o.prColors + ' رنگ');
  t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
  await ctx.close();
}

/* ================= تقویم ================= */
console.log('===== تقویم =====');
{
  const ctx = await b.newContext({ viewport: { width: 1440, height: 1000 } });
  await ctx.addCookies(await session('kartabl', process.env.VS_IT_PASS || 'siamaksiamak'));
  const p = await ctx.newPage();
  await p.goto('http://' + HOST + ':' + PORT + '/siamak/', { waitUntil: 'load' });
  await p.waitForTimeout(3600);
  await p.evaluate(() => document.querySelector('.nav-list .navbtn[data-view="cal"]').click());
  await p.waitForTimeout(1600);

  const read = () => p.evaluate(() => {
    const main = document.querySelector('.c2-main'), box = document.querySelector('.c2-box');
    const side = document.querySelector('.c2-side');
    return { nosel: main.classList.contains('c2-nosel'),
             calW: Math.round(box.getBoundingClientRect().width),
             sideBg: getComputedStyle(side).backgroundColor,
             sideBorder: getComputedStyle(side).borderTopWidth };
  });
  const before = await read();
  t(before.nosel, 'بی انتخابِ روز، ستونِ کنار جمع است');
  t(before.sideBorder === '0px', 'و دیگر کارتِ خالی نیست — بی قاب', before.sideBorder);

  const clicked = await p.evaluate(() => {
    const c = [...document.querySelectorAll('#calGrid .c2-cell')].find(x => x.textContent.trim());
    if (!c) return false; c.click(); return true;
  });
  t(clicked, 'روزی برای انتخاب هست');
  await p.waitForTimeout(900);
  const after = await read();
  t(!after.nosel, 'با انتخابِ روز، ستون برمی‌گردد');
  t(after.calW < before.calW, 'و تقویم بی‌انتخاب عریض‌تر است',
    before.calW + 'px → ' + after.calW + 'px');
  t(before.calW - after.calW >= 200, 'و این فرق واقعی است، نه چند پیکسل',
    (before.calW - after.calW) + 'px');
  await ctx.close();
}

await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
