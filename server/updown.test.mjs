/* دکمهٔ «برو بالا / برو پایین» در هر دو کارتابل و در پنلِ ادمین.

   سه چیز را نگه می‌دارد:

   یک) دکمه دقیقاً وقتی دیده می‌شود که صفحه اسکرول داشته باشد. ارتفاعِ
   صفحه با عوض شدنِ تب و اندازهٔ پنجره مدام تغییر می‌کند، پس آزمون
   وضعیتِ یک لحظه را نمی‌سنجد؛ در چند تب و چند اندازه همان قاعده را
   می‌سنجد.

   دو) هر زدنی یک پرشِ کامل است: از بالا تا ته، و از ته تا بالا.

   سه) کفِ صفحه شلوغ است و دکمه نباید روی چیزی بیفتد. اولین جایی که
   گذاشته شد گوشهٔ راست بود و درست روی «خروج از کارتابل» افتاد — در
   صفحهٔ راست‌به‌چپ، ستونِ بخش‌ها سمتِ راست است. پس آزمون جای دکمه را
   نمی‌سنجد، هم‌پوشانی‌اش را می‌سنجد: با تهِ ستونِ بخش‌ها، با دکمهٔ
   گفتگو، و با نوارِ پایینیِ حالتِ برنامه. */
import { launch } from './pw.mjs';
import { IT, FIN, ADMIN, IT_API, IT_PASS, FIN_API, FIN_PASS, signIn } from './where.mjs';

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const b = await launch();
const errs = [];

/* اسکرولِ نرم چند صدم ثانیه طول می‌کشد و اندازهٔ صفحه هم فرق می‌کند؛
   پس منتظرِ «ایستادنِ» صفحه می‌مانیم، نه یک عددِ ثابتِ حدسی. */
async function settle(p) {
  let last = -1;
  for (let i = 0; i < 30; i++) {
    const y = await p.evaluate(() => Math.round(window.scrollY));
    if (y === last) return y;
    last = y;
    await p.waitForTimeout(120);
  }
  return last;
}

const probe = p => p.evaluate(() => {
  const el = document.querySelector('.updown');
  if (!el) return null;
  const r = el.getBoundingClientRect();
  /* هر چیزی که کفِ صفحه نشسته و دکمه نباید رویش بیفتد */
  const hits = [];
  for (const sel of ['.ch-fab-wrap', '.sidebar-foot', '.appbar', '.demobar', '.pwa-up']) {
    for (const el of document.querySelectorAll(sel)) {
      const f = el.getBoundingClientRect();
      if (!f.width || !f.height) continue;
      if (getComputedStyle(el).display === 'none') continue;
      if (!(r.right <= f.left || f.right <= r.left || r.bottom <= f.top || f.bottom <= r.top))
        hits.push(sel);
    }
  }
  return {
    n: document.querySelectorAll('.updown').length,
    off: el.classList.contains('off'),
    up: el.classList.contains('up'),
    title: el.title,
    aria: el.getAttribute('aria-label'),
    z: getComputedStyle(el).zIndex,
    right: Math.round(innerWidth - r.right),
    bottom: Math.round(innerHeight - r.bottom),
    w: Math.round(parseFloat(getComputedStyle(el).width)),
    hits,
    left: Math.round(r.left),
    max: Math.round(Math.max(0, document.documentElement.scrollHeight - innerHeight)),
    y: Math.round(window.scrollY)
  };
});

/* ---------------- کارتابلِ فنی ---------------- */
const ctx = await b.newContext({ viewport: { width: 1400, height: 950 } });
const p = await ctx.newPage();
p.on('pageerror', e => errs.push('it: ' + String(e).slice(0, 130)));
p.on('dialog', d => d.accept());
await signIn(p, IT, IT_API, IT_PASS);
await p.waitForTimeout(600);

