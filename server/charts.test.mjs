/* چیدنِ نمودارهای داشبورد.

   داشبورد هفت‌هشت نمودارِ ثابت داشت که در خودِ قالب نوشته شده بودند:
   کسی که بخشی را نداشت یکی‌شان همیشه خالی می‌ماند، و کسی که چیزِ
   دیگری می‌خواست راهی نداشت جز این‌که بگوید تا قالب عوض شود.

   حالا نمودارهای آماده خاموش‌شدنی‌اند و از روی جدول‌های خودِ کارتابل
   می‌شود نمودارِ تازه ساخت. موتورش یکی است و هر دو کارتابل همان را
   می‌آورند، وگرنه فردا یکی از دیگری جا می‌ماند — پس این آزمون هر دو
   را می‌سنجد، نه یکی را.

   دو ایرادی که همین آزمون‌ها بیرون کشیدند و این‌جا قفل شده‌اند:
   «hidden» روی المانی که CSS بهش grid یا flex داده کار نمی‌کند، و
   عوض‌کردنِ «چه چیزی شمرده شود» ستونِ گروه‌بندیِ انتخاب‌شده را بی‌صدا
   به اولی برمی‌گرداند. */
import { launch } from './pw.mjs';
import { readFileSync } from 'node:fs';
import { ensureTasks, PRIORITY_ROWS } from './seed.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const rd = p => readFileSync(new URL(p, import.meta.url), 'utf8');

/* ---------- سیم‌کشی ---------- */
console.log('===== سیم‌کشی =====');
{
  const eng = rd('../public/_t/p/chartcfg.tpl');
  const css = rd('../public/_t/p/chartcfgcss.tpl');
  t(!/<\/?(script|style)\b/i.test(eng) && !/<!--/.test(eng), 'جزوِ موتور تگ و توضیحِ HTML ندارد');
  t(!/<\/?(script|style)\b/i.test(css), 'جزوِ شیوه‌نامه تگ ندارد');

  const tpls = rd('../src/templates.js');
  t(/\['chartcfg', *p_chartcfg\]/.test(tpls) && /\['chartcfgcss', *p_chartcfgcss\]/.test(tpls),
    'هر دو جزو ثبت شده‌اند');

  const kb = rd('../src/kartabl.js');
  t(/FEATURES = \[[^\]]*'charts'/.test(kb), 'دسترسیِ charts در فهرستِ دسترسی‌هاست');
  const adm = rd('../src/admin-planer.js');
  t(/id: 'charts'/.test(adm), 'و در پنلِ ادمین برچسب دارد');

  const set = rd('../public/_t/p/settings.tpl');
  t(/data-feat="charts"/.test(set), 'پنلِ تنظیمات زیرِ همان دسترسی است');
  t(/id="chartCfgBody"/.test(set), 'و جای بدنه‌اش هست');

  for (const f of ['it.tpl', 'fin.tpl']) {
    const src = rd('../public/_t/' + f);
    t(/\{\{PART:chartcfg\}\}/.test(src) && /\{\{PART:chartcfgcss\}\}/.test(src), f + ': جزوها را می‌آورد');
    t(/window\.CHART_BUILT *=/.test(src), f + ': نمودارهای آماده‌اش را معرفی می‌کند');
    t(/window\.CHART_SRC *=/.test(src), f + ': جدول‌هایش را معرفی می‌کند');
    t(/id="customCharts"/.test(src), f + ': جای نمودارهای دلخواه در داشبورد هست');
    t(/applyBuiltinCharts\(\)/.test(src) && /renderCustomCharts\(\)/.test(src), f + ': هر دو صدا زده می‌شوند');
    t(/if\(view==="settings"\)\{ *renderChartSettings\(\)/.test(src), f + ': با بازشدنِ تنظیمات ساخته می‌شود');
  }
  /* «hidden» روی grid و flex بی‌اثر است؛ بی این قاعده قابِ خالی روی
     هر داشبوردی می‌نشست. */
  t(/\.grid-auto\[hidden\]/.test(css) && /\.dash-group-label\[hidden\]/.test(css),
    'شیوه‌نامه «hidden» را روی گرید هم اعمال می‌کند');
}

async function session(api, pass) {
  const r = await fetch(BASE + '/api/' + api + '/login', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST },
    body: JSON.stringify({ password: pass }) });
  return (r.headers.getSetCookie ? r.headers.getSetCookie() : []).map(c => {
    const kv = c.split(';')[0];
    return { name: kv.split('=')[0], value: kv.slice(kv.indexOf('=') + 1), domain: HOST, path: '/' };
  });
}

const b = await launch();

