/* تمِ کارتابل (در تنظیمات) و گامِ تازهٔ رنگِ نمودارها.
   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const WHO = [
  { slug: 'siamak', page: '/siamak/', api: 'kartabl', pass: 'siamaksiamak', name: 'کارتابلِ فنی' },
  { slug: 'sina', page: '/sina/', api: 'sina', pass: 'sinasinasina', name: 'کارتابلِ مالی' }
];

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };
const mk = () => { let ck = ''; return async (path, opt) => {
  const o = Object.assign({ headers: {} }, opt || {});
  o.headers = Object.assign({ 'Content-Type': 'application/json' }, o.headers, ck ? { cookie: ck } : {});
  const r = await fetch(BASE + path, o);
  for (const c of (r.headers.getSetCookie ? r.headers.getSetCookie() : [])) {
    const kv = c.split(';')[0], k = kv.split('=')[0];
    ck = ck.split('; ').filter(x => x && x.split('=')[0] !== k).concat([kv]).join('; ');
  }
  try { return await r.json(); } catch (e) { return {}; }
}; };
const adm = mk();
await adm('/api/admin.planer/signin',
  { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
for (const w of WHO)
  await adm('/api/admin.planer/planners/' + w.slug + '/password',
    { method: 'POST', body: JSON.stringify({ password: w.pass }) });

/* کنتراست، همان‌طور که مرورگر رنگ را می‌دهد */
const lum = c => {
  const m = String(c).match(/\d+(\.\d+)?/g) || [];
  const [r, g, b] = m.slice(0, 3).map(Number).map(v => {
    v /= 255;
    return v <= 0.04045 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
  });
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
};
const ct = (a, b) => Math.round(((Math.max(lum(a), lum(b)) + 0.05) /
                                 (Math.min(lum(a), lum(b)) + 0.05)) * 10) / 10;

const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const errs = [];

