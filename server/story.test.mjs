/* «یک ماه در کارتابل» — بخشِ داستانیِ صفحهٔ خانه.

   الگویش از سایت‌هایی آمده که اسکرول را به زمان تبدیل می‌کنند: صحنه
   می‌چسبد و پنج فصل یکی‌یکی عوض می‌شوند، با برچسب‌هایی که به نقاطی
   از تصویر سنجاق‌اند.

   چیزی که این آزمون نگه می‌دارد، خودِ جلوه نیست — آن لایهٔ اضافه است
   و اگر نباشد کسی چیزی را از دست نمی‌دهد. چیزی که نباید از دست برود
   این است: روی گوشی، با prefers-reduced-motion، و بی جاوااسکریپت،
   هر پنج فصل با تصویر و توضیحشان دیده شوند.

   جلوه‌ای که فقط روی دسکتاپِ من کار کند و جای دیگر چیزی نصفه بگذارد،
   از نبودنش بدتر است. */
import { launch } from './pw.mjs';
import { HOME, panelHtml } from './where.mjs';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await launch();
const errs = [];

/* ---------- ساختار، از خودِ HTML ---------- */
console.log('— ساختار —');
{
  const html = await panelHtml('/');
  const chs = (html.match(/class="st-ch"/g) || []).length;
  t(chs === 5, 'پنج فصل در خودِ HTML هست', String(chs));
  const shots = [...new Set([...html.matchAll(/\/shots\/([a-z]+\.jpg)/g)].map(m => m[1]))];
  t(shots.length >= 4, 'و تصویرهایشان از /shots/ می‌آیند', shots.join('، '));
  const pins = (html.match(/class="st-pin/g) || []).length;
  t(pins >= 10, 'و برچسب‌ها سرِ جایشان‌اند', pins + ' برچسب');
  /* هر برچسب باید مختصات داشته باشد وگرنه گوشهٔ تصویر می‌نشیند */
  const withXY = (html.match(/class="st-pin[^"]*" style="--x:[0-9]+%;--y:[0-9]+%/g) || []).length;
  t(withXY === pins, 'هر برچسب مختصاتِ خودش را دارد', `${withXY} از ${pins}`);
  t(/روی هر تصویر بزنید تا بزرگ شود/.test(html), 'و تصویرها هنوز بزرگ‌شدنی‌اند');
}

async function look(opt) {
  const c = await b.newContext(opt);
  const p = await c.newPage();
  p.on('pageerror', e => errs.push(String(e).slice(0, 110)));
  await p.goto(HOME, { waitUntil: 'networkidle' });
  await p.evaluate(() => document.getElementById('look').scrollIntoView());
  await p.waitForTimeout(800);
  return { c, p };
}
const sense = p => p.evaluate(() => {
  const s = document.getElementById('story');
  return {
    on: s.classList.contains('st-on'),
    shown: [...s.querySelectorAll('.st-ch')].filter(x => x.getBoundingClientRect().height > 40).length,
    pins: [...s.querySelectorAll('.st-pin')].filter(x => getComputedStyle(x).opacity !== '0').length,
    slip: Math.round(document.documentElement.scrollWidth - innerWidth),
    imgs: [...s.querySelectorAll('.st-img img')].filter(i => i.naturalWidth > 0).length
  };
});

/* ---------- دسکتاپ: حالتِ چسبان ---------- */
console.log('— دسکتاپ —');
{
  const { c, p } = await look({ viewport: { width: 1360, height: 900 } });
  const s0 = await sense(p);
  t(s0.on, 'حالتِ چسبان روشن است');
  t(s0.imgs === 5, 'و هر پنج تصویر واقعاً بار شده‌اند', String(s0.imgs));
  t(s0.slip <= 1, 'و صفحه افقی نمی‌لغزد', String(s0.slip));

  const track = await p.evaluate(() => {
    const r = document.querySelector('.st-track').getBoundingClientRect();
    return { top: scrollY + r.top, span: r.height - innerHeight };
  });
  const seen = [];
  for (let i = 0; i < 5; i++) {
    await p.evaluate(a => scrollTo({ top: a.top + a.span * ((a.i + 0.5) / 5) }), { ...track, i });
    await p.waitForTimeout(900);
    seen.push(await p.evaluate(() => {
      const on = [...document.querySelectorAll('.st-ch')].findIndex(x => x.classList.contains('on'));
      const cur = [...document.querySelectorAll('#stRail button')].findIndex(x => x.getAttribute('aria-current') === 'true');
      const pins = [...document.querySelectorAll('.st-ch.on .st-pin')].filter(x => getComputedStyle(x).opacity !== '0').length;
      return { on, cur, pins };
    }));
  }
  t(seen.every((x, i) => x.on === i), 'اسکرول فصل‌ها را به ترتیب جلو می‌برد',
    seen.map(x => x.on).join('→'));
  t(seen.every((x, i) => x.cur === i), 'و ریل همان فصل را نشان می‌دهد',
    seen.map(x => x.cur).join('→'));
  t(seen.every(x => x.pins > 0), 'و برچسب‌های هر فصل ظاهر می‌شوند',
    seen.map(x => x.pins).join('، '));

  /* زدنِ ریل باید ببردمان همان‌جا */
  await p.evaluate(() => document.querySelectorAll('#stRail button')[1].click());
  await p.waitForTimeout(1400);
  const jumped = await p.evaluate(() =>
    [...document.querySelectorAll('.st-ch')].findIndex(x => x.classList.contains('on')));
  t(jumped === 1, 'زدنِ ریل به همان فصل می‌برد', 'فصل ' + jumped);
  await c.close();
}

/* ---------- جاهایی که جلوه نباید باشد ---------- */
for (const [label, opt] of [
  ['گوشی ۴۱۲', { viewport: { width: 412, height: 860 } }],
  ['جنبشِ کمتر', { viewport: { width: 1360, height: 900 }, reducedMotion: 'reduce' }],
  ['بی جاوااسکریپت', { viewport: { width: 1360, height: 900 }, javaScriptEnabled: false }]
]) {
  console.log(`— ${label} —`);
  const { c, p } = await look(opt);
  const s = await sense(p);
  t(!s.on, 'حالتِ چسبان خاموش است');
  t(s.shown === 5, 'و هر پنج فصل دیده می‌شوند', String(s.shown));
  t(s.pins >= 10, 'و همهٔ برچسب‌ها پیدا', String(s.pins));
  t(s.slip <= 1, 'و صفحه افقی نمی‌لغزد', String(s.slip));
  await c.close();
}

t(errs.length === 0, 'هیچ خطای صفحه‌ای نبود', errs.join(' | ') || 'پاک');
await b.close();
console.log((bad ? 'BAD ' : '') + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
