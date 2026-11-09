/* دکمه‌های چاپ — هر چهار تا.

   از یک بررسیِ ساده شروع شد («دکمه‌های چاپ را چک کن») و سه ایراد داد
   که هیچ‌کدام از نگاه کردن به کد پیدا نمی‌شد، چون همه‌شان فقط در
   «@media print» زنده‌اند — جایی که نه چشم می‌بیند نه آزمونِ معمولی:

   ۱) کاغذِ کارتابل کاملاً سفید بود. شیوه‌نامهٔ تقویم «.chat-fab» را
      پنهان می‌کرد به خیالِ دکمهٔ شناورِ گفتگو؛ ولی آن نامِ کلاسی است
      که chat.js روی خودِ body می‌گذارد. یعنی «display:none» می‌خورد
      به body و هیچ‌چیز چاپ نمی‌شد. نامِ درست «.ch-fab-wrap» است، و
      همین اشتباه یک‌بار در democss افتاده و همان‌جا هم یادداشت شده
      بود — پس آزمون لازم است، نه یادداشت.

   ۲) شیوه‌نامهٔ چاپِ گزارش عمومی بود: «*:not(:has(#rpPaper))…» سه
      شناسه ویژگی دارد و از «.view#view-cal» قوی‌تر، پس حتی با رفعِ
      بالا هم دکمهٔ چاپِ تقویم کاغذِ خالی می‌داد.

   ۳) در پنل، «body > .ov{display:block !important}» از صفتِ hidden
      قوی‌تر بود: با Ctrl+P و پنجرهٔ بسته، کلِ پنل خاموش می‌شد و یک
      پنجرهٔ خالی روی کاغذ می‌رفت.

   یک معیارِ ساده همهٔ این‌ها را می‌گیرد: روی کاغذ، چیزی که کاربر
   می‌خواهد چاپ شود باید ارتفاع و عرضِ واقعی داشته باشد. */
import { launch } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';

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

/* «روی کاغذ دیده می‌شود» یعنی قابِ واقعی دارد — نه اینکه display اش
   none نیست. عنصری که والدش پنهان است، خودش display:block دارد و
   با خواندنِ style سالم به نظر می‌رسد. */
const box = sel => `(()=>{ const e=document.querySelector(${JSON.stringify(sel)});
  if(!e) return null; const r=e.getBoundingClientRect();
  return { w:Math.round(r.width), h:Math.round(r.height) }; })()`;

const b = await launch();

/* ================= کارتابل: تقویم و گزارش ================= */
for (const [label, api, pass, path] of [
  ['کارتابلِ فنی', 'kartabl', process.env.VS_IT_PASS || 'siamaksiamak', '/siamak/'],
  ['کارتابلِ مالی', 'sina', process.env.VS_FIN_PASS || 'sinasinasina', '/sina/']
]) {
  console.log('===== ' + label + ' =====');
  const ctx = await b.newContext({ viewport: { width: 1440, height: 1000 } });
  await ctx.addCookies(await session(api, pass));
  const p = await ctx.newPage();
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 140)));
  await p.goto('http://' + HOST + ':' + PORT + path, { waitUntil: 'load' });
  await p.waitForTimeout(3600);

  /* ---- تقویم ---- */
  await p.evaluate(() => document.querySelector('.nav-list .navbtn[data-view="cal"]').click());
  await p.waitForTimeout(1500);
  await p.evaluate(() => { const c = [...document.querySelectorAll('#calGrid .c2-cell')]
    .find(x => x.textContent.trim()); if (c) c.click(); });
  await p.waitForTimeout(700);
  t(!!(await p.$('#calPrint')), 'دکمهٔ چاپِ تقویم هست');

  await p.emulateMedia({ media: 'print' });
  await p.waitForTimeout(400);
  const cal = await p.evaluate(box('.c2-box'));
  t(cal && cal.h > 200 && cal.w > 600, 'و روی کاغذ خودِ تقویم می‌رود، نه کاغذِ سفید',
    cal ? cal.w + '×' + cal.h : 'نیست');
  const body = await p.evaluate(box('body'));
  t(body && body.h > 200, 'و body از کاغذ برداشته نشده', body ? body.h + 'px بلندی' : 'نیست');
  const bar = await p.evaluate(box('.c2-bar'));
  t(!bar || !bar.h, 'و نوارِ دکمه‌ها — با خودِ دکمهٔ چاپ — روی کاغذ نیست');
  const side = await p.evaluate(box('.c2-side'));
  t(!side || !side.w, 'و ستونِ کنار هم نه');
  /* ستونِ برداشته‌شده نباید جایش را نگه دارد */
  const cols = await p.evaluate(() => getComputedStyle(document.querySelector('.c2-main')).gridTemplateColumns);
  t(!/\b300px/.test(cols), 'و ۳۰۰ پیکسلِ آن ستون از عرضِ کاغذ کم نمی‌شود', cols);
  await p.emulateMedia({ media: 'screen' });
  await p.waitForTimeout(250);

  /* ---- گزارش: بی فایل چاپ نمی‌شود، با برگهٔ باز تنها چیزِ کاغذ است ---- */
  await p.evaluate(() => document.querySelector('.nav-list .navbtn[data-view="report"]').click());
  await p.waitForTimeout(900);
  t(!!(await p.$('#rpPrint')), 'دکمهٔ چاپِ گزارش هست');
  /* نامِ فایل عمداً لاتین است: setInputFiles با نامِ فارسی بی هیچ
     خطایی هیچ‌چیز نمی‌چسباند — نه رویداد، نه پیام. */
  await p.setInputFiles('#rpFile', { name: 'report.csv', mimeType: 'text/csv',
    buffer: Buffer.from('دسته,مبلغ\nالف,120\nب,80\nالف,45\nج,200\n', 'utf8') });
  await p.waitForTimeout(2200);
  /* «RP» توی یک تابعِ بسته است و روی window نیست؛ پس از خودِ صفحه
     می‌پرسیم، نه از متغیرِ داخلی. */
  const fed = await p.evaluate(() => ({
    ttl: ($('rpTitle') || {}).textContent || '',
    rows: document.querySelectorAll('#rpPaper .rp-tab tr').length
  })).catch(() => null) || await p.evaluate(() => ({
    ttl: (document.getElementById('rpTitle') || {}).textContent || '',
    rows: document.querySelectorAll('#rpPaper .rp-tab tr').length }));
  t(fed.ttl.trim().length > 0 && fed.rows > 1, 'گزارش فایل را خواند و برگه را ساخت',
    fed.rows + ' سطر — ' + fed.ttl.slice(0, 40));
  /* همین آزمون یک ایرادِ دیگر لو داد: عنوان «جمعِ ÙØ¨ÙØº» درمی‌آمد.
     CSV را بایت‌بایت به کتابخانه می‌دادند، و هر بایتِ UTF-8 یک نویسه
     حساب می‌شد. پس نامِ ستون باید خوانا باشد، نه فقط موجود. */
  t(/[\u0600-\u06FF]/.test(fed.ttl) && !/[\u00C0-\u00FF]{2}/.test(fed.ttl),
    'و نامِ ستونِ فارسی خوانا است، نه بایت‌های به‌هم‌ریخته', fed.ttl.slice(0, 40));
  await p.emulateMedia({ media: 'print' });
  await p.waitForTimeout(500);
  const rp = await p.evaluate(box('#rpPaper'));
  t(rp && rp.w > 400 && rp.h > 100, 'و با گزارشِ ساخته‌شده، کاغذ همان برگه است',
    rp ? rp.w + '×' + rp.h : 'نیست');
  const navOnPaper = await p.evaluate(box('.sidebar'));
  t(!navOnPaper || !navOnPaper.w, 'و نوارِ کنار روی کاغذِ گزارش نمی‌آید');
  const calOnPaper = await p.evaluate(box('#view-cal'));
  t(!calOnPaper || !calOnPaper.h, 'و تقویم هم روی کاغذِ گزارش نمی‌آید');
  await p.emulateMedia({ media: 'screen' });

  /* ---- خروجیِ روزانه: کاغذِ خودش را در iframe می‌سازد ---- */
  t(await p.evaluate(() => !!(window.dayExport && window.dayExport.pdf)),
    'خروجیِ PDFِ روزانه کاغذِ جداگانهٔ خودش را دارد');

  t(errs.length === 0, 'و هیچ‌کدام خطای جاوااسکریپت نداد', errs[0] || '—');
  await ctx.close();
}

