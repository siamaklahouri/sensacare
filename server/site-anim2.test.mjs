import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';
const OUT = '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/kt/';
let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const sx = s => { const m = String(s).match(/matrix\(([-\d.]+)/); return m ? Number(m[1]) : null; };
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });

const p = await b.newPage({ viewport: { width: 1280, height: 860 } });
const errs = []; p.on('pageerror', e => errs.push(String(e).slice(0, 180)));
await p.goto('http://127.0.0.1:8895/', { waitUntil: 'networkidle' });
await p.waitForTimeout(1500);

/* ---- نوارِ پیشرفت ---- */
console.log('— نوارِ پیشرفت —');
const p0 = await p.evaluate(() => {
  const e = document.getElementById('prog'); const c = getComputedStyle(e);
  /* transformOrigin به پیکسل حساب می‌شود، نه با کلمهٔ right — پس با
     پهنای خودِ عنصر می‌سنجیمش: لنگر روی لبهٔ راست یعنی x برابرِ پهنا. */
  return { tr: c.transform, originX: parseFloat(c.transformOrigin), w: e.offsetWidth,
           h: c.height, bg: c.backgroundImage.slice(0, 22),
           inTop: !!e.closest('.top') };
});
t(p0.inTop, 'نوار داخلِ نوارِ چسبان است');
t(sx(p0.tr) !== null && sx(p0.tr) < 0.05, 'اولِ صفحه تقریباً خالی است', String(sx(p0.tr)));
t(/gradient/.test(p0.bg), 'و رنگی است', p0.bg);
t(p0.w > 0 && Math.abs(p0.originX - p0.w) < 1.5, 'و از راست پر می‌شود (راست‌به‌چپ)',
  'لنگر ' + Math.round(p0.originX) + ' از پهنای ' + p0.w);

await p.evaluate(() => scrollTo(0, document.documentElement.scrollHeight / 2));
await p.waitForTimeout(450);
const pMid = sx(await p.evaluate(() => getComputedStyle(document.getElementById('prog')).transform));
await p.evaluate(() => scrollTo(0, document.documentElement.scrollHeight));
await p.waitForTimeout(500);
const pEnd = sx(await p.evaluate(() => getComputedStyle(document.getElementById('prog')).transform));
t(pMid > .3 && pMid < .8, 'وسطِ صفحه نیمه است', pMid.toFixed(2));
t(pEnd > .97, 'و ته صفحه پر', pEnd.toFixed(2));

/* ---- خطِ لغزانِ منو ---- */
console.log('— خطِ لغزانِ منو —');
/* جایی که قرص واقعاً روی صفحه می‌افتد سنجیده می‌شود، نه عددی که به
   transform داده‌ایم — آن عدد با خودش می‌خواند حتی وقتی قرص بیرونِ
   نوار افتاده باشد. */
const readDot = () => p.evaluate(() => {
  const d = document.getElementById('navdot'), a = document.querySelector('.topnav a.on');
  const n = document.getElementById('topnav');
  const dr = d.getBoundingClientRect(), ar = a ? a.getBoundingClientRect() : null;
  const nr = n.getBoundingClientRect();
  return { w: dr.width, cx: dr.left + dr.width / 2, op: Number(getComputedStyle(d).opacity),
           on: a ? a.textContent.trim() : null,
           aCx: ar ? ar.left + ar.width / 2 : null, aW: ar ? ar.width : null,
           inside: dr.left >= nr.left - 1 && dr.right <= nr.right + 1 };
});
await p.evaluate(() => document.getElementById('jobs').scrollIntoView());
await p.waitForTimeout(700);
const d1 = await readDot();
t(d1.op > .9, 'خط دیده می‌شود', d1.op.toFixed(2));
t(d1.on === 'شغل‌ها', 'و بخشِ جاری «شغل‌ها» است', d1.on);
t(Math.abs(d1.cx - d1.aCx) < 2, 'و دقیقاً روی همان گزینه نشسته',
  'مرکزِ قرص ' + Math.round(d1.cx) + ' / مرکزِ گزینه ' + Math.round(d1.aCx));
t(Math.abs(d1.w - d1.aW) < 2, 'و هم‌اندازهٔ همان گزینه است',
  Math.round(d1.w) + ' / ' + Math.round(d1.aW));
t(d1.inside, 'و داخلِ خودِ نوار است، نه بیرونش');

await p.evaluate(() => document.getElementById('faq').scrollIntoView());
await p.waitForTimeout(800);
const d2 = await readDot();
t(d2.on === 'پرسش‌ها', 'با رفتن به بخشِ دیگر، بخشِ جاری عوض می‌شود', d2.on);
t(Math.abs(d2.cx - d1.cx) > 8, 'و قرص لغزیده', Math.round(d1.cx) + ' → ' + Math.round(d2.cx));
t(Math.abs(d2.cx - d2.aCx) < 2, 'و باز هم دقیقاً روی همان گزینه');
t(d2.inside, 'و داخلِ نوار مانده');

