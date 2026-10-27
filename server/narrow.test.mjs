/* کارتابل روی گوشی.

   اندازه‌گیریِ اولیه: جدولِ چک‌لیست روی گوشیِ ۳۹۰ پیکسلی ۵۵۸ پیکسل عرض
   داشت و افقی می‌لغزید. چیزی گم نمی‌شد، ولی پهن‌ترین ستونش «تکرار» بود
   با ۹۶ پیکسل و باریک‌ترینِ معنادارش «وظیفه» با ۴۲ — یعنی همان چیزی که
   آدم می‌خواهد بخواند به یک خانهٔ خالی فشرده شده بود. برنامهٔ روزانه
   بدتر: ۱۱۸۰ پیکسل در قابِ ۳۶۸.

   حالا روی صفحهٔ باریک، جدول فقط چیزی را نشان می‌دهد که خوانده می‌شود و
   بقیه در کشویِ ردیف‌اند. این آزمون سه چیز را با هم نگه می‌دارد، چون
   هرکدام بی آن دوتای دیگر غلط است:

   یک) جدول روی گوشی نمی‌لغزد و ستونِ اصلی عرضِ خواندنی دارد.
   دو) هیچ ستونی گم نشده: برای هر ستونِ پنهان، کشو خانهٔ خودش را دارد —
   و کشو در مرورگرِ گوشی هم باز می‌شود، نه فقط در حالتِ نصب‌شده.
   سه) روی دسکتاپ هیچ‌چیز عوض نشده. */
import { launch } from './pw.mjs';
import { IT, FIN, IT_API, IT_PASS, FIN_API, FIN_PASS, signIn } from './where.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await launch();
const errs = [];

const look = (p, view) => p.evaluate(v => {
  const tbl = document.querySelector('#view-' + v + ' table');
  if (!tbl) return null;
  const wrap = tbl.closest('.tbl-wrap') || tbl.parentElement;
  const ths = [...tbl.querySelectorAll('thead tr:first-child th')];
  const vis = ths.filter(th => getComputedStyle(th).display !== 'none');
  const main = tbl.querySelector('thead th.col-main');
  return {
    shown: vis.length, total: ths.length,
    hiddenNames: ths.filter(th => getComputedStyle(th).display === 'none')
      .map(th => th.textContent.trim()).filter(Boolean),
    mainW: main ? Math.round(main.getBoundingClientRect().width) : 0,
    scrolls: wrap.scrollWidth > wrap.clientWidth + 2
  };
}, view);

async function open(w, url, api, pass) {
  const ctx = await b.newContext({ viewport: { width: w, height: 844 },
    isMobile: w < 800, hasTouch: w < 800 });
  const p = await ctx.newPage();
  p.on('pageerror', e => errs.push(String(e).slice(0, 120)));
  p.on('dialog', d => d.accept());
  await signIn(p, url, api, pass);
  await p.waitForTimeout(1800);
  await p.evaluate(() => { const g = document.getElementById('gateScreen'); if (g) { g.hidden = true; g.innerHTML = ''; } });
  await p.waitForTimeout(400);
  return { ctx, p };
}
const go = async (p, v) => { await p.evaluate(n => {
  const x = document.querySelector('.navbtn[data-view="' + n + '"]'); if (x) x.click(); }, v);
  await p.waitForTimeout(1000); };

/* ---------------- یک) جدول روی گوشی ---------------- */
console.log('— جدول روی گوشی —');
for (const [label, url, api, pass] of [['فنی', IT, IT_API, IT_PASS], ['مالی', FIN, FIN_API, FIN_PASS]]) {
  const { ctx, p } = await open(390, url, api, pass);
  for (const v of ['checklist', 'daily']) {
    await go(p, v);
    const r = await look(p, v);
    if (!r) { t(false, label + '/' + v + ' جدولی ندارد'); continue; }
    t(!r.scrolls, label + '/' + v + ': افقی نمی‌لغزد');
    t(r.mainW >= 100, label + '/' + v + ': ستونِ اصلی عرضِ خواندنی دارد',
      r.mainW + ' پیکسل');
    t(r.hiddenNames.length >= 3, label + '/' + v + ': ستون‌های درجهٔ دوم رفته‌اند به کشو',
      r.hiddenNames.join('، '));
  }
  await ctx.close();
}