console.log('— هست و سرِ جایش است —');
{
  const r = await probe(p);
  t(!!r, 'دکمه در کارتابلِ فنی هست');
  t(r && r.n === 1, 'یکی است، نه چندتا', r && r.n);
  t(r && r.bottom <= 70 && r.bottom >= 0, 'به کفِ صفحه چسبیده', r && r.bottom);
  t(r && r.hits.length === 0,
    'و روی هیچ‌کدام از چیزهای کفِ صفحه نمی‌افتد — نه تهِ ستونِ بخش‌ها، نه دکمهٔ گفتگو',
    r && (r.hits.length ? 'روی ' + r.hits.join(' و ') : 'پاک'));
  /* پنجره‌ها و نوارهای هشدار باید رویش بیفتند، نه زیرش */
  t(r && Number(r.z) < 100, 'z-index پایین است تا پنجره‌ها رویش بیایند', r && r.z);
  t(r && !r.up && r.title === 'به پایین صفحه',
    'سرِ صفحه، پیکان به پایین است', r && r.title);
  t(r && r.aria === r.title, 'نامِ دسترس‌پذیری همان متنِ راهنماست', r && r.aria);
}

console.log('— پرش —');
{
  const before = await probe(p);
  t(before.max >= 220 && !before.off, 'در صفحهٔ بلند دیده می‌شود', 'ارتفاعِ اسکرول ' + before.max);
  await p.click('.updown');
  /* جهتِ پیکان همان لحظه برمی‌گردد، نه بعدِ نشستنِ صفحه */
  await p.waitForTimeout(160);
  const mid = await p.evaluate(() => document.querySelector('.updown').classList.contains('up'));
  t(mid, 'همان لحظهٔ زدن، پیکان برمی‌گردد — وسطِ حرکت تصمیمش عوض نمی‌شود');

  const y = await settle(p);
  const after = await probe(p);
  t(Math.abs(y - after.max) <= 4, 'یک زدن، تا تهِ صفحه', y + ' از ' + after.max);
  t(after.up && after.title === 'به بالای صفحه', 'و حالا پیکان به بالاست', after.title);

  await p.click('.updown');
  const y2 = await settle(p);
  const back = await probe(p);
  t(y2 <= 2, 'زدنِ بعدی، تا سرِ صفحه', String(y2));
  t(!back.up && back.title === 'به پایین صفحه', 'و پیکان دوباره به پایین', back.title);
}

console.log('— جهت از روی جای خودِ صفحه —');
{
  await p.evaluate(() => { const m = document.documentElement.scrollHeight - innerHeight;
    window.scrollTo(0, Math.round(m * 0.3)); });
  await p.waitForTimeout(400);
  t(await p.evaluate(() => !document.querySelector('.updown').classList.contains('up')),
    'نیمهٔ بالا: پیکان به پایین');
  await p.evaluate(() => { const m = document.documentElement.scrollHeight - innerHeight;
    window.scrollTo(0, Math.round(m * 0.7)); });
  await p.waitForTimeout(400);
  t(await p.evaluate(() => document.querySelector('.updown').classList.contains('up')),
    'نیمهٔ پایین: پیکان به بالا');
  await p.evaluate(() => window.scrollTo(0, 0));
  await p.waitForTimeout(400);
}

/* ---------------- قاعده: دکمه فقط وقتی صفحه اسکرول دارد ----------------
   در چند تب و چند اندازهٔ پنجره، همان یک قاعده سنجیده می‌شود. اگر
   هیچ حالتی پیش نیاید که دکمه پنهان شود، خودِ آزمون بی‌معنی است —
   پس آن هم شمرده می‌شود. */
console.log('— هست اگر و فقط اگر اسکرول باشد —');
{
  let hid = 0, seen = 0, wrong = [];
  const views = ['dashboard', 'checklist', 'guide', 'datetools', 'settings'];
  for (const h of [950, 2600]) {
    await p.setViewportSize({ width: 1400, height: h });
    for (const v of views) {
      const has = await p.evaluate(n => {
        const el = document.querySelector('.navbtn[data-view="' + n + '"]');
        if (!el || el.offsetParent === null) return false;
        el.click(); return true;
      }, v);
      if (!has) continue;
      await p.waitForTimeout(600);
      const r = await probe(p);
      seen++;
      if (r.off) hid++;
      if (r.off !== (r.max < 220)) wrong.push(v + '@' + h + ' (max=' + r.max + ', off=' + r.off + ')');
    }
  }
  t(seen >= 6, 'در چند تب و دو اندازهٔ پنجره سنجیده شد', seen + ' حالت');
  t(wrong.length === 0, 'هر جا اسکرول بود دکمه بود، هر جا نبود نبود',
    wrong.length ? wrong.join(' · ') : 'همه درست');
  t(hid > 0, 'و دست‌کم یک حالت پیش آمد که صفحه اسکرول نداشت و دکمه رفت',
    hid + ' حالت');
  await p.setViewportSize({ width: 1400, height: 950 });
  await p.evaluate(() => document.querySelector('.navbtn[data-view="dashboard"]').click());
  await p.waitForTimeout(600);
  t(!(await probe(p)).off, 'و با برگشتن به تبِ بلند، دوباره آمد');
}

