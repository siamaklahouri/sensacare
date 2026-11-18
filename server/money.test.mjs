/* پول: همان‌طور که تایپ می‌شود، همان‌طور که خوانده می‌شود.

   دو ایرادِ هم‌خانواده:

   ۱) عددی که با جداکنندهٔ هزارگان تایپ شود بی‌صدا خراب می‌شد.
      fadigits رقمِ فارسی و «٬» را می‌فهمید، ولی «,» و «،» و فاصله را
      نه — و صفحه‌کلیدِ فارسیِ ویندوز روی همان کلید «،» می‌دهد و کسی
      که با اکسل خو گرفته «,» می‌زند. نتیجه: فاکتورِ ۱۲٬۵۰۰٬۰۰۰ در
      دیتابیس می‌شد ۱۲. نه خطایی، نه هشداری — و جمع‌های داشبورد هم با
      همان ۱۲ حساب می‌شدند.

   ۲) مبلغ داخلِ ردیف‌ها خام نوشته می‌شد: «125000000». در این شکل یک
      صفرِ کم یا زیاد اصلاً دیده نمی‌شود.

   هر دو یک کارند: ورودی را درست بخوان، خروجی را خوانا بنویس. */
import { launch, calm } from './pw.mjs';
import { readFileSync } from 'node:fs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

console.log('===== سیم‌کشی =====');
{
  const fd = readFileSync(new URL('../public/_t/p/fadigits.tpl', import.meta.url), 'utf8');
  t(/var GROUP = /.test(fd), 'جداکنندهٔ هزارگان شناخته می‌شود');
  t(/\(\?=\\d\)/.test(fd), 'و فقط وقتی میانِ دو رقم باشد', 'وگرنه «۱۲ تومان و ۵۰۰» می‌شد ۱۲۵۰۰');
  const fin = readFileSync(new URL('../public/_t/fin.tpl', import.meta.url), 'utf8');
  t(/const MONEY_CELL = /.test(fin), 'خانه‌های پول نشان‌دار شده‌اند');
  t(fin.split('escapeHtml(cellText(field, value))').length - 1 === 8,
    'و هر هشت جدول از همان مسیر می‌گذرد',
    (fin.split('escapeHtml(cellText(field, value))').length - 1) + ' از ۸');
  t(fin.split('reflowMoney(td, f,').length - 1 === 8, 'و پس از ذخیره هر هشت‌تا بازنویسی می‌شوند');
}

const r = await fetch(BASE + '/api/sina/login', { method: 'POST',
  headers: { 'Content-Type': 'application/json', Host: HOST },
  body: JSON.stringify({ password: process.env.VS_FIN_PASS || 'sinasinasina' }) });
const ck = (r.headers.getSetCookie ? r.headers.getSetCookie() : []).map(c => {
  const kv = c.split(';')[0];
  return { name: kv.split('=')[0], value: kv.slice(kv.indexOf('=') + 1), domain: HOST, path: '/' };
});

const b = await launch();
const ctx = await b.newContext({ viewport: { width: 1400, height: 900 } });
await ctx.addCookies(ck);
const p = await ctx.newPage();
const errs = [];
p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
await p.goto('http://' + HOST + ':' + PORT + '/sina/', { waitUntil: 'load' });
await p.waitForTimeout(3800); await calm(p);

console.log('===== خواندنِ عدد =====');
/* همان parseFloatِ خودِ صفحه — هر جای برنامه که عدد می‌خواند از این
   رد می‌شود. */
const CASES = [
  ['۱۲۵۰۰۰۰۰', 12500000, 'رقمِ فارسی'],
  ['12,500,000', 12500000, 'ویرگولِ لاتین (عادتِ اکسل)'],
  ['۱۲,۵۰۰,۰۰۰', 12500000, 'رقمِ فارسی با ویرگولِ لاتین'],
  ['۱۲،۵۰۰،۰۰۰', 12500000, 'ویرگولِ عربی (کلیدِ همان‌جای کیبورد فارسی)'],
  ['۱۲٬۵۰۰٬۰۰۰', 12500000, 'جداکنندهٔ فارسی'],
  ['12 500 000', 12500000, 'فاصله'],
  ['12.500.000', 12500000, 'نقطه، وقتی بیش از یکی باشد'],
  ['12.5', 12.5, 'ولی یک نقطه هنوز ممیز است'],
  ['۱۲٫۵', 12.5, 'و ممیزِ فارسی هم'],
  ['۱۲۵۰۰۰۰۰ ریال', 12500000, 'با واحد'],
  ['۱۲ تومان و ۵۰۰', 12, 'و متنِ آزاد به هم نمی‌ریزد']
];
for (const [inp, want, why] of CASES) {
  const got = await p.evaluate(s => parseFloat(s), inp);
  t(got === want, why, JSON.stringify(inp) + ' → ' + got);
}

console.log('===== نوشتن در خانهٔ مبلغ =====');
await p.evaluate(() => {
  const x = document.querySelector('.navbtn[data-view="invoices"]');
  if (x) x.click();
});
await p.waitForTimeout(700);
/* کارتابلِ آزمون فاکتوری ندارد؛ یکی از راهِ خودِ برنامه می‌سازیم. */
await p.evaluate(() => {
  if (!invoicesData.length)
    addInvoiceRow({ invoiceNo: 'T-1', customer: 'آزمون', amount: 1, paid: 0 });
  editMode.invoices = true; renderInvoices();
});
await p.waitForTimeout(600);

const has = await p.evaluate(() => ({
  rows: document.querySelectorAll('#invoicesBody tr').length,
  cells: document.querySelectorAll('#invoicesBody [data-field="amount"]').length
}));
t(has.cells > 0, 'خانهٔ مبلغ روی صفحه هست', has.rows + ' ردیف');

if (has.cells > 0) {
  /* همان کاری که کاربر می‌کند: داخلِ خانه تایپ و بعد بیرون کلیک */
  const typed = await p.evaluate(async () => {
    const td = document.querySelector('#invoicesBody [data-field="amount"]');
    const i = parseInt(td.getAttribute('data-idx'));
    td.focus();
    td.textContent = '12,500,000';
    td.dispatchEvent(new Event('input', { bubbles: true }));
    td.blur();
    await new Promise(r => setTimeout(r, 200));
    return { saved: invoicesData[i].amount, shown: td.textContent };
  });
  t(typed.saved === 12500000, 'عددِ جداکننده‌دار درست ذخیره شد', typed.saved + '');
  t(/[۰-۹]/.test(typed.shown) && typed.shown.indexOf(',') > 0,
    'و خوانا برمی‌گردد، نه خام', typed.shown);

  /* و همان چیزی که نشان داده می‌شود، دوباره درست خوانده شود —
     وگرنه هر بار ویرایش، عدد را یک پله خراب می‌کرد. */
  const round = await p.evaluate(async () => {
    const td = document.querySelector('#invoicesBody [data-field="amount"]');
    const i = parseInt(td.getAttribute('data-idx'));
    const seen = td.textContent;
    td.focus(); td.blur();
    await new Promise(r => setTimeout(r, 200));
    return { seen, after: invoicesData[i].amount };
  });
  t(round.after === 12500000, 'و ویرایشِ دوباره خرابش نمی‌کند',
    round.seen + ' → ' + round.after);
}

t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
await b.close();
console.log(ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
