/* جابه‌جا کردنِ ردیف‌ها با کشیدن — فقط وقتی کلیدِ «حذف/تغییر» باز است. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const AB = 'الفبپتثجچحخدذرزژسشصضطظعغ';
const rnd = () => 'ردیفِ' + Array.from({length:5}, () => AB[Math.floor(Math.random()*AB.length)]).join('');
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });

/* یک کشیدنِ واقعی: dragstart روی دسته، dragover و drop روی ردیفِ مقصد */
const dragTo = (p, view, fromIdx, toIdx, after) => p.evaluate(({ x, f, to, af }) => {
  const tb = document.querySelector('#view-' + x + ' tbody');
  const rows = [...tb.querySelectorAll('tr')].filter(r => !r.classList.contains('add-row') && r.children.length > 1);
  const src = rows[f], dst = rows[to];
  const grip = src.querySelector('.rd-grip');
  if (!grip) return 'no-grip';
  const dt = new DataTransfer();
  grip.dispatchEvent(new DragEvent('dragstart', { bubbles: true, dataTransfer: dt }));
  const r = dst.getBoundingClientRect();
  const y = r.top + (af ? r.height * 0.8 : r.height * 0.2);
  const opt = { bubbles: true, cancelable: true, dataTransfer: dt, clientX: r.left + 10, clientY: y };
  dst.dispatchEvent(new DragEvent('dragover', opt));
  dst.dispatchEvent(new DragEvent('drop', opt));
  src.dispatchEvent(new DragEvent('dragend', { bubbles: true, dataTransfer: dt }));
  return 'ok';
}, { x: view, f: fromIdx, to: toIdx, af: after });

for (const [tag, port, view, firstId, arrName] of [
  ['IT', 8894, 'servers', 'newServerName', 'backupData.vm'],
  ['مالی', 8893, 'parties', 'newPartyName', 'partiesData']
]) {
  const p = await b.newPage({ viewport: { width: 1440, height: 1000 } });
  const errs = []; p.on('pageerror', e => errs.push(String(e).slice(0, 180)));
  p.on('dialog', d => d.accept());
  await p.goto('http://127.0.0.1:' + port + '/', { waitUntil: 'networkidle' });
  await p.waitForTimeout(1600);
  await p.evaluate(() => { const g = document.getElementById('gateScreen'); if (g) { g.hidden = true; g.innerHTML = ''; } });
  await p.waitForTimeout(400);
  console.log('\n===== کارتابل ' + tag + ' / ' + view + ' =====');
  await p.evaluate(x => document.querySelector(`[data-view="${x}"]`).click(), view);
  await p.waitForTimeout(600);

  /* سه ردیف می‌سازیم تا جابه‌جایی معنی داشته باشد */
  await p.evaluate(x => { document.querySelectorAll('#view-' + x + ' .edit-toggle-wrap input, #view-' + x + ' .del-toggle-wrap input')
    .forEach(i => { if (!i.checked) i.click(); }); }, view);
  await p.waitForTimeout(400);
  const names = [];
  for (let k = 0; k < 3; k++) {
    const nm = rnd(); names.push(nm);
    const h = await p.$('#' + firstId);
    await h.click(); await h.fill(nm);
    await p.evaluate(x => [...document.querySelectorAll('#view-' + x + ' tr.add-row button')]
      .filter(z => !z.classList.contains('cp-more'))[0].click(), view);
    await p.waitForTimeout(500);
  }
  await p.waitForTimeout(500);

  t(await p.evaluate(x => document.querySelectorAll('#view-' + x + ' .rd-grip').length >= 3,
    view), 'با قفلِ باز، هر ردیف دستهٔ جابه‌جایی دارد',
    String(await p.evaluate(x => document.querySelectorAll('#view-' + x + ' .rd-grip').length, view)) + ' دسته');

  /* قفل را ببند: دسته‌ها باید بروند */
  await p.evaluate(x => { document.querySelectorAll('#view-' + x + ' .edit-toggle-wrap input, #view-' + x + ' .del-toggle-wrap input')
    .forEach(i => { if (i.checked) i.click(); }); }, view);
  await p.waitForTimeout(600);
  t(await p.evaluate(x => document.querySelectorAll('#view-' + x + ' .rd-grip').length === 0, view),
    'با قفلِ بسته، هیچ دسته‌ای نیست');

  /* دوباره باز کن و ردیفِ اول را به آخر ببر */
  await p.evaluate(x => { document.querySelectorAll('#view-' + x + ' .edit-toggle-wrap input, #view-' + x + ' .del-toggle-wrap input')
    .forEach(i => { if (!i.checked) i.click(); }); }, view);
  await p.waitForTimeout(600);
  const before = await p.evaluate(a => eval(a).map(r => r.server || r.name || ''), arrName);
  t(before.length === 3, 'سه ردیف ساخته شد', before.join(' | '));

  const res = await dragTo(p, view, 0, 2, true);
  t(res === 'ok', 'کشیدن انجام شد', res);
  await p.waitForTimeout(800);
  const after = await p.evaluate(a => eval(a).map(r => r.server || r.name || ''), arrName);
  t(after.length === 3, 'هیچ ردیفی گم یا تکراری نشد', after.join(' | '));
  t(after[2] === before[0], 'ردیفِ اول رفت به آخر', before[0] + ' → جای ' + after.indexOf(before[0]));
  t(after[0] === before[1] && after[1] === before[2], 'و بقیه یکی بالا آمدند');

  /* روی صفحه هم همان ترتیب دیده شود */
  const shown = await p.evaluate(x => [...document.querySelectorAll('#view-' + x + ' tbody tr')]
    .filter(r => !r.classList.contains('add-row') && r.children.length > 1)
    .map(r => [...r.children].map(td => { const f = td.querySelector('input,select'); return f ? f.value : (td.textContent || '').trim(); })
      .find(v => /^ردیفِ/.test(v)) || ''), view);
  t(JSON.stringify(shown) === JSON.stringify(after), 'ترتیبِ روی صفحه با ترتیبِ داده یکی است',
    shown.join(' | '));

  /* و بعد از رفرش هم بماند */
  await p.reload({ waitUntil: 'networkidle' });
  await p.waitForTimeout(1600);
  await p.evaluate(() => { const g = document.getElementById('gateScreen'); if (g) { g.hidden = true; g.innerHTML = ''; } });
  await p.waitForTimeout(500);
  const kept = await p.evaluate(a => { try { return eval(a).map(r => r.server || r.name || ''); } catch(e){ return null; } }, arrName);
  t(kept && JSON.stringify(kept) === JSON.stringify(after), 'ترتیبِ تازه بعد از رفرش هم ماند',
    kept ? kept.join(' | ') : 'داده نیامد');

  t(errs.length === 0, 'هیچ خطای صفحه‌ای رخ نداد', errs[0] || '');
  await p.close();
}
await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
