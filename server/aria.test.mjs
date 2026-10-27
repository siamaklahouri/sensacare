/* نامِ دسترس‌پذیریِ کنترل‌ها.

   دکمه‌ای که متنش «✓» یا هیچ است و برچسبی ندارد، برای صفحه‌خوان فقط
   «دکمه» است. در جدولِ چک‌لیستِ ریموت ۴۵ تا از این دکمه‌ها بود — یعنی
   کلِ آن جدول با صفحه‌خوان غیرقابلِ استفاده. همین‌طور کادرهای جدولِ
   بخشِ مشترک: آدمی که می‌بیند از سرستون می‌فهمد خانه چیست، صفحه‌خوان
   سرستون را نمی‌خواند.

   آزمون قاعده را می‌سنجد نه یک مورد را: هیچ کنترلِ دیده‌شونده‌ای در
   هیچ تبی نباید بی‌نام بماند. پس کنترلِ بی‌نامِ بعدی هم همین‌جا گیر
   می‌افتد، نه شش ماه بعد. */
import { launch } from './pw.mjs';
import { IT, FIN, ADMIN, IT_API, IT_PASS, FIN_API, FIN_PASS, signIn } from './where.mjs';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await launch();
const ctx = await b.newContext({ viewport: { width: 1400, height: 950 } });
const p = await ctx.newPage();
const errs = []; p.on('pageerror', e => errs.push(String(e).slice(0, 130)));
p.on('dialog', d => d.accept());
await signIn(p, IT, IT_API, IT_PASS);
await p.waitForTimeout(900);

/* فقط آنچه همین حالا دیده می‌شود: کنترلی که در تبِ بسته است، در
   درختِ دسترس‌پذیری هم نیست. */
const scanOn = pg => pg.evaluate(() => {
  const shown = el => {
    const s = getComputedStyle(el);
    if (s.display === 'none' || s.visibility === 'hidden') return false;
    const r = el.getBoundingClientRect();
    return r.width > 0 && r.height > 0;
  };
  const named = el => !!((el.textContent || '').trim() || el.getAttribute('aria-label') ||
    el.getAttribute('title') || el.getAttribute('aria-labelledby'));
  const namedIn = el => !!(el.labels?.length || el.getAttribute('aria-label') ||
    el.getAttribute('placeholder') || el.getAttribute('title') || el.getAttribute('aria-labelledby'));
  const tag = el => (el.tagName + (el.id ? '#' + el.id : '') +
    (el.className ? '.' + String(el.className).trim().split(/\s+/)[0] : '')).slice(0, 40);
  return {
    buttons: [...document.querySelectorAll('button')].filter(x => shown(x) && !named(x)).map(tag),
    fields: [...document.querySelectorAll('input:not([type=hidden]), select, textarea')]
      .filter(x => shown(x) && !namedIn(x)).map(tag)
  };
});
const scan = () => scanOn(p);

/* همهٔ تب‌های یک صفحه را باز می‌کند و هر کنترلِ بی‌نامی را جمع. */
async function sweep(pg) {
  const views = await pg.evaluate(() =>
    [...document.querySelectorAll('.navbtn')].map(x => x.getAttribute('data-view')));
  const bagB = new Map(), bagF = new Map();
  let seen = 0;
  if (!views.length) {
    const r = await scanOn(pg);
    r.buttons.forEach(x => bagB.set(x, 1));
    r.fields.forEach(x => bagF.set(x, 1));
    return { seen: 1, bagB, bagF };
  }
  for (const v of views) {
    const hit = await pg.evaluate(n => {
      const el = document.querySelector('.navbtn[data-view="' + n + '"]');
      if (!el || el.offsetParent === null) return false;
      el.click(); return true;
    }, v);
    if (!hit) continue;
    await pg.waitForTimeout(450);
    seen++;
    const r = await scanOn(pg);
    r.buttons.forEach(x => bagB.set(v + ': ' + x, 1));
    r.fields.forEach(x => bagF.set(v + ': ' + x, 1));
  }
  return { seen, bagB, bagF };
}

