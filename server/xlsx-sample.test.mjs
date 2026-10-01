/* نمونهٔ اکسل: دانلود می‌شود، و همان فایل با خواندنِ خودِ کارتابل
   برمی‌گردد — یعنی حلقه واقعاً بسته است، نه اینکه فقط فایلی ساخته شود. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
import fs from 'node:fs';
const DIR = '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/kt/dl/';
fs.rmSync(DIR, { recursive: true, force: true }); fs.mkdirSync(DIR, { recursive: true });
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });

async function open(port) {
  const p = await b.newPage({ viewport: { width: 1440, height: 950 }, acceptDownloads: true });
  p.__errs = []; p.on('pageerror', e => p.__errs.push(String(e).slice(0, 200)));
  p.on('dialog', d => d.accept());
  await p.goto('http://127.0.0.1:' + port + '/', { waitUntil: 'networkidle' });
  await p.waitForTimeout(1500);
  await p.evaluate(() => { const g = document.getElementById('gateScreen'); if (g) { g.hidden = true; g.innerHTML = ''; } });
  return p;
}
async function grab(p, view, btn) {
  await p.evaluate(v => document.querySelector(`[data-view="${v}"]`).click(), view);
  await p.waitForTimeout(400);
  const dl = p.waitForEvent('download', { timeout: 15000 });
  await p.evaluate(id => document.getElementById(id).click(), btn);
  const d = await dl;
  const path = DIR + d.suggestedFilename();
  await d.saveAs(path);
  return path;
}

/* ---------- کارتابل IT ---------- */
console.log('— کارتابل IT: دکمهٔ نمونه —');
{
  const p = await open(8894);
  const btns = await p.evaluate(() => ['sampleServersBtn','sampleMvpnBtn','sampleCompaniesBtn','sampleRemoteBtn']
    .map(id => id + '=' + (document.getElementById(id) ? 'هست' : 'نیست')));
  t(btns.every(x => /هست/.test(x)), 'کنارِ هر دکمهٔ خواندن، دکمهٔ نمونه هست', btns.join(' '));

  const f = await grab(p, 'mvpn', 'sampleMvpnBtn');
  t(fs.existsSync(f) && fs.statSync(f).size > 2000, 'فایلِ نمونه دانلود شد',
    f.split('/').pop() + ' · ' + fs.statSync(f).size + ' بایت');
  const msg = await p.evaluate(() => document.getElementById('mvpnSyncStatus').textContent);
  t(/دانلود شد/.test(msg), 'و می‌گوید بعدش چه کند', msg.slice(0, 70));

  /* همان فایل را برمی‌گردانیم */
  await p.evaluate(() => { mvpnData = { lines: [] }; renderMvpn(); });
  await p.waitForTimeout(300);
  const ch = p.waitForEvent('filechooser');
  await p.evaluate(() => document.getElementById('refreshMvpnBtn').click());
  (await ch).setFiles(f);
  await p.waitForTimeout(2400);
  const back = await p.evaluate(() => ({
    n: (mvpnData && mvpnData.lines || []).length,
    first: (mvpnData && mvpnData.lines || [])[0] || null,
    st: document.getElementById('mvpnSyncStatus').textContent
  }));
  t(back.n === 2, 'و خودِ کارتابل همان را می‌خواند', back.n + ' ردیف');
  t(back.first && back.first.phone === '09120000001', 'شماره سرِ جایش', back.first && back.first.phone);
  t(back.first && back.first.plan === 'سازمانی ۲۰ گیگ', 'و طرح', back.first && back.first.plan);
  t(/✓/.test(back.st), 'و پیام سبز است', back.st.slice(0, 60));
  t(p.__errs.length === 0, 'بی‌خطا', p.__errs[0] || 'بی‌خطا');
  await p.close();
}

/* ---------- کارتابل مالی ---------- */
console.log('— کارتابل مالی: دکمهٔ نمونه —');
{
  const p = await open(8893);
  const ids = ['samplePartiesBtn','sampleInvoicesBtn','samplePayablesBtn','samplePayableNotesBtn',
               'sampleReceivableNotesBtn','sampleExpensesBtn','sampleBankBtn','sampleBudgetBtn'];
  const have = await p.evaluate(list => list.filter(id => document.getElementById(id)).length, ids);
  t(have === 8, 'هر هشت بخش دکمهٔ نمونه دارد', have + '/8');

  const f = await grab(p, 'invoices', 'sampleInvoicesBtn');
  t(fs.existsSync(f), 'نمونهٔ فاکتورها دانلود شد', f.split('/').pop());
  await p.evaluate(() => { invoicesData = []; renderInvoices(); });
  await p.waitForTimeout(300);
  const ch = p.waitForEvent('filechooser');
  await p.evaluate(() => document.getElementById('refreshInvoicesBtn').click());
  (await ch).setFiles(f);
  await p.waitForTimeout(2400);
  const back = await p.evaluate(() => ({ n: (invoicesData||[]).length, first: (invoicesData||[])[0] || null }));
  t(back.n === 2, 'و برگشت خوانده شد', back.n + ' ردیف');
  t(back.first && back.first.customer === 'شرکت نمونه' && back.first.amount === 50000000,
    'با همان مقدارها', JSON.stringify(back.first && [back.first.customer, back.first.amount]));
  t(p.__errs.length === 0, 'بی‌خطا', p.__errs[0] || 'بی‌خطا');
  await p.close();
}

console.log('\n' + ok + ' ok، ' + bad + ' bad');
await b.close();
process.exit(bad ? 1 : 0);
