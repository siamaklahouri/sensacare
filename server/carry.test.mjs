/* ماهی که خودش جلو می‌آید، و کاری که جا می‌ماند.

   دو حفره که با هم معنا پیدا می‌کنند:

   ۱) ماهِ کاری فقط دستی عوض می‌شد. اگر کاربر یادش می‌رفت، اولِ آذر
      هم هنوز در آبان کار می‌کرد — و حالا که نشانهٔ «عقب‌افتاده»
      داریم، همهٔ کارهایش قرمز دیده می‌شد.

   ۲) ماهِ تازه فقط کارهای تکرارشونده را می‌آورد. کارِ یک‌باره‌ای که
      انجام نشده، در بایگانیِ ماهِ قبل می‌ماند و هیچ‌کس خبردار
      نمی‌شود: تا دیروز روی صفحه «عقب‌افتاده» بود و سرِ ماه بی‌صدا
      از جلوی چشم می‌رفت.

   حالا ماه خودش جلو می‌آید (فقط به جلو، و برای هر ماه یک بار) و
   کارِ جامانده گفته می‌شود — ولی خودکار نمی‌آید، چون بعضی‌شان دیگر
   موضوعیت ندارند. */
import { launch, calm } from './pw.mjs';
import { readFileSync } from 'node:fs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const HOST = 'sltech.ir', PORT = new URL(BASE).port || '80';
const MARK = 'کارِ جاماندهٔ آزمون';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

