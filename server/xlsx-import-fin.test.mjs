import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
const DIR = '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/kt/';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
async function open(){
  const p = await b.newPage({ viewport: { width: 1440, height: 950 } });
  p.__errs = []; p.on('pageerror', e => p.__errs.push(String(e).slice(0,200)));
  p.on('dialog', d => d.accept());
  await p.goto('http://127.0.0.1:8893/', { waitUntil: 'networkidle' });
  await p.waitForTimeout(1500);
  await p.evaluate(() => { const g = document.getElementById('gateScreen'); if (g) { g.hidden = true; g.innerHTML = ''; } });
  return p;
}
async function feed(p, file){
  await p.evaluate(() => document.querySelector('[data-view="invoices"]').click());
  await p.waitForTimeout(400);
  const ch = p.waitForEvent('filechooser');
  await p.evaluate(() => document.getElementById('refreshInvoicesBtn').click());
  (await ch).setFiles(DIR + file);
  await p.waitForTimeout(2400);
}
const st = p => p.evaluate(() => {
  const e = document.getElementById('invoicesSyncStatus') ||
            document.querySelector('[id$="SyncStatus"]');
  return e ? e.textContent : '';
});

console.log('— فایلِ مردمی: Sheet1 و سرستونِ فارسیِ جابه‌جا —');
{
  const p = await open();
  await feed(p, 'fin-mardomi.xlsx');
  const r = await p.evaluate(() => ({
    n: (invoicesData||[]).length, first: (invoicesData||[])[0] || null,
    heads: [...document.querySelectorAll('#view-invoices thead tr:first-child th')].map(x=>x.textContent.trim()),
    xtra: document.querySelectorAll('#view-invoices [data-xtra]').length
  }));
  const s = await st(p);
  t(r.n === 2, 'دو ردیف خوانده شد', r.n + '');
  t(r.first && r.first.customer === 'شرکت الف', 'مشتری درست نشست (ستونِ اول بود)', r.first && r.first.customer);
  t(r.first && String(r.first.invoiceNo) === '۱۰۰۱', 'شماره فاکتور هم', r.first && r.first.invoiceNo);
  t(r.first && r.first.amount === 5000000, 'و مبلغ', r.first && r.first.amount);
  t(r.first && r.first._x && r.first._x['مرکز هزینه'] === 'تهران', 'ستونِ ناشناخته نگه داشته شد', JSON.stringify(r.first && r.first._x));
  t(/✓/.test(s) && /۲ ردیف/.test(s), 'پیام راست می‌گوید', s.slice(0,80));
  t(p.__errs.length === 0, 'بی‌خطا', p.__errs[0] || 'بی‌خطا');
  await p.close();
}
console.log('— فایلی که خودِ کارتابل ساخته —');
{
  const p = await open();
  await feed(p, 'fin-export.xlsx');
  const r = await p.evaluate(() => ({
    inv: (invoicesData||[]).length, bank: (bankData||[]).length,
    first: (invoicesData||[])[0] || null
  }));
  const s = await st(p);
  t(r.inv === 1 && r.bank === 1, 'هر دو برگه خوانده شد', 'فاکتور ' + r.inv + ' · بانک ' + r.bank);
  t(r.first && r.first.customer === 'شرکت ج' && r.first.amount === 9000000, 'و درست نشست', JSON.stringify(r.first && [r.first.customer, r.first.amount]));
  t(/دست‌نخورده ماندند/.test(s), 'و می‌گوید بقیهٔ بخش‌ها دست‌نخورده ماندند', s.slice(-70));
  t(p.__errs.length === 0, 'بی‌خطا', p.__errs[0] || 'بی‌خطا');
  await p.close();
}
console.log('\n' + ok + ' ok، ' + bad + ' bad');
await b.close();
process.exit(bad ? 1 : 0);
