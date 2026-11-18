/* حذف، با راهِ برگشت.

   در هر دو کارتابل چهارده جا ردیف حذف می‌شد و همه یک الگو داشتند:
   یک پنجرهٔ confirm مرورگر، و بعد ردیف برای همیشه رفته.

   آن پنجره دو کار می‌کرد که هیچ‌کدام خوب نبود: کارِ روزمره را کُند
   می‌کرد، و با همهٔ کُندی‌اش محافظت هم نمی‌کرد — اگر اشتباهی تأیید
   می‌شد، تنها راهِ برگشت، برگرداندنِ کلِ یک نسخهٔ پشتیبان بود.

   حالا دو لایه هست: یک کادرِ فارسیِ خودمان می‌پرسد «حذف شود؟» و نامِ
   ردیف را می‌گوید، و بعد از حذف هشت ثانیه می‌شود برگرداندش.

   مرزِ مهم: ردیف باید سرِ جای خودش برگردد، نه تهِ فهرست. ردیفی که
   جایش عوض شود، برگشتِ نصفه است. */
import { launch, calm } from './pw.mjs';
import { readFileSync } from 'node:fs';
import { ensureTasks, PRIORITY_ROWS } from './seed.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

console.log('===== سیم‌کشی =====');
{
  const js = readFileSync(new URL('../public/_t/p/undo.tpl', import.meta.url), 'utf8');
  const css = readFileSync(new URL('../public/_t/p/undocss.tpl', import.meta.url), 'utf8');
  t(!/<\/?(script|style)\b/i.test(js) && !/<!--/.test(js), 'جزوِ موتور تگ ندارد');
  t(!/<\/?(script|style)\b/i.test(css), 'جزوِ شیوه‌نامه تگ ندارد');
  t(/splice\(idx, 0, item\)/.test(js), 'برگرداندن جای ردیف را هم برمی‌گرداند');
  t(/ASKDEL\(label,/.test(js), 'حذف از کادرِ پرسش می‌گذرد');
  t(/\.dq-no"\)\.focus\(\)/.test(js), 'نشانگر روی «بی‌خیال» می‌نشیند، نه روی «حذف کن»');
  t(/@media print\{ \.undo-bar\{ display:none/.test(css.replace(/\s+/g, ' ')),
    'نوار روی کاغذ نمی‌افتد');
  t(/@media print\{ \.dq-ov\{ display:none/.test(css.replace(/\s+/g, ' ')),
    'کادرِ پرسش هم روی کاغذ نمی‌افتد');
  const tpls = readFileSync(new URL('../src/templates.js', import.meta.url), 'utf8');
  t(/\['undo', *p_undo\]/.test(tpls), 'جزو ثبت شده است');

  /* و دیگر جایی برای حذفِ ردیف confirm نمانده باشد */
  for (const f of ['it.tpl', 'fin.tpl']) {
    const src = readFileSync(new URL('../public/_t/' + f, import.meta.url), 'utf8');
    const left = (src.match(/confirm\([^)]*حذف[^)]*\)/g) || []);
    t(left.length === 0, f + ': هیچ حذفِ ردیفی پنجرهٔ confirm ندارد',
      left.join(' / ') || 'هیچ');
    t(/delRow\(/.test(src), f + ': از همان کوتاه‌نویسِ مشترک استفاده می‌کند');
  }
}

async function cookiesFor(api, pass) {
  const r = await fetch(BASE + '/api/' + api + '/login', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST }, body: JSON.stringify({ password: pass }) });
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
  await ensureTasks(BASE, HOST, api, pass, ts => ts.length >= 3, PRIORITY_ROWS);
  const ctx = await b.newContext({ viewport: { width: 1400, height: 900 } });
  await ctx.addCookies(await cookiesFor(api, pass));
  const p = await ctx.newPage();
  let dialogs = 0;
  p.on('dialog', d => { dialogs++; d.accept(); });
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
  await p.goto('http://' + HOST + ':' + PORT + path, { waitUntil: 'load' });
  await p.waitForTimeout(3800); await calm(p);
  await p.evaluate(() => { const x = document.querySelector('.navbtn[data-view="checklist"]'); if (x) x.click(); });
  await p.waitForTimeout(900);

  const before = await p.evaluate(() => ({
    n: state.tasks.length,
    names: state.tasks.map(x => x && x.task)
  }));
  t(before.n >= 3, 'چند وظیفه برای آزمون هست', before.n + '');

  /* ---- اول «بی‌خیال»: باید هیچ‌چیز حذف نشود ---- */
  await p.evaluate(() => {
    const b = document.querySelectorAll('#checklistBody [data-del]')[1];
    if (b) b.click();
  });
  await p.waitForTimeout(400);
  const asked = await p.evaluate(() => ({
    open: !!document.querySelector('.dq-ov:not([hidden])'),
    txt: (document.querySelector('.dq-p') || {}).textContent || '',
    focus: (document.activeElement || {}).className || ''
  }));
  t(asked.open, 'کادرِ پرسش باز شد');
  t(asked.txt.indexOf(before.names[1]) >= 0, 'و نامِ همان ردیف را می‌گوید', asked.txt);
  t(/dq-no/.test(asked.focus), 'و نشانگر روی «بی‌خیال» است', asked.focus);
  await p.evaluate(() => document.querySelector('.dq-no').click());
  await p.waitForTimeout(300);
  const said_no = await p.evaluate(() => ({
    n: state.tasks.length,
    open: !!document.querySelector('.dq-ov:not([hidden])'),
    bar: !!document.querySelector('.undo-bar:not([hidden])')
  }));
  t(!said_no.open, '«بی‌خیال» کادر را می‌بندد');
  t(said_no.n === before.n, 'و هیچ ردیفی حذف نمی‌شود', said_no.n + '');
  t(!said_no.bar, 'و نوارِ برگرداندن هم نمی‌آید');

  /* ---- Escape هم همان «بی‌خیال» است ---- */
  await p.evaluate(() => {
    const b = document.querySelectorAll('#checklistBody [data-del]')[1];
    if (b) b.click();
  });
  await p.waitForTimeout(350);
  await p.keyboard.press('Escape');
  await p.waitForTimeout(300);
  const esc = await p.evaluate(() => ({
    n: state.tasks.length,
    open: !!document.querySelector('.dq-ov:not([hidden])')
  }));
  t(!esc.open && esc.n === before.n, 'Escape هم بی‌خیال می‌شود', esc.n + '');

  /* ردیفِ دوم را می‌بریم — نه اولی، تا جایِ برگشت هم سنجیده شود */
  await p.evaluate(() => {
    const b = document.querySelectorAll('#checklistBody [data-del]')[1];
    if (b) b.click();
  });
  await p.waitForTimeout(350);
  await p.evaluate(() => document.querySelector('.dq-yes').click());
  await p.waitForTimeout(500);

  const gone = await p.evaluate(() => ({
    n: state.tasks.length,
    shown: !!document.querySelector('.undo-bar:not([hidden])'),
    txt: (document.querySelector('.ub-txt') || {}).textContent || '',
    hasGo: !!document.querySelector('.undo-bar .ub-go')
  }));
  t(dialogs === 0, 'پنجرهٔ مرورگر باز نشد', dialogs + ' تا');
  t(gone.n === before.n - 1, 'ردیف حذف شد', before.n + ' → ' + gone.n);
  t(gone.shown && gone.hasGo, 'و نوارِ برگرداندن آمد');
  t(gone.txt.indexOf(before.names[1]) >= 0, 'و نامِ همان ردیف را می‌گوید', gone.txt);

  await p.evaluate(() => document.querySelector('.ub-go').click());
  await p.waitForTimeout(500);
  const back = await p.evaluate(() => ({
    n: state.tasks.length,
    names: state.tasks.map(x => x && x.task),
    shown: !!document.querySelector('.undo-bar:not([hidden])')
  }));
  t(back.n === before.n, 'با یک کلیک برگشت', back.n + '');
  t(back.names[1] === before.names[1], 'و سرِ جای خودش، نه تهِ فهرست',
    back.names[1] || '—');
  t(back.names.join('|') === before.names.join('|'), 'و کلِ ترتیب همان شد');
  t(!back.shown, 'و نوار بسته شد');

  /* ✕ نوار را می‌بندد و حذف سرِ جایش می‌ماند */
  await p.evaluate(() => {
    const b = document.querySelectorAll('#checklistBody [data-del]')[0];
    if (b) b.click();
  });
  await p.waitForTimeout(350);
  await p.evaluate(() => document.querySelector('.dq-yes').click());
  await p.waitForTimeout(400);
  await p.evaluate(() => document.querySelector('.ub-x').click());
  await p.waitForTimeout(300);
  const closed = await p.evaluate(() => ({
    n: state.tasks.length,
    shown: !!document.querySelector('.undo-bar:not([hidden])')
  }));
  t(!closed.shown, '✕ نوار را می‌بندد');
  t(closed.n === before.n - 1, 'و حذف سرِ جایش می‌ماند', closed.n + '');

  t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
  await ctx.close();
}

await b.close();
console.log(ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
