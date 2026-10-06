/* پوستهٔ هر دو کارتابل باید یکی باشد.
   این آزمون برای همان چیزی نوشته شد که کاربر دید: قالبِ فنی و مالی سال‌ها
   جدا دست‌کاری شده بودند و کم‌کم دو جور شده بودند — گوشهٔ ۱۴ در برابر ۱۲،
   زمینهٔ طیف‌دار در برابر خاکستریِ تخت، عددِ رنگی در برابر عددِ مشکی.

   پس به‌جای چشم، عدد: همان مقدارهایی که مرورگر واقعاً حساب می‌کند از هر
   دو صفحه خوانده و با هم سنجیده می‌شوند. اگر فردا کسی یکی را عوض کند و
   آن یکی را نه، همین‌جا معلوم می‌شود.

   سرورِ محلی را مثل server/vshare.setup.md بالا بیاورید. */
import { chromium } from '/tmp/claude-0/-home-user-Panel/baecccd1-044f-55d8-b6c3-2f90602c9aae/scratchpad/node_modules/playwright/index.mjs';

const BASE = process.env.VS_BASE || 'http://127.0.0.1:8911';
const PAGES = [
  { name: 'فنی (سیامک)',  page: '/siamak/', api: 'kartabl', pass: 'siamaksiamak' },
  { name: 'مالی (سینا)',  page: '/sina/',   api: 'sina',    pass: 'sinasinasina' }
];

let ok = 0, bad = 0;
const t = (c, m, d) => { console.log((c ? '   ok  ' : '   BAD ') + ' ' + m + (d !== undefined ? '  — ' + d : '')); c ? ok++ : bad++; };

const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });

async function read(spec) {
  const p = await b.newPage({ viewport: { width: 1440, height: 950 } });
  await p.goto(BASE + spec.page);
  await p.evaluate(async ({ a, w }) => {
    await fetch('/api/' + a + '/login', { method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ password: w }) });
  }, { a: spec.api, w: spec.pass });
  await p.goto(BASE + spec.page, { waitUntil: 'networkidle' });
  await p.waitForTimeout(3200);

  const out = await p.evaluate(() => {
    const cs = getComputedStyle(document.documentElement);
    const body = getComputedStyle(document.body);
    const pick = (el, keys) => {
      if (!el) return null;
      const s = getComputedStyle(el), o = {};
      for (const k of keys) o[k] = s[k];
      return o;
    };
    const stat = document.querySelector('.stat');
    const bar = stat ? getComputedStyle(stat, '::before') : null;
    const val = stat && (stat.querySelector('.val') || stat.querySelector('.stat-val'));
    const lbl = stat && (stat.querySelector('.lbl') || stat.querySelector('.stat-lbl'));
    return {
      vars: {
        radius: cs.getPropertyValue('--radius').trim(),
        radiusSm: cs.getPropertyValue('--radius-sm').trim(),
        paper: cs.getPropertyValue('--paper').trim(),
        paperDeep: cs.getPropertyValue('--paper-deep').trim(),
        cardBorder: cs.getPropertyValue('--card-border').trim(),
        line: cs.getPropertyValue('--line').trim(),
        shadow: cs.getPropertyValue('--shadow').trim(),
        shadowLg: cs.getPropertyValue('--shadow-lg').trim()
      },
      /* زمینه: همان دو هاله روی کاغذ. تصویرِ خالی یعنی صفحه تخت است. */
      bodyGradients: (body.backgroundImage.match(/radial-gradient/g) || []).length,
      bodyAttach: body.backgroundAttachment,
      panel: pick(document.querySelector('.panel'), ['borderRadius', 'boxShadow']),
      stat: pick(stat, ['borderRadius', 'padding', 'boxShadow']),
      /* نوارِ رنگی باید بالای کارت باشد و تمامِ عرضش را بگیرد */
      bar: bar ? { h: bar.height, top: bar.top, left: bar.left, right: bar.right } : null,
      barWide: !!(stat && bar && parseFloat(bar.width) > stat.getBoundingClientRect().width - 4),
      val: pick(val, ['fontSize', 'fontWeight', 'fontFamily']),
      /* عددِ کارت باید رنگِ خودِ کارت را بگیرد، نه رنگِ متنِ معمولی */
      valTinted: !!(val && getComputedStyle(val).color !== getComputedStyle(document.body).color),
      lbl: pick(lbl, ['fontSize', 'fontWeight']),
      sidebar: pick(document.querySelector('.sidebar'), ['width', 'paddingTop']),
      topbar: pick(document.querySelector('.topbar'), ['height']),
      content: pick(document.querySelector('.content'), ['paddingTop', 'paddingRight']),
      title: pick(document.querySelector('.section-title'), ['fontSize', 'fontWeight']),
      btn: pick(document.querySelector('.btn'), ['borderRadius', 'fontSize', 'fontWeight']),
      th: pick(document.querySelector('thead th'), ['padding', 'letterSpacing'])
    };
  });
  await p.close();
  return out;
}

const [A, B] = [await read(PAGES[0]), await read(PAGES[1])];

console.log('===== متغیرهای پوسته =====');
for (const k of Object.keys(A.vars))
  t(A.vars[k] === B.vars[k] && A.vars[k] !== '', k, A.vars[k] + (A.vars[k] === B.vars[k] ? '' : '  ≠  ' + B.vars[k]));

console.log('\n===== زمینه =====');
t(A.bodyGradients === 2 && B.bodyGradients === 2,
  'هر دو صفحه دو هالهٔ رنگی روی کاغذ دارند، نه خاکستریِ تخت',
  A.bodyGradients + ' / ' + B.bodyGradients);
t(A.bodyAttach === B.bodyAttach, 'و زمینه در هر دو ثابت می‌ماند', A.bodyAttach);

console.log('\n===== کارت و پانل =====');
const same = (k, g) => t(JSON.stringify(A[k]) === JSON.stringify(B[k]), g,
  JSON.stringify(A[k]) + (JSON.stringify(A[k]) === JSON.stringify(B[k]) ? '' : '\n        ≠ ' + JSON.stringify(B[k])));
same('panel', 'پانل‌ها یک گوشه و یک سایه دارند');
same('stat', 'کارت‌های عدد یک شکل‌اند');
t(A.bar && B.bar && A.bar.h === B.bar.h && A.bar.top === B.bar.top && A.bar.top === '0px',
  'نوارِ رنگی در هر دو، بالای کارت است', JSON.stringify(A.bar) + ' / ' + JSON.stringify(B.bar));
t(A.barWide && B.barWide, 'و تمامِ عرضِ کارت را می‌گیرد', A.barWide + ' / ' + B.barWide);
same('val', 'عددِ کارت یک اندازه و یک قلم دارد');
t(A.valTinted && B.valTinted, 'و در هر دو رنگِ خودِ کارت را گرفته، نه رنگِ متنِ معمولی');
same('lbl', 'برچسبِ کارت یک اندازه دارد');

console.log('\n===== چیدمان =====');
same('sidebar', 'ستونِ کنار یک پهنا دارد');
same('topbar', 'نوارِ بالا یک ارتفاع دارد');
same('content', 'فاصلهٔ محتوا یکی است');
same('title', 'عنوانِ بخش یک اندازه دارد');
same('btn', 'دکمه‌ها یک شکل‌اند');
same('th', 'سرِ جدول‌ها یکی است');

await b.close();
console.log('\n' + (bad ? 'BAD ' + bad : 'همه درست') + '  (' + ok + ' تا درست)');
process.exit(bad ? 1 : 0);
