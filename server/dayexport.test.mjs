/* خروجیِ «برنامهٔ ماه» — اکسل و پی‌دی‌اف.
   سه چیز سنجیده می‌شود: دکمه‌ها سرِ جایشان باشند، آنچه بیرون می‌آید
   همان چیزی باشد که روی صفحه دیده می‌شود (نه بیشتر، نه کمتر)، و
   نامِ فایل اَسکی بماند — کروم نامِ غیرِاَسکی را دور می‌ریزد و فایل
   با نامِ «download» و بی‌پسوند ذخیره می‌شود. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });

for (const [tag, port] of [['IT', 8894], ['مالی', 8893]]) {
  const p = await b.newPage({ viewport: { width: 1440, height: 1000 }, acceptDownloads: true });
  const errs = []; p.on('pageerror', e => errs.push(String(e).slice(0, 180)));
  p.on('dialog', d => d.accept());
  await p.goto('http://127.0.0.1:' + port + '/', { waitUntil: 'networkidle' });
  await p.waitForTimeout(1600);
  await p.evaluate(() => { const g = document.getElementById('gateScreen'); if (g) { g.hidden = true; g.innerHTML = ''; } });
  await p.waitForTimeout(400);
  console.log('\n===== کارتابل ' + tag + ' =====');
  await p.evaluate(() => document.querySelector('[data-view="daily"]').click());
  await p.waitForTimeout(900);

  const btns = await p.evaluate(() => [...document.querySelectorAll('#view-daily .day-ex button')].map(x => x.id));
  t(btns.includes('dayXlsxBtn') && btns.includes('dayPdfBtn'), 'هر دو دکمهٔ خروجی هست', btns.join('،'));

  /* چند ردیف بنویسیم تا چیزی برای خروجی باشد */
  const ins = await p.$$('#view-daily td.editable-text input');
  for (let i = 0; i < Math.min(3, ins.length); i++) { await ins[i].click(); await ins[i].fill('کارِ آزمایشیِ ' + (i + 1)); }
  await p.waitForTimeout(500);

  const d = await p.evaluate(() => window.dayExport.collect());
  t(d && d.head.length >= 6, 'ستون‌ها از سرصفحهٔ خودِ جدول خوانده شدند', d ? d.head.join('، ') : '-');
  t(!d.head.some(h => /[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]/u.test(h)), 'نشانه‌ها از عنوانِ ستون‌ها برداشته شدند');
  t(!d.head.includes(''), 'ستونِ دکمهٔ حذف در خروجی نیست');
  t(d.rows.length > 0, 'ردیف‌ها چیده شدند', d.rows.length + ' ردیف');
  t(!JSON.stringify(d.rows).includes('—'), 'خطِ تیرهٔ «خالی» وارد خروجی نشد');

  /* ---- اکسل ---- */
  const dl = p.waitForEvent('download', { timeout: 15000 }).catch(() => null);
  await p.click('#dayXlsxBtn');
  const got = await dl;
  t(!!got, 'دکمهٔ اکسل فایل داد', got ? got.suggestedFilename() : 'بی‌دانلود');
  if (got) {
    const n = got.suggestedFilename();
    t(/^[\x20-\x7E]+\.xlsx$/.test(n), 'نامِ فایل اَسکی است و پسوند دارد', n);
    t(n !== 'download', 'و «download» نیست', n);
  }

  /* ---- پی‌دی‌اف: سندِ چاپ در iframeِ جدا ساخته می‌شود ---- */
  await p.click('#dayPdfBtn');
  await p.waitForTimeout(1600);
  const fr = await p.evaluate(() => {
    const f = document.getElementById('dayPrintFrame');
    if (!f || !f.contentDocument) return null;
    const doc = f.contentDocument;
    return { rows: doc.querySelectorAll('tbody tr').length,
             cols: doc.querySelectorAll('thead th').length,
             h1: (doc.querySelector('h1') || {}).textContent || '',
             dir: doc.documentElement.getAttribute('dir') };
  });
  t(!!fr, 'سندِ چاپ ساخته شد');
  if (fr) {
    t(fr.rows === d.rows.length, 'همان ردیف‌های روی صفحه روی کاغذ آمد', fr.rows + ' در برابر ' + d.rows.length);
    t(fr.cols === d.head.length, 'و همان ستون‌ها', fr.cols + ' در برابر ' + d.head.length);
    t(fr.dir === 'rtl', 'سندِ چاپ راست‌چین است');
  }

  /* ---- بی‌اجازهٔ ادمین، دکمه‌ها باید از صفحه بروند ---- */
  t(await p.evaluate(() => document.querySelectorAll('[data-feat="export"]').length > 0),
    'نوارِ خروجی نشانِ قابلیت را دارد (پس ادمین می‌تواند پسش بگیرد)');

  t(errs.length === 0, 'هیچ خطای صفحه‌ای رخ نداد', errs[0] || '');
  await p.close();
}
await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
