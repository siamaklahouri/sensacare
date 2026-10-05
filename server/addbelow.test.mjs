/* «دکمه اضاف: بیاد پایین تمام جدول ها به جای اینکه بالا باشه».

   این آزمون جای دکمه را با چشمِ مرورگر می‌سنجد، نه با ترتیبِ کد:
   هر چیزی که ردیف اضافه می‌کند — چه یک دکمهٔ «＋ افزودن» باشد، چه
   ردیفِ افزودنِ داخلِ خودِ جدول — باید پایین‌تر از آخرین ردیفِ داده
   بنشیند. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
let ok = 0, bad = 0; const found = [];
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; if (!c) found.push(m); };
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });

for (const [tag, port] of [['IT', 8894], ['مالی', 8893]]) {
  const p = await b.newPage({ viewport: { width: 1440, height: 1000 } });
  const errs = []; p.on('pageerror', e => errs.push(String(e).slice(0, 170)));
  p.on('dialog', d => d.accept());
  await p.goto('http://127.0.0.1:' + port + '/', { waitUntil: 'networkidle' });
  await p.waitForTimeout(1600);
  await p.evaluate(() => { const g = document.getElementById('gateScreen'); if (g) { g.hidden = true; g.innerHTML = ''; } });
  await p.waitForTimeout(400);
  console.log('\n===== کارتابل ' + tag + ' =====');

  const views = await p.evaluate(() => [...document.querySelectorAll('.navbtn')]
    .filter(x => x.offsetParent !== null).map(x => ({ v: x.getAttribute('data-view'), label: x.textContent.trim() })));

  for (const v of views) {
    await p.evaluate(x => document.querySelector(`[data-view="${x}"]`).click(), v.v);
    await p.waitForTimeout(450);
    const r = await p.evaluate(x => {
      const sec = document.getElementById('view-' + x);
      if (!sec) return null;
      const out = [];
      /* ۱) ردیفِ افزودنِ داخلِ جدول */
      sec.querySelectorAll('tr.add-row').forEach(row => {
        const tb = row.closest('tbody');
        const data = [...tb.querySelectorAll('tr')].filter(z => z !== row && z.children.length > 1);
        if (!data.length) return;                       /* جدولِ خالی، سنجشی ندارد */
        const last = data[data.length - 1];
        out.push({ what: 'ردیفِ افزودن', ok: row.getBoundingClientRect().top >= last.getBoundingClientRect().top });
      });
      /* ۲) دکمه‌های «＋ افزودن» بیرونِ جدول */
      sec.querySelectorAll('button').forEach(btn => {
        if (!/＋/.test(btn.textContent || '')) return;
        if (btn.offsetParent === null) return;
        if (btn.closest('tr.add-row')) return;          /* همان بالا سنجیده شد */
        /* نزدیک‌ترین جدولِ همین بخش */
        const tbls = [...sec.querySelectorAll('table')].filter(tb => tb.offsetParent !== null);
        if (!tbls.length) return;
        const bt = btn.getBoundingClientRect().top;
        /* باید پایین‌تر از پایانِ دستِ‌کم یکی از جدول‌ها باشد و از هیچ
           جدولی بالاتر نباشد */
        const above = tbls.filter(tb => bt < tb.getBoundingClientRect().top);
        out.push({ what: 'دکمهٔ «' + (btn.textContent || '').trim().slice(0, 18) + '»',
                   ok: above.length === 0,
                   d: above.length ? 'بالای ' + above.length + ' جدول است' : '' });
      });
      return out;
    }, v.v);
    if (!r || !r.length) continue;
    for (const one of r) t(one.ok, v.label + ' — ' + one.what + ' پایینِ جدول است', one.d || undefined);
  }
  t(errs.length === 0, 'هیچ خطای صفحه‌ای رخ نداد', errs[0] || '');
  await p.close();
}
await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
