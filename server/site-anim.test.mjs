import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
const OUT = '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/kt/';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });

/* ---------- ۱) با حرکت ---------- */
console.log('— صفحه با حرکت —');
{
  const p = await b.newPage({ viewport: { width: 1280, height: 860 } });
  const errs = []; p.on('pageerror', e => errs.push(String(e).slice(0, 180)));
  await p.goto('http://127.0.0.1:8895/', { waitUntil: 'domcontentloaded' });
  t(await p.evaluate(() => document.documentElement.classList.contains('anim')), 'حالتِ حرکت روشن است');

  // سربرگ: همان اول باید نیمه‌راه باشد، نه سرِ جای آخر
  const early = await p.evaluate(() => {
    const h = document.querySelector('.hero h1');
    const cs = getComputedStyle(h);
    return { op: Number(cs.opacity), tr: cs.transform };
  });
  t(early.op < 1 || early.tr !== 'none', 'سربرگ در لحظهٔ اول در حالِ آمدن است',
    'opacity=' + early.op.toFixed(2) + ' transform=' + early.tr.slice(0, 22));

  await p.waitForTimeout(1400);
  const late = await p.evaluate(() => {
    const q = s => { const e = document.querySelector(s), c = getComputedStyle(e);
      return { op: Number(c.opacity), tr: c.transform }; };
    return { h1: q('.hero h1'), lead: q('.hero p.lead'), cta: q('.hero .cta'), note: q('.hero p.note') };
  });
  t(Object.values(late).every(x => x.op > .99 && x.tr === 'none'),
    'و بعد کامل سرِ جایش می‌نشیند', JSON.stringify(Object.entries(late).map(([k, v]) => k + '=' + v.op.toFixed(2))));

  // موجِ زیرِ کلمهٔ کلیدی بعد از انیمیشن نباید گم شده باشد
  const hl = await p.evaluate(() => {
    const e = document.querySelector('.hero h1 .hl');
    const cs = getComputedStyle(e, '::after');
    return { bg: cs.backgroundImage.slice(0, 30), h: cs.height, z: cs.zIndex,
             ctx: getComputedStyle(document.querySelector('.hero h1')).transform };
  });
  t(/gradient/.test(hl.bg) && parseFloat(hl.h) > 0, 'موجِ رنگیِ زیرِ کلمهٔ کلیدی سرِ جایش است', hl.h);
  t(hl.ctx === 'none', 'و تیتر دیگر هیچ transform ی ندارد', hl.ctx);

  // نگهبان باید خوابیده باشد (اسکریپت رسیده)
  await p.waitForTimeout(1200);
  t(await p.evaluate(() => document.documentElement.classList.contains('anim')),
    'نگهبان کلاس را برنداشت، یعنی اسکریپت رسیده');

  // بخش‌های پایین: پیش از اسکرول پنهان، بعدش می‌آیند
  const jobsBefore = await p.evaluate(() => {
    const js = [...document.querySelectorAll('#jobs .job')];
    return { n: js.length, shown: js.filter(x => Number(getComputedStyle(x).opacity) > .9).length,
             marked: js.filter(x => x.classList.contains('rv')).length,
             delays: [...new Set(js.slice(0, 10).map(x => x.style.getPropertyValue('--d')))] };
  });
  t(jobsBefore.marked === jobsBefore.n, 'همهٔ چیپ‌های شغل برای آمدن علامت خورده‌اند', jobsBefore.marked + '/' + jobsBefore.n);
  t(jobsBefore.shown === 0, 'و پیش از رسیدن به آن‌ها پیدا نیستند', jobsBefore.shown + ' پیدا');
  t(jobsBefore.delays.length >= 3, 'و با فاصله‌های پلکانی می‌آیند', jobsBefore.delays.join(' '));

  await p.evaluate(() => document.getElementById('jobs').scrollIntoView());
  await p.waitForTimeout(1300);
  const jobsAfter = await p.evaluate(() => {
    const js = [...document.querySelectorAll('#jobs .job')];
    return { shown: js.filter(x => Number(getComputedStyle(x).opacity) > .9).length,
             moved: js.filter(x => getComputedStyle(x).transform !== 'none').length, n: js.length };
  });
  t(jobsAfter.shown === jobsAfter.n, 'با رسیدن به بخش، همه می‌آیند', jobsAfter.shown + '/' + jobsAfter.n);
  t(jobsAfter.moved === 0, 'و سرِ جای خودشان می‌ایستند', jobsAfter.moved + ' هنوز جابه‌جا');

  // پلن‌ها که با جاوااسکریپت ساخته می‌شوند هم باید بیایند
  await p.evaluate(() => document.getElementById('buy').scrollIntoView());
  await p.waitForTimeout(1400);
  const plans = await p.evaluate(() => {
    const ps = [...document.querySelectorAll('#buy .plan')];
    return { n: ps.length, marked: ps.filter(x => x.classList.contains('rv')).length,
             shown: ps.filter(x => Number(getComputedStyle(x).opacity) > .9).length };
  });
  t(plans.n > 0, 'پلن‌ها ساخته شدند', plans.n + ' پلن');
  t(plans.n > 0 && plans.marked === plans.n, 'و ناظر آن‌ها را هم دید (با اینکه بعداً ساخته شدند)', plans.marked + '/' + plans.n);
  t(plans.n > 0 && plans.shown === plans.n, 'و آمدند', plans.shown + '/' + plans.n);

  // هیچ‌چیز نباید با hover تکان بخورد
  const before = await p.evaluate(() => {
    const r = []; document.querySelectorAll('.topnav a').forEach(x => { const q = x.getBoundingClientRect();
      r.push([Math.round(q.left*100)/100, Math.round(q.top*100)/100]); }); return JSON.stringify(r);
  });
  await p.hover('.topnav a:nth-of-type(2)');
  await p.waitForTimeout(300);
  const after = await p.evaluate(() => {
    const r = []; document.querySelectorAll('.topnav a').forEach(x => { const q = x.getBoundingClientRect();
      r.push([Math.round(q.left*100)/100, Math.round(q.top*100)/100]); }); return JSON.stringify(r);
  });
  t(before === after, 'منوی بالا زیرِ موس تکان نمی‌خورد');

  // صفحه از پهنا بیرون نزند
  t(await p.evaluate(() => Math.max(0, document.documentElement.scrollWidth - innerWidth)) === 0,
    'صفحه از پهنا بیرون نمی‌زند');
  t(errs.length === 0, 'بی‌خطا', errs[0] || 'بی‌خطا');
  await p.screenshot({ path: OUT + 'anim-hero.png', clip: { x: 0, y: 0, width: 1280, height: 700 } });
  await p.close();
}

