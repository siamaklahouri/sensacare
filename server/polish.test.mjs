/* صیقلِ ظاهر — سه چیزی که با اندازه‌گیری سنجیده می‌شود، نه با سلیقه.

   ۱) جای ایستادنِ صفحه‌کلید. خانه‌های جدول «outline:none» داشتند و
      روی فوکوس فقط یک قابِ یک‌پیکسلی عوض می‌شد. با Tab عملاً هیچ‌چیز
      دیده نمی‌شد. حلقهٔ تازه با :focus-visible می‌آید، پس با کلیکِ
      موشواره شلوغی اضافه نمی‌کند.

      این سنجه یک بار خودش را ثابت کرد: نسخهٔ اولِ قاعده وزنش از
      «outline:none»ِ موجود کمتر بود و بی‌صدا بی‌اثر ماند. چشم
      نمی‌فهمید؛ اندازه‌گیری فهمید.

   ۲) در هر ردیف فقط یک چیزِ پُر. «انجام نشده»ی قرمزِ پُر و چیپِ
      مهلتِ گذشتهٔ قرمزِ پُر کنارِ هم، دو لکهٔ هم‌اندازه می‌شد و هیچ‌کدام
      دیده نمی‌شد. مهلت حالا خط‌دار است.

   ۳) چیزی که کم عوض می‌شود ساکت می‌ماند: «هر ماه» تا وقتی کسی
      سراغش نرفته قاب و زمینه ندارد. */
import { launch, calm } from './pw.mjs';
import { readFileSync } from 'node:fs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const clear = c => c === 'rgba(0, 0, 0, 0)' || c === 'transparent';

{
  const css = readFileSync(new URL('../public/_t/p/polishcss.tpl', import.meta.url), 'utf8');
  t(!/<\/?(script|style)\b/i.test(css), 'جزوِ شیوه‌نامه تگ ندارد');
  /* قاعده‌ای که outline می‌دهد باید focus-visible داشته باشد. «:focus»
     ساده جای دیگری هست و اشکالی هم ندارد (قابِ چیپِ تکرار)، ولی
     حلقه نباید با هر فوکوسی بیاید. */
  const ringBlocks = css.split('}').filter(b => /outline\s*:/.test(b));
  t(ringBlocks.length > 0, 'قاعدهٔ حلقه در شیوه‌نامه هست', ringBlocks.length + ' قاعده');
  t(ringBlocks.every(b => /focus-visible/.test(b.split('{')[0])),
    'و هر کدامشان فقط با :focus-visible می‌آید',
    ringBlocks.filter(b => !/focus-visible/.test(b.split('{')[0]))
      .map(b => b.split('{')[0].trim().slice(0, 40)).join(' / ') || 'همه درست');
  const tpls = readFileSync(new URL('../src/templates.js', import.meta.url), 'utf8');
  t(/\['polishcss', *p_polishcss\]/.test(tpls), 'جزو ثبت شده است');
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
  p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
  await p.goto('http://' + HOST + ':' + PORT + path, { waitUntil: 'load' });
  await p.waitForTimeout(3800); await calm(p);
  await p.evaluate(() => { const x = document.querySelector('.navbtn[data-view="checklist"]'); if (x) x.click(); });
  await p.waitForTimeout(900);

  /* ۱) حلقهٔ فوکوس.

     نکته‌ای که موقعِ نوشتنِ همین آزمون روشن شد: خانهٔ متنی همیشه
     :focus-visible می‌گیرد، چه با موشواره چه با صفحه‌کلید — چون
     جایی است که آدم تایپ می‌کند و مرورگر درست می‌گوید باید دیده
     شود. پس «با کلیک نیاید» برای خانهٔ متنی خواستهٔ درستی نیست؛
     آن‌چه باید سنجید این است که حلقه هست و دیده می‌شود. */
  const cell = await p.evaluate(() => {
    const i = document.querySelector('#checklistBody input[data-field="task"]');
    if (!i) return null;
    i.focus();
    const cs = getComputedStyle(i);
    return { style: cs.outlineStyle, width: cs.outlineWidth, color: cs.outlineColor };
  });
  t(cell && cell.style === 'solid' && parseFloat(cell.width) >= 2,
    'خانهٔ جدول روی فوکوس حلقهٔ دیدنی دارد',
    cell ? cell.style + ' ' + cell.width + ' ' + cell.color : 'خانه نیست');

  await p.evaluate(() => document.activeElement && document.activeElement.blur());
  await p.waitForTimeout(100);
  await p.keyboard.press('Tab');
  await p.keyboard.press('Tab');
  await p.waitForTimeout(200);
  const byKey = await p.evaluate(() => {
    const e = document.activeElement;
    const cs = getComputedStyle(e);
    return { tag: e.tagName, style: cs.outlineStyle, width: cs.outlineWidth };
  });
  t(byKey.style === 'solid' && parseFloat(byKey.width) >= 2,
    'و با Tab روی دکمه‌ها هم می‌آید', byKey.tag + ': ' + byKey.style + ' ' + byKey.width);

  /* «با موشواره نیاید» این‌جا سنجیده نمی‌شود: آن را خودِ مرورگر با
     :focus-visible تضمین می‌کند، و با رویدادِ ساختگی نمی‌شود حالتِ
     موشواره را درست شبیه‌سازی کرد — یک بار امتحانش کردم و سنجه
     لرزان شد. این‌که قاعده با :focus-visible نوشته شده، بالاتر روی
     خودِ شیوه‌نامه سنجیده می‌شود. */

  /* ۲) در هر ردیف یک چیزِ پُر */
  const fills = await p.evaluate(() => {
    const od = document.querySelector('#checklistBody .date-box.od');
    const st = document.querySelector('#checklistBody select.st-select[data-st="انجام نشده"]');
    const g = e => e ? getComputedStyle(e) : null;
    const a = g(od), s = g(st);
    return { odBg: a ? a.backgroundColor : '—', odBorder: a ? a.borderTopColor : '—',
             stBg: s ? s.backgroundColor : '—', has: !!od && !!st };
  });
  if (fills.has) {
    t(clear(fills.odBg), 'چیپِ مهلتِ گذشته پُر نیست', fills.odBg);
    t(!clear(fills.odBorder), 'ولی قابِ قرمزش هست', fills.odBorder);
    t(!clear(fills.stBg), 'و «انجام نشده» همچنان پُر است', fills.stBg);
  } else {
    t(true, 'در این کارتابل ردیفی با مهلتِ گذشته و کارِ ناتمام نبود — این سنجه رد شد');
  }

  /* ۳) «هر ماه» ساکت است تا موشواره برسد */
  const rep = await p.evaluate(() => {
    const r = document.querySelector('#checklistBody .rep-box');
    if (!r) return null;
    const cs = getComputedStyle(r);
    return { bg: cs.backgroundColor, border: cs.borderTopColor };
  });
  if (rep) {
    t(clear(rep.bg) && clear(rep.border), 'چیپِ تکرار در حالتِ عادی قاب و زمینه ندارد',
      rep.bg + ' / ' + rep.border);
  } else t(true, 'این کارتابل ستونِ تکرار ندارد');

  /* ۴) نوارِ لغزش */
  t(await p.evaluate(() => getComputedStyle(document.querySelector('.tbl-wrap')).scrollbarWidth === 'thin'),
    'نوارِ لغزشِ جدول باریک است');

  t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
  await ctx.close();
}

await b.close();
console.log(ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
