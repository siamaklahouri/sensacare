/* پوستهٔ همهٔ کارتابل‌ها باید یکی باشد — در روشن و در تاریک.

   این آزمون برای همان چیزی نوشته شد که کاربر دید: قالبِ فنی و مالی
   سال‌ها جدا دست‌کاری شده بودند و کم‌کم دو جور شده بودند. پس به‌جای
   چشم، عدد: همان مقدارهایی که مرورگر واقعاً حساب می‌کند از هر صفحه
   خوانده و با کارتابلِ سیامک سنجیده می‌شود.

   فهرستِ کارتابل‌ها از خودِ سرور می‌آید، نه از یک فهرستِ سفت این‌جا:
   کارتابلی که فردا ساخته شود هم همین‌جا بررسی می‌شود. برای همین
   «عمومی» هم لازم است — قالبی که کارتابل‌های تازه از آن ساخته می‌شوند.

   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';

const BASE  = process.env.VS_BASE || 'http://127.0.0.1:8911';
const AUSER = process.env.VS_ADMIN || 'admin';
const APASS = process.env.VS_ADMIN_PASS || 'adminadminadmin';
const PASS  = 'themecheck-1405';
const REF   = process.env.VS_REF || 'siamak';   /* همه با این سنجیده می‌شوند */

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

/* ---- فهرستِ کارتابل‌ها، و یک رمزِ موقت برای هرکدام ---- */
let ck = '';
async function api(path, opt) {
  const o = Object.assign({ headers: {} }, opt || {});
  o.headers = Object.assign({ 'Content-Type': 'application/json' }, o.headers, ck ? { cookie: ck } : {});
  const r = await fetch(BASE + path, o);
  for (const c of (r.headers.getSetCookie ? r.headers.getSetCookie() : [])) {
    const kv = c.split(';')[0], k = kv.split('=')[0];
    ck = ck.split('; ').filter(x => x && x.split('=')[0] !== k).concat([kv]).join('; ');
  }
  try { return await r.json(); } catch (e) { return {}; }
}
await api('/api/admin.planer/signin',
  { method: 'POST', body: JSON.stringify({ user: AUSER, password: APASS }) });
const list = (await api('/api/admin.planer/planners')).items || [];
const planners = list.filter(p => !p.closed);
for (const p of planners)
  await api('/api/admin.planer/planners/' + p.slug + '/password',
    { method: 'POST', body: JSON.stringify({ password: PASS }) });

console.log('کارتابل‌هایی که بررسی می‌شوند: ' +
  planners.map(p => p.name + ' (' + p.kind + ')').join('، '));
const kinds = [...new Set(planners.map(p => p.kind))];
t(kinds.length >= 3 && kinds.includes('it') && kinds.includes('fin') && kinds.includes('gen'),
  'هر سه قالب در این بررسی هستند: فنی، مالی و عمومی', kinds.join(', '));

const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });

/* یک ورود برای هر کارتابل، نه یکی برای هر حالتِ رنگ. حالت را روی همان
   صفحه عوض می‌کنیم: هم سریع‌تر است، هم آزمون را به سقفِ تعدادِ ورود
   نمی‌رساند — که یک بار رساند و نتیجه‌اش ۴۲۹ بود، نه یک ایرادِ واقعی. */
async function open(spec) {
  const p = await b.newPage({ viewport: { width: 1440, height: 950 } });
  await p.goto(BASE + '/' + spec.slug + '/');
  await p.evaluate(async ({ a, w }) => {
    await fetch('/api/' + a + '/login', { method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ password: w }) });
  }, { a: spec.api || spec.slug, w: PASS });
  await p.goto(BASE + '/' + spec.slug + '/', { waitUntil: 'networkidle' });
  await p.waitForTimeout(2600);
  return p;
}

