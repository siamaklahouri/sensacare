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
/* Ctrl+P در مرورگرِ واقعی رویدادِ «beforeprint» می‌فرستد و سامانهٔ
   چاپ همان‌جا بخشِ باز را آماده می‌کند. emulateMedia این رویداد را
   نمی‌فرستد، پس آزمون باید خودش بفرستد — وگرنه چیزی را می‌سنجد که
   هیچ کاربری نمی‌بیند. */
const asPrint = async p => {
  await p.emulateMedia({ media: 'print' });
  await p.evaluate(() => window.dispatchEvent(new Event('beforeprint')));
  await p.waitForTimeout(400);
};
const unPrint = async p => {
  await p.evaluate(() => window.dispatchEvent(new Event('afterprint')));
  await p.emulateMedia({ media: 'screen' });
  await p.waitForTimeout(250);
};

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

  await asPrint(p);
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
  await unPrint(p);

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
  await asPrint(p);
  const rp = await p.evaluate(box('#rpPaper'));
  t(rp && rp.w > 400 && rp.h > 100, 'و با گزارشِ ساخته‌شده، کاغذ همان برگه است',
    rp ? rp.w + '×' + rp.h : 'نیست');
  const navOnPaper = await p.evaluate(box('.sidebar'));
  t(!navOnPaper || !navOnPaper.w, 'و نوارِ کنار روی کاغذِ گزارش نمی‌آید');
  const calOnPaper = await p.evaluate(box('#view-cal'));
  t(!calOnPaper || !calOnPaper.h, 'و تقویم هم روی کاغذِ گزارش نمی‌آید');
  await unPrint(p);

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

  /* بی پنجره، Ctrl+P باید خودِ پنل را بدهد نه یک پنجرهٔ خالی.
     پنلِ ادمین سامانهٔ چاپِ کارتابل را ندارد — شیوه‌نامهٔ خودش را
     دارد — پس این‌جا رویدادی لازم نیست. */
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