for (const [label, api, pass, path] of [
  ['کارتابلِ فنی', 'kartabl', process.env.VS_IT_PASS || 'siamaksiamak', '/siamak/'],
  ['کارتابلِ مالی', 'sina', process.env.VS_FIN_PASS || 'sinasinasina', '/sina/']
]) {
  console.log('===== ' + label + ' =====');
  /* بی ردیف، ریاضیِ گروه‌بندی روی صفر اجرا می‌شود و سبزِ بی‌معنی
     می‌دهد. کارتابلِ مالی در دیتابیسِ تازه چک‌لیستِ خالی دارد. */
  const planted = await ensureTasks(BASE, HOST, api, pass,
    ts => ts.length >= 3, PRIORITY_ROWS);
  if (planted) console.log('   (' + planted + ' ردیفِ آزمون کاشته شد)');
  const ctx = await b.newContext({ viewport: { width: 1500, height: 1000 } });
  await ctx.addCookies(await session(api, pass));
  const p = await ctx.newPage();
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
  await p.goto('http://' + HOST + ':' + PORT + path, { waitUntil: 'load' });
  await p.waitForTimeout(3600);
  const go = async v => {
    await p.evaluate(n => { const x = document.querySelector('.nav-list .navbtn[data-view="' + n + '"]'); if (x) x.click(); }, v);
    await p.waitForTimeout(1000);
  };
  const shown = s => p.evaluate(sel => {
    const e = document.querySelector(sel);
    return !!e && getComputedStyle(e).display !== 'none';
  }, s);

  /* ۱) داشبوردِ دست‌نخورده نباید قابِ خالیِ «نمودارهای خودتان» داشته باشد */
  t(!(await shown('#customChartsLabel')) && !(await shown('#customCharts')),
    'بی نمودارِ دلخواه، قابِ خالی روی داشبورد نیست');

  /* ۲) بخشِ تنظیمات */
  await go('settings');
  const cfg0 = await p.evaluate(() => {
    const el = document.getElementById('chartCfgBody');
    return el ? { chks: el.querySelectorAll('[data-ccf-built]').length,
                  srcs: (document.getElementById('ccfSrc') || {}).length || 0 } : null;
  });
  t(!!cfg0 && cfg0.chks > 0, 'نمودارهای آماده در تنظیمات فهرست شده‌اند', cfg0 ? cfg0.chks + ' تا' : 'پنل نیست');
  t(!!cfg0 && cfg0.srcs > 0, 'و جدول‌های کارتابل برای ساختن هست', cfg0 ? cfg0.srcs + ' بخش' : '—');
  t(!(await shown('#ccfNumWrap')), 'ستونِ عددی تا وقتی «جمع» نخواهی دیده نمی‌شود');

  /* کشویی‌ها با قلمِ پیش‌فرضِ مرورگر می‌آمدند و وسطِ فرمِ فارسی وصله
     می‌زدند: شیوه‌نامهٔ تنظیمات فقط input را پوشانده بود. */
  const look = await p.evaluate(() => {
    const sel = document.getElementById('ccfSrc');
    const inp = document.querySelector('#chartCfgBody input[type=text]');
    const g = e => getComputedStyle(e);
    return { font: g(sel).fontFamily, same: inp ? g(sel).fontFamily === g(inp).fontFamily : false,
             size: g(sel).fontSize === (inp ? g(inp).fontSize : ''),
             radius: g(sel).borderRadius, arrow: g(sel).backgroundImage.startsWith('url(') };
  });
  t(/Vazirmatn/.test(look.font), 'کشویی با قلمِ خودِ کارتابل است', look.font.slice(0, 24));
  t(look.same && look.size, 'و قلم و اندازه‌اش با خانه‌های متنی یکی است');
  t(look.radius !== '0px', 'و قابش گرد است مثلِ بقیه', look.radius);
  t(look.arrow, 'و فلشِ خودش را دارد، نه فلشِ مرورگر');

  /* ۳) خاموش‌کردنِ یک نمودارِ آماده */
  const first = await p.evaluate(() => document.querySelector('[data-ccf-built]').getAttribute('data-ccf-built'));
  await p.evaluate(id => {
    const c = document.querySelector('[data-ccf-built="' + id + '"]');
    c.checked = false; c.dispatchEvent(new Event('change', { bubbles: true }));
  }, first);
  await p.waitForTimeout(400);
  await go('dashboard');
  const offState = await p.evaluate(id => {
    const b = (window.CHART_BUILT || []).find(x => x.id === id);
    const c = document.getElementById(b.canvas);
    const panel = c ? c.closest('.panel') : null;
    return { hidden: panel ? panel.hidden : null,
             display: panel ? getComputedStyle(panel).display : null,
             saved: (state.chartCfg.off || []).includes(id) };
  }, first);
  t(offState.hidden === true && offState.display === 'none', 'نمودارِ خاموش واقعاً از داشبورد می‌رود',
    offState.display);
  t(offState.saved, 'و در state می‌نشیند تا با پشتیبان برود');

  /* دوباره روشنش می‌کنیم تا کارتابلِ آزمون دست‌نخورده بماند */
  await go('settings');
  await p.evaluate(id => {
    const c = document.querySelector('[data-ccf-built="' + id + '"]');
    c.checked = true; c.dispatchEvent(new Event('change', { bubbles: true }));
  }, first);
  await p.waitForTimeout(300);

  /* ۴) انتخابِ ستون با عوض‌شدنِ «چه چیزی شمرده شود» نباید بپرد */
  const keep = await p.evaluate(() => {
    const srcSel = document.getElementById('ccfSrc');
    const withNum = (window.CHART_SRC || []).find(s => (s.nums || []).length);
    if (!withNum) return 'بی‌ستونِ عددی';
    srcSel.value = withNum.id; srcSel.dispatchEvent(new Event('change', { bubbles: true }));
    const by = document.getElementById('ccfBy');
    if (by.options.length < 2) return 'یک ستون';
    by.value = by.options[1].value;
    const want = by.value;
    const agg = document.getElementById('ccfAgg');
    agg.value = 'sum'; agg.dispatchEvent(new Event('change', { bubbles: true }));
    return { want, got: document.getElementById('ccfBy').value };
  });
  if (typeof keep === 'string') t(true, 'این کارتابل ستونِ عددی ندارد — این سنجه رد شد', keep);
  else t(keep.want === keep.got, 'ستونِ انتخاب‌شده با عوض‌شدنِ نوعِ شمارش نمی‌پرد',
    keep.want + ' → ' + keep.got);

  /* ۵) ساختنِ نمودار و دیده‌شدنش */
  await p.evaluate(() => {
    document.getElementById('ccfSrc').value = (window.CHART_SRC || [])[0].id;
    document.getElementById('ccfSrc').dispatchEvent(new Event('change', { bubbles: true }));
    document.getElementById('ccfAgg').value = 'count';
    document.getElementById('ccfAgg').dispatchEvent(new Event('change', { bubbles: true }));
    document.getElementById('ccfTitle').value = 'نمودارِ آزمون';
  });
  await p.click('#ccfAdd');
  await p.waitForTimeout(600);
  t(await p.evaluate(() => (state.chartCfg.custom || []).length === 1), 'نمودارِ دلخواه ساخته شد');

  await go('dashboard');
  await p.waitForTimeout(900);
  const made = await p.evaluate(() => {
    const w = document.getElementById('customCharts');
    const cv = w ? w.querySelector('canvas') : null;
    return { shown: w ? getComputedStyle(w).display !== 'none' : false,
             title: w ? (w.querySelector('h3') || {}).textContent || '' : '',
             painted: cv ? (cv.width > 10 && cv.height > 10) : false };
  });
  t(made.shown, 'قابِ نمودارهای دلخواه باز شد');
  t(/نمودارِ آزمون/.test(made.title), 'با همان عنوانی که نوشته شد', made.title);
  t(made.painted, 'و بومش کشیده شد');

  /* ۶) ریاضیِ گروه‌بندی */
  const math = await p.evaluate(() => {
    const c = state.chartCfg.custom[0];
    const src = (window.CHART_SRC || []).find(s => s.id === c.src);
    const rows = src.rows() || [];
    const want = new Map();
    rows.forEach(r => {
      const k = String((r && r[c.by]) == null ? '' : r[c.by]).trim() || 'نامشخص';
      want.set(k, (want.get(k) || 0) + 1);
    });
    const d = customChartData(c);
    const sum = d.values.reduce((s, v) => s + v, 0);
    const desc = d.values.every((v, i) => i === 0 || d.values[i - 1] >= v);
    return { sum, rows: rows.length, groups: d.labels.length, want: want.size, desc };
  });
  t(math.rows > 0, 'جدولِ منبع ردیف دارد — وگرنه ریاضیِ زیر بی‌معنی است', math.rows + ' ردیف');
  t(math.sum === math.rows, 'جمعِ ستون‌ها برابرِ شمارِ ردیف‌هاست', math.sum + '/' + math.rows);
  t(math.groups === Math.min(math.want, 11), 'شمارِ گروه‌ها درست است (با سقفِ ده و «بقیه»)',
    math.groups + ' از ' + math.want);
  t(math.desc, 'و از بزرگ به کوچک مرتب است');

  /* ۷) حذف */
  await go('settings');
  await p.evaluate(() => { const d = document.querySelector('[data-ccf-del]'); if (d) d.click(); });
  await p.waitForTimeout(500);
  t(await p.evaluate(() => (state.chartCfg.custom || []).length === 0), 'حذف شد');
  await go('dashboard');
  t(!(await shown('#customCharts')), 'و قاب دوباره بسته شد');

  t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
  await ctx.close();
}

await b.close();
console.log(ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
