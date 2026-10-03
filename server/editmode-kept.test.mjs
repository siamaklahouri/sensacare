/* کلیدِ «تغییر» روشن بود و خانه‌ها قفل. دلیلش این بود که حالتِ ویرایش
   فقط همان لحظهٔ زدنِ کلید روی خانه‌ها نشانده می‌شد، ولی هر بازسازیِ
   بعدیِ جدول خانه‌ها را دوباره با contenteditable="false" می‌ساخت.
   پس کاربر کلید را می‌زد، یک ردیف می‌افزود، و از آن به بعد هیچ خانه‌ای
   را نمی‌توانست ویرایش کند — بی‌آنکه چیزی به او بگوید. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });

for (const [tag, port, view, addId, addVal] of [
  ['IT', 8894, 'servers', 'newServerName', 'سرورِ آزمون'],
  ['IT', 8894, 'mvpn', 'newMvpnPhone', '09120009999'],
  ['مالی', 8893, 'parties', 'newPartyName', 'طرفِ آزمون']
]) {
  const p = await b.newPage({ viewport: { width: 1440, height: 950 } });
  const errs = []; p.on('pageerror', e => errs.push(String(e).slice(0, 200)));
  p.on('dialog', d => d.accept());
  await p.goto('http://127.0.0.1:' + port + '/', { waitUntil: 'networkidle' });
  await p.waitForTimeout(1500);
  await p.evaluate(() => { const g = document.getElementById('gateScreen'); if (g) { g.hidden = true; g.innerHTML = ''; } });
  await p.waitForTimeout(300);
  console.log('\n===== ' + tag + ' / ' + view + ' =====');
  await p.evaluate(x => document.querySelector(`[data-view="${x}"]`).click(), view);
  await p.waitForTimeout(600);
  await p.evaluate(x => { document.querySelectorAll('#view-' + x + ' .edit-toggle-wrap input, #view-' + x + ' .del-toggle-wrap input')
    .forEach(i => { if (!i.checked) i.click(); }); }, view);
  await p.waitForTimeout(400);

  const h = await p.$('#' + addId);
  await h.click(); await h.fill(addVal);
  await p.evaluate(x => [...document.querySelectorAll('#view-' + x + ' tr.add-row button')]
    .filter(z => !z.classList.contains('cp-more'))[0].click(), view);
  await p.waitForTimeout(900);

  const st = await p.evaluate(x => {
    const tds = [...document.querySelectorAll('#view-' + x + ' tbody tr:not(.add-row) td.editable-cell')];
    const sw = [...document.querySelectorAll('#view-' + x + ' .edit-toggle-wrap input, #view-' + x + ' .del-toggle-wrap input')];
    return { on: sw.every(i => i.checked), cells: tds.length,
             editable: tds.filter(z => z.getAttribute('contenteditable') === 'true').length };
  }, view);
  t(st.on, 'کلیدِ «تغییر» هنوز روشن است');
  t(st.cells > 0, 'ردیفِ تازه ساخته شد', st.cells + ' خانه');
  t(st.cells > 0 && st.editable === st.cells,
    'بعد از افزودنِ ردیف هم همهٔ خانه‌ها ویرایش‌پذیر ماندند', st.editable + '/' + st.cells);

  /* و واقعاً هم بشود در آن نوشت */
  if (st.cells) {
    const typed = await p.evaluate(async x => {
      const td = document.querySelector('#view-' + x + ' tbody tr:not(.add-row) td.editable-cell');
      td.focus();
      return document.activeElement === td;
    }, view);
    t(typed, 'و خانه فوکوس می‌گیرد (می‌شود در آن نوشت)');
  }
  t(errs.length === 0, 'هیچ خطای صفحه‌ای رخ نداد', errs[0] || '');
  await p.close();
}
await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
