/* کاربر گفت: «کارها رو می‌نویسی، تا بین بخش‌ها جا‌به‌جا نشی روی کارتابل
   نمی‌شینه». این آزمون دقیقاً همان را می‌سنجد: بعد از افزودن، بی‌آنکه
   جایی برویم، ردیف باید همان لحظه روی صفحه باشد. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const p = await b.newPage({ viewport: { width: 1440, height: 950 } });
const errs = []; p.on('pageerror', e => errs.push(String(e).slice(0, 200)));
p.on('dialog', d => d.accept());
/* کتابخانهٔ اکسل عمداً نمی‌رسد — همان حالتی که کاربر در آن است:
   تازه وارد شده و هنوز سراغ اکسل نرفته. */
await p.route('**/v/xlsx.full.min.js', r => r.abort());
await p.route('**cdnjs**', r => r.abort());
await p.goto('http://127.0.0.1:8894/', { waitUntil: 'networkidle' });
await p.waitForTimeout(1500);
await p.evaluate(() => { const g = document.getElementById('gateScreen'); if (g) { g.hidden = true; g.innerHTML = ''; } });
t(await p.evaluate(() => typeof XLSX === 'undefined'), 'کتابخانهٔ اکسل بار نشده (همان حالتِ کاربر)');

/* ---- سرورها ---- */
await p.evaluate(() => document.querySelector('[data-view="servers"]').click());
await p.waitForTimeout(500);
const before = await p.evaluate(() => document.querySelectorAll('#serversBody tr').length);
await p.evaluate(() => {
  document.getElementById('newServerName').value = 'SRV-NEW';
  document.getElementById('addServerBtn').click();
});
await p.waitForTimeout(600);
const sv = await p.evaluate(() => ({
  rows: document.querySelectorAll('#serversBody tr').length,
  shown: [...document.querySelectorAll('#serversBody tr')].some(tr => tr.textContent.includes('SRV-NEW')),
  inState: (backupData && backupData.vm || []).some(m => m.server === 'SRV-NEW')
}));
t(sv.inState, 'سرور در داده نشست');
t(sv.shown, 'و همان لحظه روی صفحه آمد — بی‌آنکه جایی برویم', sv.rows + ' ردیف (قبلاً ' + before + ')');

/* ---- MVPN ---- */
await p.evaluate(() => document.querySelector('[data-view="mvpn"]').click());
await p.waitForTimeout(500);
await p.evaluate(() => {
  document.getElementById('newMvpnPhone').value = '09120002222';
  document.getElementById('newMvpnOwner').value = 'آزمون';
  document.getElementById('addMvpnBtn').click();
});
await p.waitForTimeout(600);
const mv = await p.evaluate(() => ({
  shown: [...document.querySelectorAll('#mvpnBody tr')].some(tr => tr.textContent.includes('09120002222')),
  inState: (mvpnData && mvpnData.lines || []).some(l => l.phone === '09120002222')
}));
t(mv.inState, 'خط در داده نشست');
t(mv.shown, 'و همان لحظه روی صفحه آمد');

/* ---- چک‌لیست ---- */
await p.evaluate(() => document.querySelector('[data-view="checklist"]').click());
await p.waitForTimeout(500);
const n0 = await p.evaluate(() => document.querySelectorAll('#checklistBody tr').length);
await p.evaluate(() => document.getElementById('addTaskBtn').click());
await p.waitForTimeout(600);
const ck = await p.evaluate(n => ({
  rows: document.querySelectorAll('#checklistBody tr').length,
  grew: document.querySelectorAll('#checklistBody tr').length === n + 1
}), n0);
t(ck.grew, 'وظیفهٔ تازه همان لحظه در جدول آمد', n0 + ' → ' + ck.rows);

/* ---- حذف هم همان‌طور ---- */
await p.evaluate(() => document.querySelectorAll('#checklistBody .btn-del')[0].click());
await p.waitForTimeout(600);
t(await p.evaluate(n => document.querySelectorAll('#checklistBody tr').length === n, n0),
  'و حذف هم همان لحظه نشست');

t(errs.length === 0, 'و هیچ خطایی نداد', errs[0] || 'بی‌خطا');
console.log('\n' + ok + ' ok، ' + bad + ' bad');
await b.close();
process.exit(bad ? 1 : 0);
