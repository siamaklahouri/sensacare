import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });

for (const [name, port] of [['it', 8899], ['fin', 8898]]) {
  console.log('\n=== ' + name + ' ===');
  const p = await b.newPage({ viewport: { width: 1440, height: 950 } });
  await p.goto('http://127.0.0.1:' + port + '/', { waitUntil: 'networkidle' });
  await p.waitForTimeout(1300);
  await p.evaluate(() => { const g = document.getElementById('gateScreen'); if (g) { g.hidden = true; g.innerHTML = ''; } });
  await p.waitForTimeout(500);

  /* فهرست خودش اسکرول می‌شود و playwright برای بردنِ موس روی دکمهٔ
     آخر آن را می‌لغزاند — آن جابه‌جاییِ درست است، نه لرزش (کاربر با
     حرکتِ موس چیزی را اسکرول نمی‌کند). پس اسکرول را از مختصات
     برمی‌گردانیم و آنچه می‌ماند لرزشِ واقعی است. */
  const snap = () => p.evaluate(() => {
    const list = document.querySelector('.nav-list');
    const dy = list.scrollTop;
    const r = [];
    document.querySelectorAll('.sidebar .navbtn, .sidebar .navbtn .ic, .sidebar .btn, .sidebar .nav-label')
      .forEach(x => { const q = x.getBoundingClientRect();
        const off = list.contains(x) ? dy : 0;
        r.push([Math.round(q.left*100)/100, Math.round((q.top + off)*100)/100,
                Math.round(q.width*100)/100, Math.round(q.height*100)/100]); });
    return JSON.stringify(r);
  });

  const rest = await snap();
  // موس را روی تک‌تکِ دکمه‌ها می‌بریم و هر بار کلِ ستون را می‌سنجیم
  const n = await p.evaluate(() => document.querySelectorAll('.nav-list .navbtn').length);
  let worst = null;
  for (let i = 1; i <= n; i++) {
    const sel = `.nav-list .navbtn:nth-of-type(${i})`;
    const vis = await p.evaluate(s => { const e = document.querySelector(s); return !!e && e.offsetParent !== null; }, sel);
    if (!vis) continue;
    await p.hover(sel);
    await p.waitForTimeout(260);
    const now = await snap();
    if (now !== rest) { worst = i; break; }
  }
  t(worst === null, 'با بردنِ موس روی هر دکمه، هیچ‌چیزِ ستون تکان نمی‌خورد',
    worst === null ? n + ' دکمه آزموده شد' : 'دکمهٔ ' + worst + ' ستون را جابه‌جا کرد');

  // ولی رنگ باید عوض شود، وگرنه hover بی‌اثر شده
  const col = await p.evaluate(() => {
    const btn = document.querySelector('.nav-list .navbtn:nth-of-type(4)');
    const ic = btn.querySelector('.ic');
    return { icBefore: getComputedStyle(ic).backgroundColor, btnBefore: getComputedStyle(btn).backgroundColor };
  });
  await p.hover('.nav-list .navbtn:nth-of-type(4)');
  await p.waitForTimeout(300);
  const col2 = await p.evaluate(() => {
    const btn = document.querySelector('.nav-list .navbtn:nth-of-type(4)');
    const ic = btn.querySelector('.ic');
    return { icAfter: getComputedStyle(ic).backgroundColor, btnAfter: getComputedStyle(btn).backgroundColor };
  });
  t(col.icBefore !== col2.icAfter || col.btnBefore !== col2.btnAfter,
    'ولی رنگ عوض می‌شود، پس معلوم است موس کجاست',
    col.icBefore + ' → ' + col2.icAfter);

  const tr = await p.evaluate(() => {
    const out = [];
    for (const sh of document.styleSheets) {
      let rules; try { rules = sh.cssRules; } catch (e) { continue; }
      for (const r of rules)
        if (r.selectorText && /navbtn/.test(r.selectorText) && /:hover/.test(r.selectorText)
            && /transform/.test(r.style.cssText || '')) out.push(r.selectorText);
    }
    return out;
  });
  t(tr.length === 0, 'هیچ قاعدهٔ hover ی transform ندارد', tr.join(' / ') || 'هیچ');
  await p.close();
}
console.log('\n' + ok + ' ok، ' + bad + ' bad');
await b.close();
process.exit(bad ? 1 : 0);
