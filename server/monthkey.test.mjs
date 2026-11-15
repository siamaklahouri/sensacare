/* کارتابلِ تازه باید ماهِ کاری داشته باشد.

   meta در کارتابلِ نو خالی است، و کلیدِ ماه از همان meta ساخته
   می‌شود. نتیجه «?|?» بود، و سه چیز از همان‌جا خراب می‌شد:

   ۱) چیپِ بالای صفحه «؟ ؟» نشان می‌داد.
   ۲) تقویم خالی می‌ماند — کارهای «همین ماه» را از همین کلید می‌گیرد،
      پس هرچقدر هم کارِ مهلت‌دار بود، هیچ روزی چیزی نداشت.
   ۳) کارهای ماهِ اول برای همیشه زیرِ یک کلیدِ بی‌معنی بایگانی
      می‌شدند و در گزارش‌ها «؟ ؟» دیده می‌شدند.

   کارتابلِ مالی همین را از قبل درست کرده بود؛ کارتابلِ فنی نه. این
   آزمون هر دو را می‌سنجد، و مهم‌تر: می‌سنجد که دادهٔ کلیدِ بی‌نامِ
   کارتابل‌های قدیمی دور ریخته نشود. */
import { launch } from './pw.mjs';
import { todayJalali } from './seed.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

async function call(path, opts = {}) {
  const r = await fetch(BASE + path, { ...opts,
    headers: { 'Content-Type': 'application/json', Host: HOST, ...(opts.headers || {}) } });
  let data = null; try { data = await r.json(); } catch (e) {}
  const cookies = (r.headers.getSetCookie ? r.headers.getSetCookie() : []).map(c => c.split(';')[0]).join('; ');
  return { status: r.status, data, cookies };
}
async function cookiesFor(api, pass) {
  const r = await fetch(BASE + '/api/' + api + '/login', { method: 'POST',
    headers: { 'Content-Type': 'application/json', Host: HOST }, body: JSON.stringify({ password: pass }) });
  return (r.headers.getSetCookie ? r.headers.getSetCookie() : []).map(c => {
    const kv = c.split(';')[0];
    return { name: kv.split('=')[0], value: kv.slice(kv.indexOf('=') + 1), domain: HOST, path: '/' };
  });
}

const now = todayJalali();
const want = now.jy + '|' + now.name;
const b = await launch();

for (const [label, api, pass, path] of [
  ['کارتابلِ فنی', 'kartabl', process.env.VS_IT_PASS || 'siamaksiamak', '/siamak/'],
  ['کارتابلِ مالی', 'sina', process.env.VS_FIN_PASS || 'sinasinasina', '/sina/']
]) {
  console.log('===== ' + label + ' =====');

  /* وضعیتی می‌سازیم که دقیقاً مثلِ کارتابلِ قدیمیِ گرفتار باشد:
     meta خالی، کلیدِ ماه «?|?»، و یک کارِ واقعی تویش. */
  const login = await call('/api/' + api + '/login', { method: 'POST', body: JSON.stringify({ password: pass }) });
  t(login.status === 200, 'ورود برای ساختنِ وضعیتِ آزمون');
  const H = { Cookie: login.cookies };
  const got = await call('/api/' + api + '/state', { headers: H });
  const stray = { tasks: [{ category: 'آزمون', task: 'کارِ ماهِ بی‌نام', owner: '', deadline: '4',
                            status: 'انجام نشده', priority: 'متوسط', note: '' }], days: [] };
  const put = await call('/api/' + api + '/state', { method: 'PUT', headers: H,
    body: JSON.stringify({ state: { meta: { month: '', year: '' }, currentMonthKey: '?|?',
      monthsData: { '?|?': stray }, tasks: stray.tasks, days: [] },
      rev: (got.data && got.data.rev) || 0 }) });
  t(put.status === 200, 'وضعیتِ «ماهِ بی‌نام» روی سرور نشست');

  const ctx = await b.newContext({ viewport: { width: 1400, height: 900 } });
  await ctx.addCookies(await cookiesFor(api, pass));
  const p = await ctx.newPage();
  const errs = [];
  p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
  await p.goto('http://' + HOST + ':' + PORT + path, { waitUntil: 'load' });
  await p.waitForTimeout(3800);

  const o = await p.evaluate(() => ({
    key: state.currentMonthKey,
    meta: state.meta,
    keys: Object.keys(state.monthsData || {}),
    tasks: (state.tasks || []).map(x => x && x.task),
    chip: (document.querySelector('#monthChip, .month-chip, [data-month-chip]') || {}).textContent || ''
  }));
  t(o.key === want, 'ماهِ کاری روی ماهِ امروز نشست', o.key + ' / خواسته: ' + want);
  t(o.meta && o.meta.month === now.name && String(o.meta.year) === String(now.jy),
    'و meta هم پر شد', JSON.stringify(o.meta));
  t(!o.keys.includes('?|?'), 'کلیدِ «?|?» دیگر نیست', o.keys.join('، ') || 'خالی');
  t(o.tasks.includes('کارِ ماهِ بی‌نام'), 'و کارِ آن ماه گم نشد — به ماهِ جاری پیوست',
    o.tasks.join('، '));
  /* و دو تا هم نشد: وقتی کلیدِ بی‌نام خودش ماهِ کاری بوده، همان
     ردیف‌ها هم در state.tasks بودند و پیوستنِ کورکورانه تکرارشان
     می‌کرد — در نسخهٔ اولِ همین اصلاح دقیقاً همین شد. */
  t(o.tasks.filter(x => x === 'کارِ ماهِ بی‌نام').length === 1,
    'و تکرار نشد', o.tasks.length + ' ردیف');
  t(!/؟/.test(o.chip), 'چیپِ بالای صفحه «؟» نشان نمی‌دهد', o.chip.trim() || '—');

  /* و تقویم که کارهای همین ماه را از همین کلید می‌گیرد */
  await p.evaluate(() => { const x = document.querySelector('.navbtn[data-view="cal"]'); if (x) x.click(); });
  await p.waitForTimeout(1400);
  const cal = await p.evaluate(() => document.querySelectorAll('#calGrid .c2-it').length);
  t(cal > 0, 'تقویم کارِ این ماه را نشان می‌دهد', cal + ' کار');

  t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
  await ctx.close();
}

await b.close();
console.log(ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