/* ================= چاپ از هر بخش ================= */
console.log('===== هر بخش، و سربرگش =====');
{
  const ctx = await b.newContext({ viewport: { width: 1440, height: 1000 } });
  await ctx.addCookies(await session('kartabl', process.env.VS_IT_PASS || 'siamaksiamak'));
  const p = await ctx.newPage();
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 140)));
  await p.goto('http://' + HOST + ':' + PORT + '/siamak/', { waitUntil: 'load' });
  await p.waitForTimeout(4000);
  /* پنجرهٔ چاپ در آزمون باز نمی‌شود؛ فقط آماده‌سازی را می‌سنجیم. */
  await p.evaluate(() => { window.print = () => {}; });

  const btns = await p.evaluate(() => document.querySelectorAll('.kb-print-btn').length);
  t(btns >= 10, 'هر بخش دکمهٔ چاپِ خودش را دارد', btns + ' دکمه');

  /* هیچ دکمهٔ چاپی نباید به شکلکِ سیستم تکیه کند. «🖨» (U+1F5A8) در
     قلمِ شکلکِ ویندوز نیست و آن‌جا یک مربعِ خالی می‌شود — کاربر عکسش
     را فرستاد. آیکنِ برداری همه‌جا یک شکل است و رنگش را هم از متنِ
     دکمه می‌گیرد، پس با تم می‌چرخد. */
  const ic = await p.evaluate(() => {
    const all = [...document.querySelectorAll('.kb-print-btn, [data-print-ic], #printAllBtn')];
    return {
      total: all.length,
      noSvg: all.filter(e => !e.querySelector('svg')).length,
      emoji: all.filter(e => /[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]/u.test(e.textContent)).length,
      noLabel: all.filter(e => !e.getAttribute('aria-label') && !e.textContent.trim()).length,
      wrapped: all.filter(e => e.getBoundingClientRect().height > 44).length
    };
  });
  t(ic.total > 10, 'همهٔ دکمه‌های چاپ شمرده شدند', ic.total + ' دکمه');
  t(ic.noSvg === 0, 'و همه آیکنِ برداری دارند', ic.noSvg + ' بی آیکن');
  t(ic.emoji === 0, 'و هیچ‌کدام شکلکِ متنی ندارند', ic.emoji + ' با شکلک');
  t(ic.noLabel === 0, 'و هرکدام یا متن دارد یا نامِ دسترس‌پذیری', ic.noLabel + ' بی‌نام');
  t(ic.wrapped === 0, 'و متنِ هیچ‌کدام با آمدنِ آیکن دو خط نشده', ic.wrapped + ' دوخطی');

  /* بخشی که اصلاً باز نیست هم باید چاپ شود — این همان چیزی است که
     قبلاً ممکن نبود. */
  await p.evaluate(() => kbPrint('view-servers'));
  await p.waitForTimeout(1200);
  await p.emulateMedia({ media: 'print' });
  await p.waitForTimeout(400);
  const o = await p.evaluate(() => {
    const h = Math.round(document.getElementById('view-servers').getBoundingClientRect().height);
    const head = document.querySelector('#view-servers .kb-phead');
    const others = [...document.querySelectorAll('.content > .view')]
      .filter(v => v.id !== 'view-servers' && v.getBoundingClientRect().height > 0).length;
    return { h, others, text: head ? head.innerText : '',
      page: (document.getElementById('kbPageStyle') || {}).textContent || '' };
  });
  t(o.h > 200, 'بخشِ بسته هم روی کاغذ می‌رود', o.h + 'px');
  t(o.others === 0, 'و هیچ بخشِ دیگری با آن چاپ نمی‌شود', o.others + ' بخشِ اضافه');
  t(/سرورها/.test(o.text), 'سربرگ نامِ بخش را دارد');
  t(/کارتابل/.test(o.text), 'و نامِ کارتابل را');
  t(/ردیف/.test(o.text), 'و می‌گوید چند ردیف است');
  t(/\d|[۰-۹]/.test(o.text), 'و تاریخِ چاپ را', o.text.split('\n').pop().slice(0, 48));
  t(/landscape/.test(o.page), 'و جدولِ پهن روی کاغذِ خوابیده می‌رود', o.page.trim());

  /* ردیفِ جست‌وجوی سرِ جدول ابزار است، نه داده */
  const filt = await p.evaluate(() => {
    const r = document.querySelector('#view-servers tr:has(.col-filter)');
    return r ? Math.round(r.getBoundingClientRect().height) : 0;
  });
  t(filt === 0, 'ردیفِ جست‌وجو روی کاغذ نمی‌آید', filt + 'px');
  await p.emulateMedia({ media: 'screen' });
  await p.waitForTimeout(300);
  await p.evaluate(() => window.dispatchEvent(new Event('afterprint')));
  await p.waitForTimeout(300);

  /* متنِ خانه‌ها نباید بریده شود. چک‌لیست را می‌سنجیم چون خانه‌هایش
     واقعاً <input> اند — جدولِ سرورها دادهٔ خودش را به شکلِ متن در
     <td> می‌گذارد و کادرهایش فقط ردیفِ جست‌وجوست. */
  await p.evaluate(() => kbPrint('view-checklist'));
  await p.waitForTimeout(1300);
  await p.emulateMedia({ media: 'print' });
  await p.waitForTimeout(400);
  const cells = await p.evaluate(() => {
    const vals = [...document.querySelectorAll('#view-checklist tbody .kb-pval')];
    const shown = [...document.querySelectorAll('#view-checklist tbody input[type="text"], #view-checklist tbody input:not([type])')]
      .filter(i => getComputedStyle(i).display !== 'none').length;
    const wrap = vals.length ? getComputedStyle(vals[0]).whiteSpace : '';
    return { vals: vals.length, filled: vals.filter(v => v.textContent.trim()).length, shown, wrap };
  });
  t(cells.filled > 0, 'متنِ خانه‌ها روی کاغذ می‌آید',
    cells.filled + ' از ' + cells.vals + ' پُر');
  t(cells.shown === 0, 'و خودِ کادرها روی کاغذ نیستند', cells.shown + ' کادر');
  t(cells.wrap === 'normal', 'و متن می‌شکند، پس بریده نمی‌شود', cells.wrap);
  await p.emulateMedia({ media: 'screen' });
  await p.waitForTimeout(300);

  /* و بعدِ چاپ، صفحه باید دقیقاً همان‌طور که بود برگردد */
  await p.evaluate(() => window.dispatchEvent(new Event('afterprint')));
  await p.waitForTimeout(400);
  const after = await p.evaluate(() => ({
    pvals: document.querySelectorAll('.kb-pval').length,
    marks: document.querySelectorAll('.kb-print, .kb-pskip, .kb-phead').length,
    cls: document.documentElement.classList.contains('kb-printing'),
    style: !!document.getElementById('kbPageStyle')
  }));
  t(after.pvals === 0 && after.marks === 0 && !after.cls && !after.style,
    'و بعدِ چاپ هیچ ردی از آن روی صفحه نمی‌ماند', JSON.stringify(after));

  /* «همه‌ی بخش‌ها» */
  await p.evaluate(() => kbPrint('all'));
  await p.waitForTimeout(1500);
  const all = await p.evaluate(() => ({
    printed: document.querySelectorAll('.view.kb-print').length,
    heads: document.querySelectorAll('.kb-phead').length,
    last: document.querySelectorAll('.kb-print-last').length
  }));
  t(all.printed > 5, 'چاپِ همهٔ بخش‌ها همه را می‌گیرد', all.printed + ' بخش');
  t(all.heads === all.printed, 'و هر کدام سربرگِ خودش را دارد', all.heads + ' سربرگ');
  t(all.last === 1, 'و فقط آخری شکستِ صفحه ندارد', all.last + '');
  await p.evaluate(() => window.dispatchEvent(new Event('afterprint')));

  t(errs.length === 0, 'و هیچ‌کدام خطای جاوااسکریپت نداد', errs[0] || '—');
  await ctx.close();
}