console.log('===== سیم‌کشی =====');
{
  const eng = readFileSync(new URL('../public/_t/p/overdue.tpl', import.meta.url), 'utf8');
  t(/function odAutoMonth/.test(eng), 'تابعِ ماهِ خودکار هست');
  t(/now <= cur/.test(eng), 'و فقط به جلو می‌رود، نه به عقب');
  t(/state\.autoMonth === key/.test(eng), 'و برای هر ماه یک بار بس است');
  t(/function odLeftovers/.test(eng) && /function carryLeftovers/.test(eng), 'توابعِ کارِ جامانده هستند');
  t(/!repeatEvery\(t\)/.test(eng), 'و فقط کارهای یک‌باره را می‌شمارد');
  for (const f of ['it.tpl', 'fin.tpl']) {
    const src = readFileSync(new URL('../public/_t/' + f, import.meta.url), 'utf8');
    t(/\[odAutoMonth,/.test(src), f + ': سرِ راه‌اندازی صدا زده می‌شود');
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
  const ctx = await b.newContext({ viewport: { width: 1500, height: 950 } });
  await ctx.addCookies(await cookiesFor(api, pass));
  const p = await ctx.newPage();
  const errs = [];
  p.on('dialog', d => d.accept());
  p.on('pageerror', e => errs.push(String(e).slice(0, 160)));
  await p.goto('http://' + HOST + ':' + PORT + path, { waitUntil: 'load' });
  await p.waitForTimeout(3800); await calm(p);

  /* ماهِ کاری را عقب می‌بریم و یک کارِ یک‌بارهٔ ناتمام در آن می‌گذاریم.
     هر ماه نسخهٔ خودش را دارد، وگرنه هر دو به یک آرایه اشاره می‌کنند
     و «جاماندن» اصلاً رخ نمی‌دهد — همین یک بار گولم زد. */
  const before = await p.evaluate(mark => {
    const M = ["فروردین","اردیبهشت","خرداد","تیر","مرداد","شهریور","مهر","آبان","آذر","دی","بهمن","اسفند"];
    const clone = x => JSON.parse(JSON.stringify(x));
    state.tasks = (state.tasks || []).filter(x => x && x.task !== mark);
    Object.keys(state.monthsData || {}).forEach(k => {
      const md = state.monthsData[k];
      if (md && Array.isArray(md.tasks)) md.tasks = md.tasks.filter(x => x && x.task !== mark);
    });
    const [y, m] = String(state.currentMonthKey).split('|');
    const i = M.indexOf(m);
    const pm = i === 0 ? M[11] : M[i - 1];
    const py = i === 0 ? String(parseInt(y, 10) - 1) : y;
    state.monthsData[state.currentMonthKey] = clone({ tasks: state.tasks, days: state.days });
    const prev = clone({ tasks: state.tasks, days: state.days });
    prev.tasks.push({ category: 'آزمون', task: mark, owner: '', deadline: '6',
      status: 'انجام نشده', priority: 'بالا', note: '', rid: 'carry-test', every: 0 });
    state.monthsData[py + '|' + pm] = prev;
    state.currentMonthKey = py + '|' + pm;
    state.tasks = prev.tasks; state.days = prev.days;
    state.meta = { month: pm, year: py };
    delete state.autoMonth;
    return { key: state.currentMonthKey };
  }, MARK);
  /* با force: نسخهٔ سرور ردیف‌های دیگری دارد و نگهبانِ «از دست رفتنِ
     ردیف» جلوی ذخیرهٔ معمولی را می‌گیرد — یک بار همین‌جا گیر کرد و
     آزمون روی وضعیتِ قدیمی اجرا شد و بی‌جهت افتاد. */
  const saved = await p.evaluate(async () => {
    try { await Cloud.pushNow(true, true); return true; } catch (e) { return false; }
  });
  t(saved, 'وضعیتِ آزمون روی سرور نشست');
  t(!!before.key, 'ماهِ کاری برای آزمون عقب برده شد', before.key);

  await p.waitForTimeout(1200);
  await p.reload({ waitUntil: 'load' });
  await p.waitForTimeout(4200); await calm(p);

  const after = await p.evaluate(mark => ({
    key: state.currentMonthKey,
    auto: state.autoMonth || '',
    bar: (document.getElementById('odBar') || {}).innerText || '',
    left: odLeftovers().list.map(x => x.task),
    hasMark: (state.tasks || []).some(x => x && x.task === mark),
    btn: !!document.querySelector('#odBar .od-go[data-od-act="carry"]')
  }), MARK);

  t(after.key !== before.key, 'ماه خودش جلو آمد', before.key + ' → ' + after.key);
  t(after.auto === after.key, 'و نشانه گذاشت تا دوباره نکشدش', after.auto || 'نگذاشت');
  t(/ماهِ کاری خودش/.test(after.bar), 'و در نوار گفت که خودش آمده');
  t(!after.hasMark, 'کارِ یک‌بارهٔ ناتمام خودبه‌خود نیامد');
  t(after.left.includes(MARK), 'ولی گفته شد که جا مانده', after.left.join('، ') || 'چیزی نگفت');
  t(after.btn, 'و دکمهٔ آوردنش هست');

  /* دکمه را می‌زنیم */
  await p.evaluate(() => {
    const x = document.querySelector('#odBar .od-go[data-od-act="carry"]');
    if (x) x.click();
  });
  await p.waitForTimeout(900);
  const got = await p.evaluate(mark => ({
    has: (state.tasks || []).filter(x => x && x.task === mark).length,
    left: odLeftovers().list.length,
    since: ((state.tasks || []).find(x => x && x.task === mark) || {}).since
  }), MARK);
  t(got.has === 1, 'با یک کلیک آمد — یک بار، نه دو بار', got.has + '');
  t(got.left === 0, 'و دیگر جامانده‌ای نیست');
  t(got.since === after.key, 'و از این ماه به بعد شمرده می‌شود', got.since || '—');

  /* بار دوم نباید دوباره ماه را عوض کند */
  await p.reload({ waitUntil: 'load' });
  await p.waitForTimeout(4000); await calm(p);
  const again = await p.evaluate(() => ({
    key: state.currentMonthKey,
    moved: /ماهِ کاری خودش/.test((document.getElementById('odBar') || {}).innerText || '')
  }));
  t(again.key === after.key, 'بارِ دوم ماه همان ماند', again.key);
  t(!again.moved, 'و خبرِ «خودش آمد» تکرار نشد');

  t(errs.length === 0, 'و صفحه خطای جاوااسکریپت نداد', errs[0] || '—');
  await ctx.close();
}

await b.close();
console.log(ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