/* ---- شمردنِ عدد ---- */
console.log('— شمردنِ عدد —');
await p.goto('http://127.0.0.1:8895/', { waitUntil: 'networkidle' });
await p.waitForTimeout(900);
const finals = await p.evaluate(() => [...document.querySelectorAll('#jobs .job .c')].map(x => x.textContent.trim()));
await p.evaluate(() => document.getElementById('jobs').scrollIntoView());
await p.waitForTimeout(120);
const mid = await p.evaluate(() => [...document.querySelectorAll('#jobs .job .c')].map(x => x.textContent.trim()));
await p.waitForTimeout(1600);
const done = await p.evaluate(() => [...document.querySelectorAll('#jobs .job .c')].map(x => x.textContent.trim()));
t(mid.some((v, i) => v !== finals[i]), 'وسطِ راه عددها هنوز نرسیده‌اند', mid.slice(0, 4).join(' | '));
t(JSON.stringify(done) === JSON.stringify(finals), 'ولی آخرش دقیقاً همان عددِ درست است',
  done.slice(0, 4).join(' | '));
t(done.every(v => !/[0-9]/.test(v)), 'و همه‌شان فارسی‌اند، نه لاتین', done[0]);

/* ---- پرسش‌ها ---- */
console.log('— پرسش‌ها —');
await p.evaluate(() => document.getElementById('faq').scrollIntoView());
await p.waitForTimeout(600);
await p.evaluate(() => document.querySelector('#faq details summary').click());
await p.waitForTimeout(60);
const fq = await p.evaluate(() => {
  const d = document.querySelector('#faq details');
  const par = d.querySelector('p');
  return { open: d.open, anim: getComputedStyle(par).animationName,
           op: Number(getComputedStyle(par).opacity) };
});
t(fq.open, 'باز می‌شود');
t(fq.anim === 'faqIn', 'و جوابش با انیمیشن می‌آید', fq.anim);
await p.waitForTimeout(500);
t(await p.evaluate(() => Number(getComputedStyle(document.querySelector('#faq details p')).opacity)) > .99,
  'و کامل می‌نشیند');

/* ---- موجِ زیرِ کلمه ---- */
console.log('— موجِ زیرِ کلمهٔ کلیدی —');
await p.goto('http://127.0.0.1:8895/', { waitUntil: 'domcontentloaded' });
await p.waitForTimeout(200);
const sw0 = await p.evaluate(() => getComputedStyle(document.querySelector('.hero h1 .hl'), '::after').transform);
await p.waitForTimeout(1600);
const sw1 = await p.evaluate(() => {
  const c = getComputedStyle(document.querySelector('.hero h1 .hl'), '::after');
  return { tr: c.transform, op: Number(c.opacity), h: c.height };
});
t(sx(sw0) !== null && sx(sw0) < .9, 'اول کشیده نشده', String(sx(sw0)));
t(sw1.tr === 'none' || sx(sw1.tr) > .99, 'و بعد کامل کشیده می‌شود', sw1.tr.slice(0, 24));
t(sw1.op > .99 && parseFloat(sw1.h) > 0, 'و سرِ جایش می‌ماند', sw1.h);

/* ---- هیچ‌چیز با hover تکان نخورد ---- */
const snap = () => p.evaluate(() => {
  const r = []; document.querySelectorAll('.topnav a, .job, .card').forEach(x => {
    const q = x.getBoundingClientRect(); r.push([Math.round(q.left*50)/50, Math.round(q.top*50)/50]); });
  return JSON.stringify(r);
});
await p.waitForTimeout(400);
const s1 = await snap();
await p.hover('.topnav a:nth-of-type(3)');
await p.waitForTimeout(450);
t(await snap() === s1, 'زیرِ موس هیچ‌چیز جابه‌جا نمی‌شود');

t(await p.evaluate(() => Math.max(0, document.documentElement.scrollWidth - innerWidth)) === 0,
  'صفحه از پهنا بیرون نمی‌زند');
t(errs.length === 0, 'بی‌خطا', errs[0] || 'بی‌خطا');
await p.close();

/* ---- حرکت را نمی‌خواهم ---- */
console.log('— حرکت را نمی‌خواهم —');
{
  const ctx = await b.newContext({ viewport: { width: 1280, height: 860 }, reducedMotion: 'reduce' });
  const q = await ctx.newPage();
  const e2 = []; q.on('pageerror', e => e2.push(String(e).slice(0, 120)));
  await q.goto('http://127.0.0.1:8895/', { waitUntil: 'networkidle' });
  await q.waitForTimeout(700);
  await q.evaluate(() => scrollTo(0, document.documentElement.scrollHeight / 2));
  await q.waitForTimeout(400);
  const r = await q.evaluate(() => {
    const pr = getComputedStyle(document.getElementById('prog'));
    const dt = getComputedStyle(document.getElementById('navdot'));
    const m = pr.transform.match(/matrix\(([-\d.]+)/);
    return { progFilled: m ? Number(m[1]) : 0, progTrans: pr.transitionDuration,
             dotTrans: dt.transitionDuration, dotOp: Number(dt.opacity),
             nums: [...document.querySelectorAll('#jobs .job .c')].slice(0,3).map(x=>x.textContent.trim()) };
  });
  t(r.progFilled > .3, 'نوارِ پیشرفت همچنان کار می‌کند', r.progFilled.toFixed(2));
  t(/^0s(, 0s)*$/.test(r.progTrans), 'ولی بی‌لغزش', r.progTrans);
  t(/^0s(, 0s)*$/.test(r.dotTrans), 'خطِ منو هم بی‌لغزش', r.dotTrans);
  t(r.nums.every(v => /[۰-۹]/.test(v)), 'و عددها سرِ جایشان‌اند، نه صفر', r.nums.join(' | '));
  t(e2.length === 0, 'بی‌خطا', e2[0] || 'بی‌خطا');
  await ctx.close();
}

console.log('\n' + ok + ' ok، ' + bad + ' bad');
await b.close();
process.exit(bad ? 1 : 0);
