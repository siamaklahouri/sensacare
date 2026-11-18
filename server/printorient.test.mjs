/* انتخابِ ایستاده یا خوابیده، پیش از چاپ.

   تا امروز خودِ کارتابل تصمیم می‌گرفت: جدول‌های پهن خوابیده، بقیه
   ایستاده. و چون «@page{size:…}» در مرورگر بر انتخابِ کاربر در
   پنجرهٔ چاپ می‌چربد، کاربر عملاً هیچ راهی نداشت — گزارشش همین بود:
   «فقط پیش‌فرضش هست».

   پس انتخاب پیش از بازشدنِ پنجرهٔ چاپ گرفته می‌شود. حدسِ قبلی حذف
   نشد؛ همان از پیش انتخاب‌شده است. و چون کسی که یک بار جهتی را
   انتخاب کرده، دفعهٔ بعد هم همان را می‌خواهد، برای همان بخش
   یادمان می‌ماند.

   مرزها: پنجره نباید روی کاغذ بیفتد، و kbPrint با جهتِ صریح نباید
   بپرسد (وگرنه هر آزمونِ چاپ سرِ پنجره می‌ماند). */
import { launch, calm } from './pw.mjs';
import { readFileSync } from 'node:fs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

{
  const css = readFileSync(new URL('../public/_t/p/printanycss.tpl', import.meta.url), 'utf8');
  t(/@media print\{[^}]*\.kb-orient-ov\{ *display:none/.test(css.replace(/\s+/g, ' ').replace(/ \{/g, '{')),
    'پنجره روی کاغذ نمی‌افتد');
  const js = readFileSync(new URL('../public/_t/p/printany.tpl', import.meta.url), 'utf8');
  t(/function askOrient/.test(js), 'تابعِ پرسش هست');
  t(/orientRemember/.test(js), 'و انتخاب را به‌یاد می‌سپارد');
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
for (const [label, api, pass, path, wideView, narrowView] of [
  ['کارتابلِ فنی', 'kartabl', process.env.VS_IT_PASS || 'siamaksiamak', '/siamak/', 'view-checklist', 'view-dashboard'],
  ['کارتابلِ مالی', 'sina', process.env.VS_FIN_PASS || 'sinasinasina', '/sina/', 'view-checklist', 'view-dashboard']
]) {
  console.log('===== ' + label + ' =====');
  const ctx = await b.newContext({ viewport: { width: 1500, height: 1000 } });
  await ctx.addCookies(await cookiesFor(api, pass));
  const p = await ctx.newPage();
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
  await p.goto('http://' + HOST + ':' + PORT + path, { waitUntil: 'load' });
  await p.waitForTimeout(3600); await calm(p);
  await p.evaluate(() => { window.print = () => { window.__printed = (window.__printed || 0) + 1; }; });

  /* ۱) بی جهتِ صریح، می‌پرسد */
  await p.evaluate(v => { localStorage.removeItem('kb-print-orient-v1'); kbPrint(v); }, wideView);
  await p.waitForTimeout(500);
  const asked = await p.evaluate(() => {
    const ov = document.querySelector('.kb-orient-ov');
    if (!ov) return null;
    return { shown: getComputedStyle(ov).display !== 'none',
             title: (ov.querySelector('.ko-h') || {}).textContent || '',
             on: (ov.querySelector('.ko-opt.on') || {}).getAttribute
                 ? ov.querySelector('.ko-opt.on').getAttribute('data-o') : '',
             opts: ov.querySelectorAll('.ko-opt').length,
             printed: window.__printed || 0 };
  });
  t(asked && asked.shown, 'پنجرهٔ انتخاب باز شد');
  t(asked && asked.opts === 2, 'دو گزینه دارد', asked ? asked.opts + '' : '—');
  t(asked && asked.on === 'landscape', 'و حدسِ پیشین از پیش انتخاب شده', asked ? asked.on : '—');
  t(asked && asked.printed === 0, 'و تا تأیید نکرده‌ای چیزی چاپ نمی‌شود');
  t(asked && /چک‌لیست/.test(asked.title), 'و نامِ همان بخش را می‌گوید', asked ? asked.title : '—');

  /* ۲) انتخابِ دیگر + چاپ */
  await p.evaluate(() => {
    document.querySelector('.ko-opt[data-o="portrait"]').click();
    document.querySelector('.ko-go').click();
  });
  await p.waitForTimeout(600);
  const after = await p.evaluate(() => ({
    gone: !document.querySelector('.kb-orient-ov'),
    page: (document.getElementById('kbPageStyle') || {}).textContent || '',
    printed: window.__printed || 0
  }));
  t(after.gone, 'پنجره بسته شد');
  t(/portrait/.test(after.page), 'و کاغذ ایستاده شد — همان که انتخاب شد', after.page.trim());
  t(after.printed === 1, 'و یک بار چاپ شد', after.printed + '');

  /* ۳) دفعهٔ بعد همان انتخاب یادش هست */
  await p.evaluate(() => { try { if (typeof cleanupPrint === 'function') cleanupPrint(); } catch (e) {} });
  await p.evaluate(v => kbPrint(v), wideView);
  await p.waitForTimeout(500);
  t(await p.evaluate(() => {
    const o = document.querySelector('.kb-orient-ov .ko-opt.on');
    return o && o.getAttribute('data-o') === 'portrait';
  }), 'دفعهٔ بعد همان انتخابِ قبلی از پیش نشسته');

  /* ۴) «بی‌خیال» و Escape */
  await p.evaluate(() => document.querySelector('.ko-cancel').click());
  await p.waitForTimeout(300);
  t(await p.evaluate(() => !document.querySelector('.kb-orient-ov')), '«بی‌خیال» می‌بنددش');
  t(await p.evaluate(() => (window.__printed || 0) === 1), 'و چیزی چاپ نشد', '');

  await p.evaluate(v => kbPrint(v), narrowView);
  await p.waitForTimeout(400);
  await p.keyboard.press('Escape');
  await p.waitForTimeout(300);
  t(await p.evaluate(() => !document.querySelector('.kb-orient-ov')), 'Escape هم می‌بنددش');

  /* ۵) با جهتِ صریح نمی‌پرسد */
  await p.evaluate(v => kbPrint(v, 'landscape'), narrowView);
  await p.waitForTimeout(600);
  const direct = await p.evaluate(() => ({
    asked: !!document.querySelector('.kb-orient-ov'),
    page: (document.getElementById('kbPageStyle') || {}).textContent || '',
    printed: window.__printed || 0
  }));
  t(!direct.asked, 'با جهتِ صریح پنجره‌ای باز نمی‌شود');
  t(/landscape/.test(direct.page), 'و همان جهت اعمال می‌شود', direct.page.trim());
  t(direct.printed === 2, 'و چاپ انجام شد', direct.printed + '');

  t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
  await ctx.close();
}

await b.close();
console.log(ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
