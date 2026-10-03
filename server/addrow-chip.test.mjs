/* پیکانِ «دیدنِ متنِ کامل» یک <button> است که کنارِ خانه گذاشته می‌شود.
   در ردیفِ «افزودن» دو جور خرابی می‌کرد:

   یک) روی خانهٔ باریک می‌افتاد و کلیکِ کاربر را می‌دزدید — کسی که
   می‌خواست نشانگر را جایی از متنش بگذارد، پنجرهٔ «متنِ کامل» می‌گرفت.

   دو) چون دکمه است و اولِ ردیف گذاشته می‌شد، اولین <button> ردیف
   می‌شد و جای دکمهٔ «افزودن» را می‌گرفت.

   در ردیفِ افزودن اصلاً به این پیکان نیازی نیست: آن‌جا جای نوشتن است،
   نه خواندنِ یک متنِ بلندِ ذخیره‌شده. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });

const LONG = 'یادداشتِ بسیار بلندی که در هیچ خانهٔ باریکی جا نمی‌شود و باید از قابش بیرون بزند';

for (const [tag, port, view, ids] of [
  ['IT', 8894, 'mvpn', ['newMvpnPhone', 'newMvpnOwner']],
  ['مالی', 8893, 'parties', null]
]) {
  const p = await b.newPage({ viewport: { width: 1440, height: 950 } });
  const errs = []; p.on('pageerror', e => errs.push(String(e).slice(0, 200)));
  p.on('dialog', d => d.accept());
  await p.goto('http://127.0.0.1:' + port + '/', { waitUntil: 'networkidle' });
  await p.waitForTimeout(1500);
  await p.evaluate(() => { const g = document.getElementById('gateScreen'); if (g) { g.hidden = true; g.innerHTML = ''; } });
  await p.waitForTimeout(300);
  console.log('\n===== کارتابل ' + tag + ' =====');
  await p.evaluate(x => document.querySelector(`[data-view="${x}"]`).click(), view);
  await p.waitForTimeout(600);
  await p.evaluate(x => { document.querySelectorAll('#view-' + x + ' .edit-toggle-wrap input, #view-' + x + ' .del-toggle-wrap input')
    .forEach(i => { if (!i.checked) i.click(); }); }, view);
  await p.waitForTimeout(400);

  const fields = ids || await p.evaluate(x => [...document.querySelectorAll('#view-' + x + ' tr.add-row input[type=text]')]
    .filter(i => i.offsetParent !== null).slice(0, 2).map(i => i.id), view);
  t(fields.length > 0, 'خانه‌های ردیفِ افزودن پیدا شدند', fields.join(','));

  /* متنی بلند بنویس تا اگر پیکانی ساخته می‌شود، ساخته شود */
  for (const id of fields) {
    const h = await p.$('#' + id);
    if (!h) continue;
    await h.click();
    await h.fill(LONG);
    await p.waitForTimeout(80);
  }
  await p.waitForTimeout(500);

  const st = await p.evaluate(x => {
    const r = document.querySelector('#view-' + x + ' tr.add-row');
    const btns = [...r.querySelectorAll('button')];
    return { chips: r.querySelectorAll('.cp-more').length,
             firstBtn: btns.length ? (btns[0].id || btns[0].className) : '-',
             firstIsChip: btns.length ? btns[0].classList.contains('cp-more') : false };
  }, view);
  t(st.chips === 0, 'هیچ پیکانِ «متنِ کامل» در ردیفِ افزودن نیامد', st.chips + ' پیکان');
  t(!st.firstIsChip, 'اولین دکمهٔ ردیف همان دکمهٔ افزودن است، نه پیکان', st.firstBtn);

  /* و کلیک روی خانه باید نشانگر بگذارد، نه پنجره باز کند */
  const h0 = await p.$('#' + fields[0]);
  await h0.click({ timeout: 6000 }).catch(() => {});
  await p.waitForTimeout(300);
  const popOpen = await p.evaluate(() => !!document.querySelector('.cp-back:not([hidden])'));
  t(!popOpen, 'کلیک روی خانهٔ ردیفِ افزودن پنجره باز نمی‌کند');
  t(await p.evaluate(i => document.activeElement && document.activeElement.id === i, fields[0]),
    'و خودِ خانه فوکوس گرفت');

  /* ولی در ردیف‌های معمولی پیکان باید سرِ جایش بماند — وگرنه این اصلاح
     بیش از اندازه بریده و قابلیتِ «دیدنِ متنِ کامل» را از کل جدول گرفته.
     پس یک ردیفِ واقعی می‌سازیم و همان متنِ بلند را در آن می‌نویسیم. */
  await p.evaluate(x => [...document.querySelectorAll('#view-' + x + ' tr.add-row button')]
    .filter(z => !z.classList.contains('cp-more'))[0].click(), view);
  await p.waitForTimeout(800);
  const normal = await p.evaluate(x => { document.querySelectorAll('#view-' + x + ' .edit-toggle-wrap input, #view-' + x + ' .del-toggle-wrap input')
      .forEach(i => { if (!i.checked) i.click(); });
    const rows = [...document.querySelectorAll('#view-' + x + ' tbody tr')].filter(r => !r.classList.contains('add-row'));
    if (!rows.length) return 'no-rows';
    const f = rows[0].querySelector('td input[type=text], td textarea');
    return f ? (f.id || 'ok') : 'no-field';
  }, view);
  if (normal !== 'no-rows' && normal !== 'no-field') {
    await p.waitForTimeout(400);
    const h = await p.$('#view-' + view + ' tbody tr:not(.add-row) td input[type=text], #view-' + view + ' tbody tr:not(.add-row) td textarea');
    await h.click();
    await h.fill(LONG);
    await p.waitForTimeout(500);
    const n = await p.evaluate(x => [...document.querySelectorAll('#view-' + x + ' tbody tr')]
      .filter(r => !r.classList.contains('add-row'))
      .reduce((s, r) => s + r.querySelectorAll('.cp-more').length, 0), view);
    t(n > 0, 'در ردیفِ معمولی پیکان همچنان کار می‌کند', n + ' پیکان');
    /* و همان پیکان باید پنجره را باز کند */
    if (n > 0) {
      await p.evaluate(x => document.querySelector('#view-' + x + ' tbody tr:not(.add-row) .cp-more').click(), view);
      await p.waitForTimeout(400);
      const got = await p.evaluate(() => { const q = document.querySelector('.cp-back:not([hidden])');
        return q ? (q.querySelector('.cp-f').value || '') : null; });
      t(got !== null && got.indexOf('یادداشتِ بسیار بلند') === 0, 'و با زدنش متنِ کامل را نشان می‌دهد');
      await p.keyboard.press('Escape');
      await p.waitForTimeout(200);
    }
  } else {
    console.log('   --   ردیفِ معمولی برای سنجش نبود (' + normal + ')');
  }
  t(errs.length === 0, 'هیچ خطای صفحه‌ای رخ نداد', errs[0] || '');
  await p.close();
}
await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
