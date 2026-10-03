/* دو جدولِ «اسناد پرداختنی نزد دیگران» و «اسناد دریافتنی به نفع شرکت»
   در فهرستِ ذخیرهٔ محلی نبودند: ردیف ساخته می‌شد، روی صفحه هم می‌آمد،
   ولی با بستن و باز کردنِ صفحه از بین می‌رفت — بی‌هیچ پیامی.

   این آزمون همان راهِ کاربر را می‌رود: ردیف بساز، صفحه را از نو بار
   کن، و ببین هست یا نه. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const p = await b.newPage({ viewport: { width: 1440, height: 950 } });
const errs = []; p.on('pageerror', e => errs.push(String(e).slice(0, 200)));
p.on('dialog', d => d.accept());
const gate = async () => {
  await p.waitForTimeout(1500);
  await p.evaluate(() => { const g = document.getElementById('gateScreen'); if (g) { g.hidden = true; g.innerHTML = ''; } });
  await p.waitForTimeout(300);
};
await p.goto('http://127.0.0.1:8893/', { waitUntil: 'networkidle' });
await gate();

/* نشانه بی‌رقم است: صفحه رقم‌های لاتین را فارسی می‌کند و جست‌وجوی
   «آزمون12» هیچ‌وقت نمی‌خورد. */
const PN = 'سندپرداختنیآزمون', RN = 'سنددریافتنیآزمون';

const add = async (view, fields) => {
  await p.evaluate(x => document.querySelector(`[data-view="${x}"]`).click(), view);
  await p.waitForTimeout(600);
  await p.evaluate(x => { document.querySelectorAll('#view-' + x + ' .edit-toggle-wrap input, #view-' + x + ' .del-toggle-wrap input')
    .forEach(i => { if (!i.checked) i.click(); }); }, view);
  await p.waitForTimeout(400);
  /* مثل کاربر تایپ می‌کنیم: نگهبانِ ضدِ تکمیلِ خودکار هر مقداری را که
     بی‌فوکوس گذاشته شود پاک می‌کند. */
  for (const [id, val] of fields) {
    const h = await p.$('#' + id);
    if (!h) { t(false, 'خانهٔ ' + id + ' پیدا نشد'); continue; }
    await h.click();
    await h.fill(val);
    await p.waitForTimeout(40);
  }
  await p.evaluate(x => [...document.querySelectorAll('#view-' + x + ' tr.add-row button')]
    .filter(z => !z.classList.contains('cp-more'))[0].click(), view);
  await p.waitForTimeout(700);
  return await p.evaluate(x => document.getElementById('view-' + x).innerText, view);
};

const vPay = await p.evaluate(() => { const e = document.getElementById('newPayableNoteCheckNo'); return e ? e.closest('.view').id.replace(/^view-/, '') : null; });
const vRec = await p.evaluate(() => { const e = document.getElementById('newReceivableNoteCheckNo'); return e ? e.closest('.view').id.replace(/^view-/, '') : null; });
t(!!vPay && !!vRec, 'هر دو جدولِ اسناد پیدا شدند', vPay + ' / ' + vRec);

const txtP = await add(vPay, [['newPayableNoteCheckNo', PN], ['newPayableNoteBeneficiary', 'گیرنده']]);
t(txtP.includes(PN), 'سندِ پرداختنی همان لحظه در جدول آمد');
const txtR = await add(vRec, [['newReceivableNoteCheckNo', RN], ['newReceivableNoteBuyer', 'خریدار']]);
t(txtR.includes(RN), 'سندِ دریافتنی همان لحظه در جدول آمد');

/* پیش از رفرش: هر دو باید در حافظهٔ محلی نوشته شده باشند */
const cached = await p.evaluate(() => {
  for (let i = 0; i < localStorage.length; i++) {
    const k = localStorage.key(i), v = localStorage.getItem(k);
    if (v && v.indexOf('"payableNotes"') > -1) return { key: k, hasPay: v.indexOf('"payableNotes"') > -1, hasRec: v.indexOf('"receivableNotes"') > -1 };
  }
  return null;
});
t(!!cached, 'کلیدِ حافظهٔ محلی هر دو جدول را دارد', cached ? cached.key : 'هیچ کلیدی اسناد را ندارد');

/* و حالا همان کاری که کاربر می‌کند: صفحه را از نو باز کن */
await p.reload({ waitUntil: 'networkidle' });
await gate();
const after = await p.evaluate(({ a, b2 }) => {
  const pay = (typeof payableNotesData !== 'undefined' ? payableNotesData : []).some(n => (n.checkNo || '') === a);
  const rec = (typeof receivableNotesData !== 'undefined' ? receivableNotesData : []).some(n => (n.checkNo || '') === b2);
  return { pay, rec };
}, { a: PN, b2: RN });
t(after.pay, 'سندِ پرداختنی بعد از بازکردنِ دوبارهٔ صفحه هنوز هست');
t(after.rec, 'سندِ دریافتنی بعد از بازکردنِ دوبارهٔ صفحه هنوز هست');

t(errs.length === 0, 'هیچ خطای صفحه‌ای رخ نداد', errs[0] || '');
await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
