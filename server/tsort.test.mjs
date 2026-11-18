/* مرتب‌سازی و فیلترِ ستونی.

   دو چیز سنجیده می‌شود که هر کدامشان اگر خراب باشد بی‌صدا خراب است:

   ۱) ترتیب باید عددی و تاریخی باشد، نه رشته‌ای. «۱۰» از «۹» کوچک‌تر
      نیست و «۱۴۰۵/۰۲/۳۰» از «۱۴۰۵/۱۰/۰۱» بزرگ‌تر نیست — مقایسهٔ
      رشته‌ای هر دو را وارونه می‌گوید و کسی هم متوجه نمی‌شود، چون
      جدولِ مرتب‌شده همیشه مرتب به نظر می‌رسد.

   ۲) مرتب‌سازی نباید به داده دست بزند. نما عوض می‌شود، state.tasks
      همان است که بود. اگر داده هم جابه‌جا شود، «برگرداندنِ حذف»
      ردیف را سرِ جای غلط می‌نشاند. */
import { launch, calm } from './pw.mjs';
import { readFileSync } from 'node:fs';
import { ensureTasks, PRIORITY_ROWS } from './seed.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

console.log('===== سیم‌کشی =====');
{
  const js = readFileSync(new URL('../public/_t/p/tsort.tpl', import.meta.url), 'utf8');
  const css = readFileSync(new URL('../public/_t/p/tsortcss.tpl', import.meta.url), 'utf8');
  t(!/<\/?(script|style)\b/i.test(js) && !/<!--/.test(js), 'جزوِ موتور تگ ندارد');
  t(!/<\/?(script|style)\b/i.test(css), 'جزوِ شیوه‌نامه تگ ندارد');
  t(/ROWDRAG\.ids\(\)/.test(js), 'فهرستِ جدول‌ها از ROWDRAG می‌آید، نه از فهرستِ دوم');
  t(/DatePick\.toStamp/.test(js), 'تاریخ از تقویمِ خودمان رد می‌شود');
  const rd = readFileSync(new URL('../public/_t/p/rowdrag.tpl', import.meta.url), 'utf8');
  t(/ids: ids/.test(rd), 'و ROWDRAG آن فهرست را می‌دهد');
  for (const f of ['it.tpl', 'fin.tpl']) {
    const src = readFileSync(new URL('../public/_t/' + f, import.meta.url), 'utf8');
    t(src.indexOf('{{PART:rowdrag}}') < src.indexOf('{{PART:tsort}}'),
      f + ': پس از rowdrag بار می‌شود', 'وگرنه ROWDRAG.ids هنوز نیست');
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

/* ---------- کارتابل فنی: چک‌لیست ---------- */
{
  console.log('===== چک‌لیستِ کارتابل فنی =====');
  await ensureTasks(BASE, HOST, 'kartabl', process.env.VS_IT_PASS || 'siamaksiamak',
    ts => ts.length >= 3, PRIORITY_ROWS);
  const ctx = await b.newContext({ viewport: { width: 1500, height: 900 } });
  await ctx.addCookies(await cookiesFor('kartabl', process.env.VS_IT_PASS || 'siamaksiamak'));
  const p = await ctx.newPage();
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
  await p.goto('http://' + HOST + ':' + PORT + '/siamak/', { waitUntil: 'load' });
  await p.waitForTimeout(3800); await calm(p);
  await p.evaluate(() => { const x = document.querySelector('.navbtn[data-view="checklist"]'); if (x) x.click(); });
  await p.waitForTimeout(900);

  const built = await p.evaluate(() => {
    const tbl = document.getElementById('checklistBody').closest('table');
    return { heads: tbl.querySelectorAll('th.ts-h').length, boxes: tbl.querySelectorAll('.ts-f').length };
  });
  t(built.heads > 3, 'سرستون‌ها مرتب‌شونده شدند', built.heads + ' ستون');
  t(built.boxes > 3, 'و هر کدام یک فیلتر گرفتند', built.boxes + ' کادر');

  /* مهلت‌ها را عددی و به‌هم‌ریخته می‌کنیم تا ترتیب معنا داشته باشد */
  const col = await p.evaluate(() => {
    const tbl = document.getElementById('checklistBody').closest('table');
    const ths = [...tbl.querySelectorAll('th.ts-h')];
    const th = ths.find(x => x.textContent.includes('وظیفه'));
    return th ? +th.getAttribute('data-col') : -1;
  });
  t(col > 0, 'ستونِ «وظیفه» پیدا شد', 'شمارهٔ ' + col);

  await p.evaluate(c => {
    state.tasks[0].task = 'ی آخر';
    state.tasks[1].task = 'الف اول';
    state.tasks[2].task = 'ب دوم';
    renderChecklist();
  }, col);
  await p.waitForTimeout(600);

  const read = () => p.evaluate(c => [...document.querySelectorAll('#checklistBody tr')]
    .filter(tr => !tr.classList.contains('add-row') && tr.style.display !== 'none' && tr.children.length > 2)
    .map(tr => { const td = tr.children[c]; const f = td.querySelector('input,select,textarea');
                 return (f ? f.value : td.textContent).trim(); }), col);

  const before = await read();
  const data0 = await p.evaluate(() => state.tasks.map(x => x.task).join('|'));

  await p.evaluate(c => document.getElementById('checklistBody').closest('table')
    .querySelector('th.ts-h[data-col="' + c + '"]').click(), col);
  await p.waitForTimeout(400);
  const asc = await read();
  t(asc[0] === 'الف اول' && asc[asc.length - 1] === 'ی آخر',
    'کلیکِ اول: صعودی', asc.join(' | '));

  await p.evaluate(c => document.getElementById('checklistBody').closest('table')
    .querySelector('th.ts-h[data-col="' + c + '"]').click(), col);
  await p.waitForTimeout(400);
  const desc = await read();
  t(desc[0] === 'ی آخر', 'کلیکِ دوم: نزولی', desc.join(' | '));

  const data1 = await p.evaluate(() => state.tasks.map(x => x.task).join('|'));
  t(data0 === data1, 'و داده دست‌نخورده ماند — فقط نما عوض شد');
  t(await p.evaluate(() => !!document.querySelector('table[data-tsorted]')),
    'جدول خودش را «مرتب» نشان می‌دهد');
  t(await p.evaluate(() => {
    const g = document.querySelector('#checklistBody .rd-grip');
    return !g || /خاموش/.test(g.title);
  }), 'و دستهٔ کشیدن می‌گوید خاموش است');

  await p.evaluate(c => document.getElementById('checklistBody').closest('table')
    .querySelector('th.ts-h[data-col="' + c + '"]').click(), col);
  await p.waitForTimeout(400);
  const back = await read();
  t(back.join('|') === before.join('|'), 'کلیکِ سوم: همان ترتیبِ دستیِ خودت',
    back.join(' | '));
  t(await p.evaluate(() => !document.querySelector('table[data-tsorted]')),
    'و نشانِ «مرتب» برداشته شد');

  /* ---- فیلتر ---- */
  await p.evaluate(c => {
    const i = document.getElementById('checklistBody').closest('table')
      .querySelector('.ts-f[data-col="' + c + '"]');
    i.value = 'الف'; i.dispatchEvent(new Event('input', { bubbles: true }));
  }, col);
  await p.waitForTimeout(400);
  const few = await read();
  t(few.length === 1 && few[0] === 'الف اول', 'فیلترِ ستونی فقط همان را می‌گذارد',
    few.join(' | '));
  t(await p.evaluate(() => state.tasks.length) === 3, 'و داده را حذف نمی‌کند');

  await p.evaluate(c => {
    const i = document.getElementById('checklistBody').closest('table')
      .querySelector('.ts-f[data-col="' + c + '"]');
    i.value = 'چیزی که نیست'; i.dispatchEvent(new Event('input', { bubbles: true }));
  }, col);
  await p.waitForTimeout(400);
  t(await p.evaluate(() => !!document.querySelector('#checklistBody .ts-none')),
    'و جدولِ خالی می‌گوید چرا خالی است');

  await p.evaluate(c => {
    const i = document.getElementById('checklistBody').closest('table')
      .querySelector('.ts-f[data-col="' + c + '"]');
    i.focus(); i.value = 'چیزی که نیست';
  }, col);
  await p.keyboard.press('Escape');
  await p.waitForTimeout(400);
  const all = await read();
  t(all.length === 3, 'Escape فیلتر را پاک می‌کند', all.length + ' ردیف');

  t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
  await ctx.close();
}

/* ---------- کارتابل مالی: عدد و تاریخ ---------- */
{
  console.log('===== فاکتورهای کارتابل مالی =====');
  const ctx = await b.newContext({ viewport: { width: 1500, height: 900 } });
  await ctx.addCookies(await cookiesFor('sina', process.env.VS_FIN_PASS || 'sinasinasina'));
  const p = await ctx.newPage();
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
  await p.goto('http://' + HOST + ':' + PORT + '/sina/', { waitUntil: 'load' });
  await p.waitForTimeout(3800); await calm(p);
  await p.evaluate(() => { const x = document.querySelector('.navbtn[data-view="invoices"]'); if (x) x.click(); });
  await p.waitForTimeout(700);

  /* سه فاکتور با مبلغ و مهلتی که ترتیبِ رشته‌ایشان با ترتیبِ درست
     یکی نیست — همان تله‌ای که این آزمون برایش هست. */
  await p.evaluate(() => {
    invoicesData.length = 0;
    addInvoiceRow({ invoiceNo: 'A', customer: 'الف', amount: 9000, dueDate: '۱۴۰۵/۱۰/۰۱' });
    addInvoiceRow({ invoiceNo: 'B', customer: 'ب',  amount: 120000, dueDate: '۱۴۰۵/۰۲/۳۰' });
    addInvoiceRow({ invoiceNo: 'C', customer: 'پ',  amount: 80000, dueDate: '۱۴۰۵/۰۷/۱۵' });
    renderInvoices();
  });
  await p.waitForTimeout(600);

  const cols = await p.evaluate(() => {
    const tbl = document.getElementById('invoicesBody').closest('table');
    const o = {};
    [...tbl.querySelectorAll('th.ts-h')].forEach(th => {
      const s = th.textContent.trim();
      if (s.includes('مبلغ')) o.amount = +th.getAttribute('data-col');
      if (s.includes('سررسید') || s.includes('مهلت')) o.due = +th.getAttribute('data-col');
    });
    return o;
  });
  t(cols.amount >= 0, 'ستونِ مبلغ پیدا شد', String(cols.amount));

  const order = () => p.evaluate(() => [...document.querySelectorAll('#invoicesBody tr')]
    .filter(tr => !tr.classList.contains('add-row') && tr.style.display !== 'none' && tr.children.length > 2)
    .map(tr => tr.children[1].textContent.trim()));

  if (cols.amount >= 0) {
    await p.evaluate(c => document.getElementById('invoicesBody').closest('table')
      .querySelector('th.ts-h[data-col="' + c + '"]').click(), cols.amount);
    await p.waitForTimeout(400);
    const by = await order();
    t(by.join('') === 'ACB', 'مبلغ عددی مرتب می‌شود، نه رشته‌ای',
      by.join(' < ') + '  (۹۰۰۰ < ۸۰۰۰۰ < ۱۲۰۰۰۰)');
  }
  if (cols.due >= 0) {
    await p.evaluate(c => document.getElementById('invoicesBody').closest('table')
      .querySelector('th.ts-h[data-col="' + c + '"]').click(), cols.due);
    await p.waitForTimeout(400);
    const by = await order();
    t(by.join('') === 'BCA', 'و تاریخ تقویمی، نه حرف‌به‌حرف',
      by.join(' < ') + '  (۰۲/۳۰ < ۰۷/۱۵ < ۱۰/۰۱)');
  } else t(false, 'ستونِ سررسید پیدا شد');

  t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
  await ctx.close();
}

await b.close();
console.log(ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