/* یک صفحه، در یک حالتِ رنگ. مقدارها را خودِ مرورگر می‌دهد. */
async function read(p, dark) {
  await p.evaluate(d => document.documentElement.setAttribute('data-theme', d ? 'dark' : 'light'), dark);
  await p.waitForTimeout(500);

  const out = await p.evaluate(() => {
    const cs = getComputedStyle(document.documentElement);
    const body = getComputedStyle(document.body);
    const pick = (el, keys) => {
      if (!el) return null;
      const s = getComputedStyle(el), o = {};
      for (const k of keys) o[k] = s[k];
      return o;
    };
    const V = ['--radius', '--radius-sm', '--paper', '--paper-deep', '--card-border',
               '--line', '--shadow', '--shadow-lg', '--ink', '--ink-soft', '--ink-faint',
               '--white', '--brass', '--brass-deep'];
    const vars = {};
    for (const v of V) vars[v] = cs.getPropertyValue(v).trim();

    const stat = document.querySelector('.stat');
    const bar = stat ? getComputedStyle(stat, '::before') : null;
    const val = stat && (stat.querySelector('.val') || stat.querySelector('.stat-val'));
    const lbl = stat && (stat.querySelector('.lbl') || stat.querySelector('.stat-lbl'));
    return {
      vars,
      theme: document.documentElement.getAttribute('data-theme'),
      bodyBg: body.backgroundColor,
      bodyGradients: (body.backgroundImage.match(/radial-gradient/g) || []).length,
      bodyInk: body.color,
      panel: pick(document.querySelector('.panel'), ['borderRadius', 'boxShadow', 'backgroundColor', 'borderColor']),
      stat: pick(stat, ['borderRadius', 'padding', 'boxShadow', 'backgroundColor']),
      barTop: bar ? bar.top : null,
      barH: bar ? bar.height : null,
      barWide: !!(stat && bar && parseFloat(bar.width) > stat.getBoundingClientRect().width - 4),
      val: pick(val, ['fontSize', 'fontWeight', 'fontFamily']),
      valTinted: !!(val && getComputedStyle(val).color !== getComputedStyle(document.body).color),
      lbl: pick(lbl, ['fontSize', 'fontWeight']),
      sidebar: pick(document.querySelector('.sidebar'), ['width', 'paddingTop', 'backgroundColor']),
      topbar: pick(document.querySelector('.topbar'), ['height']),
      content: pick(document.querySelector('.content'), ['paddingTop', 'paddingRight']),
      title: pick(document.querySelector('.section-title'), ['fontSize', 'fontWeight', 'color']),
      navbtn: pick(document.querySelector('.navbtn'), ['borderRadius', 'fontSize']),
      btn: pick(document.querySelector('.btn'), ['borderRadius', 'fontSize', 'fontWeight']),
      wrap: pick(document.querySelector('.tbl-wrap'), ['borderRadius', 'backgroundColor']),
      th: pick(document.querySelector('thead th'), ['padding', 'letterSpacing', 'backgroundColor', 'color'])
    };
  });
  return out;
}

const KEYS = ['panel', 'stat', 'val', 'lbl', 'sidebar', 'topbar', 'content',
              'title', 'navbtn', 'btn', 'wrap', 'th'];

/* هر کارتابل یک بار باز می‌شود و تا آخرِ کار باز می‌ماند */
const pages = {};
for (const p of planners) pages[p.slug] = await open(p);

for (const dark of [false, true]) {
  const mode = dark ? 'تاریک' : 'روشن';
  console.log('\n======== حالتِ ' + mode + ' ========');
  const base = await read(pages[REF], dark);
  t(base.theme === (dark ? 'dark' : 'light'), 'حالتِ رنگ واقعاً ' + mode + ' است', base.theme);

  for (const p of planners) {
    if (p.slug === REF) continue;
    const got = await read(pages[p.slug], dark);
    console.log('--- ' + p.name + ' (' + p.kind + ') ---');

    const vbad = Object.keys(base.vars).filter(v => base.vars[v] !== got.vars[v]);
    t(vbad.length === 0, 'متغیرهای پوسته با سیامک یکی‌اند',
      vbad.length ? vbad.map(v => v + ': ' + base.vars[v] + ' ≠ ' + got.vars[v]).join(' | ') : Object.keys(base.vars).length + ' متغیر');

    t(base.bodyGradients === got.bodyGradients && base.bodyBg === got.bodyBg && base.bodyInk === got.bodyInk,
      'زمینه و رنگِ متن یکی است',
      got.bodyGradients + ' هاله، ' + got.bodyBg);

    const kbad = KEYS.filter(k => JSON.stringify(base[k]) !== JSON.stringify(got[k]));
    t(kbad.length === 0, 'پانل، کارت، نوار، دکمه و جدول یک شکل‌اند',
      kbad.length ? kbad.map(k => k + ': ' + JSON.stringify(base[k]) + ' ≠ ' + JSON.stringify(got[k])).join('\n          ') : KEYS.length + ' بخش');

    t(base.barTop === got.barTop && base.barH === got.barH && got.barWide,
      'نوارِ رنگی بالای کارت است و تمامِ عرضش را می‌گیرد',
      got.barTop + ' / ' + got.barH + ' / ' + got.barWide);
    t(got.valTinted === base.valTinted,
      'عددِ کارت همان‌طورِ سیامک رنگ گرفته', String(got.valTinted));
  }
}

await b.close();
console.log('\n' + (bad ? 'BAD ' + bad : 'همه درست') + '  (' + ok + ' تا درست)');
process.exit(bad ? 1 : 0);
