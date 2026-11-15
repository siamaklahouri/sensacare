/* سررسیدی که گذشته — کارتابلِ مالی.

   «معوق» تا امروز فقط یک وضعیتِ دستی بود: فاکتوری که سررسیدش رد
   شده بود، تا وقتی کسی خودش وضعیتش را عوض نکند هیچ‌جا شمرده
   نمی‌شد. همان حفره‌ای که در کارها بسته شد، این‌جا برای پول باز
   بود — و این یکی گران‌تر تمام می‌شود.

   یک چیزِ دیگر هم همین‌جا پیدا شد: کارتِ «سررسیدگذشته» در بخشِ
   بدهی‌ها از روزِ اول صفر نشان می‌داد. مقایسه‌اش متنی بود
   (dueDate < today) و تاریخ‌ها با رقمِ فارسی ذخیره می‌شوند، پس
   «۱۴۰۵/۰۸/۲۰» هیچ‌وقت از «1405/08/24» کوچک‌تر نمی‌شد. قابلیتی که
   بود و کار نمی‌کرد.

   مرزها: فاکتورِ تسویه‌شده هرچقدر هم سررسیدش گذشته باشد کاری با
   کسی ندارد، و سررسیدِ آینده هم نه. */
import { launch, calm } from './pw.mjs';
import { readFileSync } from 'node:fs';
import { todayJalali } from './seed.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

console.log('===== سیم‌کشی =====');
{
  const src = readFileSync(new URL('../public/_t/fin.tpl', import.meta.url), 'utf8');
  t(/function invoiceLate/.test(src) && /function payableLate/.test(src), 'توابعِ سررسیدِ گذشته هستند');
  t(/function odMoreLines/.test(src), 'و خط‌های نوار را می‌سازد');
  t(!/p\.dueDate && p\.dueDate < today/.test(src), 'مقایسهٔ متنیِ تاریخ دیگر نیست');
  t(/invoiceLate\(i\) > 0/.test(src), 'کارتِ «معوق» تاریخ را هم می‌بیند');
  const eng = readFileSync(new URL('../public/_t/p/overdue.tpl', import.meta.url), 'utf8');
  t(/function odPastDate/.test(eng) && /DatePick\.parse/.test(eng),
    'تاریخ با همان تقویمِ کارتابل خوانده می‌شود، نه با مقایسهٔ متن');
}

async function cookiesFor(api, pass) {
  const r = await fetch(BASE + '/api/' + api + '/login', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST }, body: JSON.stringify({ password: pass }) });
  return (r.headers.getSetCookie ? r.headers.getSetCookie() : []).map(c => {
    const kv = c.split(';')[0];
    return { name: kv.split('=')[0], value: kv.slice(kv.indexOf('=') + 1), domain: HOST, path: '/' };
  });
}

const now = todayJalali();
const faD = s => String(s).replace(/[0-9]/g, d => '۰۱۲۳۴۵۶۷۸۹'[d]);
const ymd = day => faD(now.jy) + '/' + faD(String(now.jm).padStart(2, '0')) + '/' + faD(String(day).padStart(2, '0'));

console.log('===== کارتابلِ مالی =====');
if (now.jd <= 2 || now.jd >= 28) {
  t(true, 'امروز نزدیکِ سرِ یا تهِ ماه است — سنجهٔ سررسید در همین ماه معنا ندارد', now.jd + '');
} else {
  const past = ymd(now.jd - 1), future = ymd(now.jd + 1);
  const b = await launch();
  const ctx = await b.newContext({ viewport: { width: 1500, height: 950 } });
  await ctx.addCookies(await cookiesFor('sina', process.env.VS_FIN_PASS || 'sinasinasina'));
  const p = await ctx.newPage();
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
  await p.goto('http://' + HOST + ':' + PORT + '/sina/', { waitUntil: 'load' });
  await p.waitForTimeout(3800); await calm(p);

  const o = await p.evaluate(([past, future]) => {
    const n0 = { inv: invoicesData.length, pay: payablesData.length };
    invoicesData.push(
      { invoiceNo: 'T1', customer: 'الف', date: '', dueDate: past, amount: 1000, paid: 0, status: 'جزئی', enteredBy: '' },
      { invoiceNo: 'T2', customer: 'ب', date: '', dueDate: past, amount: 500, paid: 500, status: 'پرداخت‌شده', enteredBy: '' },
      { invoiceNo: 'T3', customer: 'ج', date: '', dueDate: future, amount: 800, paid: 0, status: 'جزئی', enteredBy: '' });
    payablesData.push(
      { beneficiary: 'د', project: '', dueDate: past, subject: '', amount: 300, enteredBy: '' },
      { beneficiary: 'ه', project: '', dueDate: future, subject: '', amount: 200, enteredBy: '' });
    renderCards(); renderInvoices(); renderPayables(); renderOverdueBar();
    return { base: n0,
             late: lateInvoices().map(i => i.invoiceNo),
             latePay: latePayables().length,
             days: invoiceLate(invoicesData.find(i => i.invoiceNo === 'T1')),
             stat: computeFinanceStats().overdueInvoices,
             bar: (document.getElementById('odBar') || {}).innerText || '',
             cells: document.querySelectorAll('#view-invoices td.od-cell').length,
             payCells: document.querySelectorAll('#view-payables td.od-cell').length };
  }, [past, future]);

  t(o.late.length === 1 && o.late[0] === 'T1', 'فقط فاکتورِ سررسیدگذشته‌ی مانده‌دار شمرده شد', o.late.join('،') || 'هیچ');
  t(o.days === 1, 'و فاصله‌اش درست حساب شد', o.days + ' روز');
  t(o.latePay === 1, 'در بدهی‌ها هم همین‌طور', o.latePay + '');
  t(o.stat >= 1, 'کارتِ «فاکتورهای معوق» آن را می‌شمارد', o.stat + '');
  t(/فاکتور.*سررسیدش گذشته/.test(o.bar), 'نوارِ داشبورد خبرش را می‌دهد');
  t(/بدهی.*سررسیدش گذشته/.test(o.bar), 'برای بدهی‌ها هم');
  t(o.cells >= 1, 'و خانهٔ سررسید در جدول نشانه دارد', o.cells + ' خانه');
  t(o.payCells >= 1, 'در جدولِ بدهی‌ها هم', o.payCells + ' خانه');

  /* تسویه که شد، باید خاموش شود */
  const after = await p.evaluate(() => {
    const i = invoicesData.find(x => x.invoiceNo === 'T1');
    i.paid = i.amount;
    renderCards(); renderInvoices(); renderOverdueBar();
    return { late: lateInvoices().length,
             bar: (document.getElementById('odBar') || {}).innerText || '' };
  });
  t(after.late === 0, 'فاکتورِ تسویه‌شده دیگر سررسیدگذشته نیست');
  t(!/فاکتور.*سررسیدش گذشته/.test(after.bar), 'و از نوار هم می‌رود');

  t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
  await b.close();
}

console.log(ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