for (const w of WHO) {
  console.log('===== ' + w.name + ' =====');
  const p = await b.newPage({ viewport: { width: 1340, height: 950 } });
  p.on('pageerror', e => errs.push(w.slug + ': ' + String(e).slice(0, 160)));
  p.on('dialog', d => d.accept());
  await p.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await p.evaluate(async a => {
    await fetch('/api/' + a.api + '/login', { method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ password: a.pass, remember: false }) });
  }, { api: w.api, pass: w.pass });
  await p.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await p.waitForTimeout(2900);
  await p.evaluate(() => document.querySelector('.navbtn[data-view="settings"]').click());
  await p.waitForTimeout(800);

  const cards = await p.evaluate(() =>
    [...document.querySelectorAll('#ktList .kt-card')].map(x => ({
      id: x.getAttribute('data-kt-pick'),
      name: x.querySelector('.kt-name').textContent.replace('✓', '').trim(),
      on: x.classList.contains('on'),
      swatch: !!x.querySelector('.kt-swatch .s-bg')
    })));
  t(cards.length >= 5, 'بخشِ «تم کارتابل» در تنظیمات هست و چند تم دارد',
    cards.map(x => x.name).join('، '));
  t(cards.every(x => x.swatch), 'هر تم نمونهٔ رنگِ خودش را نشان می‌دهد');
  t(cards[0].id === '' && /کلاسیک/.test(cards[0].name), 'اولی «کلاسیک» است');
  t(cards.filter(x => x.on).length === 1, 'و دقیقاً یکی انتخاب‌شده است');

  const look = () => p.evaluate(() => {
    const cs = getComputedStyle(document.documentElement);
    return { kt: document.documentElement.getAttribute('data-kt'),
             theme: document.documentElement.getAttribute('data-theme'),
             paper: cs.getPropertyValue('--paper').trim(),
             brass: cs.getPropertyValue('--brass').trim(),
             ink: cs.getPropertyValue('--ink').trim(),
             bodyBg: getComputedStyle(document.body).backgroundColor,
             bodyInk: getComputedStyle(document.body).color,
             inState: (state.ui || {}).theme };
  });
  const base = await look();

  /* هر تم: رنگ عوض می‌شود، ولی خوانایی سرِ جایش می‌ماند */
  console.log('--- تم‌ها، در روز ---');
  const seen = {};
  for (const c of cards.filter(x => x.id)) {
    await p.evaluate(id => document.querySelector('[data-kt-pick="' + id + '"]').click(), c.id);
    await p.waitForTimeout(450);
    const v = await look();
    seen[c.id] = v;
    const contrast = ct(v.bodyInk, v.bodyBg);
    t(v.kt === c.id && v.paper !== base.paper && v.brass !== base.brass,
      'تمِ «' + c.name + '» کاغذ و رنگِ برند را عوض می‌کند',
      v.paper + ' / ' + v.brass);
    t(contrast >= 4.5, '…و نوشته روی کاغذش خوانا می‌ماند', contrast + ':۱');
    t(v.inState === c.id, '…و انتخاب در دادهٔ کارتابل ذخیره می‌شود', String(v.inState));
  }
  const papers = Object.values(seen).map(v => v.paper);
  t(new Set(papers).size === papers.length, 'هیچ دو تمی کاغذِ یکسان ندارند', papers.join(' '));

  /* شب */
  console.log('--- و در شب ---');
  await p.evaluate(() => document.getElementById('themeBtn').click());
  await p.waitForTimeout(700);
  let darkBad = [];
  for (const c of cards.filter(x => x.id)) {
    await p.evaluate(id => document.querySelector('[data-kt-pick="' + id + '"]').click(), c.id);
    await p.waitForTimeout(400);
    const v = await look();
    const contrast = ct(v.bodyInk, v.bodyBg);
    if (!(v.theme === 'dark' && v.paper !== seen[c.id].paper && contrast >= 4.5))
      darkBad.push(c.name + ':' + contrast + '/' + v.paper);
  }
  t(darkBad.length === 0,
    'هر تم حالتِ شبِ خودش را دارد و آن‌جا هم خوانا است', darkBad.join(' | ') || 'همه خوب');
  await p.evaluate(() => document.getElementById('themeBtn').click());
  await p.waitForTimeout(600);

  /* ماندگاری */
  await p.evaluate(() => document.querySelector('[data-kt-pick="sea"]').click());
  await p.waitForTimeout(2200);
  await p.goto(BASE + w.page, { waitUntil: 'networkidle' });
  await p.waitForTimeout(2900);
  const kept = await look();
  t(kept.kt === 'sea' && kept.inState === 'sea',
    'تم بعد از باز شدنِ دوبارهٔ صفحه سرِ جایش است', kept.kt);
  const lsKey = await p.evaluate(() => {
    const out = [];
    for (let i = 0; i < localStorage.length; i++) {
      const k = localStorage.key(i);
      if (/:kt$/.test(k)) out.push(k + '=' + localStorage.getItem(k));
    }
    return out.join(',');
  });
  t(/:kt=sea/.test(lsKey) && !/^kartabl:kt/.test(lsKey),
    'و کلیدِ مرورگرش مالِ همین کارتابل است، نه مشترک با بقیه', lsKey);

  /* برگشت به کلاسیک */
  await p.evaluate(() => document.querySelector('.navbtn[data-view="settings"]').click());
  await p.waitForTimeout(700);
  await p.evaluate(() => document.querySelector('[data-kt-pick=""]').click());
  await p.waitForTimeout(600);
  const home = await look();
  t(!home.kt && home.paper === base.paper,
    'و با «کلاسیک» همه‌چیز به حالتِ اول برمی‌گردد', home.paper);

  /* ---------- رنگِ نمودارها ---------- */
  console.log('--- رنگِ نمودارها ---');
  const tone = await p.evaluate(() => {
    const l = chartTone();
    document.documentElement.setAttribute('data-theme', 'dark');
    const d = chartTone();
    document.documentElement.removeAttribute('data-theme');
    return { l, d };
  });
  t(tone.l.doing === '#2E86F0' && tone.l.todo === '#E8A200' && tone.l.done === '#1FA05C',
    'گامِ روشن‌ترِ نمودارها نشست: آبیِ روشن، زردِ طلایی، سبزِ زنده',
    [tone.l.done, tone.l.doing, tone.l.todo].join(' '));
  t(tone.d.doing === '#5AA8FF' && tone.d.todo === '#F2C033',
    'و در شب هم همان‌ها، روشن‌تر', [tone.d.done, tone.d.doing, tone.d.todo].join(' '));
  /* ct() رنگِ rgb()ِ مرورگر را می‌خواند، نه هگز — این‌جا خودِ هگزها
     را می‌سنجیم: پنج رنگِ جدا، و هیچ‌کدام با رنگِ وضعیت‌ها یکی نیست. */
  const hexOk = v => /^#[0-9A-F]{6}$/i.test(v);
  t(tone.l.cat.length === 5 && tone.l.cat.every(hexOk) &&
    new Set(tone.l.cat).size === 5 && new Set(tone.d.cat).size === 5,
    'پنج رنگِ «هویت» هم سرِ جایشان‌اند و از هم جدا', tone.l.cat.join(' '));
  /* تم نباید رنگِ معنادارِ نمودار را عوض کند */
  await p.evaluate(() => document.querySelector('.navbtn[data-view="settings"]').click());
  await p.waitForTimeout(500);
  await p.evaluate(() => document.querySelector('[data-kt-pick="sunset"]').click());
  await p.waitForTimeout(500);
  const tone2 = await p.evaluate(() => chartTone());
  t(tone2.done === tone.l.done && tone2.doing === tone.l.doing && tone2.todo === tone.l.todo,
    'و عوض کردنِ تم، معنیِ رنگِ نمودارها را دست نمی‌زند',
    [tone2.done, tone2.doing, tone2.todo].join(' '));
  await p.evaluate(() => document.querySelector('[data-kt-pick=""]').click());
  await p.waitForTimeout(1500);
  await p.close();
  console.log('');
}

t(errs.length === 0, 'و هیچ خطای جاوااسکریپتی نبود', errs.join(' | ') || '—');
await b.close();
console.log((bad ? 'BAD ' + bad : 'همه خوب') + '  —  ' + ok + ' ok, ' + bad + ' bad');
process.exit(bad ? 1 : 0);
