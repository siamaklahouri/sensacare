/* کاربر گفته بود متنِ بلند ردیف را سه‌برابر می‌کند و کلِ جدول را به هم
   می‌ریزد. راه‌حلِ آن وقت فقط روی خانه‌هایی نشست که <input> داشتند —
   و بیشترِ جدول‌ها اصلاً <input> ندارند: خودِ <td> با contenteditable
   نوشته می‌شود. پس در آن جدول‌ها هیچ‌چیز بریده نمی‌شد و یک یادداشتِ
   بلند ردیف را از ۲۸ به ۱۲۶ پیکسل می‌رساند.

   اینجا سه چیز سنجیده می‌شود:
     یک) ردیف با متنِ بلند هم کوتاه می‌ماند،
     دو) متنِ کامل از راهِ پنجره در دسترس است،
     سه) و مهم‌تر از همه: نشانهٔ «⌄» وارد خودِ داده نمی‌شود. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const LONG = 'این یک موضوعِ بسیار بلند است که کاربر در خانهٔ موضوع می‌نویسد و شرح کاملی از بابتِ چک و قرارداد و توافقِ طرفین را در خود دارد و هیچ جوره در یک خط جا نمی‌شود';
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });

for (const [tag, port, view, fields, store] of [
  ['مالی', 8893, 'payablenotes',
    [['newPayableNoteCheckNo', 'چکِ آزمون'], ['newPayableNoteBeneficiary', 'گیرنده'], ['newPayableNoteSubject', LONG]],
    () => payableNotesData],
  ['IT', 8894, 'servers',
    [['newServerName', 'سرورِ آزمون'], ['newServerLocation', LONG]],
    () => (backupData && backupData.vm) || []]
]) {
  const p = await b.newPage({ viewport: { width: 1440, height: 950 } });
  const errs = []; p.on('pageerror', e => errs.push(String(e).slice(0, 200)));
  p.on('dialog', d => d.accept());
  await p.goto('http://127.0.0.1:' + port + '/', { waitUntil: 'networkidle' });
  await p.waitForTimeout(1500);
  await p.evaluate(() => { const g = document.getElementById('gateScreen'); if (g) { g.hidden = true; g.innerHTML = ''; } });
  await p.waitForTimeout(300);
  console.log('\n===== کارتابل ' + tag + ' / ' + view + ' =====');
  await p.evaluate(x => document.querySelector(`[data-view="${x}"]`).click(), view);
  await p.waitForTimeout(600);
  await p.evaluate(x => { document.querySelectorAll('#view-' + x + ' .edit-toggle-wrap input, #view-' + x + ' .del-toggle-wrap input')
    .forEach(i => { if (!i.checked) i.click(); }); }, view);
  await p.waitForTimeout(400);
  for (const [id, v] of fields) {
    const h = await p.$('#' + id);
    if (!h) { t(false, 'خانهٔ ' + id + ' نبود'); continue; }
    await h.click(); await h.fill(v); await p.waitForTimeout(50);
  }
  await p.evaluate(x => [...document.querySelectorAll('#view-' + x + ' tr.add-row button')]
    .filter(z => !z.classList.contains('cp-more'))[0].click(), view);
  await p.waitForTimeout(900);

  const r = await p.evaluate(x => {
    const rows = [...document.querySelectorAll('#view-' + x + ' tbody tr')].filter(z => !z.classList.contains('add-row'));
    if (!rows.length) return null;
    const tbl = rows[0].closest('table');
    const wrap = tbl.closest('.table-wrap') || tbl.parentElement;
    const cells = [...rows[0].querySelectorAll('td.editable-cell')];
    const longOne = cells.filter(c => c.classList.contains('cp-long'));
    return { h: Math.round(rows[0].getBoundingClientRect().height),
             hScroll: wrap.scrollWidth > wrap.clientWidth + 2,
             nLong: longOne.length,
             /* هیچ عنصری نباید داخلِ خانهٔ contenteditable گذاشته شده باشد */
             kids: cells.reduce((s, c) => s + c.children.length, 0) };
  }, view);
  t(!!r, 'ردیفِ تازه ساخته شد');
  if (!r) { await p.close(); continue; }
  t(r.h <= 48, 'ردیف با متنِ بلند هم یک‌خطی ماند', r.h + 'px');
  t(!r.hScroll, 'جدول پهن‌تر از قابش نشد');
  t(r.nLong === 1, 'همان یک خانهٔ بلند نشانه گرفت', r.nLong + ' خانه');
  t(r.kids === 0, 'هیچ عنصری داخلِ خانهٔ ویرایش‌پذیر گذاشته نشد', r.kids + ' فرزند');

  /* داده نباید نشانهٔ «⌄» را گرفته باشد */
  const data = await p.evaluate(f => JSON.stringify(eval('(' + f + ')')()), store.toString());
  t(data.indexOf('⌄') === -1, 'نشانهٔ «⌄» وارد داده نشد');
  t(data.indexOf('هیچ جوره در یک خط جا نمی‌شود') > -1, 'متنِ بلند کامل در داده نشست');

  /* و پنجره متنِ کامل را می‌دهد */
  await p.evaluate(x => { const c = document.querySelector('#view-' + x + ' tbody tr:not(.add-row) td.editable-cell.cp-long');
    const r2 = c.getBoundingClientRect();
    const rtl = getComputedStyle(c).direction === 'rtl';
    c.dispatchEvent(new MouseEvent('click', { bubbles: true, clientX: rtl ? r2.left + 8 : r2.right - 8, clientY: r2.top + r2.height / 2 })); }, view);
  await p.waitForTimeout(400);
  const shown = await p.evaluate(() => { const q = document.querySelector('.cp-back:not([hidden])'); return q ? q.querySelector('.cp-f').value : null; });
  t(shown !== null, 'پنجرهٔ متنِ کامل باز شد');
  t(shown !== null && shown.indexOf('هیچ جوره در یک خط جا نمی‌شود') > -1, 'و متنِ کامل را نشان داد');
  t(shown !== null && shown.indexOf('⌄') === -1, 'و نشانه جزوِ متن نبود');
  /* ویرایش از توی همان پنجره باید در داده بنشیند: این خانه‌ها با blur
     ذخیره می‌شوند، نه با change — اگر blur فرستاده نشود متنِ تازه روی
     صفحه می‌نشیند و در داده نه، که بدترین حالت است. */
  await p.evaluate(() => { const f = document.querySelector('.cp-back:not([hidden]) .cp-f');
    f.value = 'متنِ ویرایش‌شده از پنجره'; f.dispatchEvent(new Event('input', { bubbles: true })); });
  await p.evaluate(() => document.querySelector('.cp-back:not([hidden]) .cp-ok').click());
  await p.waitForTimeout(600);
  const edited = await p.evaluate(f => JSON.stringify(eval('(' + f + ')')()), store.toString());
  t(edited.indexOf('متنِ ویرایش‌شده از پنجره') > -1, 'ویرایش از توی پنجره در داده نشست');
  t(edited.indexOf('⌄') === -1, 'و باز هم نشانه وارد داده نشد');
  t(await p.evaluate(() => !document.querySelector('.cp-back:not([hidden])')), 'پنجره بعد از ثبت بسته شد');

  /* و کلیک وسطِ خانهٔ باز باید نشانگر بگذارد، نه پنجره باز کند */
  await p.evaluate(x => { const c = document.querySelector('#view-' + x + ' tbody tr:not(.add-row) td.editable-cell');
    const r2 = c.getBoundingClientRect();
    c.dispatchEvent(new MouseEvent('click', { bubbles: true, clientX: r2.left + r2.width / 2, clientY: r2.top + r2.height / 2 })); }, view);
  await p.waitForTimeout(300);
  t(await p.evaluate(() => !document.querySelector('.cp-back:not([hidden])')),
    'کلیک وسطِ خانه پنجره باز نمی‌کند (جای ویرایش است)');

  t(errs.length === 0, 'هیچ خطای صفحه‌ای رخ نداد', errs[0] || '');
  await p.close();
}
await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