/* ---------- ۲) کسی که حرکت نمی‌خواهد ---------- */
console.log('— حرکت را نخواسته —');
{
  const ctx = await b.newContext({ viewport: { width: 1280, height: 860 }, reducedMotion: 'reduce' });
  const p = await ctx.newPage();
  await p.goto('http://127.0.0.1:8895/', { waitUntil: 'networkidle' });
  await p.waitForTimeout(800);
  t(!(await p.evaluate(() => document.documentElement.classList.contains('anim'))),
    'اصلاً روشن نمی‌شود');
  const all = await p.evaluate(() => {
    const s = [...document.querySelectorAll('.sec-head, .card, .job, .step')];
    return { n: s.length, hidden: s.filter(x => Number(getComputedStyle(x).opacity) < .9).length };
  });
  t(all.hidden === 0, 'و همه‌چیز از همان اول پیداست', all.hidden + ' پنهان از ' + all.n);
  await ctx.close();
}

/* ---------- ۳) اگر اسکریپت بشکند، صفحه نباید نامرئی بماند ---------- */
console.log('— نگهبان —');
{
  const p = await b.newPage({ viewport: { width: 1280, height: 860 } });
  // اسکریپتِ پایینِ صفحه را می‌شکنیم تا فقط head اجرا شود
  let patched = false;
  await p.route('**/', async route => {
    const r = await route.fetch();
    let body = await r.text();
    /* باید جایی بشکند که try/catch قورتش ندهد — وگرنه اسکریپت به کارش
       ادامه می‌دهد و آنچه آزموده می‌شود سناریوی دیگری است. */
    const mark = 'var SEL = ".sec-head';
    patched = body.includes(mark);
    body = body.replace(mark, 'throw new Error("boom"); ' + mark);
    await route.fulfill({ status: 200, body, headers: { 'content-type': 'text/html; charset=utf-8' } });
  });
  const errs = []; p.on('pageerror', () => errs.push(1));
  await p.goto('http://127.0.0.1:8895/', { waitUntil: 'domcontentloaded' });
  await p.waitForTimeout(600);
  t(patched, 'جایِ شکستن پیدا شد');
  t(errs.length > 0, 'و اسکریپت واقعاً شکست', errs.length + ' خطا');
  await p.waitForTimeout(3000);
  t(!(await p.evaluate(() => document.documentElement.classList.contains('anim'))),
    'نگهبان کلاس را برداشت');
  const vis = await p.evaluate(() => {
    const s = [...document.querySelectorAll('.sec-head, .card, .job, .step')];
    return { n: s.length, hidden: s.filter(x => Number(getComputedStyle(x).opacity) < .9).length };
  });
  t(vis.hidden === 0, 'و هیچ‌چیز نامرئی نماند', vis.hidden + ' پنهان از ' + vis.n);
  await p.close();
}

console.log('\n' + ok + ' ok، ' + bad + ' bad');
await b.close();
process.exit(bad ? 1 : 0);