/* ================= داشبورد روی کاغذ ================= */
console.log('===== نمودارهای داشبورد =====');
{
  /* برگهٔ داشبورد چهار صفحه می‌شد که نصفش سفید بود: چهار کارتِ
     نموداری که هنوز داده ندارند، هر کدام یک‌سومِ صفحه، برای یک
     جملهٔ «هنوز داده‌ای ثبت نشده». روی صفحه جایشان درست است — خبر
     می‌دهند که این بخش هنوز پر نشده — ولی روی کاغذ هیچ‌اند. */
  const ctx = await b.newContext({ viewport: { width: 1123, height: 794 } });
  await ctx.addCookies(await session('kartabl', process.env.VS_IT_PASS || 'siamaksiamak'));
  const p = await ctx.newPage();
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 140)));
  await p.goto('http://' + HOST + ':' + PORT + '/siamak/', { waitUntil: 'load' });
  await p.waitForTimeout(4200);

  const onScreen = await p.evaluate(() => ({
    panels: [...document.querySelectorAll('#view-dashboard .panel')]
      .filter(x => x.getBoundingClientRect().height > 0).length,
    empty: document.querySelectorAll('#view-dashboard canvas[data-empty="1"]').length
  }));
  t(onScreen.empty > 0, 'داشبوردِ آزمون نمودارِ بی‌داده دارد', onScreen.empty + ' تا');
  t(onScreen.panels > 4, 'و روی صفحه همه‌شان دیده می‌شوند', onScreen.panels + ' قاب');

  await p.evaluate(() => { window.print = () => {}; kbPrint('view-dashboard'); });
  await p.waitForTimeout(1800);
  await p.emulateMedia({ media: 'print' });
  await p.waitForTimeout(500);

  const onPaper = await p.evaluate(() => {
    const vis = e => e.getBoundingClientRect().height > 0;
    const panels = [...document.querySelectorAll('#view-dashboard .panel')];
    return {
      shown: panels.filter(vis).length,
      emptyShown: panels.filter(x => vis(x) && x.querySelector('canvas[data-empty="1"]')).length,
      orphanLabels: [...document.querySelectorAll('#view-dashboard .dash-group-label')]
        .filter(lab => {
          if (!vis(lab)) return false;
          const next = lab.nextElementSibling;
          if (!next) return false;
          const ps = [...next.querySelectorAll('.panel')];
          return ps.length > 0 && !ps.some(vis);
        }).length,
      chartH: (() => { const c = document.querySelector('#view-dashboard .chart-box');
        return c ? Math.round(c.getBoundingClientRect().height) : 0; })()
    };
  });
  t(onPaper.emptyShown === 0, 'ولی روی کاغذ هیچ نمودارِ بی‌داده‌ای نمی‌رود',
    onPaper.emptyShown + ' تا');
  t(onPaper.shown > 0, 'و نمودارهای دارای داده می‌مانند', onPaper.shown + ' قاب');
  t(onPaper.shown < onScreen.panels, 'یعنی برگه کوتاه‌تر از صفحه است',
    onScreen.panels + ' → ' + onPaper.shown);
  t(onPaper.orphanLabels === 0,
    'و عنوانِ گروهی که همهٔ کارت‌هایش رفته‌اند، خودش هم می‌رود',
    onPaper.orphanLabels + ' عنوانِ بی‌کارت');
  /* ارتفاعِ نمودار روی کاغذ از ۶۲ میلی‌متر بیشتر نشود — وگرنه در هر
     صفحه فقط یکی جا می‌شود. ۶۲ میلی‌متر حدودِ ۲۳۴ پیکسل است. */
  t(onPaper.chartH > 0 && onPaper.chartH <= 240,
    'و نمودار روی کاغذ کوتاه‌تر است تا چند تا در یک صفحه جا شوند',
    onPaper.chartH + 'px');

  const bar = await p.evaluate(() => {
    try { return Chart.defaults.datasets.bar.maxBarThickness; } catch (e) { return null; }
  });
  t(bar && bar <= 60, 'و میلهٔ تنها تمامِ قاب را پر نمی‌کند', 'سقف ' + bar + 'px');

  t(errs.length === 0, 'و خطایی نداد', errs[0] || '—');
  await ctx.close();
}