console.log('— چک‌لیستِ ریموت —');
{
  await p.evaluate(() => document.querySelector('.navbtn[data-view="servers"]').click());
  await p.waitForTimeout(1200);
  const r = await p.evaluate(() => {
    const all = [...document.querySelectorAll('.day-toggle')];
    return {
      n: all.length,
      noName: all.filter(x => !x.getAttribute('aria-label')).length,
      noPressed: all.filter(x => !x.hasAttribute('aria-pressed')).length,
      /* aria-pressed باید با وضعِ واقعیِ خانه بخواند، نه همیشه false */
      mismatch: all.filter(x =>
        (x.getAttribute('aria-pressed') === 'true') !== x.classList.contains('checked')).length,
      sample: (all[0] || {}).getAttribute ? all[0].getAttribute('aria-label') : ''
    };
  });
  t(r.n > 0, 'جدولِ چک‌لیستِ ریموت خانه دارد — یعنی این سنجش بی‌معنی نیست', r.n + ' خانه');
  t(r.noName === 0, 'هر خانه نام دارد', r.noName ? r.noName + ' بی‌نام' : 'همه');
  t(r.noPressed === 0, 'و aria-pressed دارد — این دکمه نیست، کلیدِ دو حالته است',
    r.noPressed ? r.noPressed + ' بی‌آن' : 'همه');
  t(r.mismatch === 0, 'و aria-pressed با وضعِ واقعیِ خانه می‌خواند',
    r.mismatch ? r.mismatch + ' ناهماهنگ' : 'همه');
  t(/روز/.test(r.sample || ''), 'نام می‌گوید کدام سرور و کدام روز', r.sample);
}

console.log('— کارتابلِ فنی: هیچ کنترلِ بی‌نامی در هیچ تبی —');
{
  const r = await sweep(p);
  t(r.seen >= 8, 'همهٔ تب‌ها گشته شد', r.seen + ' تب');
  t(r.bagB.size === 0, 'هیچ دکمهٔ دیده‌شونده‌ای بی‌نام نیست',
    r.bagB.size ? [...r.bagB.keys()].slice(0, 6).join(' · ') : 'پاک');
  t(r.bagF.size === 0, 'و هیچ کادرِ دیده‌شونده‌ای بی‌برچسب',
    r.bagF.size ? [...r.bagF.keys()].slice(0, 6).join(' · ') : 'پاک');
}

/* کارتابلِ مالی نسخهٔ خودش را از همان جدول‌ها دارد — یعنی هر برچسبی
   دو جا لازم است و اگر یکی جا بماند، کسی خبردار نمی‌شود. */
console.log('— کارتابلِ مالی —');
{
  const c2 = await b.newContext({ viewport: { width: 1400, height: 950 } });
  const p2 = await c2.newPage();
  p2.on('pageerror', e => errs.push('fin: ' + String(e).slice(0, 130)));
  p2.on('dialog', d => d.accept());
  await signIn(p2, FIN, FIN_API, FIN_PASS);
  await p2.waitForTimeout(900);
  const r = await sweep(p2);
  t(r.seen >= 6, 'تب‌هایش گشته شد', r.seen + ' تب');
  t(r.bagB.size === 0, 'دکمهٔ بی‌نام ندارد',
    r.bagB.size ? [...r.bagB.keys()].slice(0, 6).join(' · ') : 'پاک');
  t(r.bagF.size === 0, 'کادرِ بی‌برچسب هم ندارد',
    r.bagF.size ? [...r.bagF.keys()].slice(0, 6).join(' · ') : 'پاک');
  await c2.close();
}

console.log('— پنلِ ادمین —');
{
  const c3 = await b.newContext({ viewport: { width: 1280, height: 900 } });
  const p3 = await c3.newPage();
  p3.on('pageerror', e => errs.push('admin: ' + String(e).slice(0, 130)));
  p3.on('dialog', d => d.accept());
  await p3.goto(ADMIN, { waitUntil: 'networkidle' });
  await p3.waitForTimeout(1100);
  await p3.evaluate(() => {
    const g = document.getElementById('gate'); if (g) { g.hidden = true; g.innerHTML = ''; }
    const a = document.getElementById('app'); if (a) a.hidden = false;
  });
  await p3.waitForTimeout(500);
  const r = await scanOn(p3);
  t(r.buttons.length === 0, 'دکمهٔ بی‌نام ندارد',
    r.buttons.length ? r.buttons.slice(0, 6).join(' · ') : 'پاک');
  t(r.fields.length === 0, 'کادرِ بی‌برچسب هم ندارد',
    r.fields.length ? r.fields.slice(0, 6).join(' · ') : 'پاک');
  await c3.close();
}

t(errs.length === 0, 'هیچ خطای صفحه‌ای نبود', errs.join(' | ') || 'پاک');

await ctx.close();
await b.close();
console.log((bad ? 'BAD ' : '') + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
