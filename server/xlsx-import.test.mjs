import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
const DIR = '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/kt/';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });

async function open() {
  const p = await b.newPage({ viewport: { width: 1440, height: 950 } });
  p.__errs = [];
  p.on('pageerror', e => p.__errs.push(String(e).slice(0, 200)));
  p.on('dialog', d => d.accept());
  await p.goto('http://127.0.0.1:8894/', { waitUntil: 'networkidle' });
  await p.waitForTimeout(1400);
  await p.evaluate(() => { const g = document.getElementById('gateScreen'); if (g) { g.hidden = true; g.innerHTML = ''; } });
  await p.waitForTimeout(400);
  return p;
}
async function feed(p, file, viewBtn) {
  await p.evaluate(x => document.querySelector(`[data-view="${x}"]`).click(), viewBtn);
  await p.waitForTimeout(400);
  const chooser = p.waitForEvent('filechooser');
  await p.evaluate(() => document.getElementById('refreshMvpnBtn')
    ? document.getElementById('refreshMvpnBtn').click()
    : document.getElementById('refreshExcelBtn').click());
  const fc = await chooser;
  await fc.setFiles(DIR + file);
  await p.waitForTimeout(2200);
}
const status = p => p.evaluate(() => {
  const el = document.getElementById('mvpnSyncStatus') || document.getElementById('backupSyncStatus');
  return el ? el.textContent : '';
});

/* ---------- ۱) فایلِ مردمی: Sheet1، سرستونِ فارسی، ستون‌ها جابه‌جا ---------- */
console.log('— فایلی که نامِ برگه‌اش Sheet1 است و سرستونش فارسی —');
{
  const p = await open();
  await feed(p, 'mvpn-mardomi.xlsx', 'mvpn');
  const r = await p.evaluate(() => ({
    n: (mvpnData && mvpnData.lines || []).length,
    first: (mvpnData && mvpnData.lines || [])[0] || null,
    rows: document.querySelectorAll('#mvpnBody tr').length,
    heads: [...document.querySelectorAll('#view-mvpn thead tr:first-child th')].map(x => x.textContent.trim()),
    xtra: [...document.querySelectorAll('#view-mvpn [data-xtra]')].length
  }));
  const st = await status(p);
  t(r.n === 3, 'هر سه ردیف خوانده شد', r.n + ' ردیف');
  t(r.first && r.first.phone === '09121234567', 'شماره سرِ جای خودش نشست', r.first && r.first.phone);
  t(r.first && r.first.owner === 'سیامک لاهوری', 'و مالک هم — با اینکه ستونِ اول بود نه دوم', r.first && r.first.owner);
  t(r.first && r.first.plan === 'سازمانی ۲۰ گیگ', 'و طرح', r.first && r.first.plan);
  t(r.heads.includes('واحد') && r.heads.includes('تاریخ تحویل'),
    'ستون‌های ناشناخته هم ستونِ جدول شدند', r.heads.join(' | '));
  t(r.xtra > 0, 'و خانه‌هایشان پر است', r.xtra + ' خانه');
  t(/✓/.test(st) && /۳ ردیف/.test(st), 'و پیام راست می‌گوید', st.slice(0, 90));
  t(p.__errs.length === 0, 'بی‌خطا', p.__errs[0] || 'بی‌خطا');
  await p.close();
}

/* ---------- ۲) فایلِ خودِ کارتابل: نباید چیزی بشکند ---------- */
console.log('— فایلی که خودِ کارتابل ساخته —');
{
  const p = await open();
  await feed(p, 'kartabl-export.xlsx', 'mvpn');
  const r = await p.evaluate(() => ({
    mv: (mvpnData && mvpnData.lines || []).length,
    sv: (backupData && backupData.vm || []).length,
    first: (mvpnData && mvpnData.lines || [])[0] || null,
    sv1: (backupData && backupData.vm || [])[0] || null,
    xtra: [...document.querySelectorAll('#view-mvpn [data-xtra]')].length
  }));
  t(r.mv === 2, 'خطوط خوانده شد', r.mv + '');
  t(r.sv === 2, 'سرورها هم', r.sv + '');
  t(r.first && r.first.phone === '09120000001' && r.first.owner === 'الف', 'و درست نشست', JSON.stringify(r.first && [r.first.phone, r.first.owner]));
  t(r.sv1 && r.sv1.server === 'SRV-A' && r.sv1.location === 'DC1', 'سرور هم درست', JSON.stringify(r.sv1 && [r.sv1.server, r.sv1.location]));
  t(r.xtra === 0, 'و ستونِ اضافه‌ای نساخت', r.xtra + '');
  t(p.__errs.length === 0, 'بی‌خطا', p.__errs[0] || 'بی‌خطا');
  await p.close();
}

/* ---------- ۳) فایلی که هیچ ستونش را نمی‌شناسیم ---------- */
console.log('— فایلی که هیچ ستونش آشنا نیست —');
{
  const p = await open();
  await feed(p, 'bikhabar.xlsx', 'mvpn');
  const st = await status(p);
  const r = await p.evaluate(() => ({
    heads: [...document.querySelectorAll('#view-mvpn thead tr:first-child th')].map(x => x.textContent.trim()),
    n: (mvpnData && mvpnData.lines || []).length
  }));
  t(!/^✓/.test(st), 'دیگر الکی نمی‌گوید «✓ خوانده شد»', st.slice(0, 80));
  t(/هیچ ردیفی خوانده نشد/.test(st), 'و صریح می‌گوید چیزی نیامد');
  t(/Sheet1/.test(st), 'و می‌گوید در فایل چه برگه‌هایی بود');
  t(p.__errs.length === 0, 'بی‌خطا', p.__errs[0] || 'بی‌خطا');
  await p.close();
}

console.log('\n' + ok + ' ok، ' + bad + ' bad');
await b.close();
process.exit(bad ? 1 : 0);