/* ================= پنل: فاکتور ================= */
console.log('===== پنلِ ادمین =====');
{
  const ctx = await b.newContext({ viewport: { width: 1440, height: 1000 } });
  const p = await ctx.newPage();
  await p.goto(BASE + '/login', { waitUntil: 'domcontentloaded' });
  await p.evaluate(async a => { await fetch('/api/admin.planer/signin', {
    method: 'POST', credentials: 'same-origin',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ user: a.u, password: a.p }) }); }, { u: AUSER, p: APASS });
  await p.goto(BASE + '/login', { waitUntil: 'networkidle' });
  await p.waitForTimeout(1900);

  /* بی پنجره، Ctrl+P باید خودِ پنل را بدهد نه یک پنجرهٔ خالی */
  await p.emulateMedia({ media: 'print' });
  await p.waitForTimeout(400);
  const shell = await p.evaluate(box('body'));
  t(shell && shell.h > 200, 'بی پنجرهٔ باز، چاپ خودِ پنل است نه کاغذِ سفید',
    shell ? shell.h + 'px بلندی' : 'نیست');
  const ghost = await p.evaluate(box('.ov'));
  t(!ghost || !ghost.h, 'و پنجرهٔ بستهٔ خالی روی کاغذ نمی‌آید');
  await p.emulateMedia({ media: 'screen' });
  await p.waitForTimeout(250);

  /* با فاکتور باز، فقط فاکتور */
  const opened = await p.evaluate(() => {
    if (typeof openInvoiceBox !== 'function') return false;
    openInvoiceBox('<div class="invoice"><div class="inv-top"><div class="who">' +
      '<h3>آزمون</h3></div></div><table class="inv-tab"><tr><td>یک</td></tr></table></div>' +
      '<div class="ov-acts"><button id="invPrint">چاپ</button></div>');
    return true;
  });
  t(opened, 'پنجرهٔ فاکتور باز می‌شود');
  await p.waitForTimeout(400);
  await p.emulateMedia({ media: 'print' });
  await p.waitForTimeout(400);
  const inv = await p.evaluate(box('.invoice'));
  t(inv && inv.h > 20 && inv.w > 600, 'و روی کاغذ فاکتور تمامِ عرض را می‌گیرد',
    inv ? inv.w + '×' + inv.h : 'نیست');
  const acts = await p.evaluate(box('.ov-acts'));
  t(!acts || !acts.h, 'و دکمه‌های «چاپ» و «بستن» روی کاغذ نیستند');
  const sidebarOnPaper = await p.evaluate(
    `(()=>{ const s=document.querySelector('.sidebar')||document.querySelector('nav');
       if(!s) return 0; return Math.round(s.getBoundingClientRect().width); })()`);
  t(!sidebarOnPaper, 'و بقیهٔ پنل کنار رفته', sidebarOnPaper + 'px');
  await ctx.close();
}

await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