/* ---------------- دو) هیچ ستونی گم نشده ---------------- */
console.log('— کشو، در مرورگرِ گوشی —');
{
  const { ctx, p } = await open(390, IT, IT_API, IT_PASS);
  await go(p, 'checklist');
  const appAttr = await p.evaluate(() => document.documentElement.getAttribute('data-app'));
  t(appAttr !== '1', 'این مرورگرِ معمولیِ گوشی است، نه حالتِ نصب‌شده', String(appAttr));

  const hidden = (await look(p, 'checklist')).hiddenNames
    .filter(n => /[؀-ۿ]/.test(n));          /* ستون‌های نشانه‌ای اسم ندارند */
  await p.evaluate(() => {
    const td = document.querySelector('#checklistBody tr[data-idx] td:first-child');
    if (td) td.click();
  });
  await p.waitForTimeout(700);
  const sheet = await p.evaluate(() => {
    const box = document.getElementById('rowSheet');
    if (!box) return null;
    return { open: getComputedStyle(box).display !== 'none' && box.getBoundingClientRect().height > 0,
      text: box.textContent || '' };
  });
  t(!!sheet, 'کشو ساخته شد');
  t(sheet && sheet.open, 'و با زدنِ شمارهٔ ردیف باز می‌شود');
  const missing = hidden.filter(n => !(sheet && sheet.text.includes(n)));
  t(missing.length === 0, 'برای هر ستونِ پنهان، کشو خانهٔ خودش را دارد',
    missing.length ? 'نیست: ' + missing.join('، ') : hidden.join('، '));
  await ctx.close();
}

/* ---------------- سه) دسکتاپ دست‌نخورده ---------------- */
console.log('— دسکتاپ —');
{
  const { ctx, p } = await open(1400, IT, IT_API, IT_PASS);
  await go(p, 'checklist');
  const r = await look(p, 'checklist');
  t(r.shown === r.total, 'همهٔ ستون‌ها دیده می‌شوند', r.shown + ' از ' + r.total);
  t(r.mainW >= 150, 'و ستونِ اصلی پهن است', r.mainW + ' پیکسل');
  await p.evaluate(() => {
    const td = document.querySelector('#checklistBody tr[data-idx] td:first-child');
    if (td) td.click();
  });
  await p.waitForTimeout(600);
  t(await p.evaluate(() => !document.getElementById('rowSheet')),
    'و کشو اصلاً ساخته نمی‌شود — رفتارِ دسکتاپ همان است که بود');
  await ctx.close();
}

/* ---------------- مانیفست ---------------- */
console.log('— پنجرهٔ نصب —');
{
  for (const m of ['/app.webmanifest', '/siamak/app.webmanifest']) {
    const r = await fetch(BASE + m);
    const j = await r.json();
    const sc = j.screenshots || [];
    t(sc.some(x => x.form_factor === 'narrow'), m + ': تصویرِ گوشی دارد',
      sc.length + ' تصویر');
    t(sc.some(x => x.form_factor === 'wide'), m + ': تصویرِ دسکتاپ هم');
    t((j.launch_handler || {}).client_mode === 'navigate-existing',
      m + ': در یک پنجره باز می‌شود', (j.launch_handler || {}).client_mode);
    /* ابعادِ اعلام‌شده باید با خودِ فایل بخواند، وگرنه کروم تصویر را
       بی‌صدا کنار می‌گذارد و دوباره همان نوارِ یک‌خطی می‌ماند. */
    const wrong = [];
    for (const s of sc) {
      const f = await fetch(BASE + s.src);
      if (f.status !== 200) { wrong.push(s.src + ' → ' + f.status); continue; }
      const buf = Buffer.from(await f.arrayBuffer());
      let w = 0, h = 0, i = 2;
      while (i < buf.length - 9) {
        if (buf[i] !== 0xFF) { i++; continue; }
        const mk = buf[i + 1];
        if (mk >= 0xC0 && mk <= 0xCF && mk !== 0xC4 && mk !== 0xC8 && mk !== 0xCC) {
          h = buf.readUInt16BE(i + 5); w = buf.readUInt16BE(i + 7); break;
        }
        i += 2 + buf.readUInt16BE(i + 2);
      }
      if (s.sizes !== w + 'x' + h) wrong.push(s.src + ': گفته ' + s.sizes + ' ولی ' + w + 'x' + h);
    }
    t(wrong.length === 0, m + ': ابعادِ هر تصویر با خودِ فایل می‌خواند',
      wrong.length ? wrong.join(' · ') : sc.length + ' تصویر');
  }
}

t(errs.length === 0, 'هیچ خطای صفحه‌ای نبود', errs.join(' | ') || 'پاک');

await b.close();
console.log((bad ? 'BAD ' : '') + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