/* ================= کاغذِ تنگ نیست ================= */
console.log('===== تقویم روی کاغذِ ایستاده =====');
{
  /* این یکی از روی یک PDFِ واقعی درآمد. کاربر تقویم را چاپ کرد و
     خانه‌های روز فقط چند نقطهٔ بی‌معنی داشتند، بی هیچ نامی.

     علت: calcss یک قاعدهٔ «@media (max-width:900px)» داشت که کارهای
     هر روز را به نقطهٔ شش‌پیکسلی با «font-size:0» تبدیل می‌کند — که
     روی گوشی درست است. ولی در چاپ، عرضِ رسانه عرضِ کاغذ است و A4ِ
     ایستاده ۷۹۴ پیکسل است، یعنی زیر ۹۰۰. پس همان قاعده روی کاغذ هم
     اجرا می‌شد.

     درسش از خودِ ایراد بزرگ‌تر است: هر قاعدهٔ «صفحهٔ باریک» که
     «screen and» نداشته باشد، روی کاغذ هم می‌افتد. پس این آزمون در
     عرضِ کاغذِ ایستاده می‌سنجد، نه در عرضِ دسکتاپ. */
  const ctx = await b.newContext({ viewport: { width: 794, height: 794 } });
  await ctx.addCookies(await session('kartabl', process.env.VS_IT_PASS || 'siamaksiamak'));
  const p = await ctx.newPage();
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 140)));
  await p.goto('http://' + HOST + ':' + PORT + '/siamak/', { waitUntil: 'load' });
  await p.waitForTimeout(4000);
  await p.evaluate(() => { window.print = () => {}; kbPrint('view-cal'); });
  await p.waitForTimeout(1700);
  await p.emulateMedia({ media: 'print' });
  await p.waitForTimeout(400);

  const o = await p.evaluate(() => {
    const its = [...document.querySelectorAll('#calGrid .c2-it')];
    const rect = e => e.getBoundingClientRect();
    return {
      items: its.length,
      dots: its.filter(e => parseFloat(getComputedStyle(e).fontSize) < 5).length,
      narrow: its.filter(e => rect(e).width < 20).length,
      clipped: its.filter(e => getComputedStyle(e).overflow === 'hidden').length,
      wd: getComputedStyle(document.querySelector('.c2-wd span')).fontSize,
      head: (document.querySelector('#view-cal .kb-phead') || {}).innerText || ''
    };
  });
  t(o.items > 3, 'تقویم کار دارد', o.items + ' کار');
  t(o.dots === 0, 'و هیچ‌کدام روی کاغذ نقطه نشده‌اند', o.dots + ' نقطه');
  t(o.narrow === 0, 'و همه عرضِ واقعی دارند', o.narrow + ' باریک');
  t(o.clipped === 0, 'و متنشان بریده نمی‌شود — کاغذ اسکرول ندارد', o.clipped + ' بریده');
  t(parseFloat(o.wd) > 5, 'نامِ روزهای هفته هم کامل است، نه یک حرف', o.wd);

  /* شکلک روی کاغذِ ویندوز بد در می‌آید؛ سربرگ باید متنِ خالص باشد. */
  t(!/[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]/u.test(o.head),
    'و سربرگِ کاغذ هیچ شکلکی ندارد', JSON.stringify(o.head.split('\n')[0]));
  t(/تقویم/.test(o.head) && /ساعت/.test(o.head),
    'ولی نام و تاریخش را دارد', o.head.split('\n').pop().slice(0, 44));

  /* پانویسِ امضا روی کاغذ یک خطِ سرگردان بود که صفحهٔ دوم می‌ساخت */
  const foot = await p.evaluate(() => {
    const f = document.querySelector('.appfoot');
    return f ? Math.round(f.getBoundingClientRect().height) : 0;
  });
  t(foot === 0, 'و پانویسِ امضا صفحهٔ دومِ خالی نمی‌سازد', foot + 'px');

  t(errs.length === 0, 'و خطایی نداد', errs[0] || '—');
  await ctx.close();
}

await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