/* ---------------- نسخهٔ نمایشی ----------------
   نوارِ «دمو» کفِ صفحه را می‌گیرد و از دکمه‌های شناور بالاتر می‌نشیند
   (z-index ۱۴۰ در برابرِ ۹۰ و ۸۱). پس هر دو باید از رویش رد شوند.

   دکمهٔ گفتگو تا امروز رد نمی‌شد: قاعده‌اش «.chat-fab» را هدف گرفته
   بود، که نامِ کلاسِ خودِ body است نه نامِ قابِ دکمه، و روی body هیچ
   کاری نمی‌کرد. این آزمون همان را هم نگه می‌دارد. */
console.log('— نوارِ نسخهٔ نمایشی —');
{
  const r = await p.evaluate(() => {
    document.documentElement.setAttribute('data-demo', '1');
    const bar = document.createElement('div');
    bar.className = 'demobar';
    bar.innerHTML = '<b>نسخهٔ نمایشی</b> — داده‌ها واقعی نیستند.';
    document.body.appendChild(bar);
    return true;
  });
  await p.waitForTimeout(500);
  const g = await p.evaluate(() => {
    const bar = document.querySelector('.demobar').getBoundingClientRect();
    const hit = sel => {
      const el = document.querySelector(sel);
      if (!el) return 'نیست';
      const f = el.getBoundingClientRect();
      return (f.bottom > bar.top) ? 'زیرِ نوار' : 'بالای نوار';
    };
    return { h: Math.round(bar.height), ud: hit('.updown'), fab: hit('.ch-fab-wrap') };
  });
  t(g.h > 20, 'نوارِ دمو در صفحه هست', g.h + 'پیکسل');
  t(g.ud === 'بالای نوار', 'دکمهٔ پریدن از روی نوارِ دمو رد می‌شود', g.ud);
  t(g.fab === 'بالای نوار', 'دکمهٔ گفتگو هم همین‌طور', g.fab);
  await p.evaluate(() => {
    document.documentElement.removeAttribute('data-demo');
    const b = document.querySelector('.demobar'); if (b) b.remove();
  });
  await p.waitForTimeout(300);
}

/* ---------------- کارتابلِ مالی ---------------- */
console.log('— کارتابلِ مالی —');
{
  const c2 = await b.newContext({ viewport: { width: 1400, height: 950 } });
  const p2 = await c2.newPage();
  p2.on('pageerror', e => errs.push('fin: ' + String(e).slice(0, 130)));
  p2.on('dialog', d => d.accept());
  await signIn(p2, FIN, FIN_API, FIN_PASS);
  await p2.waitForTimeout(600);
  const r = await probe(p2);
  t(!!r && r.n === 1, 'دکمه در کارتابلِ مالی هم هست');
  t(r && r.hits.length === 0, 'و آن‌جا هم روی چیزی نمی‌افتد',
    r && (r.hits.join(' و ') || 'پاک'));
  if (r && !r.off) {
    await p2.click('.updown');
    const y = await settle(p2);
    t(Math.abs(y - (await probe(p2)).max) <= 4, 'و همان‌جا هم تا ته می‌برد', String(y));
  } else {
    t(r && r.max < 220, 'صفحه‌اش اسکرول نداشت، پس دکمه هم پنهان بود', r && r.max);
  }
  await c2.close();
}

