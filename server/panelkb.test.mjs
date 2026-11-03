/* پنلِ مدیر: کیبورد، و خطی که می‌گوید کدها از کجا می‌روند.

   هر دو از یک الگو درآمدند: پنل همیشه آن یکی است که جا می‌مانَد.
   مانیفست نداشت، رنگِ نوار نداشت، متن‌هایش بعد از کارتابل‌ها درست
   شد — و لایهٔ دسترس‌پذیریِ پنجره‌ها (a11y) هم در هر دو کارتابل بود
   و در پنل نه. سنجیده شد: از دوازده Tab، هفت‌تا از پنجرهٔ باز بیرون
   می‌افتاد، روی دکمه‌های پشتِ پرده — از جمله «خروج». */
import { launch } from './pw.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AU = process.env.VS_ADMIN || 'admin';
const AP = process.env.VS_ADMIN_PASS || 'adminadminadmin';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const b = await launch();
const p = await b.newPage({ viewport: { width: 1400, height: 950 } });
const errs = [];
p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
await p.goto(BASE + '/login', { waitUntil: 'domcontentloaded' });
await p.evaluate(async a => { await fetch('/api/admin.planer/signin', { method: 'POST',
  credentials: 'same-origin', headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ user: a.u, password: a.p }) }); }, { u: AU, p: AP });
await p.goto(BASE + '/login', { waitUntil: 'networkidle' });
await p.waitForTimeout(2600);
t(errs.length === 0, 'پنل بی خطای جاوااسکریپت بالا می‌آید', errs[0] || '—');

console.log('===== پنجرهٔ زنگوله با کیبورد =====');
/* مثلِ کاربرِ واقعیِ کیبورد: اول فوکوس روی دکمه، بعد Enter.
   با «.click()»ِ برنامه‌ای فوکوس روی دکمه نمی‌نشیند، پس «جایی که
   بودیم» می‌شد body و سنجهٔ برگشتِ فوکوس بی‌دلیل قرمز می‌شد — ایرادِ
   آزمون بود، نه کد. */
await p.focus('#bellBtn');
await p.keyboard.press('Enter');
await p.waitForTimeout(500);
t(await p.evaluate(() => !document.getElementById('bellPop').hidden), 'باز می‌شود');
t(await p.evaluate(() => document.getElementById('bellPop').getAttribute('aria-modal') === 'true'),
  'و aria-modal می‌گیرد — تا صفحه‌خوان بفهمد چیزی باز شده');
t(await p.evaluate(() => document.getElementById('bellPop').contains(document.activeElement)),
  'و فوکوس می‌رود داخلش');

let out = 0, where = [];
for (let i = 0; i < 14; i++) {
  await p.keyboard.press('Tab');
  const r = await p.evaluate(() => {
    const pop = document.getElementById('bellPop'), a = document.activeElement;
    return { inside: pop.contains(a),
             tag: (a.tagName || '') + (a.id ? '#' + a.id : '') };
  });
  if (!r.inside) { out++; if (where.length < 3) where.push(r.tag); }
}
t(out === 0, 'و Tab از داخلش بیرون نمی‌رود', out ? out + ' بار بیرون: ' + where.join(', ') : '۱۴ بار، همه داخل');

await p.keyboard.press('Escape');
await p.waitForTimeout(350);
t(await p.evaluate(() => document.getElementById('bellPop').hidden), 'و Escape می‌بنددش');
t(await p.evaluate(() => document.activeElement && document.activeElement.id === 'bellBtn'),
  'و فوکوس به همان دکمه‌ای برمی‌گردد که بازش کرده بود',
  await p.evaluate(() => (document.activeElement || {}).id || '—'));

console.log('===== خطِ «کدها از کجا می‌روند» =====');
await p.evaluate(() => { const x = document.querySelector('.tabs button[data-tab="site"]'); if (x) x.click(); });
await p.waitForTimeout(1200);
const line = await p.evaluate(() => (document.getElementById('botsLive') || {}).innerText || '');
t(!!line, 'خط هست');
t(/بازیابی/.test(line), 'و از کدِ بازیابیِ «دیتای شخصی» اسم می‌برد — همان چیزی که یادها می‌رود');
t(/ورود|رمزِ تازه/.test(line), 'و از کدِ ورود و رمزِ تازه هم');
/* با یک کانال باید هشدار بدهد؛ با هیچ کانالی باید سرخ بگوید */
const live = await p.evaluate(async () => (await (await fetch('/api/admin.planer/site',
  { credentials: 'same-origin' })).json()).botsLive || []);
if (live.length === 1)
  t(/تنها همین یک کانال/.test(line), 'و چون یک کانال بیش‌تر نیست، هشدار می‌دهد', line.slice(-48));
else if (live.length === 0)
  t(/هیچ کانالِ زنده/.test(line), 'و نبودِ کانال را سرخ می‌گوید');
else
  t(live.every(x => line.includes(x)), 'و نامِ همهٔ کانال‌ها را می‌گوید', live.join('، '));

await b.close();
console.log('\n' + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