/* ---------------- پنلِ ادمین ---------------- */
console.log('— پنلِ ادمین —');
{
  /* پنجرهٔ کوتاه و فهرستِ بلند، تا صفحه واقعاً اسکرول داشته باشد —
     وگرنه دکمه درست کار می‌کند و پنهان می‌ماند، و آزمون چیزی را
     نسنجیده. */
  const c3 = await b.newContext({ viewport: { width: 1280, height: 540 } });
  const p3 = await c3.newPage();
  p3.on('pageerror', e => errs.push('admin: ' + String(e).slice(0, 130)));
  p3.on('dialog', d => d.accept());
  await p3.goto(ADMIN, { waitUntil: 'networkidle' });
  await p3.waitForTimeout(1200);
  await p3.evaluate(() => {
    const g = document.getElementById('gate'); if (g) { g.hidden = true; g.innerHTML = ''; }
    document.getElementById('app').hidden = false;
    DATA = { items: Array.from({ length: 14 }, (_, i) => ({
        slug: 'k' + i, name: 'کارتابل ' + i, closed: false, hasEscrow: true,
        job: 'it', user: 'u' + i, until: Date.now() + 9e9 })),
      jobs: [{ id: 'it', label: 'مدیر IT' }], kinds: [], escrowReady: true,
      features: [], views: {} };
    renderPlanners();
  });
  await p3.waitForTimeout(900);
  const r = await probe(p3);
  t(!!r && r.n === 1, 'دکمه در پنلِ ادمین هم هست');
  t(r && Number(r.z) < 100, 'با همان z-index پایین', r && r.z);
  t(r && r.w === 42, 'و اندازه‌اش درست گرفته — CSSش آمده', r && (r.w + 'پیکسل'));
  t(r && r.max >= 220 && !r.off, 'در صفحهٔ بلندِ پنل دیده می‌شود',
    r && ('ارتفاعِ اسکرول ' + r.max));
  if (r && !r.off) {
    await p3.click('.updown');
    const y = await settle(p3);
    t(Math.abs(y - (await probe(p3)).max) <= 4, 'و آن‌جا هم تا ته می‌برد', String(y));
  }
  await c3.close();
}

/* ---------------- گوشی، در حالتِ برنامه ----------------
   نوارِ پایینیِ برنامه کفِ صفحه را می‌گیرد و هر چیزی که آن‌جا باشد
   زیرش می‌ماند. */
console.log('— گوشی —');
{
  const c4 = await b.newContext({ viewport: { width: 390, height: 760 },
    isMobile: true, hasTouch: true, deviceScaleFactor: 2 });
  const p4 = await c4.newPage();
  p4.on('pageerror', e => errs.push('mob: ' + String(e).slice(0, 130)));
  p4.on('dialog', d => d.accept());
  await signIn(p4, IT, IT_API, IT_PASS);
  /* حالتِ «نصب‌شده» را خودِ صفحه از display-mode می‌فهمد و کرومیومِ
     آزمون آن را جعل نمی‌کند، پس نوارِ پایینی ساخته نمی‌شود. خودِ
     نوار را این‌جا می‌گذاریم: نشانه و چیدمان و ارتفاعش همان CSSِ
     واقعیِ pwacss است و تنها چیزی که جعلی است، سازنده‌اش. */
  await p4.evaluate(() => {
    document.documentElement.setAttribute('data-app', '1');
    const bar = document.createElement('nav');
    bar.className = 'appbar';
    bar.id = 'appBar';
    bar.innerHTML = ('<button type="button" class="ab">' +
      '<span class="i"><svg viewBox="0 0 24 24" width="21" height="21"></svg></span>' +
      '<span class="l">بخش</span></button>').repeat(5);
    document.body.appendChild(bar);
  });
  await p4.waitForTimeout(900);
  const r = await probe(p4);
  t(!!r && r.n === 1, 'روی گوشی هم هست');
  t(r && r.w === 38, 'یک پله کوچک‌تر است', r && (r.w + 'پیکسل'));
  const bar = await p4.evaluate(() => !!document.querySelector('.appbar') &&
    getComputedStyle(document.querySelector('.appbar')).display !== 'none');
  t(bar, 'نوارِ پایینیِ برنامه در صفحه هست — یعنی این سنجش بی‌معنی نیست');
  t(r && r.hits.length === 0, 'و دکمه زیرِ نوارِ پایینی نمی‌ماند',
    r && (r.hits.join(' و ') || 'پاک'));
  await c4.close();
}

console.log('— خطا —');
t(errs.length === 0, 'هیچ خطای صفحه‌ای نبود', errs.join(' | ') || 'پاک');

await ctx.close();
await b.close();
console.log((bad ? 'BAD ' : '') + ok + ' ok، ' + bad + ' bad');
process.exit(bad ? 1 : 0);
